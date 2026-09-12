import Testing

@testable import GiftUIRasterCore

private func limits(
    maximumRasterBytes: UInt32 = 100,
    maximumPayloadBytes: UInt32 = 20,
    maximumRegionsPerPayload: UInt16 = 4,
    maximumRegionSubmissionsPerFrame: UInt32 = 40,
    maximumTileVisitsPerFrame: UInt32 = 30,
    maximumInFlightPayloads: UInt8 = 2,
    maximumGlyphRasterBytes: UInt32 = 10,
    maximumStrokeWorkspaceBytes: UInt32 = 12
) -> RasterPayloadLimits? {
    RasterPayloadLimits(
        maximumRasterBytes: maximumRasterBytes,
        maximumPayloadBytes: maximumPayloadBytes,
        maximumRegionsPerPayload: maximumRegionsPerPayload,
        maximumRegionSubmissionsPerFrame: maximumRegionSubmissionsPerFrame,
        maximumTileVisitsPerFrame: maximumTileVisitsPerFrame,
        maximumInFlightPayloads: maximumInFlightPayloads,
        maximumGlyphRasterBytes: maximumGlyphRasterBytes,
        maximumStrokeWorkspaceBytes: maximumStrokeWorkspaceBytes
    )
}

@Test
func rasterPayloadLimitsPreserveEveryExactFieldAndLayout() {
    let value = limits()

    #expect(value?.maximumRasterBytes == 100)
    #expect(value?.maximumPayloadBytes == 20)
    #expect(value?.maximumRegionsPerPayload == 4)
    #expect(value?.maximumRegionSubmissionsPerFrame == 40)
    #expect(value?.maximumTileVisitsPerFrame == 30)
    #expect(value?.maximumInFlightPayloads == 2)
    #expect(value?.maximumInFlightBytes == 40)
    #expect(value?.maximumGlyphRasterBytes == 10)
    #expect(value?.maximumStrokeWorkspaceBytes == 12)
    #expect(value == limits())
    #expect(MemoryLayout<RasterPayloadLimits>.size <= 40)
    #expect(MemoryLayout<RasterPayloadLimits>.stride <= 40)
}

@Test
func rasterPayloadLimitsRejectEveryZeroFieldAndInFlightOverflow() {
    #expect(limits(maximumRasterBytes: 0) == nil)
    #expect(limits(maximumPayloadBytes: 0) == nil)
    #expect(limits(maximumRegionsPerPayload: 0) == nil)
    #expect(limits(maximumRegionSubmissionsPerFrame: 0) == nil)
    #expect(limits(maximumTileVisitsPerFrame: 0) == nil)
    #expect(limits(maximumInFlightPayloads: 0) == nil)
    #expect(limits(maximumGlyphRasterBytes: 0) == nil)
    #expect(limits(maximumStrokeWorkspaceBytes: 0) == nil)
    #expect(limits(maximumPayloadBytes: .max, maximumInFlightPayloads: 2) == nil)
    #expect(limits(maximumPayloadBytes: UInt32.max / 2, maximumInFlightPayloads: 2) != nil)
}

@Test
func rasterPayloadLimitsAdmitEqualityAndRejectFirstExcess() throws {
    let value = try #require(limits())

    #expect(value.admitsRasterBytes(100))
    #expect(!value.admitsRasterBytes(101))
    #expect(value.admitsPayloadBytes(20))
    #expect(!value.admitsPayloadBytes(21))
    #expect(value.admitsRegionsPerPayload(4))
    #expect(!value.admitsRegionsPerPayload(5))
    #expect(value.admitsRegionSubmissions(40))
    #expect(!value.admitsRegionSubmissions(41))
    #expect(value.admitsTileVisits(30))
    #expect(!value.admitsTileVisits(31))
    #expect(value.admitsInFlight(payloads: 2, bytes: 40))
    #expect(!value.admitsInFlight(payloads: 3, bytes: 40))
    #expect(!value.admitsInFlight(payloads: 2, bytes: 41))
    #expect(value.admitsGlyphRasterBytes(10))
    #expect(!value.admitsGlyphRasterBytes(11))
    #expect(value.admitsStrokeWorkspaceBytes(12))
    #expect(!value.admitsStrokeWorkspaceBytes(13))
}

@Test
func rasterBackendErrorsHaveExactRawValuesAndLayout() {
    #expect(RasterBackendError.invalidEnvelope.rawValue == 0)
    #expect(RasterBackendError.unsupportedOperation.rawValue == 1)
    #expect(RasterBackendError.incompatibleResource.rawValue == 2)
    #expect(RasterBackendError.invalidGeometry.rawValue == 3)
    #expect(RasterBackendError.arithmeticOverflow.rawValue == 4)
    #expect(RasterBackendError.capacityExhausted.rawValue == 5)
    #expect(RasterBackendError.malformedStream.rawValue == 6)
    #expect(RasterBackendError.rasterizationFailure.rawValue == 7)
    #expect(RasterBackendError.displayFailure.rawValue == 8)
    #expect(RasterBackendError.reentrancyViolation.rawValue == 9)
    #expect(RasterBackendError.invariantViolation.rawValue == 10)
    #expect(MemoryLayout<RasterBackendError>.size == 1)
    #expect(MemoryLayout<RasterBackendError>.stride == 1)
}
