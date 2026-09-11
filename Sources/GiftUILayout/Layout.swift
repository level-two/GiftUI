import GiftUI
import GiftUISemanticCore
import GiftUITextResources

package func layout<Semantic, Metrics, Workspace, Sink>(
    semantic: borrowing Semantic,
    metrics: borrowing Metrics,
    proposal: ProposedSize,
    limits: LayoutLimits,
    workspace: inout Workspace,
    sink: inout Sink
) -> LayoutResult
where
    Semantic: SemanticLayoutView,
    Metrics: CanonicalTextMetricsView,
    Workspace: LayoutWorkspace,
    Sink: LayoutResultSink & LayoutResultSinkState,
    Semantic.Identity == Workspace.Identity,
    Semantic.Identity == Sink.Identity
{
    guard !workspace.isLayoutActive, !sink.isLayoutActive else {
        return .failure(.reentrancyViolation)
    }

    guard limits.maximumScopes <= workspace.maximumScopes,
        limits.maximumDepth <= workspace.maximumDepth,
        limits.maximumTextScalars <= workspace.maximumTextScalars,
        limits.maximumTextLines <= workspace.maximumTextLines,
        limits.maximumPositionedGlyphs <= workspace.maximumPositionedGlyphs
    else {
        return .failure(.capacityExhausted)
    }

    guard workspace.acquireLayout() else {
        return .failure(.invariantViolation)
    }
    var validation = LayoutSemanticValidation(limits: limits)
    if let error = validation.validate(
        semantic: semantic,
        metrics: metrics,
        workspace: &workspace
    ) {
        workspace.resetLayout()
        return .failure(error)
    }
    workspace.resetLayout()

    // The T3.4 publication coordinator consumes only a complete placed
    // workspace. T4 and T5 install that geometry at this seam; until then, a
    // validated attempt fails closed without beginning or mutating the sink.
    _ = proposal
    return .failure(.invariantViolation)
}
