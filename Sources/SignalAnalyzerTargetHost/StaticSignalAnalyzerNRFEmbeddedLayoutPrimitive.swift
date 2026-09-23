/// Target-safe layout primitive values decoded from the validated packed table.
package enum StaticSignalAnalyzerNRFEmbeddedLayoutPrimitive: Equatable {
    case proxy
    case vStack(alignment: UInt8, spacing: Int32)
    case hStack(alignment: UInt8, spacing: Int32)
    case zStack(horizontal: UInt8, vertical: UInt8)
    case spacer(minLength: Int32)
    case text
    case canvas

    package init?(record: StaticSignalAnalyzerNRFScopeRecord) {
        guard record.flags == 0 else { return nil }
        switch record.kind {
        case .proxy:
            guard record.auxiliary == 0,
                record.payload0 == 0, record.payload1 == 0, record.payload2 == 0
            else { return nil }
            self = .proxy
        case .vStack:
            guard record.auxiliary <= 1,
                record.payload1 == 0, record.payload2 == 0
            else { return nil }
            self = .vStack(
                alignment: UInt8(record.auxiliary),
                spacing: Int32(bitPattern: record.payload0)
            )
        case .hStack:
            guard record.auxiliary <= 2,
                record.payload1 == 0, record.payload2 == 0
            else { return nil }
            self = .hStack(
                alignment: UInt8(record.auxiliary),
                spacing: Int32(bitPattern: record.payload0)
            )
        case .zStack:
            let horizontal = UInt8(truncatingIfNeeded: record.auxiliary)
            let vertical = UInt8(truncatingIfNeeded: record.auxiliary >> 8)
            guard horizontal <= 1, vertical <= 2,
                record.payload0 == 0, record.payload1 == 0, record.payload2 == 0
            else { return nil }
            self = .zStack(horizontal: horizontal, vertical: vertical)
        case .spacer:
            guard record.auxiliary == 0,
                record.payload1 == 0, record.payload2 == 0
            else { return nil }
            self = .spacer(minLength: Int32(bitPattern: record.payload0))
        case .text:
            guard record.auxiliary == 0, record.payload2 == 0,
                record.payload0
                    <= UInt32(StaticSignalAnalyzerNRFPackedSemanticRecords.maximumTextByteCount),
                record.payload1 <= UInt32(
                    StaticSignalAnalyzerNRFPackedSemanticRecords.maximumTextByteCount)
                    - record.payload0
            else { return nil }
            self = .text
        case .canvas:
            guard record.auxiliary == 0, (1 ... 5).contains(record.payload0),
                record.payload1 == 0, record.payload2 == 0
            else { return nil }
            self = .canvas
        case .modifier:
            return nil
        }
    }
}
