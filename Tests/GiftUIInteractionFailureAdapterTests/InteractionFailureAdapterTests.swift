import GiftUIExecution
import GiftUIFailureCore
import Testing

@testable import GiftUIInteraction
@testable import GiftUIInteractionFailureAdapterFixture

private let interactionFailureContext = ExecutionContext(
    cycle: RunCycleID(rawValue: 41),
    semanticRevision: SemanticRevision(rawValue: 43),
    candidateFrame: CandidateFrameID(rawValue: 47),
    phase: .deriving
)

@Test
func everyInteractionErrorMapsExactlyAfterMandatoryEffects() {
    let rows:
        [(
            InteractionError,
            InteractionFailureDetector,
            GiftUIConditionID,
            GiftUIFailureOrigin,
            GiftUIAffectedScope,
            GiftUIContainment
        )] = [
            (
                .capacityExhausted, .interaction, .capacityExhausted, .interaction, .candidateFrame,
                .contained
            ),
            (
                .invalidIdentity, .interaction, .invalidIdentity, .interaction, .candidateFrame,
                .contained
            ),
            (
                .invalidGeometry, .interaction, .invalidValue, .interaction, .candidateFrame,
                .contained
            ),
            (
                .incompatibleActionDomain, .coordinator, .invalidValue, .interaction,
                .candidateFrame, .contained
            ),
            (
                .invalidActionValue, .coordinator, .invalidValue, .interaction, .candidateFrame,
                .contained
            ),
            (
                .missingModelTarget, .coordinator, .invalidIdentity, .observableState,
                .candidateFrame, .contained
            ),
            (
                .invalidPhase, .interaction, .invalidPhase, .interaction, .activeCycle,
                .safetyNotProven
            ),
            (
                .reentrancyViolation, .interaction, .reentrancyViolation, .interaction,
                .activeCycle, .safetyNotProven
            ),
            (
                .invariantViolation, .interaction, .invariantViolation, .interaction, .runtime,
                .safetyNotProven
            ),
        ]

    for (error, detector, condition, origin, scope, containment) in rows {
        let mapped = InteractionFailureAdapter.map(
            error,
            detectedBy: detector,
            context: interactionFailureContext,
            mandatoryEffectsComplete: true
        )
        #expect(mapped?.localError == error)
        #expect(mapped?.detector == detector)
        #expect(mapped?.failure.context == interactionFailureContext)
        #expect(mapped?.failure.fact.condition == condition)
        #expect(mapped?.failure.fact.origin == origin)
        #expect(mapped?.failure.fact.affectedScope == scope)
        #expect(mapped?.failure.fact.containment == containment)
        #expect(mapped?.failure.annotations == GiftUIFailureAnnotations())
    }
}

@Test
func mappingRejectsIncompleteEffectsAndWrongDetectorOwnership() {
    let rows: [(InteractionError, InteractionFailureDetector)] = [
        (.capacityExhausted, .interaction),
        (.invalidIdentity, .interaction),
        (.invalidGeometry, .interaction),
        (.invalidPhase, .interaction),
        (.reentrancyViolation, .interaction),
        (.invariantViolation, .interaction),
        (.incompatibleActionDomain, .coordinator),
        (.invalidActionValue, .coordinator),
        (.missingModelTarget, .coordinator),
    ]

    for (error, detector) in rows {
        #expect(
            InteractionFailureAdapter.map(
                error,
                detectedBy: detector,
                context: interactionFailureContext,
                mandatoryEffectsComplete: false
            ) == nil
        )
        let wrongDetector: InteractionFailureDetector =
            detector == .interaction ? .coordinator : .interaction
        #expect(
            InteractionFailureAdapter.map(
                error,
                detectedBy: wrongDetector,
                context: interactionFailureContext,
                mandatoryEffectsComplete: true
            ) == nil
        )
    }
}
