import GiftUI
import Testing

@Test
func layoutContainersUseExactDefaultsAndTypedPrimitiveOperations() {
    let vertical = VStack { Spacer() }
    let horizontal = HStack { Spacer() }
    let overlay = ZStack { Spacer() }
    var visitor = CustomViewProbeVisitor(evaluateBody: true)

    vertical._giftUITraverse(&visitor)
    horizontal._giftUITraverse(&visitor)
    overlay._giftUITraverse(&visitor)

    #expect(visitor.primitiveWithContentVisits == 3)
    #expect(visitor.primitiveVisits == 3)
    #expect(
        visitor.layoutPrimitiveVisits == [
            .vStack(alignment: .center, spacing: 0),
            .spacer(minLength: 0),
            .hStack(alignment: .center, spacing: 0),
            .spacer(minLength: 0),
            .zStack(alignment: .center),
            .spacer(minLength: 0),
        ]
    )
    #expect(visitor.bodyEvaluations == 0)
}

@Test
func layoutContainersPreserveInvalidSpacingAndMinimumValues() {
    let declaration = VStack(alignment: .leading, spacing: -1) {
        HStack(alignment: .bottom, spacing: .min) {
            ZStack(alignment: .leading) {
                Spacer(minLength: -2)
            }
        }
    }
    var visitor = CustomViewProbeVisitor(evaluateBody: true)

    declaration._giftUITraverse(&visitor)

    #expect(
        visitor.layoutPrimitiveVisits == [
            .vStack(alignment: .leading, spacing: -1),
            .hStack(alignment: .bottom, spacing: .min),
            .zStack(alignment: .leading),
            .spacer(minLength: -2),
        ]
    )
    #expect(visitor.bodyEvaluations == 0)
}

@Test
func layoutContainerBuildersPreserveZeroThroughFiveContentShapes() {
    let zero = VStack {}
    let one = VStack { Spacer() }
    let five = VStack {
        Spacer(minLength: 0)
        Spacer(minLength: 1)
        Spacer(minLength: 2)
        Spacer(minLength: 3)
        Spacer(minLength: 4)
    }
    var visitor = CustomViewProbeVisitor(evaluateBody: true)

    zero._giftUITraverse(&visitor)
    one._giftUITraverse(&visitor)
    five._giftUITraverse(&visitor)

    #expect(visitor.primitiveWithContentVisits == 3)
    #expect(visitor.emptyVisits == 1)
    #expect(visitor.fixedArities == [5])
    #expect(visitor.layoutPrimitiveVisits.first == .vStack(alignment: .center, spacing: 0))
    #expect(visitor.layoutPrimitiveVisits.last == .vStack(alignment: .center, spacing: 0))
    #expect(visitor.bodyEvaluations == 0)
}
