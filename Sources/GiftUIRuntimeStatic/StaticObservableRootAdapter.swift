import GiftUI
import GiftUIObservableState

/// Caller-owned model and registration storage precede activation. Their
/// independent borrows end only after root retirement has detached every sink.
package struct StaticObservableRootAdapter<
    Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable
>: ~Copyable {
    private var models: StaticObservableModelStorage<Model, Model.Schema>
    private var registration = ObservableStateRootStorage<Identity>()

    package init?(identity: ObservableModelOwnerIdentity, schema: UInt16, needsCapture: Bool) {
        guard
            let models = StaticObservableModelStorage<Model, Model.Schema>(
                identity: identity, schema: schema, needsCapture: needsCapture)
        else { return nil }
        self.models = consume models
    }

    package mutating func withLifetime<Result>(
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
