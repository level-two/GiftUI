// Generated from nrf-static-canvas-manifest.yaml by scripts/contracts/generate-spec-001-nrf-canvas-table.rb. Do not edit.
package enum StaticSignalAnalyzerNRFEmbeddedCanvasTable {
    package static let callableCaseCount: UInt8 = 2
    package static let occurrenceCount: UInt16 = 5

    package static func callableID(at occurrence: UInt16) -> UInt8? {
        switch occurrence {
        case 0: return 1
        case 1: return 2
        case 2: return 2
        case 3: return 2
        case 4: return 2
        default: return nil
        }
    }

    package static func channel(at occurrence: UInt16) -> UInt8? {
        switch occurrence {
        case 0: return 0
        case 1: return 1
        case 2: return 2
        case 3: return 3
        case 4: return 4
        default: return nil
        }
    }

    package static func captureByteCount(for callableID: UInt8) -> UInt8? {
        switch callableID {
        case 1: return 0
        case 2: return 32
        default: return nil
        }
    }
}
