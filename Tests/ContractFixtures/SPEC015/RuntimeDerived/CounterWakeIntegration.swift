import GiftUI
@testable import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIRuntimeCore

// All state is physical caller-owned control storage. No requester contains a
// pointer or callback. Each mutation below ends before any runtime callback.
extension CounterControl {
    mutating func initializeCounterWake() {
        let p08Presence76: Bool;
        if case .none = wake {
            if case .none = scheduler {
                if !wakeEnabled { p08Presence76 = true } else { p08Presence76 = false }
            } else {
                p08Presence76 = false
            }
        } else {
            p08Presence76 = false
        }; precondition(p08Presence76)
        wake = ExecutionWakeAccumulator(requester: CounterWake())
        wakeEnabled = true
    }
    private mutating func recordHostDirective(_ result: Result<HostWakeDirective, HostWakePacingError>) {
        switch result {
        case .success(.requestWake): hostWakeRequests += 1
        case .success(.coalesced): break
        case .failure: preconditionFailure("counter wake clock/pacing contract")
        }
    }
    mutating func emitCounterWake(_ reasons: ExecutionWakeReasons, acceptedFact: Bool = false) {
        guard wakeEnabled else { disabledWakeRejections += 1; return }
        if acceptedFact {
            acceptedFactWakeRecords += 1
            if case .none = wakeFirstFactMicroseconds {
                wakeFirstFactMicroseconds = wakeClockMicroseconds
            }
        }
        wake!.accumulate(reasons)
        guard case .some = scheduler else { return }
        // Record every accepted fact independently of the canonical bit: a fact
        // behind semanticDirty still starts its own service-window deadline.
        if acceptedFact {
            let directive = scheduler!.recordAcceptedFact(at: wakeClockMicroseconds)
            recordHostDirective(directive)
        }
        let current = wake!.requester.requestCount
        // A reason added behind the outstanding bit emits no second requester
        // call, but its finite reason value must still reach host pending state.
        let directive = scheduler!.record(wake!.accumulatedReasons, at: wakeClockMicroseconds)
        recordHostDirective(directive)
        forwardedWakeRequestCount = current
    }
    mutating func takeCounterWakeAtIdleEntry() -> ExecutionWakeReasons {
        let p08ExactCase89: Bool;
        if case .idle = context.phase { p08ExactCase89 = true } else { p08ExactCase89 = false };
        precondition(p08ExactCase89)
        let taken = wake!.takeAtIdleOpportunity(phase: .idle)!
        wakeFirstFactMicroseconds = nil
        lastTakenWakeReasons = taken
        wakeTakes += 1
        return taken
    }
    mutating func establishCounterScheduler(report: HostAssemblyReport) {
        let p08Presence77: Bool;
        if wakeEnabled {
            if case .none = scheduler { p08Presence77 = true } else { p08Presence77 = false }
        } else {
            p08Presence77 = false
        }; precondition(p08Presence77)
        scheduler = CounterConstructionInputs.canonical.report.scheduler(report)
        // Startup opportunities already consumed their own notifications. Seed
        // only the still-pending canonical reasons and unconsumed fact deadline.
        if let firstFact = wakeFirstFactMicroseconds {
            let directive = scheduler!.recordAcceptedFact(at: firstFact)
            recordHostDirective(directive)
        }
        let reasons = wake!.accumulatedReasons
        if !reasons.isEmpty {
            let directive = scheduler!.record(reasons, at: wakeClockMicroseconds)
            recordHostDirective(directive)
        }
        forwardedWakeRequestCount = wake!.requester.requestCount
    }
    mutating func disableCounterWake() {
        wakeEnabled = false
        _ = wake?.takeAtIdleOpportunity(phase: .idle)
        wakeFirstFactMicroseconds = nil
        if case .some = scheduler {
            // Terminal refusal can happen inside an active scheduled cycle.
            // Completion below ends that opportunity before deferred quiescence.
            let result = scheduler!.quiesce()
            let p08Presence78: Bool;
            if case .none = result {
                p08Presence78 = true
            } else {
                if case .some(.reentrant) = result {
                    p08Presence78 = true
                } else {
                    p08Presence78 = false
                }
            }; precondition(p08Presence78)
        }
    }
}

extension CounterHostControl {
    borrowing func beginScheduledOpportunity(at timestamp: UInt64, lifecycleState: MVPHostLifecycleState, report: HostAssemblyReport) -> HostScheduledOpportunityBeginResult {
        precondition(timestamp >= pointer.pointee.wakeClockMicroseconds)
        pointer.pointee.wakeClockMicroseconds = timestamp
        return pointer.pointee.scheduler!.begin(at: timestamp, lifecycleState: lifecycleState, assemblyReport: report)
    }
    borrowing func completeScheduledOpportunity(at timestamp: UInt64, reasons: ExecutionWakeReasons, result: HostOpportunityResult<RuntimeOwnerFailure>) -> HostScheduledOpportunityResult<RuntimeOwnerFailure> {
        let completed = pointer.pointee.scheduler!.complete(at: timestamp, reasons: reasons, result: result)
        if !pointer.pointee.wakeEnabled {
            let p08Presence79: Bool;
            if case .none = pointer.pointee.scheduler!.quiesce() {
                p08Presence79 = true
            } else {
                p08Presence79 = false
            }; precondition(p08Presence79)
        }
        return completed
    }
}

func counterServiceHost<H: MVPHostInstance & ~Copyable & ~Escapable>(at timestamp: UInt64, host: inout H, control: borrowing CounterHostControl) -> HostScheduledOpportunityResult<RuntimeOwnerFailure> where H.OwnerFailure == RuntimeOwnerFailure {
    let reasons: ExecutionWakeReasons
    switch control.beginScheduledOpportunity(at: timestamp, lifecycleState: host.lifecycleState, report: host.assemblyReport) {
    case .noWork: return .noWork
    case .wait(let boundary): return .wait(untilMicroseconds: boundary)
    case .rejected(let error, let pacing): return .rejected(error, pacing: pacing)
    case .began(let accumulated): reasons = accumulated
    }
    // No scheduler/control inout borrow spans runtime or application callbacks.
    let result = host.runOpportunity()
    return control.completeScheduledOpportunity(at: timestamp, reasons: reasons, result: result)
}

// Required integration controls run through the actual active scoped hosts.
// Finite boundary injection models an admitted producer callback after sealing;
// it never mutates the root or runs application work inside the mutation domain.
func counterWakeControls<H: MVPHostInstance & ~Copyable & ~Escapable>(host: inout H, control: UnsafeMutablePointer<CounterControl>) -> Int where H.OwnerFailure == RuntimeOwnerFailure {
    let access = CounterHostControl(pointer: control)
    var admission = CounterAdmission(borrowing: control)
    var timestamp = control.pointee.wakeClockMicroseconds
    var checks = 0
    func expect(_ value: Bool) { checks += 1; if !value {
    #if !hasFeature(Embedded)
    print("counter wake control failed", checks)
    #endif
    }; precondition(value) }
    // Rejection outcomes alone do not prove queued-only notification. Observe
    // the actual canonical owner, pacing inputs and runtime before each call.
    func expectNoWake(_ expected: ExecutionAdmissionResult, submit: () -> ExecutionAdmissionOutcome) {
        let requests = control.pointee.wake!.requester.requestCount
        let reasons = control.pointee.wake!.accumulatedReasons
        let outstanding = control.pointee.wake!.wakeOutstanding
        let hostRequests = control.pointee.hostWakeRequests
        let factRecords = control.pointee.acceptedFactWakeRecords
        let firstFact = control.pointee.wakeFirstFactMicroseconds
        let clock = control.pointee.wakeClockMicroseconds
        let takes = control.pointee.wakeTakes
        let finalized = control.pointee.finalized
        let applied = control.pointee.applied
        let disabled = control.pointee.disabledWakeRejections
        expect(submit().result == expected)
        expect(control.pointee.wake!.requester.requestCount == requests)
        expect(control.pointee.wake!.accumulatedReasons == reasons)
        expect(control.pointee.wake!.wakeOutstanding == outstanding)
        expect(control.pointee.hostWakeRequests == hostRequests)
        expect(control.pointee.acceptedFactWakeRecords == factRecords)
        expect(control.pointee.wakeFirstFactMicroseconds == firstFact)
        expect(control.pointee.wakeClockMicroseconds == clock)
        expect(control.pointee.wakeTakes == takes)
        expect(control.pointee.finalized == finalized)
        expect(control.pointee.applied == applied)
        expect(control.pointee.disabledWakeRejections == disabled)
    }
    let revision = control.pointee.runtime.committedPresentation!
    expectNoWake(.invalidValue) { admission.submit(stateChange: 10) }
    expectNoWake(.invalidValue) { admission.submit(completion: 1) }
    expectNoWake(.invalidProvenance) { admission.submit(pointer: .init(phase: .down, position: .init(x: 99, y: 119), source: .init(rawValue: 1), sequence: .init(rawValue: 0), ordinal: .init(rawValue: 0), presentationRevision: .init(rawValue: revision.rawValue + 1))) }
    let initialFinalized = control.pointee.finalized
    let initialApplied = control.pointee.applied
    let factRecords = control.pointee.acceptedFactWakeRecords
    let requests = control.pointee.wake!.requester.requestCount
    let hostRequests = control.pointee.hostWakeRequests
    control.pointee.emitCounterWake(.semanticDirty)
    control.pointee.emitCounterWake(.presentationPending)
    let beforeReportRejection = counterJoinSnapshot(control)
    let p08ExactCase90: Bool;
    if case .rejected(.assemblyReportMismatch, pacing: nil) = control.pointee.scheduler!.begin(
        at: timestamp, lifecycleState: host.lifecycleState,
        assemblyReport: counterJoinReport(host.assemblyReport))
    {
        p08ExactCase90 = true
    } else {
        p08ExactCase90 = false
    }; expect(p08ExactCase90)
    expect(counterJoinSnapshot(control) == beforeReportRejection)
    // Five independently accepted notifications span all three fact categories.
    // Every supplied clock reaches pacing, while the first fact keeps its deadline.
    func expectAcceptedFact(_ count: Int) {
        expect(control.pointee.acceptedFactWakeRecords == factRecords + count)
        expect(control.pointee.wakeFirstFactMicroseconds == timestamp + 10)
        expect(control.pointee.wake!.accumulatedReasons.rawValue == 7 && control.pointee.wake!.wakeOutstanding)
        expect(control.pointee.wake!.requester.requestCount == requests + 1 && control.pointee.hostWakeRequests == hostRequests + 1)
        expect(control.pointee.finalized == initialFinalized && control.pointee.applied == initialApplied)
        var priorClock = control.pointee.scheduler!
        let p08ExactCase91: Bool;
        if case .rejected(.pacingRejected, pacing: .some(.timeRegression)) = priorClock.begin(
            at: control.pointee.wakeClockMicroseconds - 1, lifecycleState: host.lifecycleState,
            assemblyReport: host.assemblyReport)
        {
            p08ExactCase91 = true
        } else {
            p08ExactCase91 = false
        }; expect(p08ExactCase91)
    }
    control.pointee.wakeClockMicroseconds = timestamp + 10
    let p08ExactCase92: Bool;
    if case .queued = admission.submit(stateChange: 0).result {
        p08ExactCase92 = true
    } else {
        p08ExactCase92 = false
    }; expect(p08ExactCase92)
    expectAcceptedFact(1)
    control.pointee.wakeClockMicroseconds = timestamp + 20
    let p08ExactCase93: Bool;
    if case .queued = admission.submit(stateChange: 0).result {
        p08ExactCase93 = true
    } else {
        p08ExactCase93 = false
    }; expect(p08ExactCase93)
    expectAcceptedFact(2)
    control.pointee.wakeClockMicroseconds = timestamp + 30
    let p08ExactCase94: Bool;
    if case .queued = admission.submit(completion: 0).result {
        p08ExactCase94 = true
    } else {
        p08ExactCase94 = false
    }; expect(p08ExactCase94)
    expectAcceptedFact(3)
    control.pointee.wakeClockMicroseconds = timestamp + 40
    guard case .queued = control.pointee.inputGate.submit(phase: .down, position: .init(x: 99, y: 119), source: .init(rawValue: 0), observedPresentationRevision: revision, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &admission) else { preconditionFailure("counter multi-category down") }
    expectAcceptedFact(4)
    control.pointee.wakeClockMicroseconds = timestamp + 50
    guard case .queued = control.pointee.inputGate.submit(phase: .up, position: .init(x: 99, y: 119), source: .init(rawValue: 0), observedPresentationRevision: revision, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &admission) else { preconditionFailure("counter multi-category up") }
    expectAcceptedFact(5)
    expectNoWake(.invalidValue) { admission.submit(stateChange: 10) }
    expectNoWake(.invalidValue) { admission.submit(completion: 1) }
    expectNoWake(.invalidProvenance) { admission.submit(pointer: .init(phase: .down, position: .init(x: 99, y: 119), source: .init(rawValue: 1), sequence: .init(rawValue: 0), ordinal: .init(rawValue: 0), presentationRevision: .init(rawValue: revision.rawValue + 1))) }
    expectNoWake(.capacityRefused) { admission.submit(completion: 0) }
    expectNoWake(.capacityRefused) { admission.submit(pointer: .init(phase: .down, position: .init(x: 99, y: 119), source: .init(rawValue: 1), sequence: .init(rawValue: 0), ordinal: .init(rawValue: 0), presentationRevision: revision)) }
    var atDeadline = control.pointee.scheduler!
    expect(atDeadline.begin(at: timestamp + 250010, lifecycleState: host.lifecycleState, assemblyReport: host.assemblyReport) == .began(.init(rawValue: 7)))
    expect(control.pointee.wake!.accumulatedReasons.rawValue == 7)
    expect(control.pointee.wake!.requester.requestCount == requests + 1)
    expect(control.pointee.hostWakeRequests == hostRequests + 1)
    expect(control.pointee.finalized == initialFinalized)
    // Copy the actual scheduler value only for a destructive negative timestamp
    // check; the actual scheduler below still services within the exact deadline.
    var missed = control.pointee.scheduler!
    let p08ExactCase95: Bool;
    if case .rejected(.pacingRejected, pacing: .some(.serviceDeadlineMissed)) = missed.begin(
        at: timestamp + 250011, lifecycleState: host.lifecycleState,
        assemblyReport: host.assemblyReport)
    {
        p08ExactCase95 = true
    } else {
        p08ExactCase95 = false
    }; expect(p08ExactCase95)
    do {
        let service = counterServiceHost(at: timestamp + 249999, host: &host, control: access)
        let expectedDeadline = timestamp + 250000
        let matchesExpectedWait: Bool
        if case .wait(let deadline) = service {
            matchesExpectedWait = deadline == expectedDeadline
        } else {
            matchesExpectedWait = false
        }
        expect(matchesExpectedWait)
    }
    timestamp += 250000
    guard case .cycle(let reasons, .cycle(.success(let coalesced))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter coalesced reason service") }
    expect(coalesced.admission.inputEventCount == 2 && coalesced.admission.stateChangeFactCount == 2 && coalesced.admission.completionFactCount == 1 && coalesced.admission.semanticActionCount == 0)
    expect(reasons.rawValue == 7 && control.pointee.lastTakenWakeReasons == reasons)
    let p08Presence80: Bool;
    if !control.pointee.wake!.wakeOutstanding {
        if case .none = control.pointee.wakeFirstFactMicroseconds {
            p08Presence80 = true
        } else {
            p08Presence80 = false
        }
    } else {
        p08Presence80 = false
    }; expect(p08Presence80)

    // Counter-specific scalar capacity: this is34/35, never analyzer compact32/33.
    let burstFacts = control.pointee.acceptedFactWakeRecords
    let burstRequests = control.pointee.wake!.requester.requestCount
    let burstFinalized = control.pointee.finalized
    for _ in 0 ..< 34 {
        let p08ExactCase96: Bool;
        if case .queued = admission.submit(stateChange: 0).result {
            p08ExactCase96 = true
        } else {
            p08ExactCase96 = false
        }; expect(p08ExactCase96)
    }
    expect(control.pointee.runtime.admission.pendingStateCount == 34 && control.pointee.acceptedFactWakeRecords == burstFacts + 34)
    expect(control.pointee.wakeFirstFactMicroseconds == timestamp && control.pointee.wake!.requester.requestCount == burstRequests + 1)
    expect(control.pointee.finalized == burstFinalized)
    expectNoWake(.capacityRefused) { admission.submit(stateChange: 0) }
    timestamp += 250000
    guard case .cycle(.admittedWork, .cycle(.success(let burst))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter scalar34 service") }
    expect(burst.admission.stateChangeFactCount == 34 && burst.admission.inputEventCount == 0 && burst.admission.completionFactCount == 0 && burst.admission.semanticActionCount == 0)
    expect(control.pointee.runtime.admission.pendingStateCount == 0 && !control.pointee.wake!.wakeOutstanding)

    // One callback during the active cycle is admitted only for the next seal.
    control.pointee.injectCompletionAtApply = true
    let p08ExactCase97: Bool;
    if case .queued = admission.submit(stateChange: 0).result {
        p08ExactCase97 = true
    } else {
        p08ExactCase97 = false
    }; expect(p08ExactCase97)
    let beforeLate = control.pointee.wake!.requester.requestCount
    timestamp += 250000
    guard case .cycle(_, .cycle(.success(let during))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter late callback cycle") }
    expect(during.admission.completionFactCount == 0)
    expect(control.pointee.runtime.admission.pendingCompletion == 0)
    expect(control.pointee.admissionController!.didDeferAfterSeal)
    expect(control.pointee.lateCallbackObservedActive && control.pointee.lateCallbackDidNotRunRuntime)
    expect(control.pointee.wake!.wakeOutstanding && control.pointee.wake!.requester.requestCount == beforeLate + 1)
    do {
        let service = counterServiceHost(at: timestamp, host: &host, control: access)
        let expectedDeadline = timestamp + 250000
        let matchesExpectedWait: Bool
        if case .wait(let deadline) = service {
            matchesExpectedWait = deadline == expectedDeadline
        } else {
            matchesExpectedWait = false
        }
        expect(matchesExpectedWait)
    }
    timestamp += 250000
    guard case .cycle(.admittedWork, .cycle(.success(let later))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter next paced callback seal") }
    expect(later.admission.completionFactCount == 1 && later.admission.stateChangeFactCount == 0)
    let p08Presence81: Bool;
    if case .none = control.pointee.runtime.admission.pendingCompletion {
        p08Presence81 = true
    } else {
        p08Presence81 = false
    }; expect(p08Presence81)

    // Real mutation followed by layout failure emits dirty recovery. No fact is
    // replayed by the subsequent opportunity that derives the retained model.
    let beforeMutation = control.pointee.applied
    let p08ExactCase98: Bool;
    if case .queued = admission.submit(stateChange: 1).result {
        p08ExactCase98 = true
    } else {
        p08ExactCase98 = false
    }; expect(p08ExactCase98)
    control.pointee.fault = .layout
    timestamp += 250000
    guard case .cycle(_, .cycle(.failure(_, .execution(.capacityExhausted), let dirty?))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter dirty failure wake") }
    let p08ExactCase99: Bool;
    if case .dirty = dirty.semanticDisposition {
        p08ExactCase99 = true
    } else {
        p08ExactCase99 = false
    }; expect(p08ExactCase99)
    expect(control.pointee.wake!.accumulatedReasons == .semanticDirty && control.pointee.applied == beforeMutation + 1)
    control.pointee.fault = nil
    timestamp += 250000
    guard case .cycle(.semanticDirty, .cycle(.success(let recovered))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter dirty paced recovery") }
    expect(recovered.admission.stateChangeFactCount == 0 && recovered.admission.includesDirtyRederivation)
    expect(control.pointee.applied == beforeMutation + 1)

    // Actual endpoint backpressure retains one intent and wakes a fresh paced
    // attempt with no admitted fact/action replay.
    let p08ExactCase100: Bool;
    if case .queued = admission.submit(stateChange: 2).result {
        p08ExactCase100 = true
    } else {
        p08ExactCase100 = false
    }; expect(p08ExactCase100)
    control.pointee.offer = .backpressured
    timestamp += 250000
    guard case .cycle(_, .cycle(.operational(.backpressured, let pending))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter actual backpressure") }
    expect(pending.presentationPending?.retryableRefusalCount == 0)
    expect(control.pointee.wake!.accumulatedReasons == .presentationPending)
    let afterBackpressure = control.pointee.applied
    let olderIntent = pending.presentationPending!.semanticRevision
    let p08ExactCase101: Bool;
    if case .queued = admission.submit(stateChange: 4).result {
        p08ExactCase101 = true
    } else {
        p08ExactCase101 = false
    }; expect(p08ExactCase101)
    timestamp += 250000
    guard case .cycle(_, .cycle(.operational(.backpressured, let superseding))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter actual supersession") }
    expect(superseding.operationalEvents.contains(.superseded))
    expect(superseding.semanticRevision != olderIntent && superseding.presentationPending?.semanticRevision == superseding.semanticRevision)
    expect(superseding.presentationPending?.retryableRefusalCount == 0)
    expect(superseding.admission.stateChangeFactCount == 1 && superseding.admission.inputEventCount == 0 && superseding.admission.completionFactCount == 0 && superseding.admission.semanticActionCount == 0)
    expect(control.pointee.applied == afterBackpressure + 1 && control.pointee.runtime.admission.pendingStateCount == 0)
    let afterSupersession = control.pointee.applied
    control.pointee.offer = .accepted
    timestamp += 250000
    guard case .cycle(.presentationPending, .cycle(.success(let accepted))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter actual backpressure recovery") }
    expect(accepted.admission.stateChangeFactCount == 0 && accepted.admission.inputEventCount == 0 && accepted.admission.completionFactCount == 0 && accepted.admission.semanticActionCount == 0 && accepted.admission.includesPresentationRecovery)
    let p08Presence82: Bool;
    if case .none = accepted.presentationPending {
        if control.pointee.applied == afterSupersession {
            p08Presence82 = true
        } else {
            p08Presence82 = false
        }
    } else {
        p08Presence82 = false
    }; expect(p08Presence82)
    let p08ExactCase102: Bool;
    if case .noWork = counterServiceHost(at: timestamp, host: &host, control: access) {
        p08ExactCase102 = true
    } else {
        p08ExactCase102 = false
    }; expect(p08ExactCase102)

    if control.pointee.terminalRetry {
        // Additional fresh host: actual endpoint refuses without invoking body.
        let p08ExactCase103: Bool;
        if case .queued = admission.submit(stateChange: 3).result {
            p08ExactCase103 = true
        } else {
            p08ExactCase103 = false
        }; expect(p08ExactCase103)
        control.pointee.offer = .nonRetryableRefusal
        let streams = control.pointee.streams
        let applied = control.pointee.applied
        timestamp += 250000
        guard case .cycle(_, .cycle(.failure(_, .nonRetryableRefusal(.endpoint), let refused?))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter actual nonretryable refusal") }
        let p08Presence83: Bool;
        if case .unavailable = refused.presentationIntentState {
            if case .none = refused.presentationPending {
                p08Presence83 = true
            } else {
                p08Presence83 = false
            }
        } else {
            p08Presence83 = false
        }; expect(p08Presence83)
        expect(refused.admission.stateChangeFactCount == 1 && refused.admission.inputEventCount == 0 && refused.admission.completionFactCount == 0 && refused.admission.semanticActionCount == 0)
        expect(control.pointee.applied == applied + 1 && control.pointee.streams == streams)
        let p08Presence84: Bool;
        if control.pointee.runtime.admission.pendingStateCount == 0 {
            if case .none = control.pointee.runtime.pointer.capture.current {
                p08Presence84 = true
            } else {
                p08Presence84 = false
            }
        } else {
            p08Presence84 = false
        }; expect(p08Presence84)
    } else {
        // Same actual endpoint refuses three paced attempts. Count three is terminal;
        // no notification survives or invokes the runtime after teardown.
        let p08ExactCase104: Bool;
        if case .queued = admission.submit(stateChange: 3).result {
            p08ExactCase104 = true
        } else {
            p08ExactCase104 = false
        }; expect(p08ExactCase104)
        control.pointee.offer = .retryableRefusal
        for count: UInt8 in 1...3 {
            timestamp += 250000
            guard case .cycle(_, .cycle(.operational(.retryableRefusal, let refusal))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter actual refusal recovery") }
            expect(refusal.admission.stateChangeFactCount == (count == 1 ? 1 : 0))
            expect(refusal.presentationPending?.retryableRefusalCount == (count < 3 ? count : nil))
            expect(refusal.presentationIntentState == (count < 3 ? .pending : .unavailable))
        }
    }
    expect(!control.pointee.wakeEnabled && !control.pointee.wake!.wakeOutstanding && !control.pointee.inputGate.inputIsEligible)
    let stoppedRequests = control.pointee.wake!.requester.requestCount
    let stoppedFinalized = control.pointee.finalized
    expectNoWake(.unavailable) { admission.submit(stateChange: 0) }
    expectNoWake(.unavailable) { admission.submit(completion: 0) }
    expectNoWake(.unavailable) { admission.submit(pointer: .init(phase: .down, position: .init(x: 99, y: 119), source: .init(rawValue: 1), sequence: .init(rawValue: 0), ordinal: .init(rawValue: 0), presentationRevision: revision)) }
    control.pointee.emitCounterWake(.admittedWork, acceptedFact: true)
    expect(control.pointee.wake!.requester.requestCount == stoppedRequests && control.pointee.finalized == stoppedFinalized)
    let p08ExactCase105: Bool;
    if case .rejected(.pacingRejected, pacing: .some(.unavailable)) = counterServiceHost(
        at: timestamp + 250000, host: &host, control: access)
    {
        p08ExactCase105 = true
    } else {
        p08ExactCase105 = false
    }; expect(p08ExactCase105)
    return checks
}
