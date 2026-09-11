import GiftUI

enum FixtureError: Error {
    case unsupported
}

let canvas = Canvas { (_, _) throws(FixtureError) in
    throw FixtureError.unsupported
}

_ = canvas
