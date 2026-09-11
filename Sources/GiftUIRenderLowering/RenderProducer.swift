import GiftUI
import GiftUILayout
import GiftUIRenderCore
import GiftUISemanticCore
import GiftUITextResources

extension RenderProducer {
    package static func produce<Semantic, Layout, Metrics, Workspace, Sink>(
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        surfaceBounds: Rect,
        damageMode: RenderDamageMode,
        rootForeground: Color,
        limits: RenderLimits,
        workspace: inout Workspace,
        sink: inout Sink
    ) -> RenderProductionResult
    where
        Semantic: SemanticRenderView,
        Layout: ResolvedRenderLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: RenderProductionWorkspace,
        Sink: RenderOperationSink,
        Semantic.Identity == Layout.Identity,
        Semantic.Identity == Workspace.Identity
    {
        if workspace.isActive {
            return .failure(.reentrancyViolation)
        }
        guard workspace.acquire() else {
            return .failure(.invariantViolation)
        }
        defer { workspace.reset() }

        let preflightResult = preflight(
            semantic: semantic,
            layout: layout,
            textMetrics: textMetrics,
            surfaceBounds: surfaceBounds,
            damageMode: damageMode,
            limits: limits,
            workspace: &workspace,
            sink: &sink
        )
        guard case .success(let summary) = preflightResult else {
            if case .failure(let error) = preflightResult {
                return .failure(error)
            }
            return .failure(.invariantViolation)
        }
        return stream(
            preflight: summary,
            semantic: semantic,
            layout: layout,
            textMetrics: textMetrics,
            surfaceBounds: surfaceBounds,
            damageMode: damageMode,
            rootForeground: rootForeground,
            workspace: &workspace,
            sink: &sink
        )
    }
}
