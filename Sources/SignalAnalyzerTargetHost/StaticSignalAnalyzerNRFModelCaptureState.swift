import SignalAnalyzerDomain

package enum StaticSignalAnalyzerNRFModelCaptureApplyResult: Equatable {
    case applied(changed: Bool)
    case rejected
    case storageInvariantViolation
}

/// Model-owned metadata for the snapshot slot. The caller owns its record
/// bytes and must not replace them while this model state is live.
package struct StaticSignalAnalyzerNRFModelCaptureState {
    package private(set) var revision: UInt32 = 0
    package private(set) var count: UInt16 = 0
    package private(set) var duration: Duration = .zero
    package private(set) var retainedLowerBound: Duration = .zero
    package private(set) var baselineLevels: SignalChannelLevels = .allLow

    package init() {}

    package init(snapshot: borrowing StaticSignalAnalyzerNRFCaptureSnapshotView) {
        revision = snapshot.revision
        count = snapshot.count
        duration = snapshot.duration
        retainedLowerBound = snapshot.retainedLowerBound
        baselineLevels = snapshot.baselineLevels
    }

    package func visibleRange(window: Duration) -> Range<Duration>? {
        guard window > .zero else { return nil }
        let end = max(window, duration)
        return max(.zero, end - window) ..< end
    }

    package mutating func apply(
        revision nextRevision: UInt32,
        change: SignalCaptureChange,
        in regions: inout StaticSignalAnalyzerNRFCaptureRegions
    ) -> StaticSignalAnalyzerNRFModelCaptureApplyResult {
        guard revision < .max, nextRevision == revision + 1 else { return .rejected }
        switch change {
        case .reset(let baseRevision, let baselines):
            guard baseRevision == revision else { return .rejected }
            let changed =
                count != 0 || duration != .zero || retainedLowerBound != .zero
                || baselineLevels != baselines
            revision = nextRevision
            count = 0
            duration = .zero
            retainedLowerBound = .zero
            baselineLevels = baselines
            return .applied(changed: changed)

        case .insertAndTrim(
            let baseRevision, let insertionIndex, let transition,
            let evictedPrefixCount, let nextDuration, let nextLowerBound,
            let nextBaselines
        ):
            let oldCount = Int(count)
            let insertion = Int(insertionIndex)
            let eviction = Int(evictedPrefixCount)
            let combinedCount = oldCount + 1
            let nextCount = combinedCount - eviction
            guard baseRevision == revision,
                insertion <= oldCount,
                eviction <= combinedCount,
                nextCount <= StaticSignalAnalyzerNRFCaptureRegions.entriesPerSlot,
                nextDuration >= .zero,
                nextLowerBound >= .zero,
                nextLowerBound <= nextDuration,
                let insertedRecord = StaticSignalAnalyzerNRFCaptureRecord(transition)
            else { return .rejected }

            var previousTimestamp = nextLowerBound
            var changed =
                nextCount != oldCount || nextDuration != duration
                || nextLowerBound != retainedLowerBound || nextBaselines != baselineLevels
            for sourceIndex in eviction ..< combinedCount {
                guard
                    let record = mergedRecord(
                        at: sourceIndex, insertion: insertion,
                        inserted: insertedRecord, in: regions
                    ), let value = record.transition,
                    value.timestamp >= previousTimestamp,
                    value.timestamp <= nextDuration
                else { return .rejected }
                previousTimestamp = value.timestamp
                let destination = sourceIndex - eviction
                if !changed, regions.load(from: .snapshot, at: destination) != record {
                    changed = true
                }
            }

            if eviction == 0 {
                if insertion < oldCount {
                    for index in stride(from: oldCount, through: insertion + 1, by: -1) {
                        guard let record = regions.load(from: .snapshot, at: index - 1),
                            regions.store(record, in: .snapshot, at: index)
                        else { return .storageInvariantViolation }
                    }
                }
                guard regions.store(insertedRecord, in: .snapshot, at: insertion)
                else { return .storageInvariantViolation }
            } else {
                for sourceIndex in eviction ..< combinedCount {
                    guard
                        let record = mergedRecord(
                            at: sourceIndex, insertion: insertion,
                            inserted: insertedRecord, in: regions
                        ),
                        regions.store(
                            record, in: .snapshot, at: sourceIndex - eviction
                        )
                    else { return .storageInvariantViolation }
                }
            }

            revision = nextRevision
            count = UInt16(nextCount)
            duration = nextDuration
            retainedLowerBound = nextLowerBound
            baselineLevels = nextBaselines
            return .applied(changed: changed)
        }
    }

    private func mergedRecord(
        at index: Int,
        insertion: Int,
        inserted: StaticSignalAnalyzerNRFCaptureRecord,
        in regions: borrowing StaticSignalAnalyzerNRFCaptureRegions
    ) -> StaticSignalAnalyzerNRFCaptureRecord? {
        if index == insertion { return inserted }
        return regions.load(from: .snapshot, at: index < insertion ? index : index - 1)
    }
}
