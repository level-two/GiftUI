import GiftUI
import Testing

@Test
func styleModifiersTraverseInSourceCallOrderWithExactColors() {
    let declaration = Text("styled")
        .foregroundStyle(.red)
        .background(.blue)
        .foregroundStyle(.green)
    var visitor = CustomViewProbeVisitor(evaluateBody: true)

    declaration._giftUITraverse(&visitor)

    #expect(visitor.primitiveVisits == 1)
    #expect(visitor.modifierVisits == 3)
    #expect(
        visitor.styleVisits == [
            .foreground(.red),
            .background(.blue),
            .foreground(.green),
        ]
    )
    #expect(visitor.bodyEvaluations == 0)
}

@Test
func changingStyleValuesKeepsTheSameOpaqueDeclarationType() {
    let first = Text("stable").foregroundStyle(.red).background(.black)
    let second = Text("stable").foregroundStyle(.green).background(.white)

    #expect(type(of: first) == type(of: second))
}
