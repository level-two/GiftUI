import GiftUI
import GiftUIBuiltinFont

/// A transport that writes one solid RGB565 rectangle into retained display
/// memory. The display is expected to preserve all pixels outside `rect`.
public protocol RGB565SolidRectWriter {
    mutating func writeSolidRect(
        _ rect: Rect,
        pixel: RGB565Pixel
    )
}

/// Replays render operations as clipped solid rectangles into a display's
/// retained GRAM. It owns no pixel buffer; the display controller is the
/// backing store between updates.
public struct RGB565RetainedRenderer<Writer: RGB565SolidRectWriter>:
    RenderOperationSink
{
    public typealias Failure = Never

    public let configuration: RGB565RendererConfiguration
    public let clipRegion: Rect
    public private(set) var writer: Writer

    public init(
        configuration: RGB565RendererConfiguration,
        clipRegion: Rect? = nil,
        writer: Writer
    ) {
        self.configuration = configuration
        self.clipRegion = clipRegion ?? Rect(
            origin: Point(x: 0, y: 0),
            size: configuration.logicalSize
        )
        self.writer = writer
    }

    public mutating func append(_ operation: RenderOperation) {
        switch operation {
        case .fillRect(let rect, let color):
            fill(rect, color: color)
        case .strokeRect(let rect, let color, let lineWidth):
            stroke(rect, color: color, lineWidth: lineWidth)
        case .text(let text, let origin):
            drawText(text, at: origin)
        }
    }

    public mutating func clear(_ color: Color) {
        fill(
            Rect(origin: Point(x: 0, y: 0), size: configuration.logicalSize),
            color: color
        )
    }

    public mutating func fill(
        _ rect: Rect,
        color: Color
    ) {
        guard let logicalRect = clippedLogicalRect(rect) else { return }
        writer.writeSolidRect(
            physicalRect(for: logicalRect),
            pixel: RGB565Pixel(color)
        )
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

    public mutating func drawText(
        _ text: TextRun,
        at origin: Point
    ) {
        var decoder = RetainedUTF8CodePointDecoder()
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

    private mutating func drawGlyph(
        _ glyph: BitmapGlyph5x7,
        at origin: Point,
        color: Color
    ) {
        for rowIndex in 0..<BuiltinFont8x12.glyphHeight {
            let rowBits = glyph.row(at: rowIndex)
            var column = 0
            while column < BuiltinFont8x12.glyphWidth {
                let mask = UInt8(
                    1 << (BuiltinFont8x12.glyphWidth - 1 - column)
                )
                guard rowBits & mask != 0 else {
                    column += 1
                    continue
                }
                let runStart = column
                column += 1
                while column < BuiltinFont8x12.glyphWidth {
                    let nextMask = UInt8(
                        1 << (BuiltinFont8x12.glyphWidth - 1 - column)
                    )
                    guard rowBits & nextMask != 0 else { break }
                    column += 1
                }
                fill(
                    Rect(
                        origin: Point(
                            x: saturatingAdd(origin.x, 1 + runStart),
                            y: saturatingAdd(origin.y, 2 + rowIndex)
                        ),
                        size: Size(width: column - runStart, height: 1)
                    ),
                    color: color
                )
            }
        }
    }

    private func clippedLogicalRect(_ rect: Rect) -> Rect? {
        guard rect.size.width > 0, rect.size.height > 0,
              clipRegion.size.width > 0, clipRegion.size.height > 0 else {
            return nil
        }
        let surface = Rect(
            origin: Point(x: 0, y: 0),
            size: configuration.logicalSize
        )
        guard let surfaceIntersection = intersection(rect, surface),
              let clipped = intersection(surfaceIntersection, clipRegion) else {
            return nil
        }
        return clipped
    }

    private func intersection(_ lhs: Rect, _ rhs: Rect) -> Rect? {
        let minX = max(lhs.origin.x, rhs.origin.x)
        let minY = max(lhs.origin.y, rhs.origin.y)
        let maxX = min(
            saturatingAdd(lhs.origin.x, lhs.size.width),
            saturatingAdd(rhs.origin.x, rhs.size.width)
        )
        let maxY = min(
            saturatingAdd(lhs.origin.y, lhs.size.height),
            saturatingAdd(rhs.origin.y, rhs.size.height)
        )
        guard minX < maxX, minY < maxY else { return nil }
        return Rect(
            origin: Point(x: minX, y: minY),
            size: Size(width: maxX - minX, height: maxY - minY)
        )
    }

    private func physicalRect(for logicalRect: Rect) -> Rect {
        let minX = logicalRect.origin.x
        let minY = logicalRect.origin.y
        let maxX = minX + logicalRect.size.width - 1
        let maxY = minY + logicalRect.size.height - 1
        let corners = (
            physicalPoint(logicalX: minX, logicalY: minY),
            physicalPoint(logicalX: maxX, logicalY: minY),
            physicalPoint(logicalX: minX, logicalY: maxY),
            physicalPoint(logicalX: maxX, logicalY: maxY)
        )
        let physicalMinX = min(
            min(corners.0.x, corners.1.x),
            min(corners.2.x, corners.3.x)
        )
        let physicalMinY = min(
            min(corners.0.y, corners.1.y),
            min(corners.2.y, corners.3.y)
        )
        let physicalMaxX = max(
            max(corners.0.x, corners.1.x),
            max(corners.2.x, corners.3.x)
        )
        let physicalMaxY = max(
            max(corners.0.y, corners.1.y),
            max(corners.2.y, corners.3.y)
        )
        return Rect(
            origin: Point(x: physicalMinX, y: physicalMinY),
            size: Size(
                width: physicalMaxX - physicalMinX + 1,
                height: physicalMaxY - physicalMinY + 1
            )
        )
    }

    private func physicalPoint(logicalX: Int, logicalY: Int) -> Point {
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

private struct RetainedUTF8CodePointDecoder {
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
