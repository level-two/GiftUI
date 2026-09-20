import GiftUIDisplayCore
import GiftUIExecution
import GiftUIHostConfiguration

package enum DynamicSignalAnalyzerPiPacedOpportunityResult: Equatable, Sendable {
    case noWork
    case wait(untilMicroseconds: UInt64)
    case completed(
        reasons: ExecutionWakeReasons,
        result: DynamicSignalAnalyzerPiInputOpportunityResult
    )
    case rejected(HostWakePacingError)
}

/// Owns the single pacing state shared by Pi ingress and the serialized host loop.
package final class DynamicSignalAnalyzerPiWakePacingOwner {
    private var controller: HostWakePacingController

    package init(
        policy: HostPacingPolicy,
        initialFrameOriginMicroseconds: UInt64
    ) {
        controller = HostWakePacingController(
            policy: policy,
            initialFrameOriginMicroseconds: initialFrameOriginMicroseconds
        )
    }

    package var accumulatedReasons: ExecutionWakeReasons {
        controller.accumulatedReasons
    }

    package var wakeIsOutstanding: Bool { controller.wakeIsOutstanding }
    package var opportunityIsActive: Bool { controller.opportunityIsActive }

    @discardableResult
    package func recordAcceptedFact(
        at timestampMicroseconds: UInt64
    ) -> Result<HostWakeDirective, HostWakePacingError> {
        controller.recordAcceptedFact(at: timestampMicroseconds)
    }

    @discardableResult
    package func recordQueuedInput(
        at timestampMicroseconds: UInt64
    ) -> Result<HostWakeDirective, HostWakePacingError> {
        controller.record(.admittedWork, at: timestampMicroseconds)
    }

    package func schedule(
        at timestampMicroseconds: UInt64
    ) -> HostOpportunitySchedule {
        controller.schedule(at: timestampMicroseconds)
    }

    package func beginOpportunity(
        at timestampMicroseconds: UInt64
    ) -> HostOpportunityBeginResult {
        controller.beginOpportunity(at: timestampMicroseconds)
    }

    package func completeOpportunity(
        at timestampMicroseconds: UInt64
    ) -> HostWakePacingError? {
        controller.completeOpportunity(at: timestampMicroseconds)
    }

    package func service<Target>(
        at timestampMicroseconds: UInt64,
        coordinator: inout DynamicSignalAnalyzerPiInputCoordinator,
        owner: inout DynamicSignalAnalyzerPiInitialPresentationOwner<Target>,
        correlations: DynamicSignalAnalyzerPiCorrelationOwner
    ) -> DynamicSignalAnalyzerPiPacedOpportunityResult
    where Target: DisplayTarget {
        switch controller.schedule(at: timestampMicroseconds) {
        case .noWork:
            return .noWork
        case .wait(let boundary):
            return .wait(untilMicroseconds: boundary)
        case .invalid(let error):
            return .rejected(error)
        case .run:
            break
        }

        let reasons: ExecutionWakeReasons
        switch controller.beginOpportunity(at: timestampMicroseconds) {
        case .began(let value):
            reasons = value
        case .rejected(let error):
            return .rejected(error)
        }
        let result = coordinator.runOpportunity(
            into: &owner,
            correlations: correlations
        )
        if let error = controller.completeOpportunity(at: timestampMicroseconds) {
            return .rejected(error)
        }
        return .completed(reasons: reasons, result: result)
    }

    package func quiesce() -> HostWakePacingError? {
        controller.quiesce()
    }
}
