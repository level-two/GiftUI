import GiftUI
import Testing

@Test
func layoutModifiersPreserveInvalidValuesInSourceCallOrder() {
    let insets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)!
    let declaration = Text("layout")
        .padding(-1)
        .padding(EdgeSet(rawValue: 1 << 7), -2)
        .padding(insets)
        .frame(width: -3, height: nil, alignment: .leading)
        .frame(
            minWidth: 9,
            maxWidth: .points(8),
            minHeight: -4,
            maxHeight: .points(-5),
            alignment: Alignment(horizontal: .center, vertical: .bottom)
        )
    var visitor = CustomViewProbeVisitor(evaluateBody: true)

    declaration._giftUITraverse(&visitor)

    #expect(visitor.primitiveVisits == 1)
    #expect(visitor.modifierVisits == 5)
    #expect(
        visitor.layoutModifierVisits == [
            .padding(edges: .all, length: -1),
            .padding(edges: EdgeSet(rawValue: 1 << 7), length: -2),
            .paddingInsets(insets),
            .fixedFrame(width: -3, height: nil, alignment: .leading),
            .flexibleFrame(
                minWidth: 9,
                maxWidth: .points(8),
                minHeight: -4,
                maxHeight: .points(-5),
                alignment: Alignment(horizontal: .center, vertical: .bottom)
            ),
        ]
    )
}

@Test
func emptyAndAllNilLayoutModifiersRemainDistinctDeclarations() {
    let insets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)!
    let declaration = Text("layout")
        .padding([], 7)
        .padding(insets)
        .frame(width: nil, height: nil, alignment: .leading)
        .frame(
            minWidth: nil,
            maxWidth: nil,
            minHeight: nil,
            maxHeight: nil,
            alignment: .leading
        )
    var visitor = CustomViewProbeVisitor(evaluateBody: true)

    declaration._giftUITraverse(&visitor)

    #expect(
        visitor.layoutModifierVisits == [
            .padding(edges: [], length: 7),
            .paddingInsets(insets),
            .fixedFrame(width: nil, height: nil, alignment: .leading),
            .flexibleFrame(
                minWidth: nil,
                maxWidth: nil,
                minHeight: nil,
                maxHeight: nil,
                alignment: .leading
            ),
        ]
    )
}
