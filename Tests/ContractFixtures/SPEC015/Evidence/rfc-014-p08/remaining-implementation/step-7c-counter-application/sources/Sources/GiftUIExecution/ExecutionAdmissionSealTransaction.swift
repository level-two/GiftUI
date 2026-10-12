import GiftUI

enum ExecutionAdmissionSealFailure: UInt8, Equatable, Sendable {
    case invalidProvenance = 0
    case capacityExhausted = 1
}

struct CancelledInputSequence: Equatable, Sendable {
    let source: InputSourceID
    let sequence: PointerSequenceID
}

struct ExecutionAdmissionSealFailureResult: Error, Equatable, Sendable {
    let failure: ExecutionAdmissionSealFailure
    let cancelledSequence: CancelledInputSequence?
    let summary: AdmissionSummary
}

struct ExecutionAdmissionSealTransaction: Sendable {
    private let limits: ExecutionLimits
    private let zeroSummary: AdmissionSummary
    private(set) var stagedInputCount: UInt16 = 0
    private(set) var stagedActivationCount: UInt16 = 0
    private(set) var firstFailure: ExecutionAdmissionSealFailureResult?
    private(set) var isActive: Bool = false

    init?(limits: ExecutionLimits) {
        guard
            let zeroSummary = AdmissionSummary(
                inputEventCount: 0,
                stateChangeFactCount: 0,
                completionFactCount: 0,
                semanticActionCount: 0,
                includesDirtyRederivation: false,
                includesPresentationRecovery: false,
                limits: limits
            )
        else { return nil }
        self.limits = limits
        self.zeroSummary = zeroSummary
    }

    mutating func begin() -> Bool {
        guard !isActive else { return false }
        stagedInputCount = 0
        stagedActivationCount = 0
        firstFailure = nil
        isActive = true
        return true
    }

    mutating func stagePointer(
        _ pointer: NormalizedPointerEvent,
        provenanceValid: Bool,
        createsActivation: Bool,
        transitionReservationAvailable: Bool
    ) -> Bool {
        guard isActive, firstFailure == nil else { return false }
        guard provenanceValid else {
            recordFailure(
                .invalidProvenance,
                cancelledSequence: pointer
            )
            return false
        }
        guard transitionReservationAvailable else {
            recordFailure(.capacityExhausted, cancelledSequence: nil)
            return false
        }
        guard stagedInputCount < limits.maximumInputEvents else {
            return false
        }

        if createsActivation {
            guard stagedActivationCount < limits.maximumSemanticActions else {
                recordFailure(
                    .capacityExhausted,
                    cancelledSequence: pointer
                )
                return false
            }
            stagedActivationCount += 1
        }
        stagedInputCount += 1
        return true
    }

    mutating func finish(
        pendingStateChangeFacts: UInt16,
        pendingCompletionFacts: UInt16,
        includesDirtyRederivation: Bool,
        includesPresentationRecovery: Bool,
        batchReservationAvailable: Bool
    ) -> Result<ExecutionAdmissionSealSelection, ExecutionAdmissionSealFailureResult> {
        guard isActive else {
            return .failure(
                zeroFailure(.capacityExhausted, cancelledSequence: nil)
            )
        }
        defer { reset() }

        if let firstFailure {
            return .failure(firstFailure)
        }
        guard batchReservationAvailable else {
            return .failure(
                zeroFailure(.capacityExhausted, cancelledSequence: nil)
            )
        }
        guard
            let selection = ExecutionAdmissionSealer.select(
                pendingInputEvents: stagedInputCount,
                pendingStateChangeFacts: pendingStateChangeFacts,
                pendingCompletionFacts: pendingCompletionFacts,
                sameCycleActivationCandidates: stagedActivationCount,
                includesDirtyRederivation: includesDirtyRederivation,
                includesPresentationRecovery: includesPresentationRecovery,
                limits: limits
            )
        else {
            return .failure(
                zeroFailure(.capacityExhausted, cancelledSequence: nil)
            )
        }
        return .success(selection)
    }

    private mutating func recordFailure(
        _ failure: ExecutionAdmissionSealFailure,
        cancelledSequence pointer: NormalizedPointerEvent?
    ) {
        guard firstFailure == nil else { return }
        let cancellation = pointer.map {
            CancelledInputSequence(
                source: $0.source,
                sequence: $0.sequence
            )
        }
        firstFailure = zeroFailure(
            failure,
            cancelledSequence: cancellation
        )
        stagedInputCount = 0
        stagedActivationCount = 0
    }

    private func zeroFailure(
        _ failure: ExecutionAdmissionSealFailure,
        cancelledSequence: CancelledInputSequence?
    ) -> ExecutionAdmissionSealFailureResult {
        return ExecutionAdmissionSealFailureResult(
            failure: failure,
            cancelledSequence: cancelledSequence,
            summary: zeroSummary
        )
    }

    private mutating func reset() {
        stagedInputCount = 0
        stagedActivationCount = 0
        firstFailure = nil
        isActive = false
    }
}
