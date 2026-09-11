import GiftUI

func submitLineWidth(
    _ context: inout GraphicsContext,
    _ path: borrowing Path
) throws(DrawingError) {
    try context.stroke(path, with: .color(.white), lineWidth: 2)
}
