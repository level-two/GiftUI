import GiftUI

enum FixtureError: Error {
    case unsupported
}

func canvasWithUnsupportedError() -> Canvas {
    Canvas { (_, _) throws(FixtureError) in
        throw FixtureError.unsupported
    }
}
