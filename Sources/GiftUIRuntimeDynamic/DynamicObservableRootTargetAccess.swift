import GiftUIObservableState

package typealias DynamicObservableRootTargetAccess<
    Model: ObservableStateModel & ObservableModelMutation & ~Copyable,
    Identity: Equatable & Sendable
> = ObservableStateRootTargetAccess<Model, Identity>
