import GiftUIRasterCore

/// Borrows the caller's one 480 x 4 RGB565 raster region for the complete
/// synchronous raster session. A separate 240-byte coverage map tracks which
/// of its 1,920 pixels were written, without a second raster buffer.
package struct StaticSignalAnalyzerNRFTileStorage: RGB565TileStorage {
    package static let requiredByteCount = 3_840
    package static let requiredCoverageByteCount = 240
    private static let maximumPixels: UInt32 = 1_920

    private let region: UnsafeMutableRawBufferPointer
    private let coverage: UnsafeMutableRawBufferPointer

    package init?(
        region: UnsafeMutableRawBufferPointer,
        coverage: UnsafeMutableRawBufferPointer
    ) {
        guard region.count == Self.requiredByteCount,
            let rasterAddress = region.baseAddress,
            coverage.count == Self.requiredCoverageByteCount,
            let coverageAddress = coverage.baseAddress
        else { return nil }
        let rasterStart = UInt(bitPattern: rasterAddress)
        let coverageStart = UInt(bitPattern: coverageAddress)
        guard rasterStart <= UInt.max - UInt(region.count),
            coverageStart <= UInt.max - UInt(coverage.count)
        else { return nil }
        let rasterEnd = rasterStart + UInt(region.count)
        let coverageEnd = coverageStart + UInt(coverage.count)
        guard rasterEnd <= coverageStart || coverageEnd <= rasterStart else {
            return nil
        }
        self.region = region
        self.coverage = coverage
    }

    package var byteCapacity: UInt32 { UInt32(Self.requiredByteCount) }
    package var pixelCapacity: UInt32 { Self.maximumPixels }

    package mutating func reset(byteCount: UInt32, pixelCount: UInt32) -> Bool {
        guard byteCount <= byteCapacity, pixelCount <= pixelCapacity else {
            return false
        }
        region[0 ..< Int(byteCount)].initializeMemory(as: UInt8.self, repeating: 0)
        coverage.initializeMemory(as: UInt8.self, repeating: 0)
        return true
    }

    package mutating func store(
        mostSignificantByte: UInt8,
        leastSignificantByte: UInt8,
        byteOffset: UInt32,
        pixelIndex: UInt32
    ) -> Bool {
        guard byteOffset < byteCapacity,
            byteCapacity - byteOffset >= 2,
            pixelIndex < pixelCapacity
        else { return false }
        region[Int(byteOffset)] = mostSignificantByte
        region[Int(byteOffset) + 1] = leastSignificantByte
        let byteIndex = Int(pixelIndex / 8)
        coverage[byteIndex] |= UInt8(1) << UInt8(pixelIndex % 8)
        return true
    }

    package borrowing func isAffected(pixelIndex: UInt32) -> Bool {
        guard pixelIndex < pixelCapacity else { return false }
        let byteIndex = Int(pixelIndex / 8)
        return coverage[byteIndex] & (UInt8(1) << UInt8(pixelIndex % 8)) != 0
    }

    package borrowing func byte(at offset: UInt32) -> UInt8? {
        offset < byteCapacity ? region[Int(offset)] : nil
    }
}
