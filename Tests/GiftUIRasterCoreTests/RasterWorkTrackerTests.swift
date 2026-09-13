import Testing

@testable import GiftUIRasterCore

private func trackerLimits(
    rasterBytes: UInt32 = 10,
    payloadBytes: UInt32 = 8,
    regions: UInt16 = 2,
    submissions: UInt32 = 4,
    tiles: UInt32 = 3,
    glyphBytes: UInt32 = 6,
    strokeBytes: UInt32 = 7
) -> RasterPayloadLimits {
    RasterPayloadLimits(
        maximumRasterBytes: rasterBytes,
        maximumPayloadBytes: payloadBytes,
        maximumRegionsPerPayload: regions,
        maximumRegionSubmissionsPerFrame: submissions,
        maximumTileVisitsPerFrame: tiles,
        maximumInFlightPayloads: 1,
        maximumGlyphRasterBytes: glyphBytes,
        maximumStrokeWorkspaceBytes: strokeBytes
    )!
}

@Test
func rasterWorkTrackerAdmitsEqualityAndRecordsEveryHighWater() {
    var tracker = RasterWorkTracker(limits: trackerLimits())

    let raster = tracker.observeRasterBytes(10)
    let glyph = tracker.observeGlyphBytes(6)
    let stroke = tracker.observeStrokeWorkspaceBytes(7)
    let tiles = tracker.recordTileVisits(3)
    let pixels = tracker.recordPixelVisits(4)
    let firstPayload = tracker.recordPayload(bytes: 8, regions: 2)
    let secondPayload = tracker.recordPayload(bytes: 4, regions: 2)
    #expect(raster && glyph && stroke && tiles && pixels)
    #expect(firstPayload && secondPayload)
    #expect(tracker.failure == nil)
    #expect(tracker.highWater.rasterBytes == 10)
    #expect(tracker.highWater.payloadBytes == 8)
    #expect(tracker.highWater.payloads == 2)
    #expect(tracker.highWater.regionSubmissions == 4)
    #expect(tracker.highWater.tileVisits == 3)
    #expect(tracker.highWater.pixelVisits == 4)
    #expect(tracker.highWater.glyphBytes == 6)
    #expect(tracker.highWater.strokeWorkspaceBytes == 7)
}

@Test
func rasterWorkTrackerRejectsFirstExcessInEveryIndependentDomain() {
    assertCapacityFailure { $0.observeRasterBytes(11) }
    assertCapacityFailure { $0.observeGlyphBytes(7) }
    assertCapacityFailure { $0.observeStrokeWorkspaceBytes(8) }
    assertCapacityFailure { $0.recordTileVisits(4) }
    assertCapacityFailure { $0.recordPixelVisits(5) }
    assertCapacityFailure { $0.recordPayload(bytes: 9, regions: 1) }
    assertCapacityFailure { $0.recordPayload(bytes: 1, regions: 3) }

    var regions = RasterWorkTracker(limits: trackerLimits())
    let first = regions.recordPayload(bytes: 1, regions: 2)
    let second = regions.recordPayload(bytes: 1, regions: 2)
    let excess = regions.recordPayload(bytes: 1, regions: 1)
    #expect(first)
    #expect(second)
    #expect(!excess)
    #expect(regions.failure == .capacityExhausted)
}

@Test
func rasterWorkTrackerKeepsFirstFailureSticky() {
    var tracker = RasterWorkTracker(limits: trackerLimits())

    let malformed = tracker.recordPayload(bytes: 0, regions: 0)
    #expect(!malformed)
    #expect(tracker.failure == .malformedStream)
    let later = tracker.recordTileVisits(4)
    #expect(!later)
    #expect(tracker.failure == .malformedStream)
}

@Test
func rasterWorkTrackerContinuesCheckedValidationOnlyAfterAcceptance() {
    var tracker = RasterWorkTracker(limits: trackerLimits())
    tracker.acceptPresentationResponsibility()

    let excess = tracker.recordTileVisits(4)
    #expect(excess)
    #expect(tracker.failure == .capacityExhausted)
    #expect(tracker.isDraining)
    let payload = tracker.recordPayload(bytes: 1, regions: 1)
    #expect(payload)
    #expect(tracker.highWater.payloads == 1)
    #expect(tracker.highWater.regionSubmissions == 1)
    #expect(tracker.failure == .capacityExhausted)
}

@Test
func rasterWorkTrackerDetectsArithmeticOverflowAndCompletelyResets() {
    var tracker = RasterWorkTracker(
        limits: trackerLimits(submissions: .max, tiles: .max)
    )
    let exact = tracker.recordTileVisits(.max)
    let overflow = tracker.recordTileVisits()
    #expect(exact)
    #expect(!overflow)
    #expect(tracker.failure == .arithmeticOverflow)

    tracker.reset()
    #expect(tracker.failure == nil)
    #expect(tracker.highWater == RasterWorkHighWater())
    #expect(!tracker.presentationResponsibilityAccepted)
    #expect(!tracker.isDraining)
}

private func assertCapacityFailure(
    _ body: (inout RasterWorkTracker) -> Bool
) {
    var tracker = RasterWorkTracker(limits: trackerLimits())
    #expect(!body(&tracker))
    #expect(tracker.failure == .capacityExhausted)
}
