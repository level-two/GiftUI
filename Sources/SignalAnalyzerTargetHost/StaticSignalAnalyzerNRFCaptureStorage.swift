/// One exact transition in 16 bytes. Attoseconds use fewer than 60 bits;
/// the upper four bits hold the standard channel and digital level.
package struct StaticSignalAnalyzerNRFCaptureRecord: Equatable, Sendable {
    package static let byteCount = 16
    package static let attosecondMask: UInt64 = (UInt64(1) << 60) - 1

    package let seconds: Int64
    package let packedAttoseconds: UInt64

    package var attoseconds: Int64 {
        Int64(packedAttoseconds & Self.attosecondMask)
    }

    package var channelRawValue: UInt32 {
        UInt32((packedAttoseconds >> 60) & 7)
    }

    package var levelRawValue: UInt32 {
        UInt32(packedAttoseconds >> 63)
    }

    package init(
        seconds: Int64, attoseconds: Int64,
        channelRawValue: UInt32, levelRawValue: UInt32
    ) {
        self.seconds = seconds
        packedAttoseconds =
            UInt64(bitPattern: attoseconds) & Self.attosecondMask
            | (UInt64(channelRawValue & 7) << 60)
            | (UInt64(levelRawValue & 1) << 63)
    }
}

package enum StaticSignalAnalyzerNRFCaptureSlot: UInt8 {
    case live = 0
    case snapshot = 1
    case admission = 2
}

/// Borrows the exact 115,392-byte C region without constructing Swift arrays
/// or copying either capture. The caller retains the region until teardown.
package struct StaticSignalAnalyzerNRFCaptureRegions: ~Copyable {
    package static let entriesPerSlot = 2_404
    package static let requiredByteCount =
        3 * entriesPerSlot * StaticSignalAnalyzerNRFCaptureRecord.byteCount

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
