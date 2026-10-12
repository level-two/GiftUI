@testable import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIRuntimeCore

// All state is physical caller-owned control storage. No requester contains a
// pointer or callback. Each mutation below ends before any runtime callback.
extension CounterControl {
    mutating func initializeCounterWake() {
        precondition(wake == nil && scheduler == nil && !wakeEnabled)
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
            if wakeFirstFactMicroseconds == nil { wakeFirstFactMicroseconds = wakeClockMicroseconds }
        }
        wake!.accumulate(reasons)
        guard scheduler != nil else { return }
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
        precondition(context.phase == .idle)
        let taken = wake!.takeAtIdleOpportunity(phase: .idle)!
        wakeFirstFactMicroseconds = nil
        lastTakenWakeReasons = taken
        wakeTakes += 1
        return taken
    }
    mutating func establishCounterScheduler(report: HostAssemblyReport) {
        precondition(wakeEnabled && scheduler == nil)
        scheduler = HostScheduledOpportunityController(assemblyReport: report, initialFrameOriginMicroseconds: 0)
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
        if scheduler != nil {
            // Terminal refusal can happen inside an active scheduled cycle.
            // Completion below ends that opportunity before deferred quiescence.
            let result = scheduler!.quiesce()
            precondition(result == nil || result == .reentrant)
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
        if !pointer.pointee.wakeEnabled { precondition(pointer.pointee.scheduler!.quiesce() == nil) }
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
    func expect(_ value: Bool) { checks += 1; if !value { print("counter wake control failed", checks) }; precondition(value) }
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
    expect(control.pointee.scheduler!.begin(at: timestamp, lifecycleState: host.lifecycleState, assemblyReport: counterJoinReport(host.assemblyReport)) == .rejected(.assemblyReportMismatch, pacing: nil))
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
        expect(priorClock.begin(at: control.pointee.wakeClockMicroseconds - 1, lifecycleState: host.lifecycleState, assemblyReport: host.assemblyReport) == .rejected(.pacingRejected, pacing: .timeRegression))
    }
    control.pointee.wakeClockMicroseconds = timestamp + 10
    expect(admission.submit(stateChange: 0).result == .queued)
    expectAcceptedFact(1)
    control.pointee.wakeClockMicroseconds = timestamp + 20
    expect(admission.submit(stateChange: 0).result == .queued)
    expectAcceptedFact(2)
    control.pointee.wakeClockMicroseconds = timestamp + 30
    expect(admission.submit(completion: 0).result == .queued)
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
    expect(missed.begin(at: timestamp + 250011, lifecycleState: host.lifecycleState, assemblyReport: host.assemblyReport) == .rejected(.pacingRejected, pacing: .serviceDeadlineMissed))
    expect(counterServiceHost(at: timestamp + 249999, host: &host, control: access) == .wait(untilMicroseconds: timestamp + 250000))
    timestamp += 250000
    guard case .cycle(let reasons, .cycle(.success(let coalesced))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter coalesced reason service") }
    expect(coalesced.admission.inputEventCount == 2 && coalesced.admission.stateChangeFactCount == 2 && coalesced.admission.completionFactCount == 1 && coalesced.admission.semanticActionCount == 0)
    expect(reasons.rawValue == 7 && control.pointee.lastTakenWakeReasons == reasons)
    expect(!control.pointee.wake!.wakeOutstanding && control.pointee.wakeFirstFactMicroseconds == nil)

    // Counter-specific scalar capacity: this is34/35, never analyzer compact32/33.
    let burstFacts = control.pointee.acceptedFactWakeRecords
    let burstRequests = control.pointee.wake!.requester.requestCount
    let burstFinalized = control.pointee.finalized
    for _ in 0..<34 { expect(admission.submit(stateChange: 0).result == .queued) }
    expect(control.pointee.admission.pendingStateCount == 34 && control.pointee.acceptedFactWakeRecords == burstFacts + 34)
    expect(control.pointee.wakeFirstFactMicroseconds == timestamp && control.pointee.wake!.requester.requestCount == burstRequests + 1)
    expect(control.pointee.finalized == burstFinalized)
    expectNoWake(.capacityRefused) { admission.submit(stateChange: 0) }
    timestamp += 250000
    guard case .cycle(.admittedWork, .cycle(.success(let burst))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter scalar34 service") }
    expect(burst.admission.stateChangeFactCount == 34 && burst.admission.inputEventCount == 0 && burst.admission.completionFactCount == 0 && burst.admission.semanticActionCount == 0)
    expect(control.pointee.admission.pendingStateCount == 0 && !control.pointee.wake!.wakeOutstanding)

    // One callback during the active cycle is admitted only for the next seal.
    control.pointee.injectCompletionAtApply = true
    expect(admission.submit(stateChange: 0).result == .queued)
    let beforeLate = control.pointee.wake!.requester.requestCount
    timestamp += 250000
    guard case .cycle(_, .cycle(.success(let during))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter late callback cycle") }
    expect(during.admission.completionFactCount == 0)
    expect(control.pointee.admission.pendingCompletion == 0)
    expect(control.pointee.admissionController!.didDeferAfterSeal)
    expect(control.pointee.lateCallbackObservedActive && control.pointee.lateCallbackDidNotRunRuntime)
    expect(control.pointee.wake!.wakeOutstanding && control.pointee.wake!.requester.requestCount == beforeLate + 1)
    expect(counterServiceHost(at: timestamp, host: &host, control: access) == .wait(untilMicroseconds: timestamp + 250000))
    timestamp += 250000
    guard case .cycle(.admittedWork, .cycle(.success(let later))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter next paced callback seal") }
    expect(later.admission.completionFactCount == 1 && later.admission.stateChangeFactCount == 0)
    expect(control.pointee.admission.pendingCompletion == nil)

    // Real mutation followed by layout failure emits dirty recovery. No fact is
    // replayed by the subsequent opportunity that derives the retained model.
    let beforeMutation = control.pointee.applied
    expect(admission.submit(stateChange: 1).result == .queued)
    control.pointee.fault = .layout
    timestamp += 250000
    guard case .cycle(_, .cycle(.failure(_, .execution(.capacityExhausted), let dirty?))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter dirty failure wake") }
    expect(dirty.semanticDisposition == .dirty)
    expect(control.pointee.wake!.accumulatedReasons == .semanticDirty && control.pointee.applied == beforeMutation + 1)
    control.pointee.fault = nil
    timestamp += 250000
    guard case .cycle(.semanticDirty, .cycle(.success(let recovered))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter dirty paced recovery") }
    expect(recovered.admission.stateChangeFactCount == 0 && recovered.admission.includesDirtyRederivation)
    expect(control.pointee.applied == beforeMutation + 1)

    // Actual endpoint backpressure retains one intent and wakes a fresh paced
    // attempt with no admitted fact/action replay.
    expect(admission.submit(stateChange: 2).result == .queued)
    control.pointee.offer = .backpressured
    timestamp += 250000
    guard case .cycle(_, .cycle(.operational(.backpressured, let pending))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter actual backpressure") }
    expect(pending.presentationPending?.retryableRefusalCount == 0)
    expect(control.pointee.wake!.accumulatedReasons == .presentationPending)
    let afterBackpressure = control.pointee.applied
    control.pointee.offer = .accepted
    timestamp += 250000
    guard case .cycle(.presentationPending, .cycle(.success(let accepted))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter actual backpressure recovery") }
    expect(accepted.admission.stateChangeFactCount == 0 && accepted.admission.includesPresentationRecovery)
    expect(accepted.presentationPending == nil && control.pointee.applied == afterBackpressure)
    expect(counterServiceHost(at: timestamp, host: &host, control: access) == .noWork)

    // Same actual endpoint refuses three paced attempts. Count three is terminal;
    // no notification survives or invokes the runtime after teardown.
    expect(admission.submit(stateChange: 3).result == .queued)
    control.pointee.offer = .retryableRefusal
    for count: UInt8 in 1...3 {
        timestamp += 250000
        guard case .cycle(_, .cycle(.operational(.retryableRefusal, let refusal))) = counterServiceHost(at: timestamp, host: &host, control: access) else { preconditionFailure("counter actual refusal recovery") }
        expect(refusal.admission.stateChangeFactCount == (count == 1 ? 1 : 0))
        expect(refusal.presentationPending?.retryableRefusalCount == (count < 3 ? count : nil))
        expect(refusal.presentationIntentState == (count < 3 ? .pending : .unavailable))
    }
    expect(!control.pointee.wakeEnabled && !control.pointee.wake!.wakeOutstanding && !control.pointee.inputGate.inputIsEligible)
    let stoppedRequests = control.pointee.wake!.requester.requestCount
    let stoppedFinalized = control.pointee.finalized
    expectNoWake(.unavailable) { admission.submit(stateChange: 0) }
    expectNoWake(.unavailable) { admission.submit(completion: 0) }
    expectNoWake(.unavailable) { admission.submit(pointer: .init(phase: .down, position: .init(x: 99, y: 119), source: .init(rawValue: 1), sequence: .init(rawValue: 0), ordinal: .init(rawValue: 0), presentationRevision: revision)) }
    control.pointee.emitCounterWake(.admittedWork, acceptedFact: true)
    expect(control.pointee.wake!.requester.requestCount == stoppedRequests && control.pointee.finalized == stoppedFinalized)
    expect(counterServiceHost(at: timestamp + 250000, host: &host, control: access) == .rejected(.pacingRejected, pacing: .unavailable))
    return checks
}
