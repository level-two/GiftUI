import GiftUICapabilities
import Testing

@testable import GiftUIDisplayCore

private let displayExtent = CapabilityExtent(width: 8, height: 6)!

private func contribution(
    extent: CapabilityExtent = displayExtent,
    encodings: CanonicalPixelEncodingSet = [.rgb565BigEndian],
    lifetimes: SubmissionLifetimeSet = [.synchronousBorrow],
    handoffs: SubmissionHandoffSet = [.synchronous],
    maximumRegionWidth: UInt16 = 8,
    maximumRegionHeight: UInt16 = 2,
    rowByteAlignment: UInt16 = 2,
    maximumInFlightCount: UInt8 = 1,
    maximumInFlightBytes: UInt32 = 32
) -> SurfaceDisplayContribution? {
    SurfaceDisplayContributionAdapter.contribution(
        extent: extent,
        encodings: encodings,
        acceptedSubmissionLifetimes: lifetimes,
        handoffs: handoffs,
        maximumRegionWidth: maximumRegionWidth,
        maximumRegionHeight: maximumRegionHeight,
        rowByteAlignment: rowByteAlignment,
        maximumInFlightCount: maximumInFlightCount,
        maximumInFlightBytes: CapabilityByteCount(rawValue: maximumInFlightBytes)
    )
}

@Test
func surfaceDisplayAdapterPreservesEveryOwnedContributionField() {
    let value = contribution(
        encodings: [.rgb565BigEndian, .rgba8888],
        lifetimes: [.synchronousBorrow, .synchronousCopy, .ownershipTransfer],
        handoffs: [.synchronous, .queued],
        maximumRegionHeight: 6,
        rowByteAlignment: 4,
        maximumInFlightCount: 2,
        maximumInFlightBytes: 384
    )

    #expect(value?.extent == displayExtent)
    #expect(value?.encodings == [.rgb565BigEndian, .rgba8888])
    #expect(
        value?.acceptedSubmissionLifetimes
            == [.synchronousBorrow, .synchronousCopy, .ownershipTransfer]
    )
    #expect(value?.handoffs == [.synchronous, .queued])
    #expect(value?.maximumRegionWidth == 8)
    #expect(value?.maximumRegionHeight == 6)
    #expect(value?.rowByteAlignment == 4)
    #expect(value?.maximumInFlightCount == 2)
    #expect(value?.maximumInFlightBytes.rawValue == 384)
}

@Test
func surfaceDisplayAdapterRejectsEveryMalformedFieldDomain() {
    #expect(contribution(encodings: []) == nil)
    #expect(contribution(encodings: CanonicalPixelEncodingSet(rawValue: 0x04)) == nil)
    #expect(contribution(lifetimes: []) == nil)
    #expect(contribution(lifetimes: SubmissionLifetimeSet(rawValue: 0x08)) == nil)
    #expect(contribution(handoffs: []) == nil)
    #expect(contribution(handoffs: SubmissionHandoffSet(rawValue: 0x04)) == nil)
    #expect(contribution(maximumRegionWidth: 0) == nil)
    #expect(contribution(maximumRegionWidth: 9) == nil)
    #expect(contribution(maximumRegionHeight: 0) == nil)
    #expect(contribution(maximumRegionHeight: 7) == nil)
    #expect(contribution(rowByteAlignment: 0) == nil)
    #expect(contribution(maximumInFlightCount: 0) == nil)
}

@Test
func surfaceDisplayAdapterPreservesZeroAvailableByteCapacity() {
    let value = contribution(maximumInFlightBytes: 0)

    #expect(value?.maximumInFlightBytes.rawValue == 0)
}
