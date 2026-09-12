import GiftUIExecution

package enum RuntimeCoordinatorLifecycleState: UInt8, Equatable, Sendable {
    case unvalidated = 0
    case validated = 1
    case idle = 2
    case active = 3
    case quiescent = 4
    case tornDown = 5
    case rejected = 6
}

package struct RuntimeCoordinatorLifecycle: Equatable, Sendable {
    private enum EntryOwner: UInt8, Equatable, Sendable {
        case none = 0
        case admission = 1
        case opportunity = 2
    }

    package private(set) var state: RuntimeCoordinatorLifecycleState
    package private(set) var validationFailure: RuntimeProfileValidationError?
    private var successfulAudit: RuntimeStorageAudit?
    private var retainedContext: ExecutionContext
    private var entryOwner: EntryOwner
    private var quiescenceRequested: Bool

    package init() {
        state = .unvalidated
        validationFailure = nil
        successfulAudit = nil
        retainedContext = ExecutionContext(
            cycle: nil,
            semanticRevision: nil,
            candidateFrame: nil,
            phase: .idle
        )
        entryOwner = .none
        quiescenceRequested = false
    }

    package var storageAudit: RuntimeStorageAudit? {
        successfulAudit
    }

    package var executionContext: ExecutionContext {
        retainedContext
    }

    package var isQuiescent: Bool {
        state == .quiescent || state == .tornDown
    }

    package mutating func validate(
        _ result: RuntimeProfileValidationResult
    ) -> RuntimeProfileValidationError? {
        guard state == .unvalidated else { return .invariantViolation }
        switch result {
        case .valid(let audit):
            successfulAudit = audit
            state = .validated
            return nil
        case .invalid(let error):
            validationFailure = error
            state = .rejected
            return error
        }
    }

    package mutating func enterIdle() -> RuntimeProfileValidationError? {
        guard state == .validated, successfulAudit != nil else {
            return .invariantViolation
        }
        state = .idle
        return nil
    }

    package mutating func beginAdmission() -> ExecutionError? {
        guard state == .idle, !quiescenceRequested else {
            return unavailableOrReentrantError()
        }
        guard entryOwner == .none else { return .reentrancyViolation }
        entryOwner = .admission
        return nil
    }

    package mutating func finishAdmission(
        context: ExecutionContext
    ) -> ExecutionError? {
        guard entryOwner == .admission else { return .invalidPhase }
        guard context.phase == .idle, context.cycle == nil else { return .invalidPhase }
        retainedContext = context
        entryOwner = .none
        if quiescenceRequested {
            state = .quiescent
        }
        return nil
    }

    package mutating func beginOpportunity(
        context: ExecutionContext
    ) -> ExecutionError? {
        guard state == .idle, !quiescenceRequested else {
            return unavailableOrReentrantError()
        }
        guard entryOwner == .none else { return .reentrancyViolation }
        guard context.phase == .admitting, context.cycle != nil else {
            return .invalidPhase
        }
        retainedContext = context
        entryOwner = .opportunity
        state = .active
        return nil
    }

    package mutating func recordActiveContext(
        _ context: ExecutionContext
    ) -> ExecutionError? {
        guard state == .active, entryOwner == .opportunity else {
            return .invalidPhase
        }
        retainedContext = context
        return nil
    }

    package mutating func finishOpportunity(
        context: ExecutionContext
    ) -> ExecutionError? {
        guard state == .active, entryOwner == .opportunity else {
            return .invalidPhase
        }
        guard context.phase == .idle, context.cycle == nil else { return .invalidPhase }
        retainedContext = context
        entryOwner = .none
        state = quiescenceRequested ? .quiescent : .idle
        return nil
    }

    package mutating func requestQuiescence() {
        switch state {
        case .idle where entryOwner == .none:
            quiescenceRequested = true
            state = .quiescent
        case .idle, .active:
            quiescenceRequested = true
        case .unvalidated, .validated, .quiescent, .tornDown, .rejected:
            break
        }
    }

    package mutating func completeTeardown() -> Bool {
        guard state == .quiescent, entryOwner == .none else { return false }
        state = .tornDown
        return true
    }

    private func unavailableOrReentrantError() -> ExecutionError {
        entryOwner == .none ? .requiredFacilityUnavailable : .reentrancyViolation
    }
}
