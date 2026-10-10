import GiftUI

/// Binding borrows the same root activation used for reconciliation. The former
/// copyable reconciler decorator cannot carry the new scoped backing safely.
package typealias ObservableStateBindingDecorator<
    Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable
> = ObservableStateRootScope<Model, Identity>
