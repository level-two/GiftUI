import GiftUI

enum FixtureError: Error {
    case unsupported
}

let canvas = Canvas { _, _ in
    throw FixtureError.unsupported
}

_ = canvas
