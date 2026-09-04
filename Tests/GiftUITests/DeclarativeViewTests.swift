import XCTest

@testable import GiftUI

final class DeclarativeViewTests: XCTestCase {
    func testActionCasesUseTheirExactUInt16Codes() {
        XCTAssertEqual(TestAction.minimum.rawValue, UInt16.min)
        XCTAssertEqual(TestAction.ordinary.rawValue, 17)
        XCTAssertEqual(TestAction.maximum.rawValue, UInt16.max)
    }

    func testOrdinaryViewUsesDefaultCustomTraversalWitness() {
        var visitor = CustomViewProbeVisitor(evaluateBody: true)

        RootView()._giftUITraverse(&visitor)

        XCTAssertEqual(visitor.customViewVisits, 1)
        XCTAssertEqual(visitor.bodyEvaluations, 1)
    }

    func testNeverConformanceDoesNotRequireBodyEvaluation() {
        var visitor = CustomViewProbeVisitor(evaluateBody: false)

        LeafView()._giftUITraverse(&visitor)

        XCTAssertEqual(visitor.customViewVisits, 1)
        XCTAssertEqual(visitor.bodyEvaluations, 0)
    }
}

private enum TestAction: UInt16, GiftUIAction {
    case minimum = 0
    case ordinary = 17
    case maximum = 65_535
}

private struct LeafView: View {
    var body: Never {
        fatalError("LeafView.body must remain unevaluated")
    }
}

private struct RootView: View {
    var body: some View {
        LeafView()
    }
}

private struct CustomViewProbeVisitor: _GiftUISemanticTraversalVisitor {
    let evaluateBody: Bool
    var customViewVisits = 0
    var bodyEvaluations = 0

    mutating func visitCustomView<Declaration: View>(
        _ declaration: borrowing Declaration,
        body: () -> Declaration.Body
    ) {
        customViewVisits += 1
        if evaluateBody {
            _ = body()
            bodyEvaluations += 1
        }
    }
}
