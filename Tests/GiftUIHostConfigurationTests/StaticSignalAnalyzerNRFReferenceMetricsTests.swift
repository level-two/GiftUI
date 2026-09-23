import GiftUIReferenceTextResources
import GiftUITextResources
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFReferenceMetricsMatchCanonicalCatalogue() {
    let target = StaticSignalAnalyzerNRFReferenceMetrics.self
    let canonical = GiftUIReferenceTextMetricsView()
    let instance = canonical.instance(at: 0)!
    #expect(target.glyphCount == instance.glyphCount)
    #expect(target.mappingCount == instance.mappingCount)
    #expect(target.ascent == instance.lineMetrics.ascent)
    #expect(target.descent == instance.lineMetrics.descent)
    #expect(target.lineGap == instance.lineMetrics.lineGap)
    #expect(target.replacementGlyph == instance.replacementGlyph.rawValue)

    for index: UInt16 in 0 ..< target.mappingCount {
        let mapping = canonical.mapping(at: index, in: instance.id)!
        #expect(target.glyph(for: mapping.scalarValue) == mapping.glyph.rawValue)
    }
    #expect(target.glyph(for: 0x0A) == nil)
    #expect(target.glyph(for: 0x1F600) == nil)

    for glyph: UInt16 in 0 ..< target.glyphCount {
        let expected = canonical.metrics(for: GlyphID(rawValue: glyph), in: instance.id)!
        let actual = target.metric(for: glyph)!
        #expect(actual.advanceX == expected.advanceX)
        #expect(actual.offsetX == expected.offsetX)
        #expect(actual.offsetY == expected.offsetY)
        #expect(actual.width == expected.inkSize.width)
        #expect(actual.height == expected.inkSize.height)
    }
    #expect(target.metric(for: target.glyphCount) == nil)
}
