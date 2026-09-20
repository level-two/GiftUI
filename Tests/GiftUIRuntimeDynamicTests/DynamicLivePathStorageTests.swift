import GiftUI
import GiftUIDrawing
import GiftUIRenderCore
import GiftUIRuntimeDynamic
import Testing

@Test func dynamicLivePathStorageEnforcesExactBoundsAndReusesCapacity() throws {
    var storage = DynamicLivePathStorage(
        maximumPointCount: 4,
        maximumSubpathCount: 2
    )
    var path = LivePathBuilder(storage: storage)

    try path.move(to: Point(x: 1, y: 2))
    try path.move(to: Point(x: 3, y: 4))
    try path.addLine(to: Point(x: 5, y: 6))
    try path.move(to: Point(x: 7, y: 8))
    try path.addLine(to: Point(x: 9, y: 10))

    #expect(path.storage.pointCount == 4)
    #expect(path.storage.subpathCount == 2)
    #expect(path.storage.point(at: 0) == Point(x: 3, y: 4))
    #expect(path.storage.point(at: 3) == Point(x: 9, y: 10))
    #expect(
        path.storage.subpath(at: 0)
            == SubpathRange(firstPoint: 0, pointCount: 2)
    )
    #expect(
        path.storage.subpath(at: 1)
            == SubpathRange(firstPoint: 2, pointCount: 2)
    )
    #expect(throws: DrawingError.capacityExhausted) {
        try path.addLine(to: Point(x: 11, y: 12))
    }
    #expect(path.storage.point(at: 4) == nil)
    #expect(path.storage.subpath(at: 2) == nil)

    path.reset()
    #expect(!path.isActive)
    storage = path.storage
    #expect(storage.pointCount == 0)
    #expect(storage.subpathCount == 0)

    var reused = LivePathBuilder(storage: storage)
    try reused.move(to: Point(x: 13, y: 14))
    #expect(reused.storage.pointCount == 1)
    #expect(reused.storage.subpathCount == 1)
}
