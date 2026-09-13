import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import GiftUISurfaceCore
import Testing

@testable import GiftUIRasterCore

private let fillSurfaceBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 4, height: 3)!
)!
private let fillDescriptor = RasterSurfaceDescriptor(
    bounds: fillSurfaceBounds,
    encoding: .rgba8888,
    bytesPerRow: 19,
    realization: .fullSurface,
    regionWidth: 4,
    regionHeight: 3
)!

private func fillRect(
    x: Int32,
    y: Int32,
    width: Int32,
    height: Int32,
    clip: Rect = fillSurfaceBounds,
    color: Color = .red
) -> FillRectOperation {
    FillRectOperation(
        bounds: Rect(
            origin: Point(x: x, y: y),
            size: Size(width: width, height: height)!
        )!,
        clip: clip,
        color: color
    )
}

@Test
func fillCoverageUsesHalfOpenSurfaceDamageAndResolvedClipIntersection() {
    let damage = Rect(
        origin: Point(x: 1, y: 0),
        size: Size(width: 3, height: 3)!
    )!
    let clip = Rect(
        origin: Point(x: 0, y: 1),
        size: Size(width: 3, height: 2)!
    )!
    var points: [Point] = []

    let result = RasterFillCoverage.rasterize(
        fillRect(x: -2, y: -1, width: 8, height: 5, clip: clip),
        descriptor: fillDescriptor,
        damageBounds: damage
    ) { point, _ in
        points.append(point)
        return true
    }

    #expect(result == .completed(pixelCount: 4))
    #expect(
        points == [
            Point(x: 1, y: 1),
            Point(x: 2, y: 1),
            Point(x: 1, y: 2),
            Point(x: 2, y: 2),
        ]
    )
}

@Test
func fillCoverageTreatsEveryTouchingOrClippedIntersectionAsEmpty() {
    let cases = [
        fillRect(x: 4, y: 0, width: 2, height: 1),
        fillRect(x: -2, y: 0, width: 2, height: 1),
        fillRect(x: 0, y: 3, width: 1, height: 1),
        fillRect(x: 0, y: -1, width: 1, height: 1),
        fillRect(x: 0, y: 0, width: 0, height: 1),
    ]

    for operation in cases {
        var calls = 0
        let result = RasterFillCoverage.rasterize(
            operation,
            descriptor: fillDescriptor,
            damageBounds: fillSurfaceBounds
        ) { _, _ in
            calls += 1
            return true
        }
        #expect(result == .completed(pixelCount: 0))
        #expect(calls == 0)
    }
}

@Test
func fillCoverageRejectsDamageOutsideSurfaceBeforeReplacement() {
    let invalidDamage = Rect(
        origin: Point(x: -1, y: 0),
        size: Size(width: 2, height: 1)!
    )!
    var calls = 0

    let result = RasterFillCoverage.rasterize(
        fillRect(x: 0, y: 0, width: 1, height: 1),
        descriptor: fillDescriptor,
        damageBounds: invalidDamage
    ) { _, _ in
        calls += 1
        return true
    }

    #expect(result == .invalidGeometry)
    #expect(calls == 0)
}

@Test
func laterOpaqueFillsReplaceEarlierPixelsInPainterOrder() {
    var image = [CanonicalEncodedPixel?](repeating: nil, count: 12)
    var calls: [Point] = []
    let first = fillRect(x: 0, y: 0, width: 3, height: 2, color: .red)
    let second = fillRect(x: 1, y: 1, width: 3, height: 2, color: .blue)

    for operation in [first, second] {
        let result = RasterFillCoverage.rasterize(
            operation,
            descriptor: fillDescriptor,
            damageBounds: fillSurfaceBounds
        ) { point, pixel in
            calls.append(point)
            image[Int(point.y * 4 + point.x)] = pixel
            return true
        }
        #expect(result == .completed(pixelCount: 6))
    }

    let red = CanonicalEncodedPixel(color: .red, encoding: .rgba8888)
    let blue = CanonicalEncodedPixel(color: .blue, encoding: .rgba8888)
    #expect(image[0] == red)
    #expect(image[4] == red)
    #expect(image[5] == blue)
    #expect(image[6] == blue)
    #expect(image[11] == blue)
    #expect(calls.count == 12)
}

@Test
func fillCoverageStopsAtFirstReplacementRefusal() {
    var points: [Point] = []
    let result = RasterFillCoverage.rasterize(
        fillRect(x: 0, y: 0, width: 3, height: 1),
        descriptor: fillDescriptor,
        damageBounds: fillSurfaceBounds
    ) { point, _ in
        points.append(point)
        return points.count < 2
    }

    #expect(result == .replacementRefused)
    #expect(points == [Point(x: 0, y: 0), Point(x: 1, y: 0)])
}
