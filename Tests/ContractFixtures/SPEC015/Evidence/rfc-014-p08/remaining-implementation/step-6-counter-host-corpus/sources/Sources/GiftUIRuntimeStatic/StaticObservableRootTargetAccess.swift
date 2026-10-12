import GiftUIObservableState

package typealias StaticObservableRootTargetAccess<
    Model: ObservableStateModel & ObservableModelMutation & ~Copyable,
    Identity: Equatable & Sendable
> = ObservableStateRootTargetAccess<Model, Identity>
