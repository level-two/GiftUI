struct RecordingPublishedDerivation: Equatable, Sendable {
    let semanticRevision: SemanticRevision
    let firstActionGeneration: ActionGeneration?
    let secondActionGeneration: ActionGeneration?
}

enum RecordingDerivationOutcome: Equatable, Sendable {
    case unchanged
    case presentationRecoveryRequired
    case published(RecordingPublishedDerivation)
    case failure(ExecutionError)
}

struct RecordingDerivationTransaction: Equatable, Sendable {
    private(set) var publishedRevision: SemanticRevision?
    private(set) var mutationMembershipFrozen = false
    private(set) var needsLaterSemanticWake = false
    private(set) var hasAdmittedInvalidation = false
    private var didDerive = false

    init(publishedRevision: SemanticRevision? = nil) {
        self.publishedRevision = publishedRevision
    }

    mutating func recordInvalidation() {
        if mutationMembershipFrozen {
            needsLaterSemanticWake = true
        } else {
            hasAdmittedInvalidation = true
        }
    }

    mutating func freezeMutationMembership() -> ExecutionError? {
        guard !mutationMembershipFrozen else {
            return .reentrancyViolation
        }
        mutationMembershipFrozen = true
        return nil
    }

    mutating func finishDerivation(
        semanticChanged: Bool,
        hasPresentationObligation: Bool,
        stagedActionCount: UInt16,
        maximumCommittedActions: UInt16,
        semanticRevisions: inout SemanticRevisionAllocator,
        actionGenerations: inout ActionGenerationAllocator
    ) -> RecordingDerivationOutcome {
        guard mutationMembershipFrozen else {
            return .failure(.invalidPhase)
        }
        guard !didDerive else {
            return .failure(.reentrancyViolation)
        }
        didDerive = true

        guard semanticChanged else {
            hasAdmittedInvalidation = false
            return hasPresentationObligation
                ? .presentationRecoveryRequired
                : .unchanged
        }
        guard stagedActionCount <= maximumCommittedActions,
            stagedActionCount <= 2
        else {
            return .failure(.capacityExhausted)
        }

        var firstActionGeneration: ActionGeneration?
        var secondActionGeneration: ActionGeneration?
        if stagedActionCount > 0 {
            guard let generation = actionGenerations.reserve() else {
                return .failure(.identityExhausted)
            }
            firstActionGeneration = generation
        }
        if stagedActionCount > 1 {
            guard let generation = actionGenerations.reserve() else {
                return .failure(.identityExhausted)
            }
            secondActionGeneration = generation
        }
        guard let semanticRevision = semanticRevisions.reserve() else {
            return .failure(.identityExhausted)
        }

        let publication = RecordingPublishedDerivation(
            semanticRevision: semanticRevision,
            firstActionGeneration: firstActionGeneration,
            secondActionGeneration: secondActionGeneration
        )
        publishedRevision = semanticRevision
        hasAdmittedInvalidation = false
        return .published(publication)
    }
}
