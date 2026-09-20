import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUISemanticCore

package enum RuntimeProfileKind: UInt8, Equatable, Sendable {
    case dynamic = 0
    case `static` = 1
}

package struct RuntimeProfileLimits: Equatable, Sendable {
    package let semantic: SemanticExpansionLimits
    package let maximumSemanticStructuralOccurrences: UInt16
    package let layout: LayoutLimits
    package let render: RenderLimits
    package let renderWorkspace: RenderWorkspaceCapacity
    package let renderSink: RenderSinkCapacity
    package let maximumOrdinaryRenderOperations: UInt16
    package let execution: ExecutionLimits
    package let observableState: ObservableStateLimits
    package let interaction: InteractionLimits
    package let drawing: DrawingLimits
    package let staticCanvas: StaticCanvasLimits?

    package init?(
        semantic: SemanticExpansionLimits,
        maximumSemanticStructuralOccurrences: UInt16,
        layout: LayoutLimits,
        render: RenderLimits,
        renderWorkspace: RenderWorkspaceCapacity,
        renderSink: RenderSinkCapacity,
        maximumOrdinaryRenderOperations: UInt16,
        execution: ExecutionLimits,
        observableState: ObservableStateLimits,
        interaction: InteractionLimits,
        drawing: DrawingLimits,
        staticCanvas: StaticCanvasLimits?,
        profile: RuntimeProfileKind
    ) {
        guard maximumSemanticStructuralOccurrences > 0,
            maximumSemanticStructuralOccurrences >= semantic.maximumSemanticNodes,
            semantic.maximumActionOccurrences <= interaction.maximumActions,
            interaction.maximumActions <= execution.maximumCommittedActions,
            interaction.maximumHitRegions <= interaction.maximumActions,
            execution.maximumSemanticActions <= execution.maximumInputEvents,
            layout.maximumPositionedGlyphs <= render.maximumPositionedGlyphs,
            layout.maximumPositionedGlyphs <= renderSink.maximumPositionedGlyphs,
            layout.maximumScopes <= renderWorkspace.maximumLayoutScopes,
            layout.maximumTextLines <= renderWorkspace.maximumTextLines,
            drawing.maximumCanvasOccurrences <= semantic.maximumSemanticNodes,
            drawing.maximumCanvasOccurrences <= layout.maximumScopes,
            maximumOrdinaryRenderOperations <= render.maximumOperations,
            maximumOrdinaryRenderOperations <= renderSink.maximumOperations
        else {
            return nil
        }

        let (combinedOperations, overflow) =
            maximumOrdinaryRenderOperations.addingReportingOverflow(
                drawing.maximumNormalizedStrokeOperations
            )
        guard !overflow,
            combinedOperations <= render.maximumOperations,
            combinedOperations <= renderSink.maximumOperations
        else {
            return nil
        }

        switch (profile, staticCanvas) {
        case (.dynamic, nil), (.static, .some):
            break
        case (.dynamic, .some), (.static, nil):
            return nil
        }

        self.semantic = semantic
        self.maximumSemanticStructuralOccurrences = maximumSemanticStructuralOccurrences
        self.layout = layout
        self.render = render
        self.renderWorkspace = renderWorkspace
        self.renderSink = renderSink
        self.maximumOrdinaryRenderOperations = maximumOrdinaryRenderOperations
        self.execution = execution
        self.observableState = observableState
        self.interaction = interaction
        self.drawing = drawing
        self.staticCanvas = staticCanvas
    }
}

package struct RuntimeStorageAudit: Equatable, Sendable {
    package let profile: RuntimeProfileKind
    package let limits: RuntimeProfileLimits
    package let semanticCandidateBytes: UInt32
    package let semanticPublishedBytes: UInt32
    package let layoutCandidateBytes: UInt32
    package let renderWorkspaceBytes: UInt32
    package let canvasCallableBytes: UInt32
    package let pathWorkspaceBytes: UInt32
    package let drawingPlanBytes: UInt32
    package let observableLiveBytes: UInt32
    package let observableCandidateBytes: UInt32
    package let interactionCandidateBytes: UInt32
    package let interactionCommittedBytes: UInt32
    package let admissionQueueBytes: UInt32
    package let sealedBatchBytes: UInt32
    package let pointerStateBytes: UInt32
    package let coordinatorStateBytes: UInt32
    package let failureStateBytes: UInt32
    package let totalProfileBytes: UInt32

    private init(
        profile: RuntimeProfileKind,
        limits: RuntimeProfileLimits,
        byteCounts: RuntimeStorageByteCounts,
        totalProfileBytes: UInt32
    ) {
        self.profile = profile
        self.limits = limits
        semanticCandidateBytes = byteCounts.semanticCandidateBytes
        semanticPublishedBytes = byteCounts.semanticPublishedBytes
        layoutCandidateBytes = byteCounts.layoutCandidateBytes
        renderWorkspaceBytes = byteCounts.renderWorkspaceBytes
        canvasCallableBytes = byteCounts.canvasCallableBytes
        pathWorkspaceBytes = byteCounts.pathWorkspaceBytes
        drawingPlanBytes = byteCounts.drawingPlanBytes
        observableLiveBytes = byteCounts.observableLiveBytes
        observableCandidateBytes = byteCounts.observableCandidateBytes
        interactionCandidateBytes = byteCounts.interactionCandidateBytes
        interactionCommittedBytes = byteCounts.interactionCommittedBytes
        admissionQueueBytes = byteCounts.admissionQueueBytes
        sealedBatchBytes = byteCounts.sealedBatchBytes
        pointerStateBytes = byteCounts.pointerStateBytes
        coordinatorStateBytes = byteCounts.coordinatorStateBytes
        failureStateBytes = byteCounts.failureStateBytes
        self.totalProfileBytes = totalProfileBytes
    }

    static func checked(
        profile: RuntimeProfileKind,
        limits: RuntimeProfileLimits,
        byteCounts: RuntimeStorageByteCounts
    ) -> RuntimeProfileValidationResult {
        var total: UInt32 = 0
        guard accumulate(byteCounts.semanticCandidateBytes, into: &total),
            accumulate(byteCounts.semanticPublishedBytes, into: &total),
            accumulate(byteCounts.layoutCandidateBytes, into: &total),
            accumulate(byteCounts.renderWorkspaceBytes, into: &total),
            accumulate(byteCounts.canvasCallableBytes, into: &total),
            accumulate(byteCounts.pathWorkspaceBytes, into: &total),
            accumulate(byteCounts.drawingPlanBytes, into: &total),
            accumulate(byteCounts.observableLiveBytes, into: &total),
            accumulate(byteCounts.observableCandidateBytes, into: &total),
            accumulate(byteCounts.interactionCandidateBytes, into: &total),
            accumulate(byteCounts.interactionCommittedBytes, into: &total),
            accumulate(byteCounts.admissionQueueBytes, into: &total),
            accumulate(byteCounts.sealedBatchBytes, into: &total),
            accumulate(byteCounts.pointerStateBytes, into: &total),
            accumulate(byteCounts.coordinatorStateBytes, into: &total),
            accumulate(byteCounts.failureStateBytes, into: &total)
        else {
            return .invalid(.arithmeticOverflow)
        }
        return .valid(
            RuntimeStorageAudit(
                profile: profile,
                limits: limits,
                byteCounts: byteCounts,
                totalProfileBytes: total
            )
        )
    }

    private static func accumulate(_ value: UInt32, into total: inout UInt32) -> Bool {
        let (next, overflow) = total.addingReportingOverflow(value)
        guard !overflow else { return false }
        total = next
        return true
    }
}

package struct RuntimeStorageByteCounts: Equatable, Sendable {
    package let semanticCandidateBytes: UInt32
    package let semanticPublishedBytes: UInt32
    package let layoutCandidateBytes: UInt32
    package let renderWorkspaceBytes: UInt32
    package let canvasCallableBytes: UInt32
    package let pathWorkspaceBytes: UInt32
    package let drawingPlanBytes: UInt32
    package let observableLiveBytes: UInt32
    package let observableCandidateBytes: UInt32
    package let interactionCandidateBytes: UInt32
    package let interactionCommittedBytes: UInt32
    package let admissionQueueBytes: UInt32
    package let sealedBatchBytes: UInt32
    package let pointerStateBytes: UInt32
    package let coordinatorStateBytes: UInt32
    package let failureStateBytes: UInt32

    package init(
        semanticCandidateBytes: UInt32,
        semanticPublishedBytes: UInt32,
        layoutCandidateBytes: UInt32,
        renderWorkspaceBytes: UInt32,
        canvasCallableBytes: UInt32,
        pathWorkspaceBytes: UInt32,
        drawingPlanBytes: UInt32,
        observableLiveBytes: UInt32,
        observableCandidateBytes: UInt32,
        interactionCandidateBytes: UInt32,
        interactionCommittedBytes: UInt32,
        admissionQueueBytes: UInt32,
        sealedBatchBytes: UInt32,
        pointerStateBytes: UInt32,
        coordinatorStateBytes: UInt32,
        failureStateBytes: UInt32
    ) {
        self.semanticCandidateBytes = semanticCandidateBytes
        self.semanticPublishedBytes = semanticPublishedBytes
        self.layoutCandidateBytes = layoutCandidateBytes
        self.renderWorkspaceBytes = renderWorkspaceBytes
        self.canvasCallableBytes = canvasCallableBytes
        self.pathWorkspaceBytes = pathWorkspaceBytes
        self.drawingPlanBytes = drawingPlanBytes
        self.observableLiveBytes = observableLiveBytes
        self.observableCandidateBytes = observableCandidateBytes
        self.interactionCandidateBytes = interactionCandidateBytes
        self.interactionCommittedBytes = interactionCommittedBytes
        self.admissionQueueBytes = admissionQueueBytes
        self.sealedBatchBytes = sealedBatchBytes
        self.pointerStateBytes = pointerStateBytes
        self.coordinatorStateBytes = coordinatorStateBytes
        self.failureStateBytes = failureStateBytes
    }
}

package enum RuntimeProfileValidationError: UInt8, Equatable, Sendable {
    case invalidLimits = 0
    case incompatibleLimits = 1
    case missingStorage = 2
    case insufficientStorage = 3
    case arithmeticOverflow = 4
    case staticCanvasTableInvalid = 5
    case invariantViolation = 6
}

package enum RuntimeProfileValidationResult: Equatable, Sendable {
    case valid(RuntimeStorageAudit)
    case invalid(RuntimeProfileValidationError)
}
