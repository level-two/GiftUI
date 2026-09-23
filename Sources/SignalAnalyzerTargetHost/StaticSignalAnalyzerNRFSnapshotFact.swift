import SignalAnalyzerDomain

/// Metadata for the single capture snapshot whose records occupy the third
/// capture slot. This value fits in each admission region's 128-byte reserve.
package struct StaticSignalAnalyzerNRFSnapshotFact: Equatable, Sendable {
    package static let maximumByteCount = 48

    private let durationSeconds: Int64
    private let durationAttoseconds: Int64
    private let lowerBoundSeconds: Int64
    private let lowerBoundAttoseconds: Int64
    package let sequence: UInt32
    package let revision: UInt32
    package let count: UInt16
    private let baselineBits: UInt8
    private let reserved: UInt8

    package init?(
        sequence: UInt32,
        snapshot: borrowing StaticSignalAnalyzerNRFCaptureSnapshotView
    ) {
        guard sequence != 0 else { return nil }
        durationSeconds = snapshot.duration.components.seconds
        durationAttoseconds = snapshot.duration.components.attoseconds
        lowerBoundSeconds = snapshot.retainedLowerBound.components.seconds
        lowerBoundAttoseconds = snapshot.retainedLowerBound.components.attoseconds
        self.sequence = sequence
        revision = snapshot.revision
        count = snapshot.count
        let levels = snapshot.baselineLevels
        baselineBits =
            (levels.ch1 == .high ? 1 : 0)
            | (levels.ch2 == .high ? 2 : 0)
            | (levels.ch3 == .high ? 4 : 0)
            | (levels.ch4 == .high ? 8 : 0)
        reserved = 0
    }

    package var duration: Duration {
        Duration(
            secondsComponent: durationSeconds,
            attosecondsComponent: durationAttoseconds
        )
    }

    package var retainedLowerBound: Duration {
        Duration(
            secondsComponent: lowerBoundSeconds,
            attosecondsComponent: lowerBoundAttoseconds
        )
    }

    package var baselineLevels: SignalChannelLevels {
        SignalChannelLevels(
            ch1: baselineBits & 1 == 0 ? .low : .high,
            ch2: baselineBits & 2 == 0 ? .low : .high,
            ch3: baselineBits & 4 == 0 ? .low : .high,
            ch4: baselineBits & 8 == 0 ? .low : .high
        )
    }
}
