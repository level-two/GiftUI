import GiftUI
import GiftUILayout
import GiftUIReferenceTextResources
import GiftUITextResources

/// A synchronous view of the two disjoint, attempt-local profile regions.
/// The owner must finish the profile opportunity before reusing either region.
package struct StaticSignalAnalyzerNRFLayoutWorkspace: LayoutWorkspace {
    package let maximumScopes: UInt16 = 98
    package let maximumDepth: UInt16 = 13
    package let maximumTextScalars: UInt16 = 224
    package let maximumTextLines: UInt16 = 128
    package let maximumPositionedGlyphs: UInt16 = 224
    package private(set) var isLayoutActive = false

    private let scopes: UnsafeMutableRawBufferPointer
    private let text: UnsafeMutableRawBufferPointer
    private let referenceInstance: FontInstanceID
    package private(set) var scopeCount: UInt16 = 0
    package private(set) var textLineCount: UInt16 = 0
    package private(set) var positionedGlyphCount: UInt16 = 0
    private var depth: UInt16 = 0

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
        referenceInstance = instance
    }

    package mutating func acquireLayout() -> Bool {
        guard !isLayoutActive,
            scopeCount == 0, textLineCount == 0, positionedGlyphCount == 0
        else { return false }
        scopes.initializeMemory(as: UInt8.self, repeating: 0)
        text.initializeMemory(as: UInt8.self, repeating: 0)
        isLayoutActive = true
        return true
    }

    package mutating func appendScope(
        identity: borrowing UInt16,
        measurement: LayoutMeasurement
    ) -> Bool {
        guard isLayoutActive, scopeCount < maximumScopes,
            scopeIndex(for: identity) == nil,
            StaticSignalAnalyzerNRFLayoutScopeCodec.stage(
                identity: identity, measurement: measurement,
                at: scopeCount, in: scopes
            )
        else { return false }
        scopeCount += 1
        return true
    }

    package func scopeIdentity(at index: UInt16) -> UInt16? {
        guard isLayoutActive, index < scopeCount else { return nil }
        return StaticSignalAnalyzerNRFLayoutScopeCodec.read(at: index, in: scopes)?.identity
    }

    package func measurement(for identity: borrowing UInt16) -> LayoutMeasurement? {
        guard let index = scopeIndex(for: identity) else { return nil }
        return StaticSignalAnalyzerNRFLayoutScopeCodec.read(at: index, in: scopes)?.measurement
    }

    package mutating func storeMeasurement(
        _ measurement: LayoutMeasurement,
        for identity: borrowing UInt16
    ) -> Bool {
        guard let index = scopeIndex(for: identity) else { return false }
        return StaticSignalAnalyzerNRFLayoutScopeCodec.replaceMeasurement(
            measurement, for: identity, at: index, in: scopes
        )
    }

    package mutating func storePlacement(
        _ placement: LayoutPlacement,
        for identity: borrowing UInt16
    ) -> Bool {
        guard let index = scopeIndex(for: identity) else { return false }
        return StaticSignalAnalyzerNRFLayoutScopeCodec.place(
            placement, for: identity, at: index, in: scopes
        )
    }

    package func placement(for identity: borrowing UInt16) -> LayoutPlacement? {
        guard let index = scopeIndex(for: identity) else { return nil }
        return StaticSignalAnalyzerNRFLayoutScopeCodec.read(at: index, in: scopes)?.placement
    }

    package mutating func appendTextLine(_ line: LayoutTextLine<UInt16>) -> Bool {
        guard isLayoutActive, textLineCount < maximumTextLines,
            scopeIndex(for: line.identity) != nil,
            line.clip == zeroRect,
            StaticSignalAnalyzerNRFLayoutTextCodec.stageLine(
                identity: line.identity, lineIndex: line.lineIndex,
                bounds: line.bounds, baseline: line.baseline,
                at: textLineCount, in: text
            )
        else { return false }
        textLineCount += 1
        return true
    }

    package func textLine(at index: UInt16) -> LayoutTextLine<UInt16>? {
        guard isLayoutActive, index < textLineCount,
            let record = StaticSignalAnalyzerNRFLayoutTextCodec.line(at: index, in: text)
        else { return nil }
        let clip: Rect
        if let placement = placement(for: record.identity) {
            clip = intersection(placement.clip, record.bounds) ?? zeroRect
        } else {
            clip = zeroRect
        }
        return LayoutTextLine(
            identity: record.identity, lineIndex: record.lineIndex,
            bounds: record.bounds, baseline: record.baseline, clip: clip
        )
    }

    package mutating func storeTextLine(
        _ line: LayoutTextLine<UInt16>, at index: UInt16
    ) -> Bool {
        guard isLayoutActive, index < textLineCount,
            let placement = placement(for: line.identity),
            line.clip == (intersection(placement.clip, line.bounds) ?? zeroRect)
        else { return false }
        return StaticSignalAnalyzerNRFLayoutTextCodec.replaceLine(
            identity: line.identity, lineIndex: line.lineIndex,
            bounds: line.bounds, baseline: line.baseline,
            at: index, in: text
        )
    }

    package mutating func appendPositionedGlyph(
        _ glyph: LayoutPositionedGlyph<UInt16>
    ) -> Bool {
        guard isLayoutActive, positionedGlyphCount < maximumPositionedGlyphs,
            scopeIndex(for: glyph.identity) != nil,
            lineRecord(identity: glyph.identity, lineIndex: glyph.lineIndex) != nil,
            glyph.instance == referenceInstance, glyph.clip == zeroRect,
            glyph.glyphIndex
                == nextGlyphIndex(
                    identity: glyph.identity
                ),
            StaticSignalAnalyzerNRFLayoutTextCodec.stageGlyph(
                identity: glyph.identity, lineIndex: glyph.lineIndex,
                glyph: glyph.glyph, baseline: glyph.baseline,
                at: positionedGlyphCount, in: text
            )
        else { return false }
        positionedGlyphCount += 1
        return true
    }

    package func positionedGlyph(at index: UInt16) -> LayoutPositionedGlyph<UInt16>? {
        guard isLayoutActive, index < positionedGlyphCount,
            let record = StaticSignalAnalyzerNRFLayoutTextCodec.glyph(at: index, in: text),
            let line = lineRecord(identity: record.identity, lineIndex: record.lineIndex)
        else { return nil }
        let clip =
            placement(for: record.identity).flatMap {
                intersection($0.clip, line.bounds)
            } ?? zeroRect
        return LayoutPositionedGlyph(
            identity: record.identity, lineIndex: record.lineIndex,
            glyphIndex: glyphIndex(at: index, identity: record.identity),
            instance: referenceInstance, glyph: record.glyph,
            baseline: record.baseline, clip: clip
        )
    }

    package mutating func storePositionedGlyph(
        _ glyph: LayoutPositionedGlyph<UInt16>, at index: UInt16
    ) -> Bool {
        guard isLayoutActive, index < positionedGlyphCount,
            glyph.instance == referenceInstance,
            let old = positionedGlyph(at: index),
            glyph.identity == old.identity, glyph.lineIndex == old.lineIndex,
            glyph.glyphIndex == old.glyphIndex, glyph.glyph == old.glyph,
            glyph.clip == old.clip
        else { return false }
        return StaticSignalAnalyzerNRFLayoutTextCodec.replaceGlyphBaseline(
            glyph.baseline, identity: glyph.identity,
            lineIndex: glyph.lineIndex, glyph: glyph.glyph,
            at: index, in: text
        )
    }

    package mutating func pushScope(_ identity: borrowing UInt16) -> Bool {
        let identity = copy identity
        guard isLayoutActive, depth < maximumDepth,
            scopeIndex(for: identity) != nil
        else { return false }
        let offset = StaticSignalAnalyzerNRFLayoutTextCodec.scratchOffset + Int(depth) * 2
        text[offset] = UInt8(truncatingIfNeeded: identity)
        text[offset + 1] = UInt8(truncatingIfNeeded: identity >> 8)
        depth += 1
        return true
    }

    package mutating func popScope() {
        guard isLayoutActive, depth > 0 else { return }
        depth -= 1
        let offset = StaticSignalAnalyzerNRFLayoutTextCodec.scratchOffset + Int(depth) * 2
        text[offset] = 0
        text[offset + 1] = 0
    }

    package mutating func resetLayout() {
        if text[Self.publishedMarkerOffset] == 1 {
            let stackStart = StaticSignalAnalyzerNRFLayoutTextCodec.scratchOffset
            text[stackStart ..< (stackStart + Int(maximumDepth) * 2)]
                .initializeMemory(as: UInt8.self, repeating: 0)
        } else {
            scopes.initializeMemory(as: UInt8.self, repeating: 0)
            text.initializeMemory(as: UInt8.self, repeating: 0)
        }
        scopeCount = 0
        textLineCount = 0
        positionedGlyphCount = 0
        depth = 0
        isLayoutActive = false
    }

    private func scopeIndex(for identity: UInt16) -> UInt16? {
        guard isLayoutActive, identity != 0 else { return nil }
        var index: UInt16 = 0
        while index < scopeCount {
            if StaticSignalAnalyzerNRFLayoutScopeCodec.read(at: index, in: scopes)?
                .identity == identity
            {
                return index
            }
            index += 1
        }
        return nil
    }

    private func lineRecord(
        identity: UInt16, lineIndex: UInt16
    ) -> StaticSignalAnalyzerNRFLayoutLineRecord? {
        var index: UInt16 = 0
        while index < textLineCount {
            if let record = StaticSignalAnalyzerNRFLayoutTextCodec.line(at: index, in: text),
                record.identity == identity, record.lineIndex == lineIndex
            {
                return record
            }
            index += 1
        }
        return nil
    }

    private func glyphIndex(at ordinal: UInt16, identity: UInt16) -> UInt16 {
        var index: UInt16 = 0
        var result: UInt16 = 0
        while index < ordinal {
            if let record = StaticSignalAnalyzerNRFLayoutTextCodec.glyph(at: index, in: text),
                record.identity == identity
            {
                result += 1
            }
            index += 1
        }
        return result
    }

    private func nextGlyphIndex(identity: UInt16) -> UInt16 {
        glyphIndex(at: positionedGlyphCount, identity: identity)
    }

    private var zeroRect: Rect {
        Rect(origin: Point(x: 0, y: 0), size: Size(width: 0, height: 0)!)!
    }

    package static let publishedMarkerOffset =
        StaticSignalAnalyzerNRFLayoutTextCodec.scratchOffset + 26

    private func intersection(_ a: Rect, _ b: Rect) -> Rect? {
        LayoutGeometry.intersection(a, b)
    }
}
