import GiftUI
import GiftUISemanticCore

package struct ObservableStateBindingDecorator<Reconciler>
where Reconciler: ObservableStateReconciler {
    package private(set) var reconciler: Reconciler

    package init(reconciler: Reconciler) {
        self.reconciler = reconciler
    }

    package mutating func withBoundDeclaration<Declaration>(
        _ declaration: borrowing Declaration,
        structuralIdentity: Reconciler.StructuralIdentity,
        body: (borrowing Declaration) -> Void
    ) -> ObservableStateResult
    where Declaration: View & _GiftUIObservableStateHost {
        var transientDeclaration = copy declaration
        var visitor = BindingVisitor(
            structuralIdentity: structuralIdentity,
            reconciler: reconciler
        )
        transientDeclaration._giftUIVisitObservableStateDeclarations(&visitor)
        reconciler = visitor.reconciler

        if let failure = visitor.failure {
            return .failure(failure)
        }

        body(transientDeclaration)
        return .success(.unchanged)
    }
}

extension ObservableStateBindingDecorator: SemanticStatefulBinding {
    package typealias Identity = Reconciler.StructuralIdentity
    package typealias Failure = ObservableStateError

    package mutating func bind<Declaration>(
        _ declaration: borrowing Declaration,
        structuralIdentity: Reconciler.StructuralIdentity,
        body: (borrowing Declaration) -> Void
    ) -> SemanticStateBindingOutcome<ObservableStateError>
    where Declaration: View & _GiftUIObservableStateHost {
        switch withBoundDeclaration(
            declaration,
            structuralIdentity: structuralIdentity,
            body: body
        ) {
        case .success:
            return .bound
        case .failure(let error):
            return .failure(error)
        }
    }
}

private struct BindingVisitor<Reconciler>:
    _GiftUIObservableStateDeclarationVisitor
where Reconciler: ObservableStateReconciler {
    let structuralIdentity: Reconciler.StructuralIdentity
    var reconciler: Reconciler
    private(set) var failure: ObservableStateError?

    mutating func visit<Model: _GiftUIObservableReference>(
        _ state: inout State<Model>,
        declarationOrdinal: UInt16
    ) {
        guard failure == nil else { return }

        let result = reconciler.encounter(
            structuralIdentity: structuralIdentity,
            declarationOrdinal: declarationOrdinal,
            state: &state
        )
        switch result {
        case .success(.materialized), .success(.preserved):
            return
        case .success:
            failure = .invariantViolation
        case .failure(let error):
            failure = error
        }
    }
}
