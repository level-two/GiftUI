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

    mutating func visitEmpty() {}

    mutating func visitFixed<A: View, B: View>(
        _ a: borrowing A,
        _ b: borrowing B
    ) {}

    mutating func visitFixed<A: View, B: View, C: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C
    ) {}

    mutating func visitFixed<A: View, B: View, C: View, D: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D
    ) {}

    mutating func visitFixed<A: View, B: View, C: View, D: View, E: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D,
        _ e: borrowing E
    ) {}

    mutating func visitConditionalFirst<First: View, Second: View>(
        _ content: borrowing First,
        second: Second.Type
    ) {}

    mutating func visitConditionalSecond<First: View, Second: View>(
        first: First.Type,
        _ content: borrowing Second
    ) {}

    mutating func visitOptionalAbsent<Content: View>(_ content: Content.Type) {}

    mutating func visitOptionalPresent<Content: View>(
        _ content: borrowing Content
    ) {}
}
