// Generated from the portable Signal Analyzer render projection.
// Each root-first scope uses identity, parent, first child, next sibling,
// and kind only. Runtime payloads and text scalars must be filled separately.

import SignalAnalyzerPresentation

package enum StaticSignalAnalyzerNRFTopologyWriter {
    private static let normalShape: StaticString = "0867ffff0100ffff08ec6100000200ffff08473401000300ffff08449702000400ffff02643a030005001700082d0f04000600ffff03f466050007000e0008bd2a06000800ffff02b5d10700ffff090006777807000a000b000834450900ffffffff06170c07000c00ffff0873a80b000d00ffff08a2050c00ffffffff06e6fb05000f00ffff0250780e001000ffff08b7070f001100ffff01c3a310001200ffff086e4a11001300ffff08110a12001400ffff08b96213001500ffff082ecd14001600ffff0865541500ffffffff06895f03001800ffff0810fe17001900ffff08b61e18001a00ffff083e2619001b00ffff046b5a1a001c001d00088d0d1b00ffffffff074fef1a001e00ffff02a40a1d001f00400003ff331e002000280002de391f002100ffff08a23820002200ffff01e43a21002300ffff08b0db22002400ffff082f7223002500ffff08ed5024002600ffff0816bb25002700ffff08710f2600ffffffff06fe131e002900370008bd3028002a00ffff08099b29002b00ffff0801222a002c00ffff034ae82b002d002f0008d08c2c002e00ffff089e172d00ffffffff0661e22b00ffff300005a1da2b0031003300085a7d30003200ffff0843123100ffffffff0608c02b00ffff340005b3d22b003500ffff08d88234003600ffff088b423500ffffffff06ef181e003800ffff023f0137003900ffff0806a438003a00ffff01e82639003b00ffff08e6bb3a003c00ffff08811b3b003d00ffff0819c33c003e00ffff08b6923d003f00ffff080daa3e00ffffffff0645071d00410047000345c44000420043000875344100ffffffff0670a24000440045000884884300ffffffff07663b40004600ffff0827b74500ffffffff06e7761d0048004e000395cd470049004a000851534800ffffffff0617ff47004b004c0008d1b64a00ffffffff07f90647004d00ffff083e124c00ffffffff0602041d004f00550003f6f74e005000510008a6894f00ffffffff0676794e005200530008d3db5100ffffffff07c51f4e005400ffff08157d5300ffffffff0626f61d005600ffff03b1a95500570058000872d05600ffffffff062626550059005a0008dcff5800ffffffff07dd2c55005b00ffff089d2c5a00ffffffff06"
    private static let diagnosticShape: StaticString = "0867ffff0100ffff08ec6100000200ffff08473401000300ffff08449702000400ffff02643a030005001700082d0f04000600ffff03f466050007000e0008bd2a06000800ffff02b5d10700ffff090006777807000a000b000834450900ffffffff06170c07000c00ffff0873a80b000d00ffff08a2050c00ffffffff06e6fb05000f00ffff0250780e001000ffff08b7070f001100ffff01c3a310001200ffff086e4a11001300ffff08110a12001400ffff08b96213001500ffff082ecd14001600ffff0865541500ffffffff06895f03001800ffff0810fe17001900ffff08b61e18001a00ffff083e2619001b00ffff046b5a1a001c001d00088d0d1b00ffffffff074fef1a001e00ffff02a40a1d001f00400003ff331e002000280002de391f002100ffff08a23820002200ffff01e43a21002300ffff08b0db22002400ffff082f7223002500ffff08ed5024002600ffff0816bb25002700ffff08710f2600ffffffff06fe131e002900370008bd3028002a00ffff08099b29002b00ffff0801222a002c00ffff034ae82b002d002f0008d08c2c002e00ffff089e172d00ffffffff0661e22b00ffff300005a1da2b0031003300085a7d30003200ffff0843123100ffffffff0608c02b00ffff340005b3d22b003500ffff08d88234003600ffff088b423500ffffffff06ef181e003800ffff023f0137003900ffff0806a438003a00ffff01e82639003b00ffff08e6bb3a003c00ffff08811b3b003d00ffff0819c33c003e00ffff08b6923d003f00ffff080daa3e00ffffffff0645071d00410047000345c44000420043000875344100ffffffff0670a24000440045000884884300ffffffff07663b40004600ffff0827b74500ffffffff06e7761d0048004e000395cd470049004a000851534800ffffffff0617ff47004b004c0008d1b64a00ffffffff07f90647004d00ffff083e124c00ffffffff0602041d004f00550003f6f74e005000510008a6894f00ffffffff0676794e005200530008d3db5100ffffffff07c51f4e005400ffff08157d5300ffffffff0626f61d005600ffff03b1a95500570058000872d05600ffffffff062626550059005a0008dcff5800ffffffff07dd2c55005b00ffff089d2c5a00ffffffff06"

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
            count = 92
        case .diagnostic:
            shape = diagnosticShape
            count = 92
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
            scopeCount == 92
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
            scopeCount == 92
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
            scopeCount == 92
        else { return false }
        var slot: UInt16 = 0
        while slot < 26 {
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
        while slot < 26 {
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
            scopeCount == 92
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
        while slot < 15 {
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
        while slot < 15 {
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
        let scopeCount: UInt16 = 92
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
        guard textCount == (17) else { return nil }
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

    private static func invariantStyle(at ordinal: UInt16) -> (flags: UInt8, color: UInt32)? {
        switch ordinal {
        case 0: (25, 0)
        case 2: (17, 16777215)
        case 9: (17, 8421504)
        case 12: (17, 255)
        case 15: (1, 0)
        case 23: (25, 1052688)
        case 40: (25, 1579032)
        case 44: (17, 8421504)
        case 48: (17, 8421504)
        case 52: (17, 8421504)
        default: nil
        }
    }

    private static func invariantModifierOrdinal(at index: UInt16) -> UInt16 {
        switch index {
        case 0: 1
        case 1: 4
        case 2: 6
        case 3: 11
        case 4: 19
        case 5: 21
        case 6: 24
        case 7: 25
        case 8: 27
        case 9: 36
        case 10: 38
        case 11: 41
        case 12: 42
        case 13: 45
        case 14: 49
        case 15: 53
        case 16: 60
        case 17: 62
        case 18: 65
        case 19: 67
        case 20: 72
        case 21: 74
        case 22: 79
        case 23: 81
        case 24: 86
        default: 88
        }
    }

    private static func invariantModifierPayload(at slot: UInt16)
        -> (flags: UInt8, auxiliary: UInt16, payload0: UInt32, payload1: UInt32) {
        let layout = SignalAnalyzerLayoutConstraints.reference
        return switch slot {
        case 0: (2, 15, 2, 0)
        case 1: (11, 2, 0, UInt32(layout.headerHeight))
        case 2: (11, 9, UInt32(layout.headerTextWidth), 0)
        case 3: (11, 10, 0, UInt32(layout.errorLineHeight))
        case 4: (2, 15, 2, 0)
        case 5: (11, 15, UInt32(layout.buttonSize - 4), UInt32(layout.buttonSize - 4))
        case 6: (2, 15, 2, 0)
        case 7: (12, 232, 80, 0)
        case 8: (12, 210, UInt32(layout.gridWidth), UInt32(layout.gridHeight))
        case 9: (2, 15, 2, 0)
        case 10: (11, 15, UInt32(layout.buttonSize - 4), UInt32(layout.buttonSize - 4))
        case 11: (11, 13, UInt32(layout.traceWidth), 0)
        case 12: (2, 10, 2, 0)
        case 13: (11, 13, UInt32(layout.rulerLabelWidth), 0)
        case 14: (11, 13, UInt32(layout.rulerLabelWidth), 0)
        case 15: (11, 13, UInt32(layout.rulerLabelWidth), 0)
        case 16: (2, 15, 2, 0)
        case 17: (11, 15, UInt32(layout.buttonSize - 4), UInt32(layout.buttonSize - 4))
        case 18: (11, 9, UInt32(layout.labelWidth), 0)
        case 19: (12, 210, UInt32(layout.traceWidth), UInt32(layout.traceHeight))
        case 20: (11, 9, UInt32(layout.labelWidth), 0)
        case 21: (12, 210, UInt32(layout.traceWidth), UInt32(layout.traceHeight))
        case 22: (11, 9, UInt32(layout.labelWidth), 0)
        case 23: (12, 210, UInt32(layout.traceWidth), UInt32(layout.traceHeight))
        case 24: (11, 9, UInt32(layout.labelWidth), 0)
        default: (12, 210, UInt32(layout.traceWidth), UInt32(layout.traceHeight))
        }
    }

    private static func invariantPrimitiveOrdinal(at index: UInt16) -> UInt16 {
        switch index {
        case 0: 3
        case 1: 5
        case 2: 7
        case 3: 14
        case 4: 26
        case 5: 29
        case 6: 30
        case 7: 31
        case 8: 43
        case 9: 47
        case 10: 51
        case 11: 55
        case 12: 64
        case 13: 71
        case 14: 78
        default: 85
        }
    }

    private static func invariantPrimitivePayload(at slot: UInt16)
        -> (kind: StaticSignalAnalyzerNRFScopeKind, auxiliary: UInt16, payload0: UInt32) {
        switch slot {
        case 0: (.vStack, 1, 0)
        case 1: (.hStack, 0, 4)
        case 2: (.vStack, 0, 2)
        case 3: (.vStack, 1, 0)
        case 4: (.zStack, 513, 0)
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
        case 0: 16
        case 1: 33
        default: 57
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
        case 0: 28
        case 1: 68
        case 2: 75
        case 3: 82
        default: 89
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
