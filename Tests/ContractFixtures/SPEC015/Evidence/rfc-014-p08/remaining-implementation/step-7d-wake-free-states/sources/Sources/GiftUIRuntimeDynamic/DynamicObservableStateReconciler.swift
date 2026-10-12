import GiftUIObservableState

/// Reconciliation now borrows the activation's actual backing and registrations.
package typealias DynamicObservableStateReconciler<
    Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable
> = ObservableStateRootScope<Model, Identity>
