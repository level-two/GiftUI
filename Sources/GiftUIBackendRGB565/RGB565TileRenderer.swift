import GiftUI
import GiftUIBuiltinFont

public struct RGB565Tile: Equatable, Sendable {
    public let physicalX: Int
    public let physicalY: Int
    public let width: Int
    public let height: Int
    public let bytesPerRow: Int
    public let byteOrder: RGB565ByteOrder

    public var byteCount: Int {
        bytesPerRow * height
    }
}

/// Replays one logical frame into consecutive physical RGB565 row tiles.
///
/// The drawing closure is invoked once per tile so render operations never
/// need to be retained and a full-frame pixel allocation is impossible.
public struct RGB565TileRenderer: RenderBackend, RenderOperationSink, Sendable {
    public typealias Failure = Never

    public let configuration: RGB565RendererConfiguration
    private var storage: RGB565TileStorage
    private var activePhysicalX = 0
    private var activePhysicalY = 0
    private var activePhysicalWidth = 0
    private var activePhysicalHeight = 0

    public var surfaceSize: Size {
        configuration.logicalSize
    }

    public var allocatedByteCapacity: Int {
        storage.byteCapacity
    }

    public init(configuration: RGB565RendererConfiguration) {
        self.configuration = configuration
        storage = RGB565TileStorage(
            byteCapacity: configuration.tileBufferByteCapacity
        )
    }

    public mutating func renderTiles(
        drawing: (inout Self) throws -> Void,
        presenting: (
            _ tile: RGB565Tile,
            _ bytes: UnsafeRawBufferPointer
        ) throws -> Void
    ) rethrows {
        try renderTiles(
            dirtyRegion: Rect(
                origin: Point(x: 0, y: 0),
                size: configuration.logicalSize
            ),
            drawing: drawing,
            presenting: presenting
        )
    }

    /// Replays only the clipped logical dirty region into packed physical
    /// tiles. Presented rows contain no pixels outside the dirty region.
    public mutating func renderTiles(
        dirtyRegion: Rect,
        drawing: (inout Self) throws -> Void,
        presenting: (
            _ tile: RGB565Tile,
            _ bytes: UnsafeRawBufferPointer
        ) throws -> Void
    ) rethrows {
        guard let physicalBounds = physicalBounds(for: dirtyRegion) else {
            return
        }

        activePhysicalX = physicalBounds.minX
        activePhysicalWidth = physicalBounds.maxX - physicalBounds.minX
        var physicalY = physicalBounds.minY
        while physicalY < physicalBounds.maxY {
            activePhysicalY = physicalY
            activePhysicalHeight = min(
                configuration.tileHeight,
                physicalBounds.maxY - physicalY
            )
            try drawing(&self)

            let tile = RGB565Tile(
                physicalX: activePhysicalX,
                physicalY: physicalY,
                width: activePhysicalWidth,
                height: activePhysicalHeight,
                bytesPerRow: activePhysicalWidth
                    * RGB565RendererConfiguration.bytesPerPixel,
                byteOrder: configuration.byteOrder
            )
            try storage.withUnsafeBytes { storageBytes in
                let activeBytes = UnsafeRawBufferPointer(
                    start: storageBytes.baseAddress,
                    count: tile.byteCount
                )
                try presenting(tile, activeBytes)
            }
            physicalY += activePhysicalHeight
        }
        activePhysicalWidth = 0
        activePhysicalHeight = 0
    }

    public mutating func append(_ operation: RenderOperation) {
        execute(operation)
    }

    public mutating func beginFrame() {}

    public mutating func clear(_ color: Color) {
        fill(
            Rect(
                origin: Point(x: 0, y: 0),
                size: surfaceSize
            ),
            color: color
        )
    }

    public mutating func fill(_ rect: Rect, color: Color) {
        guard activePhysicalHeight > 0,
              let bounds = clippedLogicalBounds(for: rect) else {
            return
        }
        let pixel = RGB565Pixel(color)
        let bytesPerRow = activePhysicalWidth
            * RGB565RendererConfiguration.bytesPerPixel
        let activePhysicalX = self.activePhysicalX
        let activePhysicalY = self.activePhysicalY
        let byteOrder = configuration.byteOrder
        let configuration = self.configuration

        storage.withUnsafeMutableBytes { bytes in
            for logicalY in bounds.minY..<bounds.maxY {
                for logicalX in bounds.minX..<bounds.maxX {
                    let physical = Self.physicalPoint(
                        logicalX: logicalX,
                        logicalY: logicalY,
                        configuration: configuration
                    )
                    let offset = (physical.y - activePhysicalY) * bytesPerRow
                        + (physical.x - activePhysicalX)
                            * RGB565RendererConfiguration.bytesPerPixel
                    bytes[offset] = pixel.byte(at: 0, order: byteOrder)
                    bytes[offset + 1] = pixel.byte(at: 1, order: byteOrder)
                }
            }
        }
    }

    public mutating func stroke(
        _ rect: Rect,
        color: Color,
        lineWidth: Int
    ) {
        guard lineWidth > 0, rect.size.width > 0, rect.size.height > 0 else {
            return
        }
        let horizontalThickness = min(lineWidth, rect.size.height)
        let verticalThickness = min(lineWidth, rect.size.width)
        fill(
            Rect(
                origin: rect.origin,
                size: Size(width: rect.size.width, height: horizontalThickness)
            ),
            color: color
        )
        fill(
            Rect(
                origin: Point(
                    x: rect.origin.x,
                    y: saturatingAdd(
                        rect.origin.y,
                        rect.size.height - horizontalThickness
                    )
                ),
                size: Size(width: rect.size.width, height: horizontalThickness)
            ),
            color: color
        )
        fill(
            Rect(
                origin: rect.origin,
                size: Size(width: verticalThickness, height: rect.size.height)
            ),
            color: color
        )
        fill(
            Rect(
                origin: Point(
                    x: saturatingAdd(
                        rect.origin.x,
                        rect.size.width - verticalThickness
                    ),
                    y: rect.origin.y
                ),
                size: Size(width: verticalThickness, height: rect.size.height)
            ),
            color: color
        )
    }

    public mutating func drawText(_ text: TextRun, at origin: Point) {
        var decoder = UTF8CodePointDecoder()
        var glyphOriginX = origin.x
        text.forEachUTF8CodeUnit { byte in
            guard let codePoint = decoder.decode(byte) else { return }
            drawGlyph(
                BuiltinFont8x12.glyph(forCodePoint: codePoint),
                at: Point(x: glyphOriginX, y: origin.y),
                color: text.color
            )
            glyphOriginX = saturatingAdd(
                glyphOriginX,
                BuiltinFont8x12.cellWidth
            )
        }
    }

    public mutating func endFrame() {}
    public mutating func present() {}

    private mutating func drawGlyph(
        _ glyph: BitmapGlyph5x7,
        at origin: Point,
        color: Color
    ) {
        for rowIndex in 0..<BuiltinFont8x12.glyphHeight {
            let rowBits = glyph.row(at: rowIndex)
            for column in 0..<BuiltinFont8x12.glyphWidth {
                let mask = UInt8(1 << (BuiltinFont8x12.glyphWidth - 1 - column))
                guard rowBits & mask != 0 else { continue }
                fill(
                    Rect(
                        origin: Point(
                            x: saturatingAdd(origin.x, 1 + column),
                            y: saturatingAdd(origin.y, 2 + rowIndex)
                        ),
                        size: Size(width: 1, height: 1)
                    ),
                    color: color
                )
            }
        }
    }

    private func clippedLogicalBounds(for rect: Rect) -> LogicalBounds? {
        guard rect.size.width > 0, rect.size.height > 0 else { return nil }
        var minX = max(0, rect.origin.x)
        var minY = max(0, rect.origin.y)
        var maxX = min(surfaceSize.width, saturatingAdd(rect.origin.x, rect.size.width))
        var maxY = min(surfaceSize.height, saturatingAdd(rect.origin.y, rect.size.height))

        let tileMaxX = activePhysicalX + activePhysicalWidth
        let tileMaxY = activePhysicalY + activePhysicalHeight
        switch configuration.rotation {
        case .degrees0:
            minX = max(minX, activePhysicalX)
            maxX = min(maxX, tileMaxX)
            minY = max(minY, activePhysicalY)
            maxY = min(maxY, tileMaxY)
        case .degrees90:
            minX = max(minX, activePhysicalY)
            maxX = min(maxX, tileMaxY)
            minY = max(minY, configuration.physicalWidth - tileMaxX)
            maxY = min(maxY, configuration.physicalWidth - activePhysicalX)
        case .degrees180:
            minX = max(minX, configuration.physicalWidth - tileMaxX)
            maxX = min(maxX, configuration.physicalWidth - activePhysicalX)
            minY = max(minY, configuration.physicalHeight - tileMaxY)
            maxY = min(maxY, configuration.physicalHeight - activePhysicalY)
        case .degrees270:
            minX = max(minX, configuration.physicalHeight - tileMaxY)
            maxX = min(maxX, configuration.physicalHeight - activePhysicalY)
            minY = max(minY, activePhysicalX)
            maxY = min(maxY, tileMaxX)
        }
        guard minX < maxX, minY < maxY else { return nil }
        return LogicalBounds(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
    }

    private func physicalBounds(for rect: Rect) -> PhysicalBounds? {
        guard let logicalBounds = clippedSurfaceBounds(for: rect) else {
            return nil
        }
        let corners = (
            physicalPoint(
                logicalX: logicalBounds.minX,
                logicalY: logicalBounds.minY
            ),
            physicalPoint(
                logicalX: logicalBounds.maxX - 1,
                logicalY: logicalBounds.minY
            ),
            physicalPoint(
                logicalX: logicalBounds.minX,
                logicalY: logicalBounds.maxY - 1
            ),
            physicalPoint(
                logicalX: logicalBounds.maxX - 1,
                logicalY: logicalBounds.maxY - 1
            )
        )
        let minimumX = min(min(corners.0.x, corners.1.x), min(corners.2.x, corners.3.x))
        let minimumY = min(min(corners.0.y, corners.1.y), min(corners.2.y, corners.3.y))
        let maximumX = max(max(corners.0.x, corners.1.x), max(corners.2.x, corners.3.x))
        let maximumY = max(max(corners.0.y, corners.1.y), max(corners.2.y, corners.3.y))
        return PhysicalBounds(
            minX: minimumX,
            minY: minimumY,
            maxX: maximumX + 1,
            maxY: maximumY + 1
        )
    }

    private func clippedSurfaceBounds(for rect: Rect) -> LogicalBounds? {
        guard rect.size.width > 0, rect.size.height > 0 else { return nil }
        let minX = max(0, rect.origin.x)
        let minY = max(0, rect.origin.y)
        let maxX = min(surfaceSize.width, saturatingAdd(rect.origin.x, rect.size.width))
        let maxY = min(surfaceSize.height, saturatingAdd(rect.origin.y, rect.size.height))
        guard minX < maxX, minY < maxY else { return nil }
        return LogicalBounds(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
    }

    private func physicalPoint(logicalX: Int, logicalY: Int) -> Point {
        Self.physicalPoint(
            logicalX: logicalX,
            logicalY: logicalY,
            configuration: configuration
        )
    }

    private static func physicalPoint(
        logicalX: Int,
        logicalY: Int,
        configuration: RGB565RendererConfiguration
    ) -> Point {
        switch configuration.rotation {
        case .degrees0:
            Point(x: logicalX, y: logicalY)
        case .degrees90:
            Point(
                x: configuration.physicalWidth - 1 - logicalY,
                y: logicalX
            )
        case .degrees180:
            Point(
                x: configuration.physicalWidth - 1 - logicalX,
                y: configuration.physicalHeight - 1 - logicalY
            )
        case .degrees270:
            Point(
                x: logicalY,
                y: configuration.physicalHeight - 1 - logicalX
            )
        }
    }

    private func saturatingAdd(_ lhs: Int, _ rhs: Int) -> Int {
        let (result, overflow) = lhs.addingReportingOverflow(rhs)
        return overflow ? Int.max : result
    }
}

private struct LogicalBounds {
    let minX: Int
    let minY: Int
    let maxX: Int
    let maxY: Int
}

private struct PhysicalBounds {
    let minX: Int
    let minY: Int
    let maxX: Int
    let maxY: Int
}

private struct UTF8CodePointDecoder {
    private var codePoint: UInt32 = 0
    private var continuationCount = 0

    mutating func decode(_ byte: UInt8) -> UInt32? {
        if continuationCount == 0 {
            switch byte {
            case 0x00...0x7f:
                return UInt32(byte)
            case 0xc2...0xdf:
                codePoint = UInt32(byte & 0x1f)
                continuationCount = 1
            case 0xe0...0xef:
                codePoint = UInt32(byte & 0x0f)
                continuationCount = 2
            case 0xf0...0xf4:
                codePoint = UInt32(byte & 0x07)
                continuationCount = 3
            default:
                return 0xfffd
            }
            return nil
        }

        guard byte & 0xc0 == 0x80 else {
            continuationCount = 0
            codePoint = 0
            return 0xfffd
        }
        codePoint = codePoint << 6 | UInt32(byte & 0x3f)
        continuationCount -= 1
        guard continuationCount == 0 else { return nil }
        let decoded = codePoint
        codePoint = 0
        return decoded
    }
}
