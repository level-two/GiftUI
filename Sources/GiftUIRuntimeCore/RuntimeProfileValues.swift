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
        guard semantic.maximumActionOccurrences <= interaction.maximumActions,
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
