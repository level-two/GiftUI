struct ExecutionWakeAccumulator<Requester>: Sendable
where Requester: ExecutionWakeRequester & Sendable {
    private(set) var accumulatedReasons: ExecutionWakeReasons
    private(set) var wakeOutstanding: Bool
    private(set) var requester: Requester

    init(requester: Requester) {
        accumulatedReasons = []
        wakeOutstanding = false
        self.requester = requester
    }

    mutating func accumulate(_ reasons: ExecutionWakeReasons) {
        let normalized = ExecutionWakeReasons(rawValue: reasons.rawValue)
        guard !normalized.isEmpty else { return }

        accumulatedReasons.formUnion(normalized)
        guard !wakeOutstanding else { return }

        wakeOutstanding = true
        requester.requestWake(for: accumulatedReasons)
    }

    mutating func takeAtIdleOpportunity(
        phase: ExecutionPhase
    ) -> ExecutionWakeReasons? {
        guard phase == .idle else { return nil }

        let taken = accumulatedReasons
        accumulatedReasons = []
        wakeOutstanding = false
        return taken
    }
}
