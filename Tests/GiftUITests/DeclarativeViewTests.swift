import GiftUI
import XCTest

final class DeclarativeViewTests: XCTestCase {
    func testButtonBuildsAndBorrowsItsStoredLabelExactlyOnce() {
        var builderCalls = 0
        let button = Button(action: TestAction.ordinary) {
            builderCalls += 1
            return PrimitiveLeaf()
        }
        XCTAssertEqual(builderCalls, 1)

        var visitor = CustomViewProbeVisitor(evaluateBody: true)
        button._giftUITraverse(&visitor)
        button._giftUITraverse(&visitor)

        XCTAssertEqual(builderCalls, 1)
        XCTAssertEqual(visitor.actionPrimitiveWithContentVisits, 2)
        XCTAssertEqual(visitor.visitedActionCodes, [17, 17])
        XCTAssertEqual(visitor.primitiveVisits, 2)
    }

    func testButtonTitleInitializersPreserveActionAndTextValue() {
        let bounded = BoundedText("bounded")!
        let staticButton = Button("static", action: TestAction.minimum)
        let boundedButton = Button(bounded, action: TestAction.maximum)

        XCTAssertEqual(staticButton._giftUIButtonPayload.action, .minimum)
        XCTAssertEqual(
            staticButton._giftUIButtonPayload.label._giftUITextPayload,
            Text("static")._giftUITextPayload
        )
        XCTAssertEqual(boundedButton._giftUIButtonPayload.action, .maximum)
        XCTAssertEqual(
            boundedButton._giftUIButtonPayload.label._giftUITextPayload,
            Text(bounded)._giftUITextPayload
        )
    }

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

    func testGeneratedStatefulHostUsesStatefulCategoryAndBorrowedBody() {
        var visitor = CustomViewProbeVisitor(evaluateBody: true)

        StatefulRootView()._giftUITraverse(&visitor)

        XCTAssertEqual(visitor.customViewVisits, 0)
        XCTAssertEqual(visitor.statefulCustomViewVisits, 1)
        XCTAssertEqual(visitor.bodyEvaluations, 1)
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

    func testCanvasStagesOnePrimitiveWithoutInvokingDrawOrEvaluatingBody() {
        let counter = InvocationCounter()
        let canvas = Canvas { (_, _) throws(DrawingError) in
            counter.value += 1
        }
        let _: Canvas.Body.Type = Never.self
        var visitor = CustomViewProbeVisitor(evaluateBody: true)

        canvas._giftUITraverse(&visitor)

        XCTAssertEqual(visitor.primitiveVisits, 1)
        XCTAssertEqual(visitor.bodyEvaluations, 0)
        XCTAssertEqual(counter.value, 0)
    }

    func testPrimitiveWithContentUsesOnlyItsTypedOverloadAndNeverReadsBody() {
        let empty = PrimitiveContainer {}
        let one = PrimitiveContainer { PrimitiveLeaf() }
        let five = PrimitiveContainer {
            PrimitiveLeaf()
            PrimitiveLeaf()
            PrimitiveLeaf()
            PrimitiveLeaf()
            PrimitiveLeaf()
        }
        var visitor = CustomViewProbeVisitor(evaluateBody: true)

        empty._giftUITraverse(&visitor)
        one._giftUITraverse(&visitor)
        five._giftUITraverse(&visitor)

        XCTAssertEqual(visitor.primitiveWithContentVisits, 3)
        XCTAssertEqual(visitor.primitiveVisits, 1)
        XCTAssertEqual(visitor.emptyVisits, 1)
        XCTAssertEqual(visitor.fixedArities, [5])
        XCTAssertEqual(visitor.bodyEvaluations, 0)
    }

    func testActionPrimitiveWithContentUsesOnlyItsTypedOverloadAndNeverReadsBody() {
        let empty = ActionPrimitiveContainer(action: TestAction.minimum) {}
        let one = ActionPrimitiveContainer(action: TestAction.ordinary) { PrimitiveLeaf() }
        let five = ActionPrimitiveContainer(action: TestAction.maximum) {
            PrimitiveLeaf()
            PrimitiveLeaf()
            PrimitiveLeaf()
            PrimitiveLeaf()
            PrimitiveLeaf()
        }
        let _: ActionPrimitiveContainer<TestAction, EmptyView>.Body.Type = Never.self
        var visitor = CustomViewProbeVisitor(evaluateBody: true)

        visitor.visitActionPrimitive(TestActionPayload(_giftUIAction: .ordinary))
        empty._giftUITraverse(&visitor)
        one._giftUITraverse(&visitor)
        five._giftUITraverse(&visitor)

        XCTAssertEqual(visitor.actionPrimitiveWithContentVisits, 3)
        XCTAssertEqual(visitor.actionPrimitiveVisits, 1)
        XCTAssertEqual(
            visitor.visitedActionCodes,
            [
                TestAction.minimum.rawValue, TestAction.ordinary.rawValue,
                TestAction.maximum.rawValue,
            ]
        )
        XCTAssertEqual(visitor.emptyVisits, 1)
        XCTAssertEqual(visitor.fixedArities, [5])
        XCTAssertEqual(visitor.bodyEvaluations, 0)
    }
}

private final class InvocationCounter {
    var value = 0
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

@ObservableStateHost
private struct StatefulRootView: View {
    @State private var model = StatefulTestModel()

    var body: some View {
        LeafView()
    }
}

private final class StatefulTestModel: _GiftUIObservableReference {
    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
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

private struct PrimitiveLeaf: View, _GiftUISemanticPrimitivePayload {
    typealias Body = Never

    var body: Never {
        fatalError("PrimitiveLeaf.body must remain unevaluated")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitPrimitive(self)
    }
}

private struct PrimitiveContainer<Content: View>: View {
    typealias Body = Never

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: Never {
        fatalError("PrimitiveContainer.body must remain unevaluated")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitPrimitive(content: content, payload: TestPrimitivePayload())
    }
}

private struct TestActionPayload: _GiftUISemanticActionPayload {
    let _giftUIAction: TestAction
}

private struct ActionPrimitiveContainer<Action: GiftUIAction, Content: View>: View {
    typealias Body = Never

    let content: Content
    let payload: ActionPrimitivePayload<Action>

    init(action: Action, @ViewBuilder content: () -> Content) {
        self.content = content()
        payload = ActionPrimitivePayload(_giftUIAction: action)
    }

    var body: Never {
        fatalError("ActionPrimitiveContainer.body must remain unevaluated")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitActionPrimitive(content: content, payload: payload)
    }
}

private struct ActionPrimitivePayload<Action: GiftUIAction>:
    _GiftUISemanticActionPayload
{
    let _giftUIAction: Action
}

private struct TestModifierPayload: _GiftUISemanticModifierPayload {}

enum StyleVisit: Equatable {
    case foreground(Color)
    case background(Color)
}

enum LayoutModifierVisit: Equatable {
    case padding(edges: EdgeSet, length: GeometryScalar)
    case paddingInsets(EdgeInsets)
    case fixedFrame(width: GeometryScalar?, height: GeometryScalar?, alignment: Alignment)
    case flexibleFrame(
        minWidth: GeometryScalar?,
        maxWidth: FrameLimit?,
        minHeight: GeometryScalar?,
        maxHeight: FrameLimit?,
        alignment: Alignment
    )
}

enum LayoutPrimitiveVisit: Equatable {
    case vStack(alignment: HorizontalAlignment, spacing: GeometryScalar)
    case hStack(alignment: VerticalAlignment, spacing: GeometryScalar)
    case zStack(alignment: Alignment)
    case spacer(minLength: GeometryScalar)
}

struct CustomViewProbeVisitor: _GiftUISemanticTraversalVisitor {
    let evaluateBody: Bool
    var customViewVisits = 0
    var statefulCustomViewVisits = 0
    var bodyEvaluations = 0
    var firstBranchVisits = 0
    var secondBranchVisits = 0
    var emptyVisits = 0
    var fixedArities: [Int] = []
    var optionalAbsentVisits = 0
    var optionalPresentVisits = 0
    var primitiveVisits = 0
    var primitiveWithContentVisits = 0
    var actionPrimitiveVisits = 0
    var actionPrimitiveWithContentVisits = 0
    var visitedActionCodes: [UInt16] = []
    var modifierVisits = 0
    var styleVisits: [StyleVisit] = []
    var layoutModifierVisits: [LayoutModifierVisit] = []
    var layoutPrimitiveVisits: [LayoutPrimitiveVisit] = []

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

    mutating func visitStatefulCustomView<
        Declaration: View & _GiftUIObservableStateHost
    >(
        _ declaration: borrowing Declaration,
        body: (borrowing Declaration) -> Declaration.Body
    ) {
        statefulCustomViewVisits += 1
        if evaluateBody {
            _ = body(declaration)
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
        recordLayoutPrimitive(payload)
        primitiveVisits += 1
    }

    mutating func visitPrimitive<
        Content: View,
        Payload: _GiftUISemanticPrimitivePayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    ) {
        recordLayoutPrimitive(payload)
        primitiveWithContentVisits += 1
        if evaluateBody {
            content._giftUITraverse(&self)
        }
    }

    mutating func visitActionPrimitive<Payload: _GiftUISemanticActionPayload>(
        _ payload: borrowing Payload
    ) {
        actionPrimitiveVisits += 1
    }

    mutating func visitActionPrimitive<
        Content: View,
        Payload: _GiftUISemanticActionPayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    ) {
        actionPrimitiveWithContentVisits += 1
        let payloadCopy = copy payload
        if let action = payloadCopy._giftUIAction as? TestAction {
            visitedActionCodes.append(action.rawValue)
        }
        if evaluateBody {
            content._giftUITraverse(&self)
        }
    }

    private mutating func recordLayoutPrimitive<
        Payload: _GiftUISemanticPrimitivePayload
    >(_ payload: borrowing Payload) {
        let payloadCopy = copy payload
        if let stack = payloadCopy as? _GiftUIVStackPayload {
            layoutPrimitiveVisits.append(
                .vStack(alignment: stack.alignment, spacing: stack.spacing)
            )
        } else if let stack = payloadCopy as? _GiftUIHStackPayload {
            layoutPrimitiveVisits.append(
                .hStack(alignment: stack.alignment, spacing: stack.spacing)
            )
        } else if let stack = payloadCopy as? _GiftUIZStackPayload {
            layoutPrimitiveVisits.append(.zStack(alignment: stack.alignment))
        } else if let spacer = payloadCopy as? _GiftUISpacerPayload {
            layoutPrimitiveVisits.append(.spacer(minLength: spacer.minLength))
        }
    }

    mutating func visitModifier<
        Content: View,
        Payload: _GiftUISemanticModifierPayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    ) {
        if evaluateBody {
            content._giftUITraverse(&self)
        }
        let payloadCopy = copy payload
        if let foreground = payloadCopy as? _GiftUIForegroundStylePayload {
            styleVisits.append(.foreground(foreground.color))
        } else if let background = payloadCopy as? _GiftUIBackgroundPayload {
            styleVisits.append(.background(background.color))
        } else if let padding = payloadCopy as? _GiftUIPaddingPayload {
            layoutModifierVisits.append(
                .padding(edges: padding.edges, length: padding.length)
            )
        } else if let paddingInsets = payloadCopy as? _GiftUIPaddingInsetsPayload {
            layoutModifierVisits.append(.paddingInsets(paddingInsets.insets))
        } else if let frame = payloadCopy as? _GiftUIFixedFramePayload {
            layoutModifierVisits.append(
                .fixedFrame(
                    width: frame.width,
                    height: frame.height,
                    alignment: frame.alignment
                )
            )
        } else if let frame = payloadCopy as? _GiftUIFlexibleFramePayload {
            layoutModifierVisits.append(
                .flexibleFrame(
                    minWidth: frame.minWidth,
                    maxWidth: frame.maxWidth,
                    minHeight: frame.minHeight,
                    maxHeight: frame.maxHeight,
                    alignment: frame.alignment
                )
            )
        }
        modifierVisits += 1
    }
}
