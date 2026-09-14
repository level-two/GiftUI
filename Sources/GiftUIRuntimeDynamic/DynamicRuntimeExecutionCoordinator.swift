import GiftUI
import GiftUIExecution
import GiftUIRuntimeCore

/// Connects a caller-owned Dynamic profile binding to the common SPEC-009
/// seams without moving either focused owner's storage or algorithm.
package struct DynamicRuntimeExecutionCoordinator<Admission, Opportunity>:
    ExecutionAdmissionSink, ExecutionOpportunityRunner
where
    Admission: ExecutionAdmissionSink,
    Opportunity: ExecutionOpportunityRunner,
    Opportunity.OwnerFailure == RuntimeOwnerFailure
{
    package typealias StateChangeFact = Admission.StateChangeFact
    package typealias CompletionFact = Admission.CompletionFact
    package typealias OwnerFailure = RuntimeOwnerFailure

    private let binding: UnsafeMutablePointer<DynamicRuntimeProfileBinding>
    package private(set) var admission: Admission
    package private(set) var opportunity: Opportunity

    package init(
        binding: UnsafeMutablePointer<DynamicRuntimeProfileBinding>,
        admission: Admission,
        opportunity: Opportunity
    ) {
        self.binding = binding
        self.admission = admission
        self.opportunity = opportunity
    }

    package mutating func submit(
        pointer: NormalizedPointerEvent
    ) -> ExecutionAdmissionOutcome {
        guard !binding.pointee.isQuiescent else { return unavailableAdmission() }
        return admission.submit(pointer: pointer)
    }

    package mutating func submit(
        stateChange: Admission.StateChangeFact
    ) -> ExecutionAdmissionOutcome {
        guard !binding.pointee.isQuiescent else { return unavailableAdmission() }
        return admission.submit(stateChange: stateChange)
    }

    package mutating func submit(
        completion: Admission.CompletionFact
    ) -> ExecutionAdmissionOutcome {
        guard !binding.pointee.isQuiescent else { return unavailableAdmission() }
        return admission.submit(completion: completion)
    }

    package mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure> {
        guard !binding.pointee.isQuiescent else {
            return .failure(
                binding.pointee.executionContext,
                .execution(.requiredFacilityUnavailable),
                nil
            )
        }
        return opportunity.runOpportunity()
    }

    package mutating func quiesce() {
        binding.pointee.quiesce()
    }

    private func unavailableAdmission() -> ExecutionAdmissionOutcome {
        ExecutionAdmissionOutcome(
            result: .unavailable,
            context: binding.pointee.executionContext
        )
    }
}
