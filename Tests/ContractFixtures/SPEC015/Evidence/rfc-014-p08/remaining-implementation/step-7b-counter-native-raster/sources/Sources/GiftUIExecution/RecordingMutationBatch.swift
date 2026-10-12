struct RecordingSemanticAction<Identity>: Sendable
where Identity: Equatable & Sendable {
    let identity: Identity
    let actionGeneration: ActionGeneration
    let targetGeneration: ObservableTargetGeneration
}

protocol RecordingMutationOwner {
    associatedtype StateChange: Sendable
    associatedtype Completion: Sendable
    associatedtype ActionIdentity: Equatable & Sendable

    mutating func apply(stateChange: borrowing StateChange)
    mutating func apply(completion: borrowing Completion)
    borrowing func actionGeneration(
        for identity: borrowing ActionIdentity
    ) -> ActionGeneration?
    borrowing func isActionEnabled(
        _ identity: borrowing ActionIdentity
    ) -> Bool?
    borrowing func targetGeneration(
        for identity: borrowing ActionIdentity
    ) -> ObservableTargetGeneration?
    mutating func dispatch(_ identity: borrowing ActionIdentity)
}

struct RecordingMutationBatch<StateChange, Completion, ActionIdentity>:
    Sendable
where
    StateChange: Sendable,
    Completion: Sendable,
    ActionIdentity: Equatable & Sendable
{
    private let firstStateChange: StateChange?
    private let secondStateChange: StateChange?
    private let firstCompletion: Completion?
    private let secondCompletion: Completion?
    private let firstAction: RecordingSemanticAction<ActionIdentity>?
    private let secondAction: RecordingSemanticAction<ActionIdentity>?
    private var wasApplied = false

    init?(
        firstStateChange: StateChange? = nil,
        secondStateChange: StateChange? = nil,
        firstCompletion: Completion? = nil,
        secondCompletion: Completion? = nil,
        firstAction: RecordingSemanticAction<ActionIdentity>? = nil,
        secondAction: RecordingSemanticAction<ActionIdentity>? = nil
    ) {
        guard firstStateChange != nil || secondStateChange == nil,
            firstCompletion != nil || secondCompletion == nil,
            firstAction != nil || secondAction == nil
        else { return nil }
        self.firstStateChange = firstStateChange
        self.secondStateChange = secondStateChange
        self.firstCompletion = firstCompletion
        self.secondCompletion = secondCompletion
        self.firstAction = firstAction
        self.secondAction = secondAction
    }

    mutating func apply<Owner>(
        phase: ExecutionPhase,
        to owner: inout Owner
    ) -> ExecutionError?
    where
        Owner: RecordingMutationOwner,
        Owner.StateChange == StateChange,
        Owner.Completion == Completion,
        Owner.ActionIdentity == ActionIdentity
    {
        guard phase == .mutating else { return .invalidPhase }
        guard !wasApplied else { return .reentrancyViolation }
        wasApplied = true

        if let firstStateChange {
            owner.apply(stateChange: firstStateChange)
        }
        if let secondStateChange {
            owner.apply(stateChange: secondStateChange)
        }
        if let firstCompletion {
            owner.apply(completion: firstCompletion)
        }
        if let secondCompletion {
            owner.apply(completion: secondCompletion)
        }
        dispatch(firstAction, through: &owner)
        dispatch(secondAction, through: &owner)
        return nil
    }

    private func dispatch<Owner>(
        _ candidate: RecordingSemanticAction<ActionIdentity>?,
        through owner: inout Owner
    )
    where
        Owner: RecordingMutationOwner,
        Owner.StateChange == StateChange,
        Owner.Completion == Completion,
        Owner.ActionIdentity == ActionIdentity
    {
        guard let candidate,
            owner.actionGeneration(for: candidate.identity)
                == candidate.actionGeneration,
            owner.isActionEnabled(candidate.identity) == true,
            owner.targetGeneration(for: candidate.identity)
                == candidate.targetGeneration
        else { return }
        owner.dispatch(candidate.identity)
    }
}
