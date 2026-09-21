// Generated from the portable Signal Analyzer render projection.
// Each root-first scope uses identity, parent, first child, next sibling,
// and kind only. Runtime payloads and text scalars must be filled separately.

package enum StaticSignalAnalyzerNRFTopologyWriter {
    private static let normalShape: StaticString = "7c9fffff0100ffff08c2bf00000200ffff08fcbf01000300ffff02352e020004000e0003713c030005000900026f16040006000700082f4b0500ffffffff065aff04000800ffff08c3e00700ffffffff068a590300ffff0a0005ac4303000b00ffff0812eb0a000c00ffff08796b0b000d00ffff08de3b0c00ffffffff06e17302000f00440008339d0e001000ffff089f3a0f001100ffff08471610001200ffff049b16110013001400088e2e1200ffffffff07a5a311001500ffff02eab21400160020000844e215001700ffff0846f816001800ffff03ff67170019001a00087e081800ffffffff0638071700ffff1b0005902617001c001d000883021b00ffffffff0611b21700ffff1e00050dfc17001f00ffff0801d21e00ffffffff066b7814002100290008df9c20002200ffff087b5021002300ffff035a0c22002400250008e7f32300ffffffff06974922002600270008d7a72500ffffffff0781b422002800ffff0835702700ffffffff06990514002a00320008e6d129002b00ffff0885542a002c00ffff030ffd2b002d002e00082b8c2c00ffffffff06661c2b002f00300008f8842e00ffffffff0796f82b003100ffff08565b3000ffffffff061773140033003b0008bc2a32003400ffff08785433003500ffff03abbb34003600370008f6453500ffffffff069bbb34003800390008aad53700ffffffff07900334003a00ffff0804893900ffffffff0636e614003c00ffff0899963b003d00ffff081ebd3c003e00ffff0371143d003f00400008bbfd3e00ffffffff067a3f3d004100420008c81f4000ffffffff070e6f3d004300ffff0814484200ffffffff06822e02004500ffff08e98e44004600ffff089e1f45004700ffff020f9846004800530003e22b470049004c0008788348004a00ffff083b0149004b00ffff019fb74a00ffffffff06bd3947004d0050000812854c004e00ffff08858c4d004f00ffff018a5c4e00ffffffff063c0647005100ffff08074350005200ffff01ed3d5100ffffffff066cce46005400ffff03191c53005500580008867954005600ffff08b1b055005700ffff019d365600ffffffff06e625530059005c00080d9058005a00ffff08369e59005b00ffff01f2ae5a00ffffffff06d34553005d00ffff0837a95c005e00ffff080ebd5d005f00ffff0186e95e00ffffffff06"
    private static let diagnosticShape: StaticString = "7c9fffff0100ffff08c2bf00000200ffff08fcbf01000300ffff02352e020004000e0003713c030005000900026f16040006000700082f4b0500ffffffff065aff04000800ffff08c3e00700ffffffff068a590300ffff0a0005ac4303000b00ffff0812eb0a000c00ffff08796b0b000d00ffff08de3b0c00ffffffff06e17302000f00440008339d0e001000ffff089f3a0f001100ffff08471610001200ffff049b16110013001400088e2e1200ffffffff07a5a311001500ffff02eab21400160020000844e215001700ffff0846f816001800ffff03ff67170019001a00087e081800ffffffff0638071700ffff1b0005902617001c001d000883021b00ffffffff0611b21700ffff1e00050dfc17001f00ffff0801d21e00ffffffff066b7814002100290008df9c20002200ffff087b5021002300ffff035a0c22002400250008e7f32300ffffffff06974922002600270008d7a72500ffffffff0781b422002800ffff0835702700ffffffff06990514002a00320008e6d129002b00ffff0885542a002c00ffff030ffd2b002d002e00082b8c2c00ffffffff06661c2b002f00300008f8842e00ffffffff0796f82b003100ffff08565b3000ffffffff061773140033003b0008bc2a32003400ffff08785433003500ffff03abbb34003600370008f6453500ffffffff069bbb34003800390008aad53700ffffffff07900334003a00ffff0804893900ffffffff0636e614003c00ffff0899963b003d00ffff081ebd3c003e00ffff0371143d003f00400008bbfd3e00ffffffff067a3f3d004100420008c81f4000ffffffff070e6f3d004300ffff0814484200ffffffff06822e02004500600008e98e44004600ffff089e1f45004700ffff020f9846004800530003e22b470049004c0008788348004a00ffff083b0149004b00ffff019fb74a00ffffffff06bd3947004d0050000812854c004e00ffff08858c4d004f00ffff018a5c4e00ffffffff063c0647005100ffff08074350005200ffff01ed3d5100ffffffff066cce46005400ffff03191c53005500580008867954005600ffff08b1b055005700ffff019d365600ffffffff06e625530059005c00080d9058005a00ffff08369e59005b00ffff01f2ae5a00ffffffff06d34553005d00ffff0837a95c005e00ffff080ebd5d005f00ffff0186e95e00ffffffff06a92502006100ffff08f40d6000ffffffff06"

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
            count = 96
        case .diagnostic:
            shape = diagnosticShape
            count = 98
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
            scopeCount == 96 || scopeCount == 98
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
            scopeCount == 96 || scopeCount == 98
        else { return false }
        var slot: UInt16 = 0
        while slot < 13 {
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
        while slot < 13 {
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

    /// The 15 padding and frame modifiers are invariant across model state.
    /// Passthrough render colors and disabled-action flags are not written here.
    package static func populateInvariantLayoutModifiers(
        scopeCount: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == table.regionByteCount,
            scopeCount == 96 || scopeCount == 98
        else { return false }
        var slot: UInt16 = 0
        while slot < 15 {
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
        while slot < 15 {
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
            scopeCount == 96 || scopeCount == 98
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

    package static func populateLiveModifiers(
        inputs: borrowing StaticSignalAnalyzerNRFGeneratedPresentationInputs,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == table.regionByteCount else { return false }
        var slot: UInt16 = 0
        while slot < 10 {
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
        while slot < 10 {
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

    private static func liveModifierOrdinal(at slot: UInt16) -> UInt16 {
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

    private static func invariantStyle(at ordinal: UInt16) -> (
        flags: UInt8, color: UInt32
    )? {
        switch ordinal {
        case 0: (25, 0)
        case 5, 35, 44, 53, 62, 73, 77, 80, 85, 89, 93:
            (17, 16_777_215)
        case 7, 24, 27, 30: (17, 8_421_504)
        case 10: (25, 2_105_376)
        case 14: (25, 1_052_688)
        case 21: (25, 1_579_032)
        case 32, 41, 50, 59: (25, 526_344)
        case 68: (25, 3_158_064)
        case 96: (17, 255)
        default: nil
        }
    }

    private static func invariantModifierOrdinal(at slot: UInt16) -> UInt16 {
        switch slot {
        case 0: 1
        case 1: 11
        case 2: 15
        case 3: 16
        case 4: 18
        case 5: 22
        case 6: 33
        case 7: 37
        case 8: 42
        case 9: 46
        case 10: 51
        case 11: 55
        case 12: 60
        case 13: 64
        default: 69
        }
    }

    private static func invariantModifierPayload(
        at slot: UInt16
    ) -> (flags: UInt8, auxiliary: UInt16, payload0: UInt32, payload1: UInt32) {
        switch slot {
        case 0: (2, 15, 4, 0)
        case 1, 2: (2, 15, 2, 0)
        case 3: (12, 232, 80, 0)
        case 4: (11, 15, 200, 100)
        case 5: (2, 10, 2, 0)
        case 6, 8, 10, 12: (2, 5, 1, 0)
        case 7, 9, 11, 13: (11, 15, 120, 16)
        default: (2, 15, 2, 0)
        }
    }

    private static func invariantPrimitiveOrdinal(at slot: UInt16) -> UInt16 {
        switch slot {
        case 0: 2
        case 1: 3
        case 2: 4
        case 3: 17
        case 4: 20
        case 5: 23
        case 6: 34
        case 7: 43
        case 8: 52
        case 9: 61
        case 10: 70
        case 11: 71
        default: 83
        }
    }

    private static func invariantPrimitivePayload(
        at slot: UInt16
    ) -> (kind: StaticSignalAnalyzerNRFScopeKind, auxiliary: UInt16, payload0: UInt32) {
        switch slot {
        case 0: (.vStack, 1, 4)
        case 1: (.hStack, 1, 4)
        case 2: (.vStack, 0, 2)
        case 3: (.zStack, 257, 0)
        case 4: (.vStack, 1, 2)
        case 5...9: (.hStack, 1, 2)
        case 10: (.vStack, 1, 2)
        default: (.hStack, 1, 4)
        }
    }

    private static func actionOrdinal(at index: UInt16) -> UInt16 {
        switch index {
        case 0: 74
        case 1: 78
        case 2: 81
        case 3: 86
        case 4: 90
        default: 94
        }
    }

    private static func actionIdentity(at index: UInt16) -> UInt16 {
        switch index {
        case 0: 315
        case 1: 35_973
        case 2: 17_159
        case 3: 45_233
        case 4: 40_502
        default: 48_398
        }
    }

    private static func canvasOrdinal(at index: UInt16) -> UInt16 {
        switch index {
        case 0: 19
        case 1: 38
        case 2: 47
        case 3: 56
        default: 65
        }
    }

    private static func canvasIdentity(at index: UInt16) -> UInt16 {
        switch index {
        case 0: 11_918
        case 1: 42_967
        case 2: 34_040
        case 3: 54_698
        default: 8_136
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
