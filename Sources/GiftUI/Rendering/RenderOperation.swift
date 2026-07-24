public enum RenderOperation: Equatable, Sendable {
    case fillRect(Rect, Color)
    case strokeRect(Rect, Color, lineWidth: Int)
    case text(TextRun, at: Point)
}
