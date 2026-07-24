public struct TextRun: Equatable, Sendable {
    public var content: String
    public var color: Color

    public init(_ content: String, color: Color = .white) {
        self.content = content
        self.color = color
    }
}
