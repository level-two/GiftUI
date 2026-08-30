@testable import GiftUICapabilities
import XCTest

final class GiftUICapabilitiesTests: XCTestCase {
    func testCommonRawValuesAndBitsAreExact() {
        XCTAssertEqual(RasterOperationSet.opaqueRectangles.rawValue, 0x01)
        XCTAssertEqual(RasterOperationSet.positionedText.rawValue, 0x02)
        XCTAssertEqual(RasterOperationSet.straightLineStrokes.rawValue, 0x04)
        XCTAssertEqual(RasterOperationSet.clipping.rawValue, 0x08)
        XCTAssertEqual(RasterOperationSet.damage.rawValue, 0x10)
        XCTAssertEqual(allOperations.rawValue, 0x1f)
        XCTAssertEqual(CanonicalPixelEncodingSet.rgb565BigEndian.rawValue, 0x01)
        XCTAssertEqual(CanonicalPixelEncodingSet.rgba8888.rawValue, 0x02)
        XCTAssertEqual(SubmissionLifetimeSet.synchronousBorrow.rawValue, 0x01)
        XCTAssertEqual(SubmissionLifetimeSet.synchronousCopy.rawValue, 0x02)
        XCTAssertEqual(SubmissionLifetimeSet.ownershipTransfer.rawValue, 0x04)
        XCTAssertEqual(SubmissionHandoffSet.synchronous.rawValue, 0x01)
        XCTAssertEqual(SubmissionHandoffSet.queued.rawValue, 0x02)
        XCTAssertEqual(RasterRealizationKindSet.fullSurface.rawValue, 0x01)
        XCTAssertEqual(RasterRealizationKindSet.tiled.rawValue, 0x02)
        XCTAssertEqual(OperationStreamLifetime.synchronousBorrowedOneShot.rawValue, 1)
        XCTAssertEqual(CapabilityAbsence.required.rawValue, 1)
        XCTAssertEqual(CapabilityAbsence.optional.rawValue, 2)
        XCTAssertEqual(RasterRealizationKind.fullSurface.rawValue, 1)
        XCTAssertEqual(RasterRealizationKind.tiled.rawValue, 2)
        XCTAssertEqual(CanonicalPixelEncoding.rgb565BigEndian.rawValue, 1)
        XCTAssertEqual(CanonicalPixelEncoding.rgba8888.rawValue, 2)
        XCTAssertEqual(SubmissionLifetime.synchronousBorrow.rawValue, 1)
        XCTAssertEqual(SubmissionLifetime.synchronousCopy.rawValue, 2)
        XCTAssertEqual(SubmissionLifetime.ownershipTransfer.rawValue, 3)
        XCTAssertEqual(SubmissionHandoff.synchronous.rawValue, 1)
        XCTAssertEqual(SubmissionHandoff.queued.rawValue, 2)
    }

    func testMalformedCapacityAndRoleRawValuesAreExact() {
        let fields: [RasterPresentationMalformedField] = [
            .operationSet, .encodingSet, .submissionLifetimeSet, .handoffSet,
            .extent, .region, .rowByteAlignment, .inFlightCount, .byteCount,
            .alternateRealization, .policyPreference,
        ]
        XCTAssertEqual(fields.map(\.rawValue), Array(1 ... 11))
        XCTAssertEqual(
            [
                RasterPresentationContributorRole.renderProducer,
                .rasterBackend, .surfaceDisplay, .hostResourcePolicy,
            ].map(\.rawValue),
            Array(1 ... 4)
        )
        XCTAssertEqual(
            [
                RasterPresentationCapacity.resolverWorkspace,
                .raster, .payload, .inFlight,
            ].map(\.rawValue),
            Array(1 ... 4)
        )
    }

    func testExtentAndByteCountConstruction() throws {
        XCTAssertNil(CapabilityExtent(width: 0, height: 1))
        XCTAssertNil(CapabilityExtent(width: 1, height: 0))
        let extent = try XCTUnwrap(CapabilityExtent(width: .max, height: .max))
        XCTAssertEqual(extent.width, .max)
        XCTAssertEqual(extent.height, .max)
        XCTAssertEqual(CapabilityByteCount(rawValue: 0).rawValue, 0)
        XCTAssertLessThan(CapabilityByteCount(rawValue: 1), .init(rawValue: 2))
    }

    func testRequirementRequiresExactOperationsAndValidSetsButAllowsZeroCeilings() throws {
        let extent = try makeExtent()
        let value = try XCTUnwrap(RasterPresentationRequirement(
            operations: allOperations,
            extent: extent,
            operationStream: .synchronousBorrowedOneShot,
            acceptedEncodings: [.rgb565BigEndian, .rgba8888],
            acceptedSubmissionLifetimes: [.synchronousBorrow, .synchronousCopy],
            maximumRasterBytes: .init(rawValue: 0),
            maximumPayloadBytes: .init(rawValue: 0),
            maximumInFlightBytes: .init(rawValue: 0),
            absence: .required
        ))
        XCTAssertEqual(value.extent, extent)
        XCTAssertEqual(value.maximumRasterBytes.rawValue, 0)
        XCTAssertNil(makeRequirement(operations: [.opaqueRectangles]))
        XCTAssertNil(makeRequirement(encodings: []))
        XCTAssertNil(makeRequirement(encodings: .init(rawValue: 0x80)))
        XCTAssertNil(makeRequirement(lifetimes: []))
        XCTAssertNil(makeRequirement(lifetimes: .init(rawValue: 0x80)))
    }

    func testContributorStructuralBoundsAndAlternateRules() throws {
        XCTAssertNil(RenderProducerContribution(
            operations: [], operationStream: .synchronousBorrowedOneShot
        ))
        XCTAssertNil(RenderProducerContribution(
            operations: .init(rawValue: 0x80),
            operationStream: .synchronousBorrowedOneShot
        ))
        let full = try XCTUnwrap(makeRealization(kind: .fullSurface))
        let tiled = try XCTUnwrap(makeRealization(kind: .tiled))
        XCTAssertNotNil(RasterBackendContribution(primary: full, alternate: tiled))
        XCTAssertNil(RasterBackendContribution(primary: full, alternate: full))
        XCTAssertNil(makeRealization(kind: .tiled, regionWidth: 0))
        XCTAssertNil(makeRealization(kind: .tiled, regionHeight: 0))
        XCTAssertNil(makeRealization(kind: .tiled, alignment: 0))
        XCTAssertNil(makeRealization(kind: .tiled, regionWidth: 481))
        XCTAssertNil(makeRealization(kind: .tiled, payloadBytes: 959))
        XCTAssertNotNil(makeRealization(kind: .tiled, payloadBytes: 960))
    }

    func testSurfaceAndPolicyRejectMalformedStructuralValuesAndPreferences() throws {
        let extent = try makeExtent()
        XCTAssertNotNil(makeSurface(extent: extent))
        XCTAssertNil(makeSurface(extent: extent, regionWidth: 0))
        XCTAssertNil(makeSurface(extent: extent, regionHeight: 321))
        XCTAssertNil(makeSurface(extent: extent, alignment: 0))
        XCTAssertNil(makeSurface(extent: extent, inFlightCount: 0))
        XCTAssertNil(makeSurface(extent: extent, encodings: []))
        XCTAssertNotNil(makePolicy())
        XCTAssertNil(makePolicy(realizations: []))
        XCTAssertNil(makePolicy(encodings: []))
        XCTAssertNil(makePolicy(preferredRealization: .fullSurface))
        XCTAssertNil(makePolicy(preferredEncoding: [.rgb565BigEndian, .rgba8888]))
        XCTAssertNil(makePolicy(preferredEncoding: .rgba8888))
    }

    func testUnavailableVocabularyRetainsBoundedPayloads() {
        let count = CapabilityByteCount(rawValue: 7)
        let reasons: [RasterPresentationUnavailable] = [
            .malformedRequirement(field: .extent),
            .duplicateContributor(role: .renderProducer),
            .missingContributor(role: .rasterBackend),
            .malformedContribution(role: .surfaceDisplay, field: .region),
            .insufficientCapacity(domain: .payload, required: count, available: .init(rawValue: 6)),
            .operationSetMismatch, .operationStreamMismatch,
            .logicalExtentOverflow, .unsupportedLogicalExtent,
            .noCommonCanonicalPixelEncoding, .incompatibleSubmissionLifetime,
            .incompatibleSubmissionHandoff, .byteCountOverflow(domain: .raster),
            .policyHasNoConformingRealization,
        ]
        XCTAssertEqual(Set(reasons.map { String(describing: $0) }).count, reasons.count)
        XCTAssertLessThanOrEqual(MemoryLayout<RasterPresentationUnavailable>.size, 16)
    }

    func testRecordLayoutsAndSendableConformancesAreBounded() throws {
        XCTAssertLessThanOrEqual(MemoryLayout<RasterPresentationRequirement>.size, 32)
        XCTAssertLessThanOrEqual(MemoryLayout<RasterRealizationContribution>.size, 40)
        XCTAssertLessThanOrEqual(MemoryLayout<RasterBackendContribution>.size, 88)
        XCTAssertLessThanOrEqual(MemoryLayout<SurfaceDisplayContribution>.size, 40)
        XCTAssertLessThanOrEqual(MemoryLayout<RasterPresentationPolicy>.size, 32)
        XCTAssertLessThanOrEqual(MemoryLayout<EffectiveRasterPresentation>.size, 48)
        XCTAssertLessThanOrEqual(MemoryLayout<CapabilitySnapshot>.size, 56)
        requireSendable(CapabilityExtent.self)
        requireSendable(RasterPresentationRequirement.self)
        requireSendable(RasterBackendContribution.self)
        requireSendable(SurfaceDisplayContribution.self)
        requireSendable(RasterPresentationPolicy.self)
        requireSendable(RasterPresentationResolution.self)
        requireSendable(CapabilitySnapshot.self)
        requireSendable(RasterPresentationUnavailable.self)
    }

    private var allOperations: RasterOperationSet {
        [.opaqueRectangles, .positionedText, .straightLineStrokes, .clipping, .damage]
    }

    private func makeExtent() throws -> CapabilityExtent {
        try XCTUnwrap(CapabilityExtent(width: 480, height: 320))
    }

    private func makeRequirement(
        operations: RasterOperationSet? = nil,
        encodings: CanonicalPixelEncodingSet = .rgb565BigEndian,
        lifetimes: SubmissionLifetimeSet = .synchronousBorrow
    ) -> RasterPresentationRequirement? {
        guard let extent = CapabilityExtent(width: 480, height: 320) else { return nil }
        return RasterPresentationRequirement(
            operations: operations ?? allOperations,
            extent: extent,
            operationStream: .synchronousBorrowedOneShot,
            acceptedEncodings: encodings,
            acceptedSubmissionLifetimes: lifetimes,
            maximumRasterBytes: .init(rawValue: 1),
            maximumPayloadBytes: .init(rawValue: 1),
            maximumInFlightBytes: .init(rawValue: 1),
            absence: .required
        )
    }

    private func makeRealization(
        kind: RasterRealizationKind,
        regionWidth: UInt16 = 480,
        regionHeight: UInt16 = 4,
        alignment: UInt16 = 2,
        payloadBytes: UInt32 = 3_840
    ) -> RasterRealizationContribution? {
        guard let extent = CapabilityExtent(width: 480, height: 320) else { return nil }
        return RasterRealizationContribution(
            kind: kind, operations: allOperations,
            operationStream: .synchronousBorrowedOneShot,
            encodings: .rgb565BigEndian,
            producedSubmissionLifetimes: .synchronousBorrow,
            maximumExtent: extent,
            maximumRegionWidth: regionWidth,
            maximumRegionHeight: regionHeight,
            rowByteAlignment: alignment,
            maximumRasterBytes: .init(rawValue: 3_840),
            maximumPayloadBytes: .init(rawValue: payloadBytes)
        )
    }

    private func makeSurface(
        extent: CapabilityExtent,
        regionWidth: UInt16 = 480,
        regionHeight: UInt16 = 320,
        alignment: UInt16 = 2,
        inFlightCount: UInt8 = 1,
        encodings: CanonicalPixelEncodingSet = .rgb565BigEndian
    ) -> SurfaceDisplayContribution? {
        SurfaceDisplayContribution(
            extent: extent, encodings: encodings,
            acceptedSubmissionLifetimes: .synchronousBorrow,
            handoffs: .synchronous,
            maximumRegionWidth: regionWidth,
            maximumRegionHeight: regionHeight,
            rowByteAlignment: alignment,
            maximumInFlightCount: inFlightCount,
            maximumInFlightBytes: .init(rawValue: 3_840)
        )
    }

    private func makePolicy(
        realizations: RasterRealizationKindSet = .tiled,
        encodings: CanonicalPixelEncodingSet = .rgb565BigEndian,
        preferredRealization: RasterRealizationKind = .tiled,
        preferredEncoding: CanonicalPixelEncodingSet = .rgb565BigEndian
    ) -> RasterPresentationPolicy? {
        RasterPresentationPolicy(
            maximumRasterBytes: .init(rawValue: 3_840),
            maximumPayloadBytes: .init(rawValue: 3_840),
            maximumInFlightBytes: .init(rawValue: 3_840),
            allowedRealizations: realizations,
            allowedEncodings: encodings,
            preferredRealization: preferredRealization,
            preferredEncoding: preferredEncoding
        )
    }
}

private func requireSendable<T: Sendable>(_: T.Type) {}
