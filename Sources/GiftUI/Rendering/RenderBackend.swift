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

public extension RenderBackend {
    mutating func execute(_ operation: RenderOperation) {
        switch operation {
        case .fillRect(let rect, let color):
            fill(rect, color: color)
        case .strokeRect(let rect, let color, let lineWidth):
            stroke(rect, color: color, lineWidth: lineWidth)
        case .text(let text, let origin):
            drawText(text, at: origin)
        }
    }
}
