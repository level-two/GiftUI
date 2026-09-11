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
    workspace.resetLayout()

    // T3.3 installs semantic validation and measurement at this seam. Until
    // then, an otherwise admitted attempt fails closed without beginning or
    // mutating the result sink.
    _ = semantic
    _ = metrics
    _ = proposal
    return .failure(.invariantViolation)
}
