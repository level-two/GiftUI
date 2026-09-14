import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIRuntimeCore

/// Connects a caller-owned Static profile binding to the common SPEC-009 seams
/// without moving either focused owner's fixed storage.
package protocol StaticExecutionProfileBinding {
    var executionContext: ExecutionContext { get }
    var isQuiescent: Bool { get }

    mutating func quiesce()
}

package struct StaticRuntimeExecutionBindingAdapter<Regions, Metadata>:
    StaticExecutionProfileBinding
where
    Regions: StaticProfileStorageRegions & ~Copyable,
    Metadata: RuntimeStaticCanvasAuditMetadata & StaticCanvasCallableTable
{
    private let binding: UnsafeMutablePointer<StaticRuntimeProfileBinding<Regions, Metadata>>

    package init(
        binding: UnsafeMutablePointer<StaticRuntimeProfileBinding<Regions, Metadata>>
    ) {
        self.binding = binding
    }

    package var executionContext: ExecutionContext {
        binding.pointee.executionContext
    }

    package var isQuiescent: Bool {
        binding.pointee.isQuiescent
    }

    package mutating func quiesce() {
        binding.pointee.quiesce()
    }
}

package struct StaticRuntimeExecutionCoordinator<Binding, Admission, Opportunity>:
    ExecutionAdmissionSink, ExecutionOpportunityRunner
where
    Binding: StaticExecutionProfileBinding,
    Admission: ExecutionAdmissionSink,
    Opportunity: ExecutionOpportunityRunner,
    Opportunity.OwnerFailure == RuntimeOwnerFailure
{
    package typealias StateChangeFact = Admission.StateChangeFact
    package typealias CompletionFact = Admission.CompletionFact
    package typealias OwnerFailure = RuntimeOwnerFailure

    private var binding: Binding
    package private(set) var admission: Admission
    package private(set) var opportunity: Opportunity

    package init(
        binding: Binding,
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

    package mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure> {
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
