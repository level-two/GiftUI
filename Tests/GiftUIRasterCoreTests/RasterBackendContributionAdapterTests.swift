import GiftUICapabilities
import Testing

@testable import GiftUIRasterCore

private let extent = CapabilityExtent(width: 8, height: 6)!
private let allOperations = RasterBackendContributionAdapter.requiredOperations

private func realization(
    kind: RasterRealizationKind = .tiled,
    operations: RasterOperationSet = allOperations,
    operationStream: OperationStreamLifetime = .synchronousBorrowedOneShot,
    encodings: CanonicalPixelEncodingSet = [.rgb565BigEndian],
    lifetimes: SubmissionLifetimeSet = [.synchronousBorrow],
    maximumExtent: CapabilityExtent = extent,
    maximumRegionWidth: UInt16 = 8,
    maximumRegionHeight: UInt16 = 2,
    rowByteAlignment: UInt16 = 2,
    maximumRasterBytes: UInt32 = 32,
    maximumPayloadBytes: UInt32 = 32
) -> RasterRealizationContribution? {
    RasterBackendContributionAdapter.realization(
        kind: kind,
        operations: operations,
        operationStream: operationStream,
        encodings: encodings,
        producedSubmissionLifetimes: lifetimes,
        maximumExtent: maximumExtent,
        maximumRegionWidth: maximumRegionWidth,
        maximumRegionHeight: maximumRegionHeight,
        rowByteAlignment: rowByteAlignment,
        maximumRasterBytes: CapabilityByteCount(rawValue: maximumRasterBytes),
        maximumPayloadBytes: CapabilityByteCount(rawValue: maximumPayloadBytes)
    )
}

@Test
func rasterBackendAdapterPreservesEveryOwnedContributionField() {
    let primary = realization(
        encodings: [.rgb565BigEndian, .rgba8888],
        lifetimes: [.synchronousBorrow, .synchronousCopy],
        maximumRasterBytes: 48,
        maximumPayloadBytes: 64
    )!
    let alternate = realization(
        kind: .fullSurface,
        encodings: [.rgba8888],
        lifetimes: [.ownershipTransfer],
        maximumRegionHeight: 6,
        rowByteAlignment: 4,
        maximumRasterBytes: 192,
        maximumPayloadBytes: 192
    )!
    let contribution = RasterBackendContributionAdapter.contribution(
        primary: primary,
        alternate: alternate
    )

    #expect(contribution?.primary.kind == .tiled)
    #expect(contribution?.primary.operations == allOperations)
    #expect(contribution?.primary.operationStream == .synchronousBorrowedOneShot)
    #expect(contribution?.primary.encodings == [.rgb565BigEndian, .rgba8888])
    #expect(
        contribution?.primary.producedSubmissionLifetimes
            == [.synchronousBorrow, .synchronousCopy]
    )
    #expect(contribution?.primary.maximumExtent == extent)
    #expect(contribution?.primary.maximumRegionWidth == 8)
    #expect(contribution?.primary.maximumRegionHeight == 2)
    #expect(contribution?.primary.rowByteAlignment == 2)
    #expect(contribution?.primary.maximumRasterBytes.rawValue == 48)
    #expect(contribution?.primary.maximumPayloadBytes.rawValue == 64)
    #expect(contribution?.alternate == alternate)
}

@Test
func rasterBackendAdapterRejectsInvalidOperationAndLifetimeFacts() {
    #expect(realization(operations: [.opaqueRectangles]) == nil)
    #expect(realization(operations: RasterOperationSet(rawValue: 0x3f)) == nil)
    #expect(
        realization(operationStream: .incompatibleWithSynchronousBorrowedOneShot)
            == nil
    )
    #expect(realization(encodings: []) == nil)
    #expect(realization(encodings: CanonicalPixelEncodingSet(rawValue: 0x04)) == nil)
    #expect(realization(lifetimes: []) == nil)
    #expect(realization(lifetimes: SubmissionLifetimeSet(rawValue: 0x08)) == nil)
    #expect(realization(lifetimes: [.ownershipTransfer]) == nil)
    #expect(
        realization(lifetimes: [.synchronousBorrow, .ownershipTransfer]) == nil
    )
}

@Test
func rasterBackendAdapterRejectsInvalidRegionAndAlignmentFacts() {
    #expect(realization(maximumRegionWidth: 0) == nil)
    #expect(realization(maximumRegionWidth: 9) == nil)
    #expect(realization(maximumRegionHeight: 0) == nil)
    #expect(realization(maximumRegionHeight: 7) == nil)
    #expect(realization(rowByteAlignment: 0) == nil)
    #expect(realization(maximumPayloadBytes: 15) == nil)

    let zeroByteCeilings = realization(
        kind: .fullSurface,
        maximumRegionHeight: 6,
        maximumRasterBytes: 0,
        maximumPayloadBytes: 0
    )
    #expect(zeroByteCeilings?.maximumRasterBytes.rawValue == 0)
    #expect(zeroByteCeilings?.maximumPayloadBytes.rawValue == 0)
}

@Test
func rasterBackendAdapterRejectsBypassedAndDuplicateRealizations() {
    let malformedCoverage = RasterRealizationContribution(
        kind: .fullSurface,
        operations: [.opaqueRectangles],
        operationStream: .synchronousBorrowedOneShot,
        encodings: [.rgba8888],
        producedSubmissionLifetimes: [.synchronousBorrow],
        maximumExtent: extent,
        maximumRegionWidth: 8,
        maximumRegionHeight: 6,
        rowByteAlignment: 4,
        maximumRasterBytes: CapabilityByteCount(rawValue: 192),
        maximumPayloadBytes: CapabilityByteCount(rawValue: 192)
    )!
    let malformedStream = RasterRealizationContribution(
        kind: .fullSurface,
        operations: allOperations,
        operationStream: .incompatibleWithSynchronousBorrowedOneShot,
        encodings: [.rgba8888],
        producedSubmissionLifetimes: [.synchronousBorrow],
        maximumExtent: extent,
        maximumRegionWidth: 8,
        maximumRegionHeight: 6,
        rowByteAlignment: 4,
        maximumRasterBytes: CapabilityByteCount(rawValue: 192),
        maximumPayloadBytes: CapabilityByteCount(rawValue: 192)
    )!
    let primary = realization()!

    #expect(
        RasterBackendContributionAdapter.contribution(primary: malformedCoverage)
            == nil
    )
    #expect(
        RasterBackendContributionAdapter.contribution(primary: malformedStream)
            == nil
    )
    #expect(
        RasterBackendContributionAdapter.contribution(
            primary: primary,
            alternate: realization()!
        ) == nil
    )
}
