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

package struct RuntimeRecordLimits: Equatable, Sendable {
    package let maximumPathEntries: UInt16
    package let maximumPathDepth: UInt16
    package let maximumPathChildFanout: UInt16
    package let maximumPayloadBytesPerBank: UInt32
    package let maximumIdentityComponentsPerKey: UInt16
    package let maximumInteractionIdentityComponents: UInt32

    package init(
        maximumPathEntries: UInt16,
        maximumPathDepth: UInt16,
        maximumPathChildFanout: UInt16,
        maximumPayloadBytesPerBank: UInt32,
        maximumIdentityComponentsPerKey: UInt16,
        maximumInteractionIdentityComponents: UInt32
    ) {
        self.maximumPathEntries = maximumPathEntries
        self.maximumPathDepth = maximumPathDepth
        self.maximumPathChildFanout = maximumPathChildFanout
        self.maximumPayloadBytesPerBank = maximumPayloadBytesPerBank
        self.maximumIdentityComponentsPerKey = maximumIdentityComponentsPerKey
        self.maximumInteractionIdentityComponents = maximumInteractionIdentityComponents
    }
}

package struct RuntimeModelLimits: Equatable, Sendable {
    package let maximumModelSlots: UInt16
    package let maximumOwningTickets: UInt16
    package let maximumFramePins: UInt16
    package let maximumModelCaptureBanks: UInt16

    package init(
        maximumModelSlots: UInt16,
        maximumOwningTickets: UInt16,
        maximumFramePins: UInt16,
        maximumModelCaptureBanks: UInt16
    ) {
        self.maximumModelSlots = maximumModelSlots
        self.maximumOwningTickets = maximumOwningTickets
        self.maximumFramePins = maximumFramePins
        self.maximumModelCaptureBanks = maximumModelCaptureBanks
    }
}

package struct RuntimeProfileLimits: Equatable, Sendable {
    package let records: RuntimeRecordLimits
    package let models: RuntimeModelLimits
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
        records: RuntimeRecordLimits,
        models: RuntimeModelLimits,
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
        guard records.maximumPathEntries > 0,
            records.maximumPathDepth > 0,
            records.maximumPathDepth <= SemanticCompleteIdentity.capacity,
            records.maximumPathChildFanout > 0,
            records.maximumIdentityComponentsPerKey >= records.maximumPathDepth,
            records.maximumIdentityComponentsPerKey <= SemanticCompleteIdentity.capacity,
            records.maximumInteractionIdentityComponents > 0,
            models.maximumModelSlots > 0,
            models.maximumOwningTickets > 0,
            models.maximumFramePins > 0,
            models.maximumModelCaptureBanks <= 1,
            maximumSemanticStructuralOccurrences > 0,
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

        self.records = records
        self.models = models
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
    package let semanticCandidatePathBytes: UInt32
    package let semanticPublishedPathBytes: UInt32
    package let semanticCandidatePayloadBytes: UInt32
    package let semanticPublishedPayloadBytes: UInt32
    package let identityMatchWorkspaceBytes: UInt32
    package let interactionCandidateIdentityBytes: UInt32
    package let interactionCommittedIdentityBytes: UInt32
    package let modelMetadataBytes: UInt32
    package let modelOwnerBytes: UInt32
    package let framePinBytes: UInt32
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
        semanticCandidatePathBytes = byteCounts.semanticCandidatePathBytes
        semanticPublishedPathBytes = byteCounts.semanticPublishedPathBytes
        semanticCandidatePayloadBytes = byteCounts.semanticCandidatePayloadBytes
        semanticPublishedPayloadBytes = byteCounts.semanticPublishedPayloadBytes
        identityMatchWorkspaceBytes = byteCounts.identityMatchWorkspaceBytes
        interactionCandidateIdentityBytes = byteCounts.interactionCandidateIdentityBytes
        interactionCommittedIdentityBytes = byteCounts.interactionCommittedIdentityBytes
        modelMetadataBytes = byteCounts.modelMetadataBytes
        modelOwnerBytes = byteCounts.modelOwnerBytes
        framePinBytes = byteCounts.framePinBytes
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
        guard accumulate(byteCounts.semanticCandidatePathBytes, into: &total),
            accumulate(byteCounts.semanticPublishedPathBytes, into: &total),
            accumulate(byteCounts.semanticCandidatePayloadBytes, into: &total),
            accumulate(byteCounts.semanticPublishedPayloadBytes, into: &total),
            accumulate(byteCounts.identityMatchWorkspaceBytes, into: &total),
            accumulate(byteCounts.interactionCandidateIdentityBytes, into: &total),
            accumulate(byteCounts.interactionCommittedIdentityBytes, into: &total),
            accumulate(byteCounts.modelMetadataBytes, into: &total),
            accumulate(byteCounts.modelOwnerBytes, into: &total),
            accumulate(byteCounts.framePinBytes, into: &total),
            accumulate(byteCounts.semanticCandidateBytes, into: &total),
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
    package let semanticCandidatePathBytes: UInt32
    package let semanticPublishedPathBytes: UInt32
    package let semanticCandidatePayloadBytes: UInt32
    package let semanticPublishedPayloadBytes: UInt32
    package let identityMatchWorkspaceBytes: UInt32
    package let interactionCandidateIdentityBytes: UInt32
    package let interactionCommittedIdentityBytes: UInt32
    package let modelMetadataBytes: UInt32
    package let modelOwnerBytes: UInt32
    package let framePinBytes: UInt32
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
        semanticCandidatePathBytes: UInt32,
        semanticPublishedPathBytes: UInt32,
        semanticCandidatePayloadBytes: UInt32,
        semanticPublishedPayloadBytes: UInt32,
        identityMatchWorkspaceBytes: UInt32,
        interactionCandidateIdentityBytes: UInt32,
        interactionCommittedIdentityBytes: UInt32,
        modelMetadataBytes: UInt32,
        modelOwnerBytes: UInt32,
        framePinBytes: UInt32,
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
        self.semanticCandidatePathBytes = semanticCandidatePathBytes
        self.semanticPublishedPathBytes = semanticPublishedPathBytes
        self.semanticCandidatePayloadBytes = semanticCandidatePayloadBytes
        self.semanticPublishedPayloadBytes = semanticPublishedPayloadBytes
        self.identityMatchWorkspaceBytes = identityMatchWorkspaceBytes
        self.interactionCandidateIdentityBytes = interactionCandidateIdentityBytes
        self.interactionCommittedIdentityBytes = interactionCommittedIdentityBytes
        self.modelMetadataBytes = modelMetadataBytes
        self.modelOwnerBytes = modelOwnerBytes
        self.framePinBytes = framePinBytes
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
