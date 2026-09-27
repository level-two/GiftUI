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
            region: UnsafeMutableRawBufferPointer(rebasing: region[0 ..< 2_559]),
            coverage: coverage
        ) == nil)
    #expect(
        StaticSignalAnalyzerNRFTileStorage(
            region: region,
            coverage: UnsafeMutableRawBufferPointer(rebasing: coverage[0 ..< 159])
        ) == nil)
    #expect(
        StaticSignalAnalyzerNRFTileStorage(
            region: region,
            coverage: UnsafeMutableRawBufferPointer(rebasing: region[0 ..< 160])
        ) == nil)
    guard
        var storage = StaticSignalAnalyzerNRFTileStorage(
            region: region, coverage: coverage
        )
    else {
        Issue.record("Exact Static tile storage did not construct")
        return
    }
    #expect(storage.byteCapacity == 2_560)
    #expect(storage.pixelCapacity == 1_280)
    let oversizedReset = storage.reset(byteCount: 2_561, pixelCount: 1_280)
    #expect(!oversizedReset)
    let initialReset = storage.reset(byteCount: 2_560, pixelCount: 1_280)
    #expect(initialReset)
    let finalPixel = storage.store(
        mostSignificantByte: 0xAB,
        leastSignificantByte: 0xCD,
        byteOffset: 2_558,
        pixelIndex: 1_279
    )
    #expect(finalPixel)
    #expect(storage.byte(at: 2_558) == 0xAB)
    #expect(storage.byte(at: 2_559) == 0xCD)
    #expect(storage.isAffected(pixelIndex: 1_279))
    #expect(!storage.isAffected(pixelIndex: 1_278))
    let outOfBoundsPixel = storage.store(
        mostSignificantByte: 0,
        leastSignificantByte: 0,
        byteOffset: 2_559,
        pixelIndex: 1_279
    )
    #expect(!outOfBoundsPixel)
    let secondReset = storage.reset(byteCount: 2_560, pixelCount: 1_280)
    #expect(secondReset)
    #expect(!storage.isAffected(pixelIndex: 1_279))
    #expect(storage.byte(at: 2_558) == 0)
    #expect(storage.byte(at: 2_560) == nil)
}
