import GiftUICapabilities

package enum SurfaceDisplayContributionAdapter {
    package static func contribution(
        extent: CapabilityExtent,
        encodings: CanonicalPixelEncodingSet,
        acceptedSubmissionLifetimes: SubmissionLifetimeSet,
        handoffs: SubmissionHandoffSet,
        maximumRegionWidth: UInt16,
        maximumRegionHeight: UInt16,
        rowByteAlignment: UInt16,
        maximumInFlightCount: UInt8,
        maximumInFlightBytes: CapabilityByteCount
    ) -> SurfaceDisplayContribution? {
        SurfaceDisplayContribution(
            extent: extent,
            encodings: encodings,
            acceptedSubmissionLifetimes: acceptedSubmissionLifetimes,
            handoffs: handoffs,
            maximumRegionWidth: maximumRegionWidth,
            maximumRegionHeight: maximumRegionHeight,
            rowByteAlignment: rowByteAlignment,
            maximumInFlightCount: maximumInFlightCount,
            maximumInFlightBytes: maximumInFlightBytes
        )
    }
}
