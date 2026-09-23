/// Target-safe layout modifier values decoded from the validated packed table.
package enum StaticSignalAnalyzerNRFEmbeddedLayoutModifier: Equatable {
    package enum Limit: Equatable {
        case points(Int32)
        case infinity
    }

    case passthrough
    case padding(edges: UInt8, length: Int32)
    case fixedFrame(
        width: Int32?, height: Int32?, horizontal: UInt8, vertical: UInt8
    )
    case flexibleFrame(
        minWidth: Int32?, maxWidth: Limit?,
        minHeight: Int32?, maxHeight: Limit?,
        horizontal: UInt8, vertical: UInt8
    )

    package init?(record: StaticSignalAnalyzerNRFScopeRecord) {
        guard record.kind == .modifier, record.flags & 0x80 == 0 else {
            return nil
        }
        let kind = record.flags & 7
        let renderCode = (record.flags >> 3) & 7
        let disablesActions = record.flags & 0x40 != 0
        guard !disablesActions || (kind == 1 && renderCode == 0) else {
            return nil
        }
        switch kind {
        case 1:
            guard renderCode == 0 || renderCode == 2 || renderCode == 3,
                record.auxiliary == 0,
                record.payload1 == 0, record.payload2 == 0,
                renderCode != 0 || record.payload0 == 0,
                record.payload0 & 0xFF00_0000 == 0
            else { return nil }
            self = .passthrough
        case 2:
            guard renderCode == 0, record.auxiliary <= 15,
                record.payload1 == 0, record.payload2 == 0
            else { return nil }
            self = .padding(
                edges: UInt8(record.auxiliary),
                length: Int32(bitPattern: record.payload0)
            )
        case 3:
            let bits = record.auxiliary
            guard renderCode == 1, bits & ~UInt16(0x1F) == 0,
                record.payload2 == 0,
                bits & 1 != 0 || record.payload0 == 0,
                bits & 2 != 0 || record.payload1 == 0,
                let alignment = Self.alignment(bits >> 2)
            else { return nil }
            self = .fixedFrame(
                width: bits & 1 != 0 ? Int32(bitPattern: record.payload0) : nil,
                height: bits & 2 != 0 ? Int32(bitPattern: record.payload1) : nil,
                horizontal: alignment.0, vertical: alignment.1
            )
        case 4:
            let bits = record.auxiliary
            guard renderCode == 1, bits & ~UInt16(0x1FF) == 0,
                bits & 6 != 6, bits & 48 != 48,
                let alignment = Self.alignment(bits >> 6)
            else { return nil }
            var used: UInt8 = 0
            func next() -> Int32? {
                let value: UInt32
                switch used {
                case 0: value = record.payload0
                case 1: value = record.payload1
                case 2: value = record.payload2
                default: return nil
                }
                used += 1
                return Int32(bitPattern: value)
            }
            let minWidth = bits & 1 != 0 ? next() : nil
            let maxWidth: Limit?
            if bits & 2 != 0 {
                guard let value = next() else { return nil }
                maxWidth = .points(value)
            } else {
                maxWidth = bits & 4 != 0 ? .infinity : nil
            }
            let minHeight = bits & 8 != 0 ? next() : nil
            let maxHeight: Limit?
            if bits & 16 != 0 {
                guard let value = next() else { return nil }
                maxHeight = .points(value)
            } else {
                maxHeight = bits & 32 != 0 ? .infinity : nil
            }
            guard used <= 3,
                used > 0 || record.payload0 == 0,
                used > 1 || record.payload1 == 0,
                used > 2 || record.payload2 == 0,
                bits & 1 == 0 || minWidth != nil,
                bits & 8 == 0 || minHeight != nil
            else { return nil }
            self = .flexibleFrame(
                minWidth: minWidth, maxWidth: maxWidth,
                minHeight: minHeight, maxHeight: maxHeight,
                horizontal: alignment.0, vertical: alignment.1
            )
        default:
            return nil
        }
    }

    private static func alignment(_ bits: UInt16) -> (UInt8, UInt8)? {
        guard bits < 6 else { return nil }
        let horizontal = UInt8(bits & 1)
        let vertical = UInt8(bits >> 1)
        guard vertical <= 2 else { return nil }
        return (horizontal, vertical)
    }
}
