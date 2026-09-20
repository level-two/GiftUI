import GiftUI
import GiftUILayout
import GiftUITextResources

private struct DynamicLayoutWorkspaceScope {
    let identity: DynamicSemanticIdentity
    var measurement: LayoutMeasurement
    var placement: LayoutPlacement?
}

package struct DynamicLayoutWorkspace: LayoutWorkspace {
    package let maximumScopes: UInt16
    package let maximumDepth: UInt16
    package let maximumTextScalars: UInt16
    package let maximumTextLines: UInt16
    package let maximumPositionedGlyphs: UInt16
    package private(set) var isLayoutActive = false

    private var scopes: [DynamicLayoutWorkspaceScope] = []
    private var lines: [LayoutTextLine<DynamicSemanticIdentity>] = []
    private var glyphs: [LayoutPositionedGlyph<DynamicSemanticIdentity>] = []
    private var depth: [DynamicSemanticIdentity] = []

    package init(limits: LayoutLimits) {
        maximumScopes = limits.maximumScopes
        maximumDepth = limits.maximumDepth
        maximumTextScalars = limits.maximumTextScalars
        maximumTextLines = limits.maximumTextLines
        maximumPositionedGlyphs = limits.maximumPositionedGlyphs
        scopes.reserveCapacity(Int(limits.maximumScopes))
        lines.reserveCapacity(Int(limits.maximumTextLines))
        glyphs.reserveCapacity(Int(limits.maximumPositionedGlyphs))
        depth.reserveCapacity(Int(limits.maximumDepth))
    }

    package mutating func acquireLayout() -> Bool {
        guard !isLayoutActive else { return false }
        isLayoutActive = true
        return true
    }

    package mutating func appendScope(
        identity: borrowing DynamicSemanticIdentity,
        measurement: LayoutMeasurement
    ) -> Bool {
        let identity = copy identity
        guard scopes.count < Int(maximumScopes),
            !scopes.contains(where: { $0.identity == identity })
        else { return false }
        scopes.append(
            DynamicLayoutWorkspaceScope(
                identity: identity,
                measurement: measurement,
                placement: nil
            )
        )
        return true
    }

    package var scopeCount: UInt16 { UInt16(scopes.count) }

    package func scopeIdentity(at index: UInt16) -> DynamicSemanticIdentity? {
        guard Int(index) < scopes.count else { return nil }
        return scopes[Int(index)].identity
    }

    package func measurement(
        for identity: borrowing DynamicSemanticIdentity
    ) -> LayoutMeasurement? {
        let identity = copy identity
        return scopes.first { $0.identity == identity }?.measurement
    }

    package mutating func storeMeasurement(
        _ measurement: LayoutMeasurement,
        for identity: borrowing DynamicSemanticIdentity
    ) -> Bool {
        let identity = copy identity
        guard let index = scopes.firstIndex(where: { $0.identity == identity })
        else { return false }
        scopes[index].measurement = measurement
        return true
    }

    package mutating func storePlacement(
        _ placement: LayoutPlacement,
        for identity: borrowing DynamicSemanticIdentity
    ) -> Bool {
        let identity = copy identity
        guard let index = scopes.firstIndex(where: { $0.identity == identity }),
            scopes[index].placement == nil
        else { return false }
        scopes[index].placement = placement
        return true
    }

    package func placement(
        for identity: borrowing DynamicSemanticIdentity
    ) -> LayoutPlacement? {
        let identity = copy identity
        return scopes.first { $0.identity == identity }?.placement
    }

    package var textLineCount: UInt16 { UInt16(lines.count) }

    package mutating func appendTextLine(
        _ line: LayoutTextLine<DynamicSemanticIdentity>
    ) -> Bool {
        guard lines.count < Int(maximumTextLines) else { return false }
        lines.append(line)
        return true
    }

    package func textLine(
        at index: UInt16
    ) -> LayoutTextLine<DynamicSemanticIdentity>? {
        guard Int(index) < lines.count else { return nil }
        return lines[Int(index)]
    }

    package mutating func storeTextLine(
        _ line: LayoutTextLine<DynamicSemanticIdentity>,
        at index: UInt16
    ) -> Bool {
        guard Int(index) < lines.count else { return false }
        lines[Int(index)] = line
        return true
    }

    package var positionedGlyphCount: UInt16 { UInt16(glyphs.count) }

    package mutating func appendPositionedGlyph(
        _ glyph: LayoutPositionedGlyph<DynamicSemanticIdentity>
    ) -> Bool {
        guard glyphs.count < Int(maximumPositionedGlyphs) else { return false }
        glyphs.append(glyph)
        return true
    }

    package func positionedGlyph(
        at index: UInt16
    ) -> LayoutPositionedGlyph<DynamicSemanticIdentity>? {
        guard Int(index) < glyphs.count else { return nil }
        return glyphs[Int(index)]
    }

    package mutating func storePositionedGlyph(
        _ glyph: LayoutPositionedGlyph<DynamicSemanticIdentity>,
        at index: UInt16
    ) -> Bool {
        guard Int(index) < glyphs.count else { return false }
        glyphs[Int(index)] = glyph
        return true
    }

    package mutating func pushScope(
        _ identity: borrowing DynamicSemanticIdentity
    ) -> Bool {
        guard depth.count < Int(maximumDepth) else { return false }
        depth.append(copy identity)
        return true
    }

    package mutating func popScope() {
        _ = depth.popLast()
    }

    package mutating func resetLayout() {
        scopes.removeAll(keepingCapacity: true)
        lines.removeAll(keepingCapacity: true)
        glyphs.removeAll(keepingCapacity: true)
        depth.removeAll(keepingCapacity: true)
        isLayoutActive = false
    }
}

private struct DynamicResolvedLayoutScope: Equatable, Sendable {
    let identity: DynamicSemanticIdentity
    let bounds: Rect
    let clip: Rect
}

private struct DynamicResolvedLayoutLine: Equatable, Sendable {
    let identity: DynamicSemanticIdentity
    let line: ResolvedRenderTextLine
}

private struct DynamicResolvedLayoutGlyph: Equatable, Sendable {
    let identity: DynamicSemanticIdentity
    let glyph: ResolvedRenderGlyph
}

package struct DynamicResolvedLayoutView: ResolvedRenderLayoutView {
    package let rootIdentity: DynamicSemanticIdentity
    package let layoutScopeCount: UInt16
    package let renderSnapshotVersion: UInt32
    package let rootBounds: Rect
    private let scopes: [DynamicResolvedLayoutScope]
    private let lines: [DynamicResolvedLayoutLine]
    private let glyphs: [DynamicResolvedLayoutGlyph]

    fileprivate init(
        rootIdentity: DynamicSemanticIdentity,
        layoutScopeCount: UInt16,
        renderSnapshotVersion: UInt32,
        rootBounds: Rect,
        scopes: [DynamicResolvedLayoutScope],
        lines: [DynamicResolvedLayoutLine],
        glyphs: [DynamicResolvedLayoutGlyph]
    ) {
        self.rootIdentity = rootIdentity
        self.layoutScopeCount = layoutScopeCount
        self.renderSnapshotVersion = renderSnapshotVersion
        self.rootBounds = rootBounds
        self.scopes = scopes
        self.lines = lines
        self.glyphs = glyphs
    }

    package func layoutIdentity(at ordinal: UInt16) -> DynamicSemanticIdentity? {
        guard Int(ordinal) < scopes.count else { return nil }
        return scopes[Int(ordinal)].identity
    }

    package func layoutOrdinal(of identity: DynamicSemanticIdentity) -> UInt16? {
        scopes.firstIndex { $0.identity == identity }.map(UInt16.init)
    }

    package func bounds(of identity: DynamicSemanticIdentity) -> Rect? {
        scopes.first { $0.identity == identity }?.bounds
    }

    package func clip(of identity: DynamicSemanticIdentity) -> Rect? {
        scopes.first { $0.identity == identity }?.clip
    }

    package func textLineCount(of identity: DynamicSemanticIdentity) -> UInt16? {
        guard scopes.contains(where: { $0.identity == identity }) else { return nil }
        return UInt16(lines.lazy.filter { $0.identity == identity }.count)
    }

    package func textLine(
        of identity: DynamicSemanticIdentity,
        at index: UInt16
    ) -> ResolvedRenderTextLine? {
        lines.first {
            $0.identity == identity && $0.line.lineIndex == index
        }?.line
    }

    package func glyph(
        of identity: DynamicSemanticIdentity,
        at index: UInt16
    ) -> ResolvedRenderGlyph? {
        glyphs.first {
            $0.identity == identity && $0.glyph.glyphIndex == index
        }?.glyph
    }
}

package struct DynamicResolvedLayoutStorage: ResolvedRenderLayoutResultStorage {
    package private(set) var isLayoutActive = false
    package private(set) var hasPublishedResult = false

    private let limits: LayoutLimits
    private var candidateSummary: LayoutSummary?
    private var candidateScopes: [DynamicResolvedLayoutScope] = []
    private var candidateLines: [DynamicResolvedLayoutLine] = []
    private var candidateGlyphs: [DynamicResolvedLayoutGlyph] = []
    private var publishedSummary: LayoutSummary?
    private var publishedScopes: [DynamicResolvedLayoutScope] = []
    private var publishedLines: [DynamicResolvedLayoutLine] = []
    private var publishedGlyphs: [DynamicResolvedLayoutGlyph] = []
    private var version: UInt32 = 0

    package init(limits: LayoutLimits) {
        self.limits = limits
        candidateScopes.reserveCapacity(Int(limits.maximumScopes))
        candidateLines.reserveCapacity(Int(limits.maximumTextLines))
        candidateGlyphs.reserveCapacity(Int(limits.maximumPositionedGlyphs))
        publishedScopes.reserveCapacity(Int(limits.maximumScopes))
        publishedLines.reserveCapacity(Int(limits.maximumTextLines))
        publishedGlyphs.reserveCapacity(Int(limits.maximumPositionedGlyphs))
    }

    package var renderView: DynamicResolvedLayoutView {
        precondition(hasPublishedResult)
        let summary = publishedSummary!
        return DynamicResolvedLayoutView(
            rootIdentity: publishedScopes[0].identity,
            layoutScopeCount: summary.scopeCount,
            renderSnapshotVersion: version,
            rootBounds: summary.rootBounds,
            scopes: publishedScopes,
            lines: publishedLines,
            glyphs: publishedGlyphs
        )
    }

    package mutating func begin(summary: LayoutSummary) -> Bool {
        guard !isLayoutActive,
            summary.scopeCount > 0,
            summary.scopeCount <= limits.maximumScopes,
            summary.textScalarCount <= limits.maximumTextScalars,
            summary.textLineCount <= limits.maximumTextLines,
            summary.positionedGlyphCount <= limits.maximumPositionedGlyphs,
            summary.maximumObservedDepth <= limits.maximumDepth
        else { return false }
        clearCandidate()
        candidateSummary = summary
        isLayoutActive = true
        return true
    }

    package mutating func stageScope(
        identity: DynamicSemanticIdentity,
        bounds: Rect,
        clip: Rect
    ) -> Bool {
        guard isLayoutActive,
            candidateScopes.count < Int(limits.maximumScopes),
            !candidateScopes.contains(where: { $0.identity == identity })
        else { return false }
        candidateScopes.append(
            DynamicResolvedLayoutScope(identity: identity, bounds: bounds, clip: clip)
        )
        return true
    }

    package mutating func stageTextLine(
        identity: DynamicSemanticIdentity,
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        clip: Rect
    ) -> Bool {
        guard isLayoutActive,
            candidateLines.count < Int(limits.maximumTextLines),
            candidateScopes.contains(where: { $0.identity == identity })
        else { return false }
        candidateLines.append(
            DynamicResolvedLayoutLine(
                identity: identity,
                line: ResolvedRenderTextLine(
                    lineIndex: lineIndex,
                    bounds: bounds,
                    baseline: baseline,
                    clip: clip,
                    glyphCount: 0
                )
            )
        )
        return true
    }

    package mutating func stageGlyph(
        identity: DynamicSemanticIdentity,
        lineIndex: UInt16,
        glyphIndex: UInt16,
        instance: FontInstanceID,
        glyph: GlyphID,
        baseline: Point,
        clip: Rect
    ) -> Bool {
        guard isLayoutActive,
            candidateGlyphs.count < Int(limits.maximumPositionedGlyphs),
            candidateLines.contains(where: {
                $0.identity == identity && $0.line.lineIndex == lineIndex
            })
        else { return false }
        candidateGlyphs.append(
            DynamicResolvedLayoutGlyph(
                identity: identity,
                glyph: ResolvedRenderGlyph(
                    lineIndex: lineIndex,
                    glyphIndex: glyphIndex,
                    instance: instance,
                    glyph: glyph,
                    baseline: baseline,
                    clip: clip
                )
            )
        )
        return true
    }

    package mutating func publish() -> Bool {
        guard isLayoutActive, let summary = candidateSummary,
            candidateScopes.count == Int(summary.scopeCount),
            candidateLines.count == Int(summary.textLineCount),
            candidateGlyphs.count == Int(summary.positionedGlyphCount)
        else { return false }
        let nextVersion = version.addingReportingOverflow(1)
        guard !nextVersion.overflow, nextVersion.partialValue != 0 else { return false }
        publishedSummary = summary
        publishedScopes = candidateScopes
        publishedLines = candidateLines.map { record in
            DynamicResolvedLayoutLine(
                identity: record.identity,
                line: ResolvedRenderTextLine(
                    lineIndex: record.line.lineIndex,
                    bounds: record.line.bounds,
                    baseline: record.line.baseline,
                    clip: record.line.clip,
                    glyphCount: UInt16(
                        candidateGlyphs.lazy.filter {
                            $0.identity == record.identity
                                && $0.glyph.lineIndex == record.line.lineIndex
                        }.count
                    )
                )
            )
        }
        publishedGlyphs = candidateGlyphs
        version = nextVersion.partialValue
        hasPublishedResult = true
        clearCandidate()
        isLayoutActive = false
        return true
    }

    package mutating func discard() {
        clearCandidate()
        isLayoutActive = false
    }

    private mutating func clearCandidate() {
        candidateSummary = nil
        candidateScopes.removeAll(keepingCapacity: true)
        candidateLines.removeAll(keepingCapacity: true)
        candidateGlyphs.removeAll(keepingCapacity: true)
    }
}
