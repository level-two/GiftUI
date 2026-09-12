import GiftUI
import XCTest

final class DrawingSurfaceTests: XCTestCase {
    func testContextSuppliesTwoInoutsAndForwardsPathOperations() throws {
        var probe = DrawingSurfaceProbe()

        try withUnsafeMutablePointer(to: &probe) { pointer in
            var context = makeContext(pointer)
            let result = try context.withPath {
                (context, path) throws(DrawingError) -> UInt16 in
                try path.move(to: Point(x: 1, y: 2))
                try path.addLine(to: Point(x: 3, y: 4))
                try context.stroke(
                    path,
                    with: .color(Color(red: 5, green: 6, blue: 7)),
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                return 9
            }
            XCTAssertEqual(result, 9)
        }

        XCTAssertEqual(probe.beginCount, 1)
        XCTAssertEqual(probe.endCount, 1)
        XCTAssertFalse(probe.pathIsActive)
        XCTAssertEqual(probe.livePointCount, 0)
        XCTAssertEqual(probe.liveSubpathCount, 0)
        XCTAssertEqual(probe.points, [Point(x: 1, y: 2), Point(x: 3, y: 4)])
        XCTAssertEqual(probe.strokeCount, 1)
        XCTAssertEqual(probe.strokeColor, Color(red: 5, green: 6, blue: 7))
        XCTAssertEqual(
            probe.strokeStyle,
            StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
        )
    }

    func testThrowingPathBodyEndsScopeAndPreservesBodyError() throws {
        var probe = DrawingSurfaceProbe(endStatus: .invariantViolation)

        try withUnsafeMutablePointer(to: &probe) { pointer in
            var context = makeContext(pointer)
            XCTAssertThrowsError(
                try context.withPath { (_, path) throws(DrawingError) in
                    try path.move(to: Point(x: 10, y: 11))
                    throw DrawingError.invalidValue
                }
            ) { error in
                XCTAssertEqual(error as? DrawingError, .invalidValue)
            }
        }

        XCTAssertEqual(probe.beginCount, 1)
        XCTAssertEqual(probe.endCount, 1)
        XCTAssertFalse(probe.pathIsActive)
        XCTAssertEqual(probe.livePointCount, 0)
        XCTAssertEqual(probe.liveSubpathCount, 0)
    }

    func testSuccessfulBodySurfacesEndScopeFailure() throws {
        var probe = DrawingSurfaceProbe(endStatus: .invariantViolation)

        try withUnsafeMutablePointer(to: &probe) { pointer in
            var context = makeContext(pointer)
            XCTAssertThrowsError(
                try context.withPath { (_, _) throws(DrawingError) in }
            ) { error in
                XCTAssertEqual(error as? DrawingError, .invariantViolation)
            }
        }

        XCTAssertEqual(probe.endCount, 1)
        XCTAssertFalse(probe.pathIsActive)
    }

    func testNestedPathScopeIsRejectedBeforeReplacingTheActivePath() throws {
        var probe = DrawingSurfaceProbe()

        try withUnsafeMutablePointer(to: &probe) { pointer in
            var context = makeContext(pointer)
            try context.withPath { (context, _) throws(DrawingError) in
                XCTAssertThrowsError(
                    try context.withPath { (_, _) throws(DrawingError) in }
                ) { error in
                    XCTAssertEqual(error as? DrawingError, .reentrancyViolation)
                }
                XCTAssertTrue(pointer.pointee.pathIsActive)
            }
        }

        XCTAssertEqual(probe.beginCount, 1)
        XCTAssertEqual(probe.endCount, 1)
        XCTAssertFalse(probe.pathIsActive)
    }

    func testDrawingStylesPreserveExactValuesAndDefaults() {
        let color = Color(red: 1, green: 127, blue: 255)
        let shading = Shading.color(color)
        let defaultStyle = StrokeStyle()
        let explicitStyle = StrokeStyle(
            lineWidth: -1,
            lineCap: .round,
            lineJoin: .round
        )
        let sendableShading: any Sendable = shading
        let sendableStyle: any Sendable = explicitStyle

        XCTAssertEqual(shading.colorValue, color)
        XCTAssertEqual(shading, Shading.color(color))
        XCTAssertEqual(defaultStyle.lineWidth, 1)
        XCTAssertEqual(defaultStyle.lineCap, .butt)
        XCTAssertEqual(defaultStyle.lineJoin, .miter)
        XCTAssertEqual(explicitStyle.lineWidth, -1)
        XCTAssertEqual(explicitStyle.lineCap, .round)
        XCTAssertEqual(explicitStyle.lineJoin, .round)
        XCTAssertTrue(sendableShading is Shading)
        XCTAssertTrue(sendableStyle is StrokeStyle)
    }

    func testStyleEnumsAndDrawingErrorsPreserveExactCases() {
        XCTAssertEqual(LineCap.butt.rawValue, 0)
        XCTAssertEqual(LineCap.round.rawValue, 1)
        XCTAssertEqual(LineJoin.miter.rawValue, 0)
        XCTAssertEqual(LineJoin.round.rawValue, 1)

        let errors: [DrawingError] = [
            .invalidValue,
            .invalidPathState,
            .arithmeticOverflow,
            .capacityExhausted,
            .invalidScope,
            .invalidPhase,
            .reentrancyViolation,
            .invariantViolation,
        ]
        let sendableErrors: any Sendable = errors

        XCTAssertEqual(errors.count, 8)
        XCTAssertTrue(sendableErrors is [DrawingError])
    }

    func testWidthOverloadUsesDefaultsAndInvalidWidthsDoNotReachStorage() throws {
        var probe = DrawingSurfaceProbe()

        try withUnsafeMutablePointer(to: &probe) { pointer in
            var context = makeContext(pointer)
            try context.withPath { (context, path) throws(DrawingError) in
                try path.move(to: Point(x: 0, y: 0))
                try context.stroke(path, with: .color(.white), lineWidth: 2)

                for width: GeometryScalar in [0, -1, .min] {
                    XCTAssertThrowsError(
                        try context.stroke(
                            path,
                            with: .color(.red),
                            style: StrokeStyle(
                                lineWidth: width,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                    ) { error in
                        XCTAssertEqual(error as? DrawingError, .invalidValue)
                    }
                }
            }
        }

        XCTAssertEqual(probe.strokeCount, 1)
        XCTAssertEqual(probe.strokeColor, .white)
        XCTAssertEqual(
            probe.strokeStyle,
            StrokeStyle(lineWidth: 2, lineCap: .butt, lineJoin: .miter)
        )
    }
}

private let expectedContextGeneration: UInt32 = 17
private let expectedPathGeneration: UInt32 = 23

private struct DrawingSurfaceProbe {
    var beginCount = 0
    var endCount = 0
    var pathIsActive = false
    var livePointCount = 0
    var liveSubpathCount = 0
    var points: [Point] = []
    var strokeCount = 0
    var strokeColor: Color?
    var strokeStyle: StrokeStyle?
    var endStatus: _GiftUIDrawingStatus = .success
}

private let drawingSurfaceProbeOperations = _GiftUIDrawingOperations(
    beginPath: drawingSurfaceProbeBegin,
    endPath: drawingSurfaceProbeEnd,
    movePath: drawingSurfaceProbeMove,
    addLineToPath: drawingSurfaceProbeAddLine,
    strokePath: drawingSurfaceProbeStroke
)

private func makeContext(
    _ pointer: UnsafeMutablePointer<DrawingSurfaceProbe>
) -> GraphicsContext {
    GraphicsContext(
        storage: UnsafeMutableRawPointer(pointer),
        generation: expectedContextGeneration,
        operations: drawingSurfaceProbeOperations
    )
}

private func drawingSurfaceProbe(
    _ storage: UnsafeMutableRawPointer
) -> UnsafeMutablePointer<DrawingSurfaceProbe> {
    storage.assumingMemoryBound(to: DrawingSurfaceProbe.self)
}

private func drawingSurfaceProbeBegin(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UnsafeMutablePointer<UInt32>
) -> UInt8 {
    guard contextGeneration == expectedContextGeneration else {
        return _GiftUIDrawingStatus.invalidScope.rawValue
    }
    let probe = drawingSurfaceProbe(storage)
    guard !probe.pointee.pathIsActive else {
        return _GiftUIDrawingStatus.reentrancyViolation.rawValue
    }
    probe.pointee.beginCount += 1
    probe.pointee.pathIsActive = true
    probe.pointee.livePointCount = 0
    probe.pointee.liveSubpathCount = 0
    pathGeneration.pointee = expectedPathGeneration
    return _GiftUIDrawingStatus.success.rawValue
}

private func drawingSurfaceProbeEnd(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UInt32
) -> UInt8 {
    guard contextGeneration == expectedContextGeneration,
        pathGeneration == expectedPathGeneration
    else {
        return _GiftUIDrawingStatus.invalidScope.rawValue
    }
    let probe = drawingSurfaceProbe(storage)
    probe.pointee.endCount += 1
    probe.pointee.pathIsActive = false
    probe.pointee.livePointCount = 0
    probe.pointee.liveSubpathCount = 0
    return probe.pointee.endStatus.rawValue
}

private func drawingSurfaceProbeMove(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UInt32,
    _ x: GeometryScalar,
    _ y: GeometryScalar
) -> UInt8 {
    let status = drawingSurfaceProbeAppend(
        storage,
        contextGeneration,
        pathGeneration,
        Point(x: x, y: y)
    )
    if status == _GiftUIDrawingStatus.success.rawValue {
        let probe = drawingSurfaceProbe(storage)
        probe.pointee.livePointCount += 1
        probe.pointee.liveSubpathCount += 1
    }
    return status
}

private func drawingSurfaceProbeAddLine(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UInt32,
    _ x: GeometryScalar,
    _ y: GeometryScalar
) -> UInt8 {
    let status = drawingSurfaceProbeAppend(
        storage,
        contextGeneration,
        pathGeneration,
        Point(x: x, y: y)
    )
    if status == _GiftUIDrawingStatus.success.rawValue {
        drawingSurfaceProbe(storage).pointee.livePointCount += 1
    }
    return status
}

private func drawingSurfaceProbeAppend(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UInt32,
    _ point: Point
) -> UInt8 {
    guard contextGeneration == expectedContextGeneration,
        pathGeneration == expectedPathGeneration
    else {
        return _GiftUIDrawingStatus.invalidScope.rawValue
    }
    let probe = drawingSurfaceProbe(storage)
    guard probe.pointee.pathIsActive else {
        return _GiftUIDrawingStatus.invalidScope.rawValue
    }
    probe.pointee.points.append(point)
    return _GiftUIDrawingStatus.success.rawValue
}

private func drawingSurfaceProbeStroke(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UInt32,
    _ red: UInt8,
    _ green: UInt8,
    _ blue: UInt8,
    _ lineWidth: GeometryScalar,
    _ lineCap: UInt8,
    _ lineJoin: UInt8
) -> UInt8 {
    guard contextGeneration == expectedContextGeneration,
        pathGeneration == expectedPathGeneration
    else {
        return _GiftUIDrawingStatus.invalidScope.rawValue
    }
    let probe = drawingSurfaceProbe(storage)
    guard probe.pointee.pathIsActive,
        let cap = LineCap(rawValue: lineCap),
        let join = LineJoin(rawValue: lineJoin)
    else {
        return _GiftUIDrawingStatus.invariantViolation.rawValue
    }
    probe.pointee.strokeCount += 1
    probe.pointee.strokeColor = Color(red: red, green: green, blue: blue)
    probe.pointee.strokeStyle = StrokeStyle(
        lineWidth: lineWidth,
        lineCap: cap,
        lineJoin: join
    )
    return _GiftUIDrawingStatus.success.rawValue
}
