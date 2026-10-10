import GiftUI
import GiftUIObservableState

/// Retains actual typed backing for the entire activation. Host assembly issues
/// the identity from its longer-lived namespace; this adapter never resets it.
package final class DynamicObservableRootAdapter<
    Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable
> {
    private let models: DynamicObservableModelStorage<Model, Model.Schema>
    private var registration = DynamicObservableModelRegistration<Identity>()

    package init?(identity: ObservableModelOwnerIdentity, schema: UInt16, needsCapture: Bool) {
        guard
            let models = DynamicObservableModelStorage<Model, Model.Schema>(
                identity: identity, schema: schema, needsCapture: needsCapture)
        else { return nil }
        self.models = models
    }

    package func withLifetime<Result>(
        _ body: (
            borrowing ObservableModelScope<Model, Model.Schema>,
            borrowing ObservableStateRootScope<Model, Identity>
        ) throws(ObservableStateError) -> Result
    ) throws(ObservableStateError) -> Result {
        try models.withLifetime { (scope) throws(ObservableStateError) in
            try scope.withRoot(storage: &registration) { (root) throws(ObservableStateError) in
                try body(scope, root)
            }
        }
    }
}
