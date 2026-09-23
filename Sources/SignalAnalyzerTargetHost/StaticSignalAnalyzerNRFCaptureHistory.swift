import SignalAnalyzerDomain

package enum StaticSignalAnalyzerNRFCaptureHistoryRejection: Equatable, Sendable {
    case invalidTransition
    case outsideRetainedHistory
    case revisionExhausted
}

package enum StaticSignalAnalyzerNRFCaptureHistoryResult: Equatable, Sendable {
    case accepted(revision: UInt32, change: SignalCaptureChange)
    case rejected(StaticSignalAnalyzerNRFCaptureHistoryRejection)
}

/// Metadata for one copied admission snapshot. The record bytes remain in
/// caller storage until its fact is applied or explicitly discarded.
package struct StaticSignalAnalyzerNRFCaptureSnapshot: Equatable, Sendable {
    package let revision: UInt32
    package let count: UInt16
    package let duration: Duration
    package let retainedLowerBound: Duration
    package let baselineLevels: SignalChannelLevels
}

/// Capture policy state for the caller-owned nRF record region. The live slot
/// contains exactly `count` initialized records; mutation never allocates.
package struct StaticSignalAnalyzerNRFCaptureHistory {
    package private(set) var revision: UInt32 = 0
    package private(set) var count: UInt16 = 0
    package private(set) var duration: Duration = .zero
    package private(set) var retainedLowerBound: Duration = .zero
    package private(set) var baselineLevels: SignalChannelLevels = .allLow

    private var epochSourceTimestamp: Duration = .zero
    private var latestSourceTimestamp: Duration = .zero

    package init(initialRevision: UInt32 = 0) {
        revision = initialRevision
    }

    package mutating func receive(
        _ source: SignalTransition,
        in regions: inout StaticSignalAnalyzerNRFCaptureRegions
    ) -> StaticSignalAnalyzerNRFCaptureHistoryResult {
        guard StaticSignalAnalyzerNRFCaptureRecord(source) != nil else {
            return .rejected(.invalidTransition)
        }
        guard revision < .max else { return .rejected(.revisionExhausted) }

        let timestamp = source.timestamp - epochSourceTimestamp
        guard timestamp >= retainedLowerBound else {
            return .rejected(.outsideRetainedHistory)
        }
        let transition = SignalTransition(
            channelID: source.channelID, timestamp: timestamp, level: source.level
        )
        guard let record = StaticSignalAnalyzerNRFCaptureRecord(transition) else {
            return .rejected(.invalidTransition)
        }

        let oldCount = Int(count)
        var insertion = oldCount
        for index in 0 ..< oldCount {
            guard let existing = regions.load(from: .live, at: index)?.transition else {
                return .rejected(.invalidTransition)
            }
            if existing.timestamp > timestamp {
                insertion = index
                break
            }
        }

        let nextDuration = max(duration, timestamp)
        let timeBound = max(.zero, nextDuration - .seconds(30))
        let combinedCount = oldCount + 1
        var timeTrim = 0
        while timeTrim < combinedCount {
            guard
                let item = mergedElement(
                    at: timeTrim, insertion: insertion, inserted: transition,
                    in: regions
                )
            else { return .rejected(.invalidTransition) }
            if item.timestamp >= timeBound { break }
            timeTrim += 1
        }
        let trim = max(
            timeTrim, combinedCount - StaticSignalAnalyzerNRFCaptureRegions.entriesPerSlot)
        var nextBaselines = baselineLevels
        var nextLowerBound = timeBound
        for index in 0 ..< trim {
            guard
                let item = mergedElement(
                    at: index, insertion: insertion, inserted: transition,
                    in: regions
                )
            else { return .rejected(.invalidTransition) }
            nextBaselines = nextBaselines.replacingLevel(item.level, for: item.channelID)
            if index >= timeTrim { nextLowerBound = max(nextLowerBound, item.timestamp) }
        }

        if trim == 0 {
            if insertion < oldCount {
                for index in stride(from: oldCount, through: insertion + 1, by: -1) {
                    guard let item = regions.load(from: .live, at: index - 1),
                        regions.store(item, in: .live, at: index)
                    else { return .rejected(.invalidTransition) }
                }
            }
            guard regions.store(record, in: .live, at: insertion) else {
                return .rejected(.invalidTransition)
            }
        } else {
            for index in trim ..< combinedCount {
                let destination = index - trim
                let item: StaticSignalAnalyzerNRFCaptureRecord?
                if index == insertion {
                    item = record
                } else {
                    item = regions.load(
                        from: .live, at: index < insertion ? index : index - 1
                    )
                }
                guard let item, regions.store(item, in: .live, at: destination)
                else { return .rejected(.invalidTransition) }
            }
        }

        let baseRevision = revision
        revision += 1
        count = UInt16(combinedCount - trim)
        duration = nextDuration
        retainedLowerBound = nextLowerBound
        baselineLevels = nextBaselines
        latestSourceTimestamp = max(latestSourceTimestamp, source.timestamp)
        return .accepted(
            revision: revision,
            change: .insertAndTrim(
                baseRevision: baseRevision,
                insertionIndex: UInt16(insertion),
                transition: transition,
                evictedPrefixCount: UInt16(trim),
                duration: duration,
                retainedLowerBound: retainedLowerBound,
                baselines: baselineLevels
            )
        )
    }

    package mutating func clear(
        in regions: inout StaticSignalAnalyzerNRFCaptureRegions
    ) -> StaticSignalAnalyzerNRFCaptureHistoryResult {
        guard revision < .max else { return .rejected(.revisionExhausted) }
        var levels = baselineLevels
        for index in 0 ..< Int(count) {
            guard let item = regions.load(from: .live, at: index)?.transition else {
                return .rejected(.invalidTransition)
            }
            levels = levels.replacingLevel(item.level, for: item.channelID)
        }
        let baseRevision = revision
        revision += 1
        count = 0
        duration = .zero
        retainedLowerBound = .zero
        baselineLevels = levels
        epochSourceTimestamp = latestSourceTimestamp
        return .accepted(
            revision: revision,
            change: .reset(baseRevision: baseRevision, baselines: levels)
        )
    }

    /// Copies only initialized live records to the admission slot. The
    /// caller must release the admitted fact before recopying this slot.
    package func snapshot(
        in regions: inout StaticSignalAnalyzerNRFCaptureRegions
    ) -> StaticSignalAnalyzerNRFCaptureSnapshot? {
        for index in 0 ..< Int(count) {
            guard let item = regions.load(from: .live, at: index),
                item.transition != nil,
                regions.store(item, in: .admission, at: index)
            else { return nil }
        }
        return StaticSignalAnalyzerNRFCaptureSnapshot(
            revision: revision,
            count: count,
            duration: duration,
            retainedLowerBound: retainedLowerBound,
            baselineLevels: baselineLevels
        )
    }

    private func mergedElement(
        at index: Int,
        insertion: Int,
        inserted: SignalTransition,
        in regions: borrowing StaticSignalAnalyzerNRFCaptureRegions
    ) -> SignalTransition? {
        if index == insertion { return inserted }
        return regions.load(
            from: .live, at: index < insertion ? index : index - 1
        )?.transition
    }
}

private extension SignalChannelLevels {
    func replacingLevel(_ level: DigitalLevel, for channelID: SignalChannelID) -> Self {
        switch channelID.rawValue {
        case 1: Self(ch1: level, ch2: ch2, ch3: ch3, ch4: ch4)
        case 2: Self(ch1: ch1, ch2: level, ch3: ch3, ch4: ch4)
        case 3: Self(ch1: ch1, ch2: ch2, ch3: level, ch4: ch4)
        case 4: Self(ch1: ch1, ch2: ch2, ch3: ch3, ch4: level)
        default: self
        }
    }
}
