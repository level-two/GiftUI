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
        guard current != forwardedWakeRequestCount else { return }
        let directive = scheduler!.record(wake!.requester.reasons, at: wakeClockMicroseconds)
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
