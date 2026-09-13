import SignalAnalyzerDomain
import Testing

@Suite("Signal Analyzer capture publication values")
struct SignalCapturePublicationTests {
    @Test("revision zero accepts only the initial empty snapshot")
    func revisionZeroSnapshot() {
        let initial = SignalCaptureRevisionState.initial
        #expect(
            SignalCapturePublication.snapshot(revision: 0, capture: .empty())
                .replay(on: initial) == .applied(initial)
        )

        let nonempty = capture([transition(1)], duration: 1)
        #expect(
            SignalCapturePublication.snapshot(revision: 0, capture: nonempty)
                .replay(on: initial) == .rejected
        )
    }

    @Test("insert happens before prefix trimming")
    func insertionBeforeTrimming() {
        let preceding = SignalCaptureRevisionState(
            revision: 7,
            capture: capture([transition(10), transition(20)], duration: 20)
        )
        let publication = SignalCapturePublication.mutation(
            revision: 8,
            change: .insertAndTrim(
                baseRevision: 7,
                insertionIndex: 0,
                transition: transition(5),
                evictedPrefixCount: 1,
                duration: .microseconds(20),
                retainedLowerBound: .microseconds(10),
                baselines: .allLow
            )
        )

        let expected = SignalCaptureRevisionState(
            revision: 8,
            capture: SignalCapture(
                transitions: [transition(10), transition(20)],
                duration: .microseconds(20),
                retainedLowerBound: .microseconds(10)
            )!
        )
        #expect(publication.replay(on: preceding) == .applied(expected))
    }

    @Test("reset clears epoch and history while using supplied baselines")
    func reset() {
        let preceding = SignalCaptureRevisionState(
            revision: 2,
            capture: capture([transition(1)], duration: 1)
        )
        let baselines = SignalChannelLevels(ch1: .high, ch2: .low, ch3: .high, ch4: .low)
        let publication = SignalCapturePublication.mutation(
            revision: 3,
            change: .reset(baseRevision: 2, baselines: baselines)
        )
        let expectedCapture = SignalCapture(
            transitions: [SignalTransition](),
            duration: .zero,
            baselineLevels: baselines
        )!

        #expect(
            publication.replay(on: preceding)
                == .applied(
                    SignalCaptureRevisionState(revision: 3, capture: expectedCapture)
                )
        )
    }

    @Test("revision mismatch and revision exhaustion fail closed")
    func revisionValidation() {
        let initial = SignalCaptureRevisionState.initial
        let wrongBase = SignalCapturePublication.mutation(
            revision: 1,
            change: .reset(baseRevision: 1, baselines: .allLow)
        )
        let skippedTarget = SignalCapturePublication.mutation(
            revision: 2,
            change: .reset(baseRevision: 0, baselines: .allLow)
        )
        let exhausted = SignalCaptureRevisionState(revision: .max, capture: .empty())
        let wrapped = SignalCapturePublication.mutation(
            revision: 0,
            change: .reset(baseRevision: .max, baselines: .allLow)
        )

        #expect(wrongBase.replay(on: initial) == .rejected)
        #expect(skippedTarget.replay(on: initial) == .rejected)
        #expect(wrapped.replay(on: exhausted) == .rejected)
    }

    @Test("mutation bounds reject malformed descriptions without changing input")
    func mutationBounds() {
        let preceding = SignalCaptureRevisionState.initial
        let badInsertion = SignalCapturePublication.mutation(
            revision: 1,
            change: .insertAndTrim(
                baseRevision: 0,
                insertionIndex: 1,
                transition: transition(0),
                evictedPrefixCount: 0,
                duration: .zero,
                retainedLowerBound: .zero,
                baselines: .allLow
            )
        )
        let badEviction = SignalCapturePublication.mutation(
            revision: 1,
            change: .insertAndTrim(
                baseRevision: 0,
                insertionIndex: 0,
                transition: transition(0),
                evictedPrefixCount: 2,
                duration: .zero,
                retainedLowerBound: .zero,
                baselines: .allLow
            )
        )

        #expect(badInsertion.replay(on: preceding) == .rejected)
        #expect(badEviction.replay(on: preceding) == .rejected)
        #expect(preceding == .initial)
    }

    @Test("capacity pressure may evict the newly inserted transition")
    func maximumCapacityInsertAndTrim() {
        let transitions = (0 ..< SignalCapture.maximumTransitionCount).map { transition($0) }
        let preceding = SignalCaptureRevisionState(
            revision: 40,
            capture: capture(
                transitions,
                duration: SignalCapture.maximumTransitionCount
            )
        )
        let accepted = SignalCapturePublication.mutation(
            revision: 41,
            change: .insertAndTrim(
                baseRevision: 40,
                insertionIndex: 0,
                transition: transition(0),
                evictedPrefixCount: 1,
                duration: .microseconds(SignalCapture.maximumTransitionCount),
                retainedLowerBound: .zero,
                baselines: .allLow
            )
        )
        let rejected = SignalCapturePublication.mutation(
            revision: 41,
            change: .insertAndTrim(
                baseRevision: 40,
                insertionIndex: 2_404,
                transition: transition(SignalCapture.maximumTransitionCount),
                evictedPrefixCount: 0,
                duration: .microseconds(SignalCapture.maximumTransitionCount),
                retainedLowerBound: .zero,
                baselines: .allLow
            )
        )

        #expect(
            accepted.replay(on: preceding)
                == .applied(
                    SignalCaptureRevisionState(revision: 41, capture: preceding.capture)
                )
        )
        #expect(rejected.replay(on: preceding) == .rejected)
    }

    @Test("terminal failure remains structural and carries no revision")
    func terminalFailure() {
        let diagnostic = SignalAnalyzerDiagnostic(exactUTF8: Array("revision exhausted".utf8))!
        let publication = SignalCapturePublication.terminalFailure(
            condition: .captureRevisionExhausted,
            diagnostic: diagnostic
        )

        #expect(
            publication.replay(on: .initial)
                == .terminalFailure(
                    condition: .captureRevisionExhausted,
                    diagnostic: diagnostic
                )
        )
    }

    @Test("delivery outcomes preserve every exact rejection category")
    func deliveryOutcomes() {
        #expect(SignalSinkDeliveryOutcome.accepted(sequence: 1) != .accepted(sequence: 2))
        #expect(
            Set([
                SignalSinkDeliveryRejection.snapshotCapacityExhausted.rawValue,
                SignalSinkDeliveryRejection.factCapacityExhausted.rawValue,
                SignalSinkDeliveryRejection.runtimeUnavailable.rawValue,
                SignalSinkDeliveryRejection.sequenceExhausted.rawValue,
            ]).count == 4
        )
    }
}

private func capture(
    _ transitions: [SignalTransition],
    duration: Int
) -> SignalCapture {
    SignalCapture(
        transitions: transitions,
        duration: .microseconds(duration)
    )!
}

private func transition(_ timestamp: Int) -> SignalTransition {
    SignalTransition(
        channelID: SignalChannelID(rawValue: 1),
        timestamp: .microseconds(timestamp),
        level: timestamp.isMultiple(of: 2) ? .low : .high
    )
}
