import GiftUI

private struct CheckedIdentityCursor: Equatable, Sendable {
    private var nextRawValue: UInt32?

    init() {
        nextRawValue = 0
    }

    init(nextRawValue: UInt32?) {
        self.nextRawValue = nextRawValue
    }

    mutating func reserveRawValue() -> UInt32? {
        guard let reserved = nextRawValue else { return nil }
        let successor = reserved.addingReportingOverflow(1)
        nextRawValue = successor.overflow ? nil : successor.partialValue
        return reserved
    }
}

package struct RunCycleIDAllocator: Equatable, Sendable {
    private var cursor: CheckedIdentityCursor

    package init() {
        cursor = CheckedIdentityCursor()
    }

    init(nextRawValue: UInt32?) {
        cursor = CheckedIdentityCursor(nextRawValue: nextRawValue)
    }

    package mutating func reserve() -> RunCycleID? {
        cursor.reserveRawValue().map(RunCycleID.init(rawValue:))
    }
}

package struct SemanticRevisionAllocator: Equatable, Sendable {
    private var cursor: CheckedIdentityCursor

    package init() {
        cursor = CheckedIdentityCursor()
    }

    init(nextRawValue: UInt32?) {
        cursor = CheckedIdentityCursor(nextRawValue: nextRawValue)
    }

    package mutating func reserve() -> SemanticRevision? {
        cursor.reserveRawValue().map(SemanticRevision.init(rawValue:))
    }
}

package struct CandidateFrameIDAllocator: Equatable, Sendable {
    private var cursor: CheckedIdentityCursor

    package init() {
        cursor = CheckedIdentityCursor()
    }

    init(nextRawValue: UInt32?) {
        cursor = CheckedIdentityCursor(nextRawValue: nextRawValue)
    }

    package mutating func reserve() -> CandidateFrameID? {
        cursor.reserveRawValue().map(CandidateFrameID.init(rawValue:))
    }
}

package struct PresentationRevisionAllocator: Equatable, Sendable {
    private var cursor: CheckedIdentityCursor

    package init() {
        cursor = CheckedIdentityCursor()
    }

    init(nextRawValue: UInt32?) {
        cursor = CheckedIdentityCursor(nextRawValue: nextRawValue)
    }

    package mutating func reserve() -> PresentationRevision? {
        cursor.reserveRawValue().map(PresentationRevision.init(rawValue:))
    }
}

package struct ActionGenerationAllocator: Equatable, Sendable {
    private var cursor: CheckedIdentityCursor

    package init() {
        cursor = CheckedIdentityCursor()
    }

    init(nextRawValue: UInt32?) {
        cursor = CheckedIdentityCursor(nextRawValue: nextRawValue)
    }

    package mutating func reserve() -> ActionGeneration? {
        cursor.reserveRawValue().map(ActionGeneration.init(rawValue:))
    }
}
