import GiftUICapabilities
import GiftUIFailureCore
import XCTest

@testable import GiftUICapabilityFailureAdapterFixture

final class CapabilityFailureAdapterTests: XCTestCase {
    func testCapabilityConditionNamesUseExactRawValuesAndLeaveElevenUnnamed() {
        let conditions: [GiftUIConditionID] = [
            .rasterMalformedRequirement,
            .rasterDuplicateContributor,
            .rasterMissingContributor,
            .rasterMalformedContribution,
            .rasterInsufficientCapacity,
            .rasterOperationSetMismatch,
            .rasterOperationStreamMismatch,
            .rasterLogicalExtentOverflow,
            .rasterUnsupportedLogicalExtent,
            .rasterNoCommonCanonicalPixelEncoding,
            .rasterIncompatibleSubmissionLifetime,
            .rasterIncompatibleSubmissionHandoff,
            .rasterPolicyHasNoConformingRealization,
            .rasterByteCountOverflow,
        ]
        XCTAssertEqual(conditions.map(\.rawValue), Array(UInt16(12) ... 25))
        XCTAssertFalse(conditions.contains(GiftUIConditionID(rawValue: 11)))
        XCTAssertEqual(GiftUIConditionID.invariantViolation.rawValue, 10)
    }

    func testEveryUnavailableFamilyMapsToExactFailureEnvelope() {
        for (unavailable, condition) in cases {
            XCTAssertEqual(
                CapabilityFailureAdapter.requiredFamilyFailure(unavailable),
                .failure(
                    GiftUIFailureFact(
                        condition: condition,
                        origin: .capability,
                        affectedScope: .runtime,
                        containment: .contained
                    ))
            )
            XCTAssertNotEqual(condition, .requiredFacilityUnavailable)
        }
    }

    func testAssociatedPayloadsCannotChangePrimaryConditionIdentity() {
        let count = CapabilityByteCount(rawValue: 9)
        let available = CapabilityByteCount(rawValue: 3)
        for field in malformedFields {
            XCTAssertEqual(
                CapabilityFailureAdapter.condition(
                    for: .malformedRequirement(field: field)
                ),
                .rasterMalformedRequirement
            )
            for role in roles {
                XCTAssertEqual(
                    CapabilityFailureAdapter.condition(
                        for: .malformedContribution(
                            role: role,
                            field: field
                        )),
                    .rasterMalformedContribution
                )
            }
        }
        for role in roles {
            XCTAssertEqual(
                CapabilityFailureAdapter.condition(for: .duplicateContributor(role: role)),
                .rasterDuplicateContributor
            )
            XCTAssertEqual(
                CapabilityFailureAdapter.condition(for: .missingContributor(role: role)),
                .rasterMissingContributor
            )
        }
        for capacity in capacities {
            XCTAssertEqual(
                CapabilityFailureAdapter.condition(
                    for: .insufficientCapacity(
                        domain: capacity,
                        required: count,
                        available: available
                    )),
                .rasterInsufficientCapacity
            )
            XCTAssertEqual(
                CapabilityFailureAdapter.condition(
                    for: .byteCountOverflow(domain: capacity)
                ),
                .rasterByteCountOverflow
            )
        }
    }

    func testRuntimeFaultFactsCannotMutateAnExistingSnapshot() throws {
        let snapshot = try makeAvailableSnapshot()
        let before = snapshot
        let injectedFacts = [
            GiftUIFailureFact(
                condition: .nonRetryableRefusal,
                origin: .backend,
                affectedScope: .runtime,
                containment: .contained
            ),
            GiftUIFailureFact(
                condition: .requiredFacilityUnavailable,
                origin: .displayDriver,
                affectedScope: .runtime,
                containment: .contained
            ),
            GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .transport,
                affectedScope: .runtime,
                containment: .safetyNotProven
            ),
        ]
        for fact in injectedFacts {
            let outcome = GiftUIOutcome<CapabilitySnapshot>.failure(fact)
            guard case .failure = outcome else { return XCTFail("expected failure") }
            XCTAssertEqual(snapshot, before)
        }
    }

    private var cases: [(RasterPresentationUnavailable, GiftUIConditionID)] {
        let required = CapabilityByteCount(rawValue: 2)
        let available = CapabilityByteCount(rawValue: 1)
        return [
            (.malformedRequirement(field: .extent), .rasterMalformedRequirement),
            (.duplicateContributor(role: .renderProducer), .rasterDuplicateContributor),
            (.missingContributor(role: .rasterBackend), .rasterMissingContributor),
            (
                .malformedContribution(
                    role: .surfaceDisplay,
                    field: .rowByteAlignment
                ), .rasterMalformedContribution
            ),
            (
                .insufficientCapacity(
                    domain: .payload,
                    required: required,
                    available: available
                ), .rasterInsufficientCapacity
            ),
            (.operationSetMismatch, .rasterOperationSetMismatch),
            (.operationStreamMismatch, .rasterOperationStreamMismatch),
            (.logicalExtentOverflow, .rasterLogicalExtentOverflow),
            (.unsupportedLogicalExtent, .rasterUnsupportedLogicalExtent),
            (.noCommonCanonicalPixelEncoding, .rasterNoCommonCanonicalPixelEncoding),
            (.incompatibleSubmissionLifetime, .rasterIncompatibleSubmissionLifetime),
            (.incompatibleSubmissionHandoff, .rasterIncompatibleSubmissionHandoff),
            (.policyHasNoConformingRealization, .rasterPolicyHasNoConformingRealization),
            (.byteCountOverflow(domain: .raster), .rasterByteCountOverflow),
        ]
    }

    private var malformedFields: [RasterPresentationMalformedField] {
        [
            .operationSet, .encodingSet, .submissionLifetimeSet, .handoffSet,
            .extent, .region, .rowByteAlignment, .inFlightCount, .byteCount,
            .alternateRealization, .policyPreference,
        ]
    }

    private var roles: [RasterPresentationContributorRole] {
        [.renderProducer, .rasterBackend, .surfaceDisplay, .hostResourcePolicy]
    }

    private var capacities: [RasterPresentationCapacity] {
        [.resolverWorkspace, .raster, .payload, .inFlight]
    }

    private func makeAvailableSnapshot() throws -> CapabilitySnapshot {
        let operations: RasterOperationSet = [
            .opaqueRectangles, .positionedText, .straightLineStrokes,
            .clipping, .damage,
        ]
        let extent = try XCTUnwrap(CapabilityExtent(width: 4, height: 4))
        let requirement = try XCTUnwrap(
            RasterPresentationRequirement(
                operations: operations,
                extent: extent,
                operationStream: .synchronousBorrowedOneShot,
                acceptedEncodings: .rgb565BigEndian,
                acceptedSubmissionLifetimes: .synchronousBorrow,
                maximumRasterBytes: .init(rawValue: 16),
                maximumPayloadBytes: .init(rawValue: 16),
                maximumInFlightBytes: .init(rawValue: 16),
                absence: .required
            ))
        let producer = try XCTUnwrap(
            RenderProducerContribution(
                operations: operations,
                operationStream: .synchronousBorrowedOneShot
            ))
        let realization = try XCTUnwrap(
            RasterRealizationContribution(
                kind: .tiled,
                operations: operations,
                operationStream: .synchronousBorrowedOneShot,
                encodings: .rgb565BigEndian,
                producedSubmissionLifetimes: .synchronousBorrow,
                maximumExtent: extent,
                maximumRegionWidth: 4,
                maximumRegionHeight: 2,
                rowByteAlignment: 2,
                maximumRasterBytes: .init(rawValue: 16),
                maximumPayloadBytes: .init(rawValue: 16)
            ))
        let backend = try XCTUnwrap(
            RasterBackendContribution(
                primary: realization,
                alternate: nil
            ))
        let surface = try XCTUnwrap(
            SurfaceDisplayContribution(
                extent: extent,
                encodings: .rgb565BigEndian,
                acceptedSubmissionLifetimes: .synchronousBorrow,
                handoffs: .synchronous,
                maximumRegionWidth: 4,
                maximumRegionHeight: 2,
                rowByteAlignment: 2,
                maximumInFlightCount: 1,
                maximumInFlightBytes: .init(rawValue: 16)
            ))
        let policy = try XCTUnwrap(
            RasterPresentationPolicy(
                maximumRasterBytes: .init(rawValue: 16),
                maximumPayloadBytes: .init(rawValue: 16),
                maximumInFlightBytes: .init(rawValue: 16),
                allowedRealizations: .tiled,
                allowedEncodings: .rgb565BigEndian,
                preferredRealization: .tiled,
                preferredEncoding: .rgb565BigEndian
            ))
        var contributions = RasterPresentationContributions()
        XCTAssertEqual(contributions.insert(.renderProducer(producer)), .inserted)
        XCTAssertEqual(contributions.insert(.rasterBackend(backend)), .inserted)
        XCTAssertEqual(contributions.insert(.surfaceDisplay(surface)), .inserted)
        XCTAssertEqual(
            contributions.insert(.hostResourcePolicy(policy)),
            .inserted
        )
        var workspace = try XCTUnwrap(RasterPresentationResolverWorkspace())
        let resolution = RasterPresentationResolver.resolve(
            requirement: requirement,
            contributions: contributions,
            workspace: &workspace
        )
        guard case .available(let effective) = resolution else {
            throw SnapshotFixtureError.unavailable
        }
        return CapabilitySnapshot(rasterPresentation: effective)
    }

}

private enum SnapshotFixtureError: Error {
    case unavailable
}
