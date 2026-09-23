/// Target-safe line and glyph records inside the exact render workspace.
package enum StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec {
    package static let regionByteCount = 4_704
    package static let maximumLines: UInt16 = 128
    package static let maximumGlyphs: UInt16 = 224
    package static let glyphBaseOffset = 2_048
    package static let scratchOffset = 4_288

    package struct Line: Equatable {
        package let identity: UInt16
        package let lineIndex: UInt16
        package let x: Int16
        package let y: Int16
        package let width: Int16
        package let height: Int16
        package let baselineX: Int16
        package let baselineY: Int16

        package init(
            identity: UInt16, lineIndex: UInt16,
            x: Int16, y: Int16, width: Int16, height: Int16,
            baselineX: Int16, baselineY: Int16
        ) {
            self.identity = identity
            self.lineIndex = lineIndex
            self.x = x
            self.y = y
            self.width = width
            self.height = height
            self.baselineX = baselineX
            self.baselineY = baselineY
        }
    }

    package struct Glyph: Equatable {
        package let identity: UInt16
        package let lineIndex: UInt16
        package let glyphID: UInt16
        package let baselineX: Int16
        package let baselineY: Int16

        package init(
            identity: UInt16, lineIndex: UInt16,
            glyphID: UInt16, baselineX: Int16, baselineY: Int16
        ) {
            self.identity = identity
            self.lineIndex = lineIndex
            self.glyphID = glyphID
            self.baselineX = baselineX
            self.baselineY = baselineY
        }
    }

    package static func stageLine(
        _ line: Line, at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let offset = lineOffset(ordinal, in: region),
            line.identity != 0,
            line.width >= 0, line.height >= 0,
            region[offset ..< offset + 16].allSatisfy({ $0 == 0 })
        else { return false }
        write(line.identity, at: offset, in: region)
        write(line.lineIndex, at: offset + 2, in: region)
        write(UInt16(bitPattern: line.x), at: offset + 4, in: region)
        write(UInt16(bitPattern: line.y), at: offset + 6, in: region)
        write(UInt16(bitPattern: line.width), at: offset + 8, in: region)
        write(UInt16(bitPattern: line.height), at: offset + 10, in: region)
        write(UInt16(bitPattern: line.baselineX), at: offset + 12, in: region)
        write(UInt16(bitPattern: line.baselineY), at: offset + 14, in: region)
        return true
    }

    package static func replaceLine(
        _ line: Line, at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let offset = lineOffset(ordinal, in: region),
            word(at: offset, in: region) == line.identity,
            word(at: offset + 2, in: region) == line.lineIndex,
            line.identity != 0, line.width >= 0, line.height >= 0
        else { return false }
        write(UInt16(bitPattern: line.x), at: offset + 4, in: region)
        write(UInt16(bitPattern: line.y), at: offset + 6, in: region)
        write(UInt16(bitPattern: line.width), at: offset + 8, in: region)
        write(UInt16(bitPattern: line.height), at: offset + 10, in: region)
        write(UInt16(bitPattern: line.baselineX), at: offset + 12, in: region)
        write(UInt16(bitPattern: line.baselineY), at: offset + 14, in: region)
        return true
    }

    package static func line(
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Line? {
        guard let offset = lineOffset(ordinal, in: region),
            let identity = word(at: offset, in: region), identity != 0,
            let lineIndex = word(at: offset + 2, in: region),
            let x = signed(at: offset + 4, in: region),
            let y = signed(at: offset + 6, in: region),
            let width = signed(at: offset + 8, in: region), width >= 0,
            let height = signed(at: offset + 10, in: region), height >= 0,
            let baselineX = signed(at: offset + 12, in: region),
            let baselineY = signed(at: offset + 14, in: region)
        else { return nil }
        return Line(
            identity: identity, lineIndex: lineIndex,
            x: x, y: y, width: width, height: height,
            baselineX: baselineX, baselineY: baselineY
        )
    }

    package static func stageGlyph(
        _ glyph: Glyph, at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let offset = glyphOffset(ordinal, in: region),
            glyph.identity != 0,
            region[offset ..< offset + 10].allSatisfy({ $0 == 0 })
        else { return false }
        write(glyph.identity, at: offset, in: region)
        write(glyph.lineIndex, at: offset + 2, in: region)
        write(glyph.glyphID, at: offset + 4, in: region)
        write(UInt16(bitPattern: glyph.baselineX), at: offset + 6, in: region)
        write(UInt16(bitPattern: glyph.baselineY), at: offset + 8, in: region)
        return true
    }

    package static func replaceGlyphBaseline(
        _ glyph: Glyph, at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let offset = glyphOffset(ordinal, in: region),
            word(at: offset, in: region) == glyph.identity,
            word(at: offset + 2, in: region) == glyph.lineIndex,
            word(at: offset + 4, in: region) == glyph.glyphID,
            glyph.identity != 0
        else { return false }
        write(UInt16(bitPattern: glyph.baselineX), at: offset + 6, in: region)
        write(UInt16(bitPattern: glyph.baselineY), at: offset + 8, in: region)
        return true
    }

    package static func glyph(
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Glyph? {
        guard let offset = glyphOffset(ordinal, in: region),
            let identity = word(at: offset, in: region), identity != 0,
            let lineIndex = word(at: offset + 2, in: region),
            let glyphID = word(at: offset + 4, in: region),
            let x = signed(at: offset + 6, in: region),
            let y = signed(at: offset + 8, in: region)
        else { return nil }
        return Glyph(
            identity: identity, lineIndex: lineIndex,
            glyphID: glyphID, baselineX: x, baselineY: y
        )
    }

    private static func lineOffset(
        _ ordinal: UInt16, in region: UnsafeMutableRawBufferPointer
    ) -> Int? {
        guard region.count == regionByteCount, ordinal < maximumLines else { return nil }
        return Int(ordinal) * 16
    }

    private static func glyphOffset(
        _ ordinal: UInt16, in region: UnsafeMutableRawBufferPointer
    ) -> Int? {
        guard region.count == regionByteCount, ordinal < maximumGlyphs else { return nil }
        return glyphBaseOffset + Int(ordinal) * 10
    }

    private static func word(
        at offset: Int, in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        guard offset >= 0 && offset + 1 < region.count else { return nil }
        return UInt16(region[offset]) | UInt16(region[offset + 1]) << 8
    }

    private static func signed(
        at offset: Int, in region: UnsafeMutableRawBufferPointer
    ) -> Int16? {
        word(at: offset, in: region).map { Int16(bitPattern: $0) }
    }

    private static func write(
        _ value: UInt16, at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) {
        region[offset] = UInt8(truncatingIfNeeded: value)
        region[offset + 1] = UInt8(truncatingIfNeeded: value >> 8)
    }
}
