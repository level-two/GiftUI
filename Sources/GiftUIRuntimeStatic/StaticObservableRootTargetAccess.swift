import GiftUI
import GiftUIExecution
import GiftUIInteraction

package struct StaticObservableRootTargetAccess<Model, Identity>:
    ActionModelTargetAccess
where Model: _GiftUIObservableReference, Identity: Equatable & Sendable {
    private let root:
        UnsafeMutablePointer<
            StaticObservableRootAdapter<Model, Identity>
        >

    package init(
        root: UnsafeMutablePointer<
            StaticObservableRootAdapter<Model, Identity>
        >
    ) {
        self.root = root
    }

    package borrowing func currentGeneration() -> ObservableTargetGeneration? {
        root.pointee.targetGeneration()
    }

    package mutating func withCurrentModel(
        matching generation: ObservableTargetGeneration,
        _ body: (borrowing Model) -> Void
    ) -> Bool {
        root.pointee.withModel(matching: generation, body)
    }
}
