import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUISemanticCore
import Testing

@testable import GiftUIRuntimeCore

private func makeAuditLimits() -> RuntimeProfileLimits {
    RuntimeProfileLimits(
        semantic: SemanticExpansionLimits(
            maximumDepth: 2,
            maximumSemanticNodes: 2,
            maximumBodyEvaluations: 2,
            maximumModifierApplications: 1,
            maximumActionOccurrences: 1
        )!,
        layout: LayoutLimits(
            maximumScopes: 2,
            maximumDepth: 2,
            maximumTextScalars: 2,
            maximumTextLines: 2,
            maximumPositionedGlyphs: 2
        )!,
        render: RenderLimits(
            maximumOperations: 2,
            maximumPositionedGlyphs: 2,
            maximumClipDepth: 2
        )!,
        renderWorkspace: RenderWorkspaceCapacity(
            maximumSemanticScopes: 2,
            maximumLayoutScopes: 2,
            maximumTraversalDepth: 2,
            maximumTextLines: 2
        )!,
        renderSink: RenderSinkCapacity(maximumOperations: 2, maximumPositionedGlyphs: 2),
        maximumOrdinaryRenderOperations: 1,
        execution: ExecutionLimits(
            maximumInputEvents: 1,
            maximumStateChangeFacts: 1,
            maximumCompletionFacts: 0,
            maximumSemanticActions: 1,
            maximumActiveInputSources: 1,
            maximumCommittedActions: 1
        )!,
        observableState: ObservableStateLimits(
            maximumLocations: 1,
            maximumRegistrations: 1,
            maximumStagedAssociations: 1
        )!,
        interaction: InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!,
        drawing: DrawingLimits(
            maximumLineWidth: 1,
            maximumCanvasOccurrences: 1,
            maximumLivePathPoints: 1,
            maximumLivePathSubpaths: 1,
            maximumPlanStrokes: 1,
            maximumPlanPoints: 1,
            maximumPlanSubpaths: 1,
            maximumNormalizedStrokeOperations: 1
        )!,
        staticCanvas: nil,
        profile: .dynamic
    )!
}

private func byteCounts(
    semanticCandidate: UInt32 = 1,
    semanticPublished: UInt32 = 2,
    layoutCandidate: UInt32 = 3,
    renderWorkspace: UInt32 = 4,
    canvasCallable: UInt32 = 5,
    pathWorkspace: UInt32 = 6,
    drawingPlan: UInt32 = 7,
    observableLive: UInt32 = 8,
    observableCandidate: UInt32 = 9,
    interactionCandidate: UInt32 = 10,
    interactionCommitted: UInt32 = 11,
    admissionQueue: UInt32 = 12,
    sealedBatch: UInt32 = 13,
    pointerState: UInt32 = 14,
    coordinatorState: UInt32 = 15,
    failureState: UInt32 = 16
) -> RuntimeStorageByteCounts {
    RuntimeStorageByteCounts(
        semanticCandidateBytes: semanticCandidate,
        semanticPublishedBytes: semanticPublished,
        layoutCandidateBytes: layoutCandidate,
        renderWorkspaceBytes: renderWorkspace,
        canvasCallableBytes: canvasCallable,
        pathWorkspaceBytes: pathWorkspace,
        drawingPlanBytes: drawingPlan,
        observableLiveBytes: observableLive,
        observableCandidateBytes: observableCandidate,
        interactionCandidateBytes: interactionCandidate,
        interactionCommittedBytes: interactionCommitted,
        admissionQueueBytes: admissionQueue,
        sealedBatchBytes: sealedBatch,
        pointerStateBytes: pointerState,
        coordinatorStateBytes: coordinatorState,
        failureStateBytes: failureState
    )
}

@Test
func checkedAuditPreservesEveryExclusiveFieldAndExactTotal() {
    let result = RuntimeStorageAudit.checked(
        profile: .dynamic,
        limits: makeAuditLimits(),
        byteCounts: byteCounts()
    )

    guard case .valid(let audit) = result else {
        Issue.record("expected a valid audit")
        return
    }
    #expect(audit.profile == .dynamic)
    #expect(audit.semanticCandidateBytes == 1)
    #expect(audit.semanticPublishedBytes == 2)
    #expect(audit.layoutCandidateBytes == 3)
    #expect(audit.renderWorkspaceBytes == 4)
    #expect(audit.canvasCallableBytes == 5)
    #expect(audit.pathWorkspaceBytes == 6)
    #expect(audit.drawingPlanBytes == 7)
    #expect(audit.observableLiveBytes == 8)
    #expect(audit.observableCandidateBytes == 9)
    #expect(audit.interactionCandidateBytes == 10)
    #expect(audit.interactionCommittedBytes == 11)
    #expect(audit.admissionQueueBytes == 12)
    #expect(audit.sealedBatchBytes == 13)
    #expect(audit.pointerStateBytes == 14)
    #expect(audit.coordinatorStateBytes == 15)
    #expect(audit.failureStateBytes == 16)
    #expect(audit.totalProfileBytes == 136)
}

@Test
func checkedAuditReturnsArithmeticOverflowWithoutSaturation() {
    let result = RuntimeStorageAudit.checked(
        profile: .dynamic,
        limits: makeAuditLimits(),
        byteCounts: byteCounts(semanticCandidate: .max, semanticPublished: 1)
    )

    #expect(result == .invalid(.arithmeticOverflow))
}

@Test
func zeroByteOverlayAliasIsRepresentedOnlyByItsChargedOwner() {
    let result = RuntimeStorageAudit.checked(
        profile: .dynamic,
        limits: makeAuditLimits(),
        byteCounts: byteCounts(layoutCandidate: 0, renderWorkspace: 64)
    )

    guard case .valid(let audit) = result else {
        Issue.record("expected a valid charged-overlay audit")
        return
    }
    #expect(audit.layoutCandidateBytes == 0)
    #expect(audit.renderWorkspaceBytes == 64)
    #expect(audit.totalProfileBytes == 193)
}
