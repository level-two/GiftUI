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
        #expect(fixture.owner.policyCallCount == 1)
        #expect(fixture.owner.lastPolicyContext == .activeDelivery)
        #expect(fixture.owner.lastAllowedDispositions == [.quiesceAffectedScope])
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
        #expect(fixture.owner.policyCallCount == 0)
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
        #expect(phase.owner.policyCallCount == 0)
    }

    @Test("every unsafe runtime condition records exact effects and one policy selection")
    func exhaustiveUnsafeRuntimeRows() {
        let rows:
            [(
                SignalAnalyzerRuntimeCondition, SignalAnalyzerResidualPolicyContext, Bool,
                [SignalAnalyzerMandatoryEffect], GiftUIResidualDisposition
            )] = [
                (
                    .stateLocationCapacityExhausted, .initialModelAttachment, false,
                    [.removePartialCandidate, .quiesceAffectedScope], .quiesceAffectedScope
                ),
                (
                    .registrationCapacityExhausted, .initialModelAttachment, false,
                    [.removePartialCandidate, .quiesceAffectedScope], .quiesceAffectedScope
                ),
                (
                    .replacementStagingExhausted, .modelReplacement, true,
                    [.removePartialCandidate, .preserveExistingModel], .continueOperation
                ),
                (
                    .duplicateModelOwner, .modelReplacement, true,
                    [.removePartialCandidate, .preserveExistingModel], .continueOperation
                ),
                (
                    .incompatibleStateAssociation, .modelReplacement, true,
                    [.removePartialCandidate, .preserveExistingModel], .continueOperation
                ),
                (
                    .staleRegistrationReport, .modelChangeReport, true,
                    [.preserveLastCompleteRevision], .continueOperation
                ),
                (
                    .identityGenerationExhausted, .modelReplacement, true,
                    [
                        .preserveLastCompleteRevision, .preventNormalCycle, .requireFreshGraph,
                        .quiesceAffectedScope,
                    ], .quiesceAffectedScope
                ),
                (
                    .captureRevisionMismatch, .captureFactApplication, true,
                    [
                        .preserveLastCompleteRevision, .markPresentationFailed, .detachObservation,
                        .requireFreshGraph, .quiesceAffectedScope,
                    ], .quiesceAffectedScope
                ),
                (
                    .reservedFailureCapacityExhausted, .activeDelivery, true,
                    [
                        .preserveLastCompleteRevision, .preventNormalCycle, .requireFreshGraph,
                        .quiesceAffectedScope,
                    ], .quiesceAffectedScope
                ),
                (
                    .mutationPhaseViolation, .modelChangeReport, true,
                    [
                        .discardPartialPublication, .quiesceRuntimeHealth, .preventNormalCycle,
                        .quiesceAffectedScope,
                    ], .quiesceAffectedScope
                ),
                (
                    .observableStateReentrancyViolation, .modelChangeReport, true,
                    [
                        .discardPartialPublication, .quiesceRuntimeHealth, .preventNormalCycle,
                        .quiesceAffectedScope,
                    ], .quiesceAffectedScope
                ),
                (
                    .observableStateInvariantViolation, .modelChangeReport, true,
                    [
                        .discardPartialPublication, .quiesceRuntimeHealth, .preventNormalCycle,
                        .quiesceAffectedScope,
                    ], .quiesceAffectedScope
                ),
            ]

        for (condition, context, existing, effects, disposition) in rows {
            let fixture = makeOwner()
            _ = fixture.owner.handleRuntimeFailure(
                condition,
                context: context,
                stableStateProven: false,
                existingLiveModel: existing,
                diagnostic: ownerDiagnostic("matrix")
            )
            #expect(fixture.effects.values == effects)
            #expect(fixture.owner.policyCallCount == 1)
            #expect(fixture.owner.lastPolicyContext == context)
            #expect(fixture.owner.lastDisposition == disposition)
        }
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
