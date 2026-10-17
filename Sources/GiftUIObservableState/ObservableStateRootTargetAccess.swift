import GiftUIExecution

/// Scoped generation-checked target operations. Interaction's accepted-offer
/// adapter composes this value; authored code receives no raw model callback.
@usableFromInline
package struct ObservableStateRootTargetAccess<
    Model: ObservableStateModel & ObservableModelMutation & ~Copyable,
    Identity: Equatable & Sendable
>: ~Copyable, ~Escapable {
    @usableFromInline let root: ObservableStateRootScope<Model, Identity>
    @usableFromInline let identity: Identity
    @usableFromInline let ordinal: UInt16

    @_lifetime(copy root)
    @inlinable
    package init(
        root: borrowing ObservableStateRootScope<Model, Identity>, identity: Identity,
        ordinal: UInt16
    ) {
        self.root = root.borrowedRoot()
        self.identity = identity
        self.ordinal = ordinal
    }

    @inlinable
    package borrowing func currentGeneration() -> ObservableTargetGeneration? {
        guard let generation = root.generation(identity: identity, ordinal: ordinal) else {
            return nil
        }
        return ObservableTargetGeneration(rawValue: generation)
    }

    @inlinable
    package borrowing func mutate(
        matching generation: ObservableTargetGeneration, mutation: Model.Mutation
    ) -> ObservableStateResult {
        root.mutate(identity: identity, ordinal: ordinal, matching: generation, mutation: mutation)
    }
    @inlinable
    package borrowing func mutate(
        matching generation: ObservableTargetGeneration, operation: () -> Model.Mutation
    ) -> ObservableStateResult {
        root.mutate(
            identity: identity, ordinal: ordinal, matching: generation, operation: operation)
    }

}
