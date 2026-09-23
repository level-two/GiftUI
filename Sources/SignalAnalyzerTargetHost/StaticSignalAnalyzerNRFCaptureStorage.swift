/// Exact target encoding for one transition. The portable value conversion
/// is in a separate source so this same record builds in Embedded Swift.
package struct StaticSignalAnalyzerNRFCaptureRecord: Equatable, Sendable {
    package static let byteCount = 24

    package let seconds: Int64
    package let attoseconds: Int64
    package let channelRawValue: UInt32
    package let levelRawValue: UInt32
}

package enum StaticSignalAnalyzerNRFCaptureSlot: UInt8 {
    case live = 0
    case snapshot = 1
}

/// Borrows the exact 115,392-byte C region without constructing Swift arrays
/// or copying either capture. The caller retains the region until teardown.
package struct StaticSignalAnalyzerNRFCaptureRegions: ~Copyable {
    package static let entriesPerSlot = 2_404
    package static let requiredByteCount =
        2 * entriesPerSlot * StaticSignalAnalyzerNRFCaptureRecord.byteCount

    private let storage: UnsafeMutableRawBufferPointer

    package init?(storage: UnsafeMutableRawBufferPointer) {
        guard storage.count == Self.requiredByteCount,
            let address = storage.baseAddress,
            UInt(bitPattern: address) & 7 == 0,
            MemoryLayout<StaticSignalAnalyzerNRFCaptureRecord>.stride
                == StaticSignalAnalyzerNRFCaptureRecord.byteCount
        else { return nil }
        self.storage = storage
    }

    package mutating func store(
        _ record: StaticSignalAnalyzerNRFCaptureRecord,
        in slot: StaticSignalAnalyzerNRFCaptureSlot,
        at index: Int
    ) -> Bool {
        guard let offset = offset(for: slot, index: index),
            let address = storage.baseAddress
        else { return false }
        address.storeBytes(
            of: record, toByteOffset: offset, as: StaticSignalAnalyzerNRFCaptureRecord.self)
        return true
    }

    package borrowing func load(
        from slot: StaticSignalAnalyzerNRFCaptureSlot,
        at index: Int
    ) -> StaticSignalAnalyzerNRFCaptureRecord? {
        guard let offset = offset(for: slot, index: index),
            let address = storage.baseAddress
        else { return nil }
        return address.load(fromByteOffset: offset, as: StaticSignalAnalyzerNRFCaptureRecord.self)
    }

    private borrowing func offset(
        for slot: StaticSignalAnalyzerNRFCaptureSlot,
        index: Int
    ) -> Int? {
        guard index >= 0, index < Self.entriesPerSlot else { return nil }
        return (Int(slot.rawValue) * Self.entriesPerSlot + index)
            * StaticSignalAnalyzerNRFCaptureRecord.byteCount
    }
}
