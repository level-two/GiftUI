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
        XCTAssertNil(makeRequirement(operations: .init(rawValue: 0xff)))
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

    func testEveryContributorOptionSetRejectsEmptyAndUnknownBits() throws {
        XCTAssertNil(makeRealization(kind: .fullSurface, operations: []))
        XCTAssertNil(makeRealization(
            kind: .fullSurface, operations: .init(rawValue: 0x80)
        ))
        XCTAssertNil(makeRealization(kind: .fullSurface, encodings: []))
        XCTAssertNil(makeRealization(
            kind: .fullSurface, encodings: .init(rawValue: 0x80)
        ))
        XCTAssertNil(makeRealization(kind: .fullSurface, lifetimes: []))
        XCTAssertNil(makeRealization(
            kind: .fullSurface, lifetimes: .init(rawValue: 0x80)
        ))

        let extent = try makeExtent()
        XCTAssertNil(makeSurface(extent: extent, encodings: .init(rawValue: 0x80)))
        XCTAssertNil(makeSurface(extent: extent, lifetimes: []))
        XCTAssertNil(makeSurface(
            extent: extent, lifetimes: .init(rawValue: 0x80)
        ))
        XCTAssertNil(makeSurface(extent: extent, handoffs: []))
        XCTAssertNil(makeSurface(
            extent: extent, handoffs: .init(rawValue: 0x80)
        ))

        XCTAssertNil(makePolicy(realizations: .init(rawValue: 0x80)))
        XCTAssertNil(makePolicy(encodings: .init(rawValue: 0x80)))
    }

    func testTiledRealizationRequiresACompleteAlignedRowForEveryEncoding() {
        XCTAssertNil(makeRealization(
            kind: .tiled,
            encodings: [.rgb565BigEndian, .rgba8888],
            payloadBytes: 960
        ))
        XCTAssertNotNil(makeRealization(
            kind: .tiled,
            encodings: [.rgb565BigEndian, .rgba8888],
            payloadBytes: 1_920
        ))
        XCTAssertNil(makeRealization(
            kind: .tiled,
            encodings: .rgba8888,
            alignment: .max,
            payloadBytes: 65_534
        ))
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

    func testContributionBufferPreservesFirstValuesAndRejectsEveryLaterRoleValue() throws {
        let first = try XCTUnwrap(RenderProducerContribution(
            operations: .opaqueRectangles,
            operationStream: .synchronousBorrowedOneShot
        ))
        let second = try XCTUnwrap(RenderProducerContribution(
            operations: allOperations,
            operationStream: .synchronousBorrowedOneShot
        ))
        var contributions = RasterPresentationContributions()
        XCTAssertEqual(RasterPresentationContributions.capacity, 4)
        XCTAssertEqual(contributions.insert(.renderProducer(first)), .inserted)
        XCTAssertEqual(
            contributions.insert(.renderProducer(second)),
            .rejected(.duplicateContributor(role: .renderProducer))
        )
        XCTAssertEqual(contributions.renderProducer, first)

        try insertRemainingContributions(into: &contributions)
        XCTAssertEqual(
            contributions.insert(.hostResourcePolicy(try XCTUnwrap(makePolicy()))),
            .rejected(.duplicateContributor(role: .hostResourcePolicy))
        )
        XCTAssertEqual(contributions.duplicateMask, 0b1001)
        XCTAssertEqual(
            contributions.firstInputIssue,
            .duplicateContributor(role: .renderProducer)
        )
    }

    func testContributionEqualityIgnoresDuplicatedSlotsAndNotInsertionOrder() throws {
        var first = try makeCompleteContributions(reverseOrder: false)
        var reordered = try makeCompleteContributions(reverseOrder: true)
        XCTAssertEqual(first, reordered)

        let narrow = try XCTUnwrap(RenderProducerContribution(
            operations: .opaqueRectangles,
            operationStream: .synchronousBorrowedOneShot
        ))
        XCTAssertEqual(first.insert(.renderProducer(narrow)),
                       .rejected(.duplicateContributor(role: .renderProducer)))
        XCTAssertEqual(reordered.insert(.renderProducer(narrow)),
                       .rejected(.duplicateContributor(role: .renderProducer)))
        reordered.renderProducer = narrow
        XCTAssertEqual(first, reordered)

        reordered.surfaceDisplay = try XCTUnwrap(makeSurface(
            extent: try makeExtent(), regionHeight: 4
        ))
        XCTAssertNotEqual(first, reordered)
    }

    func testContributionIssueSelectionUsesLowestRoleThenLowestMissingRole() throws {
        var contributions = RasterPresentationContributions()
        XCTAssertEqual(contributions.firstInputIssue, .missingContributor(role: .renderProducer))
        XCTAssertEqual(
            contributions.insert(.renderProducer(try makeProducer())), .inserted
        )
        XCTAssertEqual(
            contributions.insert(.surfaceDisplay(try makeSurfaceValue())), .inserted
        )
        XCTAssertEqual(
            contributions.insert(.hostResourcePolicy(try makePolicyValue())), .inserted
        )
        XCTAssertEqual(contributions.firstInputIssue, .missingContributor(role: .rasterBackend))

        XCTAssertEqual(
            contributions.insert(.surfaceDisplay(try makeSurfaceValue())),
            .rejected(.duplicateContributor(role: .surfaceDisplay))
        )
        XCTAssertEqual(
            contributions.insert(.renderProducer(try makeProducer())),
            .rejected(.duplicateContributor(role: .renderProducer))
        )
        XCTAssertEqual(
            contributions.firstInputIssue,
            .duplicateContributor(role: .renderProducer)
        )
    }

    func testResolverWorkspaceHasExactUsableCapacitiesAndReusableTwoSlots() throws {
        XCTAssertEqual(RasterPresentationResolverWorkspace.candidateCapacity, 2)
        XCTAssertNotNil(RasterPresentationResolverWorkspace(usableCandidateCapacity: 0))
        XCTAssertNotNil(RasterPresentationResolverWorkspace(usableCandidateCapacity: 1))
        XCTAssertNotNil(RasterPresentationResolverWorkspace())
        XCTAssertNil(RasterPresentationResolverWorkspace(usableCandidateCapacity: 3))

        let full = NormalizedRasterPresentationCandidate(
            realization: try XCTUnwrap(makeRealization(kind: .fullSurface))
        )
        let tiled = NormalizedRasterPresentationCandidate(
            realization: try XCTUnwrap(makeRealization(kind: .tiled))
        )
        var zero = try XCTUnwrap(RasterPresentationResolverWorkspace(
            usableCandidateCapacity: 0
        ))
        XCTAssertFalse(zero.append(full))

        var one = try XCTUnwrap(RasterPresentationResolverWorkspace(
            usableCandidateCapacity: 1
        ))
        XCTAssertTrue(one.append(full))
        XCTAssertFalse(one.append(tiled))

        var two = try XCTUnwrap(RasterPresentationResolverWorkspace())
        XCTAssertTrue(two.append(full))
        XCTAssertTrue(two.append(tiled))
        XCTAssertFalse(two.append(full))
        two.reset()
        XCTAssertTrue(two.append(tiled))
        XCTAssertTrue(two.append(full))
        XCTAssertLessThanOrEqual(MemoryLayout<RasterPresentationResolverWorkspace>.size, 96)
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
        XCTAssertLessThanOrEqual(MemoryLayout<RasterPresentationContributions>.size, 192)
        XCTAssertLessThanOrEqual(MemoryLayout<RasterPresentationResolverWorkspace>.size, 96)
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
        requireSendable(RasterPresentationContribution.self)
        requireSendable(RasterPresentationContributions.self)
        requireSendable(RasterPresentationContributionInsertion.self)
        requireSendable(RasterPresentationResolverWorkspace.self)
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
        operations: RasterOperationSet? = nil,
        encodings: CanonicalPixelEncodingSet = .rgb565BigEndian,
        lifetimes: SubmissionLifetimeSet = .synchronousBorrow,
        regionWidth: UInt16 = 480,
        regionHeight: UInt16 = 4,
        alignment: UInt16 = 2,
        payloadBytes: UInt32 = 3_840
    ) -> RasterRealizationContribution? {
        guard let extent = CapabilityExtent(width: 480, height: 320) else { return nil }
        return RasterRealizationContribution(
            kind: kind, operations: operations ?? allOperations,
            operationStream: .synchronousBorrowedOneShot,
            encodings: encodings,
            producedSubmissionLifetimes: lifetimes,
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
        encodings: CanonicalPixelEncodingSet = .rgb565BigEndian,
        lifetimes: SubmissionLifetimeSet = .synchronousBorrow,
        handoffs: SubmissionHandoffSet = .synchronous
    ) -> SurfaceDisplayContribution? {
        SurfaceDisplayContribution(
            extent: extent, encodings: encodings,
            acceptedSubmissionLifetimes: lifetimes,
            handoffs: handoffs,
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

    private func makeProducer() throws -> RenderProducerContribution {
        try XCTUnwrap(RenderProducerContribution(
            operations: allOperations,
            operationStream: .synchronousBorrowedOneShot
        ))
    }

    private func makeBackend() throws -> RasterBackendContribution {
        try XCTUnwrap(RasterBackendContribution(
            primary: try XCTUnwrap(makeRealization(kind: .fullSurface)),
            alternate: try XCTUnwrap(makeRealization(kind: .tiled))
        ))
    }

    private func makeSurfaceValue() throws -> SurfaceDisplayContribution {
        try XCTUnwrap(makeSurface(extent: try makeExtent()))
    }

    private func makePolicyValue() throws -> RasterPresentationPolicy {
        try XCTUnwrap(makePolicy())
    }

    private func insertRemainingContributions(
        into contributions: inout RasterPresentationContributions
    ) throws {
        XCTAssertEqual(contributions.insert(.rasterBackend(try makeBackend())), .inserted)
        XCTAssertEqual(contributions.insert(.surfaceDisplay(try makeSurfaceValue())), .inserted)
        XCTAssertEqual(contributions.insert(.hostResourcePolicy(try makePolicyValue())), .inserted)
    }

    private func makeCompleteContributions(
        reverseOrder: Bool
    ) throws -> RasterPresentationContributions {
        var contributions = RasterPresentationContributions()
        if reverseOrder {
            XCTAssertEqual(
                contributions.insert(.hostResourcePolicy(try makePolicyValue())), .inserted
            )
            XCTAssertEqual(
                contributions.insert(.surfaceDisplay(try makeSurfaceValue())), .inserted
            )
            XCTAssertEqual(
                contributions.insert(.rasterBackend(try makeBackend())), .inserted
            )
            XCTAssertEqual(
                contributions.insert(.renderProducer(try makeProducer())), .inserted
            )
        } else {
            XCTAssertEqual(
                contributions.insert(.renderProducer(try makeProducer())), .inserted
            )
            try insertRemainingContributions(into: &contributions)
        }
        return contributions
    }
}

private func requireSendable<T: Sendable>(_: T.Type) {}
