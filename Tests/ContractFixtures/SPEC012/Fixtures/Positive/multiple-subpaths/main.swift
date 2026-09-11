import GiftUI

func multipleSubpaths(
    _ context: inout GraphicsContext
) throws(DrawingError) {
    try context.withPath { (context, path) throws(DrawingError) in
        try path.move(to: Point(x: 0, y: 0))
        try path.addLine(to: Point(x: 1, y: 1))
        try path.move(to: Point(x: 2, y: 2))
        try path.addLine(to: Point(x: 3, y: 3))
        try context.stroke(path, with: .color(.blue), lineWidth: 1)
    }
}
