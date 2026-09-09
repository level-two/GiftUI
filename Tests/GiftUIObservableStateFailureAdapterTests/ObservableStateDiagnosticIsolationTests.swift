import Testing

@testable import GiftUIFailureCore
@testable import GiftUIFailureDiagnostics
@testable import GiftUIObservableState
@testable import GiftUIObservableStateFailureAdapterFixture

private enum ObservableDiagnosticConfiguration: CaseIterable, Equatable {
    case absent
    case enabled
    case disabled
    case lost
    case saturated
}

private struct ObservableStateCorrectnessSnapshot: Equatable {
    let result: ObservableStateResult
    let liveSet: UInt16
    let attachmentGeneration: UInt32
    let dirtyLocations: UInt16
    let semanticWakePending: Bool
    let publicationGeneration: UInt32
    let mappedFailure: CorrelatedObservableStateFailure
}

private final class ObservableStateDiagnosticAuthority {
    private(set) var snapshot: ObservableStateCorrectnessSnapshot
    private(set) var rejectedMutationCount: UInt8 = 0
    private var diagnosticsActive = false

    init(snapshot: ObservableStateCorrectnessSnapshot) {
        self.snapshot = snapshot
    }

    func enterDiagnostics() {
        diagnosticsActive = true
    }

    func attemptAuthoritativeMutation() {
        guard !diagnosticsActive else {
            rejectedMutationCount += 1
            return
        }
        snapshot = observableStateCorrectnessSnapshot()
    }
}

private final class ObservableDiagnosticConstructionCounter {
    var value: UInt8 = 0
}

private struct ObservableDiagnosticSink: GiftUIDiagnosticSink {
    let result: GiftUIDiagnosticSinkResult
    let authority: ObservableStateDiagnosticAuthority
    private(set) var consumed: UInt8 = 0

    mutating func consume(_ record: GiftUIDiagnosticRecord) -> GiftUIDiagnosticSinkResult {
        _ = record
        consumed += 1
        authority.attemptAuthoritativeMutation()
        return result
    }
}

@Test
func diagnosticProjectionStatesPreserveCompleteObservableCorrectness() {
    let baseline = observableStateCorrectnessSnapshot()

    for configuration in ObservableDiagnosticConfiguration.allCases {
        let authority = ObservableStateDiagnosticAuthority(snapshot: baseline)
        let construction = ObservableDiagnosticConstructionCounter()

        if configuration == .absent {
            #expect(authority.snapshot == baseline)
            #expect(construction.value == 0)
            continue
        }

        authority.enterDiagnostics()
        let selected = configuration != .disabled
        let result: GiftUIDiagnosticSinkResult =
            switch configuration {
            case .lost: .dropped
            case .saturated: .saturated
            default: .accepted
            }
        var projector = GiftUIDiagnosticProjector(
            selection: observableDiagnosticSelection(enabled: selected),
            sink: ObservableDiagnosticSink(result: result, authority: authority)
        )

        projector.projectObservableFailure(
            baseline.mappedFailure,
            construction: construction
        )

        #expect(authority.snapshot == baseline)
        #expect(observableStateCorrectnessSnapshot() == baseline)
        if selected {
            #expect(construction.value == 1)
            #expect(projector.sink.consumed == 1)
            #expect(projector.counters.count(for: result) == 1)
            #expect(authority.rejectedMutationCount == 1)
        } else {
            #expect(construction.value == 0)
            #expect(projector.sink.consumed == 0)
            #expect(projector.counters == .init())
            #expect(authority.rejectedMutationCount == 0)
        }
    }
}

private func observableStateCorrectnessSnapshot() -> ObservableStateCorrectnessSnapshot {
    let mappedFailure = GiftUIObservableStateFailureAdapter.map(
        .incompatibleAssociation,
        detectedAt: .replacement,
        mandatoryEffectsComplete: true
    )!
    return ObservableStateCorrectnessSnapshot(
        result: .failure(.incompatibleAssociation),
        liveSet: 0b0000_0011,
        attachmentGeneration: 89,
        dirtyLocations: 0b0000_0010,
        semanticWakePending: true,
        publicationGeneration: 55,
        mappedFailure: mappedFailure
    )
}

private func observableDiagnosticSelection(enabled: Bool) -> GiftUIDiagnosticSelection {
    GiftUIDiagnosticSelection(
        kindMask: enabled ? 1 << GiftUIDiagnosticKind.failureOutcome.rawValue : 0,
        originMask: 1 << GiftUIFailureOrigin.observableState.rawValue,
        minimumSeverity: .error
    )
}

extension GiftUIDiagnosticProjector {
    fileprivate mutating func projectObservableFailure(
        _ failure: CorrelatedObservableStateFailure,
        construction: ObservableDiagnosticConstructionCounter
    ) {
        project(kind: .failureOutcome, origin: .observableState, severity: .error) {
            construction.value += 1
            return GiftUIDiagnosticRecord(
                kind: .failureOutcome,
                severity: .error,
                flags: 0,
                origin: .observableState,
                affectedScope: failure.fact.affectedScope,
                condition: failure.fact.condition.rawValue,
                correlation0: UInt32(failure.localError.rawValue),
                correlation1: UInt32(failure.detectionContext.rawValue),
                observation0: UInt32(failure.fact.containment.rawValue)
            )
        }
    }
}

extension GiftUIDiagnosticDeliveryCounters {
    fileprivate func count(for result: GiftUIDiagnosticSinkResult) -> UInt32 {
        switch result {
        case .accepted: accepted
        case .dropped: dropped
        case .saturated: saturated
        case .failed: failed
        }
    }
}
