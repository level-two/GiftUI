import GiftUIExecution

package enum RuntimeCleanupFailureContainment: UInt8, Equatable, Sendable {
    case none = 0
    case contained = 1
    case safetyNotProven = 2
}

package struct RuntimeFocusedFailureState: Equatable, Sendable {
    package private(set) var firstFailure: RuntimeOwnerFailure?
    package private(set) var detectingContext: ExecutionContext?
    package private(set) var cleanupContainment: RuntimeCleanupFailureContainment

    package init() {
        firstFailure = nil
        detectingContext = nil
        cleanupContainment = .none
    }

    package mutating func captureFirst(
        _ failure: RuntimeOwnerFailure,
        context: ExecutionContext
    ) {
        guard firstFailure == nil else { return }
        firstFailure = failure
        detectingContext = context
    }

    package mutating func recordCleanupFailure(
        containment: RuntimeCleanupFailureContainment
    ) {
        if containment.rawValue > cleanupContainment.rawValue {
            cleanupContainment = containment
        }
    }

    package func selectedFailure()
        -> (context: ExecutionContext, failure: RunCycleFailure<RuntimeOwnerFailure>)?
    {
        guard let firstFailure, let detectingContext else { return nil }
        return (detectingContext, .focusedOwner(firstFailure))
    }
}
