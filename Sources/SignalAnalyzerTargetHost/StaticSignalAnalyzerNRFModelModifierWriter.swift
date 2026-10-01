import SignalAnalyzerDomain

/// Writes the fifteen model-dependent passthrough modifiers in the generated
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
        while slot < 15 {
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
        while slot < 15 {
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
        case 0: 17
        case 1: 18
        case 2: 20
        case 3: 32
        case 4: 34
        case 5: 35
        case 6: 37
        case 7: 56
        case 8: 58
        case 9: 59
        case 10: 61
        case 11: 69
        case 12: 76
        case 13: 83
        default: 90
        }
    }

    private static func payload(
        at ordinal: UInt16,
        model: borrowing StaticSignalAnalyzerNRFModelLocation,
        capture: borrowing StaticSignalAnalyzerNRFCaptureRegions
    ) -> (flags: UInt8, color: UInt32)? {
        switch ordinal {
        case 17, 18, 20:
            let running: Bool
            if case .running = model.acquisitionState { running = true } else { running = false }
            let color: UInt32 =
                ordinal == 20
                ? (running ? 0x10_30_00 : 0x20_10_38) : (running ? 0x00_FF_00 : 0x80_60_FF)
            return (ordinal == 17 ? 17 : 25, color)
        case 32: return (model.visibleWindowRawValue == 0 ? 65 : 1, 0)
        case 56: return (model.visibleWindowRawValue == 2 ? 65 : 1, 0)
        case 34, 35, 37, 58, 59, 61:
            let disabled =
                ordinal < 56 ? model.visibleWindowRawValue == 0 : model.visibleWindowRawValue == 2
            let fill = ordinal == 37 || ordinal == 61
            let color: UInt32 =
                fill ? (disabled ? 0x18_18_18 : 0x40_40_40) : (disabled ? 0x80_80_80 : 0xFF_FF_FF)
            return (ordinal == 34 || ordinal == 58 ? 17 : 25, color)
        case 69, 76, 83, 90:
            let channel = Int((ordinal - 69) / 7) + 1
            guard
                let level = model.capture.currentLevel(
                    for: SignalChannelID(rawValue: channel), in: capture)
            else { return nil }
            return (17, level == .low ? 0xFF_80_00 : 0x00_FF_00)
        default: return nil
        }
    }
}
