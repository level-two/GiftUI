import GiftUI
import GiftUILayout
import GiftUIRenderCore
import GiftUISemanticCore
import GiftUITextResources

@usableFromInline
package enum RenderProducer {}

@usableFromInline
internal struct RenderPreflightSummary {
    @usableFromInline
    let header: RenderPlanHeader
    @usableFromInline
    let semanticSnapshotVersion: UInt32
    @usableFromInline
    let layoutSnapshotVersion: UInt32
    @usableFromInline
    let extensionOperationCount: UInt16

    @inlinable
    init(
        header: RenderPlanHeader,
        semanticSnapshotVersion: UInt32,
        layoutSnapshotVersion: UInt32,
        extensionOperationCount: UInt16
    ) {
        self.header = header
        self.semanticSnapshotVersion = semanticSnapshotVersion
        self.layoutSnapshotVersion = layoutSnapshotVersion
        self.extensionOperationCount = extensionOperationCount
    }
}

@usableFromInline
internal enum RenderPreflightResult {
    case success(RenderPreflightSummary)
    case failure(RenderProductionError)
}

extension RenderProducer {
    @inlinable
    static func preflight<Semantic, Layout, Metrics, Workspace, Sink>(
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        surfaceBounds: Rect,
        damageMode: RenderDamageMode,
        limits: RenderLimits,
        workspace: inout Workspace,
        sink: inout Sink
    ) -> RenderPreflightResult
    where
        Semantic: SemanticRenderView & ~Escapable,
        Layout: ResolvedRenderLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: RenderProductionWorkspace,
        Sink: RenderOperationSink,
        Semantic.Identity == Layout.Identity,
        Semantic.Identity == Workspace.Identity
    {
        var extensionVisitor = EmptyRenderPreflightExtension<Semantic.Identity>()
        let result = preflightTraversal(
            semantic: semantic,
            layout: layout,
            textMetrics: textMetrics,
            surfaceBounds: surfaceBounds,
            damageMode: damageMode,
            limits: limits,
            workspace: &workspace,
            extensionVisitor: &extensionVisitor
        )
        guard case .success(let summary) = result else { return result }
        let sinkCapacity = sink.capacity
        guard summary.header.operationCount <= sinkCapacity.maximumOperations,
            summary.header.positionedGlyphCount
                <= sinkCapacity.maximumPositionedGlyphs
        else {
            return .failure(.capacityExhausted)
        }
        guard case .success = extensionVisitor.complete() else {
            return .failure(.invariantViolation)
        }
        return result
    }

    @inlinable
    package static func preflight<
        Semantic, Layout, Metrics, Workspace, Extension
    >(
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        surfaceBounds: Rect,
        damageMode: RenderDamageMode,
        limits: RenderLimits,
        configuredSinkCapacity: RenderSinkCapacity,
        workspace: inout Workspace,
        extensionVisitor: inout Extension
    ) -> RenderProductionResult
    where
        Semantic: SemanticRenderView & ~Escapable,
        Layout: ResolvedRenderLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: RenderProductionWorkspace,
        Extension: RenderPreflightExtension,
        Semantic.Identity == Layout.Identity,
        Semantic.Identity == Workspace.Identity,
        Semantic.Identity == Extension.Identity
    {
        if workspace.isActive {
            return .failure(.reentrancyViolation)
        }
        guard workspace.acquire() else {
            return .failure(.invariantViolation)
        }
        defer { workspace.reset() }

        let result = preflightTraversal(
            semantic: semantic,
            layout: layout,
            textMetrics: textMetrics,
            surfaceBounds: surfaceBounds,
            damageMode: damageMode,
            limits: limits,
            workspace: &workspace,
            extensionVisitor: &extensionVisitor
        )
        guard case .success(let summary) = result else {
            if case .failure(let error) = result { return .failure(error) }
            return .failure(.invariantViolation)
        }
        guard
            summary.header.operationCount
                <= configuredSinkCapacity.maximumOperations,
            summary.header.positionedGlyphCount
                <= configuredSinkCapacity.maximumPositionedGlyphs
        else { return .failure(.capacityExhausted) }
        switch extensionVisitor.complete() {
        case .success:
            break
        case .failure(let error):
            return .failure(error)
        }
        return .success(summary.header)
    }

    @inlinable
    static func preflightTraversal<
        Semantic, Layout, Metrics, Workspace, Extension
    >(
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        surfaceBounds: Rect,
        damageMode: RenderDamageMode,
        limits: RenderLimits,
        workspace: inout Workspace,
        extensionVisitor: inout Extension
    ) -> RenderPreflightResult
    where
        Semantic: SemanticRenderView & ~Escapable,
        Layout: ResolvedRenderLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: RenderProductionWorkspace,
        Extension: RenderPreflightExtension,
        Semantic.Identity == Layout.Identity,
        Semantic.Identity == Workspace.Identity,
        Semantic.Identity == Extension.Identity
    {
        let semanticVersion = semantic.renderSnapshotVersion
        let layoutVersion = layout.renderSnapshotVersion

        guard surfaceBounds.origin == Point(x: 0, y: 0) else {
            return .failure(.invalidInput)
        }
        let mappedRoot = semantic.layoutIdentity(for: semantic.rootIdentity)
        if let mappedRoot, mappedRoot != layout.rootIdentity {
            return .failure(.invalidInput)
        }

        let structuralCapacity = workspace.structuralCapacity
        guard limits.maximumOperations <= workspace.capacity.maximumOperations,
            limits.maximumPositionedGlyphs
                <= workspace.capacity.maximumPositionedGlyphs,
            limits.maximumClipDepth <= workspace.capacity.maximumClipDepth,
            semantic.semanticScopeCount
                <= structuralCapacity.maximumSemanticScopes,
            layout.layoutScopeCount <= structuralCapacity.maximumLayoutScopes
        else {
            return .failure(.capacityExhausted)
        }
        guard case .some = mappedRoot else {
            return .failure(.invariantViolation)
        }

        var state = RenderPreflightState(
            limits: limits,
            structuralCapacity: structuralCapacity
        )
        if let error = state.visit(
            semantic.rootIdentity,
            semantic: semantic,
            layout: layout,
            textMetrics: textMetrics,
            surfaceBounds: surfaceBounds,
            semanticDepth: 1,
            clipDepth: 1,
            workspace: &workspace,
            extensionVisitor: &extensionVisitor
        ) {
            return .failure(error)
        }

        guard state.semanticVisitCount == semantic.semanticScopeCount,
            state.layoutVisitCount == layout.layoutScopeCount,
            case .none = semantic.semanticIdentity(at: semantic.semanticScopeCount),
            case .none = layout.layoutIdentity(at: layout.layoutScopeCount)
        else {
            return .failure(.invariantViolation)
        }
        let damageBounds: Rect
        switch damageMode {
        case .rootIntersection:
            guard
                let intersection = LayoutGeometry.intersection(
                    layout.rootBounds,
                    surfaceBounds
                )
            else {
                return .failure(.arithmeticOverflow)
            }
            damageBounds = intersection
        case .initializeCompleteSurface:
            damageBounds = surfaceBounds
        }

        guard semantic.renderSnapshotVersion == semanticVersion,
            layout.renderSnapshotVersion == layoutVersion
        else {
            return .failure(.invariantViolation)
        }

        return .success(
            RenderPreflightSummary(
                header: RenderPlanHeader(
                    surfaceBounds: surfaceBounds,
                    damageBounds: damageBounds,
                    operationCount: state.operationCount,
                    positionedGlyphCount: state.positionedGlyphCount,
                    maximumObservedClipDepth: state.maximumObservedClipDepth
                ),
                semanticSnapshotVersion: semanticVersion,
                layoutSnapshotVersion: layoutVersion,
                extensionOperationCount: state.extensionOperationCount
            )
        )
    }
}

@usableFromInline
internal struct RenderPreflightState {
    @usableFromInline
    let limits: RenderLimits
    @usableFromInline
    let structuralCapacity: RenderWorkspaceCapacity
    @usableFromInline
    var operationCount: UInt16 = 0
    @usableFromInline
    var positionedGlyphCount: UInt16 = 0
    @usableFromInline
    var maximumObservedClipDepth: UInt16 = 1
    @usableFromInline
    var semanticVisitCount: UInt16 = 0
    @usableFromInline
    var layoutVisitCount: UInt16 = 0
    @usableFromInline
    var textLineCount: UInt16 = 0
    @usableFromInline
    var extensionOperationCount: UInt16 = 0

    @inlinable
    init(limits: RenderLimits, structuralCapacity: RenderWorkspaceCapacity) {
        self.limits = limits
        self.structuralCapacity = structuralCapacity
    }

    @inlinable
    mutating func visit<Semantic, Layout, Metrics, Workspace, Extension>(
        _ identity: Semantic.Identity,
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        surfaceBounds: Rect,
        semanticDepth: UInt16,
        clipDepth: UInt16,
        workspace: inout Workspace,
        extensionVisitor: inout Extension
    ) -> RenderProductionError?
    where
        Semantic: SemanticRenderView & ~Escapable,
        Layout: ResolvedRenderLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: RenderProductionWorkspace,
        Extension: RenderPreflightExtension,
        Semantic.Identity == Layout.Identity,
        Semantic.Identity == Workspace.Identity,
        Semantic.Identity == Extension.Identity
    {
        guard semanticDepth <= structuralCapacity.maximumTraversalDepth else {
            return .capacityExhausted
        }
        guard let ordinal = semantic.semanticOrdinal(of: identity),
            ordinal < semantic.semanticScopeCount,
            semantic.semanticIdentity(at: ordinal) == identity
        else {
            return .invariantViolation
        }
        switch workspace.visitSemanticScope(at: ordinal) {
        case .first:
            guard let next = incremented(semanticVisitCount) else {
                return .capacityExhausted
            }
            semanticVisitCount = next
        case .repeated, .invalid:
            return .invariantViolation
        }

        guard let scope = semantic.scope(at: identity),
            let layoutIdentity = semantic.layoutIdentity(for: identity),
            let layoutOrdinal = layout.layoutOrdinal(of: layoutIdentity),
            layoutOrdinal < layout.layoutScopeCount,
            layout.layoutIdentity(at: layoutOrdinal) == layoutIdentity,
            let bounds = layout.bounds(of: layoutIdentity),
            let logicalClip = layout.clip(of: layoutIdentity),
            let childCount = semantic.childCount(of: identity)
        else {
            return .invariantViolation
        }
        switch workspace.visitLayoutScope(at: layoutOrdinal) {
        case .first:
            guard let next = incremented(layoutVisitCount) else {
                return .capacityExhausted
            }
            layoutVisitCount = next
        case .repeated:
            break
        case .invalid:
            return .invariantViolation
        }

        guard let finalClip = LayoutGeometry.intersection(logicalClip, surfaceBounds)
        else {
            return .arithmeticOverflow
        }

        var activeClipDepth = clipDepth
        if scope == .clipBoundary {
            guard let next = incremented(activeClipDepth) else {
                return .capacityExhausted
            }
            activeClipDepth = next
            if let error = observeClipDepth(activeClipDepth) { return error }
        }

        switch scope {
        case .foregroundStyle, .background, .clipBoundary:
            guard childCount == 1 else { return .invariantViolation }
        case .text, .canvas:
            guard childCount == 0 else { return .invariantViolation }
        case .structural:
            break
        }

        if case .background = scope,
            bounds.size.width > 0,
            bounds.size.height > 0,
            finalClip.size.width > 0,
            finalClip.size.height > 0,
            let error = reserveOperation()
        {
            return error
        }

        if scope == .text,
            let error = validateText(
                identity: layoutIdentity,
                layout: layout,
                textMetrics: textMetrics,
                surfaceBounds: surfaceBounds,
                clipDepth: activeClipDepth
            )
        {
            return error
        }

        switch extensionVisitor.visit(
            scope: scope,
            identity: identity,
            bounds: bounds,
            clip: logicalClip
        ) {
        case .success(let visit):
            if let error = reserveOperations(visit.operationCount) { return error }
            let extensionTotal = extensionOperationCount.addingReportingOverflow(
                visit.operationCount
            )
            guard !extensionTotal.overflow else { return .capacityExhausted }
            extensionOperationCount = extensionTotal.partialValue
        case .failure(let error):
            return error
        }

        var childIndex: UInt16 = 0
        while childIndex < childCount {
            guard let child = semantic.child(of: identity, at: childIndex) else {
                return .invariantViolation
            }
            guard let childDepth = incremented(semanticDepth) else {
                return .capacityExhausted
            }
            if let error = visit(
                child,
                semantic: semantic,
                layout: layout,
                textMetrics: textMetrics,
                surfaceBounds: surfaceBounds,
                semanticDepth: childDepth,
                clipDepth: activeClipDepth,
                workspace: &workspace,
                extensionVisitor: &extensionVisitor
            ) {
                return error
            }
            childIndex += 1
        }
        guard case .none = semantic.child(of: identity, at: childCount) else {
            return .invariantViolation
        }
        return nil
    }

    @inlinable
    mutating func validateText<Layout, Metrics>(
        identity: Layout.Identity,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        surfaceBounds: Rect,
        clipDepth: UInt16
    ) -> RenderProductionError?
    where Layout: ResolvedRenderLayoutView, Metrics: CanonicalTextMetricsView {
        guard let lineCount = layout.textLineCount(of: identity) else {
            return .invariantViolation
        }
        var lineIndex: UInt16 = 0
        var glyphIndex: UInt16 = 0
        while lineIndex < lineCount {
            guard let nextTextLineCount = incremented(textLineCount),
                nextTextLineCount <= structuralCapacity.maximumTextLines
            else {
                return .capacityExhausted
            }
            textLineCount = nextTextLineCount
            guard let line = layout.textLine(of: identity, at: lineIndex),
                line.lineIndex == lineIndex
            else {
                return .invariantViolation
            }
            guard let lineClipDepth = incremented(clipDepth) else {
                return .capacityExhausted
            }
            if let error = observeClipDepth(lineClipDepth) { return error }
            guard
                let finalClip = LayoutGeometry.intersection(
                    line.clip,
                    surfaceBounds
                )
            else {
                return .arithmeticOverflow
            }

            let emitsGroup =
                line.glyphCount > 0
                && finalClip.size.width > 0
                && finalClip.size.height > 0
            if emitsGroup {
                if let error = reserveOperation() { return error }
                let glyphTotal = positionedGlyphCount.addingReportingOverflow(
                    line.glyphCount
                )
                guard !glyphTotal.overflow,
                    glyphTotal.partialValue <= limits.maximumPositionedGlyphs
                else {
                    return .capacityExhausted
                }
                positionedGlyphCount = glyphTotal.partialValue
            }

            var lineGlyphIndex: UInt16 = 0
            var lineInstance: FontInstanceID?
            while lineGlyphIndex < line.glyphCount {
                guard let glyph = layout.glyph(of: identity, at: glyphIndex),
                    glyph.lineIndex == lineIndex,
                    glyph.glyphIndex == glyphIndex,
                    glyph.clip == line.clip
                else {
                    return .invariantViolation
                }
                if let lineInstance {
                    guard glyph.instance == lineInstance else {
                        return .invariantViolation
                    }
                } else {
                    lineInstance = glyph.instance
                }
                guard
                    isCompatible(
                        instance: glyph.instance,
                        glyph: glyph.glyph,
                        textMetrics: textMetrics
                    )
                else {
                    return .incompatibleTextResource
                }
                guard let nextGlyphIndex = incremented(glyphIndex) else {
                    return .capacityExhausted
                }
                glyphIndex = nextGlyphIndex
                lineGlyphIndex += 1
            }

            lineIndex += 1
        }
        guard case .none = layout.textLine(of: identity, at: lineCount),
            case .none = layout.glyph(of: identity, at: glyphIndex)
        else {
            return .invariantViolation
        }
        return nil
    }

    @inlinable
    func isCompatible<Metrics>(
        instance: FontInstanceID,
        glyph: GlyphID,
        textMetrics: borrowing Metrics
    ) -> Bool where Metrics: CanonicalTextMetricsView {
        guard instance.resource == textMetrics.descriptor.resource,
            instance.instanceIndex < textMetrics.descriptor.instanceCount,
            let descriptor = textMetrics.instance(at: instance.instanceIndex),
            descriptor.id == instance,
            glyph.rawValue < descriptor.glyphCount,
            case .some = textMetrics.metrics(for: glyph, in: instance)
        else {
            return false
        }
        return true
    }

    @inlinable
    mutating func reserveOperation() -> RenderProductionError? {
        reserveOperations(1)
    }

    @inlinable
    mutating func reserveOperations(
        _ count: UInt16
    ) -> RenderProductionError? {
        let next = operationCount.addingReportingOverflow(count)
        guard !next.overflow,
            next.partialValue <= limits.maximumOperations
        else {
            return .capacityExhausted
        }
        operationCount = next.partialValue
        return nil
    }

    @inlinable
    mutating func observeClipDepth(
        _ depth: UInt16
    ) -> RenderProductionError? {
        guard depth <= limits.maximumClipDepth else {
            return .capacityExhausted
        }
        maximumObservedClipDepth = max(maximumObservedClipDepth, depth)
        return nil
    }

    @inlinable
    func incremented(_ value: UInt16) -> UInt16? {
        let result = value.addingReportingOverflow(1)
        return result.overflow ? nil : result.partialValue
    }
}

@usableFromInline
internal struct EmptyRenderPreflightExtension<Identity>: RenderPreflightExtension
where Identity: Equatable & Sendable {
    @inlinable
    init() {}

    @inlinable
    mutating func visit(
        scope _: SemanticRenderScope,
        identity _: Identity,
        bounds _: Rect,
        clip _: Rect
    ) -> RenderExtensionVisitResult {
        .success(RenderExtensionVisit(operationCount: 0))
    }

    @inlinable
    mutating func complete() -> RenderExtensionCompletionResult {
        .success
    }
}
