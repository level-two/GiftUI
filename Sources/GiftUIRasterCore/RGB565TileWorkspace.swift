import GiftUI
import GiftUICapabilities
import GiftUISurfaceCore

package protocol RGB565TileStorage {
    var byteCapacity: UInt32 { get }
    var pixelCapacity: UInt32 { get }

    mutating func reset(byteCount: UInt32, pixelCount: UInt32) -> Bool
    mutating func store(
        mostSignificantByte: UInt8,
        leastSignificantByte: UInt8,
        byteOffset: UInt32,
        pixelIndex: UInt32
    ) -> Bool
    borrowing func isAffected(pixelIndex: UInt32) -> Bool
    borrowing func byte(at offset: UInt32) -> UInt8?
}

package struct RGB565TileWorkspace<Storage>
where Storage: RGB565TileStorage {
    package let descriptor: RasterSurfaceDescriptor
    package private(set) var storage: Storage
    package private(set) var activeTile: Rect?

    package init?(
        descriptor: RasterSurfaceDescriptor,
        storage: consuming Storage
    ) {
        let requiredBytes = descriptor.bytesPerRow.multipliedReportingOverflow(
            by: UInt32(descriptor.regionHeight)
        )
        let requiredPixels = UInt32(descriptor.regionWidth)
            .multipliedReportingOverflow(by: UInt32(descriptor.regionHeight))
        guard descriptor.encoding == .rgb565BigEndian,
            descriptor.realization == .tiled,
            !requiredBytes.overflow,
            !requiredPixels.overflow,
            storage.byteCapacity >= requiredBytes.partialValue,
            storage.pixelCapacity >= requiredPixels.partialValue
        else { return nil }
        self.descriptor = descriptor
        self.storage = storage
    }

    package mutating func beginTile(_ tile: Rect) -> Bool {
        guard activeTile == nil,
            tile.minX == descriptor.bounds.minX,
            tile.size.width == descriptor.bounds.size.width,
            tile.size.height > 0,
            tile.size.height <= Int32(descriptor.regionHeight),
            contains(descriptor.bounds, tile)
        else { return false }
        let byteCount = descriptor.bytesPerRow.multipliedReportingOverflow(
            by: UInt32(tile.size.height)
        )
        let pixelCount = UInt32(descriptor.regionWidth)
            .multipliedReportingOverflow(by: UInt32(tile.size.height))
        guard !byteCount.overflow, !pixelCount.overflow,
            storage.reset(
                byteCount: byteCount.partialValue,
                pixelCount: pixelCount.partialValue
            )
        else { return false }
        activeTile = tile
        return true
    }

    package mutating func replacePixel(
        at point: Point,
        with pixel: CanonicalEncodedPixel
    ) -> Bool {
        guard let activeTile, activeTile.contains(point),
            pixel.encoding == .rgb565BigEndian,
            pixel.byteCount == 2
        else { return false }
        let localY = point.y - activeTile.minY
        let rowOffset = UInt32(localY).multipliedReportingOverflow(
            by: descriptor.bytesPerRow
        )
        let columnOffset = UInt32(point.x).multipliedReportingOverflow(by: 2)
        let pixelRow = UInt32(localY).multipliedReportingOverflow(
            by: UInt32(descriptor.regionWidth)
        )
        guard !rowOffset.overflow, !columnOffset.overflow, !pixelRow.overflow else {
            return false
        }
        let byteOffset = rowOffset.partialValue.addingReportingOverflow(
            columnOffset.partialValue
        )
        let pixelIndex = pixelRow.partialValue.addingReportingOverflow(
            UInt32(point.x)
        )
        guard !byteOffset.overflow, !pixelIndex.overflow else { return false }
        return storage.store(
            mostSignificantByte: pixel.byte0,
            leastSignificantByte: pixel.byte1,
            byteOffset: byteOffset.partialValue,
            pixelIndex: pixelIndex.partialValue
        )
    }

    package mutating func finishTile() -> Bool {
        guard activeTile != nil else { return false }
        activeTile = nil
        return true
    }

    private func contains(_ outer: Rect, _ inner: Rect) -> Bool {
        inner.minX >= outer.minX && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX && inner.maxY <= outer.maxY
    }
}
