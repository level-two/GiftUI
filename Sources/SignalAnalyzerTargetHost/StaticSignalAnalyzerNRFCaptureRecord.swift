import SignalAnalyzerDomain

/// Exact target encoding for one transition. The portable transition value
/// stays unchanged; firmware stores two 2,404-entry slots in caller RAM.
package struct StaticSignalAnalyzerNRFCaptureRecord: Equatable, Sendable {
    package static let byteCount = 24

    private let seconds: Int64
    private let attoseconds: Int64
    private let channelRawValue: UInt32
    private let levelRawValue: UInt32

    package init?(_ transition: SignalTransition) {
        let components = transition.timestamp.components
        guard transition.channelID.isStandard,
            transition.timestamp >= .zero,
            components.seconds >= 0,
            components.attoseconds >= 0,
            components.attoseconds < 1_000_000_000_000_000_000
        else { return nil }
        seconds = components.seconds
        attoseconds = components.attoseconds
        channelRawValue = UInt32(transition.channelID.rawValue)
        levelRawValue = transition.level == .low ? 0 : 1
    }

    package var transition: SignalTransition? {
        guard seconds >= 0, attoseconds >= 0,
            attoseconds < 1_000_000_000_000_000_000,
            channelRawValue >= 1, channelRawValue <= 4,
            levelRawValue <= 1
        else { return nil }
        return SignalTransition(
            channelID: SignalChannelID(rawValue: Int(channelRawValue)),
            timestamp: Duration(
                secondsComponent: seconds,
                attosecondsComponent: attoseconds
            ),
            level: levelRawValue == 0 ? .low : .high
        )
    }
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
