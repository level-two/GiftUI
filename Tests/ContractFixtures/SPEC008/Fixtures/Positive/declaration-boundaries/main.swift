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
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = Never

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> Never
    {
        fatalError("declaration boundary fixture is compile-only")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>(
        _ visitor: inout Visitor
    ) where Visitor.Domain == Domain {
        visitor.visitEmpty()
    }
}

func requireView<Content: View>(_: Content) {}

requireView(DeclarationBoundaryCustomView())
requireView(Text<_GiftUIEmptyReadDomain>(maximum))
requireView(Text<_GiftUIEmptyReadDomain>(oversizedLiteral))
_ = empty
_ = oversized
_ = malformed
_ = embeddedNull
_ = trailingNull
_ = ascii
_ = degree
_ = integers
