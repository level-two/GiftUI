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

    func testEveryStructuralWrapperUsesItsVisitorCategory() {
        var visitor = CustomViewProbeVisitor(evaluateBody: false)

        ViewBuilder.buildBlock()._giftUITraverse(&visitor)
        ViewBuilder.buildBlock(LeafView(), LeafView())._giftUITraverse(&visitor)
        ViewBuilder.buildBlock(LeafView(), LeafView(), LeafView())._giftUITraverse(&visitor)
        ViewBuilder.buildBlock(LeafView(), LeafView(), LeafView(), LeafView())
            ._giftUITraverse(&visitor)
        ViewBuilder.buildBlock(LeafView(), LeafView(), LeafView(), LeafView(), LeafView())
            ._giftUITraverse(&visitor)
        ViewBuilder.buildOptional(Optional<LeafView>.none)._giftUITraverse(&visitor)
        ViewBuilder.buildOptional(LeafView())._giftUITraverse(&visitor)

        XCTAssertEqual(visitor.emptyVisits, 1)
        XCTAssertEqual(visitor.fixedArities, [2, 3, 4, 5])
        XCTAssertEqual(visitor.optionalAbsentVisits, 1)
        XCTAssertEqual(visitor.optionalPresentVisits, 1)
    }

    func testTypedPayloadCategoriesRemainGeneric() {
        var visitor = CustomViewProbeVisitor(evaluateBody: false)

        visitor.visitPrimitive(TestPrimitivePayload())
        visitor.visitActionPrimitive(TestActionPayload(_giftUIAction: .ordinary))
        visitor.visitModifier(content: LeafView(), payload: TestModifierPayload())

        XCTAssertEqual(visitor.primitiveVisits, 1)
        XCTAssertEqual(visitor.actionPrimitiveVisits, 1)
        XCTAssertEqual(visitor.modifierVisits, 1)
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

private struct TestPrimitivePayload: _GiftUISemanticPrimitivePayload {}

private struct TestActionPayload: _GiftUISemanticActionPayload {
    let _giftUIAction: TestAction
}

private struct TestModifierPayload: _GiftUISemanticModifierPayload {}

private struct CustomViewProbeVisitor: _GiftUISemanticTraversalVisitor {
    let evaluateBody: Bool
    var customViewVisits = 0
    var bodyEvaluations = 0
    var firstBranchVisits = 0
    var secondBranchVisits = 0
    var emptyVisits = 0
    var fixedArities: [Int] = []
    var optionalAbsentVisits = 0
    var optionalPresentVisits = 0
    var primitiveVisits = 0
    var actionPrimitiveVisits = 0
    var modifierVisits = 0

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

    mutating func visitEmpty() {
        emptyVisits += 1
    }

    mutating func visitFixed<A: View, B: View>(
        _ a: borrowing A,
        _ b: borrowing B
    ) {
        fixedArities.append(2)
    }

    mutating func visitFixed<A: View, B: View, C: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C
    ) {
        fixedArities.append(3)
    }

    mutating func visitFixed<A: View, B: View, C: View, D: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D
    ) {
        fixedArities.append(4)
    }

    mutating func visitFixed<A: View, B: View, C: View, D: View, E: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D,
        _ e: borrowing E
    ) {
        fixedArities.append(5)
    }

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

    mutating func visitOptionalAbsent<Content: View>(_ content: Content.Type) {
        optionalAbsentVisits += 1
    }

    mutating func visitOptionalPresent<Content: View>(
        _ content: borrowing Content
    ) {
        optionalPresentVisits += 1
    }

    mutating func visitPrimitive<Payload: _GiftUISemanticPrimitivePayload>(
        _ payload: borrowing Payload
    ) {
        primitiveVisits += 1
    }

    mutating func visitActionPrimitive<Payload: _GiftUISemanticActionPayload>(
        _ payload: borrowing Payload
    ) {
        actionPrimitiveVisits += 1
    }

    mutating func visitModifier<
        Content: View,
        Payload: _GiftUISemanticModifierPayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    ) {
        modifierVisits += 1
    }
}
