import GiftUIHostConfiguration
import GiftUIRuntimeCore
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFProfileRegionsMapEveryGeneratedByteCount() {
    withProfileStorage { storage, regions in
        let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()

        #expect(regions.byteCounts == preset.expectedStorageBytes)
        #expect(storage.count == StaticSignalAnalyzerNRFProfileRegions.requiredByteCount)

        let expectedByteCounts = [
            3_024, 3_024, 3_136, 4_704, 160, 3_280, 13_536, 128,
            128, 256, 256, 2_176, 2_176, 96, 192, 96,
        ]
        var expectedOffset = 0
        for (family, expectedByteCount) in zip(
            RuntimeStorageFamily.allCases,
            expectedByteCounts
        ) {
            regions.withRegion(family) { region in
                #expect(region.count == expectedByteCount)
                #expect(
                    Int(bitPattern: region.baseAddress)
                        - Int(bitPattern: storage.baseAddress) == expectedOffset
                )
            }
            expectedOffset += expectedByteCount
        }
        #expect(expectedOffset == storage.count)
    }
}

@Test func staticNRFProfileRegionsRejectIncorrectCallerStorage() {
    let storage = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 8)
    defer { storage.deallocate() }
    let regions = StaticSignalAnalyzerNRFProfileRegions(
        storage: UnsafeMutableRawBufferPointer(start: storage, count: 1)
    )

    switch consume regions {
    case nil:
        break
    case .some:
        Issue.record("Static nRF profile regions accepted incorrect storage")
    }
}

@Test func staticNRFProfileRegionsResetAttemptAndRetainedLifetimesSeparately() {
    withProfileStorage { storage, regions in
        storage.initializeMemory(as: UInt8.self, repeating: 0xA5)

        regions.resetAttemptRegions()
        #expect(nonzeroByteCount(in: storage) == 8_144)

        regions.resetAllRegions()
        #expect(nonzeroByteCount(in: storage) == 0)
    }
}

private func withProfileStorage(
    _ body: (
        UnsafeMutableRawBufferPointer,
        inout StaticSignalAnalyzerNRFProfileRegions
    ) -> Void
) {
    let byteCount = StaticSignalAnalyzerNRFProfileRegions.requiredByteCount
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: 8)
    defer { pointer.deallocate() }
    let storage = UnsafeMutableRawBufferPointer(start: pointer, count: byteCount)
    guard var regions = StaticSignalAnalyzerNRFProfileRegions(storage: storage) else {
        Issue.record("Static nRF profile regions did not accept exact storage")
        return
    }
    #expect(nonzeroByteCount(in: storage) == 0)
    body(storage, &regions)
}

private func nonzeroByteCount(in storage: UnsafeMutableRawBufferPointer) -> Int {
    storage.reduce(into: 0) { count, byte in
        if byte != 0 { count += 1 }
    }
}
