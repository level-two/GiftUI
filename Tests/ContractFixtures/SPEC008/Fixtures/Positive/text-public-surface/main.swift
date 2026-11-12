import GiftUI

func requireView<Content: View>(_: Content) {}

func exerciseTextSurface() {
    let bounded = BoundedText(utf8: [UInt8(ascii: "O"), UInt8(ascii: "K")])!
    let literalText: Text<_GiftUIEmptyReadDomain> = Text<_GiftUIEmptyReadDomain>("GiftUI")
    let boundedText: Text<_GiftUIEmptyReadDomain> = Text<_GiftUIEmptyReadDomain>(bounded)

    requireView(literalText)
    requireView(boundedText)
}

exerciseTextSurface()
