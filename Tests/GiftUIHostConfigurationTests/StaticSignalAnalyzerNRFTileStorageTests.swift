import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFTileStorageUsesExactBorrowedRegionAndBoundedCoverage() {
    let pointer = UnsafeMutableRawPointer.allocate(
        byteCount: StaticSignalAnalyzerNRFTileStorage.requiredByteCount,
        alignment: 8
    )
    defer { pointer.deallocate() }
    let region = UnsafeMutableRawBufferPointer(
        start: pointer,
        count: StaticSignalAnalyzerNRFTileStorage.requiredByteCount
    )
    let coveragePointer = UnsafeMutableRawPointer.allocate(
        byteCount: StaticSignalAnalyzerNRFTileStorage.requiredCoverageByteCount,
        alignment: 8
    )
    defer { coveragePointer.deallocate() }
    let coverage = UnsafeMutableRawBufferPointer(
        start: coveragePointer,
        count: StaticSignalAnalyzerNRFTileStorage.requiredCoverageByteCount
    )
    #expect(
        StaticSignalAnalyzerNRFTileStorage(
            region: UnsafeMutableRawBufferPointer(rebasing: region[0 ..< 3_839]),
            coverage: coverage
        ) == nil)
    #expect(
        StaticSignalAnalyzerNRFTileStorage(
            region: region,
            coverage: UnsafeMutableRawBufferPointer(rebasing: coverage[0 ..< 239])
        ) == nil)
    #expect(
        StaticSignalAnalyzerNRFTileStorage(
            region: region,
            coverage: UnsafeMutableRawBufferPointer(rebasing: region[0 ..< 240])
        ) == nil)
    guard
        var storage = StaticSignalAnalyzerNRFTileStorage(
            region: region, coverage: coverage
        )
    else {
        Issue.record("Exact Static tile storage did not construct")
        return
    }
    #expect(storage.byteCapacity == 3_840)
    #expect(storage.pixelCapacity == 1_920)
    let oversizedReset = storage.reset(byteCount: 3_841, pixelCount: 1_920)
    #expect(!oversizedReset)
    let initialReset = storage.reset(byteCount: 3_840, pixelCount: 1_920)
    #expect(initialReset)
    let finalPixel = storage.store(
        mostSignificantByte: 0xAB,
        leastSignificantByte: 0xCD,
        byteOffset: 3_838,
        pixelIndex: 1_919
    )
    #expect(finalPixel)
    #expect(storage.byte(at: 3_838) == 0xAB)
    #expect(storage.byte(at: 3_839) == 0xCD)
    #expect(storage.isAffected(pixelIndex: 1_919))
    #expect(!storage.isAffected(pixelIndex: 1_918))
    let outOfBoundsPixel = storage.store(
        mostSignificantByte: 0,
        leastSignificantByte: 0,
        byteOffset: 3_839,
        pixelIndex: 1_919
    )
    #expect(!outOfBoundsPixel)
    let secondReset = storage.reset(byteCount: 3_840, pixelCount: 1_920)
    #expect(secondReset)
    #expect(!storage.isAffected(pixelIndex: 1_919))
    #expect(storage.byte(at: 3_838) == 0)
    #expect(storage.byte(at: 3_840) == nil)
}
