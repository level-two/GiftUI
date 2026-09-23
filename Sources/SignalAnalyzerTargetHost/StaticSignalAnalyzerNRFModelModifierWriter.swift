import SignalAnalyzerDomain

/// Writes the ten model-dependent passthrough modifiers in the generated
/// Static tree. Colors use the packed R | G << 8 | B << 16 schema.
package enum StaticSignalAnalyzerNRFModelModifierWriter {
    package static func populate(
        model: borrowing StaticSignalAnalyzerNRFModelLocation,
        capture: borrowing StaticSignalAnalyzerNRFCaptureRegions,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == table.regionByteCount else { return false }
        var slot: UInt16 = 0
        while slot < 10 {
            let ordinal = scopeOrdinal(at: slot)
            guard let record = table.scope(at: ordinal, in: region),
                record.kind == .modifier,
                record.flags == 0, record.auxiliary == 0,
                record.payload0 == 0, record.payload1 == 0,
                record.payload2 == 0,
                payload(at: ordinal, model: model, capture: capture) != nil
            else { return false }
            slot += 1
        }
        slot = 0
        while slot < 10 {
            let ordinal = scopeOrdinal(at: slot)
            guard let old = table.scope(at: ordinal, in: region),
                let payload = payload(at: ordinal, model: model, capture: capture),
                table.storeScope(
                    StaticSignalAnalyzerNRFScopeRecord(
                        identity: old.identity,
                        parent: old.parent,
                        firstChild: old.firstChild,
                        nextSibling: old.nextSibling,
                        kind: .modifier,
                        flags: payload.flags,
                        auxiliary: 0,
                        payload0: payload.color,
                        payload1: 0,
                        payload2: 0
                    ),
                    at: ordinal,
                    in: region
                )
            else { return false }
            slot += 1
        }
        return true
    }

    private static func scopeOrdinal(at slot: UInt16) -> UInt16 {
        switch slot {
        case 0: 12
        case 1: 39
        case 2: 48
        case 3: 57
        case 4: 66
        case 5: 72
        case 6: 76
        case 7: 84
        case 8: 88
        default: 92
        }
    }

    private static func payload(
        at ordinal: UInt16,
        model: borrowing StaticSignalAnalyzerNRFModelLocation,
        capture: borrowing StaticSignalAnalyzerNRFCaptureRegions
    ) -> (flags: UInt8, color: UInt32)? {
        switch ordinal {
        case 12:
            switch model.acquisitionState {
            case .idle, .stopped: return (17, 0xFF_FF_FF)
            case .running: return (17, 0x00_FF_00)
            case .failed: return (17, 0x00_00_FF)
            }
        case 39, 48, 57, 66:
            let channel: Int
            switch ordinal {
            case 39: channel = 1
            case 48: channel = 2
            case 57: channel = 3
            default: channel = 4
            }
            guard
                let level = model.capture.currentLevel(
                    for: SignalChannelID(rawValue: channel), in: capture
                )
            else { return nil }
            return (17, level == .low ? 0xFF_80_00 : 0x00_FF_00)
        case 72:
            if case .running = model.acquisitionState { return (65, 0) }
            return (1, 0)
        case 76:
            if case .running = model.acquisitionState { return (1, 0) }
            return (65, 0)
        case 84: return (model.visibleWindowRawValue == 0 ? 65 : 1, 0)
        case 88: return (model.visibleWindowRawValue == 1 ? 65 : 1, 0)
        case 92: return (model.visibleWindowRawValue == 2 ? 65 : 1, 0)
        default: return nil
        }
    }
}
