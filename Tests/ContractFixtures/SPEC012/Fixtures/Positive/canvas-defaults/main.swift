import GiftUI

let canvas = Canvas { (_, _) throws(DrawingError) in
    _ = StrokeStyle()
    _ = Shading.color(.white)
}

_ = canvas
