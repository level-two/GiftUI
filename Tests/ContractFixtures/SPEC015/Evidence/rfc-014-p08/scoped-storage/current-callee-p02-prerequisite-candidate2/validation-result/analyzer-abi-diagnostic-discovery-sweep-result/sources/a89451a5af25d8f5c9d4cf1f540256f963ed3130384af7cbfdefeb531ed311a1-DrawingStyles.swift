public enum LineCap: UInt8, Equatable, Sendable {
    case butt = 0
    case round = 1
}

public enum LineJoin: UInt8, Equatable, Sendable {
    case miter = 0
    case round = 1
}

public struct Shading: Equatable, Sendable {
    package let colorValue: Color

    public static func color(_ color: Color) -> Shading {
        Shading(colorValue: color)
    }
}

public struct StrokeStyle: Equatable, Sendable {
    public let lineWidth: GeometryScalar
    public let lineCap: LineCap
    public let lineJoin: LineJoin

    public init(
        lineWidth: GeometryScalar = 1,
        lineCap: LineCap = .butt,
        lineJoin: LineJoin = .miter
    ) {
        self.lineWidth = lineWidth
        self.lineCap = lineCap
        self.lineJoin = lineJoin
    }
}
