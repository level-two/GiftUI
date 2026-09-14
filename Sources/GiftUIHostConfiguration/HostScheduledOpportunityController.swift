import GiftUIExecution

package enum HostScheduledOpportunityError: UInt8, Error, Equatable, Sendable {
    case invalidLifecycle = 0
    case assemblyReportMismatch = 1
    case pacingRejected = 2
    case invalidRuntimeResult = 3
    case invalidCompletion = 4
}

package enum HostScheduledOpportunityResult: Equatable, Sendable {
    case noWork
    case wait(untilMicroseconds: UInt64)
    case cycle(reasons: ExecutionWakeReasons, result: HostOpportunityResult)
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

    package mutating func service<Instance: MVPHostInstance>(
        at timestampMicroseconds: UInt64,
        instance: inout Instance
    ) -> HostScheduledOpportunityResult {
        guard instance.lifecycleState == .active else {
            return .rejected(.invalidLifecycle, pacing: nil)
        }
        guard instance.assemblyReport == assemblyReport else {
            return .rejected(.assemblyReportMismatch, pacing: nil)
        }
        switch pacing.schedule(at: timestampMicroseconds) {
        case .noWork:
            return .noWork
        case .wait(let boundary):
            return .wait(untilMicroseconds: boundary)
        case .invalid(let error):
            return .rejected(.pacingRejected, pacing: error)
        case .run:
            break
        }

        let reasons: ExecutionWakeReasons
        switch pacing.beginOpportunity(at: timestampMicroseconds) {
        case .began(let accumulated):
            reasons = accumulated
        case .rejected(let error):
            return .rejected(.pacingRejected, pacing: error)
        }

        let result = instance.runOpportunity()
        let completionError = pacing.completeOpportunity(
            at: timestampMicroseconds
        )
        guard completionError == nil else {
            return .rejected(.invalidCompletion, pacing: completionError)
        }
        guard result != .invalidLifecycle else {
            return .rejected(.invalidRuntimeResult, pacing: nil)
        }
        return .cycle(reasons: reasons, result: result)
    }

    package mutating func quiesce() -> HostWakePacingError? {
        pacing.quiesce()
    }
}
