// Disposable exact-declaration and generated-callable fixture for SPIKE-008.

public protocol View {}

public protocol _GiftUISemanticTraversalVisitor {
    mutating func visitPrimitive<Primitive>(_ primitive: borrowing Primitive)
}

public typealias GeometryScalar = Int32

public struct Point: Equatable, Sendable {
    public let x: GeometryScalar
    public let y: GeometryScalar

    public init(x: GeometryScalar, y: GeometryScalar) {
        self.x = x
        self.y = y
    }
}

public struct Size: Equatable, Sendable {
    public let width: GeometryScalar
    public let height: GeometryScalar

    public init(width: GeometryScalar, height: GeometryScalar) {
        self.width = width
        self.height = height
    }
}

public struct Color: Equatable, Sendable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}

public enum LineCap: UInt8, Equatable, Sendable {
    case butt = 0
    case round = 1
}

public enum LineJoin: UInt8, Equatable, Sendable {
    case miter = 0
    case round = 1
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

public struct Shading: Equatable, Sendable {
    let value: Color

    public static func color(_ color: Color) -> Shading {
        Shading(value: color)
    }
}

public enum DrawingError: Error, Equatable, Sendable {
    case invalidValue
    case invalidPathState
    case arithmeticOverflow
    case capacityExhausted
    case invalidScope
    case invalidPhase
    case reentrancyViolation
    case invariantViolation
}

nonisolated(unsafe) private var cleanupCount: UInt32 = 0

public struct Path: ~Copyable {
    private var current: Point
    private var first: Point
    private var hasCurrent: Bool
    private var pointCount: UInt8

    fileprivate init() {
        current = Point(x: 0, y: 0)
        first = Point(x: 0, y: 0)
        hasCurrent = false
        pointCount = 0
    }

    public mutating func move(to point: Point) throws(DrawingError) {
        current = point
        first = point
        hasCurrent = true
        pointCount = 1
    }

    public mutating func addLine(to point: Point) throws(DrawingError) {
        guard hasCurrent else { throw DrawingError.invalidPathState }
        guard pointCount < UInt8.max else { throw DrawingError.capacityExhausted }
        current = point
        pointCount &+= 1
    }

    fileprivate borrowing func fixtureDigest() throws(DrawingError) -> UInt32 {
        guard hasCurrent else { throw DrawingError.invalidPathState }
        return UInt32(bitPattern: first.x) ^
            (UInt32(bitPattern: first.y) &* 3) ^
            (UInt32(bitPattern: current.x) &* 5) ^
            (UInt32(bitPattern: current.y) &* 7) ^
            UInt32(pointCount)
    }

    fileprivate mutating func reset() {
        hasCurrent = false
        pointCount = 0
        cleanupCount &+= 1
    }
}

public struct GraphicsContext: ~Copyable {
    private var transcript: UInt32
    private var strokes: UInt16

    fileprivate init(seed: UInt32) {
        transcript = seed
        strokes = 0
    }

    public mutating func withPath<Result>(
        _ body: (
            inout GraphicsContext,
            inout Path
        ) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result {
        var path = Path()
        defer { path.reset() }
        return try body(&self, &path)
    }

    public mutating func stroke(
        _ path: borrowing Path,
        with shading: Shading,
        lineWidth: GeometryScalar
    ) throws(DrawingError) {
        try stroke(
            path,
            with: shading,
            style: StrokeStyle(lineWidth: lineWidth)
        )
    }

    public mutating func stroke(
        _ path: borrowing Path,
        with shading: Shading,
        style: StrokeStyle
    ) throws(DrawingError) {
        guard style.lineWidth > 0 else { throw DrawingError.invalidValue }
        transcript ^= try path.fixtureDigest()
        transcript ^= UInt32(shading.value.red) << 16
        transcript ^= UInt32(shading.value.green) << 8
        transcript ^= UInt32(shading.value.blue)
        transcript ^= UInt32(bitPattern: style.lineWidth)
        transcript ^= UInt32(style.lineCap.rawValue) << 28
        transcript ^= UInt32(style.lineJoin.rawValue) << 30
        strokes &+= 1
    }

    fileprivate borrowing func fixtureResult() -> UInt32 {
        transcript ^ UInt32(strokes)
    }
}

public struct Canvas: View {
    public typealias Body = Never

    public init(
        _ draw: @escaping (
            inout GraphicsContext,
            Size
        ) throws(DrawingError) -> Void
    ) {
        // Static lowering consumes the source closure before semantic retention.
        // This declaration fixture intentionally stores no escaping closure.
    }

    public var body: Never {
        fatalError("Canvas is a semantic primitive")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitPrimitive(self)
    }
}

private enum GeneratedCanvasTag: UInt8 {
    case trace = 0
    case throwingTrace = 1
}

private protocol StaticCanvasCallable: ~Copyable {
    borrowing func invoke(
        _ context: inout GraphicsContext,
        _ size: Size
    ) throws(DrawingError)
}

private struct GeneratedCanvasCallable: StaticCanvasCallable, ~Copyable {
    let tag: GeneratedCanvasTag
    let origin: Point
    let color: Color

    @inline(never)
    borrowing func invoke(
        _ context: inout GraphicsContext,
        _ size: Size
    ) throws(DrawingError) {
        try context.withPath { (context, path) throws(DrawingError) in
            try path.move(to: origin)
            if tag == .throwingTrace {
                throw DrawingError.invalidValue
            }
            try path.addLine(to: Point(x: size.width, y: size.height))
            try context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )

            try path.addLine(to: Point(x: size.width, y: origin.y))
            try context.stroke(path, with: .color(color), lineWidth: 1)
        }
    }
}

@inline(never)
private func invokeGenerated(
    _ callable: borrowing GeneratedCanvasCallable,
    _ context: inout GraphicsContext,
    _ size: Size
) throws(DrawingError) {
    try callable.invoke(&context, size)
}

@_cdecl("spike008_swift_run")
public func spike008SwiftRun(_ seed: UInt32) -> UInt32 {
    cleanupCount = 0
    var context = GraphicsContext(seed: seed ^ 0x0080_0000)
    let size = Size(width: 320, height: 120)
    let success = GeneratedCanvasCallable(
        tag: .trace,
        origin: Point(x: 4, y: 8),
        color: Color(red: 32, green: 160, blue: 240)
    )
    let failure = GeneratedCanvasCallable(
        tag: .throwingTrace,
        origin: Point(x: 12, y: 16),
        color: Color(red: 255, green: 0, blue: 0)
    )
    do {
        try invokeGenerated(success, &context, size)
        try invokeGenerated(failure, &context, size)
        return 0
    } catch DrawingError.invalidValue {
        return context.fixtureResult() ^ cleanupCount
    } catch {
        return 0
    }
}
