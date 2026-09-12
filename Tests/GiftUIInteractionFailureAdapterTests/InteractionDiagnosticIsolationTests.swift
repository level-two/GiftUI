import GiftUIExecution
import GiftUIFailureCore
import Testing

@testable import GiftUIFailureDiagnostics
@testable import GiftUIInteraction
@testable import GiftUIInteractionFailureAdapterFixture

private struct InteractionCorrectnessSnapshot: Equatable {
    let mappedFailure: CorrelatedInteractionFailure<ExecutionContext>
    let effectState: InteractionFailureEffectState
    let allowedDispositions: GiftUIAllowedDispositions
    let handlerInvocationCount: UInt8
    let fallbackCount: UInt8
    let retargetCount: UInt8
    let partialPublicationCount: UInt8
    let aliasCount: UInt8
}

private final class InteractionDiagnosticAuthority {
    private(set) var snapshot: InteractionCorrectnessSnapshot
    private(set) var rejectedMutationCount: UInt8 = 0
    private var diagnosticsActive = false

    init(snapshot: InteractionCorrectnessSnapshot) {
        self.snapshot = snapshot
    }

    func enterDiagnostics() {
        diagnosticsActive = true
    }

    func attemptFallbackRetargetPublicationAndAlias() {
        guard !diagnosticsActive else {
            rejectedMutationCount += 4
            return
        }
        snapshot = interactionCorrectnessSnapshot()
    }
}

private final class InteractionDiagnosticConstructionCounter {
    var value: UInt8 = 0
}

private struct InteractionDiagnosticSink: GiftUIDiagnosticSink {
    let result: GiftUIDiagnosticSinkResult
    let authority: InteractionDiagnosticAuthority
    private(set) var consumed: UInt8 = 0

    mutating func consume(_ record: GiftUIDiagnosticRecord) -> GiftUIDiagnosticSinkResult {
        _ = record
        consumed += 1
        authority.attemptFallbackRetargetPublicationAndAlias()
        return result
    }
}

@Test
func diagnosticConfigurationsPreserveCompleteInteractionCorrectness() {
    let baseline = interactionCorrectnessSnapshot()
    let configurations: [(String, GiftUIDiagnosticSinkResult?)] = [
        ("omitted", nil),
        ("selected", .accepted),
        ("dropped", .dropped),
        ("saturated", .saturated),
        ("failing", .failed),
    ]

    for (name, sinkResult) in configurations {
        let authority = InteractionDiagnosticAuthority(snapshot: baseline)
        let construction = InteractionDiagnosticConstructionCounter()
        authority.enterDiagnostics()

        guard let sinkResult else {
            #expect(construction.value == 0, "configuration: \(name)")
            #expect(authority.snapshot == baseline)
            #expect(authority.rejectedMutationCount == 0)
            continue
        }

        var projector = GiftUIDiagnosticProjector(
            selection: interactionDiagnosticSelection(),
            sink: InteractionDiagnosticSink(result: sinkResult, authority: authority)
        )
        projector.projectInteractionFailure(
            baseline.mappedFailure,
            construction: construction
        )

        #expect(interactionCorrectnessSnapshot() == baseline, "configuration: \(name)")
        #expect(authority.snapshot == baseline)
        #expect(construction.value == 1)
        #expect(projector.sink.consumed == 1)
        #expect(projector.counters.count(for: sinkResult) == 1)
        #expect(authority.rejectedMutationCount == 4)
    }
}

private func interactionCorrectnessSnapshot() -> InteractionCorrectnessSnapshot {
    var effectState = InteractionFailureEffectState(committedStateToken: 0xA11CE)
    let effects = InteractionFailureContainment.apply(
        .invalidGeometry,
        mutationAlreadyOccurred: true,
        to: &effectState
    )
    let context = ExecutionContext(
        cycle: RunCycleID(rawValue: 53),
        semanticRevision: SemanticRevision(rawValue: 59),
        candidateFrame: CandidateFrameID(rawValue: 61),
        phase: .deriving
    )
    let mapped = InteractionFailureAdapter.map(
        .invalidGeometry,
        detectedBy: .interaction,
        context: context,
        mandatoryEffectsComplete: effects.mandatoryEffectsComplete
    )!
    return InteractionCorrectnessSnapshot(
        mappedFailure: mapped,
        effectState: effectState,
        allowedDispositions: effects.allowedDispositions,
        handlerInvocationCount: 0,
        fallbackCount: 0,
        retargetCount: 0,
        partialPublicationCount: 0,
        aliasCount: 0
    )
}

private func interactionDiagnosticSelection() -> GiftUIDiagnosticSelection {
    GiftUIDiagnosticSelection(
        kindMask: 1 << GiftUIDiagnosticKind.failureOutcome.rawValue,
        originMask: 1 << GiftUIFailureOrigin.interaction.rawValue,
        minimumSeverity: .error
    )
}

extension GiftUIDiagnosticProjector {
    fileprivate mutating func projectInteractionFailure<Context>(
        _ failure: CorrelatedInteractionFailure<Context>,
        construction: InteractionDiagnosticConstructionCounter
    ) where Context: Equatable & Sendable {
        project(kind: .failureOutcome, origin: .interaction, severity: .error) {
            construction.value += 1
            return GiftUIDiagnosticRecord(
                kind: .failureOutcome,
                severity: .error,
                flags: 0,
                origin: failure.failure.fact.origin,
                affectedScope: failure.failure.fact.affectedScope,
                condition: failure.failure.fact.condition.rawValue,
                correlation0: UInt32(failure.localError.rawValue),
                correlation1: UInt32(failure.detector.rawValue),
                observation0: UInt32(failure.failure.fact.containment.rawValue)
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
