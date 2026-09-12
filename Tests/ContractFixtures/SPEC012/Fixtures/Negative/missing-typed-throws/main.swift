import GiftUI

enum FixtureError: Error {
    case unsupported
}

func canvasWithUntypedError() -> Canvas {
    Canvas { _, _ in
        throw FixtureError.unsupported
    }
}
