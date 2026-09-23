/// The four caller-owned nRF work regions form one exact, disjoint map.
/// This source is shared by the host composition and Embedded Swift startup.
package enum StaticSignalAnalyzerNRFRegionMap {
    package static func validate(
        profile: UnsafeMutableRawBufferPointer,
        capture: UnsafeMutableRawBufferPointer,
        raster: UnsafeMutableRawBufferPointer,
        coverage: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard profile.count == 36_368,
            capture.count == StaticSignalAnalyzerNRFCaptureRegions.requiredByteCount,
            raster.count == 3_840,
            coverage.count == 240,
            aligned(profile), aligned(capture), aligned(raster), aligned(coverage)
        else { return false }
        return disjoint(profile, capture) && disjoint(profile, raster)
            && disjoint(profile, coverage) && disjoint(capture, raster)
            && disjoint(capture, coverage) && disjoint(raster, coverage)
    }

    private static func aligned(_ region: UnsafeMutableRawBufferPointer) -> Bool {
        guard let address = region.baseAddress else { return false }
        return UInt(bitPattern: address) & 7 == 0
    }

    private static func disjoint(
        _ first: UnsafeMutableRawBufferPointer,
        _ second: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let firstAddress = first.baseAddress,
            let secondAddress = second.baseAddress,
            first.count > 0, second.count > 0
        else { return false }
        let a = UInt(bitPattern: firstAddress)
        let b = UInt(bitPattern: secondAddress)
        guard a <= UInt.max - UInt(first.count),
            b <= UInt.max - UInt(second.count)
        else { return false }
        return a + UInt(first.count) <= b || b + UInt(second.count) <= a
    }
}
