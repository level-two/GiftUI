import GiftUI

func canvasWithDefaults() -> Canvas {
    Canvas { (_, _) throws(DrawingError) in
        _ = StrokeStyle()
        _ = Shading.color(.white)
    }
}
