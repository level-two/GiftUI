import GiftUIExecution

package enum HostWakeDirective: UInt8, Equatable, Sendable {
    case requestWake = 0
    case coalesced = 1
}

package enum HostWakePacingError: UInt8, Error, Equatable, Sendable {
    case unavailable = 0
    case reentrant = 1
    case noPendingWork = 2
    case tooEarly = 3
    case serviceDeadlineMissed = 4
    case timeRegression = 5
    case arithmeticOverflow = 6
    case invalidPacingWindow = 7
}

package enum HostOpportunitySchedule: Equatable, Sendable {
    case noWork
    case wait(untilMicroseconds: UInt64)
    case run
    case invalid(HostWakePacingError)
}

package enum HostOpportunityBeginResult: Equatable, Sendable {
    case began(ExecutionWakeReasons)
    case rejected(HostWakePacingError)
}

package struct HostWakePacingController: Sendable {
    private let minimumFrameIntervalMicroseconds: UInt64
    private let maximumFactServiceLatencyMicroseconds: UInt64
    private var pendingReasons: ExecutionWakeReasons = []
    private var firstPendingFactMicroseconds: UInt64?
    private var lastOpportunityStartMicroseconds: UInt64
    private var activeOpportunityStartMicroseconds: UInt64?
    private var lastObservedMicroseconds: UInt64
    private var isAvailable = true

    package init(
        policy: HostPacingPolicy,
        initialFrameOriginMicroseconds: UInt64
    ) {
        minimumFrameIntervalMicroseconds = UInt64(
            policy.minimumFrameIntervalMicroseconds
        )
        maximumFactServiceLatencyMicroseconds = UInt64(
            policy.maximumFactServiceLatencyMicroseconds
        )
        lastOpportunityStartMicroseconds = initialFrameOriginMicroseconds
        lastObservedMicroseconds = initialFrameOriginMicroseconds
    }

    package var accumulatedReasons: ExecutionWakeReasons { pendingReasons }
    package var wakeIsOutstanding: Bool { !pendingReasons.isEmpty }
    package var opportunityIsActive: Bool { activeOpportunityStartMicroseconds != nil }

    package mutating func recordAcceptedFact(
        at timestampMicroseconds: UInt64
    ) -> Result<HostWakeDirective, HostWakePacingError> {
        switch record(.admittedWork, at: timestampMicroseconds) {
        case .success(let directive):
            if firstPendingFactMicroseconds == nil {
                firstPendingFactMicroseconds = timestampMicroseconds
            }
            return .success(directive)
        case .failure(let error):
            return .failure(error)
        }
    }

    package mutating func record(
        _ reasons: ExecutionWakeReasons,
        at timestampMicroseconds: UInt64
    ) -> Result<HostWakeDirective, HostWakePacingError> {
        guard isAvailable else { return .failure(.unavailable) }
        guard timestampMicroseconds >= lastObservedMicroseconds else {
            return .failure(.timeRegression)
        }
        let normalized = ExecutionWakeReasons(rawValue: reasons.rawValue)
        guard !normalized.isEmpty else { return .success(.coalesced) }
        lastObservedMicroseconds = timestampMicroseconds
        let wasEmpty = pendingReasons.isEmpty
        pendingReasons.formUnion(normalized)
        return .success(wasEmpty ? .requestWake : .coalesced)
    }

    package mutating func schedule(
        at timestampMicroseconds: UInt64
    ) -> HostOpportunitySchedule {
        guard isAvailable else { return .invalid(.unavailable) }
        guard activeOpportunityStartMicroseconds == nil else {
            return .invalid(.reentrant)
        }
        guard timestampMicroseconds >= lastObservedMicroseconds else {
            return .invalid(.timeRegression)
        }
        lastObservedMicroseconds = timestampMicroseconds
        guard !pendingReasons.isEmpty else { return .noWork }
        guard
            let frameBoundary = adding(
                minimumFrameIntervalMicroseconds,
                to: lastOpportunityStartMicroseconds
            )
        else {
            return .invalid(.arithmeticOverflow)
        }
        if let firstPendingFactMicroseconds {
            guard
                let deadline = adding(
                    maximumFactServiceLatencyMicroseconds,
                    to: firstPendingFactMicroseconds
                )
            else {
                return .invalid(.arithmeticOverflow)
            }
            guard frameBoundary <= deadline else {
                return .invalid(.invalidPacingWindow)
            }
            guard timestampMicroseconds <= deadline else {
                return .invalid(.serviceDeadlineMissed)
            }
        }
        guard timestampMicroseconds >= frameBoundary else {
            return .wait(untilMicroseconds: frameBoundary)
        }
        return .run
    }

    package mutating func beginOpportunity(
        at timestampMicroseconds: UInt64
    ) -> HostOpportunityBeginResult {
        switch schedule(at: timestampMicroseconds) {
        case .run:
            let reasons = pendingReasons
            pendingReasons = []
            firstPendingFactMicroseconds = nil
            activeOpportunityStartMicroseconds = timestampMicroseconds
            return .began(reasons)
        case .noWork:
            return .rejected(.noPendingWork)
        case .wait:
            return .rejected(.tooEarly)
        case .invalid(let error):
            return .rejected(error)
        }
    }

    package mutating func completeOpportunity(
        at timestampMicroseconds: UInt64
    ) -> HostWakePacingError? {
        guard let start = activeOpportunityStartMicroseconds else {
            return .noPendingWork
        }
        guard timestampMicroseconds >= lastObservedMicroseconds,
            timestampMicroseconds >= start
        else {
            return .timeRegression
        }
        lastObservedMicroseconds = timestampMicroseconds
        lastOpportunityStartMicroseconds = start
        activeOpportunityStartMicroseconds = nil
        return nil
    }

    package mutating func quiesce() -> HostWakePacingError? {
        guard activeOpportunityStartMicroseconds == nil else { return .reentrant }
        isAvailable = false
        pendingReasons = []
        firstPendingFactMicroseconds = nil
        return nil
    }

    private func adding(_ interval: UInt64, to timestamp: UInt64) -> UInt64? {
        let (value, overflow) = timestamp.addingReportingOverflow(interval)
        return overflow ? nil : value
    }

}
