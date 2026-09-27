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
            region: UnsafeMutableRawBufferPointer(rebasing: region[0 ..< 1_919]),
            coverage: coverage
        ) == nil)
    #expect(
        StaticSignalAnalyzerNRFTileStorage(
            region: region,
            coverage: UnsafeMutableRawBufferPointer(rebasing: coverage[0 ..< 119])
        ) == nil)
    #expect(
        StaticSignalAnalyzerNRFTileStorage(
            region: region,
            coverage: UnsafeMutableRawBufferPointer(rebasing: region[0 ..< 120])
        ) == nil)
    guard
        var storage = StaticSignalAnalyzerNRFTileStorage(
            region: region, coverage: coverage
        )
    else {
        Issue.record("Exact Static tile storage did not construct")
        return
    }
    #expect(storage.byteCapacity == 1_920)
    #expect(storage.pixelCapacity == 960)
    let oversizedReset = storage.reset(byteCount: 1_921, pixelCount: 960)
    #expect(!oversizedReset)
    let initialReset = storage.reset(byteCount: 1_920, pixelCount: 960)
    #expect(initialReset)
    let finalPixel = storage.store(
        mostSignificantByte: 0xAB,
        leastSignificantByte: 0xCD,
        byteOffset: 1_918,
        pixelIndex: 959
    )
    #expect(finalPixel)
    #expect(storage.byte(at: 1_918) == 0xAB)
    #expect(storage.byte(at: 1_919) == 0xCD)
    #expect(storage.isAffected(pixelIndex: 959))
    #expect(!storage.isAffected(pixelIndex: 958))
    let outOfBoundsPixel = storage.store(
        mostSignificantByte: 0,
        leastSignificantByte: 0,
        byteOffset: 1_919,
        pixelIndex: 959
    )
    #expect(!outOfBoundsPixel)
    let secondReset = storage.reset(byteCount: 1_920, pixelCount: 960)
    #expect(secondReset)
    #expect(!storage.isAffected(pixelIndex: 959))
    #expect(storage.byte(at: 1_918) == 0)
    #expect(storage.byte(at: 1_920) == nil)
}
