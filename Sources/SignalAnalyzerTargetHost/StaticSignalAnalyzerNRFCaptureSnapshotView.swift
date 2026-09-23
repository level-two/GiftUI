import SignalAnalyzerDomain

/// Validated, scoped read access to one copied capture snapshot slot.
/// The caller keeps the 115,392-byte region alive and unchanged for this scope.
package struct StaticSignalAnalyzerNRFCaptureSnapshotView: ~Copyable {
    private let regions: StaticSignalAnalyzerNRFCaptureRegions
    package let revision: UInt32
    package let count: UInt16
    package let duration: Duration
    package let retainedLowerBound: Duration
    package let baselineLevels: SignalChannelLevels

    package init?(
        storage: UnsafeMutableRawBufferPointer,
        revision: UInt32,
        count: UInt16,
        duration: Duration,
        retainedLowerBound: Duration,
        baselineLevels: SignalChannelLevels
    ) {
        guard count <= StaticSignalAnalyzerNRFCaptureRegions.entriesPerSlot,
            duration >= .zero,
            retainedLowerBound >= .zero,
            retainedLowerBound <= duration,
            revision != 0
                || (count == 0 && duration == .zero && retainedLowerBound == .zero
                    && baselineLevels == .allLow),
            let regions = StaticSignalAnalyzerNRFCaptureRegions(storage: storage)
        else { return nil }

        var preceding = retainedLowerBound
        for index in 0 ..< Int(count) {
            guard let transition = regions.load(from: .snapshot, at: index)?.transition,
                transition.timestamp >= preceding,
                transition.timestamp <= duration
            else { return nil }
            preceding = transition.timestamp
        }

        self.regions = consume regions
        self.revision = revision
        self.count = count
        self.duration = duration
        self.retainedLowerBound = retainedLowerBound
        self.baselineLevels = baselineLevels
    }

    package borrowing func transition(at index: UInt16) -> SignalTransition? {
        guard index < count else { return nil }
        return regions.load(from: .snapshot, at: Int(index))?.transition
    }

    package borrowing func visibleRange(window: Duration) -> Range<Duration>? {
        guard window > .zero else { return nil }
        let end = max(window, duration)
        return max(.zero, end - window) ..< end
    }
}
