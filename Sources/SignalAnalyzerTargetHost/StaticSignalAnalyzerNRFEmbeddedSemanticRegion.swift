/// Target-safe candidate and published semantic region ownership. A caller
/// lends both fixed profile slices for one synchronous presentation attempt.
package enum StaticSignalAnalyzerNRFEmbeddedSemanticRegion {
    package static let byteCount = 3_024
    private static let prefixByteCount = 88
    private static let checksumOffset = 84
    private static let magic: UInt32 = 0x5341_4E43
    private static let tableMagic: UInt32 = 0x5341_4E54
    private static let rootIdentity: UInt32 = 1_410_692_621

    package static func stage(
        variant: StaticSignalAnalyzerNRFSemanticVariant,
        model: borrowing StaticSignalAnalyzerNRFModelLocation,
        capture: borrowing StaticSignalAnalyzerNRFCaptureRegions,
        in candidate: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        guard candidate.count == byteCount, candidate.baseAddress != nil,
            (model.errorMessage != nil) == (variant == .diagnostic)
        else { return nil }
        candidate.initializeMemory(as: UInt8.self, repeating: 0)
        encodePrefix(variant: variant, in: candidate)
        let count: UInt16 = variant == .normal ? 96 : 98
        guard
            StaticSignalAnalyzerNRFTopologyWriter.populateShape(
                variant: variant, in: candidate
            ) == count,
            StaticSignalAnalyzerNRFTopologyWriter.populateBindings(
                scopeCount: count, in: candidate
            ),
            StaticSignalAnalyzerNRFTopologyWriter.populateInvariantPrimitives(
                scopeCount: count, in: candidate
            ),
            StaticSignalAnalyzerNRFTopologyWriter.populateInvariantLayoutModifiers(
                scopeCount: count, in: candidate
            ),
            StaticSignalAnalyzerNRFTopologyWriter.populateInvariantStyles(
                scopeCount: count, in: candidate
            ),
            StaticSignalAnalyzerNRFModelModifierWriter.populate(
                model: model, capture: capture, in: candidate
            ),
            let textBytes = StaticSignalAnalyzerNRFModelTextWriter.populate(
                variant: variant, model: model, capture: capture, in: candidate
            ),
            StaticSignalAnalyzerNRFEmbeddedSemanticValidator.validate(
                variant: variant, textByteCount: textBytes, in: candidate
            )
        else { return nil }
        seal(scopeCount: count, textByteCount: textBytes, in: candidate)
        store(checksum(candidate), at: checksumOffset, in: candidate)
        return verify(candidate, state: 1) ? textBytes : nil
    }

    package static func publish(
        revision: UInt32,
        candidate: UnsafeMutableRawBufferPointer,
        published: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard revision > 0, candidate.count == byteCount,
            published.count == byteCount,
            candidate.baseAddress != nil, published.baseAddress != nil,
            regionsDisjoint(candidate, published),
            verify(candidate, state: 1), canPublish(revision, over: published)
        else { return false }
        published.baseAddress!.copyMemory(from: candidate.baseAddress!, byteCount: byteCount)
        published[6] = 2
        store(revision, at: 28, in: published)
        store(checksum(published), at: checksumOffset, in: published)
        return verify(published, state: 2)
    }

    package static func verifyPublished(
        _ published: UnsafeMutableRawBufferPointer
    ) -> Bool {
        verify(published, state: 2)
    }

    private static func verify(
        _ region: UnsafeMutableRawBufferPointer,
        state: UInt8
    ) -> Bool {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == byteCount, region.baseAddress != nil,
            loadUInt32(at: 0, in: region) == magic,
            loadUInt16(at: 4, in: region) == 1,
            region[6] == state,
            let variant = StaticSignalAnalyzerNRFSemanticVariant(rawValue: region[7]),
            loadUInt32(at: 8, in: region) == rootIdentity,
            loadUInt32(at: checksumOffset, in: region) == checksum(region),
            loadUInt32(at: table.reservedOffset, in: region) == tableMagic,
            loadUInt16(at: table.reservedOffset + 8, in: region) == 6,
            loadUInt16(at: table.reservedOffset + 10, in: region) == 2,
            loadUInt32(at: table.reservedOffset + 12, in: region) == 0
        else { return false }
        let scopeCount: UInt16 = variant == .normal ? 96 : 98
        let textBytes = loadUInt16(at: table.reservedOffset + 6, in: region)
        guard loadUInt16(at: table.reservedOffset + 4, in: region) == scopeCount,
            loadUInt16(at: 12, in: region) == (variant == .normal ? 47 : 48),
            loadUInt16(at: 14, in: region) == 14,
            loadUInt16(at: 16, in: region) == (variant == .normal ? 49 : 50),
            loadUInt16(at: 18, in: region) == 6,
            loadUInt16(at: 20, in: region) == 34,
            loadUInt16(at: 22, in: region) == (variant == .normal ? 124 : 126),
            loadUInt16(at: 24, in: region) == (variant == .normal ? 201 : 203),
            loadUInt16(at: 26, in: region) == 5,
            state != 1 || loadUInt32(at: 28, in: region) == 0,
            state != 2 || loadUInt32(at: 28, in: region) > 0,
            StaticSignalAnalyzerNRFEmbeddedSemanticValidator.validate(
                variant: variant, textByteCount: textBytes, in: region
            )
        else { return false }
        var canvas: UInt16 = 0
        while canvas < 5 {
            let offset = 32 + Int(canvas) * 8
            guard loadUInt16(at: offset, in: region) == canvas + 1,
                loadUInt16(at: offset + 2, in: region) == (canvas == 0 ? 1 : 2),
                loadUInt16(at: offset + 4, in: region) == (canvas == 0 ? 0 : 32),
                loadUInt16(at: offset + 6, in: region) == 0
            else { return false }
            canvas += 1
        }
        var action: UInt16 = 0
        while action < 6 {
            guard loadUInt16(at: 72 + Int(action) * 2, in: region) == action
            else { return false }
            action += 1
        }
        return true
    }

    private static func canPublish(
        _ revision: UInt32,
        over published: UnsafeMutableRawBufferPointer
    ) -> Bool {
        var empty = true
        var index = 0
        while index < prefixByteCount {
            if published[index] != 0 {
                empty = false
                break
            }
            index += 1
        }
        if empty { return true }
        return verify(published, state: 2)
            && loadUInt32(at: 28, in: published) < revision
    }

    private static func regionsDisjoint(
        _ first: UnsafeMutableRawBufferPointer,
        _ second: UnsafeMutableRawBufferPointer
    ) -> Bool {
        let firstStart = UInt(bitPattern: first.baseAddress!)
        let secondStart = UInt(bitPattern: second.baseAddress!)
        let firstEnd = firstStart.addingReportingOverflow(UInt(byteCount))
        let secondEnd = secondStart.addingReportingOverflow(UInt(byteCount))
        return !firstEnd.overflow && !secondEnd.overflow
            && (firstEnd.partialValue <= secondStart
                || secondEnd.partialValue <= firstStart)
    }

    private static func encodePrefix(
        variant: StaticSignalAnalyzerNRFSemanticVariant,
        in region: UnsafeMutableRawBufferPointer
    ) {
        store(magic, at: 0, in: region)
        store(UInt16(1), at: 4, in: region)
        region[6] = 1
        region[7] = variant.rawValue
        store(rootIdentity, at: 8, in: region)
        store(variant == .normal ? UInt16(47) : 48, at: 12, in: region)
        store(UInt16(14), at: 14, in: region)
        store(variant == .normal ? UInt16(49) : 50, at: 16, in: region)
        store(UInt16(6), at: 18, in: region)
        store(UInt16(34), at: 20, in: region)
        store(variant == .normal ? UInt16(124) : 126, at: 22, in: region)
        store(variant == .normal ? UInt16(201) : 203, at: 24, in: region)
        store(UInt16(5), at: 26, in: region)
        var canvas: UInt16 = 0
        while canvas < 5 {
            let offset = 32 + Int(canvas) * 8
            store(canvas + 1, at: offset, in: region)
            store(canvas == 0 ? UInt16(1) : 2, at: offset + 2, in: region)
            store(canvas == 0 ? UInt16(0) : 32, at: offset + 4, in: region)
            canvas += 1
        }
        var action: UInt16 = 0
        while action < 6 {
            store(action, at: 72 + Int(action) * 2, in: region)
            action += 1
        }
    }

    private static func seal(
        scopeCount: UInt16,
        textByteCount: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) {
        let offset = StaticSignalAnalyzerNRFPackedSemanticRecords.reservedOffset
        store(tableMagic, at: offset, in: region)
        store(scopeCount, at: offset + 4, in: region)
        store(textByteCount, at: offset + 6, in: region)
        store(UInt16(6), at: offset + 8, in: region)
        store(UInt16(2), at: offset + 10, in: region)
    }

    private static func checksum(_ region: UnsafeMutableRawBufferPointer) -> UInt32 {
        var value: UInt32 = 2_166_136_261
        var index = 0
        while index < byteCount {
            if index < checksumOffset || index >= checksumOffset + 4 {
                value ^= UInt32(region[index])
                value = value &* 16_777_619
            }
            index += 1
        }
        return value
    }

    private static func store(
        _ value: UInt16, at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) {
        region[offset] = UInt8(truncatingIfNeeded: value)
        region[offset + 1] = UInt8(truncatingIfNeeded: value >> 8)
    }

    private static func store(
        _ value: UInt32, at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) {
        region[offset] = UInt8(truncatingIfNeeded: value)
        region[offset + 1] = UInt8(truncatingIfNeeded: value >> 8)
        region[offset + 2] = UInt8(truncatingIfNeeded: value >> 16)
        region[offset + 3] = UInt8(truncatingIfNeeded: value >> 24)
    }

    private static func loadUInt16(
        at offset: Int, in region: UnsafeMutableRawBufferPointer
    ) -> UInt16 {
        UInt16(region[offset]) | UInt16(region[offset + 1]) << 8
    }

    private static func loadUInt32(
        at offset: Int, in region: UnsafeMutableRawBufferPointer
    ) -> UInt32 {
        UInt32(region[offset]) | UInt32(region[offset + 1]) << 8
            | UInt32(region[offset + 2]) << 16 | UInt32(region[offset + 3]) << 24
    }
}
