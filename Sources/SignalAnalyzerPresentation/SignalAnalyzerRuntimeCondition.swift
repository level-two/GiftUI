package enum SignalAnalyzerRuntimeCondition: UInt8, Equatable, Sendable {
    case stateLocationCapacityExhausted
    case registrationCapacityExhausted
    case replacementStagingExhausted
    case duplicateModelOwner
    case incompatibleStateAssociation
    case staleRegistrationReport
    case mutationPhaseViolation
    case observableStateReentrancyViolation
    case observableStateInvariantViolation
    case captureRevisionMismatch
    case reservedFailureCapacityExhausted
    case identityGenerationExhausted
}
