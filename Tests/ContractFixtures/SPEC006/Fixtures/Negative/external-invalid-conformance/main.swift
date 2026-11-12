import GiftUI

struct InvalidExternalView: View {
    typealias Domain = _GiftUIEmptyReadDomain
    typealias Body = UInt8

    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>) -> UInt8 { 0 }
}
