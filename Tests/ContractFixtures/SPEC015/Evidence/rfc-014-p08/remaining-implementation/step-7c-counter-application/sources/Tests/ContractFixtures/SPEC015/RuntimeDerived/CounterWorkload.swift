import GiftUIRuntimeCore
@testable import GiftUIHostConfiguration

// Immutable scalar reservations for the finite UInt8 counter. No occurrence,
// branch, parent/child or expanded topology is supplied to the runtime.
// Actual storage/audit and complete source-route fit are proved separately.
enum P08CounterWorkload {
    static func limits(_ profile: RuntimeProfileKind, models: RuntimeModelLimits? = nil,
                       actionCount: UInt16 = 2, captureBytes: UInt16 = 32) -> RuntimeProfileLimits {
        RuntimeProfileLimits(
            records: .init(maximumPathEntries: 192, maximumPathDepth: 24,
                maximumPathChildFanout: 5, maximumPayloadBytesPerBank: 4096,
                maximumIdentityComponentsPerKey: 24, maximumInteractionIdentityComponents: 48),
            models: models ?? .init(maximumModelSlots: 2, maximumOwningTickets: 4,
                maximumFramePins: 2, maximumModelCaptureBanks: 0),
            semantic: .init(maximumDepth: 24, maximumSemanticNodes: 24,
                maximumBodyEvaluations: 8, maximumModifierApplications: 8,
                maximumActionOccurrences: actionCount)!,
            maximumSemanticStructuralOccurrences: 64,
            layout: .init(maximumScopes: 32, maximumDepth: 12, maximumTextScalars: 64,
                maximumTextLines: 16, maximumPositionedGlyphs: 64)!,
            render: .init(maximumOperations: 25, maximumPositionedGlyphs: 64, maximumClipDepth: 4)!,
            renderWorkspace: .init(maximumSemanticScopes: 32, maximumLayoutScopes: 32,
                maximumTraversalDepth: 12, maximumTextLines: 16)!,
            renderSink: .init(maximumOperations: 25, maximumPositionedGlyphs: 64),
            maximumOrdinaryRenderOperations: 24,
            execution: .init(maximumInputEvents: max(2, actionCount), maximumStateChangeFacts: 34,
                maximumCompletionFacts: 1, maximumSemanticActions: actionCount,
                maximumActiveInputSources: 1, maximumCommittedActions: actionCount)!,
            observableState: .init(maximumLocations: 1, maximumRegistrations: 1,
                maximumStagedAssociations: 1)!,
            interaction: .init(maximumActions: actionCount, maximumHitRegions: actionCount)!,
            drawing: .init(maximumLineWidth: 1, maximumCanvasOccurrences: 1,
                maximumLivePathPoints: 2, maximumLivePathSubpaths: 1, maximumPlanStrokes: 1,
                maximumPlanPoints: 2, maximumPlanSubpaths: 1, maximumNormalizedStrokeOperations: 1)!,
            staticCanvas: profile == .static
                ? .init(maximumStaticCallableCases: 1, maximumStaticCaptureBytes: captureBytes)! : nil,
            profile: profile)!
    }
    static func value(_ limits: RuntimeProfileLimits, schema: UInt16 = 4) -> SignalAnalyzerHostWorkload {
        .init(schemaVersion: schema, requiredPathEntries: 192, requiredPayloadBytesPerBank: 4096,
            requiredInteractionIdentityComponents: 48, requiredPathDepth: 24,
            requiredPathChildFanout: 5, requiredIdentityComponentsPerKey: 24,
            requiredRuntimeLimits: limits, semanticNodeOccurrences: 24,
            semanticStructuralOccurrences: 64, renderSemanticScopeOccurrences: 32,
            layoutScopeOccurrences: 32, maximumRenderTraversalDepth: 12,
            renderTextLineCount: 16, positionedGlyphCount: 64, ordinaryRenderOperations: 24,
            inputEventsPerOpportunity: limits.execution.maximumInputEvents,
            semanticActionsPerOpportunity: limits.semantic.maximumActionOccurrences,
            completionFactsPerOpportunity: 1,
            drawing: .init(canvasOccurrences: 1, maximumLivePathPoints: 2,
                maximumLivePathSubpaths: 1, submittedStrokes: 1, snapshottedPoints: 2,
                snapshottedSubpaths: 1, normalizedStrokeOperations: 1, greatestLineWidth: 1,
                staticCallableCases: limits.staticCanvas?.maximumStaticCallableCases,
                maximumStaticCaptureBytes: limits.staticCanvas?.maximumStaticCaptureBytes))
    }
    static let cardinality = SignalAnalyzerHostCardinality(actionCaseCount: 2,
        rootModelLocationCount: 1, activeRegistrationCount: 1, stagedAssociationCount: 1,
        snapshotFactCapacity: 1, compactFactCapacity: 32, reservedFailureFactCapacity: 1,
        normalizedInputSourceCapacity: 1)
    // Conservative admission/pacing reservations retain the governed host table;
    // no source or admission region is made available to model replacement.
    static let pacing = HostPacingPolicy(minimumFrameIntervalMicroseconds: 250_000,
        maximumFactServiceLatencyMicroseconds: 250_000,
        minimumAcceptedTransitionSpacingMicroseconds: 50_000,
        maximumTransitionFactsPerServiceWindow: 20, maximumBootstrapFactsPerServiceWindow: 2,
        maximumActionInducedFactsPerServiceWindow: 6, maximumRetryableRefusals: 3)!
}
