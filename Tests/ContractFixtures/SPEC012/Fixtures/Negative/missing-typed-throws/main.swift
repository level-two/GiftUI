import GiftUI

enum FixtureError: Error {
    case unsupported
}

struct CanvasWithUntypedError: Canvas {
    typealias Domain = _GiftUIEmptyReadDomain

    func _giftUIDraw(
        in _: Rect,
        context _: inout GraphicsContext,
        read _: borrowing _GiftUIFrameRead<Domain>
    ) throws {
        throw FixtureError.unsupported
    }
}
