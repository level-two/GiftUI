import GiftUI

@testable import GiftUISemanticCore

private struct EmptyReadSemanticBinding<Identity: Equatable>:
    SemanticStatefulBinding, ~Copyable, ~Escapable
{
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Failure = Never
    private var storage: InlineArray<0, UInt8> = .init(repeating: 0)

    @_lifetime(borrow storage)
    init(storage: borrowing InlineArray<0, UInt8>) { self.storage = storage }

    borrowing func evaluate<Declaration: View>(
        _ declaration: borrowing Declaration,
        beforeBody: () -> SemanticExpansionError?,
        body: (borrowing _GiftUIFrameRead<Domain>) throws(_GiftUIAccessFailure) -> Declaration.Body
    ) -> SemanticBodyEvaluation<Declaration.Body, Never>
    where Declaration.Domain == Domain, Declaration.Body.Domain == Domain {
        if let error = beforeBody() { return .semanticFailure(error) }
        do throws(_GiftUIAccessFailure) {
            return .body(try body(_GiftUIFrameRead<Domain>(slots: Span<UInt8>())))
        } catch {
            return .accessFailure(error)
        }
    }

    borrowing func evaluateStateful<Declaration: View & _GiftUIObservableStateHost>(
        _ declaration: borrowing Declaration,
        structuralIdentity: Identity,
        beforeBody: () -> SemanticExpansionError?,
        body: (borrowing Declaration, borrowing _GiftUIFrameRead<Domain>)
            throws(_GiftUIAccessFailure) -> Declaration.Body
    ) -> SemanticBodyEvaluation<Declaration.Body, Never>
    where Declaration.Domain == Domain, Declaration.Body.Domain == Domain {
        .accessFailure(.invalidPhase)
    }
}

func expandStatelessSemanticTreeForTesting<
    Root: View,
    Workspace: SemanticExpansionWorkspace,
    Sink: SemanticExpansionSink
>(
    _ root: borrowing Root,
    limits: SemanticExpansionLimits,
    workspace: inout Workspace,
    sink: inout Sink
) -> SemanticExpansionResult
where
    Root.Domain == _GiftUIEmptyReadDomain,
    Workspace.Identity == Sink.Identity
{
    let result = expandSemanticTreeWithStateBinding(
        root,
        limits: limits,
        workspace: &workspace,
        sink: &sink,
        stateBinding: EmptyReadSemanticBinding<Workspace.Identity>(storage: .init(repeating: 0))
    )
    switch result {
    case .success(let summary):
        return .success(summary)
    case .semanticFailure(let error):
        return .failure(error)
    case .accessFailure:
        preconditionFailure("stateless expansion test adapter received an access failure")
    case .bindingFailure(let impossible):
        switch impossible {}
    }
}
