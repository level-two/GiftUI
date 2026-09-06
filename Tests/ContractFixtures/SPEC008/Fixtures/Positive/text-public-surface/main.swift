import GiftUI

func requireView<Content: View>(_: Content) {}

let bounded = BoundedText(utf8: [UInt8(ascii: "O"), UInt8(ascii: "K")])!
let literalText: Text = Text("GiftUI")
let boundedText: Text = Text(bounded)

requireView(literalText)
requireView(boundedText)
