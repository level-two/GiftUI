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
