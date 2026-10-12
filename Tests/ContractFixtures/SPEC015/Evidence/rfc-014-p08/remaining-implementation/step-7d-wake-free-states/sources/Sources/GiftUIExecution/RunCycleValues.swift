import GiftUI
import GiftUIRenderCore

package enum ExecutionError: UInt8, Equatable, Sendable {
    case invalidValue = 0
    case arithmeticOverflow = 1
    case capacityExhausted = 2
    case identityExhausted = 3
    case invalidProvenance = 4
    case invalidPhase = 5
    case reentrancyViolation = 6
    case requiredFacilityUnavailable = 7
    case invariantViolation = 8
}

package enum SemanticCycleDisposition: UInt8, Equatable, Sendable {
    case unchanged = 0
    case published = 1
    case dirty = 2
}

package enum ExecutionOperational: UInt8, Equatable, Sendable {
    case noChange = 0
    case backpressured = 1
    case retryableRefusal = 2
    case superseded = 3
    case deferredToLaterAdmission = 4
}

package struct ExecutionOperationalEvents: OptionSet, Equatable, Sendable {
    package let rawValue: UInt8

    package init(rawValue: UInt8) {
        self.rawValue = rawValue & 0x1F
    }

    package static let noChange = Self(rawValue: 0x01)
    package static let backpressured = Self(rawValue: 0x02)
    package static let retryableRefusal = Self(rawValue: 0x04)
    package static let superseded = Self(rawValue: 0x08)
    package static let deferredToLaterAdmission = Self(rawValue: 0x10)
}

package enum PresentationIntentState: UInt8, Equatable, Sendable {
    case satisfied = 0
    case pending = 1
    case unavailable = 2
}

package enum RunCycleFailure<OwnerFailure: Equatable & Sendable>: Equatable, Sendable {
    case execution(ExecutionError)
    case renderProduction(RenderProductionError)
    case frameOffer(FrameOfferFailure)
    case nonRetryableRefusal(FrameRefusalOrigin)
    case focusedOwner(OwnerFailure)
}

package struct RunCycleSummary: Equatable, Sendable {
    package let cycle: RunCycleID
    package let admission: AdmissionSummary
    package let semanticRevision: SemanticRevision?
    package let semanticDisposition: SemanticCycleDisposition
    package let logicalFrameDisposition: LogicalFrameDisposition
    package let committedPresentationRevision: PresentationRevision?
    package let presentationIntentState: PresentationIntentState
    package let presentationPending: PresentationPendingIntent?
    package let operationalEvents: ExecutionOperationalEvents

    package init?(
        cycle: RunCycleID,
        admission: AdmissionSummary,
        semanticRevision: SemanticRevision?,
        semanticDisposition: SemanticCycleDisposition,
        logicalFrameDisposition: LogicalFrameDisposition,
        committedPresentationRevision: PresentationRevision?,
        presentationIntentState: PresentationIntentState,
        presentationPending: PresentationPendingIntent?,
        operationalEvents: ExecutionOperationalEvents
    ) {
        guard (presentationIntentState == .pending) == (presentationPending != nil),
            presentationPending?.semanticRevision == semanticRevision || presentationPending == nil,
            semanticDisposition != .published || semanticRevision != nil,
            logicalFrameDisposition != .committed || committedPresentationRevision != nil,
            logicalFrameDisposition != .committed || presentationIntentState == .satisfied,
            !operationalEvents.contains([.backpressured, .retryableRefusal]),
            !operationalEvents.contains(.noChange)
                || operationalEvents.intersection([.backpressured, .retryableRefusal, .superseded])
                    .isEmpty,
            !operationalEvents.contains(.noChange)
                || (semanticDisposition == .unchanged
                    && logicalFrameDisposition == .notProduced
                    && presentationIntentState == .satisfied),
            !operationalEvents.contains(.backpressured)
                || (logicalFrameDisposition == .aborted && presentationIntentState == .pending),
            !operationalEvents.contains(.retryableRefusal)
                || (logicalFrameDisposition == .aborted
                    && presentationIntentState != .satisfied),
            !operationalEvents.contains(.superseded) || semanticDisposition == .published
        else { return nil }

        self.cycle = cycle
        self.admission = admission
        self.semanticRevision = semanticRevision
        self.semanticDisposition = semanticDisposition
        self.logicalFrameDisposition = logicalFrameDisposition
        self.committedPresentationRevision = committedPresentationRevision
        self.presentationIntentState = presentationIntentState
        self.presentationPending = presentationPending
        self.operationalEvents = operationalEvents
    }
}

package enum RunCycleResult<OwnerFailure: Equatable & Sendable>: Equatable, Sendable {
    case success(RunCycleSummary)
    case operational(ExecutionOperational, RunCycleSummary)
    case failure(
        ExecutionContext,
        RunCycleFailure<OwnerFailure>,
        RunCycleSummary?
    )
}
