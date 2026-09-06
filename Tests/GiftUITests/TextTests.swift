import GiftUI
import Testing

private func admittedBytes(of text: Text) -> [UInt8]? {
    switch text._giftUITextPayload.content {
    case .admitted(let content):
        content.withUTF8(Array.init)
    case .invalidDeclaration:
        nil
    }
}

@Test
func textStoresExactBoundedContentFromBothInitializers() {
    let bounded = BoundedText(utf8: [0x41, 0xC2, 0xB0])!
    let fromBounded = Text(bounded)
    let fromLiteral = Text("A°")

    #expect(admittedBytes(of: fromBounded) == [0x41, 0xC2, 0xB0])
    #expect(admittedBytes(of: fromLiteral) == [0x41, 0xC2, 0xB0])
}

@Test
func oversizedTextLiteralStoresOnlyInvalidDeclarationMarker() {
    let text = Text(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    )

    #expect(text._giftUITextPayload.content == .invalidDeclaration)
    #expect(admittedBytes(of: text) == nil)
}

@Test
func textUsesPrimitiveTraversalWithoutEvaluatingBody() {
    let admitted = Text("admitted")
    let invalid = Text(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    )
    var visitor = CustomViewProbeVisitor(evaluateBody: true)

    admitted._giftUITraverse(&visitor)
    invalid._giftUITraverse(&visitor)

    #expect(visitor.primitiveVisits == 2)
    #expect(visitor.customViewVisits == 0)
    #expect(visitor.bodyEvaluations == 0)
    #expect(visitor.actionPrimitiveVisits == 0)
    #expect(visitor.modifierVisits == 0)
}
