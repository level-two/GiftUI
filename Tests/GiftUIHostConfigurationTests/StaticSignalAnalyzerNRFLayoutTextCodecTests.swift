import GiftUI
import GiftUITextResources
import Testing

@testable import SignalAnalyzerTargetHost

@Test func staticNRFLayoutTextCodecKeepsExactDisjointLineGlyphAndScratchRanges() {
    let codec = StaticSignalAnalyzerNRFLayoutTextCodec.self
    #expect(codec.glyphBaseOffset == 2_048)
    #expect(codec.scratchOffset == 4_288)
    #expect(codec.scratchByteCount == 416)
    var storage = [UInt8](repeating: 0, count: codec.regionByteCount)
    storage.withUnsafeMutableBytes { region in
        let bounds = Rect(
            origin: Point(x: -12, y: 42),
            size: Size(width: 480, height: 16)!
        )!
        let baseline = Point(x: -12, y: 55)
        let glyph = GlyphID(rawValue: 42)
        #expect(
            codec.stageLine(
                identity: 0xBF7C,
                lineIndex: 0,
                bounds: bounds,
                baseline: baseline,
                at: 0,
                in: region
            )
        )
        #expect(
            codec.line(at: 0, in: region)
                == StaticSignalAnalyzerNRFLayoutLineRecord(
                    identity: 0xBF7C,
                    lineIndex: 0,
                    bounds: bounds,
                    baseline: baseline
                )
        )
        #expect(
            codec.stageGlyph(
                identity: 0xBF7C,
                lineIndex: 0,
                glyph: glyph,
                baseline: baseline,
                at: 0,
                in: region
            )
        )
        #expect(
            codec.glyph(at: 0, in: region)
                == StaticSignalAnalyzerNRFLayoutGlyphRecord(
                    identity: 0xBF7C,
                    lineIndex: 0,
                    glyph: glyph,
                    baseline: baseline
                )
        )
        let moved = Point(x: 2, y: 80)
        #expect(
            codec.replaceGlyphBaseline(
                moved,
                identity: 0xBF7C,
                lineIndex: 0,
                glyph: glyph,
                at: 0,
                in: region
            )
        )
        #expect(codec.glyph(at: 0, in: region)?.baseline == moved)
        #expect(
            codec.stageLine(
                identity: 0x1234,
                lineIndex: 95,
                bounds: bounds,
                baseline: baseline,
                at: 127,
                in: region
            )
        )
        #expect(
            codec.stageGlyph(
                identity: 0x1234,
                lineIndex: 95,
                glyph: glyph,
                baseline: baseline,
                at: 223,
                in: region
            )
        )
        #expect(codec.line(at: 127, in: region)?.identity == 0x1234)
        #expect(codec.glyph(at: 223, in: region)?.identity == 0x1234)
        #expect(
            !codec.stageLine(
                identity: 1, lineIndex: 0, bounds: bounds, baseline: baseline,
                at: 128, in: region
            ))
        #expect(
            !codec.stageGlyph(
                identity: 1, lineIndex: 0, glyph: glyph, baseline: baseline,
                at: 224, in: region
            ))
        #expect(region[codec.scratchOffset ..< codec.regionByteCount].allSatisfy { $0 == 0 })
    }
}

@Test func staticNRFLayoutTextCodecRejectsOverflowDuplicateAndWrongRegion() {
    let codec = StaticSignalAnalyzerNRFLayoutTextCodec.self
    var storage = [UInt8](repeating: 0, count: codec.regionByteCount)
    storage.withUnsafeMutableBytes { region in
        let bounds = Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 480, height: 16)!
        )!
        let invalid = Rect(
            origin: Point(x: 32_768, y: 0),
            size: Size(width: 480, height: 16)!
        )!
        let baseline = Point(x: 0, y: 12)
        let glyph = GlyphID(rawValue: 7)
        #expect(
            !codec.stageLine(
                identity: 1, lineIndex: 0, bounds: invalid, baseline: baseline,
                at: 0, in: region
            ))
        #expect(
            codec.stageLine(
                identity: 1, lineIndex: 0, bounds: bounds, baseline: baseline,
                at: 0, in: region
            ))
        #expect(
            !codec.stageLine(
                identity: 1, lineIndex: 0, bounds: bounds, baseline: baseline,
                at: 0, in: region
            ))
        #expect(
            !codec.replaceLine(
                identity: 2, lineIndex: 0, bounds: bounds, baseline: baseline,
                at: 0, in: region
            ))
        #expect(
            !codec.stageGlyph(
                identity: 1, lineIndex: 0, glyph: glyph,
                baseline: Point(x: 32_768, y: 0), at: 0, in: region
            ))
        #expect(
            codec.stageGlyph(
                identity: 1, lineIndex: 0, glyph: glyph,
                baseline: baseline, at: 0, in: region
            ))
        #expect(
            !codec.stageGlyph(
                identity: 1, lineIndex: 0, glyph: glyph,
                baseline: baseline, at: 0, in: region
            ))
        #expect(
            !codec.replaceGlyphBaseline(
                baseline, identity: 1, lineIndex: 0,
                glyph: GlyphID(rawValue: 8), at: 0, in: region
            ))
    }
    var undersized = [UInt8](repeating: 0, count: codec.regionByteCount - 1)
    undersized.withUnsafeMutableBytes { region in
        #expect(codec.line(at: 0, in: region) == nil)
        #expect(codec.glyph(at: 0, in: region) == nil)
    }
}
