func illegalOuterContextAccess(
    _ context: inout GraphicsContext
) throws(DrawingError) {
    try context.withPath { (_, path) throws(DrawingError) in
        try path.move(to: Point(x: 0, y: 0))
        try path.addLine(to: Point(x: 1, y: 1))
        try context.stroke(path, with: .color(.white), lineWidth: 1)
    }
}
