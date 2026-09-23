/// Validates the complete generated UTF-8 table before another target stage
/// may borrow it. The expected fingerprint binds the tree to its generator.
package enum StaticSignalAnalyzerNRFEmbeddedSemanticValidator {
    package static func validate(
        variant: StaticSignalAnalyzerNRFSemanticVariant,
        textByteCount: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        let count: UInt16 = variant == .normal ? 96 : 98
        guard region.count == table.regionByteCount,
            textByteCount <= table.maximumTextByteCount,
            let root = table.scope(at: 0, in: region),
            root.kind == .modifier,
            root.parent == table.missingOrdinal,
            root.nextSibling == table.missingOrdinal
        else { return false }

        var fingerprint: UInt64 = 0xCBF2_9CE4_8422_2325
        var ordinal: UInt16 = 0
        var coveredText: UInt16 = 0
        var textScopes: UInt16 = 0
        var canvasMask: UInt8 = 0
        while ordinal < count {
            guard let record = table.scope(at: ordinal, in: region),
                validPayload(record, coveredText: coveredText, in: region)
            else { return false }
            fingerprint = mix(record.identity, into: fingerprint)
            fingerprint = mix(record.parent, into: fingerprint)
            fingerprint = mix(record.firstChild, into: fingerprint)
            fingerprint = mix(record.nextSibling, into: fingerprint)
            fingerprint =
                (fingerprint ^ UInt64(record.kind.rawValue))
                &* 0x100_0000_01B3

            if ordinal > 0 {
                guard record.parent < ordinal,
                    incomingLinks(to: ordinal, count: count, in: region) == 1
                else { return false }
            }
            if record.firstChild != table.missingOrdinal {
                guard record.firstChild > ordinal,
                    record.firstChild < count,
                    table.scope(at: record.firstChild, in: region)?.parent == ordinal
                else { return false }
            }
            if record.nextSibling != table.missingOrdinal {
                guard record.nextSibling > ordinal,
                    record.nextSibling < count,
                    table.scope(at: record.nextSibling, in: region)?.parent == record.parent
                else { return false }
            }
            var earlier: UInt16 = 0
            while earlier < ordinal {
                guard table.scope(at: earlier, in: region)?.identity != record.identity
                else { return false }
                earlier += 1
            }
            if record.kind == .text {
                coveredText += UInt16(record.payload1)
                textScopes += 1
            }
            if record.kind == .canvas {
                let bit = UInt8(1) << UInt8(record.payload0 - 1)
                guard canvasMask & bit == 0 else { return false }
                canvasMask |= bit
            }
            ordinal += 1
        }
        guard coveredText == textByteCount,
            textScopes == (variant == .normal ? 20 : 21),
            canvasMask == 0b1_1111,
            fingerprint
                == (variant == .normal
                    ? table.normalTopologyFingerprint
                    : table.diagnosticTopologyFingerprint)
        else { return false }

        var action: UInt16 = 0
        while action < table.actionCount {
            guard table.actionScope(at: action, in: region) == actionOrdinal(action)
            else { return false }
            action += 1
        }
        return true
    }

    private static func validPayload(
        _ record: StaticSignalAnalyzerNRFScopeRecord,
        coveredText: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        let zeroTail = record.payload1 == 0 && record.payload2 == 0
        switch record.kind {
        case .proxy:
            return record.flags == 0 && record.auxiliary == 0
                && record.payload0 == 0 && zeroTail
        case .vStack, .hStack:
            return record.flags == 0 && record.auxiliary <= 2 && zeroTail
        case .zStack:
            return record.flags == 0 && record.auxiliary & 0xFF <= 1
                && record.auxiliary >> 8 <= 2 && record.payload0 == 0 && zeroTail
        case .spacer:
            return record.flags == 0 && record.auxiliary == 0 && zeroTail
        case .text:
            guard record.flags == 0 && record.auxiliary == 0,
                record.payload2 == 0,
                record.payload0 == UInt32(coveredText),
                record.payload1
                    <= UInt32(
                        StaticSignalAnalyzerNRFPackedSemanticRecords.maximumTextByteCount
                            - coveredText)
            else { return false }
            return StaticSignalAnalyzerNRFUTF8TextPool.scalarCount(
                from: coveredText,
                byteCount: UInt16(record.payload1),
                in: region
            ) != nil
        case .canvas:
            return record.flags == 0 && record.auxiliary == 0
                && (1 ... 5).contains(record.payload0) && zeroTail
        case .modifier:
            guard record.payload2 == 0 else { return false }
            switch record.flags {
            case 1, 65:
                return record.auxiliary == 0 && record.payload0 == 0
                    && record.payload1 == 0
            case 17, 25:
                return record.auxiliary == 0
                    && record.payload0 <= 0xFF_FF_FF
                    && record.payload1 == 0
            case 2:
                return record.auxiliary <= 15 && record.payload1 == 0
            case 11:
                return record.auxiliary <= 31
                    && (record.auxiliary & 1 != 0 || record.payload0 == 0)
                    && (record.auxiliary & 2 != 0 || record.payload1 == 0)
            case 12:
                return record.auxiliary <= 0x1FF
                    && record.auxiliary & 6 != 6
                    && record.auxiliary & 48 != 48
            default: return false
            }
        }
    }

    private static func incomingLinks(
        to target: UInt16,
        count: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt8 {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        var links: UInt8 = 0
        var ordinal: UInt16 = 0
        while ordinal < count {
            if let record = table.scope(at: ordinal, in: region) {
                if record.firstChild == target { links += 1 }
                if record.nextSibling == target { links += 1 }
            }
            ordinal += 1
        }
        return links
    }

    private static func actionOrdinal(_ action: UInt16) -> UInt16 {
        switch action {
        case 0: 74
        case 1: 78
        case 2: 81
        case 3: 86
        case 4: 90
        default: 94
        }
    }

    private static func mix(_ value: UInt16, into hash: UInt64) -> UInt64 {
        let low =
            (hash ^ UInt64(UInt8(truncatingIfNeeded: value)))
            &* 0x100_0000_01B3
        return (low ^ UInt64(UInt8(truncatingIfNeeded: value >> 8)))
            &* 0x100_0000_01B3
    }

}
