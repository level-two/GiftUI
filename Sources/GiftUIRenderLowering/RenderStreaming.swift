import GiftUI
import GiftUILayout
import GiftUIRenderCore
import GiftUISemanticCore
import GiftUITextResources

extension RenderProducer {
    static func stream<Semantic, Layout, Metrics, Workspace, Sink>(
        preflight: RenderPreflightSummary,
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        surfaceBounds: Rect,
        damageMode: RenderDamageMode,
        rootForeground: Color,
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
        var extensionVisitor = EmptyRenderStreamingExtension<
            Semantic.Identity, Sink
        >()
        return stream(
            preflight: preflight,
            semantic: semantic,
            layout: layout,
            textMetrics: textMetrics,
            surfaceBounds: surfaceBounds,
            damageMode: damageMode,
            rootForeground: rootForeground,
            workspace: &workspace,
            extensionVisitor: &extensionVisitor,
            sink: &sink
        )
    }

    static func stream<
        Semantic, Layout, Metrics, Workspace, Extension, Sink
    >(
        preflight: RenderPreflightSummary,
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        surfaceBounds: Rect,
        damageMode: RenderDamageMode,
        rootForeground: Color,
        workspace: inout Workspace,
        extensionVisitor: inout Extension,
        sink: inout Sink
    ) -> RenderProductionResult
    where
        Semantic: SemanticRenderView,
        Layout: ResolvedRenderLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: RenderProductionWorkspace,
        Extension: RenderStreamingExtension,
        Sink: RenderOperationSink,
        Semantic.Identity == Layout.Identity,
        Semantic.Identity == Workspace.Identity,
        Semantic.Identity == Extension.Identity,
        Extension.Sink == Sink
    {
        guard
            snapshotsMatch(
                preflight,
                semantic: semantic,
                layout: layout
            )
        else {
            return .failure(.invariantViolation)
        }
        guard workspace.currentForeground == nil,
            workspace.pushForeground(rootForeground),
            workspace.currentForeground == rootForeground
        else {
            return .failure(.invariantViolation)
        }
        guard sink.begin(preflight.header) else {
            return .failure(.sinkRefused)
        }

        var state = RenderStreamingState()
        if let error = state.stream(
            semantic.rootIdentity,
            semantic: semantic,
            layout: layout,
            textMetrics: textMetrics,
            surfaceBounds: surfaceBounds,
            workspace: &workspace,
            extensionVisitor: &extensionVisitor,
            sink: &sink
        ) {
            sink.discard()
            return .failure(error)
        }
        guard state.operationCount == preflight.header.operationCount,
            state.positionedGlyphCount
                == preflight.header.positionedGlyphCount,
            state.extensionOperationCount
                == preflight.extensionOperationCount,
            semantic.semanticIdentity(at: semantic.semanticScopeCount) == nil,
            layout.layoutIdentity(at: layout.layoutScopeCount) == nil,
            damageMatches(
                preflight.header.damageBounds,
                layout: layout,
                surfaceBounds: surfaceBounds,
                damageMode: damageMode
            ),
            snapshotsMatch(
                preflight,
                semantic: semantic,
                layout: layout
            )
        else {
            sink.discard()
            return .failure(.invariantViolation)
        }
        guard workspace.popForeground(), workspace.currentForeground == nil else {
            sink.discard()
            return .failure(.invariantViolation)
        }
        switch extensionVisitor.complete() {
        case .success:
            break
        case .failure(let error):
            sink.discard()
            return .failure(error)
        }
        guard sink.finish() else {
            sink.discard()
            return .failure(.invariantViolation)
        }
        return .success(preflight.header)
    }

    private static func damageMatches<Layout>(
        _ expected: Rect,
        layout: borrowing Layout,
        surfaceBounds: Rect,
        damageMode: RenderDamageMode
    ) -> Bool where Layout: ResolvedRenderLayoutView {
        switch damageMode {
        case .rootIntersection:
            return LayoutGeometry.intersection(layout.rootBounds, surfaceBounds)
                == expected
        case .initializeCompleteSurface:
            return surfaceBounds == expected
        }
    }

    private static func snapshotsMatch<Semantic, Layout>(
        _ preflight: RenderPreflightSummary,
        semantic: borrowing Semantic,
        layout: borrowing Layout
    ) -> Bool
    where
        Semantic: SemanticRenderView,
        Layout: ResolvedRenderLayoutView,
        Semantic.Identity == Layout.Identity
    {
        guard semantic.renderSnapshotVersion == preflight.semanticSnapshotVersion
        else {
            return false
        }
        return layout.renderSnapshotVersion == preflight.layoutSnapshotVersion
    }
}

private struct RenderStreamingState {
    var operationCount: UInt16 = 0
    var positionedGlyphCount: UInt16 = 0
    var extensionOperationCount: UInt16 = 0

    mutating func stream<
        Semantic, Layout, Metrics, Workspace, Extension, Sink
    >(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        surfaceBounds: Rect,
        workspace: inout Workspace,
        extensionVisitor: inout Extension,
        sink: inout Sink
    ) -> RenderProductionError?
    where
        Semantic: SemanticRenderView,
        Layout: ResolvedRenderLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: RenderProductionWorkspace,
        Extension: RenderStreamingExtension,
        Sink: RenderOperationSink,
        Semantic.Identity == Layout.Identity,
        Semantic.Identity == Workspace.Identity,
        Semantic.Identity == Extension.Identity,
        Extension.Sink == Sink
    {
        guard let ordinal = semantic.semanticOrdinal(of: identity),
            ordinal < semantic.semanticScopeCount,
            semantic.semanticIdentity(at: ordinal) == identity,
            let scope = semantic.scope(at: identity),
            let layoutIdentity = semantic.layoutIdentity(for: identity),
            let layoutOrdinal = layout.layoutOrdinal(of: layoutIdentity),
            layoutOrdinal < layout.layoutScopeCount,
            layout.layoutIdentity(at: layoutOrdinal) == layoutIdentity,
            let bounds = layout.bounds(of: layoutIdentity),
            let logicalClip = layout.clip(of: layoutIdentity),
            let childCount = semantic.childCount(of: identity),
            let finalClip = LayoutGeometry.intersection(
                logicalClip,
                surfaceBounds
            )
        else {
            return .invariantViolation
        }

        switch scope {
        case .foregroundStyle, .background, .clipBoundary:
            guard childCount == 1 else { return .invariantViolation }
        case .text, .canvas:
            guard childCount == 0 else { return .invariantViolation }
        case .structural:
            break
        }

        guard let inheritedForeground = workspace.currentForeground else {
            return .invariantViolation
        }
        let overridesForeground: Bool
        if case .foregroundStyle(let color) = scope {
            guard workspace.pushForeground(color), workspace.currentForeground == color else {
                return .invariantViolation
            }
            overridesForeground = true
        } else {
            overridesForeground = false
        }
        if case .background(let color) = scope,
            bounds.size.width > 0,
            bounds.size.height > 0,
            finalClip.size.width > 0,
            finalClip.size.height > 0
        {
            guard
                sink.fillRect(
                    FillRectOperation(
                        bounds: bounds,
                        clip: finalClip,
                        color: color
                    )
                ), incrementOperation()
            else {
                return .invariantViolation
            }
        }

        if scope == .text {
            guard let foreground = workspace.currentForeground,
                streamText(
                    identity: layoutIdentity,
                    layout: layout,
                    textMetrics: textMetrics,
                    surfaceBounds: surfaceBounds,
                    foreground: foreground,
                    sink: &sink
                )
            else {
                return .invariantViolation
            }
        }

        switch extensionVisitor.visit(
            scope: scope,
            identity: identity,
            bounds: bounds,
            clip: logicalClip,
            sink: &sink
        ) {
        case .success(let visit):
            let extensionTotal = extensionOperationCount.addingReportingOverflow(
                visit.operationCount
            )
            let operationTotal = operationCount.addingReportingOverflow(
                visit.operationCount
            )
            guard !extensionTotal.overflow, !operationTotal.overflow else {
                return .invariantViolation
            }
            extensionOperationCount = extensionTotal.partialValue
            operationCount = operationTotal.partialValue
        case .failure(let error):
            return error
        }

        var childIndex: UInt16 = 0
        while childIndex < childCount {
            guard let child = semantic.child(of: identity, at: childIndex) else {
                return .invariantViolation
            }
            if let error = stream(
                child,
                semantic: semantic,
                layout: layout,
                textMetrics: textMetrics,
                surfaceBounds: surfaceBounds,
                workspace: &workspace,
                extensionVisitor: &extensionVisitor,
                sink: &sink
            ) {
                return error
            }
            childIndex += 1
        }
        guard semantic.child(of: identity, at: childCount) == nil else {
            return .invariantViolation
        }
        if overridesForeground {
            guard workspace.popForeground(),
                workspace.currentForeground == inheritedForeground
            else {
                return .invariantViolation
            }
        } else if workspace.currentForeground != inheritedForeground {
            return .invariantViolation
        }
        return nil
    }

    private mutating func streamText<Layout, Metrics, Sink>(
        identity: Layout.Identity,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        surfaceBounds: Rect,
        foreground: Color,
        sink: inout Sink
    ) -> Bool
    where
        Layout: ResolvedRenderLayoutView,
        Metrics: CanonicalTextMetricsView,
        Sink: RenderOperationSink
    {
        guard let lineCount = layout.textLineCount(of: identity) else {
            return false
        }
        var lineIndex: UInt16 = 0
        var glyphIndex: UInt16 = 0
        while lineIndex < lineCount {
            guard let line = layout.textLine(of: identity, at: lineIndex),
                line.lineIndex == lineIndex,
                let finalClip = LayoutGeometry.intersection(
                    line.clip,
                    surfaceBounds
                )
            else {
                return false
            }
            let emitsGroup =
                line.glyphCount > 0
                && finalClip.size.width > 0
                && finalClip.size.height > 0

            var lineGlyphIndex: UInt16 = 0
            var lineInstance: FontInstanceID?
            while lineGlyphIndex < line.glyphCount {
                guard let glyph = layout.glyph(of: identity, at: glyphIndex),
                    glyph.lineIndex == lineIndex,
                    glyph.glyphIndex == glyphIndex,
                    glyph.clip == line.clip,
                    compatible(
                        instance: glyph.instance,
                        glyph: glyph.glyph,
                        textMetrics: textMetrics
                    )
                else {
                    return false
                }
                if let lineInstance {
                    guard glyph.instance == lineInstance else { return false }
                } else {
                    lineInstance = glyph.instance
                    if emitsGroup,
                        sink.beginPositionedGlyphs(
                            PositionedGlyphOperationHeader(
                                instance: glyph.instance,
                                clip: finalClip,
                                color: foreground,
                                glyphCount: line.glyphCount
                            )
                        ) == false
                    {
                        return false
                    }
                }
                if emitsGroup,
                    sink.positionedGlyph(
                        PositionedGlyph(
                            glyph: glyph.glyph,
                            baseline: glyph.baseline
                        )
                    ) == false
                {
                    return false
                }
                let nextGlyphIndex = glyphIndex.addingReportingOverflow(1)
                guard !nextGlyphIndex.overflow else { return false }
                glyphIndex = nextGlyphIndex.partialValue
                lineGlyphIndex += 1
            }
            if emitsGroup {
                guard lineInstance != nil,
                    sink.endPositionedGlyphs(),
                    incrementOperation(),
                    incrementGlyphs(by: line.glyphCount)
                else {
                    return false
                }
            }
            lineIndex += 1
        }
        guard layout.textLine(of: identity, at: lineCount) == nil else {
            return false
        }
        return layout.glyph(of: identity, at: glyphIndex) == nil
    }

    private func compatible<Metrics>(
        instance: FontInstanceID,
        glyph: GlyphID,
        textMetrics: borrowing Metrics
    ) -> Bool where Metrics: CanonicalTextMetricsView {
        guard instance.resource == textMetrics.descriptor.resource,
            instance.instanceIndex < textMetrics.descriptor.instanceCount,
            let descriptor = textMetrics.instance(at: instance.instanceIndex),
            descriptor.id == instance,
            glyph.rawValue < descriptor.glyphCount,
            textMetrics.metrics(for: glyph, in: instance) != nil
        else {
            return false
        }
        return true
    }

    private mutating func incrementOperation() -> Bool {
        let result = operationCount.addingReportingOverflow(1)
        guard !result.overflow else { return false }
        operationCount = result.partialValue
        return true
    }

    private mutating func incrementGlyphs(by count: UInt16) -> Bool {
        let result = positionedGlyphCount.addingReportingOverflow(count)
        guard !result.overflow else { return false }
        positionedGlyphCount = result.partialValue
        return true
    }
}

private struct EmptyRenderStreamingExtension<Identity, Sink>:
    RenderStreamingExtension
where Identity: Equatable & Sendable, Sink: RenderOperationSink {
    mutating func visit(
        scope _: SemanticRenderScope,
        identity _: Identity,
        bounds _: Rect,
        clip _: Rect,
        sink _: inout Sink
    ) -> RenderExtensionVisitResult {
        .success(RenderExtensionVisit(operationCount: 0))
    }

    mutating func complete() -> RenderExtensionCompletionResult {
        .success
    }
}
