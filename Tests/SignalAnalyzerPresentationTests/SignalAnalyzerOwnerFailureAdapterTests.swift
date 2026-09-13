import GiftUIFailureCore
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

@Suite("Signal Analyzer owner failure adapter")
struct SignalAnalyzerOwnerFailureAdapterTests {
    @Test("active admission effects precede selected residual disposition")
    func activeAdmission() {
        let fixture = makeOwner()
        let failure = fixture.owner.failure(for: .factCapacityExhausted, context: .activeDelivery)

        fixture.owner.completeAdmissionFailure(
            failure,
            rejection: .factCapacityExhausted,
            context: .activeDelivery,
            reservedOutcome: .accepted(sequence: 2)
        )

        #expect(
            fixture.effects.values == [
                .rejectWithoutOverwrite,
                .reservedFailureAttempted,
                .stopAcquisitionDelivery,
                .quiesceAffectedScope,
            ])
        #expect(fixture.repository.stopCount == 1)
        #expect(fixture.owner.lastDisposition == .quiesceAffectedScope)
    }

    @Test("reserved failure rejection escalates without recursive admission")
    func reservedFailureRejection() {
        let fixture = makeOwner()
        let failure = fixture.owner.failure(for: .factCapacityExhausted, context: .activeDelivery)

        fixture.owner.completeAdmissionFailure(
            failure,
            rejection: .factCapacityExhausted,
            context: .activeDelivery,
            reservedOutcome: .rejected(.factCapacityExhausted)
        )

        #expect(fixture.repository.stopCount == 1)
        #expect(fixture.owner.lastDisposition == .quiesceAffectedScope)
        #expect(
            fixture.effects.values == [
                .rejectWithoutOverwrite,
                .reservedFailureAttempted,
                .stopAcquisitionDelivery,
                .preserveLastCompleteRevision,
                .preventNormalCycle,
                .requireFreshGraph,
                .quiesceAffectedScope,
            ])
    }

    @Test("terminal repository failure has mandatory effects and no policy")
    func repositoryTerminal() {
        let fixture = makeOwner()
        let failure = fixture.owner.failure(
            for: .captureRevisionExhausted,
            diagnostic: ownerDiagnostic("terminal")
        )

        fixture.owner.completeRepositoryFailure(
            failure,
            condition: .captureRevisionExhausted,
            reservedOutcome: .accepted(sequence: 3)
        )

        #expect(fixture.repository.stopCount == 1)
        #expect(fixture.owner.lastDisposition == nil)
        #expect(
            fixture.effects.values == [
                .rejectWithoutOverwrite,
                .stopAcquisitionDelivery,
                .reservedFailureAttempted,
                .detachObservation,
                .quiesceAffectedScope,
                .requireFreshGraph,
            ])
    }

    @Test("runtime rows select exact policy or coordinator-owned retry")
    func runtimeRows() {
        let initial = makeOwner()
        _ = initial.owner.handleRuntimeFailure(
            .stateLocationCapacityExhausted,
            context: .initialModelAttachment,
            stableStateProven: true,
            existingLiveModel: false,
            diagnostic: ownerDiagnostic("initial")
        )
        #expect(initial.owner.lastDisposition == .quiesceAffectedScope)

        let replacement = makeOwner()
        _ = replacement.owner.handleRuntimeFailure(
            .replacementStagingExhausted,
            context: .modelReplacement,
            stableStateProven: true,
            existingLiveModel: true,
            diagnostic: ownerDiagnostic("replacement")
        )
        #expect(replacement.owner.lastDisposition == .continueOperation)
        #expect(replacement.effects.values == [.removePartialCandidate, .preserveExistingModel])

        let stale = makeOwner()
        _ = stale.owner.handleRuntimeFailure(
            .staleRegistrationReport,
            context: .modelChangeReport,
            stableStateProven: true,
            existingLiveModel: true,
            diagnostic: ownerDiagnostic("stale")
        )
        #expect(stale.owner.lastDisposition == .continueOperation)

        let phase = makeOwner()
        _ = phase.owner.handleRuntimeFailure(
            .mutationPhaseViolation,
            context: .modelChangeReport,
            stableStateProven: true,
            existingLiveModel: true,
            diagnostic: ownerDiagnostic("phase")
        )
        #expect(phase.owner.lastDisposition == nil)
        #expect(phase.effects.values == [.preserveLastCompleteRevision, .schedulePacedRetry])
    }
}

private final class OwnerEffects: SignalAnalyzerMandatoryEffectSink {
    var values: [SignalAnalyzerMandatoryEffect] = []
    func apply(_ effect: SignalAnalyzerMandatoryEffect) { values.append(effect) }
}

private final class OwnerRepository: SignalAcquisitionRepository {
    var stopCount = 0
    func startObservingCapture(sink: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws {}
    func stop() { stopCount += 1 }
    func clear() {}
}

private func makeOwner() -> (
    owner: SignalAnalyzerOwnerFailureAdapter<OwnerEffects>,
    effects: OwnerEffects,
    repository: OwnerRepository
) {
    let effects = OwnerEffects()
    let repository = OwnerRepository()
    return (
        SignalAnalyzerOwnerFailureAdapter(
            effects: effects,
            stopAcquisition: StopSignalAcquisitionUseCase(repository: repository)
        ),
        effects,
        repository
    )
}

private func ownerDiagnostic(_ text: String) -> SignalAnalyzerDiagnostic {
    SignalAnalyzerDiagnostic(exactUTF8: Array(text.utf8))!
}
