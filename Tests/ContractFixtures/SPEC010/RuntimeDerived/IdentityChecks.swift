import GiftUI
import GiftUIFailureCore
import GiftUIObservableStateFailureAdapterFixture
@testable import GiftUIObservableState

@main struct IdentityChecks {
    static func main() throws {
        var checks = 0
        func expect(_ condition: Bool) {
            checks += 1
            precondition(condition)
        }
        for raw: UInt8 in 0...17 {
            expect(ObservableStateError(rawValue: raw)?.rawValue == raw)
        }
        expect(ObservableStateError(rawValue: 18) == nil)
        expect(MemoryLayout<ObservableStateError>.size == 1)
        let access: [(_GiftUIAccessFailure, ObservableStateError)] = [
            (.invalidPhase, .invalidPhaseSafetyNotProven),
            (.wrongOwner, .staleModel), (.wrongSchema, .staleModel),
            (.staleModel, .staleModel), (.outOfBounds, .modelReadOutOfBounds),
        ]
        for (input, output) in access { expect(ObservableStateError(accessFailure: input) == output) }
        var owners = ObservableModelOwnerNamespace()
        expect(try owners.issue().rawValue == 0)
        expect(try owners.issue().rawValue == 1)
        var allocations = ObservableModelAllocationNamespace()
        expect(try allocations.issue() == 0)
        expect(try allocations.issue() == 1)
        expect(try owners.issue().rawValue == 2)
        var exhaustedOwners = ObservableModelOwnerNamespace(nextValue: .max)
        var exhaustedAllocations = ObservableModelAllocationNamespace(nextValue: .max)
        expect(try exhaustedOwners.issue().rawValue == .max)
        expect(try exhaustedAllocations.issue() == .max)
        for _ in 0..<2 {
            do { _ = try exhaustedOwners.issue(); expect(false) }
            catch { expect(error == .modelGenerationExhausted) }
            do { _ = try exhaustedAllocations.issue(); expect(false) }
            catch { expect(error == .modelGenerationExhausted) }
        }
        let order: [ObservableStateError] = [
            .reentrancyViolation, .invalidPhaseSafetyNotProven, .invalidPhaseContained,
            .incompatibleAssociation, .staleModel, .duplicateOwner,
            .registrationGenerationExhausted, .modelGenerationExhausted, .retainedModel,
            .modelCapacityExhausted, .ownerCapacityExhausted, .locationCapacityExhausted,
            .registrationCapacityExhausted, .associationStagingCapacityExhausted,
            .replacementStagingCapacityExhausted, .staleAttachment,
            .modelReadOutOfBounds, .invariantViolation,
        ]
        for (index, higher) in order.enumerated() {
            expect(GiftUIObservableStateFailureAdapter.selectFocusedFailure(from: .failure(higher)) == higher)
            for lower in order.dropFirst(index + 1) {
                expect(GiftUIObservableStateFailureAdapter.selectFocusedFailure(from: [.failure(lower), .failure(higher)]) == higher)
            }
        }
        let mappings: [(ObservableStateError, ObservableStateFailureDetectionContext, GiftUIConditionID, GiftUIAffectedScope, GiftUIContainment)] = [
            (.modelCapacityExhausted, .initialOrCandidateBinding, .capacityExhausted, .component, .contained),
            (.ownerCapacityExhausted, .initialOrCandidateBinding, .capacityExhausted, .component, .contained),
            (.modelCapacityExhausted, .replacement, .capacityExhausted, .operation, .contained),
            (.ownerCapacityExhausted, .replacement, .capacityExhausted, .operation, .contained),
            (.retainedModel, .replacement, .capacityExhausted, .operation, .contained),
            (.modelGenerationExhausted, .runtime, .invalidIdentity, .runtime, .safetyNotProven),
            (.staleModel, .replacement, .invalidIdentity, .operation, .contained),
            (.staleModel, .initialOrCandidateBinding, .invalidIdentity, .operation, .contained),
            (.staleModel, .activeCycle, .invalidIdentity, .operation, .contained),
            (.modelReadOutOfBounds, .activeCycle, .invalidValue, .activeCycle, .contained),
        ]
        for (error, context, condition, scope, containment) in mappings {
            let mapped = GiftUIObservableStateFailureAdapter.map(error, detectedAt: context, mandatoryEffectsComplete: true)
            expect(mapped?.fact == GiftUIFailureFact(condition: condition, origin: .observableState, affectedScope: scope, containment: containment))
            expect(GiftUIObservableStateFailureAdapter.map(error, detectedAt: context, mandatoryEffectsComplete: false) == nil)
        }
        print("P03 identity/error checks=\(checks) failures=0")
    }
}
