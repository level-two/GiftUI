import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import GiftUISurfaceCore
import Testing

@testable import GiftUIRasterCore

struct StrokeOperationFixture {
    let symbol: Character
    let color: Color
    let lineWidth: Int32
    let cap: LineCap
    let join: LineJoin
    let origin: Point
    let clip: Rect
    let points: [Point]
    let subpaths: [SubpathRange]
}

struct StrokeVectorFixture: CustomTestStringConvertible {
    let name: String
    let width: Int32
    let height: Int32
    let operations: [StrokeOperationFixture]
    let expectedMask: [String]

    var testDescription: String { name }
}

struct FixtureStroke: StraightLineStrokeView {
    let header: StraightLineStrokeHeader
    let points: [Point]
    let subpaths: [SubpathRange]

    func point(at index: UInt16) -> Point? {
        guard index < points.count else { return nil }
        return points[Int(index)]
    }

    func subpath(at index: UInt16) -> SubpathRange? {
        guard index < subpaths.count else { return nil }
        return subpaths[Int(index)]
    }
}

private func point(_ x: Int32, _ y: Int32) -> Point {
    Point(x: x, y: y)
}

private func rect(_ x: Int32, _ y: Int32, _ width: Int32, _ height: Int32)
    -> Rect
{
    Rect(
        origin: point(x, y),
        size: Size(width: width, height: height)!
    )!
}

private func operation(
    _ symbol: Character = "A",
    color: Color = .red,
    width: Int32,
    cap: LineCap = .butt,
    join: LineJoin = .miter,
    origin: Point = point(0, 0),
    clip: Rect,
    points: [Point],
    subpaths: [(UInt16, UInt16)]
) -> StrokeOperationFixture {
    StrokeOperationFixture(
        symbol: symbol,
        color: color,
        lineWidth: width,
        cap: cap,
        join: join,
        origin: origin,
        clip: clip,
        points: points,
        subpaths: subpaths.map {
            SubpathRange(firstPoint: $0.0, pointCount: $0.1)!
        }
    )
}

let strokeVectors: [StrokeVectorFixture] = [
    StrokeVectorFixture(
        name: "horizontal-odd-butt",
        width: 7,
        height: 5,
        operations: [
            operation(
                width: 1,
                clip: rect(0, 0, 7, 5),
                points: [point(1, 2), point(6, 2)],
                subpaths: [(0, 2)]
            )
        ],
        expectedMask: [".......", ".AAAAA.", ".AAAAA.", ".......", "......."]
    ),
    StrokeVectorFixture(
        name: "vertical-even-butt",
        width: 5,
        height: 7,
        operations: [
            operation(
                color: .green,
                width: 2,
                clip: rect(0, 0, 5, 7),
                points: [point(2, 1), point(2, 6)],
                subpaths: [(0, 2)]
            )
        ],
        expectedMask: [".....", ".AA..", ".AA..", ".AA..", ".AA..", ".AA..", "....."]
    ),
    StrokeVectorFixture(
        name: "diagonal-round-cap",
        width: 6,
        height: 6,
        operations: [
            operation(
                color: .blue,
                width: 1,
                cap: .round,
                clip: rect(0, 0, 6, 6),
                points: [point(1, 1), point(5, 5)],
                subpaths: [(0, 2)]
            )
        ],
        expectedMask: ["......", ".A....", "..A...", "...A..", "....A.", "......"]
    ),
    StrokeVectorFixture(
        name: "single-point-subpath",
        width: 4,
        height: 4,
        operations: [
            operation(
                width: 3,
                cap: .round,
                join: .round,
                clip: rect(0, 0, 4, 4),
                points: [point(2, 2)],
                subpaths: [(0, 1)]
            )
        ],
        expectedMask: ["....", "....", "....", "...."]
    ),
    StrokeVectorFixture(
        name: "repeated-point-round-join",
        width: 7,
        height: 7,
        operations: [
            operation(
                width: 3,
                join: .round,
                clip: rect(0, 0, 7, 7),
                points: [point(1, 4), point(4, 4), point(4, 4), point(4, 1)],
                subpaths: [(0, 4)]
            )
        ],
        expectedMask: [".......", "..AAAA.", ".AAAAA.", ".AAAAA.", ".AAAA..", ".AAA...", "......."]
    ),
    StrokeVectorFixture(
        name: "zero-length-subpath",
        width: 4,
        height: 4,
        operations: [
            operation(
                width: 4,
                cap: .round,
                join: .round,
                clip: rect(0, 0, 4, 4),
                points: [point(2, 2), point(2, 2), point(2, 2)],
                subpaths: [(0, 3)]
            )
        ],
        expectedMask: ["....", "....", "....", "...."]
    ),
    StrokeVectorFixture(
        name: "right-angle-miter",
        width: 7,
        height: 7,
        operations: [
            operation(
                width: 2,
                clip: rect(0, 0, 7, 7),
                points: [point(1, 5), point(5, 5), point(5, 1)],
                subpaths: [(0, 3)]
            )
        ],
        expectedMask: [".......", "....AA.", "....AA.", "....AA.", ".AAAAA.", ".AAAAA.", "......."]
    ),
    StrokeVectorFixture(
        name: "acute-angle-miter",
        width: 10,
        height: 8,
        operations: [
            operation(
                width: 3,
                clip: rect(0, 0, 10, 8),
                points: [point(1, 6), point(5, 2), point(8, 6)],
                subpaths: [(0, 3)]
            )
        ],
        expectedMask: [
            "....AA....", "...AAAA...", "..AAAAA...", ".AAAAAAA..", "AAAAAAAAA.", "AAAA..AAA.",
            ".AA...A...", "..........",
        ]
    ),
    StrokeVectorFixture(
        name: "obtuse-angle-round",
        width: 10,
        height: 7,
        operations: [
            operation(
                width: 2,
                join: .round,
                clip: rect(0, 0, 10, 7),
                points: [point(1, 5), point(5, 3), point(9, 4)],
                subpaths: [(0, 3)]
            )
        ],
        expectedMask: [
            "..........", "..........", "....AAA...", "..AAAAAAA.", ".AAA...AA.", ".A........",
            "..........",
        ]
    ),
    StrokeVectorFixture(
        name: "collinear-same-direction",
        width: 9,
        height: 5,
        operations: [
            operation(
                width: 2,
                clip: rect(0, 0, 9, 5),
                points: [point(1, 2), point(4, 2), point(8, 2)],
                subpaths: [(0, 3)]
            )
        ],
        expectedMask: [".........", ".AAAAAAA.", ".AAAAAAA.", ".........", "........."]
    ),
    StrokeVectorFixture(
        name: "exact-reversal",
        width: 7,
        height: 5,
        operations: [
            operation(
                width: 2,
                clip: rect(0, 0, 7, 5),
                points: [point(1, 2), point(6, 2), point(2, 2)],
                subpaths: [(0, 3)]
            )
        ],
        expectedMask: [".......", ".AAAAA.", ".AAAAA.", ".......", "......."]
    ),
    StrokeVectorFixture(
        name: "miter-limit-bevel-fallback",
        width: 22,
        height: 8,
        operations: [
            operation(
                width: 4,
                clip: rect(0, 0, 22, 8),
                points: [point(1, 4), point(10, 4), point(1, 5)],
                subpaths: [(0, 3)]
            )
        ],
        expectedMask: [
            "......................", "......................", ".AAAAAAAAA............",
            ".AAAAAAAAA............", ".AAAAAAAAA............", ".AAAAAAAAA............",
            ".AAAAA................", "......................",
        ]
    ),
    StrokeVectorFixture(
        name: "negative-outside-canvas",
        width: 9,
        height: 7,
        operations: [
            operation(
                width: 1,
                cap: .round,
                origin: point(4, 3),
                clip: rect(0, 0, 9, 7),
                points: [point(-3, -2), point(4, 3)],
                subpaths: [(0, 2)]
            )
        ],
        expectedMask: [
            ".........", ".AA......", "..AA.....", "....A....", ".....AA..", "......AA.",
            ".........",
        ]
    ),
    StrokeVectorFixture(
        name: "inherited-clip-all-edges",
        width: 6,
        height: 6,
        operations: [
            operation(
                width: 8,
                clip: rect(1, 1, 4, 4),
                points: [point(-2, 3), point(8, 3)],
                subpaths: [(0, 2)]
            )
        ],
        expectedMask: ["......", ".AAAA.", ".AAAA.", ".AAAA.", ".AAAA.", "......"]
    ),
    StrokeVectorFixture(
        name: "inherited-empty-clip",
        width: 5,
        height: 5,
        operations: [
            operation(
                width: 5,
                cap: .round,
                join: .round,
                clip: rect(2, 2, 0, 2),
                points: [point(0, 2), point(5, 2)],
                subpaths: [(0, 2)]
            )
        ],
        expectedMask: [".....", ".....", ".....", ".....", "....."]
    ),
    StrokeVectorFixture(
        name: "overlap-painter-order",
        width: 7,
        height: 7,
        operations: [
            operation(
                "A",
                width: 3,
                clip: rect(0, 0, 7, 7),
                points: [point(0, 3), point(7, 3)],
                subpaths: [(0, 2)]
            ),
            operation(
                "B",
                color: .blue,
                width: 3,
                clip: rect(0, 0, 7, 7),
                points: [point(3, 0), point(3, 7)],
                subpaths: [(0, 2)]
            ),
        ],
        expectedMask: [".BBBB..", "ABBBBAA", "ABBBBAA", "ABBBBAA", "ABBBBAA", ".BBBB..", ".BBBB.."]
    ),
    StrokeVectorFixture(
        name: "rgb-rounding-boundaries",
        width: 6,
        height: 3,
        operations: [
            operation(
                "A", color: Color(red: 0, green: 0, blue: 0), width: 1,
                clip: rect(0, 0, 6, 3), points: [point(0, 0), point(0, 3)],
                subpaths: [(0, 2)]),
            operation(
                "B", color: Color(red: 1, green: 1, blue: 1), width: 1,
                clip: rect(0, 0, 6, 3), points: [point(1, 0), point(1, 3)],
                subpaths: [(0, 2)]),
            operation(
                "C", color: Color(red: 127, green: 127, blue: 127), width: 1,
                clip: rect(0, 0, 6, 3), points: [point(2, 0), point(2, 3)],
                subpaths: [(0, 2)]),
            operation(
                "D", color: Color(red: 128, green: 128, blue: 128), width: 1,
                clip: rect(0, 0, 6, 3), points: [point(3, 0), point(3, 3)],
                subpaths: [(0, 2)]),
            operation(
                "E", color: Color(red: 254, green: 254, blue: 254), width: 1,
                clip: rect(0, 0, 6, 3), points: [point(4, 0), point(4, 3)],
                subpaths: [(0, 2)]),
            operation(
                "F", color: Color(red: 255, green: 255, blue: 255), width: 1,
                clip: rect(0, 0, 6, 3), points: [point(5, 0), point(5, 3)],
                subpaths: [(0, 2)]),
        ],
        expectedMask: ["BCDEFF", "BCDEFF", "BCDEFF"]
    ),
]

@Test(arguments: strokeVectors)
private func strokeCoverageMatchesEveryIndependentSPEC012GoldenMask(
    _ fixture: StrokeVectorFixture
) {
    let bounds = rect(0, 0, fixture.width, fixture.height)
    let descriptor = RasterSurfaceDescriptor(
        bounds: bounds,
        encoding: .rgba8888,
        bytesPerRow: UInt32(fixture.width) * 4,
        realization: .fullSurface,
        regionWidth: UInt16(fixture.width),
        regionHeight: UInt16(fixture.height)
    )!
    var image = [[Character]](
        repeating: [Character](repeating: ".", count: Int(fixture.width)),
        count: Int(fixture.height)
    )

    for operation in fixture.operations {
        let stroke = FixtureStroke(
            header: StraightLineStrokeHeader(
                color: operation.color,
                lineWidth: operation.lineWidth,
                lineCap: operation.cap,
                lineJoin: operation.join,
                surfaceOrigin: operation.origin,
                inheritedClip: operation.clip,
                pointCount: UInt16(operation.points.count),
                subpathCount: UInt16(operation.subpaths.count)
            ),
            points: operation.points,
            subpaths: operation.subpaths
        )
        let result = RasterStrokeCoverage.rasterize(
            stroke,
            descriptor: descriptor,
            damageBounds: bounds
        ) { pixel, _ in
            image[Int(pixel.y)][Int(pixel.x)] = operation.symbol
            return true
        }
        guard case .completed = result else {
            Issue.record("unexpected raster result: \(result)")
            return
        }
    }

    #expect(image.map { String($0) } == fixture.expectedMask)
}

@Test
func strokeCoverageRejectsMalformedViewsBeforeReplacingPixels() {
    let bounds = rect(0, 0, 4, 4)
    let descriptor = RasterSurfaceDescriptor(
        bounds: bounds,
        encoding: .rgb565BigEndian,
        bytesPerRow: 8,
        realization: .fullSurface,
        regionWidth: 4,
        regionHeight: 4
    )!
    let malformed = FixtureStroke(
        header: StraightLineStrokeHeader(
            color: .red,
            lineWidth: 1,
            lineCap: .butt,
            lineJoin: .miter,
            surfaceOrigin: point(0, 0),
            inheritedClip: bounds,
            pointCount: 3,
            subpathCount: 1
        ),
        points: [point(0, 0), point(3, 3)],
        subpaths: [SubpathRange(firstPoint: 0, pointCount: 3)!]
    )
    var calls = 0

    let result = RasterStrokeCoverage.rasterize(
        malformed,
        descriptor: descriptor,
        damageBounds: bounds
    ) { _, _ in
        calls += 1
        return true
    }

    #expect(result == .invalidStroke)
    #expect(calls == 0)
}

@Test
func strokeCoverageReportsTranslatedPointOverflowBeforeReplacingPixels() {
    let bounds = rect(0, 0, 4, 4)
    let descriptor = RasterSurfaceDescriptor(
        bounds: bounds,
        encoding: .rgb565BigEndian,
        bytesPerRow: 8,
        realization: .fullSurface,
        regionWidth: 4,
        regionHeight: 4
    )!
    let stroke = FixtureStroke(
        header: StraightLineStrokeHeader(
            color: .red,
            lineWidth: 1,
            lineCap: .butt,
            lineJoin: .miter,
            surfaceOrigin: point(1, 0),
            inheritedClip: bounds,
            pointCount: 2,
            subpathCount: 1
        ),
        points: [point(.max, 0), point(0, 0)],
        subpaths: [SubpathRange(firstPoint: 0, pointCount: 2)!]
    )
    var calls = 0

    let result = RasterStrokeCoverage.rasterize(
        stroke,
        descriptor: descriptor,
        damageBounds: bounds
    ) { _, _ in
        calls += 1
        return true
    }

    #expect(result == .arithmeticOverflow)
    #expect(calls == 0)
}

@Test
func strokeCoverageStopsAtFirstReplacementRefusal() {
    let fixture = strokeVectors[0]
    let bounds = rect(0, 0, fixture.width, fixture.height)
    let descriptor = RasterSurfaceDescriptor(
        bounds: bounds,
        encoding: .rgba8888,
        bytesPerRow: UInt32(fixture.width) * 4,
        realization: .fullSurface,
        regionWidth: UInt16(fixture.width),
        regionHeight: UInt16(fixture.height)
    )!
    let operation = fixture.operations[0]
    let stroke = FixtureStroke(
        header: StraightLineStrokeHeader(
            color: operation.color,
            lineWidth: operation.lineWidth,
            lineCap: operation.cap,
            lineJoin: operation.join,
            surfaceOrigin: operation.origin,
            inheritedClip: operation.clip,
            pointCount: UInt16(operation.points.count),
            subpathCount: UInt16(operation.subpaths.count)
        ),
        points: operation.points,
        subpaths: operation.subpaths
    )
    var calls = 0

    let result = RasterStrokeCoverage.rasterize(
        stroke,
        descriptor: descriptor,
        damageBounds: bounds
    ) { _, _ in
        calls += 1
        return calls < 2
    }

    #expect(result == .replacementRefused)
    #expect(calls == 2)
}
