import GiftUI

public struct FramebufferBackend: RenderBackend, Sendable {
    public private(set) var surface: MemoryFramebufferSurface

    public var surfaceSize: Size {
        Size(width: surface.width, height: surface.height)
    }

    public init(surface: MemoryFramebufferSurface) {
        self.surface = surface
    }

    public mutating func beginFrame() {}

    public mutating func clear(_ color: Color) {
        fill(
            Rect(origin: Point(x: 0, y: 0), size: surfaceSize),
            color: color
        )
    }

    public mutating func fill(_ rect: Rect, color: Color) {
        let minX = max(0, rect.origin.x)
        let minY = max(0, rect.origin.y)
        let maxX = min(surface.width, rect.origin.x + rect.size.width)
        let maxY = min(surface.height, rect.origin.y + rect.size.height)
        guard minX < maxX, minY < maxY else { return }

        let bytesPerRow = surface.bytesPerRow
        surface.withUnsafeMutableBytes { bytes in
            for y in minY..<maxY {
                for x in minX..<maxX {
                    let offset = y * bytesPerRow + x * 4
                    bytes[offset] = color.red
                    bytes[offset + 1] = color.green
                    bytes[offset + 2] = color.blue
                    bytes[offset + 3] = color.alpha
                }
            }
        }
    }

    public mutating func stroke(
        _ rect: Rect,
        color: Color,
        lineWidth: Int
    ) {
        guard lineWidth > 0 else { return }
        fill(
            Rect(
                origin: rect.origin,
                size: Size(width: rect.size.width, height: lineWidth)
            ),
            color: color
        )
        fill(
            Rect(
                origin: Point(
                    x: rect.origin.x,
                    y: rect.origin.y + rect.size.height - lineWidth
                ),
                size: Size(width: rect.size.width, height: lineWidth)
            ),
            color: color
        )
        fill(
            Rect(
                origin: rect.origin,
                size: Size(width: lineWidth, height: rect.size.height)
            ),
            color: color
        )
        fill(
            Rect(
                origin: Point(
                    x: rect.origin.x + rect.size.width - lineWidth,
                    y: rect.origin.y
                ),
                size: Size(width: lineWidth, height: rect.size.height)
            ),
            color: color
        )
    }

    public mutating func drawText(_ text: TextRun, at origin: Point) {
        // Bitmap-font rasterization is introduced in the renderer milestone.
    }

    public mutating func endFrame() {}
    public mutating func present() {}
}
