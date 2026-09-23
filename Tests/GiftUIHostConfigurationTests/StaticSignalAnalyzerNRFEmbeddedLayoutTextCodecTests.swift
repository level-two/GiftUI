import GiftUI
import GiftUILayout
import GiftUITextResources
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFEmbeddedLayoutTextCodecMatchesHostBytes() {
    let target = StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.self
    let host = StaticSignalAnalyzerNRFLayoutTextCodec.self
    var targetBytes = [UInt8](repeating: 0, count: target.regionByteCount)
    var hostBytes = [UInt8](repeating: 0, count: host.regionByteCount)
    targetBytes.withUnsafeMutableBytes { targetRegion in
        hostBytes.withUnsafeMutableBytes { hostRegion in
            let bounds = Rect(
                origin: Point(x: -8, y: 12),
                size: Size(width: 184, height: 16)!
            )!
            let baseline = Point(x: -8, y: 24)
            let line = target.Line(
                identity: 0xBEEF, lineIndex: 2,
                x: -8, y: 12, width: 184, height: 16,
                baselineX: -8, baselineY: 24
            )
            let targetLine = target.stageLine(line, at: 0, in: targetRegion)
            let hostLine = host.stageLine(
                identity: line.identity, lineIndex: line.lineIndex,
                bounds: bounds, baseline: baseline,
                at: 0, in: hostRegion
            )
            #expect(targetLine && hostLine)
            #expect([UInt8](targetRegion) == [UInt8](hostRegion))
            #expect(target.line(at: 0, in: targetRegion) == line)

            let glyph = target.Glyph(
                identity: line.identity, lineIndex: line.lineIndex,
                glyphID: 42, baselineX: -8, baselineY: 24
            )
            let targetGlyph = target.stageGlyph(glyph, at: 0, in: targetRegion)
            let hostGlyph = host.stageGlyph(
                identity: glyph.identity, lineIndex: glyph.lineIndex,
                glyph: GlyphID(rawValue: 42), baseline: baseline,
                at: 0, in: hostRegion
            )
            #expect(targetGlyph && hostGlyph)
            #expect([UInt8](targetRegion) == [UInt8](hostRegion))
            #expect(target.glyph(at: 0, in: targetRegion) == glyph)

            let moved = target.Glyph(
                identity: line.identity, lineIndex: line.lineIndex,
                glyphID: 42, baselineX: 10, baselineY: 25
            )
            let movedTarget = target.replaceGlyphBaseline(
                moved, at: 0, in: targetRegion
            )
            let movedHost = host.replaceGlyphBaseline(
                Point(x: 10, y: 25),
                identity: glyph.identity, lineIndex: glyph.lineIndex,
                glyph: GlyphID(rawValue: 42), at: 0, in: hostRegion
            )
            #expect(movedTarget && movedHost)
            #expect([UInt8](targetRegion) == [UInt8](hostRegion))
            #expect(target.glyph(at: 0, in: targetRegion) == moved)

            let invalid = target.Glyph(
                identity: glyph.identity, lineIndex: glyph.lineIndex,
                glyphID: 43, baselineX: 0, baselineY: 0
            )
            #expect(!target.replaceGlyphBaseline(invalid, at: 0, in: targetRegion))
            #expect(target.line(at: target.maximumLines, in: targetRegion) == nil)
            #expect(target.glyph(at: target.maximumGlyphs, in: targetRegion) == nil)
        }
    }
}
