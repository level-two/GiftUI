import SignalAnalyzerDomain

/// Writes the sixteen model-dependent passthrough modifiers in the generated
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
        while slot < 16 {
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
        while slot < 16 {
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
        case 0: 11
        case 1: 16
        case 2: 17
        case 3: 19
        case 4: 31
        case 5: 33
        case 6: 34
        case 7: 36
        case 8: 55
        case 9: 57
        case 10: 58
        case 11: 60
        case 12: 68
        case 13: 75
        case 14: 82
        default: 89
        }
    }

    private static func payload(
        at ordinal: UInt16,
        model: borrowing StaticSignalAnalyzerNRFModelLocation,
        capture: borrowing StaticSignalAnalyzerNRFCaptureRegions
    ) -> (flags: UInt8, color: UInt32)? {
        switch ordinal {
        case 11:
            switch model.acquisitionState {
            case .idle, .stopped: return (17, 0xFF_FF_FF)
            case .running: return (17, 0x00_FF_00)
            case .failed: return (17, 0x00_00_FF)
            }
        case 16, 17, 19:
            let running: Bool
            if case .running = model.acquisitionState { running = true } else { running = false }
            let color: UInt32 =
                ordinal == 19
                ? (running ? 0x10_30_00 : 0x20_10_38) : (running ? 0x00_FF_00 : 0x80_60_FF)
            return (ordinal == 16 ? 17 : 25, color)
        case 31: return (model.visibleWindowRawValue == 0 ? 65 : 1, 0)
        case 55: return (model.visibleWindowRawValue == 2 ? 65 : 1, 0)
        case 33, 34, 36, 57, 58, 60:
            let disabled =
                ordinal < 55 ? model.visibleWindowRawValue == 0 : model.visibleWindowRawValue == 2
            let fill = ordinal == 36 || ordinal == 60
            let color: UInt32 =
                fill ? (disabled ? 0x18_18_18 : 0x40_40_40) : (disabled ? 0x80_80_80 : 0xFF_FF_FF)
            return (ordinal == 33 || ordinal == 57 ? 17 : 25, color)
        case 68, 75, 82, 89:
            let channel = Int((ordinal - 68) / 7) + 1
            guard
                let level = model.capture.currentLevel(
                    for: SignalChannelID(rawValue: channel), in: capture)
            else { return nil }
            return (17, level == .low ? 0xFF_80_00 : 0x00_FF_00)
        default: return nil
        }
    }
}
