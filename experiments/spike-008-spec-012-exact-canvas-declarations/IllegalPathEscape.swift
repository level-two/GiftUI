func illegalPathEscape(
    _ context: inout GraphicsContext
) throws(DrawingError) -> Path {
    try context.withPath { (_, path) throws(DrawingError) in
        path
    }
}
