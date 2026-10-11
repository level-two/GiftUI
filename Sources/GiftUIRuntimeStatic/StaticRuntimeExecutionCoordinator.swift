import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIRuntimeCore

/// Connects a caller-owned Static profile binding to the common SPEC-009 seams
/// without moving either focused owner's fixed storage.
package protocol StaticExecutionProfileBinding: ~Copyable, ~Escapable {
    var executionContext: ExecutionContext { get }
    var isQuiescent: Bool { get }

    mutating func quiesce()
}

package struct StaticRuntimeExecutionCoordinator<Binding, Admission, Opportunity>:
    ~Copyable, ~Escapable, ExecutionAdmissionSink, ExecutionOpportunityRunner
where
    Binding: StaticExecutionProfileBinding & ~Copyable & ~Escapable,
    Admission: ExecutionAdmissionSink & ~Copyable & ~Escapable,
    Opportunity: ExecutionOpportunityRunner & ~Copyable & ~Escapable
{
    package typealias StateChangeFact = Admission.StateChangeFact
    package typealias CompletionFact = Admission.CompletionFact
    package typealias OwnerFailure = Opportunity.OwnerFailure

    private var binding: Binding
    package private(set) var admission: Admission
    package private(set) var opportunity: Opportunity

    @_lifetime(copy binding, copy admission, copy opportunity)
    package init(
        binding: consuming Binding,
        admission: consuming Admission,
        opportunity: consuming Opportunity
    ) {
        self.binding = consume binding
        self.admission = consume admission
        self.opportunity = consume opportunity
    }

    package mutating func submit(
        pointer: NormalizedPointerEvent
    ) -> ExecutionAdmissionOutcome {
        guard !binding.isQuiescent else { return unavailableAdmission() }
        return admission.submit(pointer: pointer)
    }

    package mutating func submit(
        stateChange: Admission.StateChangeFact
    ) -> ExecutionAdmissionOutcome {
        guard !binding.isQuiescent else { return unavailableAdmission() }
        return admission.submit(stateChange: stateChange)
    }

    package mutating func submit(
        completion: Admission.CompletionFact
    ) -> ExecutionAdmissionOutcome {
        guard !binding.isQuiescent else { return unavailableAdmission() }
        return admission.submit(completion: completion)
    }

    package mutating func runOpportunity() -> RunCycleResult<OwnerFailure> {
        guard !binding.isQuiescent else {
            return .failure(
                binding.executionContext,
                .execution(.requiredFacilityUnavailable),
                nil
            )
        }
        return opportunity.runOpportunity()
    }

    package mutating func quiesce() {
        binding.quiesce()
    }

    private func unavailableAdmission() -> ExecutionAdmissionOutcome {
        ExecutionAdmissionOutcome(
            result: .unavailable,
            context: binding.executionContext
        )
    }
}
