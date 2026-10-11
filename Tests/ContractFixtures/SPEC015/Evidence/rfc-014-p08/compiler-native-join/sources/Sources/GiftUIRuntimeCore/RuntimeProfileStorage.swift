package protocol RuntimeProfileStorage: ~Copyable {
    associatedtype StructuralIdentity: Equatable & Sendable

    static var profile: RuntimeProfileKind { get }
    var limits: RuntimeProfileLimits { get }

    borrowing func audit() -> RuntimeProfileValidationResult
    mutating func resetAttemptStorage()
    mutating func resetAllStorage()
}

package enum RuntimeProfileStorageUseState: UInt8, Equatable, Sendable {
    case beforeUse = 0
    case inUse = 1
    case quiescedAndTornDown = 2
}

package struct ValidatedRuntimeProfileStorage<Storage: RuntimeProfileStorage & ~Copyable>: ~Copyable
{
    private var storage: Storage
    private let retainedStructuralIdentity: Storage.StructuralIdentity
    private let retainedAudit: RuntimeStorageAudit
    private var useState: RuntimeProfileStorageUseState

    package init?(
        storage: consuming Storage,
        structuralIdentity: Storage.StructuralIdentity
    ) {
        guard case .valid(let audit) = storage.audit(),
            audit.profile == Storage.profile,
            audit.limits == storage.limits
        else {
            return nil
        }

        self.storage = consume storage
        retainedStructuralIdentity = structuralIdentity
        retainedAudit = audit
        useState = .beforeUse
    }

    package var profile: RuntimeProfileKind {
        retainedAudit.profile
    }

    package var limits: RuntimeProfileLimits {
        retainedAudit.limits
    }

    package var structuralIdentity: Storage.StructuralIdentity {
        retainedStructuralIdentity
    }

    package var storageUseState: RuntimeProfileStorageUseState {
        useState
    }

    package borrowing func audit() -> RuntimeProfileValidationResult {
        .valid(retainedAudit)
    }

    package mutating func beginUse() -> Bool {
        guard useState != .quiescedAndTornDown else { return false }
        useState = .inUse
        return true
    }

    package mutating func finishQuiescenceAndTeardown() {
        useState = .quiescedAndTornDown
    }

    package mutating func resetAttemptStorage() -> RuntimeProfileValidationResult {
        storage.resetAttemptStorage()
        return validateRetainedStorage()
    }

    package mutating func resetAllStorage() -> RuntimeProfileValidationResult {
        guard useState == .beforeUse || useState == .quiescedAndTornDown else {
            return .invalid(.invariantViolation)
        }
        storage.resetAllStorage()
        return validateRetainedStorage()
    }

    private borrowing func validateRetainedStorage() -> RuntimeProfileValidationResult {
        guard Storage.profile == retainedAudit.profile,
            storage.limits == retainedAudit.limits,
            storage.audit() == .valid(retainedAudit)
        else {
            return .invalid(.invariantViolation)
        }
        return .valid(retainedAudit)
    }
}
