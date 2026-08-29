import XCTest
@testable import GiftUI

final class GiftUITests: XCTestCase {
    func testGeometryScalarAndValueLayoutsAreBounded() {
        XCTAssertEqual(MemoryLayout<GeometryScalar>.size, 4)
        XCTAssertLessThanOrEqual(MemoryLayout<Point>.size, 8)
        XCTAssertLessThanOrEqual(MemoryLayout<Size>.size, 8)
        XCTAssertLessThanOrEqual(MemoryLayout<Rect>.size, 16)
        XCTAssertLessThanOrEqual(MemoryLayout<ProposedSize>.size, 16)
    }

    func testPointIsAnImmutableCopyableValue() {
        let original = Point(x: .min, y: .max)
        let copy = original

        XCTAssertEqual(copy, original)
        XCTAssertEqual(copy.x, .min)
        XCTAssertEqual(copy.y, .max)
        XCTAssertEqual(Set([original, copy]).count, 1)
    }

    func testSizeAcceptsZeroAndRejectsEitherNegativeDimension() {
        XCTAssertEqual(Size(width: 0, height: 0), Size(width: 0, height: 0))
        XCTAssertEqual(Size(width: .max, height: .max)?.width, .max)
        XCTAssertNil(Size(width: -1, height: 0))
        XCTAssertNil(Size(width: 0, height: -1))
        XCTAssertNil(Size(width: .min, height: .min))
    }

    func testProposedSizePreservesIndependentAbsence() {
        let absent = ProposedSize()
        let widthOnly = ProposedSize(width: 12)
        let heightOnly = ProposedSize(height: 34)

        XCTAssertNotNil(absent)
        XCTAssertNil(absent?.width)
        XCTAssertNil(absent?.height)
        XCTAssertEqual(widthOnly?.width, 12)
        XCTAssertNil(widthOnly?.height)
        XCTAssertNil(heightOnly?.width)
        XCTAssertEqual(heightOnly?.height, 34)
        XCTAssertNotNil(ProposedSize(width: 0, height: 0))
        XCTAssertNil(ProposedSize(width: -1))
        XCTAssertNil(ProposedSize(height: -1))
    }

    func testCheckedAdditionBoundaries() {
        let cases: [(GeometryScalar, GeometryScalar, GeometryScalar?)] = [
            (0, 0, 0),
            (7, 5, 12),
            (-7, 5, -2),
            (.min, 0, .min),
            (.max, 0, .max),
            (.max, 1, nil),
            (1, .max, nil),
            (.min, -1, nil),
            (-1, .min, nil),
            (.max, .max, nil),
            (.min, .min, nil),
        ]

        for (lhs, rhs, expected) in cases {
            XCTAssertEqual(GeometryArithmetic.add(lhs, rhs), expected)
        }
    }

    func testCheckedSubtractionBoundaries() {
        let cases: [(GeometryScalar, GeometryScalar, GeometryScalar?)] = [
            (0, 0, 0),
            (7, 5, 2),
            (-7, 5, -12),
            (.min, 0, .min),
            (.max, 0, .max),
            (.max, -1, nil),
            (.min, 1, nil),
            (0, .min, nil),
            (-1, .max, .min),
        ]

        for (lhs, rhs, expected) in cases {
            XCTAssertEqual(GeometryArithmetic.subtract(lhs, rhs), expected)
        }
    }

    func testCheckedMultiplicationBoundaries() {
        let cases: [(GeometryScalar, GeometryScalar, GeometryScalar?)] = [
            (0, 0, 0),
            (0, .max, 0),
            (.min, 0, 0),
            (7, 5, 35),
            (-7, 5, -35),
            (.max, 1, .max),
            (.min, 1, .min),
            (.max, 2, nil),
            (2, .max, nil),
            (.min, 2, nil),
            (2, .min, nil),
            (.min, -1, nil),
            (-1, .min, nil),
            (.max, -1, -.max),
        ]

        for (lhs, rhs, expected) in cases {
            XCTAssertEqual(GeometryArithmetic.multiply(lhs, rhs), expected)
        }
    }

    func testRectPublishesExactTotalEdges() throws {
        let size = try XCTUnwrap(Size(width: 30, height: 40))
        let rect = try XCTUnwrap(Rect(origin: Point(x: -10, y: 20), size: size))

        XCTAssertEqual(rect.minX, -10)
        XCTAssertEqual(rect.minY, 20)
        XCTAssertEqual(rect.maxX, 20)
        XCTAssertEqual(rect.maxY, 60)
    }

    func testRectAcceptsMaximumValidExtentsAndBothScalarLimits() throws {
        let maximum = try XCTUnwrap(Rect(
            origin: Point(x: 0, y: 0),
            size: try XCTUnwrap(Size(width: .max, height: .max))
        ))
        XCTAssertEqual(maximum.maxX, .max)
        XCTAssertEqual(maximum.maxY, .max)

        let fromMinimum = try XCTUnwrap(Rect(
            origin: Point(x: .min, y: .min),
            size: try XCTUnwrap(Size(width: .max, height: .max))
        ))
        XCTAssertEqual(fromMinimum.maxX, -1)
        XCTAssertEqual(fromMinimum.maxY, -1)

        let zeroAtMaximum = try XCTUnwrap(Rect(
            origin: Point(x: .max, y: .max),
            size: try XCTUnwrap(Size(width: 0, height: 0))
        ))
        XCTAssertEqual(zeroAtMaximum.maxX, .max)
        XCTAssertEqual(zeroAtMaximum.maxY, .max)
    }

    func testRectRejectsEitherUnrepresentableExclusiveEdge() throws {
        let widthOverflow = Rect(
            origin: Point(x: .max, y: 0),
            size: try XCTUnwrap(Size(width: 1, height: 0))
        )
        let heightOverflow = Rect(
            origin: Point(x: 0, y: .max),
            size: try XCTUnwrap(Size(width: 0, height: 1))
        )

        XCTAssertNil(widthOverflow)
        XCTAssertNil(heightOverflow)
    }

    func testRectContainsUsesHalfOpenEdges() throws {
        let rect = try XCTUnwrap(Rect(
            origin: Point(x: -2, y: -3),
            size: try XCTUnwrap(Size(width: 4, height: 6))
        ))

        XCTAssertTrue(rect.contains(Point(x: -2, y: -3)))
        XCTAssertTrue(rect.contains(Point(x: 1, y: 2)))
        XCTAssertFalse(rect.contains(Point(x: 2, y: 2)))
        XCTAssertFalse(rect.contains(Point(x: 1, y: 3)))
        XCTAssertFalse(rect.contains(Point(x: -3, y: 0)))
    }

    func testEmptyRectContainsNoPoint() throws {
        let emptyWidth = try XCTUnwrap(Rect(
            origin: Point(x: 4, y: 5),
            size: try XCTUnwrap(Size(width: 0, height: 10))
        ))
        let emptyHeight = try XCTUnwrap(Rect(
            origin: Point(x: 4, y: 5),
            size: try XCTUnwrap(Size(width: 10, height: 0))
        ))

        XCTAssertFalse(emptyWidth.contains(Point(x: 4, y: 5)))
        XCTAssertFalse(emptyHeight.contains(Point(x: 4, y: 5)))
    }

    func testNormalizedPointerEventRequiresBoundedProvenance() {
        let event = NormalizedPointerEvent(
            phase: .down,
            position: Point(x: -12, y: 34),
            source: InputSourceID(rawValue: 1),
            sequence: PointerSequenceID(rawValue: 2),
            ordinal: InputOrdinal(rawValue: 3),
            presentationRevision: PresentationRevision(rawValue: 4)
        )

        XCTAssertEqual(event.phase, .down)
        XCTAssertEqual(event.position, Point(x: -12, y: 34))
        XCTAssertEqual(event.source.rawValue, 1)
        XCTAssertEqual(event.sequence.rawValue, 2)
        XCTAssertEqual(event.ordinal.rawValue, 3)
        XCTAssertEqual(event.presentationRevision.rawValue, 4)
    }
}
