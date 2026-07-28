import GiftUI
import GiftUIBuiltinFont

enum BitmapTextRasterizer {
    static func draw(
        _ text: TextRun,
        at origin: Point,
        surface: inout MemoryFramebufferSurface
    ) {
        let width = surface.width
        let height = surface.height
        let bytesPerRow = surface.bytesPerRow

        surface.withUnsafeMutableBytes { bytes in
            var glyphOriginX = origin.x
            for scalar in text.content.unicodeScalars {
                let glyph = BuiltinFont8x12.glyph(forCodePoint: scalar.value)
                for rowIndex in 0..<BuiltinFont8x12.glyphHeight {
                    let rowBits = glyph.row(at: rowIndex)
                    let y = origin.y + 2 + rowIndex
                    guard y >= 0, y < height else { continue }

                    for column in 0..<5 {
                        let mask = UInt8(1 << (4 - column))
                        guard rowBits & mask != 0 else { continue }

                        let x = glyphOriginX + 1 + column
                        guard x >= 0, x < width else { continue }

                        let offset = y * bytesPerRow + x * 4
                        bytes[offset] = text.color.red
                        bytes[offset + 1] = text.color.green
                        bytes[offset + 2] = text.color.blue
                        bytes[offset + 3] = text.color.alpha
                    }
                }
                glyphOriginX += BuiltinFont8x12.cellWidth
            }
        }
    }
}
