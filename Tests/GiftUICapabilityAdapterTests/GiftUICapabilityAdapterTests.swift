import GiftUI
import GiftUICapabilities
import XCTest

final class GiftUICapabilityAdapterTests: XCTestCase {
    func testSPEC002ExtentConversionDistinguishesMalformedFromOverflow() throws {
        XCTAssertEqual(
            FixtureCapabilityAdapter.extent(try XCTUnwrap(Size(width: 0, height: 1))),
            .unavailable(.malformedRequirement(field: .extent))
        )
        XCTAssertEqual(
            FixtureCapabilityAdapter.extent(try XCTUnwrap(Size(width: 1, height: 0))),
            .unavailable(.malformedRequirement(field: .extent))
        )
        XCTAssertEqual(
            FixtureCapabilityAdapter.extent(try XCTUnwrap(Size(width: 65_536, height: 1))),
            .unavailable(.logicalExtentOverflow)
        )
        XCTAssertEqual(
            FixtureCapabilityAdapter.extent(try XCTUnwrap(Size(width: 1, height: 65_536))),
            .unavailable(.logicalExtentOverflow)
        )
        XCTAssertEqual(
            FixtureCapabilityAdapter.extent(try XCTUnwrap(Size(width: 640, height: 480))),
            .value(try XCTUnwrap(CapabilityExtent(width: 640, height: 480)))
        )
    }

    func testRawRequirementUsesLowestMalformedFieldBeforeExtentConversion() throws {
        let validSize = try XCTUnwrap(Size(width: 480, height: 320))
        let zeroSize = try XCTUnwrap(Size(width: 0, height: 0))
        let overflowSize = try XCTUnwrap(Size(width: 65_536, height: 320))

        XCTAssertEqual(
            FixtureCapabilityAdapter.requirement(.init(
                operationBits: 0,
                encodingBits: 0,
                lifetimeBits: 0,
                size: overflowSize,
                maximumRasterBytes: -1,
                maximumPayloadBytes: -1,
                maximumInFlightBytes: -1
            )),
            .unavailable(.malformedRequirement(field: .operationSet))
        )
        XCTAssertEqual(
            FixtureCapabilityAdapter.requirement(.init(
                operationBits: 0x1f,
                encodingBits: 0,
                lifetimeBits: 0,
                size: zeroSize,
                maximumRasterBytes: -1,
                maximumPayloadBytes: -1,
                maximumInFlightBytes: -1
            )),
            .unavailable(.malformedRequirement(field: .encodingSet))
        )
        XCTAssertEqual(
            FixtureCapabilityAdapter.requirement(.init(
                operationBits: 0x1f,
                encodingBits: 1,
                lifetimeBits: 0,
                size: zeroSize,
                maximumRasterBytes: -1,
                maximumPayloadBytes: -1,
                maximumInFlightBytes: -1
            )),
            .unavailable(.malformedRequirement(field: .submissionLifetimeSet))
        )
        XCTAssertEqual(
            FixtureCapabilityAdapter.requirement(.init(
                operationBits: 0x1f,
                encodingBits: 1,
                lifetimeBits: 1,
                size: zeroSize,
                maximumRasterBytes: -1,
                maximumPayloadBytes: -1,
                maximumInFlightBytes: -1
            )),
            .unavailable(.malformedRequirement(field: .extent))
        )
        XCTAssertEqual(
            FixtureCapabilityAdapter.requirement(.init(
                operationBits: 0x1f,
                encodingBits: 1,
                lifetimeBits: 1,
                size: overflowSize,
                maximumRasterBytes: -1,
                maximumPayloadBytes: -1,
                maximumInFlightBytes: -1
            )),
            .unavailable(.logicalExtentOverflow)
        )
        XCTAssertEqual(
            FixtureCapabilityAdapter.requirement(.init(
                operationBits: 0x1f,
                encodingBits: 1,
                lifetimeBits: 1,
                size: validSize,
                maximumRasterBytes: -1,
                maximumPayloadBytes: 1,
                maximumInFlightBytes: 1
            )),
            .unavailable(.malformedRequirement(field: .byteCount))
        )
        XCTAssertEqual(
            FixtureCapabilityAdapter.requirement(.init(
                operationBits: 0x1f,
                encodingBits: 1,
                lifetimeBits: 1,
                size: validSize,
                maximumRasterBytes: Int64(UInt32.max) + 1,
                maximumPayloadBytes: 1,
                maximumInFlightBytes: 1
            )),
            .unavailable(.malformedRequirement(field: .byteCount))
        )

        let valid = FixtureCapabilityAdapter.requirement(.init(
            operationBits: 0x1f,
            encodingBits: 3,
            lifetimeBits: 7,
            size: validSize,
            maximumRasterBytes: 0,
            maximumPayloadBytes: 0,
            maximumInFlightBytes: 0
        ))
        guard case let .value(requirement) = valid else {
            return XCTFail("valid raw requirement was rejected: \(valid)")
        }
        XCTAssertEqual(requirement.extent, CapabilityExtent(width: 480, height: 320))
        XCTAssertEqual(requirement.maximumRasterBytes.rawValue, 0)
    }

    func testMalformedContributionSelectionUsesLowestRoleThenField() {
        let failures = RawContributionFailures(
            renderProducer: [.encodingSet, .operationSet],
            rasterBackend: [.alternateRealization],
            surfaceDisplay: [.region],
            hostResourcePolicy: [.policyPreference]
        )
        XCTAssertEqual(
            FixtureCapabilityAdapter.firstMalformedContribution(failures),
            .malformedContribution(role: .renderProducer, field: .operationSet)
        )
        XCTAssertEqual(
            FixtureCapabilityAdapter.firstMalformedContribution(.init(
                renderProducer: [],
                rasterBackend: [.rowByteAlignment, .region],
                surfaceDisplay: [.encodingSet],
                hostResourcePolicy: [.policyPreference]
            )),
            .malformedContribution(role: .rasterBackend, field: .region)
        )
        XCTAssertNil(FixtureCapabilityAdapter.firstMalformedContribution(.init()))
    }

    func testEveryMalformedFieldIsPreservedForEveryContributorRole() {
        let fields: [RasterPresentationMalformedField] = [
            .operationSet, .encodingSet, .submissionLifetimeSet, .handoffSet,
            .extent, .region, .rowByteAlignment, .inFlightCount, .byteCount,
            .alternateRealization, .policyPreference,
        ]
        for field in fields {
            let mask = MalformedFieldMask(arrayLiteral: field)
            XCTAssertEqual(
                FixtureCapabilityAdapter.firstMalformedContribution(.init(
                    renderProducer: mask
                )),
                .malformedContribution(role: .renderProducer, field: field)
            )
            XCTAssertEqual(
                FixtureCapabilityAdapter.firstMalformedContribution(.init(
                    rasterBackend: mask
                )),
                .malformedContribution(role: .rasterBackend, field: field)
            )
            XCTAssertEqual(
                FixtureCapabilityAdapter.firstMalformedContribution(.init(
                    surfaceDisplay: mask
                )),
                .malformedContribution(role: .surfaceDisplay, field: field)
            )
            XCTAssertEqual(
                FixtureCapabilityAdapter.firstMalformedContribution(.init(
                    hostResourcePolicy: mask
                )),
                .malformedContribution(role: .hostResourcePolicy, field: field)
            )
        }
    }
}

private enum AdapterResult<Value: Equatable>: Equatable {
    case value(Value)
    case unavailable(RasterPresentationUnavailable)
}

private struct RawRequirement {
    let operationBits: UInt8
    let encodingBits: UInt8
    let lifetimeBits: UInt8
    let size: Size
    let maximumRasterBytes: Int64
    let maximumPayloadBytes: Int64
    let maximumInFlightBytes: Int64
}

private struct MalformedFieldMask: ExpressibleByArrayLiteral {
    private let rawValue: UInt16

    init(arrayLiteral elements: RasterPresentationMalformedField...) {
        rawValue = elements.reduce(0) { $0 | (1 << ($1.rawValue - 1)) }
    }

    var lowestField: RasterPresentationMalformedField? {
        for rawValue in UInt8(1) ... UInt8(11) {
            if self.rawValue & (1 << (rawValue - 1)) != 0 {
                return RasterPresentationMalformedField(rawValue: rawValue)
            }
        }
        return nil
    }
}

private struct RawContributionFailures {
    let renderProducer: MalformedFieldMask
    let rasterBackend: MalformedFieldMask
    let surfaceDisplay: MalformedFieldMask
    let hostResourcePolicy: MalformedFieldMask

    init(
        renderProducer: MalformedFieldMask = [],
        rasterBackend: MalformedFieldMask = [],
        surfaceDisplay: MalformedFieldMask = [],
        hostResourcePolicy: MalformedFieldMask = []
    ) {
        self.renderProducer = renderProducer
        self.rasterBackend = rasterBackend
        self.surfaceDisplay = surfaceDisplay
        self.hostResourcePolicy = hostResourcePolicy
    }
}

private enum FixtureCapabilityAdapter {
    static func extent(_ size: Size) -> AdapterResult<CapabilityExtent> {
        guard size.width > 0, size.height > 0 else {
            return .unavailable(.malformedRequirement(field: .extent))
        }
        guard size.width <= UInt16.max, size.height <= UInt16.max else {
            return .unavailable(.logicalExtentOverflow)
        }
        guard let extent = CapabilityExtent(
            width: UInt16(size.width), height: UInt16(size.height)
        ) else {
            return .unavailable(.malformedRequirement(field: .extent))
        }
        return .value(extent)
    }

    static func requirement(
        _ raw: RawRequirement
    ) -> AdapterResult<RasterPresentationRequirement> {
        let operations = RasterOperationSet(rawValue: raw.operationBits)
        guard operations.rawValue == 0x1f else {
            return .unavailable(.malformedRequirement(field: .operationSet))
        }
        let encodings = CanonicalPixelEncodingSet(rawValue: raw.encodingBits)
        guard raw.encodingBits != 0, raw.encodingBits & ~0x03 == 0 else {
            return .unavailable(.malformedRequirement(field: .encodingSet))
        }
        let lifetimes = SubmissionLifetimeSet(rawValue: raw.lifetimeBits)
        guard raw.lifetimeBits != 0, raw.lifetimeBits & ~0x07 == 0 else {
            return .unavailable(.malformedRequirement(field: .submissionLifetimeSet))
        }
        let extent: CapabilityExtent
        switch self.extent(raw.size) {
        case let .value(value): extent = value
        case let .unavailable(reason): return .unavailable(reason)
        }
        guard let rasterBytes = byteCount(raw.maximumRasterBytes),
              let payloadBytes = byteCount(raw.maximumPayloadBytes),
              let inFlightBytes = byteCount(raw.maximumInFlightBytes) else {
            return .unavailable(.malformedRequirement(field: .byteCount))
        }
        guard let requirement = RasterPresentationRequirement(
            operations: operations,
            extent: extent,
            operationStream: .synchronousBorrowedOneShot,
            acceptedEncodings: encodings,
            acceptedSubmissionLifetimes: lifetimes,
            maximumRasterBytes: rasterBytes,
            maximumPayloadBytes: payloadBytes,
            maximumInFlightBytes: inFlightBytes,
            absence: .required
        ) else {
            return .unavailable(.malformedRequirement(field: .operationSet))
        }
        return .value(requirement)
    }

    static func firstMalformedContribution(
        _ failures: RawContributionFailures
    ) -> RasterPresentationUnavailable? {
        if let field = failures.renderProducer.lowestField {
            return .malformedContribution(role: .renderProducer, field: field)
        }
        if let field = failures.rasterBackend.lowestField {
            return .malformedContribution(role: .rasterBackend, field: field)
        }
        if let field = failures.surfaceDisplay.lowestField {
            return .malformedContribution(role: .surfaceDisplay, field: field)
        }
        if let field = failures.hostResourcePolicy.lowestField {
            return .malformedContribution(role: .hostResourcePolicy, field: field)
        }
        return nil
    }

    private static func byteCount(_ rawValue: Int64) -> CapabilityByteCount? {
        guard rawValue >= 0, rawValue <= UInt32.max else { return nil }
        return CapabilityByteCount(rawValue: UInt32(rawValue))
    }
}
