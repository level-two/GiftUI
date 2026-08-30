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
        XCTAssertEqual(
            OperationStreamLifetime.incompatibleWithSynchronousBorrowedOneShot.rawValue,
            2
        )
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

    func testRasterArithmeticCoversBothEncodingsAndRegionKinds() throws {
        let tiled = try evaluateArithmetic(
            width: 5,
            height: 9,
            kind: .tiled,
            encoding: .rgb565BigEndian,
            realizationRegionHeight: 3,
            surfaceRegionHeight: 4,
            realizationAlignment: 6,
            surfaceAlignment: 8
        )
        XCTAssertEqual(tiled, .available(RasterPresentationArithmeticValue(
            effectiveRowAlignment: 24,
            regionExtent: try XCTUnwrap(CapabilityExtent(width: 5, height: 3)),
            rowBytes: .init(rawValue: 24),
            requiredRasterBytes: .init(rawValue: 72),
            requiredPayloadBytes: .init(rawValue: 72),
            requiredInFlightBytes: .init(rawValue: 72)
        )))

        let fullSurface = try evaluateArithmetic(
            width: 5,
            height: 7,
            kind: .fullSurface,
            encoding: .rgba8888,
            realizationRegionHeight: 7,
            surfaceRegionHeight: 7,
            realizationAlignment: 4,
            surfaceAlignment: 8
        )
        XCTAssertEqual(fullSurface, .available(RasterPresentationArithmeticValue(
            effectiveRowAlignment: 8,
            regionExtent: try XCTUnwrap(CapabilityExtent(width: 5, height: 7)),
            rowBytes: .init(rawValue: 24),
            requiredRasterBytes: .init(rawValue: 168),
            requiredPayloadBytes: .init(rawValue: 168),
            requiredInFlightBytes: .init(rawValue: 168)
        )))
    }

    func testRasterArithmeticProducesExactNRFUsage() throws {
        let outcome = try evaluateArithmetic(
            width: 480,
            height: 320,
            kind: .tiled,
            encoding: .rgb565BigEndian,
            realizationRegionHeight: 4,
            surfaceRegionHeight: 320,
            realizationAlignment: 2,
            surfaceAlignment: 2,
            ceiling: 3_840
        )
        XCTAssertEqual(outcome, .available(RasterPresentationArithmeticValue(
            effectiveRowAlignment: 2,
            regionExtent: try XCTUnwrap(CapabilityExtent(width: 480, height: 4)),
            rowBytes: .init(rawValue: 960),
            requiredRasterBytes: .init(rawValue: 3_840),
            requiredPayloadBytes: .init(rawValue: 3_840),
            requiredInFlightBytes: .init(rawValue: 3_840)
        )))
    }

    func testRasterArithmeticSelectsEveryRegionLimitAndRejectsNarrowOrShortFullSurface() throws {
        guard case let .available(logicalMinimum) = try evaluateArithmetic(
            width: 5, height: 2, kind: .tiled, encoding: .rgb565BigEndian,
            realizationExtentHeight: 4, surfaceExtentHeight: 4,
            realizationRegionHeight: 3, surfaceRegionHeight: 4,
            realizationAlignment: 1, surfaceAlignment: 1
        ) else { return XCTFail("logical height must be selectable") }
        XCTAssertEqual(logicalMinimum.regionExtent.height, 2)

        guard case let .available(surfaceMinimum) = try evaluateArithmetic(
            width: 5, height: 9, kind: .tiled, encoding: .rgb565BigEndian,
            realizationRegionHeight: 4, surfaceRegionHeight: 3,
            realizationAlignment: 1, surfaceAlignment: 1
        ) else { return XCTFail("surface height must be selectable") }
        XCTAssertEqual(surfaceMinimum.regionExtent.height, 3)

        XCTAssertEqual(
            try evaluateArithmetic(
                width: 5, height: 2, kind: .fullSurface,
                encoding: .rgb565BigEndian,
                realizationRegionWidth: 4,
                realizationRegionHeight: 2, surfaceRegionHeight: 2,
                realizationAlignment: 1, surfaceAlignment: 1
            ),
            .unavailable(.unsupportedLogicalExtent)
        )
        XCTAssertEqual(
            try evaluateArithmetic(
                width: 5, height: 2, kind: .fullSurface,
                encoding: .rgb565BigEndian,
                surfaceRegionWidth: 4,
                realizationRegionHeight: 2, surfaceRegionHeight: 2,
                realizationAlignment: 1, surfaceAlignment: 1
            ),
            .unavailable(.unsupportedLogicalExtent)
        )
        XCTAssertEqual(
            try evaluateArithmetic(
                width: 5, height: 3, kind: .fullSurface,
                encoding: .rgb565BigEndian,
                realizationRegionHeight: 2, surfaceRegionHeight: 3,
                realizationAlignment: 1, surfaceAlignment: 1
            ),
            .unavailable(.unsupportedLogicalExtent)
        )
        XCTAssertEqual(
            try evaluateArithmetic(
                width: 5, height: 3, kind: .fullSurface,
                encoding: .rgb565BigEndian,
                realizationRegionHeight: 3, surfaceRegionHeight: 2,
                realizationAlignment: 1, surfaceAlignment: 1
            ),
            .unavailable(.unsupportedLogicalExtent)
        )
    }

    func testRasterArithmeticMaximumTypedRowsRemainRepresentable() throws {
        let maximumLCM = try evaluateArithmetic(
            width: .max,
            height: 1,
            kind: .fullSurface,
            encoding: .rgb565BigEndian,
            realizationRegionHeight: 1,
            surfaceRegionHeight: 1,
            realizationAlignment: .max,
            surfaceAlignment: .max - 1,
            ceiling: .max
        )
        guard case let .available(lcmValue) = maximumLCM else {
            return XCTFail("maximum typed LCM must remain representable")
        }
        XCTAssertEqual(lcmValue.effectiveRowAlignment, 4_294_770_690)
        XCTAssertEqual(lcmValue.rowBytes.rawValue, 4_294_770_690)

        let maximumUnalignedRow = try evaluateArithmetic(
            width: .max,
            height: 1,
            kind: .fullSurface,
            encoding: .rgba8888,
            realizationRegionHeight: 1,
            surfaceRegionHeight: 1,
            realizationAlignment: 1,
            surfaceAlignment: 1,
            ceiling: .max
        )
        guard case let .available(rowValue) = maximumUnalignedRow else {
            return XCTFail("maximum typed unaligned row must remain representable")
        }
        XCTAssertEqual(rowValue.rowBytes.rawValue, 262_140)
    }

    func testRasterArithmeticSharedUsageOverflowIsAssignedToRaster() throws {
        let outcome = try evaluateArithmetic(
            width: .max,
            height: 2,
            kind: .fullSurface,
            encoding: .rgb565BigEndian,
            realizationRegionHeight: 2,
            surfaceRegionHeight: 2,
            realizationAlignment: .max,
            surfaceAlignment: .max - 1,
            ceiling: .max
        )
        XCTAssertEqual(outcome, .unavailable(.byteCountOverflow(domain: .raster)))
    }

    func testRasterArithmeticReportsEveryExactMinimumCapacity() throws {
        let required = CapabilityByteCount(rawValue: 16)
        XCTAssertEqual(
            try evaluateArithmetic(
                width: 4, height: 2, kind: .fullSurface,
                encoding: .rgb565BigEndian,
                realizationRegionHeight: 2, surfaceRegionHeight: 2,
                realizationAlignment: 1, surfaceAlignment: 1,
                rasterCeilings: (20, 15, 18)
            ),
            .unavailable(.insufficientCapacity(
                domain: .raster, required: required, available: .init(rawValue: 15)
            ))
        )
        XCTAssertEqual(
            try evaluateArithmetic(
                width: 4, height: 2, kind: .fullSurface,
                encoding: .rgb565BigEndian,
                realizationRegionHeight: 2, surfaceRegionHeight: 2,
                realizationAlignment: 1, surfaceAlignment: 1,
                payloadCeilings: (20, 18, 15)
            ),
            .unavailable(.insufficientCapacity(
                domain: .payload, required: required, available: .init(rawValue: 15)
            ))
        )
        XCTAssertEqual(
            try evaluateArithmetic(
                width: 4, height: 2, kind: .fullSurface,
                encoding: .rgb565BigEndian,
                realizationRegionHeight: 2, surfaceRegionHeight: 2,
                realizationAlignment: 1, surfaceAlignment: 1,
                inFlightCeilings: (20, 0, 18)
            ),
            .unavailable(.insufficientCapacity(
                domain: .inFlight, required: required, available: .init(rawValue: 0)
            ))
        )
    }

    func testRasterArithmeticCoversAllNineCapacityOwnersAtTheirBoundary() throws {
        let equalityOwnerPositions: [(UInt32, UInt32, UInt32)] = [
            (16, 20, 20), (20, 16, 20), (20, 20, 16),
        ]
        let firstExcessOwnerPositions: [(UInt32, UInt32, UInt32)] = [
            (15, 20, 20), (20, 15, 20), (20, 20, 15),
        ]

        for ceilings in equalityOwnerPositions {
            try assertArithmeticUsageAvailable(rasterCeilings: ceilings)
            try assertArithmeticUsageAvailable(payloadCeilings: ceilings)
            try assertArithmeticUsageAvailable(inFlightCeilings: ceilings)
        }
        for ceilings in firstExcessOwnerPositions {
            XCTAssertEqual(
                try boundaryArithmetic(rasterCeilings: ceilings),
                .unavailable(.insufficientCapacity(
                    domain: .raster,
                    required: .init(rawValue: 16),
                    available: .init(rawValue: 15)
                ))
            )
            XCTAssertEqual(
                try boundaryArithmetic(payloadCeilings: ceilings),
                .unavailable(.insufficientCapacity(
                    domain: .payload,
                    required: .init(rawValue: 16),
                    available: .init(rawValue: 15)
                ))
            )
            XCTAssertEqual(
                try boundaryArithmetic(inFlightCeilings: ceilings),
                .unavailable(.insufficientCapacity(
                    domain: .inFlight,
                    required: .init(rawValue: 16),
                    available: .init(rawValue: 15)
                ))
            )
        }
    }

    func testOperationStreamNegativeFactIsConstructibleOnlyForContributions() throws {
        XCTAssertNil(makeRequirement(
            operationStream: .incompatibleWithSynchronousBorrowedOneShot
        ))
        let producer = try XCTUnwrap(RenderProducerContribution(
            operations: allOperations,
            operationStream: .incompatibleWithSynchronousBorrowedOneShot
        ))
        XCTAssertEqual(
            RasterPresentationCompatibility.producerIssue(
                requirement: try XCTUnwrap(makeRequirement()), producer: producer
            ),
            .operationStreamMismatch
        )
        let realization = try XCTUnwrap(makeRealization(
            kind: .tiled,
            operationStream: .incompatibleWithSynchronousBorrowedOneShot
        ))
        XCTAssertEqual(
            try evaluateCompatibility(realization: realization),
            .unavailable(.operationStreamMismatch)
        )
    }

    func testProducerAndCandidateOperationMismatchRemainDistinctFromStreamMismatch() throws {
        let requirement = try XCTUnwrap(makeRequirement(byteCeiling: 3_840))
        let narrowProducer = try XCTUnwrap(RenderProducerContribution(
            operations: .opaqueRectangles,
            operationStream: .synchronousBorrowedOneShot
        ))
        XCTAssertEqual(
            RasterPresentationCompatibility.producerIssue(
                requirement: requirement, producer: narrowProducer
            ),
            .operationSetMismatch
        )
        XCTAssertEqual(
            try evaluateCompatibility(realization: try XCTUnwrap(makeRealization(
                kind: .tiled, operations: .opaqueRectangles
            ))),
            .unavailable(.operationSetMismatch)
        )
    }

    func testEncodingLifetimeAndHandoffFailuresAreIndependent() throws {
        XCTAssertEqual(
            try evaluateCompatibility(
                realization: try XCTUnwrap(makeRealization(
                    kind: .tiled, encodings: .rgb565BigEndian
                )),
                surface: try makeSurfaceValue(encodings: .rgba8888)
            ),
            .unavailable(.noCommonCanonicalPixelEncoding)
        )
        XCTAssertEqual(
            try evaluateCompatibility(
                realization: try XCTUnwrap(makeRealization(
                    kind: .tiled, lifetimes: .synchronousCopy
                )),
                requirementLifetimes: .synchronousBorrow
            ),
            .unavailable(.incompatibleSubmissionLifetime)
        )
        XCTAssertEqual(
            try evaluateCompatibility(
                realization: try XCTUnwrap(makeRealization(kind: .tiled)),
                surface: try makeSurfaceValue(handoffs: .queued)
            ),
            .unavailable(.incompatibleSubmissionHandoff)
        )
    }

    func testCompleteSubmissionLifetimeHandoffMatrixAndRawOrder() throws {
        let cases: [(SubmissionLifetimeSet, SubmissionHandoffSet, SubmissionLifetime, SubmissionHandoff, Bool)] = [
            (.synchronousBorrow, .synchronous, .synchronousBorrow, .synchronous, true),
            (.synchronousBorrow, .queued, .synchronousBorrow, .queued, false),
            (.synchronousCopy, .synchronous, .synchronousCopy, .synchronous, true),
            (.synchronousCopy, .queued, .synchronousCopy, .queued, true),
            (.ownershipTransfer, .synchronous, .ownershipTransfer, .synchronous, true),
            (.ownershipTransfer, .queued, .ownershipTransfer, .queued, true),
        ]
        for (lifetimeSet, handoffSet, expectedLifetime, expectedHandoff, available) in cases {
            let outcome = try evaluateCompatibility(
                realization: try XCTUnwrap(makeRealization(
                    kind: .tiled, lifetimes: lifetimeSet
                )),
                surface: try makeSurfaceValue(
                    lifetimes: lifetimeSet, handoffs: handoffSet
                ),
                requirementLifetimes: lifetimeSet
            )
            if available {
                guard case let .available(path) = outcome else {
                    return XCTFail("matrix-compatible path must be available")
                }
                XCTAssertEqual(path.submissionLifetime, expectedLifetime)
                XCTAssertEqual(path.handoff, expectedHandoff)
            } else {
                XCTAssertEqual(outcome, .unavailable(.incompatibleSubmissionHandoff))
            }
        }

        guard case let .available(rawOrdered) = try evaluateCompatibility(
            realization: try XCTUnwrap(makeRealization(
                kind: .tiled,
                lifetimes: [.synchronousBorrow, .synchronousCopy, .ownershipTransfer]
            )),
            surface: try makeSurfaceValue(
                lifetimes: [.synchronousBorrow, .synchronousCopy, .ownershipTransfer],
                handoffs: [.synchronous, .queued]
            ),
            requirementLifetimes: [.synchronousBorrow, .synchronousCopy, .ownershipTransfer]
        ) else { return XCTFail("raw-ordered path must be available") }
        XCTAssertEqual(rawOrdered.submissionLifetime, .synchronousBorrow)
        XCTAssertEqual(rawOrdered.handoff, .synchronous)
    }

    func testPolicyFiltersOnlyAfterTechnicalConformanceAndUsesPreferences() throws {
        let both = try XCTUnwrap(makeRealization(
            kind: .tiled,
            encodings: [.rgb565BigEndian, .rgba8888],
            rasterBytes: 7_680,
            payloadBytes: 7_680
        ))
        let bothSurface = try makeSurfaceValue(
            encodings: [.rgb565BigEndian, .rgba8888], inFlightBytes: 7_680
        )
        let rgbaPolicy = try XCTUnwrap(makePolicy(
            encodings: [.rgb565BigEndian, .rgba8888],
            preferredEncoding: .rgba8888,
            byteCeiling: 7_680
        ))
        guard case let .available(preferred) = try evaluateCompatibility(
            realization: both,
            surface: bothSurface,
            requirementEncodings: [.rgb565BigEndian, .rgba8888],
            requirementByteCeiling: 7_680,
            policy: rgbaPolicy
        ) else { return XCTFail("preferred encoding must be selected") }
        XCTAssertEqual(preferred.encoding, .rgba8888)

        let constrainedPolicy = try XCTUnwrap(makePolicy(
            encodings: [.rgb565BigEndian, .rgba8888],
            preferredEncoding: .rgba8888,
            byteCeiling: 3_840
        ))
        guard case let .available(fallback) = try evaluateCompatibility(
            realization: both,
            surface: bothSurface,
            requirementEncodings: [.rgb565BigEndian, .rgba8888],
            policy: constrainedPolicy
        ) else { return XCTFail("conforming fallback must be selected") }
        XCTAssertEqual(fallback.encoding, .rgb565BigEndian)

        XCTAssertEqual(
            try evaluateCompatibility(
                realization: try XCTUnwrap(makeRealization(kind: .tiled)),
                policy: try XCTUnwrap(makePolicy(
                    realizations: .fullSurface,
                    preferredRealization: .fullSurface
                ))
            ),
            .unavailable(.policyHasNoConformingRealization)
        )
        XCTAssertEqual(
            try evaluateCompatibility(
                realization: try XCTUnwrap(makeRealization(kind: .tiled)),
                policy: try XCTUnwrap(makePolicy(
                    encodings: .rgba8888,
                    preferredEncoding: .rgba8888
                ))
            ),
            .unavailable(.policyHasNoConformingRealization)
        )
    }

    func testRealizationPreferenceIsIndependentOfCandidateDeclarationOrder() throws {
        let arithmetic = RasterPresentationArithmeticValue(
            effectiveRowAlignment: 2,
            regionExtent: try XCTUnwrap(CapabilityExtent(width: 1, height: 1)),
            rowBytes: .init(rawValue: 2),
            requiredRasterBytes: .init(rawValue: 2),
            requiredPayloadBytes: .init(rawValue: 2),
            requiredInFlightBytes: .init(rawValue: 2)
        )
        let full = RasterPresentationCandidatePath(
            realization: .fullSurface,
            encoding: .rgb565BigEndian,
            submissionLifetime: .synchronousBorrow,
            handoff: .synchronous,
            arithmetic: arithmetic
        )
        let tiled = RasterPresentationCandidatePath(
            realization: .tiled,
            encoding: .rgb565BigEndian,
            submissionLifetime: .synchronousBorrow,
            handoff: .synchronous,
            arithmetic: arithmetic
        )
        let policy = try XCTUnwrap(makePolicy(
            realizations: [.fullSurface, .tiled],
            preferredRealization: .tiled
        ))
        XCTAssertTrue(RasterPresentationCompatibility.prefers(
            tiled, over: full, policy: policy
        ))
        XCTAssertFalse(RasterPresentationCompatibility.prefers(
            full, over: tiled, policy: policy
        ))
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

    private func evaluateArithmetic(
        width: UInt16,
        height: UInt16,
        kind: RasterRealizationKind,
        encoding: CanonicalPixelEncoding,
        realizationExtentHeight: UInt16? = nil,
        surfaceExtentHeight: UInt16? = nil,
        realizationRegionWidth: UInt16? = nil,
        surfaceRegionWidth: UInt16? = nil,
        realizationRegionHeight: UInt16,
        surfaceRegionHeight: UInt16,
        realizationAlignment: UInt16,
        surfaceAlignment: UInt16,
        ceiling: UInt32 = 1_000_000,
        rasterCeilings: (UInt32, UInt32, UInt32)? = nil,
        payloadCeilings: (UInt32, UInt32, UInt32)? = nil,
        inFlightCeilings: (UInt32, UInt32, UInt32)? = nil
    ) throws -> RasterPresentationArithmeticOutcome {
        let extent = try XCTUnwrap(CapabilityExtent(width: width, height: height))
        let realizationExtent = try XCTUnwrap(CapabilityExtent(
            width: width,
            height: realizationExtentHeight ?? height
        ))
        let surfaceExtent = try XCTUnwrap(CapabilityExtent(
            width: width,
            height: surfaceExtentHeight ?? height
        ))
        let encodingSet: CanonicalPixelEncodingSet = encoding == .rgb565BigEndian
            ? .rgb565BigEndian
            : .rgba8888
        let raster = rasterCeilings ?? (ceiling, ceiling, ceiling)
        let payload = payloadCeilings ?? (ceiling, ceiling, ceiling)
        let inFlight = inFlightCeilings ?? (ceiling, ceiling, ceiling)
        let requirement = try XCTUnwrap(RasterPresentationRequirement(
            operations: allOperations,
            extent: extent,
            operationStream: .synchronousBorrowedOneShot,
            acceptedEncodings: encodingSet,
            acceptedSubmissionLifetimes: .synchronousBorrow,
            maximumRasterBytes: .init(rawValue: raster.0),
            maximumPayloadBytes: .init(rawValue: payload.0),
            maximumInFlightBytes: .init(rawValue: inFlight.0),
            absence: .required
        ))
        let realization = try XCTUnwrap(RasterRealizationContribution(
            kind: kind,
            operations: allOperations,
            operationStream: .synchronousBorrowedOneShot,
            encodings: encodingSet,
            producedSubmissionLifetimes: .synchronousBorrow,
            maximumExtent: realizationExtent,
            maximumRegionWidth: realizationRegionWidth ?? width,
            maximumRegionHeight: realizationRegionHeight,
            rowByteAlignment: realizationAlignment,
            maximumRasterBytes: .init(rawValue: raster.1),
            maximumPayloadBytes: .init(rawValue: payload.1)
        ))
        let surface = try XCTUnwrap(SurfaceDisplayContribution(
            extent: surfaceExtent,
            encodings: encodingSet,
            acceptedSubmissionLifetimes: .synchronousBorrow,
            handoffs: .synchronous,
            maximumRegionWidth: surfaceRegionWidth ?? width,
            maximumRegionHeight: surfaceRegionHeight,
            rowByteAlignment: surfaceAlignment,
            maximumInFlightCount: 1,
            maximumInFlightBytes: .init(rawValue: inFlight.1)
        ))
        let policy = try XCTUnwrap(RasterPresentationPolicy(
            maximumRasterBytes: .init(rawValue: raster.2),
            maximumPayloadBytes: .init(rawValue: payload.2),
            maximumInFlightBytes: .init(rawValue: inFlight.2),
            allowedRealizations: kind == .fullSurface ? .fullSurface : .tiled,
            allowedEncodings: encodingSet,
            preferredRealization: kind,
            preferredEncoding: encodingSet
        ))
        return RasterPresentationArithmetic.evaluate(
            requirement: requirement,
            realization: realization,
            surface: surface,
            policy: policy,
            encoding: encoding
        )
    }

    private func boundaryArithmetic(
        rasterCeilings: (UInt32, UInt32, UInt32)? = nil,
        payloadCeilings: (UInt32, UInt32, UInt32)? = nil,
        inFlightCeilings: (UInt32, UInt32, UInt32)? = nil
    ) throws -> RasterPresentationArithmeticOutcome {
        try evaluateArithmetic(
            width: 4,
            height: 2,
            kind: .fullSurface,
            encoding: .rgb565BigEndian,
            realizationRegionHeight: 2,
            surfaceRegionHeight: 2,
            realizationAlignment: 1,
            surfaceAlignment: 1,
            rasterCeilings: rasterCeilings,
            payloadCeilings: payloadCeilings,
            inFlightCeilings: inFlightCeilings
        )
    }

    private func assertArithmeticUsageAvailable(
        rasterCeilings: (UInt32, UInt32, UInt32)? = nil,
        payloadCeilings: (UInt32, UInt32, UInt32)? = nil,
        inFlightCeilings: (UInt32, UInt32, UInt32)? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        guard case let .available(value) = try boundaryArithmetic(
            rasterCeilings: rasterCeilings,
            payloadCeilings: payloadCeilings,
            inFlightCeilings: inFlightCeilings
        ) else {
            return XCTFail("boundary equality must remain available", file: file, line: line)
        }
        XCTAssertEqual(value.requiredRasterBytes.rawValue, 16, file: file, line: line)
    }

    private func makeExtent() throws -> CapabilityExtent {
        try XCTUnwrap(CapabilityExtent(width: 480, height: 320))
    }

    private func makeRequirement(
        operations: RasterOperationSet? = nil,
        operationStream: OperationStreamLifetime = .synchronousBorrowedOneShot,
        encodings: CanonicalPixelEncodingSet = .rgb565BigEndian,
        lifetimes: SubmissionLifetimeSet = .synchronousBorrow,
        byteCeiling: UInt32 = 1
    ) -> RasterPresentationRequirement? {
        guard let extent = CapabilityExtent(width: 480, height: 320) else { return nil }
        return RasterPresentationRequirement(
            operations: operations ?? allOperations,
            extent: extent,
            operationStream: operationStream,
            acceptedEncodings: encodings,
            acceptedSubmissionLifetimes: lifetimes,
            maximumRasterBytes: .init(rawValue: byteCeiling),
            maximumPayloadBytes: .init(rawValue: byteCeiling),
            maximumInFlightBytes: .init(rawValue: byteCeiling),
            absence: .required
        )
    }

    private func makeRealization(
        kind: RasterRealizationKind,
        operations: RasterOperationSet? = nil,
        operationStream: OperationStreamLifetime = .synchronousBorrowedOneShot,
        encodings: CanonicalPixelEncodingSet = .rgb565BigEndian,
        lifetimes: SubmissionLifetimeSet = .synchronousBorrow,
        regionWidth: UInt16 = 480,
        regionHeight: UInt16 = 4,
        alignment: UInt16 = 2,
        rasterBytes: UInt32 = 3_840,
        payloadBytes: UInt32 = 3_840
    ) -> RasterRealizationContribution? {
        guard let extent = CapabilityExtent(width: 480, height: 320) else { return nil }
        return RasterRealizationContribution(
            kind: kind, operations: operations ?? allOperations,
            operationStream: operationStream,
            encodings: encodings,
            producedSubmissionLifetimes: lifetimes,
            maximumExtent: extent,
            maximumRegionWidth: regionWidth,
            maximumRegionHeight: regionHeight,
            rowByteAlignment: alignment,
            maximumRasterBytes: .init(rawValue: rasterBytes),
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
        handoffs: SubmissionHandoffSet = .synchronous,
        inFlightBytes: UInt32 = 3_840
    ) -> SurfaceDisplayContribution? {
        SurfaceDisplayContribution(
            extent: extent, encodings: encodings,
            acceptedSubmissionLifetimes: lifetimes,
            handoffs: handoffs,
            maximumRegionWidth: regionWidth,
            maximumRegionHeight: regionHeight,
            rowByteAlignment: alignment,
            maximumInFlightCount: inFlightCount,
            maximumInFlightBytes: .init(rawValue: inFlightBytes)
        )
    }

    private func makePolicy(
        realizations: RasterRealizationKindSet = .tiled,
        encodings: CanonicalPixelEncodingSet = .rgb565BigEndian,
        preferredRealization: RasterRealizationKind = .tiled,
        preferredEncoding: CanonicalPixelEncodingSet = .rgb565BigEndian,
        byteCeiling: UInt32 = 3_840
    ) -> RasterPresentationPolicy? {
        RasterPresentationPolicy(
            maximumRasterBytes: .init(rawValue: byteCeiling),
            maximumPayloadBytes: .init(rawValue: byteCeiling),
            maximumInFlightBytes: .init(rawValue: byteCeiling),
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

    private func makeSurfaceValue(
        encodings: CanonicalPixelEncodingSet = .rgb565BigEndian,
        lifetimes: SubmissionLifetimeSet = .synchronousBorrow,
        handoffs: SubmissionHandoffSet = .synchronous,
        inFlightBytes: UInt32 = 3_840
    ) throws -> SurfaceDisplayContribution {
        try XCTUnwrap(makeSurface(
            extent: try makeExtent(),
            encodings: encodings,
            lifetimes: lifetimes,
            handoffs: handoffs,
            inFlightBytes: inFlightBytes
        ))
    }

    private func evaluateCompatibility(
        realization: RasterRealizationContribution,
        surface: SurfaceDisplayContribution? = nil,
        requirementEncodings: CanonicalPixelEncodingSet = .rgb565BigEndian,
        requirementLifetimes: SubmissionLifetimeSet = .synchronousBorrow,
        requirementByteCeiling: UInt32 = 3_840,
        policy: RasterPresentationPolicy? = nil
    ) throws -> RasterPresentationCandidateOutcome {
        RasterPresentationCompatibility.evaluateCandidate(
            requirement: try XCTUnwrap(makeRequirement(
                encodings: requirementEncodings,
                lifetimes: requirementLifetimes,
                byteCeiling: requirementByteCeiling
            )),
            realization: realization,
            surface: try surface ?? makeSurfaceValue(
                encodings: requirementEncodings,
                lifetimes: requirementLifetimes,
                inFlightBytes: requirementByteCeiling
            ),
            policy: try policy ?? XCTUnwrap(makePolicy(
                encodings: requirementEncodings,
                preferredEncoding: requirementEncodings == .rgba8888
                    ? .rgba8888
                    : .rgb565BigEndian,
                byteCeiling: requirementByteCeiling
            ))
        )
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
