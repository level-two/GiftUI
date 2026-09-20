import GiftUIExecution
import GiftUIHostConfiguration

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

    package func quiesce() -> HostWakePacingError? {
        controller.quiesce()
    }
}
