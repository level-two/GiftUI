import GiftUI
import GiftUIFailureCore
import XCTest

private enum FoundationFailureAdapter {
    static func size(
        width: GeometryScalar,
        height: GeometryScalar
    ) -> GiftUIOutcome<Size> {
        guard let value = Size(width: width, height: height) else {
            return .failure(invalidValueFact)
        }
        return .success(value)
    }

    static func proposedSize(
        width: GeometryScalar?,
        height: GeometryScalar?
    ) -> GiftUIOutcome<ProposedSize> {
        guard let value = ProposedSize(width: width, height: height) else {
            return .failure(invalidValueFact)
        }
        return .success(value)
    }

    static func adding(
        _ lhs: GeometryScalar,
        _ rhs: GeometryScalar
    ) -> GiftUIOutcome<GeometryScalar> {
        guard let value = GeometryArithmetic.add(lhs, rhs) else {
            return .failure(arithmeticOverflowFact)
        }
        return .success(value)
    }

    static func rect(
        origin: Point,
        size: Size
    ) -> GiftUIOutcome<Rect> {
        guard let value = Rect(origin: origin, size: size) else {
            return .failure(arithmeticOverflowFact)
        }
        return .success(value)
    }

    static func logicalCoordinate(
        from physicalCoordinate: Int64
    ) -> GiftUIOutcome<GeometryScalar> {
        guard let value = GeometryScalar(exactly: physicalCoordinate) else {
            return .failure(arithmeticOverflowFact)
        }
        return .success(value)
    }

    private static let invalidValueFact = GiftUIFailureFact(
        condition: .invalidValue,
        origin: .foundation,
        affectedScope: .operation,
        containment: .contained
    )

    private static let arithmeticOverflowFact = GiftUIFailureFact(
        condition: .arithmeticOverflow,
        origin: .foundation,
        affectedScope: .operation,
        containment: .contained
    )
}

final class GiftUIFoundationFailureAdapterTests: XCTestCase {
    func testNegativeDimensionsAndInvalidProposalsMapToInvalidValue() {
        assertFailure(
            FoundationFailureAdapter.size(width: -1, height: 4),
            condition: .invalidValue
        )
        assertFailure(
            FoundationFailureAdapter.size(width: 4, height: -1),
            condition: .invalidValue
        )
        assertFailure(
            FoundationFailureAdapter.proposedSize(width: -1, height: nil),
            condition: .invalidValue
        )
        assertFailure(
            FoundationFailureAdapter.proposedSize(width: nil, height: -1),
            condition: .invalidValue
        )
    }

    func testScalarOverflowMapsToArithmeticOverflowWithoutPartialValue() {
        assertFailure(
            FoundationFailureAdapter.adding(.max, 1),
            condition: .arithmeticOverflow
        )
        assertFailure(
            FoundationFailureAdapter.adding(.min, -1),
            condition: .arithmeticOverflow
        )
    }

    func testUnrepresentableRectangleEdgeMapsToArithmeticOverflow() throws {
        let size = try XCTUnwrap(Size(width: 1, height: 1))

        assertFailure(
            FoundationFailureAdapter.rect(
                origin: Point(x: .max, y: 0),
                size: size
            ),
            condition: .arithmeticOverflow
        )
        assertFailure(
            FoundationFailureAdapter.rect(
                origin: Point(x: 0, y: .max),
                size: size
            ),
            condition: .arithmeticOverflow
        )
    }

    func testOutOfRangePhysicalCoordinatesMapToArithmeticOverflow() {
        assertFailure(
            FoundationFailureAdapter.logicalCoordinate(
                from: Int64(GeometryScalar.max) + 1
            ),
            condition: .arithmeticOverflow
        )
        assertFailure(
            FoundationFailureAdapter.logicalCoordinate(
                from: Int64(GeometryScalar.min) - 1
            ),
            condition: .arithmeticOverflow
        )
    }

    func testValidControlsPreserveCompleteValues() throws {
        let size = try unwrapSuccess(
            FoundationFailureAdapter.size(width: 4, height: 5)
        )
        XCTAssertEqual(size, Size(width: 4, height: 5))

        let proposal = try unwrapSuccess(
            FoundationFailureAdapter.proposedSize(width: nil, height: 5)
        )
        XCTAssertNil(proposal.width)
        XCTAssertEqual(proposal.height, 5)

        XCTAssertEqual(
            try unwrapSuccess(FoundationFailureAdapter.adding(20, 22)),
            42
        )
        XCTAssertEqual(
            try unwrapSuccess(
                FoundationFailureAdapter.logicalCoordinate(from: 42)
            ),
            42
        )

        let rect = try unwrapSuccess(
            FoundationFailureAdapter.rect(
                origin: Point(x: -2, y: 3),
                size: size
            )
        )
        XCTAssertEqual(rect.maxX, 2)
        XCTAssertEqual(rect.maxY, 8)
    }

    private func assertFailure<Success>(
        _ outcome: GiftUIOutcome<Success>,
        condition: GiftUIConditionID,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .failure(let fact) = outcome else {
            return XCTFail("expected failure with no partial value", file: file, line: line)
        }
        XCTAssertEqual(fact.condition, condition, file: file, line: line)
        XCTAssertEqual(fact.origin, .foundation, file: file, line: line)
        XCTAssertEqual(fact.affectedScope, .operation, file: file, line: line)
        XCTAssertEqual(fact.containment, .contained, file: file, line: line)
    }

    private func unwrapSuccess<Success>(
        _ outcome: GiftUIOutcome<Success>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Success {
        guard case .success(let value) = outcome else {
            XCTFail("expected complete success value", file: file, line: line)
            throw AdapterTestError.expectedSuccess
        }
        return value
    }
}

private enum AdapterTestError: Error {
    case expectedSuccess
}
