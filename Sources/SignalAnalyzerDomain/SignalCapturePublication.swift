package enum SignalAnalyzerRepositoryCondition: UInt8, Equatable, Sendable {
    case captureRevisionExhausted
}

package enum SignalCapturePublication: Equatable, Sendable {
    case snapshot(revision: UInt32, capture: SignalCapture)
    case mutation(revision: UInt32, change: SignalCaptureChange)
    case terminalFailure(
        condition: SignalAnalyzerRepositoryCondition,
        diagnostic: SignalAnalyzerDiagnostic
    )
}

package enum SignalSinkDeliveryRejection: UInt8, Equatable, Sendable {
    case snapshotCapacityExhausted
    case factCapacityExhausted
    case runtimeUnavailable
    case sequenceExhausted
}

package enum SignalSinkDeliveryOutcome: Equatable, Sendable {
    case accepted(sequence: UInt32)
    case rejected(SignalSinkDeliveryRejection)
}

package struct SignalCaptureRevisionState: Equatable, Sendable {
    package let revision: UInt32
    package let capture: SignalCapture

    package init(revision: UInt32, capture: SignalCapture) {
        self.revision = revision
        self.capture = capture
    }

    package static let initial = SignalCaptureRevisionState(
        revision: 0,
        capture: .empty()
    )
}

package enum SignalCaptureReplayResult: Equatable, Sendable {
    case applied(SignalCaptureRevisionState)
    case terminalFailure(
        condition: SignalAnalyzerRepositoryCondition,
        diagnostic: SignalAnalyzerDiagnostic
    )
    case rejected
}

package extension SignalCapturePublication {
    func replay(on preceding: SignalCaptureRevisionState) -> SignalCaptureReplayResult {
        switch self {
        case .snapshot(let revision, let capture):
            guard revision != 0 || capture == .empty() else {
                return .rejected
            }
            return .applied(SignalCaptureRevisionState(revision: revision, capture: capture))

        case .mutation(let revision, let change):
            guard let expectedRevision = preceding.revision.nonwrappingSuccessor,
                revision == expectedRevision,
                change.baseRevision == preceding.revision,
                let capture = change.applying(to: preceding.capture)
            else {
                return .rejected
            }
            return .applied(SignalCaptureRevisionState(revision: revision, capture: capture))

        case .terminalFailure(let condition, let diagnostic):
            return .terminalFailure(condition: condition, diagnostic: diagnostic)
        }
    }
}

private extension SignalCaptureChange {
    var baseRevision: UInt32 {
        switch self {
        case .insertAndTrim(let baseRevision, _, _, _, _, _, _):
            baseRevision
        case .reset(let baseRevision, _):
            baseRevision
        }
    }

    func applying(to capture: SignalCapture) -> SignalCapture? {
        switch self {
        case .insertAndTrim(
            _,
            let
                insertionIndex,
            let
                transition,
            let
                evictedPrefixCount,
            let
                duration,
            let
                retainedLowerBound,
            let
                baselines
        ):
            var transitions = Array(capture.transitions)
            let insertion = Int(insertionIndex)
            guard insertion <= transitions.count,
                insertion <= SignalCapture.maximumTransitionCount
            else {
                return nil
            }

            transitions.insert(transition, at: insertion)
            let eviction = Int(evictedPrefixCount)
            guard eviction <= transitions.count,
                eviction <= SignalCapture.maximumTransitionCount
            else {
                return nil
            }
            transitions.removeFirst(eviction)

            return SignalCapture(
                transitions: transitions,
                duration: duration,
                retainedLowerBound: retainedLowerBound,
                baselineLevels: baselines
            )

        case .reset(_, let baselines):
            return SignalCapture(
                transitions: [SignalTransition](),
                duration: .zero,
                retainedLowerBound: .zero,
                baselineLevels: baselines
            )
        }
    }
}

private extension UInt32 {
    var nonwrappingSuccessor: UInt32? {
        guard self < .max else { return nil }
        return self + 1
    }
}
