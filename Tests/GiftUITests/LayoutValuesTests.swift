import GiftUI
import XCTest

final class LayoutValuesTests: XCTestCase {
    func testAlignmentRawValuesAndConstantsAreExact() {
        XCTAssertEqual(HorizontalAlignment.leading.rawValue, 0)
        XCTAssertEqual(HorizontalAlignment.center.rawValue, 1)
        XCTAssertEqual(VerticalAlignment.top.rawValue, 0)
        XCTAssertEqual(VerticalAlignment.center.rawValue, 1)
        XCTAssertEqual(VerticalAlignment.bottom.rawValue, 2)

        XCTAssertEqual(
            Alignment.center,
            Alignment(horizontal: .center, vertical: .center)
        )
        XCTAssertEqual(
            Alignment.leading,
            Alignment(horizontal: .leading, vertical: .center)
        )
    }

    func testEdgeInsetsAcceptOnlyNonnegativeFields() throws {
        let insets = try XCTUnwrap(
            EdgeInsets(top: 0, leading: 1, bottom: .max, trailing: 2)
        )
        XCTAssertEqual(insets.top, 0)
        XCTAssertEqual(insets.leading, 1)
        XCTAssertEqual(insets.bottom, .max)
        XCTAssertEqual(insets.trailing, 2)

        XCTAssertNil(EdgeInsets(top: -1, leading: 0, bottom: 0, trailing: 0))
        XCTAssertNil(EdgeInsets(top: 0, leading: -1, bottom: 0, trailing: 0))
        XCTAssertNil(EdgeInsets(top: 0, leading: 0, bottom: -1, trailing: 0))
        XCTAssertNil(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -1))
    }

    func testEdgeSetsUseExactBitsAndPreserveReservedBits() {
        XCTAssertEqual(EdgeSet.top.rawValue, 1 << 0)
        XCTAssertEqual(EdgeSet.leading.rawValue, 1 << 1)
        XCTAssertEqual(EdgeSet.bottom.rawValue, 1 << 2)
        XCTAssertEqual(EdgeSet.trailing.rawValue, 1 << 3)
        XCTAssertEqual(EdgeSet.horizontal, [.leading, .trailing])
        XCTAssertEqual(EdgeSet.vertical, [.top, .bottom])
        XCTAssertEqual(EdgeSet.all, [.top, .leading, .bottom, .trailing])
        XCTAssertEqual(EdgeSet().rawValue, 0)

        for bit in 4 ... 7 {
            let reserved = EdgeSet(rawValue: 1 << bit)
            XCTAssertEqual(reserved.rawValue, 1 << bit)
            XCTAssertFalse(reserved.isEmpty)
        }
    }

    func testFrameLimitPreservesFiniteAndInvalidValues() {
        XCTAssertEqual(FrameLimit.points(0), .points(0))
        XCTAssertEqual(FrameLimit.points(.max), .points(.max))
        XCTAssertEqual(FrameLimit.points(-1), .points(-1))
        XCTAssertEqual(FrameLimit.points(.min), .points(.min))
        XCTAssertEqual(FrameLimit.infinity, .infinity)
    }
}
