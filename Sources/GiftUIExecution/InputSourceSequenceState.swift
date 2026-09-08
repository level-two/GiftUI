import GiftUI

enum InputSequenceValidation: UInt8, Equatable, Sendable {
    case accepted = 0
    case consumedWhileCancelled = 1
    case invalidProvenance = 2
    case unavailable = 3
}

struct TargetInputSequenceGate: Equatable, Sendable {
    private var nextSubmittedSequenceRaw: UInt32?

    init(nextSubmittedSequenceRaw: UInt32? = 0) {
        self.nextSubmittedSequenceRaw = nextSubmittedSequenceRaw
    }

    var sequenceForUnsubmittedPhysicalInput: PointerSequenceID? {
        nextSubmittedSequenceRaw.map(PointerSequenceID.init(rawValue:))
    }

    mutating func beginSubmittedDown() -> PointerSequenceID? {
        guard let rawValue = nextSubmittedSequenceRaw else { return nil }

        let reserved = PointerSequenceID(rawValue: rawValue)
        let successor = rawValue.addingReportingOverflow(1)
        nextSubmittedSequenceRaw =
            successor.overflow
            ? nil
            : successor.partialValue
        return reserved
    }

    mutating func abandonUnsubmittedPhysicalInput() {
        // A wholly target-local physical sequence consumes no runtime value.
    }
}

struct InputSourceSequenceState: Equatable, Sendable {
    enum Mode: UInt8, Equatable, Sendable {
        case synchronized = 0
        case active = 1
        case cancelled = 2
        case quiescent = 3
    }

    private(set) var mode: Mode = .synchronized
    private(set) var sequence: PointerSequenceID?
    private(set) var ordinal: InputOrdinal?

    mutating func validate(
        phase: PointerPhase,
        sequence proposedSequence: PointerSequenceID,
        ordinal proposedOrdinal: InputOrdinal,
        targetGateAllowsResynchronization: Bool
    ) -> InputSequenceValidation {
        guard mode != .quiescent else { return .unavailable }

        switch phase {
        case .down:
            return validateDown(
                sequence: proposedSequence,
                ordinal: proposedOrdinal,
                targetGateAllowsResynchronization:
                    targetGateAllowsResynchronization
            )
        case .move, .up:
            return validateLaterPhase(
                phase: phase,
                sequence: proposedSequence,
                ordinal: proposedOrdinal
            )
        }
    }

    mutating func cancelCurrentSequence() {
        if mode == .active {
            mode = .cancelled
        }
    }

    private mutating func validateDown(
        sequence proposedSequence: PointerSequenceID,
        ordinal proposedOrdinal: InputOrdinal,
        targetGateAllowsResynchronization: Bool
    ) -> InputSequenceValidation {
        let replacesUnfinished = mode == .active || mode == .cancelled
        if replacesUnfinished && !targetGateAllowsResynchronization {
            cancelCurrentSequence()
            return .invalidProvenance
        }
        guard proposedOrdinal.rawValue == 0 else {
            cancelCurrentSequence()
            return .invalidProvenance
        }
        guard let expectedSequence = expectedNextSequence() else {
            mode = .quiescent
            return .unavailable
        }
        guard proposedSequence == expectedSequence else {
            cancelCurrentSequence()
            return .invalidProvenance
        }

        mode = .active
        sequence = proposedSequence
        ordinal = proposedOrdinal
        return .accepted
    }

    private mutating func validateLaterPhase(
        phase: PointerPhase,
        sequence proposedSequence: PointerSequenceID,
        ordinal proposedOrdinal: InputOrdinal
    ) -> InputSequenceValidation {
        guard mode == .active || mode == .cancelled,
            sequence == proposedSequence,
            let lastOrdinal = ordinal,
            let expectedOrdinal = checkedSuccessor(lastOrdinal),
            proposedOrdinal == expectedOrdinal
        else {
            cancelCurrentSequence()
            return .invalidProvenance
        }

        let wasCancelled = mode == .cancelled
        ordinal = proposedOrdinal
        if phase == .up {
            mode = .synchronized
        }
        return wasCancelled ? .consumedWhileCancelled : .accepted
    }

    private func expectedNextSequence() -> PointerSequenceID? {
        guard let sequence else {
            return PointerSequenceID(rawValue: 0)
        }
        let successor = sequence.rawValue.addingReportingOverflow(1)
        return successor.overflow
            ? nil
            : PointerSequenceID(rawValue: successor.partialValue)
    }

    private func checkedSuccessor(_ ordinal: InputOrdinal) -> InputOrdinal? {
        let successor = ordinal.rawValue.addingReportingOverflow(1)
        return successor.overflow
            ? nil
            : InputOrdinal(rawValue: successor.partialValue)
    }
}
