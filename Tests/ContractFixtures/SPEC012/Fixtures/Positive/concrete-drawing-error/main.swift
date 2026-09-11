import GiftUI

func failDrawing() throws(DrawingError) {
    throw DrawingError.capacityExhausted
}

func forwardDrawingError(
    _ context: inout GraphicsContext
) throws(DrawingError) {
    try context.withPath { (_, _) throws(DrawingError) in
        try failDrawing()
    }
}
