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
    var engine = LayoutEngine(
        limits: limits,
        validatedCounters: validation.countersSnapshot
    )
    guard
        let measurement = engine.measure(
            semantic: semantic,
            metrics: metrics,
            proposal: proposal,
            workspace: &workspace
        )
    else {
        workspace.resetLayout()
        return .failure(engine.failure ?? .invariantViolation)
    }
    let rootBounds = Rect(
        origin: Point(x: 0, y: 0),
        size: measurement.resolvedSize
    )!
    guard
        engine.place(
            semantic: semantic,
            metrics: metrics,
            rootBounds: rootBounds,
            workspace: &workspace
        )
    else {
        workspace.resetLayout()
        return .failure(engine.failure ?? .invariantViolation)
    }
    let counters = engine.finalCounters
    let summary = LayoutSummary(
        scopeCount: counters.scopeCount,
        textScalarCount: counters.textScalarCount,
        textLineCount: counters.textLineCount,
        positionedGlyphCount: counters.positionedGlyphCount,
        maximumObservedDepth: counters.maximumObservedDepth,
        rootBounds: rootBounds
    )
    return publishLayout(summary: summary, workspace: &workspace, sink: &sink)
}
