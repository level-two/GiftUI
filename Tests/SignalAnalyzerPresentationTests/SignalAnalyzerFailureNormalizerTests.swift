import GiftUIFailureCore
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

@Suite("Signal Analyzer failure normalization")
struct SignalAnalyzerFailureNormalizerTests {
    @Test("repository and admission conditions map exactly")
    func producerMappings() {
        let diagnostic = analyzerDiagnostic("producer")
        assertFact(
            SignalAnalyzerFailureNormalizer.operationalFailure(
                for: .captureRevisionExhausted,
                diagnostic: diagnostic
            ).failure,
            .invalidProvenance, .semantic, .component, .safetyNotProven
        )

        let cases:
            [(
                SignalSinkDeliveryRejection, GiftUIConditionID, GiftUIFailureOrigin,
                GiftUIAffectedScope, GiftUIContainment
            )] = [
                (
                    .snapshotCapacityExhausted, .capacityExhausted, .presentationIntegration,
                    .component, .contained
                ),
                (
                    .factCapacityExhausted, .capacityExhausted, .presentationIntegration,
                    .component, .contained
                ),
                (
                    .runtimeUnavailable, .requiredFacilityUnavailable, .execution, .runtime,
                    .safetyNotProven
                ),
                (
                    .sequenceExhausted, .invalidProvenance, .presentationIntegration, .runtime,
                    .safetyNotProven
                ),
            ]
        for (condition, identity, origin, scope, containment) in cases {
            let normalized = SignalAnalyzerFailureNormalizer.operationalFailure(
                for: condition,
                diagnostic: diagnostic
            )
            assertFact(normalized.failure, identity, origin, scope, containment)
            #expect(normalized.diagnostic == diagnostic)
        }
    }

    @Test("all runtime conditions map exactly")
    func runtimeMappings() {
        let d = analyzerDiagnostic("runtime")
        let cases:
            [(
                SignalAnalyzerRuntimeCondition, GiftUIConditionID, GiftUIFailureOrigin,
                GiftUIAffectedScope, GiftUIContainment
            )] = [
                (
                    .stateLocationCapacityExhausted, .capacityExhausted, .observableState,
                    .component, .contained
                ),
                (
                    .registrationCapacityExhausted, .capacityExhausted, .observableState,
                    .component, .contained
                ),
                (
                    .replacementStagingExhausted, .capacityExhausted, .observableState, .operation,
                    .contained
                ),
                (.duplicateModelOwner, .invalidIdentity, .observableState, .component, .contained),
                (
                    .incompatibleStateAssociation, .invalidIdentity, .observableState, .component,
                    .contained
                ),
                (
                    .staleRegistrationReport, .invalidIdentity, .observableState, .operation,
                    .contained
                ),
                (
                    .identityGenerationExhausted, .invalidIdentity, .observableState, .runtime,
                    .safetyNotProven
                ),
                (
                    .captureRevisionMismatch, .invalidProvenance, .presentationIntegration,
                    .component, .contained
                ),
                (
                    .reservedFailureCapacityExhausted, .capacityExhausted, .presentationIntegration,
                    .runtime, .safetyNotProven
                ),
                (
                    .mutationPhaseViolation, .invalidPhase, .observableState, .activeCycle,
                    .safetyNotProven
                ),
                (
                    .observableStateReentrancyViolation, .reentrancyViolation, .observableState,
                    .activeCycle, .safetyNotProven
                ),
                (
                    .observableStateInvariantViolation, .invariantViolation, .observableState,
                    .runtime, .safetyNotProven
                ),
            ]
        for (condition, identity, origin, scope, containment) in cases {
            let normalized = SignalAnalyzerFailureNormalizer.operationalFailure(
                for: condition,
                stableStateProven: false,
                diagnostic: d
            )
            assertFact(normalized.failure, identity, origin, scope, containment)
        }
        let contained = SignalAnalyzerFailureNormalizer.operationalFailure(
            for: .mutationPhaseViolation,
            stableStateProven: true,
            diagnostic: d
        )
        assertFact(contained.failure, .invalidPhase, .observableState, .activeCycle, .contained)
    }

    @Test("diagnostics cannot alter normalized facts")
    func diagnosticIndependence() {
        let first = SignalAnalyzerFailureNormalizer.operationalFailure(
            for: .runtimeUnavailable,
            diagnostic: analyzerDiagnostic("first")
        )
        let second = SignalAnalyzerFailureNormalizer.operationalFailure(
            for: .runtimeUnavailable,
            diagnostic: analyzerDiagnostic("second")
        )
        #expect(first.failure == second.failure)
        #expect(first.diagnostic != second.diagnostic)
    }
}

private func assertFact(
    _ fact: GiftUIFailureFact,
    _ condition: GiftUIConditionID,
    _ origin: GiftUIFailureOrigin,
    _ scope: GiftUIAffectedScope,
    _ containment: GiftUIContainment
) {
    #expect(fact.condition == condition)
    #expect(fact.origin == origin)
    #expect(fact.affectedScope == scope)
    #expect(fact.containment == containment)
}

private func analyzerDiagnostic(_ text: String) -> SignalAnalyzerDiagnostic {
    SignalAnalyzerDiagnostic(exactUTF8: Array(text.utf8))!
}
