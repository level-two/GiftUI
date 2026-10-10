import GiftUI
import GiftUILayout
import GiftUISemanticCore
import GiftUITextResources

package struct StaticTextMetricsView: CanonicalTextMetricsView {
    package init() {}

    package var descriptor: TextResourceDescriptor {
        TextResourceDescriptor(
            schemaVersion: 1,
            resource: resource,
            instanceCount: 1,
            realizationCount: 1,
            canonicalManifestByteCount: 1
        )
    }

    package func instance(at index: UInt16) -> FontInstanceDescriptor? {
        guard index == 0 else { return nil }
        return FontInstanceDescriptor(
            id: FontInstanceID(resource: resource, instanceIndex: 0),
            lineMetrics: FontLineMetrics(ascent: 1, descent: 0, lineGap: 0),
            replacementGlyph: GlyphID(rawValue: 0),
            glyphCount: 1,
            mappingCount: 0
        )
    }

    package func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? { nil }

    package func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? { nil }

    private var resource: FontResourceID {
        FontResourceID(
            rawValue: TextResourceDigest(
                word0: 0,
                word1: 0,
                word2: 0,
                word3: 0,
                word4: 0,
                word5: 0,
                word6: 0,
                word7: 7
            )
        )
    }
}

package struct BankLayoutWorkspace: LayoutWorkspace {
    package let maximumScopes: UInt16 = 98
    package let maximumDepth: UInt16 = 13
    package let maximumTextScalars: UInt16 = 224
    package let maximumTextLines: UInt16 = 98
    package let maximumPositionedGlyphs: UInt16 = 224
    package var isLayoutActive = false
    private var identities = InlineArray<98, SemanticRecordReference?>(repeating: nil)
    private var measurements = InlineArray<98, LayoutMeasurement?>(repeating: nil)
    private var placements = InlineArray<98, LayoutPlacement?>(repeating: nil)
    private var storedScopeCount: UInt16 = 0
    private var lines = InlineArray<98, LayoutTextLine<SemanticRecordReference>?>(repeating: nil)
    private var storedLineCount: UInt16 = 0
    private var glyphs = InlineArray<224, LayoutPositionedGlyph<SemanticRecordReference>?>(repeating: nil)
    private var storedGlyphCount: UInt16 = 0
    private var depth = InlineArray<13, SemanticRecordReference?>(repeating: nil)
    private var storedDepth: UInt16 = 0

    package init() {}

    package mutating func acquireLayout() -> Bool {
        guard !isLayoutActive else { return false }
        isLayoutActive = true
        return true
    }

    package mutating func appendScope(
        identity: borrowing SemanticRecordReference,
        measurement: LayoutMeasurement
    ) -> Bool {
        let value = copy identity
        guard isLayoutActive, storedScopeCount < maximumScopes,
            findScope(value) == nil
        else { return false }
        let index = Int(storedScopeCount)
        identities[index] = value
        measurements[index] = measurement
        placements[index] = nil
        storedScopeCount += 1
        return true
    }

    package var scopeCount: UInt16 { storedScopeCount }
    package func scopeIdentity(at index: UInt16) -> SemanticRecordReference? {
        guard index < storedScopeCount else { return nil }
        return identities[Int(index)]
    }
    package func measurement(for identity: borrowing SemanticRecordReference) -> LayoutMeasurement? {
        findScope(copy identity).flatMap { measurements[$0] }
    }
    package mutating func storeMeasurement(
        _ measurement: LayoutMeasurement,
        for identity: borrowing SemanticRecordReference
    ) -> Bool {
        guard let index = findScope(copy identity) else { return false }
        measurements[index] = measurement
        return true
    }
    package mutating func storePlacement(
        _ placement: LayoutPlacement,
        for identity: borrowing SemanticRecordReference
    ) -> Bool {
        guard let index = findScope(copy identity), placements[index] == nil else {
            return false
        }
        placements[index] = placement
        return true
    }
    package func placement(for identity: borrowing SemanticRecordReference) -> LayoutPlacement? {
        findScope(copy identity).flatMap { placements[$0] }
    }
    package var textLineCount: UInt16 { storedLineCount }
    package mutating func appendTextLine(_ line: LayoutTextLine<SemanticRecordReference>) -> Bool {
        guard storedLineCount < maximumTextLines else { return false }
        lines[Int(storedLineCount)] = line
        storedLineCount += 1
        return true
    }
    package func textLine(at index: UInt16) -> LayoutTextLine<SemanticRecordReference>? {
        guard index < storedLineCount else { return nil }
        return lines[Int(index)]
    }
    package mutating func storeTextLine(
        _ line: LayoutTextLine<SemanticRecordReference>,
        at index: UInt16
    ) -> Bool {
        guard index < storedLineCount else { return false }
        lines[Int(index)] = line
        return true
    }
    package var positionedGlyphCount: UInt16 { storedGlyphCount }
    package mutating func appendPositionedGlyph(
        _ glyph: LayoutPositionedGlyph<SemanticRecordReference>
    ) -> Bool {
        guard storedGlyphCount < maximumPositionedGlyphs else { return false }
        glyphs[Int(storedGlyphCount)] = glyph
        storedGlyphCount += 1
        return true
    }
    package func positionedGlyph(
        at index: UInt16
    ) -> LayoutPositionedGlyph<SemanticRecordReference>? {
        guard index < storedGlyphCount else { return nil }
        return glyphs[Int(index)]
    }
    package mutating func storePositionedGlyph(
        _ glyph: LayoutPositionedGlyph<SemanticRecordReference>,
        at index: UInt16
    ) -> Bool {
        guard index < storedGlyphCount else { return false }
        glyphs[Int(index)] = glyph
        return true
    }
    package mutating func pushScope(_ identity: borrowing SemanticRecordReference) -> Bool {
        guard storedDepth < maximumDepth else { return false }
        depth[Int(storedDepth)] = copy identity
        storedDepth += 1
        return true
    }
    package mutating func popScope() {
        guard storedDepth > 0 else { return }
        storedDepth -= 1
        depth[Int(storedDepth)] = nil
    }
    package mutating func resetLayout() {
        var scopeIndex: UInt16 = 0
        while scopeIndex < storedScopeCount {
            identities[Int(scopeIndex)] = nil
            measurements[Int(scopeIndex)] = nil
            placements[Int(scopeIndex)] = nil
            scopeIndex += 1
        }
        var lineIndex: UInt16 = 0
        while lineIndex < storedLineCount {
            lines[Int(lineIndex)] = nil
            lineIndex += 1
        }
        var glyphIndex: UInt16 = 0
        while glyphIndex < storedGlyphCount {
            glyphs[Int(glyphIndex)] = nil
            glyphIndex += 1
        }
        while storedDepth > 0 { popScope() }
        storedScopeCount = 0
        storedLineCount = 0
        storedGlyphCount = 0
        isLayoutActive = false
    }

    private func findScope(_ identity: SemanticRecordReference) -> Int? {
        var index: UInt16 = 0
        while index < storedScopeCount {
            if identities[Int(index)] == identity { return Int(index) }
            index += 1
        }
        return nil
    }
}

