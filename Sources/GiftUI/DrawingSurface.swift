package typealias _GiftUIBeginPath =
    @convention(c) (
        UnsafeMutableRawPointer,
        UInt32,
        UnsafeMutablePointer<UInt32>
    ) -> UInt8

package typealias _GiftUIEndPath =
    @convention(c) (
        UnsafeMutableRawPointer,
        UInt32,
        UInt32
    ) -> UInt8

package typealias _GiftUIMutatePath =
    @convention(c) (
        UnsafeMutableRawPointer,
        UInt32,
        UInt32,
        GeometryScalar,
        GeometryScalar
    ) -> UInt8

package typealias _GiftUIStrokePath =
    @convention(c) (
        UnsafeMutableRawPointer,
        UInt32,
        UInt32,
        UInt8,
        UInt8,
        UInt8,
        GeometryScalar,
        UInt8,
        UInt8
    ) -> UInt8

package enum _GiftUIDrawingStatus: UInt8 {
    case success = 0
    case invalidValue = 1
    case invalidPathState = 2
    case arithmeticOverflow = 3
    case capacityExhausted = 4
    case invalidScope = 5
    case invalidPhase = 6
    case reentrancyViolation = 7
    case invariantViolation = 8
}

package struct _GiftUIDrawingOperations {
    package let beginPath: _GiftUIBeginPath
    package let endPath: _GiftUIEndPath
    package let movePath: _GiftUIMutatePath
    package let addLineToPath: _GiftUIMutatePath
    package let strokePath: _GiftUIStrokePath

    package init(
        beginPath: _GiftUIBeginPath,
        endPath: _GiftUIEndPath,
        movePath: _GiftUIMutatePath,
        addLineToPath: _GiftUIMutatePath,
        strokePath: _GiftUIStrokePath
    ) {
        self.beginPath = beginPath
        self.endPath = endPath
        self.movePath = movePath
        self.addLineToPath = addLineToPath
        self.strokePath = strokePath
    }
}

public struct GraphicsContext: ~Copyable {
    private let storage: UnsafeMutableRawPointer
    private let generation: UInt32
    private let operations: _GiftUIDrawingOperations
    private var isActive: Bool

    package init(
        storage: UnsafeMutableRawPointer,
        generation: UInt32,
        operations: _GiftUIDrawingOperations
    ) {
        self.storage = storage
        self.generation = generation
        self.operations = operations
        isActive = true
    }

    public mutating func withPath<Result>(
        _ body: (
            inout GraphicsContext,
            inout Path
        ) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result {
        guard isActive else { throw DrawingError.invalidScope }
        var pathGeneration: UInt32 = 0
        try requireDrawingSuccess(
            operations.beginPath(storage, generation, &pathGeneration)
        )
        var path = Path(
            storage: storage,
            contextGeneration: generation,
            pathGeneration: pathGeneration,
            operations: operations
        )

        let result: Result
        do {
            result = try body(&self, &path)
        } catch {
            path.invalidate()
            _ = operations.endPath(storage, generation, pathGeneration)
            throw error
        }

        path.invalidate()
        try requireDrawingSuccess(
            operations.endPath(storage, generation, pathGeneration)
        )
        return result
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
        guard isActive, path.isActive else {
            throw DrawingError.invalidScope
        }
        try requireDrawingSuccess(
            operations.strokePath(
                storage,
                generation,
                path.pathGeneration,
                shading.colorValue.red,
                shading.colorValue.green,
                shading.colorValue.blue,
                style.lineWidth,
                style.lineCap.rawValue,
                style.lineJoin.rawValue
            )
        )
    }

    package mutating func invalidate() {
        isActive = false
    }
}

public struct Path: ~Copyable {
    private let storage: UnsafeMutableRawPointer
    private let contextGeneration: UInt32
    fileprivate let pathGeneration: UInt32
    private let operations: _GiftUIDrawingOperations
    fileprivate var isActive: Bool

    fileprivate init(
        storage: UnsafeMutableRawPointer,
        contextGeneration: UInt32,
        pathGeneration: UInt32,
        operations: _GiftUIDrawingOperations
    ) {
        self.storage = storage
        self.contextGeneration = contextGeneration
        self.pathGeneration = pathGeneration
        self.operations = operations
        isActive = true
    }

    public mutating func move(to point: Point) throws(DrawingError) {
        guard isActive else { throw DrawingError.invalidScope }
        try requireDrawingSuccess(
            operations.movePath(
                storage,
                contextGeneration,
                pathGeneration,
                point.x,
                point.y
            )
        )
    }

    public mutating func addLine(to point: Point) throws(DrawingError) {
        guard isActive else { throw DrawingError.invalidScope }
        try requireDrawingSuccess(
            operations.addLineToPath(
                storage,
                contextGeneration,
                pathGeneration,
                point.x,
                point.y
            )
        )
    }

    fileprivate mutating func invalidate() {
        isActive = false
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

private func requireDrawingSuccess(_ rawStatus: UInt8) throws(DrawingError) {
    switch _GiftUIDrawingStatus(rawValue: rawStatus) {
    case .success:
        return
    case .invalidValue:
        throw DrawingError.invalidValue
    case .invalidPathState:
        throw DrawingError.invalidPathState
    case .arithmeticOverflow:
        throw DrawingError.arithmeticOverflow
    case .capacityExhausted:
        throw DrawingError.capacityExhausted
    case .invalidScope:
        throw DrawingError.invalidScope
    case .invalidPhase:
        throw DrawingError.invalidPhase
    case .reentrancyViolation:
        throw DrawingError.reentrancyViolation
    case .invariantViolation, nil:
        throw DrawingError.invariantViolation
    }
}
