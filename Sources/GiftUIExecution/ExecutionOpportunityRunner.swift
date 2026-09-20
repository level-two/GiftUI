package protocol ExecutionOpportunityRunner {
    associatedtype OwnerFailure: Equatable & Sendable

    mutating func runOpportunity() -> RunCycleResult<OwnerFailure>
}
