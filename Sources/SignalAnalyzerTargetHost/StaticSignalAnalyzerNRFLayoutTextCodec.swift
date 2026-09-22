import GiftUI
import GiftUILayout
import GiftUITextResources

package struct StaticSignalAnalyzerNRFLayoutLineRecord: Equatable {
    package let identity: UInt16
    package let lineIndex: UInt16
    package let bounds: Rect
    package let baseline: Point
}

package struct StaticSignalAnalyzerNRFLayoutGlyphRecord: Equatable {
    package let identity: UInt16
    package let lineIndex: UInt16
    package let glyph: GlyphID
    package let baseline: Point
}

/// Compact in-place line/glyph records in the audited 4,704-byte render region.
/// The caller owns counts, font-instance validation, and derived clips/indexes.
package enum StaticSignalAnalyzerNRFLayoutTextCodec {
    package static let maximumLines = 128
    package static let maximumGlyphs = 224
    package static let lineByteCount = 16
    package static let glyphByteCount = 10
    package static let glyphBaseOffset = maximumLines * lineByteCount
    package static let scratchOffset = glyphBaseOffset + maximumGlyphs * glyphByteCount
    package static let regionByteCount = 4_704
    package static let scratchByteCount = regionByteCount - scratchOffset

    package static func stageLine(
        identity: UInt16,
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let offset = lineOffset(at: ordinal, in: region),
            identity != 0,
            region[offset ..< (offset + lineByteCount)].allSatisfy({ $0 == 0 }),
            let values = packedLine(bounds: bounds, baseline: baseline)
        else { return false }
        write(identity, at: offset, in: region)
        write(lineIndex, at: offset + 2, in: region)
        writeLine(values, at: offset, in: region)
        return true
    }

    package static func replaceLine(
        identity: UInt16,
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let offset = lineOffset(at: ordinal, in: region),
            word(at: offset, in: region) == identity,
            word(at: offset + 2, in: region) == lineIndex,
            identity != 0,
            let values = packedLine(bounds: bounds, baseline: baseline)
        else { return false }
        writeLine(values, at: offset, in: region)
        return true
    }

    package static func line(
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFLayoutLineRecord? {
        guard let offset = lineOffset(at: ordinal, in: region),
            let identity = word(at: offset, in: region), identity != 0,
            let lineIndex = word(at: offset + 2, in: region),
            let x = signed(at: offset + 4, in: region),
            let y = signed(at: offset + 6, in: region),
            let width = signed(at: offset + 8, in: region),
            let height = signed(at: offset + 10, in: region),
            let baselineX = signed(at: offset + 12, in: region),
            let baselineY = signed(at: offset + 14, in: region),
            let size = Size(width: width, height: height),
            let bounds = Rect(origin: Point(x: x, y: y), size: size)
        else { return nil }
        return StaticSignalAnalyzerNRFLayoutLineRecord(
            identity: identity,
            lineIndex: lineIndex,
            bounds: bounds,
            baseline: Point(x: baselineX, y: baselineY)
        )
    }

    package static func stageGlyph(
        identity: UInt16,
        lineIndex: UInt16,
        glyph: GlyphID,
        baseline: Point,
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let offset = glyphRecordOffset(at: ordinal, in: region),
            identity != 0,
            region[offset ..< (offset + glyphByteCount)].allSatisfy({ $0 == 0 }),
            let x = packed(baseline.x),
            let y = packed(baseline.y)
        else { return false }
        write(identity, at: offset, in: region)
        write(lineIndex, at: offset + 2, in: region)
        write(glyph.rawValue, at: offset + 4, in: region)
        write(x, at: offset + 6, in: region)
        write(y, at: offset + 8, in: region)
        return true
    }

    package static func replaceGlyphBaseline(
        _ baseline: Point,
        identity: UInt16,
        lineIndex: UInt16,
        glyph: GlyphID,
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let offset = glyphRecordOffset(at: ordinal, in: region),
            word(at: offset, in: region) == identity,
            word(at: offset + 2, in: region) == lineIndex,
            word(at: offset + 4, in: region) == glyph.rawValue,
            identity != 0,
            let x = packed(baseline.x),
            let y = packed(baseline.y)
        else { return false }
        write(x, at: offset + 6, in: region)
        write(y, at: offset + 8, in: region)
        return true
    }

    package static func glyph(
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFLayoutGlyphRecord? {
        guard let offset = glyphRecordOffset(at: ordinal, in: region),
            let identity = word(at: offset, in: region), identity != 0,
            let lineIndex = word(at: offset + 2, in: region),
            let glyphID = word(at: offset + 4, in: region),
            let x = signed(at: offset + 6, in: region),
            let y = signed(at: offset + 8, in: region)
        else { return nil }
        return StaticSignalAnalyzerNRFLayoutGlyphRecord(
            identity: identity,
            lineIndex: lineIndex,
            glyph: GlyphID(rawValue: glyphID),
            baseline: Point(x: x, y: y)
        )
    }

    private struct PackedLine {
        let x: UInt16
        let y: UInt16
        let width: UInt16
        let height: UInt16
        let baselineX: UInt16
        let baselineY: UInt16
    }

    private static func packedLine(
        bounds: Rect,
        baseline: Point
    ) -> PackedLine? {
        guard let x = packed(bounds.origin.x),
            let y = packed(bounds.origin.y),
            let width = packed(bounds.size.width),
            let height = packed(bounds.size.height),
            let baselineX = packed(baseline.x),
            let baselineY = packed(baseline.y)
        else { return nil }
        return PackedLine(
            x: x,
            y: y,
            width: width,
            height: height,
            baselineX: baselineX,
            baselineY: baselineY
        )
    }

    private static func writeLine(
        _ values: PackedLine,
        at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) {
        write(values.x, at: offset + 4, in: region)
        write(values.y, at: offset + 6, in: region)
        write(values.width, at: offset + 8, in: region)
        write(values.height, at: offset + 10, in: region)
        write(values.baselineX, at: offset + 12, in: region)
        write(values.baselineY, at: offset + 14, in: region)
    }

    private static func lineOffset(
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Int? {
        guard region.count == regionByteCount, Int(ordinal) < maximumLines else {
            return nil
        }
        return Int(ordinal) * lineByteCount
    }

    private static func glyphRecordOffset(
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Int? {
        guard region.count == regionByteCount, Int(ordinal) < maximumGlyphs else {
            return nil
        }
        return glyphBaseOffset + Int(ordinal) * glyphByteCount
    }

    private static func packed(_ value: GeometryScalar) -> UInt16? {
        Int16(exactly: value).map { UInt16(bitPattern: $0) }
    }

    private static func word(
        at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        guard offset >= 0, offset + 1 < region.count else { return nil }
        return UInt16(region[offset]) | (UInt16(region[offset + 1]) << 8)
    }

    private static func signed(
        at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) -> GeometryScalar? {
        word(at: offset, in: region).map { GeometryScalar(Int16(bitPattern: $0)) }
    }

    private static func write(
        _ value: UInt16,
        at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) {
        region[offset] = UInt8(truncatingIfNeeded: value)
        region[offset + 1] = UInt8(truncatingIfNeeded: value >> 8)
    }
}
