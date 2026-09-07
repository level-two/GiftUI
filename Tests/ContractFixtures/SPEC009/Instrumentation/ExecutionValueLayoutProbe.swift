import GiftUIExecution

package struct ExecutionFixtureOwnerFailure: Equatable, Sendable {
    package let rawValue: UInt32
}

package enum ExecutionValueLayoutProbe {
    @inline(__always)
    private static func size<T>(of type: T.Type) -> UInt32 {
        UInt32(MemoryLayout<T>.size)
    }

    @inline(never) package static func runCycleIDSize() -> UInt32 { size(of: RunCycleID.self) }
    @inline(never) package static func semanticRevisionSize() -> UInt32 { size(of: SemanticRevision.self) }
    @inline(never) package static func candidateFrameIDSize() -> UInt32 { size(of: CandidateFrameID.self) }
    @inline(never) package static func actionGenerationSize() -> UInt32 { size(of: ActionGeneration.self) }
    @inline(never) package static func observableTargetGenerationSize() -> UInt32 { size(of: ObservableTargetGeneration.self) }
    @inline(never) package static func executionPhaseSize() -> UInt32 { size(of: ExecutionPhase.self) }
    @inline(never) package static func executionLimitsSize() -> UInt32 { size(of: ExecutionLimits.self) }
    @inline(never) package static func executionContextSize() -> UInt32 { size(of: ExecutionContext.self) }
    @inline(never) package static func wakeReasonsSize() -> UInt32 { size(of: ExecutionWakeReasons.self) }
    @inline(never) package static func pendingIntentSize() -> UInt32 { size(of: PresentationPendingIntent.self) }
    @inline(never) package static func frameProvenanceSize() -> UInt32 { size(of: FrameProvenance.self) }
    @inline(never) package static func frameOfferDispositionSize() -> UInt32 { size(of: FrameOfferDisposition.self) }
    @inline(never) package static func logicalFrameDispositionSize() -> UInt32 { size(of: LogicalFrameDisposition.self) }
    @inline(never) package static func frameStreamResultSize() -> UInt32 { size(of: FrameStreamResult.self) }
    @inline(never) package static func frameOfferResultSize() -> UInt32 { size(of: FrameOfferResult.self) }
    @inline(never) package static func frameOfferFailureSize() -> UInt32 { size(of: FrameOfferFailure.self) }
    @inline(never) package static func frameRefusalOriginSize() -> UInt32 { size(of: FrameRefusalOrigin.self) }
    @inline(never) package static func admissionKindSize() -> UInt32 { size(of: AdmissionKind.self) }
    @inline(never) package static func admissionResultSize() -> UInt32 { size(of: ExecutionAdmissionResult.self) }
    @inline(never) package static func admissionOutcomeSize() -> UInt32 { size(of: ExecutionAdmissionOutcome.self) }
    @inline(never) package static func admissionSummarySize() -> UInt32 { size(of: AdmissionSummary.self) }
    @inline(never) package static func capturedActionSize() -> UInt32 { size(of: CapturedAction<UInt32>.self) }
    @inline(never) package static func executionErrorSize() -> UInt32 { size(of: ExecutionError.self) }
    @inline(never) package static func semanticDispositionSize() -> UInt32 { size(of: SemanticCycleDisposition.self) }
    @inline(never) package static func executionOperationalSize() -> UInt32 { size(of: ExecutionOperational.self) }
    @inline(never) package static func operationalEventsSize() -> UInt32 { size(of: ExecutionOperationalEvents.self) }
    @inline(never) package static func presentationIntentStateSize() -> UInt32 { size(of: PresentationIntentState.self) }
    @inline(never) package static func ownerFailureSize() -> UInt32 { size(of: ExecutionFixtureOwnerFailure.self) }
    @inline(never) package static func runCycleFailureSize() -> UInt32 { size(of: RunCycleFailure<ExecutionFixtureOwnerFailure>.self) }
    @inline(never) package static func runCycleSummarySize() -> UInt32 { size(of: RunCycleSummary.self) }
    @inline(never) package static func runCycleResultSize() -> UInt32 { size(of: RunCycleResult<ExecutionFixtureOwnerFailure>.self) }
}
