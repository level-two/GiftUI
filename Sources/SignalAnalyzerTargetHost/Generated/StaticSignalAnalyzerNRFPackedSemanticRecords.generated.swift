// Generated storage schema for the bounded Signal Analyzer Static semantic projection.
// The table is not a complete semantic result until the portable hierarchy populates it.

package enum StaticSignalAnalyzerNRFScopeKind: UInt8, Sendable {
    case proxy = 1
    case vStack = 2
    case hStack = 3
    case zStack = 4
    case spacer = 5
    case text = 6
    case canvas = 7
    case modifier = 8
}

package struct StaticSignalAnalyzerNRFScopeRecord: Equatable, Sendable {
    package let identity: UInt16
    package let parent: UInt16
    package let firstChild: UInt16
    package let nextSibling: UInt16
    package let kind: StaticSignalAnalyzerNRFScopeKind
    package let flags: UInt8
    package let auxiliary: UInt16
    package let payload0: UInt32
    package let payload1: UInt32
    package let payload2: UInt32

    package init(
        identity: UInt16,
        parent: UInt16,
        firstChild: UInt16,
        nextSibling: UInt16,
        kind: StaticSignalAnalyzerNRFScopeKind,
        flags: UInt8,
        auxiliary: UInt16,
        payload0: UInt32,
        payload1: UInt32,
        payload2: UInt32
    ) {
        self.identity = identity
        self.parent = parent
        self.firstChild = firstChild
        self.nextSibling = nextSibling
        self.kind = kind
        self.flags = flags
        self.auxiliary = auxiliary
        self.payload0 = payload0
        self.payload1 = payload1
        self.payload2 = payload2
    }
}

package struct StaticSignalAnalyzerNRFPackedTableSummary: Equatable, Sendable {
    package let scopeCount: UInt16
    package let scalarCount: UInt16

    package init(scopeCount: UInt16, scalarCount: UInt16) {
        self.scopeCount = scopeCount
        self.scalarCount = scalarCount
    }
}

/// Byte-level table operations on a caller-owned 3,024-byte semantic region.
/// No operation allocates a region or lets a pointer escape the borrow.
package enum StaticSignalAnalyzerNRFPackedSemanticRecords {
    package static let maximumScopeCount: UInt16 = 98
    package static let maximumScalarCount: UInt16 = 139
    package static let actionCount: UInt16 = 6
    package static let missingOrdinal = UInt16.max
    package static let scopeOffset = 88
    package static let scopeStride = 24
    package static let scalarOffset = 2_440
    package static let actionOffset = 2_996
    package static let reservedOffset = 3_008
    package static let regionByteCount = 3_024
    private static let tableMagic: UInt32 = 0x5341_4E54
    private static let tableSchema: UInt16 = 1

    package static func storeScope(
        _ record: StaticSignalAnalyzerNRFScopeRecord,
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard validRegion(region), ordinal < maximumScopeCount,
            record.identity != 0,
            validRelation(record.parent),
            validRelation(record.firstChild),
            validRelation(record.nextSibling)
        else { return false }
        let offset = scopeOffset + Int(ordinal) * scopeStride
        put(record.identity, in: region, at: offset)
        put(record.parent, in: region, at: offset + 2)
        put(record.firstChild, in: region, at: offset + 4)
        put(record.nextSibling, in: region, at: offset + 6)
        region[offset + 8] = record.kind.rawValue
        region[offset + 9] = record.flags
        put(record.auxiliary, in: region, at: offset + 10)
        put(record.payload0, in: region, at: offset + 12)
        put(record.payload1, in: region, at: offset + 16)
        put(record.payload2, in: region, at: offset + 20)
        return true
    }

    package static func scope(
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFScopeRecord? {
        guard validRegion(region), ordinal < maximumScopeCount else { return nil }
        let offset = scopeOffset + Int(ordinal) * scopeStride
        guard let kind = StaticSignalAnalyzerNRFScopeKind(rawValue: region[offset + 8]),
            getUInt16(from: region, at: offset) != 0,
            validRelation(getUInt16(from: region, at: offset + 2)),
            validRelation(getUInt16(from: region, at: offset + 4)),
            validRelation(getUInt16(from: region, at: offset + 6))
        else { return nil }
        return StaticSignalAnalyzerNRFScopeRecord(
            identity: getUInt16(from: region, at: offset),
            parent: getUInt16(from: region, at: offset + 2),
            firstChild: getUInt16(from: region, at: offset + 4),
            nextSibling: getUInt16(from: region, at: offset + 6),
            kind: kind,
            flags: region[offset + 9],
            auxiliary: getUInt16(from: region, at: offset + 10),
            payload0: getUInt32(from: region, at: offset + 12),
            payload1: getUInt32(from: region, at: offset + 16),
            payload2: getUInt32(from: region, at: offset + 20)
        )
    }

    package static func storeScalar(
        _ scalar: UInt32,
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard validRegion(region), ordinal < maximumScalarCount,
            scalar <= 0x10_FFFF, !(0xD800...0xDFFF).contains(scalar)
        else { return false }
        put(scalar, in: region, at: scalarOffset + Int(ordinal) * 4)
        return true
    }

    package static func scalar(
        at ordinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt32? {
        guard validRegion(region), ordinal < maximumScalarCount else { return nil }
        let value = getUInt32(from: region, at: scalarOffset + Int(ordinal) * 4)
        guard value <= 0x10_FFFF, !(0xD800...0xDFFF).contains(value) else {
            return nil
        }
        return value
    }

    package static func storeActionScope(
        _ scopeOrdinal: UInt16,
        at actionOrdinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard validRegion(region), actionOrdinal < actionCount,
            scopeOrdinal < maximumScopeCount
        else { return false }
        put(scopeOrdinal, in: region, at: actionOffset + Int(actionOrdinal) * 2)
        return true
    }

    package static func actionScope(
        at actionOrdinal: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        guard validRegion(region), actionOrdinal < actionCount else { return nil }
        let ordinal = getUInt16(from: region, at: actionOffset + Int(actionOrdinal) * 2)
        return ordinal < maximumScopeCount ? ordinal : nil
    }

    /// Validate an ordered, fully linked projection before its owning region
    /// is checksummed and published. This does not mutate the region.
    package static func validateTopology(
        scopeCount: UInt16,
        scalarCount: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard validRegion(region), scopeCount > 0,
            scopeCount <= maximumScopeCount,
            scalarCount <= maximumScalarCount,
            let root = scope(at: 0, in: region),
            root.parent == missingOrdinal,
            root.nextSibling == missingOrdinal
        else { return false }

        var ordinal: UInt16 = 0
        while ordinal < scopeCount {
            guard let record = scope(at: ordinal, in: region) else { return false }
            if ordinal > 0 {
                guard record.parent < ordinal,
                    incomingLinkCount(to: ordinal, scopeCount: scopeCount, in: region) == 1
                else { return false }
            }
            if record.firstChild != missingOrdinal {
                guard record.firstChild > ordinal,
                    record.firstChild < scopeCount,
                    scope(at: record.firstChild, in: region)?.parent == ordinal
                else { return false }
            }
            if record.nextSibling != missingOrdinal {
                guard record.nextSibling > ordinal,
                    record.nextSibling < scopeCount,
                    scope(at: record.nextSibling, in: region)?.parent == record.parent
                else { return false }
            }
            var earlier: UInt16 = 0
            while earlier < ordinal {
                guard scope(at: earlier, in: region)?.identity != record.identity else {
                    return false
                }
                earlier += 1
            }
            ordinal += 1
        }

        var scalarOrdinal: UInt16 = 0
        while scalarOrdinal < scalarCount {
            guard scalar(at: scalarOrdinal, in: region) != nil else { return false }
            scalarOrdinal += 1
        }
        var actionOrdinal: UInt16 = 0
        while actionOrdinal < actionCount {
            guard let action = actionScope(at: actionOrdinal, in: region),
                action < scopeCount
            else { return false }
            actionOrdinal += 1
        }
        return true
    }

    /// Finalize only a fully populated table. The owning region must update
    /// its whole-region checksum after this footer is written.
    package static func sealTable(
        scopeCount: UInt16,
        scalarCount: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard validRegion(region),
            footerIsZero(in: region),
            validateTopology(
                scopeCount: scopeCount,
                scalarCount: scalarCount,
                in: region
            )
        else { return false }
        put(tableMagic, in: region, at: reservedOffset)
        put(scopeCount, in: region, at: reservedOffset + 4)
        put(scalarCount, in: region, at: reservedOffset + 6)
        put(actionCount, in: region, at: reservedOffset + 8)
        put(tableSchema, in: region, at: reservedOffset + 10)
        return true
    }

    package static func tableSummary(
        in region: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFPackedTableSummary? {
        guard validRegion(region),
            getUInt32(from: region, at: reservedOffset) == tableMagic,
            getUInt16(from: region, at: reservedOffset + 8) == actionCount,
            getUInt16(from: region, at: reservedOffset + 10) == tableSchema,
            getUInt32(from: region, at: reservedOffset + 12) == 0
        else { return nil }
        let scopeCount = getUInt16(from: region, at: reservedOffset + 4)
        let scalarCount = getUInt16(from: region, at: reservedOffset + 6)
        guard validateTopology(
            scopeCount: scopeCount,
            scalarCount: scalarCount,
            in: region
        ) else { return nil }
        return StaticSignalAnalyzerNRFPackedTableSummary(
            scopeCount: scopeCount,
            scalarCount: scalarCount
        )
    }

    private static func footerIsZero(
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        var offset = reservedOffset
        while offset < regionByteCount {
            if region[offset] != 0 { return false }
            offset += 1
        }
        return true
    }

    private static func incomingLinkCount(
        to target: UInt16,
        scopeCount: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt8 {
        var count: UInt8 = 0
        var source: UInt16 = 0
        while source < scopeCount {
            guard let record = scope(at: source, in: region) else { return 0 }
            if record.firstChild == target { count += 1 }
            if record.nextSibling == target { count += 1 }
            if count > 1 { return count }
            source += 1
        }
        return count
    }

    private static func validRegion(_ region: UnsafeMutableRawBufferPointer) -> Bool {
        region.count == regionByteCount && region.baseAddress != nil
    }

    private static func validRelation(_ ordinal: UInt16) -> Bool {
        ordinal == missingOrdinal || ordinal < maximumScopeCount
    }

    private static func put(
        _ value: UInt16,
        in region: UnsafeMutableRawBufferPointer,
        at offset: Int
    ) {
        region[offset] = UInt8(truncatingIfNeeded: value)
        region[offset + 1] = UInt8(truncatingIfNeeded: value >> 8)
    }

    private static func put(
        _ value: UInt32,
        in region: UnsafeMutableRawBufferPointer,
        at offset: Int
    ) {
        region[offset] = UInt8(truncatingIfNeeded: value)
        region[offset + 1] = UInt8(truncatingIfNeeded: value >> 8)
        region[offset + 2] = UInt8(truncatingIfNeeded: value >> 16)
        region[offset + 3] = UInt8(truncatingIfNeeded: value >> 24)
    }

    private static func getUInt16(
        from region: UnsafeMutableRawBufferPointer,
        at offset: Int
    ) -> UInt16 {
        UInt16(region[offset]) | UInt16(region[offset + 1]) << 8
    }

    private static func getUInt32(
        from region: UnsafeMutableRawBufferPointer,
        at offset: Int
    ) -> UInt32 {
        UInt32(region[offset]) | UInt32(region[offset + 1]) << 8
            | UInt32(region[offset + 2]) << 16 | UInt32(region[offset + 3]) << 24
    }
}
