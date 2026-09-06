import GiftUI

func requireSendable<Value: Sendable>(_: Value) {}

let literal = BoundedText("GiftUI")!
let collected = BoundedText(utf8: [UInt8(ascii: "O"), UInt8(ascii: "K")])!
let integer = BoundedText(Int32.min)
let equal = literal == BoundedText(utf8: Array("GiftUI".utf8))!

literal.withUTF8 { bytes in
    _ = bytes.count
}

requireSendable(literal)
_ = collected.utf8ByteCount
_ = integer
_ = equal
_ = BoundedText.maximumUTF8ByteCount
