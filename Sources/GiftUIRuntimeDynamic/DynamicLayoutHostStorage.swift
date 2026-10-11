import GiftUI
import GiftUILayout
import GiftUISemanticCore
import GiftUITextResources

private struct DynamicLayoutWorkspaceScope {
    let identity: SemanticRecordReference
    var measurement: LayoutMeasurement
    var placement: LayoutPlacement?
    var lineRange: Range<UInt16>?
    var glyphRange: Range<UInt16>?
}

package struct DynamicLayoutWorkspace: LayoutWorkspace {
    package let maximumScopes: UInt16
    package let maximumDepth: UInt16
    package let maximumTextScalars: UInt16
    package let maximumTextLines: UInt16
    package let maximumPositionedGlyphs: UInt16
    package private(set) var isLayoutActive = false

    private var scopes: [DynamicLayoutWorkspaceScope] = []
    private var scopeIndex: [Int?]
    private var lines: [LayoutTextLine<SemanticRecordReference>] = []
    private var glyphs: [LayoutPositionedGlyph<SemanticRecordReference>] = []
    private var depth: [SemanticRecordReference] = []

    package init(limits: LayoutLimits, maximumSemanticRecords: UInt16) {
        maximumScopes = limits.maximumScopes
        maximumDepth = limits.maximumDepth
        maximumTextScalars = limits.maximumTextScalars
        maximumTextLines = limits.maximumTextLines
        maximumPositionedGlyphs = limits.maximumPositionedGlyphs
        scopes.reserveCapacity(Int(limits.maximumScopes))
        scopeIndex = Array(repeating: nil, count: Int(maximumSemanticRecords))
        lines.reserveCapacity(Int(limits.maximumTextLines))
        glyphs.reserveCapacity(Int(limits.maximumPositionedGlyphs))
        depth.reserveCapacity(Int(limits.maximumDepth))
    }

    /// One indexed entry and one complete-reference comparison per lookup.
    private func index(of identity: SemanticRecordReference) -> Int? {
        guard Int(identity.ordinal) < scopeIndex.count,
            let index = scopeIndex[Int(identity.ordinal)],
            scopes[index].identity == identity
        else { return nil }
        return index
    }

    /// Exclusive retained Array payload; value metadata is accounted by its owner.
    package var reservedPayloadBytes: UInt64 {
        UInt64(scopes.capacity * MemoryLayout<DynamicLayoutWorkspaceScope>.stride)
            + UInt64(scopeIndex.capacity * MemoryLayout<Int?>.stride)
            + UInt64(lines.capacity * MemoryLayout<LayoutTextLine<SemanticRecordReference>>.stride)
            + UInt64(
                glyphs.capacity
                    * MemoryLayout<LayoutPositionedGlyph<SemanticRecordReference>>.stride)
            + UInt64(depth.capacity * MemoryLayout<SemanticRecordReference>.stride)
    }

    package mutating func acquireLayout() -> Bool {
        guard !isLayoutActive else { return false }
        isLayoutActive = true
        return true
    }

    package mutating func appendScope(
        identity: borrowing SemanticRecordReference,
        measurement: LayoutMeasurement
    ) -> Bool {
        let identity = copy identity
        guard scopes.count < Int(maximumScopes),
            Int(identity.ordinal) < scopeIndex.count,
            scopeIndex[Int(identity.ordinal)] == nil
        else { return false }
        scopeIndex[Int(identity.ordinal)] = scopes.count
        scopes.append(
            DynamicLayoutWorkspaceScope(
                identity: identity,
                measurement: measurement,
                placement: nil,
                lineRange: nil,
                glyphRange: nil
            )
        )
        return true
    }

    package var scopeCount: UInt16 { UInt16(scopes.count) }

    package func scopeIdentity(at index: UInt16) -> SemanticRecordReference? {
        guard Int(index) < scopes.count else { return nil }
        return scopes[Int(index)].identity
    }

    package func measurement(
        for identity: borrowing SemanticRecordReference
    ) -> LayoutMeasurement? {
        let identity = copy identity
        guard let index = index(of: identity) else { return nil }
        return scopes[index].measurement
    }

    package mutating func storeMeasurement(
        _ measurement: LayoutMeasurement,
        for identity: borrowing SemanticRecordReference
    ) -> Bool {
        let identity = copy identity
        guard let index = index(of: identity)
        else { return false }
        scopes[index].measurement = measurement
        return true
    }

    package mutating func storePlacement(
        _ placement: LayoutPlacement,
        for identity: borrowing SemanticRecordReference
    ) -> Bool {
        let identity = copy identity
        guard let index = index(of: identity),
            scopes[index].placement == nil
        else { return false }
        scopes[index].placement = placement
        return true
    }

    package func placement(
        for identity: borrowing SemanticRecordReference
    ) -> LayoutPlacement? {
        let identity = copy identity
        guard let index = index(of: identity) else { return nil }
        return scopes[index].placement
    }

    package var textLineCount: UInt16 { UInt16(lines.count) }

    package mutating func appendTextLine(
        _ line: LayoutTextLine<SemanticRecordReference>
    ) -> Bool {
        guard lines.count < Int(maximumTextLines),
            let index = index(of: line.identity)
        else { return false }
        let ordinal = UInt16(lines.count)
        if let range = scopes[index].lineRange {
            guard range.upperBound == ordinal else { return false }
            scopes[index].lineRange = range.lowerBound ..< (ordinal + 1)
        } else {
            scopes[index].lineRange = ordinal ..< (ordinal + 1)
        }
        lines.append(line)
        return true
    }

    package func textLineRange(
        for identity: borrowing SemanticRecordReference
    ) -> Range<UInt16>? {
        let identity = copy identity
        guard let index = index(of: identity) else { return nil }
        return scopes[index].lineRange
    }

    package func textLine(
        at index: UInt16
    ) -> LayoutTextLine<SemanticRecordReference>? {
        guard Int(index) < lines.count else { return nil }
        return lines[Int(index)]
    }

    package mutating func storeTextLine(
        _ line: LayoutTextLine<SemanticRecordReference>,
        at index: UInt16
    ) -> Bool {
        guard Int(index) < lines.count else { return false }
        lines[Int(index)] = line
        return true
    }

    package var positionedGlyphCount: UInt16 { UInt16(glyphs.count) }

    package mutating func appendPositionedGlyph(
        _ glyph: LayoutPositionedGlyph<SemanticRecordReference>
    ) -> Bool {
        guard glyphs.count < Int(maximumPositionedGlyphs),
            let index = index(of: glyph.identity)
        else { return false }
        let ordinal = UInt16(glyphs.count)
        if let range = scopes[index].glyphRange {
            guard range.upperBound == ordinal else { return false }
            scopes[index].glyphRange = range.lowerBound ..< (ordinal + 1)
        } else {
            scopes[index].glyphRange = ordinal ..< (ordinal + 1)
        }
        glyphs.append(glyph)
        return true
    }

    package func positionedGlyphRange(
        for identity: borrowing SemanticRecordReference
    ) -> Range<UInt16>? {
        let identity = copy identity
        guard let index = index(of: identity) else { return nil }
        return scopes[index].glyphRange
    }

    package func positionedGlyph(
        at index: UInt16
    ) -> LayoutPositionedGlyph<SemanticRecordReference>? {
        guard Int(index) < glyphs.count else { return nil }
        return glyphs[Int(index)]
    }

    package mutating func storePositionedGlyph(
        _ glyph: LayoutPositionedGlyph<SemanticRecordReference>,
        at index: UInt16
    ) -> Bool {
        guard Int(index) < glyphs.count else { return false }
        glyphs[Int(index)] = glyph
        return true
    }

    package mutating func pushScope(
        _ identity: borrowing SemanticRecordReference
    ) -> Bool {
        guard depth.count < Int(maximumDepth) else { return false }
        depth.append(copy identity)
        return true
    }

    package mutating func popScope() {
        _ = depth.popLast()
    }

    package mutating func resetLayout() {
        for scope in scopes { scopeIndex[Int(scope.identity.ordinal)] = nil }
        scopes.removeAll(keepingCapacity: true)
        lines.removeAll(keepingCapacity: true)
        glyphs.removeAll(keepingCapacity: true)
        depth.removeAll(keepingCapacity: true)
        isLayoutActive = false
    }
}

private struct DynamicResolvedLayoutScope: Equatable, Sendable {
    let identity: SemanticRecordReference
    let bounds: Rect
    let clip: Rect
}

private struct DynamicResolvedLayoutLine: Equatable, Sendable {
    let identity: SemanticRecordReference
    let line: ResolvedRenderTextLine
}

private struct DynamicResolvedLayoutGlyph: Equatable, Sendable {
    let identity: SemanticRecordReference
    let glyph: ResolvedRenderGlyph
}

package struct DynamicResolvedLayoutView: ResolvedRenderLayoutView {
    package let rootIdentity: SemanticRecordReference
    package let layoutScopeCount: UInt16
    package let renderSnapshotVersion: UInt32
    package let rootBounds: Rect
    private let scopes: [DynamicResolvedLayoutScope]
    private let lines: [DynamicResolvedLayoutLine]
    private let glyphs: [DynamicResolvedLayoutGlyph]

    fileprivate init(
        rootIdentity: SemanticRecordReference,
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

    package func layoutIdentity(at ordinal: UInt16) -> SemanticRecordReference? {
        guard Int(ordinal) < scopes.count else { return nil }
        return scopes[Int(ordinal)].identity
    }

    package func layoutOrdinal(of identity: SemanticRecordReference) -> UInt16? {
        scopes.firstIndex { $0.identity == identity }.map(UInt16.init)
    }

    package func bounds(of identity: SemanticRecordReference) -> Rect? {
        scopes.first { $0.identity == identity }?.bounds
    }

    package func clip(of identity: SemanticRecordReference) -> Rect? {
        scopes.first { $0.identity == identity }?.clip
    }

    package func textLineCount(of identity: SemanticRecordReference) -> UInt16? {
        guard scopes.contains(where: { $0.identity == identity }) else { return nil }
        return UInt16(lines.lazy.filter { $0.identity == identity }.count)
    }

    package func textLine(
        of identity: SemanticRecordReference,
        at index: UInt16
    ) -> ResolvedRenderTextLine? {
        lines.first {
            $0.identity == identity && $0.line.lineIndex == index
        }?.line
    }

    package func glyph(
        of identity: SemanticRecordReference,
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

    package var reservedPayloadBytes: UInt64 {
        UInt64(
            (candidateScopes.capacity + publishedScopes.capacity)
                * MemoryLayout<DynamicResolvedLayoutScope>.stride)
            + UInt64(
                (candidateLines.capacity + publishedLines.capacity)
                    * MemoryLayout<DynamicResolvedLayoutLine>.stride)
            + UInt64(
                (candidateGlyphs.capacity + publishedGlyphs.capacity)
                    * MemoryLayout<DynamicResolvedLayoutGlyph>.stride)
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
        identity: SemanticRecordReference,
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
        identity: SemanticRecordReference,
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
        identity: SemanticRecordReference,
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
        swap(&publishedScopes, &candidateScopes)
        publishedLines.removeAll(keepingCapacity: true)
        for record in candidateLines {
            publishedLines.append(
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
                ))
        }
        swap(&publishedGlyphs, &candidateGlyphs)
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
