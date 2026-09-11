import GiftUI

func submitExplicitStyle(
    _ context: inout GraphicsContext,
    _ path: borrowing Path
) throws(DrawingError) {
    try context.stroke(
        path,
        with: .color(.red),
        style: StrokeStyle(
            lineWidth: 3,
            lineCap: .round,
            lineJoin: .round
        )
    )
}
