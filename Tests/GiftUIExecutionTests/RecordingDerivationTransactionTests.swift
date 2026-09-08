import Testing

@testable import GiftUIExecution

@Test
func mutationMembershipFreezesAndInvalidationsCoalesceByEpoch() {
    var transaction = RecordingDerivationTransaction()
    transaction.recordInvalidation()
    transaction.recordInvalidation()
    #expect(transaction.hasAdmittedInvalidation)
    #expect(!transaction.needsLaterSemanticWake)

    #expect(transaction.freezeMutationMembership() == nil)
    #expect(
        transaction.freezeMutationMembership() == .reentrancyViolation
    )
    transaction.recordInvalidation()
    transaction.recordInvalidation()
    #expect(transaction.hasAdmittedInvalidation)
    #expect(transaction.needsLaterSemanticWake)
}

@Test
func changedDerivationReservesActionsThenPublishesAtomically() {
    var transaction = RecordingDerivationTransaction()
    var semantics = SemanticRevisionAllocator()
    var actions = ActionGenerationAllocator()
    #expect(transaction.freezeMutationMembership() == nil)

    let outcome = transaction.finishDerivation(
        semanticChanged: true,
        hasPresentationObligation: false,
        stagedActionCount: 2,
        maximumCommittedActions: 2,
        semanticRevisions: &semantics,
        actionGenerations: &actions
    )
    guard case .published(let publication) = outcome else {
        Issue.record("changed derivation did not publish")
        return
    }
    #expect(publication.semanticRevision == SemanticRevision(rawValue: 0))
    #expect(publication.firstActionGeneration == ActionGeneration(rawValue: 0))
    #expect(publication.secondActionGeneration == ActionGeneration(rawValue: 1))
    #expect(transaction.publishedRevision == publication.semanticRevision)
    #expect(!transaction.hasAdmittedInvalidation)
    #expect(actions.reserve() == ActionGeneration(rawValue: 2))
    #expect(semantics.reserve() == SemanticRevision(rawValue: 1))
}

@Test
func everyPrepublicationReservationFailurePreservesPriorPublication() {
    let prior = SemanticRevision(rawValue: 9)

    var capacity = RecordingDerivationTransaction(publishedRevision: prior)
    var capacitySemantics = SemanticRevisionAllocator()
    var capacityActions = ActionGenerationAllocator()
    #expect(capacity.freezeMutationMembership() == nil)
    #expect(
        capacity.finishDerivation(
            semanticChanged: true,
            hasPresentationObligation: false,
            stagedActionCount: 3,
            maximumCommittedActions: 2,
            semanticRevisions: &capacitySemantics,
            actionGenerations: &capacityActions
        ) == .failure(.capacityExhausted)
    )
    #expect(capacity.publishedRevision == prior)
    #expect(capacityActions.reserve() == ActionGeneration(rawValue: 0))

    var actionFailure = RecordingDerivationTransaction(publishedRevision: prior)
    var actionSemantics = SemanticRevisionAllocator()
    var exhaustedActions = ActionGenerationAllocator(nextRawValue: nil)
    #expect(actionFailure.freezeMutationMembership() == nil)
    #expect(
        actionFailure.finishDerivation(
            semanticChanged: true,
            hasPresentationObligation: false,
            stagedActionCount: 1,
            maximumCommittedActions: 2,
            semanticRevisions: &actionSemantics,
            actionGenerations: &exhaustedActions
        ) == .failure(.identityExhausted)
    )
    #expect(actionFailure.publishedRevision == prior)
    #expect(actionSemantics.reserve() == SemanticRevision(rawValue: 0))

    var semanticFailure = RecordingDerivationTransaction(publishedRevision: prior)
    var exhaustedSemantics = SemanticRevisionAllocator(nextRawValue: nil)
    var semanticFailureActions = ActionGenerationAllocator()
    #expect(semanticFailure.freezeMutationMembership() == nil)
    #expect(
        semanticFailure.finishDerivation(
            semanticChanged: true,
            hasPresentationObligation: false,
            stagedActionCount: 1,
            maximumCommittedActions: 2,
            semanticRevisions: &exhaustedSemantics,
            actionGenerations: &semanticFailureActions
        ) == .failure(.identityExhausted)
    )
    #expect(semanticFailure.publishedRevision == prior)
    #expect(semanticFailureActions.reserve() == ActionGeneration(rawValue: 1))
}

@Test
func unchangedWithoutObligationAllocatesNoCandidateOrFrame() {
    var transaction = RecordingDerivationTransaction(
        publishedRevision: SemanticRevision(rawValue: 3)
    )
    var semantics = SemanticRevisionAllocator()
    var actions = ActionGenerationAllocator()
    var candidates = CandidateFrameIDAllocator()
    #expect(transaction.freezeMutationMembership() == nil)
    #expect(
        transaction.finishDerivation(
            semanticChanged: false,
            hasPresentationObligation: false,
            stagedActionCount: 0,
            maximumCommittedActions: 2,
            semanticRevisions: &semantics,
            actionGenerations: &actions
        ) == .unchanged
    )
    #expect(transaction.publishedRevision == SemanticRevision(rawValue: 3))
    #expect(semantics.reserve() == SemanticRevision(rawValue: 0))
    #expect(actions.reserve() == ActionGeneration(rawValue: 0))
    #expect(candidates.reserve() == CandidateFrameID(rawValue: 0))

    var recovery = RecordingDerivationTransaction(
        publishedRevision: SemanticRevision(rawValue: 3)
    )
    #expect(recovery.freezeMutationMembership() == nil)
    #expect(
        recovery.finishDerivation(
            semanticChanged: false,
            hasPresentationObligation: true,
            stagedActionCount: 0,
            maximumCommittedActions: 2,
            semanticRevisions: &semantics,
            actionGenerations: &actions
        ) == .presentationRecoveryRequired
    )
}
