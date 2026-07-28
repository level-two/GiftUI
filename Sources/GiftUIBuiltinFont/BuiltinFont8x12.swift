public struct BitmapGlyph5x7: Equatable, Sendable {
    private let row0: UInt8
    private let row1: UInt8
    private let row2: UInt8
    private let row3: UInt8
    private let row4: UInt8
    private let row5: UInt8
    private let row6: UInt8

    public init(
        _ row0: UInt8,
        _ row1: UInt8,
        _ row2: UInt8,
        _ row3: UInt8,
        _ row4: UInt8,
        _ row5: UInt8,
        _ row6: UInt8
    ) {
        self.row0 = row0
        self.row1 = row1
        self.row2 = row2
        self.row3 = row3
        self.row4 = row4
        self.row5 = row5
        self.row6 = row6
    }

    public func row(at index: Int) -> UInt8 {
        switch index {
        case 0: row0
        case 1: row1
        case 2: row2
        case 3: row3
        case 4: row4
        case 5: row5
        case 6: row6
        default: 0
        }
    }
}

/// The allocation-free 5x7 glyph data used within 8x12 GiftUI text cells.
public enum BuiltinFont8x12 {
    public static let cellWidth = 8
    public static let cellHeight = 12
    public static let glyphWidth = 5
    public static let glyphHeight = 7

    public static func glyph(forCodePoint codePoint: UInt32) -> BitmapGlyph5x7 {
        let normalized = codePoint >= 97 && codePoint <= 122
            ? codePoint - 32
            : codePoint
        switch normalized {
        case 32: return glyph(0, 0, 0, 0, 0, 0, 0)
        case 65: return glyph(0b01110, 0b10001, 0b10001, 0b11111, 0b10001, 0b10001, 0b10001)
        case 66: return glyph(0b11110, 0b10001, 0b10001, 0b11110, 0b10001, 0b10001, 0b11110)
        case 67: return glyph(0b01110, 0b10001, 0b10000, 0b10000, 0b10000, 0b10001, 0b01110)
        case 68: return glyph(0b11110, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b11110)
        case 69: return glyph(0b11111, 0b10000, 0b10000, 0b11110, 0b10000, 0b10000, 0b11111)
        case 70: return glyph(0b11111, 0b10000, 0b10000, 0b11110, 0b10000, 0b10000, 0b10000)
        case 71: return glyph(0b01110, 0b10001, 0b10000, 0b10111, 0b10001, 0b10001, 0b01110)
        case 72: return glyph(0b10001, 0b10001, 0b10001, 0b11111, 0b10001, 0b10001, 0b10001)
        case 73: return glyph(0b01110, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b01110)
        case 74: return glyph(0b00111, 0b00010, 0b00010, 0b00010, 0b10010, 0b10010, 0b01100)
        case 75: return glyph(0b10001, 0b10010, 0b10100, 0b11000, 0b10100, 0b10010, 0b10001)
        case 76: return glyph(0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b11111)
        case 77: return glyph(0b10001, 0b11011, 0b10101, 0b10101, 0b10001, 0b10001, 0b10001)
        case 78: return glyph(0b10001, 0b11001, 0b10101, 0b10011, 0b10001, 0b10001, 0b10001)
        case 79: return glyph(0b01110, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110)
        case 80: return glyph(0b11110, 0b10001, 0b10001, 0b11110, 0b10000, 0b10000, 0b10000)
        case 81: return glyph(0b01110, 0b10001, 0b10001, 0b10001, 0b10101, 0b10010, 0b01101)
        case 82: return glyph(0b11110, 0b10001, 0b10001, 0b11110, 0b10100, 0b10010, 0b10001)
        case 83: return glyph(0b01111, 0b10000, 0b10000, 0b01110, 0b00001, 0b00001, 0b11110)
        case 84: return glyph(0b11111, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100)
        case 85: return glyph(0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110)
        case 86: return glyph(0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01010, 0b00100)
        case 87: return glyph(0b10001, 0b10001, 0b10001, 0b10101, 0b10101, 0b10101, 0b01010)
        case 88: return glyph(0b10001, 0b10001, 0b01010, 0b00100, 0b01010, 0b10001, 0b10001)
        case 89: return glyph(0b10001, 0b10001, 0b01010, 0b00100, 0b00100, 0b00100, 0b00100)
        case 90: return glyph(0b11111, 0b00001, 0b00010, 0b00100, 0b01000, 0b10000, 0b11111)
        case 48: return glyph(0b01110, 0b10001, 0b10011, 0b10101, 0b11001, 0b10001, 0b01110)
        case 49: return glyph(0b00100, 0b01100, 0b00100, 0b00100, 0b00100, 0b00100, 0b01110)
        case 50: return glyph(0b01110, 0b10001, 0b00001, 0b00010, 0b00100, 0b01000, 0b11111)
        case 51: return glyph(0b11110, 0b00001, 0b00001, 0b01110, 0b00001, 0b00001, 0b11110)
        case 52: return glyph(0b00010, 0b00110, 0b01010, 0b10010, 0b11111, 0b00010, 0b00010)
        case 53: return glyph(0b11111, 0b10000, 0b10000, 0b11110, 0b00001, 0b00001, 0b11110)
        case 54: return glyph(0b01110, 0b10000, 0b10000, 0b11110, 0b10001, 0b10001, 0b01110)
        case 55: return glyph(0b11111, 0b00001, 0b00010, 0b00100, 0b01000, 0b01000, 0b01000)
        case 56: return glyph(0b01110, 0b10001, 0b10001, 0b01110, 0b10001, 0b10001, 0b01110)
        case 57: return glyph(0b01110, 0b10001, 0b10001, 0b01111, 0b00001, 0b00001, 0b01110)
        case 43: return glyph(0, 0b00100, 0b00100, 0b11111, 0b00100, 0b00100, 0)
        case 45: return glyph(0, 0, 0, 0b11111, 0, 0, 0)
        case 46: return glyph(0, 0, 0, 0, 0, 0b00110, 0b00110)
        case 44: return glyph(0, 0, 0, 0, 0b00110, 0b00100, 0b01000)
        case 58: return glyph(0, 0b00110, 0b00110, 0, 0b00110, 0b00110, 0)
        case 59: return glyph(0, 0b00110, 0b00110, 0, 0b00110, 0b00100, 0b01000)
        case 33: return glyph(0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0, 0b00100)
        case 63: return fallback
        case 47: return glyph(0b00001, 0b00010, 0b00010, 0b00100, 0b01000, 0b01000, 0b10000)
        case 92: return glyph(0b10000, 0b01000, 0b01000, 0b00100, 0b00010, 0b00010, 0b00001)
        case 40: return glyph(0b00010, 0b00100, 0b01000, 0b01000, 0b01000, 0b00100, 0b00010)
        case 41: return glyph(0b01000, 0b00100, 0b00010, 0b00010, 0b00010, 0b00100, 0b01000)
        case 91: return glyph(0b01110, 0b01000, 0b01000, 0b01000, 0b01000, 0b01000, 0b01110)
        case 93: return glyph(0b01110, 0b00010, 0b00010, 0b00010, 0b00010, 0b00010, 0b01110)
        case 95: return glyph(0, 0, 0, 0, 0, 0, 0b11111)
        case 61: return glyph(0, 0, 0b11111, 0, 0b11111, 0, 0)
        case 42: return glyph(0, 0b10101, 0b01110, 0b11111, 0b01110, 0b10101, 0)
        case 39: return glyph(0b00100, 0b00100, 0b01000, 0, 0, 0, 0)
        case 34: return glyph(0b01010, 0b01010, 0b10100, 0, 0, 0, 0)
        case 176: return glyph(0b01100, 0b10010, 0b10010, 0b01100, 0, 0, 0)
        default: return fallback
        }
    }

    public static let fallback = glyph(
        0b11111, 0b10001, 0b00010, 0b00100, 0b00100, 0, 0b00100
    )

    private static func glyph(
        _ row0: UInt8,
        _ row1: UInt8,
        _ row2: UInt8,
        _ row3: UInt8,
        _ row4: UInt8,
        _ row5: UInt8,
        _ row6: UInt8
    ) -> BitmapGlyph5x7 {
        BitmapGlyph5x7(row0, row1, row2, row3, row4, row5, row6)
    }
}
