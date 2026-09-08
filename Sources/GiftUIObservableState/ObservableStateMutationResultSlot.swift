import GiftUIExecution

enum ObservableStateMutationFailureRoute: Equatable, Sendable {
    case none
    case cycleLocal
    case ownerAdapter(ObservableStateError)
}

struct ObservableStateMutationResultSlot: Equatable, Sendable {
    private(set) var cycleActive = false
    private var firstFailure: ObservableStateError?

    var pendingFailure: ObservableStateError? {
        firstFailure
    }

    mutating func beginCycle(phase: ExecutionPhase) -> ObservableStateError? {
        guard !cycleActive else { return .reentrancyViolation }
        guard phase == .mutating else {
            return .invalidPhaseSafetyNotProven
        }
        cycleActive = true
        firstFailure = nil
        return nil
    }

    mutating func record(
        _ result: ObservableStateResult
    ) -> ObservableStateMutationFailureRoute {
        guard case .failure(let failure) = result else { return .none }
        guard cycleActive else { return .ownerAdapter(failure) }
        if firstFailure == nil {
            firstFailure = failure
        }
        return .cycleLocal
    }

    mutating func recordReportDisposition(
        _ disposition: ObservableStateReportDisposition
    ) -> ObservableStateMutationFailureRoute {
        record(disposition.ownerResult)
    }

    mutating func consumeAfterOperation() -> ObservableStateError? {
        guard cycleActive else { return nil }
        let failure = firstFailure
        firstFailure = nil
        return failure
    }

    mutating func prepareForDerivation() -> ObservableStateError? {
        guard cycleActive else { return .invalidPhaseSafetyNotProven }
        guard firstFailure == nil else { return .invariantViolation }
        cycleActive = false
        return nil
    }
}
