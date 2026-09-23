// Generated from ReferenceCatalogue.generated.swift by scripts/contracts/generate-spec-001-nrf-font.rb. Do not edit.
package enum StaticSignalAnalyzerNRFReferenceMetrics {
    package static let ascent: Int16 = 16
    package static let descent: Int16 = 4
    package static let lineGap: Int16 = 0
    package static let replacementGlyph: UInt16 = 0
    package static let glyphCount: UInt16 = 102
    package static let mappingCount: UInt16 = 96

    package struct Metric: Equatable {
        package let advanceX: Int16
        package let offsetX: Int16
        package let offsetY: Int16
        package let width: Int16
        package let height: Int16
    }

    package static func glyph(for scalar: UInt32) -> UInt16? {
        switch scalar {
        case 0x0020: return 100
        case 0x0021: return 67
        case 0x0022: return 83
        case 0x0023: return 76
        case 0x0024: return 55
        case 0x0025: return 97
        case 0x0026: return 66
        case 0x0027: return 82
        case 0x0028: return 69
        case 0x0029: return 70
        case 0x002a: return 95
        case 0x002b: return 91
        case 0x002c: return 84
        case 0x002d: return 80
        case 0x002e: return 85
        case 0x002f: return 77
        case 0x0030: return 56
        case 0x0031: return 57
        case 0x0032: return 58
        case 0x0033: return 59
        case 0x0034: return 60
        case 0x0035: return 61
        case 0x0036: return 62
        case 0x0037: return 63
        case 0x0038: return 64
        case 0x0039: return 65
        case 0x003a: return 86
        case 0x003b: return 87
        case 0x003c: return 88
        case 0x003d: return 90
        case 0x003e: return 89
        case 0x003f: return 68
        case 0x0040: return 75
        case 0x0041: return 1
        case 0x0042: return 2
        case 0x0043: return 3
        case 0x0044: return 4
        case 0x0045: return 5
        case 0x0046: return 6
        case 0x0047: return 7
        case 0x0048: return 8
        case 0x0049: return 9
        case 0x004a: return 10
        case 0x004b: return 11
        case 0x004c: return 12
        case 0x004d: return 13
        case 0x004e: return 14
        case 0x004f: return 15
        case 0x0050: return 16
        case 0x0051: return 17
        case 0x0052: return 18
        case 0x0053: return 19
        case 0x0054: return 20
        case 0x0055: return 21
        case 0x0056: return 22
        case 0x0057: return 23
        case 0x0058: return 24
        case 0x0059: return 25
        case 0x005a: return 26
        case 0x005b: return 71
        case 0x005c: return 79
        case 0x005d: return 72
        case 0x005e: return 94
        case 0x005f: return 93
        case 0x0060: return 98
        case 0x0061: return 27
        case 0x0062: return 28
        case 0x0063: return 29
        case 0x0064: return 30
        case 0x0065: return 31
        case 0x0066: return 32
        case 0x0067: return 33
        case 0x0068: return 34
        case 0x0069: return 35
        case 0x006a: return 38
        case 0x006b: return 39
        case 0x006c: return 40
        case 0x006d: return 41
        case 0x006e: return 42
        case 0x006f: return 43
        case 0x0070: return 44
        case 0x0071: return 45
        case 0x0072: return 46
        case 0x0073: return 47
        case 0x0074: return 48
        case 0x0075: return 49
        case 0x0076: return 50
        case 0x0077: return 51
        case 0x0078: return 52
        case 0x0079: return 53
        case 0x007a: return 54
        case 0x007b: return 73
        case 0x007c: return 78
        case 0x007d: return 74
        case 0x007e: return 92
        case 0x00b0: return 96
        default: return nil
        }
    }

    package static func metric(for glyph: UInt16) -> Metric? {
        switch glyph {
        case 0: return Metric(advanceX: 11, offsetX: 0, offsetY: -15, width: 11, height: 19)
        case 1: return Metric(advanceX: 11, offsetX: 0, offsetY: -12, width: 11, height: 12)
        case 2: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 3: return Metric(advanceX: 12, offsetX: 0, offsetY: -12, width: 12, height: 12)
        case 4: return Metric(advanceX: 12, offsetX: 0, offsetY: -12, width: 12, height: 12)
        case 5: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 6: return Metric(advanceX: 9, offsetX: 0, offsetY: -12, width: 9, height: 12)
        case 7: return Metric(advanceX: 12, offsetX: 0, offsetY: -12, width: 12, height: 12)
        case 8: return Metric(advanceX: 12, offsetX: 0, offsetY: -12, width: 12, height: 12)
        case 9: return Metric(advanceX: 4, offsetX: 0, offsetY: -12, width: 4, height: 12)
        case 10: return Metric(advanceX: 9, offsetX: 0, offsetY: -12, width: 9, height: 12)
        case 11: return Metric(advanceX: 11, offsetX: 0, offsetY: -12, width: 11, height: 12)
        case 12: return Metric(advanceX: 9, offsetX: 0, offsetY: -12, width: 9, height: 12)
        case 13: return Metric(advanceX: 14, offsetX: 0, offsetY: -12, width: 14, height: 12)
        case 14: return Metric(advanceX: 12, offsetX: 0, offsetY: -12, width: 12, height: 12)
        case 15: return Metric(advanceX: 12, offsetX: 0, offsetY: -12, width: 12, height: 12)
        case 16: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 17: return Metric(advanceX: 12, offsetX: 0, offsetY: -12, width: 12, height: 13)
        case 18: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 19: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 20: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 21: return Metric(advanceX: 12, offsetX: 0, offsetY: -12, width: 12, height: 12)
        case 22: return Metric(advanceX: 11, offsetX: 0, offsetY: -12, width: 11, height: 12)
        case 23: return Metric(advanceX: 16, offsetX: 0, offsetY: -12, width: 16, height: 12)
        case 24: return Metric(advanceX: 11, offsetX: 0, offsetY: -12, width: 11, height: 12)
        case 25: return Metric(advanceX: 11, offsetX: 0, offsetY: -12, width: 11, height: 12)
        case 26: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 27: return Metric(advanceX: 9, offsetX: 0, offsetY: -9, width: 9, height: 9)
        case 28: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 29: return Metric(advanceX: 9, offsetX: 0, offsetY: -9, width: 9, height: 9)
        case 30: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 31: return Metric(advanceX: 9, offsetX: 0, offsetY: -9, width: 9, height: 9)
        case 32: return Metric(advanceX: 6, offsetX: 0, offsetY: -12, width: 6, height: 12)
        case 33: return Metric(advanceX: 10, offsetX: 0, offsetY: -9, width: 10, height: 12)
        case 34: return Metric(advanceX: 9, offsetX: 0, offsetY: -12, width: 9, height: 12)
        case 35: return Metric(advanceX: 4, offsetX: 0, offsetY: -13, width: 4, height: 13)
        case 36: return Metric(advanceX: 4, offsetX: 0, offsetY: -9, width: 4, height: 9)
        case 37: return Metric(advanceX: 4, offsetX: -1, offsetY: -9, width: 5, height: 12)
        case 38: return Metric(advanceX: 4, offsetX: -1, offsetY: -13, width: 5, height: 16)
        case 39: return Metric(advanceX: 9, offsetX: 0, offsetY: -12, width: 9, height: 12)
        case 40: return Metric(advanceX: 4, offsetX: 0, offsetY: -12, width: 4, height: 12)
        case 41: return Metric(advanceX: 14, offsetX: 0, offsetY: -9, width: 14, height: 9)
        case 42: return Metric(advanceX: 9, offsetX: 0, offsetY: -9, width: 9, height: 9)
        case 43: return Metric(advanceX: 10, offsetX: 0, offsetY: -9, width: 10, height: 9)
        case 44: return Metric(advanceX: 10, offsetX: 0, offsetY: -9, width: 10, height: 12)
        case 45: return Metric(advanceX: 10, offsetX: 0, offsetY: -9, width: 10, height: 12)
        case 46: return Metric(advanceX: 6, offsetX: 0, offsetY: -9, width: 6, height: 9)
        case 47: return Metric(advanceX: 8, offsetX: 0, offsetY: -9, width: 8, height: 9)
        case 48: return Metric(advanceX: 5, offsetX: 0, offsetY: -11, width: 5, height: 11)
        case 49: return Metric(advanceX: 9, offsetX: 0, offsetY: -9, width: 9, height: 9)
        case 50: return Metric(advanceX: 9, offsetX: 0, offsetY: -9, width: 9, height: 9)
        case 51: return Metric(advanceX: 13, offsetX: 0, offsetY: -9, width: 13, height: 9)
        case 52: return Metric(advanceX: 9, offsetX: 0, offsetY: -9, width: 9, height: 9)
        case 53: return Metric(advanceX: 9, offsetX: 0, offsetY: -9, width: 9, height: 12)
        case 54: return Metric(advanceX: 9, offsetX: 0, offsetY: -9, width: 9, height: 9)
        case 55: return Metric(advanceX: 10, offsetX: 0, offsetY: -14, width: 10, height: 16)
        case 56: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 57: return Metric(advanceX: 7, offsetX: 0, offsetY: -12, width: 7, height: 12)
        case 58: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 59: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 60: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 61: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 62: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 63: return Metric(advanceX: 9, offsetX: 0, offsetY: -12, width: 9, height: 12)
        case 64: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 65: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 66: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 11, height: 12)
        case 67: return Metric(advanceX: 5, offsetX: 0, offsetY: -12, width: 5, height: 12)
        case 68: return Metric(advanceX: 8, offsetX: 0, offsetY: -12, width: 8, height: 12)
        case 69: return Metric(advanceX: 6, offsetX: 0, offsetY: -13, width: 6, height: 15)
        case 70: return Metric(advanceX: 6, offsetX: 0, offsetY: -13, width: 6, height: 15)
        case 71: return Metric(advanceX: 6, offsetX: 0, offsetY: -14, width: 6, height: 17)
        case 72: return Metric(advanceX: 6, offsetX: 0, offsetY: -14, width: 6, height: 17)
        case 73: return Metric(advanceX: 7, offsetX: 0, offsetY: -12, width: 7, height: 16)
        case 74: return Metric(advanceX: 7, offsetX: 0, offsetY: -12, width: 7, height: 16)
        case 75: return Metric(advanceX: 15, offsetX: 0, offsetY: -13, width: 15, height: 16)
        case 76: return Metric(advanceX: 10, offsetX: 0, offsetY: -12, width: 10, height: 12)
        case 77: return Metric(advanceX: 6, offsetX: 0, offsetY: -12, width: 6, height: 14)
        case 78: return Metric(advanceX: 5, offsetX: 0, offsetY: -16, width: 5, height: 20)
        case 79: return Metric(advanceX: 6, offsetX: 0, offsetY: -12, width: 6, height: 14)
        case 80: return Metric(advanceX: 7, offsetX: 0, offsetY: -7, width: 7, height: 7)
        case 81: return Metric(advanceX: 4, offsetX: 0, offsetY: -12, width: 4, height: 12)
        case 82: return Metric(advanceX: 5, offsetX: 0, offsetY: -12, width: 5, height: 12)
        case 83: return Metric(advanceX: 7, offsetX: 0, offsetY: -12, width: 7, height: 12)
        case 84: return Metric(advanceX: 5, offsetX: 0, offsetY: -2, width: 5, height: 5)
        case 85: return Metric(advanceX: 5, offsetX: 0, offsetY: -3, width: 5, height: 3)
        case 86: return Metric(advanceX: 5, offsetX: 0, offsetY: -9, width: 5, height: 9)
        case 87: return Metric(advanceX: 5, offsetX: 0, offsetY: -9, width: 5, height: 12)
        case 88: return Metric(advanceX: 11, offsetX: 0, offsetY: -9, width: 11, height: 9)
        case 89: return Metric(advanceX: 11, offsetX: 0, offsetY: -9, width: 11, height: 9)
        case 90: return Metric(advanceX: 11, offsetX: 0, offsetY: -8, width: 11, height: 8)
        case 91: return Metric(advanceX: 11, offsetX: 0, offsetY: -9, width: 11, height: 9)
        case 92: return Metric(advanceX: 11, offsetX: 0, offsetY: -7, width: 11, height: 7)
        case 93: return Metric(advanceX: 7, offsetX: 0, offsetY: -1, width: 8, height: 3)
        case 94: return Metric(advanceX: 8, offsetX: 0, offsetY: -11, width: 8, height: 11)
        case 95: return Metric(advanceX: 8, offsetX: 0, offsetY: -12, width: 8, height: 12)
        case 96: return Metric(advanceX: 7, offsetX: 0, offsetY: -13, width: 7, height: 13)
        case 97: return Metric(advanceX: 16, offsetX: 0, offsetY: -12, width: 16, height: 12)
        case 98: return Metric(advanceX: 5, offsetX: 0, offsetY: -13, width: 5, height: 13)
        case 99: return Metric(advanceX: 0, offsetX: 0, offsetY: -13, width: 4, height: 13)
        case 100: return Metric(advanceX: 5, offsetX: 0, offsetY: 0, width: 5, height: 0)
        case 101: return Metric(advanceX: 0, offsetX: 0, offsetY: -13, width: 3, height: 13)
        default: return nil
        }
    }
}
