import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIRuntimeCore

/// Connects a caller-owned Static profile binding to the common SPEC-009 seams
/// without moving either focused owner's fixed storage.
@usableFromInline
package protocol StaticExecutionProfileBinding: ~Copyable, ~Escapable {
    var executionContext: ExecutionContext { get }
    var isQuiescent: Bool { get }

    mutating func quiesce()
}

@usableFromInline
package struct StaticRuntimeExecutionCoordinator<Binding, Admission, Opportunity>:
    ~Copyable, ~Escapable, ExecutionAdmissionSink, ExecutionOpportunityRunner
where
    Binding: StaticExecutionProfileBinding & ~Copyable & ~Escapable,
    Admission: ExecutionAdmissionSink & ~Copyable & ~Escapable,
    Opportunity: ExecutionOpportunityRunner & RuntimeOpportunityQuiescence & ~Copyable & ~Escapable
{
    @usableFromInline
    package typealias StateChangeFact = Admission.StateChangeFact
    @usableFromInline
    package typealias CompletionFact = Admission.CompletionFact
    @usableFromInline
    package typealias OwnerFailure = Opportunity.OwnerFailure

    @usableFromInline
    internal var binding: Binding
    @usableFromInline
    package internal(set) var admission: Admission
    @usableFromInline
    package internal(set) var opportunity: Opportunity

    @_lifetime(copy binding, copy admission, copy opportunity)
    @inlinable
    package init(
        binding: consuming Binding,
        admission: consuming Admission,
        opportunity: consuming Opportunity
    ) {
        self.binding = consume binding
        self.admission = consume admission
        self.opportunity = consume opportunity
    }

    @inlinable
    package mutating func submit(
        pointer: NormalizedPointerEvent
    ) -> ExecutionAdmissionOutcome {
        guard !binding.isQuiescent else { return unavailableAdmission() }
        return admission.submit(pointer: pointer)
    }

    @inlinable
    package mutating func submit(
        stateChange: Admission.StateChangeFact
    ) -> ExecutionAdmissionOutcome {
        guard !binding.isQuiescent else { return unavailableAdmission() }
        return admission.submit(stateChange: stateChange)
    }

    @inlinable
    package mutating func submit(
        completion: Admission.CompletionFact
    ) -> ExecutionAdmissionOutcome {
        guard !binding.isQuiescent else { return unavailableAdmission() }
        return admission.submit(completion: completion)
    }

    @inlinable
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

    @inlinable
    package mutating func quiesce() {
        binding.quiesce()
        opportunity.quiesceOpportunity()
    }

    /// Transfers the opportunity only after synchronous coordinator quiescence. The
    /// returned value retains all of its original backing lifetime dependence.
    @_lifetime(copy self)
    @inlinable
    package consuming func takeQuiescedOpportunity() -> Opportunity? {
        guard binding.isQuiescent && opportunity.isOpportunityQuiescent else { return nil }
        return consume opportunity
    }

    @inlinable
    internal func unavailableAdmission() -> ExecutionAdmissionOutcome {
        ExecutionAdmissionOutcome(
            result: .unavailable,
            context: binding.executionContext
        )
    }
}

extension StaticRuntimeExecutionCoordinator: GiftUIRuntimeProfileCoordinator
where
    Binding: RuntimeAuditedExecutionProfileBinding & ~Copyable & ~Escapable,
    Admission: ~Copyable & ~Escapable,
    Opportunity: ~Copyable & ~Escapable
{
    @usableFromInline
    package typealias Endpoint = Binding.Endpoint
    @inlinable
    package var profile: RuntimeProfileKind { .static }
    @inlinable
    package var storageAudit: RuntimeStorageAudit { binding.storageAudit }
    @inlinable
    package var executionContext: ExecutionContext { binding.executionContext }
    @inlinable
    package var isQuiescent: Bool { binding.isQuiescent && opportunity.isOpportunityQuiescent }
}
