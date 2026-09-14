import GiftUI
import GiftUIExecution
import GiftUIInteraction

package struct DynamicObservableRootTargetAccess<Model, Identity>:
    ActionModelTargetAccess
where Model: _GiftUIObservableReference, Identity: Equatable & Sendable {
    private weak var root: DynamicObservableRootAdapter<Model, Identity>?

    package init(root: DynamicObservableRootAdapter<Model, Identity>) {
        self.root = root
    }

    package borrowing func currentGeneration() -> ObservableTargetGeneration? {
        root?.currentTargetGeneration()
    }

    package mutating func withCurrentModel(
        matching generation: ObservableTargetGeneration,
        _ body: (borrowing Model) -> Void
    ) -> Bool {
        root?.withModel(matching: generation, body) ?? false
    }
}
