import GiftUI

enum FixtureError: Error {
    case unsupported
}

struct CanvasWithUnsupportedError: Canvas {
    typealias Domain = _GiftUIEmptyReadDomain

    func _giftUIDraw(
        in _: Rect,
        context _: inout GraphicsContext,
        read _: borrowing _GiftUIFrameRead<Domain>
    ) throws(FixtureError) {
        throw FixtureError.unsupported
    }
}
