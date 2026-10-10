/// Issued by host assembly bookkeeping, independently of registration generations.
package struct ObservableModelOwnerIdentity: Equatable, Sendable {
    package let rawValue: UInt32

    fileprivate init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

/// The host keeps this namespace alive across retirement and reassembly.
/// It cannot be copied to fork an issuing cursor or reset after exhaustion.
package struct ObservableModelOwnerNamespace: ~Copyable {
    private var nextValue: UInt32?

    package init() {
        nextValue = 0
    }

    // Internal boundary fixture entry; production starts at zero.
    init(nextValue: UInt32?) {
        self.nextValue = nextValue
    }

    package var isExhausted: Bool { nextValue == nil }

    package mutating func issue() throws(ObservableStateError) -> ObservableModelOwnerIdentity {
        guard let value = nextValue else { throw .modelGenerationExhausted }
        let successor = value.addingReportingOverflow(1)
        nextValue = successor.overflow ? nil : successor.partialValue
        return ObservableModelOwnerIdentity(rawValue: value)
    }
}

/// Each live owning store has a separate noncopyable allocation cursor.
package struct ObservableModelAllocationNamespace: ~Copyable {
    private var nextValue: UInt32?

    package init() {
        nextValue = 0
    }

    init(nextValue: UInt32?) {
        self.nextValue = nextValue
    }

    package var isExhausted: Bool { nextValue == nil }

    package mutating func issue() throws(ObservableStateError) -> UInt32 {
        guard let value = nextValue else { throw .modelGenerationExhausted }
        let successor = value.addingReportingOverflow(1)
        nextValue = successor.overflow ? nil : successor.partialValue
        return value
    }
}
