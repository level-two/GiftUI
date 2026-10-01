// Generated from the portable Signal Analyzer render projection.
// Each root-first scope uses identity, parent, first child, next sibling,
// and kind only. Runtime payloads and text scalars must be filled separately.

import SignalAnalyzerPresentation

package enum StaticSignalAnalyzerNRFTopologyWriter {
    private static let normalShape: StaticString = "0867ffff0100ffff08ec6100000200ffff08473401000300ffff08449702000400ffff02643a030005001600082d0f04000600ffff03f466050007000d0008bd2a06000800ffff02b5d10700ffff090006777807000a000b000834450900ffffffff06281607000c00ffff08e0670b00ffffffff06e6fb05000e00ffff0250780d000f00ffff08b7070e001000ffff01c3a30f001100ffff086e4a10001200ffff08110a11001300ffff08b96212001400ffff082ecd13001500ffff0865541400ffffffff06895f03001700ffff0810fe16001800ffff08b61e17001900ffff083e2618001a00ffff046b5a19001b001c00088d0d1a00ffffffff074fef19001d00ffff02a40a1c001e003f0003ff331d001f00270002de391e002000ffff08a2381f002100ffff01e43a20002200ffff08b0db21002300ffff082f7222002400ffff08ed5023002500ffff0816bb24002600ffff08710f2500ffffffff06fe131d002800360008bd3027002900ffff08099b28002a00ffff08012229002b00ffff034ae82a002c002e0008d08c2b002d00ffff089e172c00ffffffff0661e22a00ffff2f0005a1da2a0030003200085a7d2f003100ffff0843123000ffffffff0608c02a00ffff330005b3d22a003400ffff08d88233003500ffff088b423400ffffffff06ef181d003700ffff023f0136003800ffff0806a437003900ffff01e82638003a00ffff08e6bb39003b00ffff08811b3a003c00ffff0819c33b003d00ffff08b6923c003e00ffff080daa3d00ffffffff0645071c00400046000345c43f00410042000875344000ffffffff0670a23f00430044000884884200ffffffff07663b3f004500ffff0827b74400ffffffff06e7761c0047004d000395cd4600480049000851534700ffffffff0617ff46004a004b0008d1b64900ffffffff07f90646004c00ffff083e124b00ffffffff0602041c004e00540003f6f74d004f00500008a6894e00ffffffff0676794d005100520008d3db5000ffffffff07c51f4d005300ffff08157d5200ffffffff0626f61c005500ffff03b1a95400560057000872d05500ffffffff06262654005800590008dcff5700ffffffff07dd2c54005a00ffff089d2c5900ffffffff06"
    private static let diagnosticShape: StaticString = "0867ffff0100ffff08ec6100000200ffff08473401000300ffff08449702000400ffff02643a030005001600082d0f04000600ffff03f466050007000d0008bd2a06000800ffff02b5d10700ffff090006777807000a000b000834450900ffffffff06281607000c00ffff08e0670b00ffffffff06e6fb05000e00ffff0250780d000f00ffff08b7070e001000ffff01c3a30f001100ffff086e4a10001200ffff08110a11001300ffff08b96212001400ffff082ecd13001500ffff0865541400ffffffff06895f030017005b000810fe16001800ffff08b61e17001900ffff083e2618001a00ffff046b5a19001b001c00088d0d1a00ffffffff074fef19001d00ffff02a40a1c001e003f0003ff331d001f00270002de391e002000ffff08a2381f002100ffff01e43a20002200ffff08b0db21002300ffff082f7222002400ffff08ed5023002500ffff0816bb24002600ffff08710f2500ffffffff06fe131d002800360008bd3027002900ffff08099b28002a00ffff08012229002b00ffff034ae82a002c002e0008d08c2b002d00ffff089e172c00ffffffff0661e22a00ffff2f0005a1da2a0030003200085a7d2f003100ffff0843123000ffffffff0608c02a00ffff330005b3d22a003400ffff08d88233003500ffff088b423400ffffffff06ef181d003700ffff023f0136003800ffff0806a437003900ffff01e82638003a00ffff08e6bb39003b00ffff08811b3a003c00ffff0819c33b003d00ffff08b6923c003e00ffff080daa3d00ffffffff0645071c00400046000345c43f00410042000875344000ffffffff0670a23f00430044000884884200ffffffff07663b3f004500ffff0827b74400ffffffff06e7761c0047004d000395cd4600480049000851534700ffffffff0617ff46004a004b0008d1b64900ffffffff07f90646004c00ffff083e124b00ffffffff0602041c004e00540003f6f74d004f00500008a6894e00ffffffff0676794d005100520008d3db5000ffffffff07c51f4d005300ffff08157d5200ffffffff0626f61c005500ffff03b1a95400560057000872d05500ffffffff06262654005800590008dcff5700ffffffff07dd2c54005a00ffff089d2c5900ffffffff063a0803005c00ffff08eb625b00ffffffff06"

    package static func populateShape(
        variant: StaticSignalAnalyzerNRFSemanticVariant,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == table.regionByteCount else { return nil }
        let shape: StaticString
        let count: UInt16
        switch variant {
        case .normal:
            shape = normalShape
            count = 91
        case .diagnostic:
            shape = diagnosticShape
            count = 93
        }
        return shape.withUTF8Buffer { bytes in
            let length = bytes.last == 0 ? bytes.count - 1 : bytes.count
            guard length == Int(count) * 18 else { return nil }
            var ordinal: UInt16 = 0
            while ordinal < count {
                let base = Int(ordinal) * 18
                guard let identity = word(in: bytes, at: base),
                    let parent = word(in: bytes, at: base + 4),
                    let firstChild = word(in: bytes, at: base + 8),
                    let nextSibling = word(in: bytes, at: base + 12),
                    let kindByte = byte(in: bytes, at: base + 16),
                    let kind = StaticSignalAnalyzerNRFScopeKind(rawValue: kindByte),
                    table.storeScope(
                        StaticSignalAnalyzerNRFScopeRecord(
                            identity: identity,
                            parent: parent,
                            firstChild: firstChild,
                            nextSibling: nextSibling,
                            kind: kind,
                            flags: 0,
                            auxiliary: 0,
                            payload0: 0,
                            payload1: 0,
                            payload2: 0
                        ),
                        at: ordinal,
                        in: region
                    )
                else { return nil }
                ordinal += 1
            }
            return count
        }
    }

    /// Fill only the variant-stable action and Canvas associations after
    /// populateShape. The generated text and modifier payloads remain open.
    package static func populateBindings(
        scopeCount: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == table.regionByteCount,
            scopeCount == 91 || scopeCount == 93
        else { return false }
        var index: UInt16 = 0
        while index < 5 {
            let ordinal = canvasOrdinal(at: index)
            guard let record = table.scope(at: ordinal, in: region),
                record.kind == .canvas,
                record.identity == canvasIdentity(at: index),
                record.payload0 == 0, record.payload1 == 0, record.payload2 == 0
            else { return false }
            index += 1
        }
        index = 0
        while index < table.actionCount {
            let ordinal = actionOrdinal(at: index)
            guard let record = table.scope(at: ordinal, in: region),
                record.identity == actionIdentity(at: index),
                region[table.actionOffset + Int(index) * 2] == 0,
                region[table.actionOffset + Int(index) * 2 + 1] == 0
            else { return false }
            index += 1
        }
        index = 0
        while index < 5 {
            let ordinal = canvasOrdinal(at: index)
            guard let old = table.scope(at: ordinal, in: region),
                table.storeScope(
                    StaticSignalAnalyzerNRFScopeRecord(
                        identity: old.identity,
                        parent: old.parent,
                        firstChild: old.firstChild,
                        nextSibling: old.nextSibling,
                        kind: old.kind,
                        flags: old.flags,
                        auxiliary: old.auxiliary,
                        payload0: UInt32(index + 1),
                        payload1: old.payload1,
                        payload2: old.payload2
                    ),
                    at: ordinal,
                    in: region
                )
            else { return false }
            index += 1
        }
        index = 0
        while index < table.actionCount {
            guard table.storeActionScope(
                actionOrdinal(at: index),
                at: index,
                in: region
            ) else { return false }
            index += 1
        }
        return true
    }

    /// The current portable tree has the same invariant stack/spacer payloads
    /// in both variants. No text, Canvas, or modifier payload is inferred here.
    package static func populateInvariantPrimitives(
        scopeCount: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == table.regionByteCount,
            scopeCount == 91 || scopeCount == 93
        else { return false }
        var slot: UInt16 = 0
        while slot < 16 {
            let ordinal = invariantPrimitiveOrdinal(at: slot)
            let payload = invariantPrimitivePayload(at: slot)
            guard let record = table.scope(at: ordinal, in: region),
                record.kind == payload.kind,
                record.auxiliary == 0,
                record.payload0 == 0,
                record.payload1 == 0,
                record.payload2 == 0
            else { return false }
            slot += 1
        }
        slot = 0
        while slot < 16 {
            let ordinal = invariantPrimitiveOrdinal(at: slot)
            let payload = invariantPrimitivePayload(at: slot)
            guard let old = table.scope(at: ordinal, in: region),
                table.storeScope(
                    StaticSignalAnalyzerNRFScopeRecord(
                        identity: old.identity,
                        parent: old.parent,
                        firstChild: old.firstChild,
                        nextSibling: old.nextSibling,
                        kind: old.kind,
                        flags: old.flags,
                        auxiliary: payload.auxiliary,
                        payload0: payload.payload0,
                        payload1: old.payload1,
                        payload2: old.payload2
                    ),
                    at: ordinal,
                    in: region
                )
            else { return false }
            slot += 1
        }
        return true
    }

    /// The generated padding and frame modifiers are invariant across model state.
    /// Passthrough render colors and disabled-action flags are not written here.
    package static func populateInvariantLayoutModifiers(
        scopeCount: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == table.regionByteCount,
            scopeCount == 91 || scopeCount == 93
        else { return false }
        var slot: UInt16 = 0
        while slot < 25 {
            let ordinal = invariantModifierOrdinal(at: slot)
            guard let record = table.scope(at: ordinal, in: region),
                record.kind == .modifier,
                record.flags == 0,
                record.auxiliary == 0,
                record.payload0 == 0,
                record.payload1 == 0,
                record.payload2 == 0
            else { return false }
            slot += 1
        }
        slot = 0
        while slot < 25 {
            let ordinal = invariantModifierOrdinal(at: slot)
            let payload = invariantModifierPayload(at: slot)
            guard let old = table.scope(at: ordinal, in: region),
                table.storeScope(
                    StaticSignalAnalyzerNRFScopeRecord(
                        identity: old.identity,
                        parent: old.parent,
                        firstChild: old.firstChild,
                        nextSibling: old.nextSibling,
                        kind: .modifier,
                        flags: payload.flags,
                        auxiliary: payload.auxiliary,
                        payload0: payload.payload0,
                        payload1: payload.payload1,
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

    /// Fixed palette and label styles only. Status, channel levels, and
    /// disabled-control passthroughs are evaluated from live model state.
    package static func populateInvariantStyles(
        scopeCount: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == table.regionByteCount,
            scopeCount == 91 || scopeCount == 93
        else { return false }
        var ordinal: UInt16 = 0
        while ordinal < scopeCount {
            if invariantStyle(at: ordinal) != nil {
                guard let record = table.scope(at: ordinal, in: region),
                    record.kind == .modifier,
                    record.flags == 0,
                    record.auxiliary == 0,
                    record.payload0 == 0,
                    record.payload1 == 0,
                    record.payload2 == 0
                else { return false }
            }
            ordinal += 1
        }
        ordinal = 0
        while ordinal < scopeCount {
            if let style = invariantStyle(at: ordinal) {
                guard let old = table.scope(at: ordinal, in: region),
                    table.storeScope(
                        StaticSignalAnalyzerNRFScopeRecord(
                            identity: old.identity,
                            parent: old.parent,
                            firstChild: old.firstChild,
                            nextSibling: old.nextSibling,
                            kind: .modifier,
                            flags: style.flags,
                            auxiliary: 0,
                            payload0: style.color,
                            payload1: 0,
                            payload2: 0
                        ),
                        at: ordinal,
                        in: region
                    )
                else { return false }
            }
            ordinal += 1
        }
        return true
    }

    #if !GIFTUI_NRF_EMBEDDED
    package static func populateLiveModifiers(
        inputs: borrowing StaticSignalAnalyzerNRFGeneratedPresentationInputs,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == table.regionByteCount else { return false }
        var slot: UInt16 = 0
        while slot < 16 {
            let ordinal = liveModifierOrdinal(at: slot)
            guard let record = table.scope(at: ordinal, in: region),
                record.kind == .modifier,
                record.flags == 0,
                record.auxiliary == 0,
                record.payload0 == 0,
                record.payload1 == 0,
                record.payload2 == 0,
                inputs.liveModifierInput(at: ordinal) != nil
            else { return false }
            slot += 1
        }
        slot = 0
        while slot < 16 {
            let ordinal = liveModifierOrdinal(at: slot)
            guard let old = table.scope(at: ordinal, in: region),
                let payload = inputs.liveModifierInput(at: ordinal),
                table.storeScope(
                    StaticSignalAnalyzerNRFScopeRecord(
                        identity: old.identity,
                        parent: old.parent,
                        firstChild: old.firstChild,
                        nextSibling: old.nextSibling,
                        kind: .modifier,
                        flags: payload.flags,
                        auxiliary: payload.auxiliary,
                        payload0: payload.payload0,
                        payload1: payload.payload1,
                        payload2: payload.payload2
                    ),
                    at: ordinal,
                    in: region
                )
            else { return false }
            slot += 1
        }
        return true
    }

    /// Writes every generated text scope as a contiguous UTF-8 byte range.
    /// Capacity and shape are checked before the first byte is changed.
    package static func populateTextBytes(
        inputs: borrowing StaticSignalAnalyzerNRFGeneratedPresentationInputs,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        let pool = StaticSignalAnalyzerNRFUTF8TextPool.self
        guard region.count == table.regionByteCount else { return nil }
        let scopeCount: UInt16 = inputs.semantic.variant == .normal ? 91 : 93
        var ordinal: UInt16 = 0
        var required: UInt16 = 0
        var textCount: UInt16 = 0
        while ordinal < scopeCount {
            guard let record = table.scope(at: ordinal, in: region) else { return nil }
            if record.kind == .text {
                guard record.flags == 0, record.auxiliary == 0,
                    record.payload0 == 0, record.payload1 == 0,
                    record.payload2 == 0,
                    let value = inputs.textInput(at: ordinal),
                    value.utf8ByteCount <= Int(pool.maximumByteCount - required)
                else { return nil }
                required += UInt16(value.utf8ByteCount)
                textCount += 1
            }
            ordinal += 1
        }
        guard textCount == (scopeCount == 91 ? 17 : 18) else { return nil }
        ordinal = 0
        var used: UInt16 = 0
        while ordinal < scopeCount {
            guard let old = table.scope(at: ordinal, in: region) else { return nil }
            if old.kind == .text {
                guard let value = inputs.textInput(at: ordinal),
                    let count = pool.append(value, at: used, in: region),
                    table.storeScope(
                        StaticSignalAnalyzerNRFScopeRecord(
                            identity: old.identity,
                            parent: old.parent,
                            firstChild: old.firstChild,
                            nextSibling: old.nextSibling,
                            kind: .text,
                            flags: 0,
                            auxiliary: 0,
                            payload0: UInt32(used),
                            payload1: UInt32(count),
                            payload2: 0
                        ),
                        at: ordinal,
                        in: region
                    )
                else { return nil }
                used += count
            }
            ordinal += 1
        }
        return used == required ? used : nil
    }
    #endif

    private static func liveModifierOrdinal(at index: UInt16) -> UInt16 {
        switch index {
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

    private static func invariantStyle(at ordinal: UInt16) -> (flags: UInt8, color: UInt32)? {
        switch ordinal {
        case 0: (25, 0)
        case 2: (17, 16777215)
        case 9: (17, 8421504)
        case 14: (1, 0)
        case 22: (25, 1052688)
        case 39: (25, 1579032)
        case 43: (17, 8421504)
        case 47: (17, 8421504)
        case 51: (17, 8421504)
        case 91: (17, 255)
        default: nil
        }
    }

    private static func invariantModifierOrdinal(at index: UInt16) -> UInt16 {
        switch index {
        case 0: 1
        case 1: 4
        case 2: 6
        case 3: 18
        case 4: 20
        case 5: 23
        case 6: 24
        case 7: 26
        case 8: 35
        case 9: 37
        case 10: 40
        case 11: 41
        case 12: 44
        case 13: 48
        case 14: 52
        case 15: 59
        case 16: 61
        case 17: 64
        case 18: 66
        case 19: 71
        case 20: 73
        case 21: 78
        case 22: 80
        case 23: 85
        default: 87
        }
    }

    private static func invariantModifierPayload(at slot: UInt16)
        -> (flags: UInt8, auxiliary: UInt16, payload0: UInt32, payload1: UInt32) {
        let layout = SignalAnalyzerLayoutConstraints.reference
        return switch slot {
        case 0: (2, 15, 2, 0)
        case 1: (11, 2, 0, UInt32(layout.headerHeight))
        case 2: (11, 9, UInt32(layout.headerTextWidth), 0)
        case 3: (2, 15, 2, 0)
        case 4: (11, 15, UInt32(layout.buttonSize - 4), UInt32(layout.buttonSize - 4))
        case 5: (2, 15, 2, 0)
        case 6: (12, 232, 80, 0)
        case 7: (12, 210, UInt32(layout.gridWidth), UInt32(layout.gridHeight))
        case 8: (2, 15, 2, 0)
        case 9: (11, 15, UInt32(layout.buttonSize - 4), UInt32(layout.buttonSize - 4))
        case 10: (11, 13, UInt32(layout.traceWidth), 0)
        case 11: (2, 10, 2, 0)
        case 12: (11, 13, UInt32(layout.rulerLabelWidth), 0)
        case 13: (11, 13, UInt32(layout.rulerLabelWidth), 0)
        case 14: (11, 13, UInt32(layout.rulerLabelWidth), 0)
        case 15: (2, 15, 2, 0)
        case 16: (11, 15, UInt32(layout.buttonSize - 4), UInt32(layout.buttonSize - 4))
        case 17: (11, 9, UInt32(layout.labelWidth), 0)
        case 18: (12, 210, UInt32(layout.traceWidth), UInt32(layout.traceHeight))
        case 19: (11, 9, UInt32(layout.labelWidth), 0)
        case 20: (12, 210, UInt32(layout.traceWidth), UInt32(layout.traceHeight))
        case 21: (11, 9, UInt32(layout.labelWidth), 0)
        case 22: (12, 210, UInt32(layout.traceWidth), UInt32(layout.traceHeight))
        case 23: (11, 9, UInt32(layout.labelWidth), 0)
        default: (12, 210, UInt32(layout.traceWidth), UInt32(layout.traceHeight))
        }
    }

    private static func invariantPrimitiveOrdinal(at index: UInt16) -> UInt16 {
        switch index {
        case 0: 3
        case 1: 5
        case 2: 7
        case 3: 13
        case 4: 25
        case 5: 28
        case 6: 29
        case 7: 30
        case 8: 42
        case 9: 46
        case 10: 50
        case 11: 54
        case 12: 63
        case 13: 70
        case 14: 77
        default: 84
        }
    }

    private static func invariantPrimitivePayload(at slot: UInt16)
        -> (kind: StaticSignalAnalyzerNRFScopeKind, auxiliary: UInt16, payload0: UInt32) {
        switch slot {
        case 0: (.vStack, 1, 0)
        case 1: (.hStack, 0, 4)
        case 2: (.vStack, 0, 2)
        case 3: (.vStack, 1, 0)
        case 4: (.zStack, 257, 0)
        case 5: (.vStack, 0, 0)
        case 6: (.hStack, 1, 2)
        case 7: (.vStack, 1, 0)
        case 8: (.hStack, 1, 2)
        case 9: (.spacer, 0, 0)
        case 10: (.spacer, 0, 0)
        case 11: (.vStack, 1, 0)
        case 12: (.hStack, 1, 2)
        case 13: (.hStack, 1, 2)
        case 14: (.hStack, 1, 2)
        default: (.hStack, 1, 2)
        }
    }

    private static func actionOrdinal(at index: UInt16) -> UInt16 {
        switch index {
        case 0: 15
        case 1: 32
        default: 56
        }
    }

    private static func actionIdentity(at index: UInt16) -> UInt16 {
        switch index {
        case 0: 1975
        case 1: 14498
        default: 41990
        }
    }

    private static func canvasOrdinal(at index: UInt16) -> UInt16 {
        switch index {
        case 0: 27
        case 1: 67
        case 2: 74
        case 3: 81
        default: 88
        }
    }

    private static func canvasIdentity(at index: UInt16) -> UInt16 {
        switch index {
        case 0: 3469
        case 1: 34948
        case 2: 46801
        case 3: 56275
        default: 65500
        }
    }

    private static func word(
        in bytes: UnsafeBufferPointer<UInt8>,
        at offset: Int
    ) -> UInt16? {
        guard let low = byte(in: bytes, at: offset),
            let high = byte(in: bytes, at: offset + 2)
        else { return nil }
        return UInt16(low) | UInt16(high) << 8
    }

    private static func byte(
        in bytes: UnsafeBufferPointer<UInt8>,
        at offset: Int
    ) -> UInt8? {
        guard offset + 1 < bytes.count,
            let high = nibble(bytes[offset]),
            let low = nibble(bytes[offset + 1])
        else { return nil }
        return high << 4 | low
    }

    private static func nibble(_ value: UInt8) -> UInt8? {
        switch value {
        case 48...57: value - 48
        case 97...102: value - 87
        default: nil
        }
    }
}
