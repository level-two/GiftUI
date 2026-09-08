struct ExecutionAdmissionSealSelection: Equatable, Sendable {
    let summary: AdmissionSummary
    let hasDeferredWork: Bool
}

struct ExecutionAdmissionSealer {
    static func select(
        pendingInputEvents: UInt16,
        pendingStateChangeFacts: UInt16,
        pendingCompletionFacts: UInt16,
        sameCycleActivationCandidates: UInt16,
        includesDirtyRederivation: Bool,
        includesPresentationRecovery: Bool,
        limits: ExecutionLimits
    ) -> ExecutionAdmissionSealSelection? {
        let inputCount = min(
            pendingInputEvents,
            limits.maximumInputEvents
        )
        let stateChangeCount = min(
            pendingStateChangeFacts,
            limits.maximumStateChangeFacts
        )
        let completionCount = min(
            pendingCompletionFacts,
            limits.maximumCompletionFacts
        )
        guard sameCycleActivationCandidates <= inputCount,
            sameCycleActivationCandidates <= limits.maximumSemanticActions,
            let summary = AdmissionSummary(
                inputEventCount: inputCount,
                stateChangeFactCount: stateChangeCount,
                completionFactCount: completionCount,
                semanticActionCount: sameCycleActivationCandidates,
                includesDirtyRederivation: includesDirtyRederivation,
                includesPresentationRecovery: includesPresentationRecovery,
                limits: limits
            )
        else {
            return nil
        }

        return ExecutionAdmissionSealSelection(
            summary: summary,
            hasDeferredWork: pendingInputEvents > inputCount
                || pendingStateChangeFacts > stateChangeCount
                || pendingCompletionFacts > completionCount
        )
    }
}
