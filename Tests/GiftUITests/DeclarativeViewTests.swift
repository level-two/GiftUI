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

    func testBuilderLowersZeroAndOneChildWithoutAWrapperForOne() {
        let empty: EmptyView = ViewBuilder.buildBlock()
        let leaf = LeafView()
        let unchanged: LeafView = ViewBuilder.buildBlock(leaf)

        XCTAssertEqual(MemoryLayout.size(ofValue: empty), 0)
        XCTAssertEqual(MemoryLayout.size(ofValue: unchanged), MemoryLayout<LeafView>.size)
    }

    func testConditionalTraversalObservesOnlyTheSelectedBranch() {
        let first: ConditionalContent<LeafView, InactiveLeaf> =
            ViewBuilder.buildEither(first: LeafView())
        let second: ConditionalContent<InactiveLeaf, LeafView> =
            ViewBuilder.buildEither(second: LeafView())
        var visitor = CustomViewProbeVisitor(evaluateBody: false)

        first._giftUITraverse(&visitor)
        second._giftUITraverse(&visitor)

        XCTAssertEqual(visitor.firstBranchVisits, 1)
        XCTAssertEqual(visitor.secondBranchVisits, 1)
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

private struct InactiveLeaf: View {
    init() {
        fatalError("an inactive generic branch must not be instantiated")
    }

    var body: Never {
        fatalError("an inactive generic branch must not be evaluated")
    }
}

private struct CustomViewProbeVisitor: _GiftUISemanticTraversalVisitor {
    let evaluateBody: Bool
    var customViewVisits = 0
    var bodyEvaluations = 0
    var firstBranchVisits = 0
    var secondBranchVisits = 0

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
    ) {
        firstBranchVisits += 1
    }

    mutating func visitConditionalSecond<First: View, Second: View>(
        first: First.Type,
        _ content: borrowing Second
    ) {
        secondBranchVisits += 1
    }

    mutating func visitOptionalAbsent<Content: View>(_ content: Content.Type) {}

    mutating func visitOptionalPresent<Content: View>(
        _ content: borrowing Content
    ) {}
}
