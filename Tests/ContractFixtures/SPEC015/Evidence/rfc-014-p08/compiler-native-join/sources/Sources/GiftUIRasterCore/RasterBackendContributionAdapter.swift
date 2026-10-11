import GiftUICapabilities

package enum RasterBackendContributionAdapter {
    package static let requiredOperations: RasterOperationSet = [
        .opaqueRectangles,
        .positionedText,
        .straightLineStrokes,
        .clipping,
        .damage,
    ]

    package static func realization(
        kind: RasterRealizationKind,
        operations: RasterOperationSet,
        operationStream: OperationStreamLifetime,
        encodings: CanonicalPixelEncodingSet,
        producedSubmissionLifetimes: SubmissionLifetimeSet,
        maximumExtent: CapabilityExtent,
        maximumRegionWidth: UInt16,
        maximumRegionHeight: UInt16,
        rowByteAlignment: UInt16,
        maximumRasterBytes: CapabilityByteCount,
        maximumPayloadBytes: CapabilityByteCount
    ) -> RasterRealizationContribution? {
        guard operations == requiredOperations,
            operationStream == .synchronousBorrowedOneShot,
            admitsSubmissionLifetimes(
                producedSubmissionLifetimes,
                for: kind
            )
        else {
            return nil
        }

        return RasterRealizationContribution(
            kind: kind,
            operations: operations,
            operationStream: operationStream,
            encodings: encodings,
            producedSubmissionLifetimes: producedSubmissionLifetimes,
            maximumExtent: maximumExtent,
            maximumRegionWidth: maximumRegionWidth,
            maximumRegionHeight: maximumRegionHeight,
            rowByteAlignment: rowByteAlignment,
            maximumRasterBytes: maximumRasterBytes,
            maximumPayloadBytes: maximumPayloadBytes
        )
    }

    package static func contribution(
        primary: RasterRealizationContribution,
        alternate: RasterRealizationContribution? = nil
    ) -> RasterBackendContribution? {
        guard isConforming(primary), alternate.map(isConforming) ?? true else {
            return nil
        }
        return RasterBackendContribution(primary: primary, alternate: alternate)
    }

    private static func isConforming(
        _ realization: RasterRealizationContribution
    ) -> Bool {
        realization.operations == requiredOperations
            && realization.operationStream == .synchronousBorrowedOneShot
            && admitsSubmissionLifetimes(
                realization.producedSubmissionLifetimes,
                for: realization.kind
            )
    }

    private static func admitsSubmissionLifetimes(
        _ lifetimes: SubmissionLifetimeSet,
        for kind: RasterRealizationKind
    ) -> Bool {
        guard kind == .tiled else { return true }
        let synchronous: SubmissionLifetimeSet = [
            .synchronousBorrow,
            .synchronousCopy,
        ]
        return !lifetimes.isEmpty && lifetimes.subtracting(synchronous).isEmpty
    }
}
