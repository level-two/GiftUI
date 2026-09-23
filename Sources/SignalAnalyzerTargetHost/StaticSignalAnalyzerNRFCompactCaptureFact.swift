import SignalAnalyzerDomain

/// Fixed admission representation for one portable capture mutation. The
/// producer rejects an unrepresentable value before it receives a sequence.
package struct StaticSignalAnalyzerNRFCompactCaptureFact: Equatable, Sendable {
    package static let byteCount = 64

    private let transition: StaticSignalAnalyzerNRFCaptureRecord
    private let durationAttoseconds: Int64
    private let lowerBoundAttoseconds: Int64
    package let sequence: UInt32
    private let baseRevision: UInt32
    private let durationSeconds: Int32
    private let lowerBoundSeconds: Int32
    private let insertionIndex: UInt16
    private let evictedPrefixCount: UInt16
    private let baselineBits: UInt8
    private let kind: UInt8
    private let reserved: UInt16

    package init?(sequence: UInt32, revision: UInt32, change: SignalCaptureChange) {
        guard sequence != 0, revision != 0 else { return nil }
        let baseRevision: UInt32
        let transition: StaticSignalAnalyzerNRFCaptureRecord
        let duration: Duration
        let lowerBound: Duration
        let insertionIndex: UInt16
        let evictedPrefixCount: UInt16
        let baselines: SignalChannelLevels
        let kind: UInt8
        switch change {
        case .insertAndTrim(
            let base, let insertion, let value, let eviction,
            let nextDuration, let nextLowerBound, let nextBaselines
        ):
            guard let record = StaticSignalAnalyzerNRFCaptureRecord(value),
                nextLowerBound <= nextDuration
            else { return nil }
            baseRevision = base
            transition = record
            duration = nextDuration
            lowerBound = nextLowerBound
            insertionIndex = insertion
            evictedPrefixCount = eviction
            baselines = nextBaselines
            kind = 0
        case .reset(let base, let nextBaselines):
            baseRevision = base
            transition = StaticSignalAnalyzerNRFCaptureRecord(
                seconds: 0, attoseconds: 0, channelRawValue: 0, levelRawValue: 0
            )
            duration = .zero
            lowerBound = .zero
            insertionIndex = 0
            evictedPrefixCount = 0
            baselines = nextBaselines
            kind = 1
        }
        guard baseRevision < .max, revision == baseRevision + 1,
            let durationSeconds = Int32(exactly: duration.components.seconds),
            let lowerBoundSeconds = Int32(exactly: lowerBound.components.seconds),
            durationSeconds >= 0, lowerBoundSeconds >= 0,
            duration.components.attoseconds >= 0,
            duration.components.attoseconds < 1_000_000_000_000_000_000,
            lowerBound.components.attoseconds >= 0,
            lowerBound.components.attoseconds < 1_000_000_000_000_000_000
        else { return nil }

        self.transition = transition
        durationAttoseconds = duration.components.attoseconds
        lowerBoundAttoseconds = lowerBound.components.attoseconds
        self.sequence = sequence
        self.baseRevision = baseRevision
        self.durationSeconds = durationSeconds
        self.lowerBoundSeconds = lowerBoundSeconds
        self.insertionIndex = insertionIndex
        self.evictedPrefixCount = evictedPrefixCount
        baselineBits = Self.bits(for: baselines)
        self.kind = kind
        reserved = 0
    }

    package var publication: (revision: UInt32, change: SignalCaptureChange)? {
        guard baseRevision < .max, reserved == 0, baselineBits & 0xF0 == 0 else {
            return nil
        }
        let levels = SignalChannelLevels(
            ch1: baselineBits & 1 == 0 ? .low : .high,
            ch2: baselineBits & 2 == 0 ? .low : .high,
            ch3: baselineBits & 4 == 0 ? .low : .high,
            ch4: baselineBits & 8 == 0 ? .low : .high
        )
        let revision = baseRevision + 1
        switch kind {
        case 0:
            guard let value = transition.transition else { return nil }
            return (
                revision,
                .insertAndTrim(
                    baseRevision: baseRevision,
                    insertionIndex: insertionIndex,
                    transition: value,
                    evictedPrefixCount: evictedPrefixCount,
                    duration: Duration(
                        secondsComponent: Int64(durationSeconds),
                        attosecondsComponent: durationAttoseconds
                    ),
                    retainedLowerBound: Duration(
                        secondsComponent: Int64(lowerBoundSeconds),
                        attosecondsComponent: lowerBoundAttoseconds
                    ),
                    baselines: levels
                )
            )
        case 1:
            guard transition.channelRawValue == 0, transition.levelRawValue == 0,
                transition.seconds == 0, transition.attoseconds == 0,
                durationSeconds == 0, durationAttoseconds == 0,
                lowerBoundSeconds == 0, lowerBoundAttoseconds == 0,
                insertionIndex == 0, evictedPrefixCount == 0
            else { return nil }
            return (revision, .reset(baseRevision: baseRevision, baselines: levels))
        default: return nil
        }
    }

    private static func bits(for levels: SignalChannelLevels) -> UInt8 {
        (levels.ch1 == .high ? 1 : 0)
            | (levels.ch2 == .high ? 2 : 0)
            | (levels.ch3 == .high ? 4 : 0)
            | (levels.ch4 == .high ? 8 : 0)
    }
}
