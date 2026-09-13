import SignalAnalyzerDomain

package enum SignalCaptureStoreRejection: Equatable, Sendable {
    case invalidTransition
    case outsideRetainedHistory
    case revisionExhausted
}

package enum SignalCaptureStoreResult: Equatable, Sendable {
    case accepted(SignalCapturePublication)
    case rejected(SignalCaptureStoreRejection)
}

package struct SignalCaptureStore: Sendable {
    package private(set) var revision: UInt32
    package private(set) var capture: SignalCapture

    private let capacity: Int
    private var epochSourceTimestamp: Duration
    private var latestSourceTimestamp: Duration

    package init(capacity: Int = SignalCapture.maximumTransitionCount) {
        precondition(capacity >= SignalCapture.maximumTransitionCount)
        self.capacity = capacity
        revision = 0
        capture = .empty()
        epochSourceTimestamp = .zero
        latestSourceTimestamp = .zero
    }

    package mutating func receive(_ sourceTransition: SignalTransition) -> SignalCaptureStoreResult
    {
        guard sourceTransition.channelID.isStandard,
            sourceTransition.timestamp >= .zero
        else {
            return .rejected(.invalidTransition)
        }
        guard revision < .max else {
            return .rejected(.revisionExhausted)
        }

        let epochTimestamp = sourceTransition.timestamp - epochSourceTimestamp
        guard epochTimestamp >= capture.retainedLowerBound else {
            return .rejected(.outsideRetainedHistory)
        }

        let transition = SignalTransition(
            channelID: sourceTransition.channelID,
            timestamp: epochTimestamp,
            level: sourceTransition.level
        )
        var transitions = Array(capture.transitions)
        let insertionIndex =
            transitions.firstIndex { $0.timestamp > epochTimestamp }
            ?? transitions.endIndex
        transitions.insert(transition, at: insertionIndex)

        let duration = max(capture.duration, epochTimestamp)
        var retainedLowerBound = max(.zero, duration - .seconds(30))
        var baselines = capture.baselineLevels
        var evictedPrefixCount = 0

        while let first = transitions.first, first.timestamp < retainedLowerBound {
            baselines = baselines.replacingLevel(first.level, for: first.channelID)
            transitions.removeFirst()
            evictedPrefixCount += 1
        }
        while transitions.count > capacity {
            let first = transitions.removeFirst()
            baselines = baselines.replacingLevel(first.level, for: first.channelID)
            retainedLowerBound = max(retainedLowerBound, first.timestamp)
            evictedPrefixCount += 1
        }

        guard
            let nextCapture = SignalCapture(
                transitions: transitions,
                duration: duration,
                retainedLowerBound: retainedLowerBound,
                baselineLevels: baselines
            )
        else {
            return .rejected(.invalidTransition)
        }

        let baseRevision = revision
        revision += 1
        capture = nextCapture
        latestSourceTimestamp = max(latestSourceTimestamp, sourceTransition.timestamp)
        return .accepted(
            .mutation(
                revision: revision,
                change: .insertAndTrim(
                    baseRevision: baseRevision,
                    insertionIndex: UInt16(insertionIndex),
                    transition: transition,
                    evictedPrefixCount: UInt16(evictedPrefixCount),
                    duration: duration,
                    retainedLowerBound: retainedLowerBound,
                    baselines: baselines
                )
            )
        )
    }

    package mutating func clear() -> SignalCaptureStoreResult {
        guard revision < .max else {
            return .rejected(.revisionExhausted)
        }

        let baselines = currentLevels
        let baseRevision = revision
        revision += 1
        capture = SignalCapture(
            transitions: [SignalTransition](),
            duration: .zero,
            baselineLevels: baselines
        )!
        epochSourceTimestamp = latestSourceTimestamp
        return .accepted(
            .mutation(
                revision: revision,
                change: .reset(baseRevision: baseRevision, baselines: baselines)
            )
        )
    }

    package var currentLevels: SignalChannelLevels {
        capture.transitions.reduce(capture.baselineLevels) { levels, transition in
            levels.replacingLevel(transition.level, for: transition.channelID)
        }
    }
}

private extension SignalChannelLevels {
    func replacingLevel(_ level: DigitalLevel, for channelID: SignalChannelID) -> Self {
        switch channelID.rawValue {
        case 1: SignalChannelLevels(ch1: level, ch2: ch2, ch3: ch3, ch4: ch4)
        case 2: SignalChannelLevels(ch1: ch1, ch2: level, ch3: ch3, ch4: ch4)
        case 3: SignalChannelLevels(ch1: ch1, ch2: ch2, ch3: level, ch4: ch4)
        case 4: SignalChannelLevels(ch1: ch1, ch2: ch2, ch3: ch3, ch4: level)
        default: self
        }
    }
}
