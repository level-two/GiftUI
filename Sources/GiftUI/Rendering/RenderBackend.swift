public protocol RenderBackend {
    var surfaceSize: Size { get }

    mutating func beginFrame()
    mutating func clear(_ color: Color)
    mutating func fill(_ rect: Rect, color: Color)
    mutating func stroke(_ rect: Rect, color: Color, lineWidth: Int)
    mutating func drawText(_ text: TextRun, at origin: Point)
    mutating func endFrame()
    mutating func present()
}
