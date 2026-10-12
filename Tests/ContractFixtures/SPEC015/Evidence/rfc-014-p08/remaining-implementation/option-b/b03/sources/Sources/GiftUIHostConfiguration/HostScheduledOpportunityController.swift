import GiftUIExecution

package enum HostScheduledOpportunityError: UInt8, Error, Equatable, Sendable {
    case invalidLifecycle = 0
    case assemblyReportMismatch = 1
    case pacingRejected = 2
    case invalidRuntimeResult = 3
    case invalidCompletion = 4
}

package enum HostScheduledOpportunityResult<OwnerFailure: Equatable & Sendable>: Equatable, Sendable
{
    case noWork
    case wait(untilMicroseconds: UInt64)
    case cycle(reasons: ExecutionWakeReasons, result: HostOpportunityResult<OwnerFailure>)
    case rejected(HostScheduledOpportunityError, pacing: HostWakePacingError?)
}

// Begin and complete are separate short borrows when the instance's callbacks
// record new work into this same containing scheduler.
package enum HostScheduledOpportunityBeginResult: Equatable, Sendable {
    case noWork
    case wait(untilMicroseconds: UInt64)
    case began(ExecutionWakeReasons)
    case rejected(HostScheduledOpportunityError, pacing: HostWakePacingError?)
}

package struct HostScheduledOpportunityController: Sendable {
    package let assemblyReport: HostAssemblyReport
    private var pacing: HostWakePacingController

    package init(
        assemblyReport: HostAssemblyReport,
        initialFrameOriginMicroseconds: UInt64
    ) {
        self.assemblyReport = assemblyReport
        pacing = HostWakePacingController(
            policy: HostPacingPolicy(
                minimumFrameIntervalMicroseconds:
                    assemblyReport.minimumFrameIntervalMicroseconds,
                maximumFactServiceLatencyMicroseconds:
                    assemblyReport.maximumFactServiceLatencyMicroseconds,
                minimumAcceptedTransitionSpacingMicroseconds:
                    assemblyReport.minimumAcceptedTransitionSpacingMicroseconds,
                maximumTransitionFactsPerServiceWindow: 20,
                maximumBootstrapFactsPerServiceWindow: 2,
                maximumActionInducedFactsPerServiceWindow: 6,
                maximumRetryableRefusals: assemblyReport.maximumRetryableRefusals
            )!,
            initialFrameOriginMicroseconds: initialFrameOriginMicroseconds
        )
    }

    package mutating func recordAcceptedFact(
        at timestampMicroseconds: UInt64
    ) -> Result<HostWakeDirective, HostWakePacingError> {
        pacing.recordAcceptedFact(at: timestampMicroseconds)
    }

    package mutating func record(
        _ reasons: ExecutionWakeReasons,
        at timestampMicroseconds: UInt64
    ) -> Result<HostWakeDirective, HostWakePacingError> {
        pacing.record(reasons, at: timestampMicroseconds)
    }

    package mutating func begin(
        at timestampMicroseconds: UInt64,
        lifecycleState: MVPHostLifecycleState,
        assemblyReport: HostAssemblyReport
    ) -> HostScheduledOpportunityBeginResult {
        guard lifecycleState == .active else { return .rejected(.invalidLifecycle, pacing: nil) }
        guard assemblyReport == self.assemblyReport else {
            return .rejected(.assemblyReportMismatch, pacing: nil)
        }
        switch pacing.schedule(at: timestampMicroseconds) {
        case .noWork: return .noWork
        case .wait(let boundary): return .wait(untilMicroseconds: boundary)
        case .invalid(let error): return .rejected(.pacingRejected, pacing: error)
        case .run: break
        }
        switch pacing.beginOpportunity(at: timestampMicroseconds) {
        case .began(let reasons): return .began(reasons)
        case .rejected(let error): return .rejected(.pacingRejected, pacing: error)
        }
    }

    package mutating func complete<OwnerFailure: Equatable & Sendable>(
        at timestampMicroseconds: UInt64,
        reasons: ExecutionWakeReasons,
        result: HostOpportunityResult<OwnerFailure>
    ) -> HostScheduledOpportunityResult<OwnerFailure> {
        let completionError = pacing.completeOpportunity(at: timestampMicroseconds)
        guard completionError == nil else {
            return .rejected(.invalidCompletion, pacing: completionError)
        }
        guard result != .invalidLifecycle else {
            return .rejected(.invalidRuntimeResult, pacing: nil)
        }
        return .cycle(reasons: reasons, result: result)
    }

    package mutating func service<Instance: MVPHostInstance & ~Copyable & ~Escapable>(
        at timestampMicroseconds: UInt64,
        instance: inout Instance
    ) -> HostScheduledOpportunityResult<Instance.OwnerFailure> {
        let reasons: ExecutionWakeReasons
        switch begin(
            at: timestampMicroseconds, lifecycleState: instance.lifecycleState,
            assemblyReport: instance.assemblyReport)
        {
        case .noWork: return .noWork
        case .wait(let boundary): return .wait(untilMicroseconds: boundary)
        case .rejected(let error, let pacing): return .rejected(error, pacing: pacing)
        case .began(let accumulated): reasons = accumulated
        }
        let result = instance.runOpportunity()
        return complete(at: timestampMicroseconds, reasons: reasons, result: result)
    }

    package mutating func quiesce() -> HostWakePacingError? {
        pacing.quiesce()
    }
}
