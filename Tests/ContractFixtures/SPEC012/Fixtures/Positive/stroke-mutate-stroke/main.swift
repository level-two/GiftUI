import GiftUI

func strokeMutateStroke(
    _ context: inout GraphicsContext
) throws(DrawingError) {
    try context.withPath { (context, path) throws(DrawingError) in
        try path.move(to: Point(x: 0, y: 0))
        try path.addLine(to: Point(x: 1, y: 1))
        try context.stroke(path, with: .color(.white), lineWidth: 1)

        try path.addLine(to: Point(x: 2, y: 1))
        try context.stroke(
            path,
            with: .color(.red),
            style: StrokeStyle(lineWidth: 2, lineCap: .round)
        )
    }
}
