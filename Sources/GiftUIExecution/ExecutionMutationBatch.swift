package protocol ExecutionMutationBatchView: Sendable {
    associatedtype StateChange: Sendable
    associatedtype Completion: Sendable
    associatedtype ActionIdentity: Equatable & Sendable

    var stateChangeCount: UInt16 { get }
    var completionCount: UInt16 { get }
    var actionCount: UInt16 { get }

    borrowing func stateChange(at index: UInt16) -> StateChange
    borrowing func completion(at index: UInt16) -> Completion
    borrowing func action(at index: UInt16) -> CapturedAction<ActionIdentity>
}

package protocol ExecutionMutationOwner {
    associatedtype StateChange: Sendable
    associatedtype Completion: Sendable
    associatedtype ActionIdentity: Equatable & Sendable

    mutating func apply(stateChange: borrowing StateChange)
    mutating func apply(completion: borrowing Completion)
    mutating func dispatch(
        _ captured: borrowing CapturedAction<ActionIdentity>
    )
}

package struct ExecutionMutationBatch<View>: Sendable
where View: ExecutionMutationBatchView {
    private let view: View
    private var wasApplied = false

    package init?(view: View, limits: ExecutionLimits) {
        guard view.stateChangeCount <= limits.maximumStateChangeFacts,
            view.completionCount <= limits.maximumCompletionFacts,
            view.actionCount <= limits.maximumSemanticActions
        else { return nil }
        self.view = view
    }

    package mutating func apply<Owner>(
        phase: ExecutionPhase,
        to owner: inout Owner
    ) -> ExecutionError?
    where
        Owner: ExecutionMutationOwner,
        Owner.StateChange == View.StateChange,
        Owner.Completion == View.Completion,
        Owner.ActionIdentity == View.ActionIdentity
    {
        guard phase == .mutating else { return .invalidPhase }
        guard !wasApplied else { return .reentrancyViolation }
        wasApplied = true

        for index in 0 ..< view.stateChangeCount {
            let fact = view.stateChange(at: index)
            owner.apply(stateChange: fact)
        }
        for index in 0 ..< view.completionCount {
            let fact = view.completion(at: index)
            owner.apply(completion: fact)
        }
        for index in 0 ..< view.actionCount {
            let captured = view.action(at: index)
            owner.dispatch(captured)
        }
        return nil
    }
}
