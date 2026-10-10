import GiftUI
import GiftUISemanticCore

/// Lexical join between Semantic Core's traversal and the existing State owner.
/// The bridge owns no model, read scope, or independent registration lifetime.
package struct ObservableSemanticBodyBinding<
    Model: ObservableStateModel & ~Copyable,
    Identity: Equatable & Sendable,
    Domain: _GiftUIReadDomain
>: ~Copyable, ~Escapable, SemanticStatefulBinding
where Domain.Slot == ObservableModelReadSlot<Model> {
    package typealias Failure = ObservableStateError
    private let models: ObservableModelScope<Model, Model.Schema>
    private let root: ObservableStateRootScope<Model, Identity>

    @_lifetime(copy models, copy root)
    package init(
        models: consuming ObservableModelScope<Model, Model.Schema>,
        root: consuming ObservableStateRootScope<Model, Identity>,
        domain: Domain.Type
    ) {
        self.models = consume models
        self.root = consume root
    }

    package borrowing func evaluate<Declaration: View>(
        _ declaration: borrowing Declaration,
        beforeBody: () -> SemanticExpansionError?,
        body: (borrowing _GiftUIFrameRead<Domain>) throws(_GiftUIAccessFailure) -> Declaration.Body
    ) -> SemanticBodyEvaluation<Declaration.Body, ObservableStateError>
    where Declaration.Domain == Domain, Declaration.Body.Domain == Domain {
        if let failure = beforeBody() { return .semanticFailure(failure) }
        do throws(_GiftUIAccessFailure) {
            return .body(try models.withRead(Domain.self, body))
        } catch { return .accessFailure(error) }
    }

    package borrowing func evaluateStateful<Declaration: View & _GiftUIObservableStateHost>(
        _ declaration: borrowing Declaration,
        structuralIdentity: Identity,
        beforeBody: () -> SemanticExpansionError?,
        body: (borrowing Declaration, borrowing _GiftUIFrameRead<Domain>)
            throws(_GiftUIAccessFailure) -> Declaration.Body
    ) -> SemanticBodyEvaluation<Declaration.Body, ObservableStateError>
    where Declaration.Domain == Domain, Declaration.Body.Domain == Domain {
        do throws(ObservableStateError) {
            return try root.withBoundDeclaration(declaration, identity: structuralIdentity) {
                (bound) throws(ObservableStateError) in
                if let failure = beforeBody() { return .semanticFailure(failure) }
                do throws(_GiftUIAccessFailure) {
                    return .body(
                        try models.withRead(Domain.self) {
                            (read) throws(_GiftUIAccessFailure) in
                            try body(bound, read)
                        })
                } catch { return .accessFailure(error) }
            }
        } catch { return .bindingFailure(error) }
    }
}
