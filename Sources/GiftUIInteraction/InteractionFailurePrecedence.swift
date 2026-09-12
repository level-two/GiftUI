package struct InteractionVisibleFailures: Equatable, Sendable {
    private var rawValue: UInt16 = 0

    package init() {}

    package mutating func insert(_ error: InteractionError) {
        rawValue |= UInt16(1) << UInt16(error.rawValue)
    }

    package borrowing func contains(_ error: InteractionError) -> Bool {
        rawValue & (UInt16(1) << UInt16(error.rawValue)) != 0
    }
}

package enum InteractionFailurePrecedence {
    package static func select(
        from failures: borrowing InteractionVisibleFailures
    ) -> InteractionError? {
        if failures.contains(.reentrancyViolation) { return .reentrancyViolation }
        if failures.contains(.invalidPhase) { return .invalidPhase }
        if failures.contains(.incompatibleActionDomain) { return .incompatibleActionDomain }
        if failures.contains(.missingModelTarget) { return .missingModelTarget }
        if failures.contains(.invalidIdentity) { return .invalidIdentity }
        if failures.contains(.invalidGeometry) { return .invalidGeometry }
        if failures.contains(.invalidActionValue) { return .invalidActionValue }
        if failures.contains(.capacityExhausted) { return .capacityExhausted }
        if failures.contains(.invariantViolation) { return .invariantViolation }
        return nil
    }
}
