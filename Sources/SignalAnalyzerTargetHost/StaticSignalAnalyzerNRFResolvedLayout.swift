import GiftUI
import GiftUILayout
import GiftUIReferenceTextResources
import GiftUISemanticCore
import GiftUITextResources

/// Reads a published layout only while its enclosing Static opportunity lives.
package struct StaticSignalAnalyzerNRFResolvedLayoutView: ResolvedRenderLayoutView {
    package let rootIdentity: UInt16
    package let layoutScopeCount: UInt16
    package let renderSnapshotVersion: UInt32
    package let rootBounds: Rect
    private let scopes: UnsafeMutableRawBufferPointer
    private let text: UnsafeMutableRawBufferPointer
    private let lineCount: UInt16
    private let glyphCount: UInt16
    private let instance: FontInstanceID

    fileprivate init(
        summary: LayoutSummary, version: UInt32,
        scopes: UnsafeMutableRawBufferPointer,
        text: UnsafeMutableRawBufferPointer,
        lineCount: UInt16, glyphCount: UInt16,
        instance: FontInstanceID
    ) {
        rootIdentity = StaticSignalAnalyzerNRFLayoutScopeCodec.read(at: 0, in: scopes)!.identity
        layoutScopeCount = summary.scopeCount
        renderSnapshotVersion = version
        rootBounds = summary.rootBounds
        self.scopes = scopes
        self.text = text
        self.lineCount = lineCount
        self.glyphCount = glyphCount
        self.instance = instance
    }

    package func layoutIdentity(at ordinal: UInt16) -> UInt16? {
        guard isPublished, ordinal < layoutScopeCount else { return nil }
        return StaticSignalAnalyzerNRFLayoutScopeCodec.read(at: ordinal, in: scopes)?.identity
    }

    package func layoutOrdinal(of identity: UInt16) -> UInt16? {
        guard isPublished else { return nil }
        var ordinal: UInt16 = 0
        while ordinal < layoutScopeCount {
            if layoutIdentity(at: ordinal) == identity { return ordinal }
            ordinal += 1
        }
        return nil
    }

    package func bounds(of identity: UInt16) -> Rect? {
        guard let ordinal = layoutOrdinal(of: identity) else { return nil }
        return StaticSignalAnalyzerNRFLayoutScopeCodec.read(at: ordinal, in: scopes)?
            .placement?.bounds
    }

    package func clip(of identity: UInt16) -> Rect? {
        guard let ordinal = layoutOrdinal(of: identity) else { return nil }
        return StaticSignalAnalyzerNRFLayoutScopeCodec.read(at: ordinal, in: scopes)?
            .placement?.clip
    }

    package func textLineCount(of identity: UInt16) -> UInt16? {
        guard layoutOrdinal(of: identity) != nil else { return nil }
        var ordinal: UInt16 = 0
        var count: UInt16 = 0
        while ordinal < lineCount {
            if StaticSignalAnalyzerNRFLayoutTextCodec.line(at: ordinal, in: text)?
                .identity == identity
            {
                count += 1
            }
            ordinal += 1
        }
        return count
    }

    package func textLine(of identity: UInt16, at index: UInt16) -> ResolvedRenderTextLine? {
        guard let scopeClip = clip(of: identity) else { return nil }
        var ordinal: UInt16 = 0
        while ordinal < lineCount {
            if let record = StaticSignalAnalyzerNRFLayoutTextCodec.line(at: ordinal, in: text),
                record.identity == identity, record.lineIndex == index
            {
                var count: UInt16 = 0
                var glyphOrdinal: UInt16 = 0
                while glyphOrdinal < glyphCount {
                    if let glyph = StaticSignalAnalyzerNRFLayoutTextCodec.glyph(
                        at: glyphOrdinal, in: text
                    ), glyph.identity == identity, glyph.lineIndex == index {
                        count += 1
                    }
                    glyphOrdinal += 1
                }
                return ResolvedRenderTextLine(
                    lineIndex: index, bounds: record.bounds, baseline: record.baseline,
                    clip: LayoutGeometry.intersection(scopeClip, record.bounds)!,
                    glyphCount: count
                )
            }
            ordinal += 1
        }
        return nil
    }

    package func glyph(of identity: UInt16, at index: UInt16) -> ResolvedRenderGlyph? {
        guard clip(of: identity) != nil else { return nil }
        var ordinal: UInt16 = 0
        var localIndex: UInt16 = 0
        while ordinal < glyphCount {
            if let record = StaticSignalAnalyzerNRFLayoutTextCodec.glyph(at: ordinal, in: text),
                record.identity == identity
            {
                if localIndex == index,
                    let line = textLine(of: identity, at: record.lineIndex)
                {
                    return ResolvedRenderGlyph(
                        lineIndex: record.lineIndex, glyphIndex: index,
                        instance: instance, glyph: record.glyph,
                        baseline: record.baseline, clip: line.clip
                    )
                }
                localIndex += 1
            }
            ordinal += 1
        }
        return nil
    }

    private var isPublished: Bool {
        text[StaticSignalAnalyzerNRFLayoutWorkspace.publishedMarkerOffset] == 1
    }
}

/// Validates publication against records already written by the workspace.
/// It owns no second scope, line, or glyph array.
package struct StaticSignalAnalyzerNRFResolvedLayoutStorage:
    ResolvedRenderLayoutResultStorage
{
    package private(set) var isLayoutActive = false
    package private(set) var hasPublishedResult = false
    private let scopes: UnsafeMutableRawBufferPointer
    private let text: UnsafeMutableRawBufferPointer
    private let instance: FontInstanceID
    private var summary: LayoutSummary?
    private var version: UInt32 = 0
    private var scopeCount: UInt16 = 0
    private var lineCount: UInt16 = 0
    private var glyphCount: UInt16 = 0

    package init?(
        scopes: UnsafeMutableRawBufferPointer,
        text: UnsafeMutableRawBufferPointer
    ) {
        guard scopes.count == StaticSignalAnalyzerNRFLayoutScopeCodec.regionByteCount,
            text.count == StaticSignalAnalyzerNRFLayoutTextCodec.regionByteCount,
            let instance = GiftUIReferenceTextMetricsView().instance(at: 0)?.id
        else { return nil }
        self.scopes = scopes
        self.text = text
        self.instance = instance
    }

    package var renderView: StaticSignalAnalyzerNRFResolvedLayoutView {
        precondition(hasPublishedResult && isPublished)
        return StaticSignalAnalyzerNRFResolvedLayoutView(
            summary: summary!, version: version, scopes: scopes, text: text,
            lineCount: lineCount, glyphCount: glyphCount, instance: instance
        )
    }

    package mutating func begin(summary: LayoutSummary) -> Bool {
        guard !isLayoutActive, !hasPublishedResult,
            summary.scopeCount > 0, summary.scopeCount <= 98,
            summary.textScalarCount <= 224, summary.textLineCount <= 128,
            summary.positionedGlyphCount <= 224,
            summary.maximumObservedDepth <= 13,
            text[StaticSignalAnalyzerNRFLayoutWorkspace.publishedMarkerOffset] == 0
        else { return false }
        self.summary = summary
        isLayoutActive = true
        return true
    }

    package mutating func stageScope(identity: UInt16, bounds: Rect, clip: Rect) -> Bool {
        guard isLayoutActive, let summary, scopeCount < summary.scopeCount,
            let record = StaticSignalAnalyzerNRFLayoutScopeCodec.read(
                at: scopeCount, in: scopes
            ), record.identity == identity,
            record.placement == LayoutPlacement(bounds: bounds, clip: clip)
        else { return false }
        scopeCount += 1
        return true
    }

    package mutating func stageTextLine(
        identity: UInt16, lineIndex: UInt16, bounds: Rect,
        baseline: Point, clip: Rect
    ) -> Bool {
        guard isLayoutActive, let summary, lineCount < summary.textLineCount,
            let record = StaticSignalAnalyzerNRFLayoutTextCodec.line(at: lineCount, in: text),
            record.identity == identity, record.lineIndex == lineIndex,
            record.bounds == bounds, record.baseline == baseline,
            let scopeClip = scopeClip(of: identity),
            clip == LayoutGeometry.intersection(scopeClip, bounds)
        else { return false }
        lineCount += 1
        return true
    }

    package mutating func stageGlyph(
        identity: UInt16, lineIndex: UInt16, glyphIndex: UInt16,
        instance: FontInstanceID, glyph: GlyphID,
        baseline: Point, clip: Rect
    ) -> Bool {
        guard isLayoutActive, let summary, glyphCount < summary.positionedGlyphCount,
            let record = StaticSignalAnalyzerNRFLayoutTextCodec.glyph(at: glyphCount, in: text),
            record.identity == identity, record.lineIndex == lineIndex,
            record.glyph == glyph, record.baseline == baseline,
            instance == self.instance,
            glyphIndex == precedingGlyphCount(of: identity),
            let line = matchingLine(identity: identity, lineIndex: lineIndex),
            let scopeClip = scopeClip(of: identity),
            clip == LayoutGeometry.intersection(scopeClip, line.bounds)
        else { return false }
        glyphCount += 1
        return true
    }

    package mutating func publish() -> Bool {
        guard isLayoutActive, let summary,
            scopeCount == summary.scopeCount,
            lineCount == summary.textLineCount,
            glyphCount == summary.positionedGlyphCount,
            StaticSignalAnalyzerNRFLayoutScopeCodec.read(at: 0, in: scopes)?
                .placement?.bounds == summary.rootBounds
        else { return false }
        let next = version.addingReportingOverflow(1)
        guard !next.overflow, next.partialValue != 0 else { return false }
        version = next.partialValue
        text[StaticSignalAnalyzerNRFLayoutWorkspace.publishedMarkerOffset] = 1
        hasPublishedResult = true
        isLayoutActive = false
        return true
    }

    package mutating func discard() {
        text[StaticSignalAnalyzerNRFLayoutWorkspace.publishedMarkerOffset] = 0
        summary = nil
        scopeCount = 0
        lineCount = 0
        glyphCount = 0
        isLayoutActive = false
        hasPublishedResult = false
    }

    private var isPublished: Bool {
        text[StaticSignalAnalyzerNRFLayoutWorkspace.publishedMarkerOffset] == 1
    }

    private func scopeClip(of identity: UInt16) -> Rect? {
        var ordinal: UInt16 = 0
        while ordinal < scopeCount {
            if let record = StaticSignalAnalyzerNRFLayoutScopeCodec.read(
                at: ordinal, in: scopes
            ), record.identity == identity {
                return record.placement?.clip
            }
            ordinal += 1
        }
        return nil
    }

    private func matchingLine(
        identity: UInt16, lineIndex: UInt16
    ) -> StaticSignalAnalyzerNRFLayoutLineRecord? {
        var ordinal: UInt16 = 0
        while ordinal < lineCount {
            if let record = StaticSignalAnalyzerNRFLayoutTextCodec.line(at: ordinal, in: text),
                record.identity == identity, record.lineIndex == lineIndex
            {
                return record
            }
            ordinal += 1
        }
        return nil
    }

    private func precedingGlyphCount(of identity: UInt16) -> UInt16 {
        var ordinal: UInt16 = 0
        var count: UInt16 = 0
        while ordinal < glyphCount {
            if StaticSignalAnalyzerNRFLayoutTextCodec.glyph(at: ordinal, in: text)?
                .identity == identity
            {
                count += 1
            }
            ordinal += 1
        }
        return count
    }
}
