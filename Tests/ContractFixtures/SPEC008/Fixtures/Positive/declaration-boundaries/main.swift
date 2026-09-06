import GiftUI

private let maximumLiteral: StaticString =
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
private let oversizedLiteral: StaticString =
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

let empty = BoundedText("")!
let maximum = BoundedText(maximumLiteral)!
let oversized = BoundedText(oversizedLiteral)
let malformed = BoundedText(utf8: [0xF0, 0x9F, 0x8E] as [UInt8])
let embeddedNull = BoundedText("A\0B")!
let trailingNull = BoundedText("A\0")!
let ascii = BoundedText("ASCII")!
let degree = BoundedText("°")!
let replacement = BoundedText("�")!
let integers = [
    BoundedText(Int32.min),
    BoundedText(-1),
    BoundedText(0),
    BoundedText(1),
    BoundedText(Int32.max),
]

struct DeclarationBoundaryCustomView: View {
    var body: some View {
        Text(replacement)
            .foregroundStyle(.gray)
            .background(.black)
            .foregroundStyle(.white)
    }
}

func requireView<Content: View>(_: Content) {}

requireView(DeclarationBoundaryCustomView())
requireView(Text(maximum))
requireView(Text(oversizedLiteral))
_ = empty
_ = oversized
_ = malformed
_ = embeddedNull
_ = trailingNull
_ = ascii
_ = degree
_ = integers
