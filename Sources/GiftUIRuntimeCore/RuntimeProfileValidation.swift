import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUISemanticCore

package struct RuntimeProfileLimitInputs: Sendable {
    package let semantic: SemanticExpansionLimits?
    package let layout: LayoutLimits?
    package let render: RenderLimits?
    package let renderWorkspace: RenderWorkspaceCapacity?
    package let renderSink: RenderSinkCapacity
    package let maximumOrdinaryRenderOperations: UInt16
    package let execution: ExecutionLimits?
    package let observableState: ObservableStateLimits?
    package let interaction: InteractionLimits?
    package let drawing: DrawingLimits?
    package let staticCanvas: StaticCanvasLimits?
    package let profile: RuntimeProfileKind

    package init(
        semantic: SemanticExpansionLimits?,
        layout: LayoutLimits?,
        render: RenderLimits?,
        renderWorkspace: RenderWorkspaceCapacity?,
        renderSink: RenderSinkCapacity,
        maximumOrdinaryRenderOperations: UInt16,
        execution: ExecutionLimits?,
        observableState: ObservableStateLimits?,
        interaction: InteractionLimits?,
        drawing: DrawingLimits?,
        staticCanvas: StaticCanvasLimits?,
        profile: RuntimeProfileKind
    ) {
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
        self.profile = profile
    }
}

package struct RuntimeStorageCapacities: Sendable {
    package let semanticCandidate: SemanticExpansionLimits?
    package let semanticPublished: SemanticExpansionLimits?
    package let layoutCandidate: LayoutLimits?
    package let render: RenderLimits?
    package let renderWorkspace: RenderWorkspaceCapacity?
    package let canvasCallableOccurrences: UInt16?
    package let staticCanvasCaptureBytes: UInt16?
    package let pathPoints: UInt16?
    package let pathSubpaths: UInt16?
    package let drawingPlanStrokes: UInt16?
    package let drawingPlanPoints: UInt16?
    package let drawingPlanSubpaths: UInt16?
    package let normalizedStrokeOperations: UInt16?
    package let observableLiveLocations: UInt16?
    package let observableLiveRegistrations: UInt16?
    package let observableCandidateAssociations: UInt16?
    package let interactionCandidateActions: UInt16?
    package let interactionCandidateHitRegions: UInt16?
    package let interactionCommittedActions: UInt16?
    package let interactionCommittedHitRegions: UInt16?
    package let admissionQueue: ExecutionLimits?
    package let sealedBatch: ExecutionLimits?
    package let pointerStates: UInt16?
    package let coordinatorStatePresent: Bool
    package let failureStatePresent: Bool
    package let byteCounts: RuntimeStorageByteCounts?

    package init(
        semanticCandidate: SemanticExpansionLimits?,
        semanticPublished: SemanticExpansionLimits?,
        layoutCandidate: LayoutLimits?,
        render: RenderLimits?,
        renderWorkspace: RenderWorkspaceCapacity?,
        canvasCallableOccurrences: UInt16?,
        staticCanvasCaptureBytes: UInt16?,
        pathPoints: UInt16?,
        pathSubpaths: UInt16?,
        drawingPlanStrokes: UInt16?,
        drawingPlanPoints: UInt16?,
        drawingPlanSubpaths: UInt16?,
        normalizedStrokeOperations: UInt16?,
        observableLiveLocations: UInt16?,
        observableLiveRegistrations: UInt16?,
        observableCandidateAssociations: UInt16?,
        interactionCandidateActions: UInt16?,
        interactionCandidateHitRegions: UInt16?,
        interactionCommittedActions: UInt16?,
        interactionCommittedHitRegions: UInt16?,
        admissionQueue: ExecutionLimits?,
        sealedBatch: ExecutionLimits?,
        pointerStates: UInt16?,
        coordinatorStatePresent: Bool,
        failureStatePresent: Bool,
        byteCounts: RuntimeStorageByteCounts?
    ) {
        self.semanticCandidate = semanticCandidate
        self.semanticPublished = semanticPublished
        self.layoutCandidate = layoutCandidate
        self.render = render
        self.renderWorkspace = renderWorkspace
        self.canvasCallableOccurrences = canvasCallableOccurrences
        self.staticCanvasCaptureBytes = staticCanvasCaptureBytes
        self.pathPoints = pathPoints
        self.pathSubpaths = pathSubpaths
        self.drawingPlanStrokes = drawingPlanStrokes
        self.drawingPlanPoints = drawingPlanPoints
        self.drawingPlanSubpaths = drawingPlanSubpaths
        self.normalizedStrokeOperations = normalizedStrokeOperations
        self.observableLiveLocations = observableLiveLocations
        self.observableLiveRegistrations = observableLiveRegistrations
        self.observableCandidateAssociations = observableCandidateAssociations
        self.interactionCandidateActions = interactionCandidateActions
        self.interactionCandidateHitRegions = interactionCandidateHitRegions
        self.interactionCommittedActions = interactionCommittedActions
        self.interactionCommittedHitRegions = interactionCommittedHitRegions
        self.admissionQueue = admissionQueue
        self.sealedBatch = sealedBatch
        self.pointerStates = pointerStates
        self.coordinatorStatePresent = coordinatorStatePresent
        self.failureStatePresent = failureStatePresent
        self.byteCounts = byteCounts
    }
}

package protocol RuntimeStaticCanvasAuditMetadata {
    var callableCaseCount: UInt16 { get }
    var declaredEntryCount: UInt16 { get }
    var maximumDeclaredID: UInt16 { get }
    func coverageMultiplicity(for id: UInt16) -> UInt8
    func captureByteCount(for id: UInt16) -> UInt16?
}

package enum RuntimeProfileValidator {
    private enum CommonValidation {
        case valid(RuntimeProfileLimits, RuntimeStorageAudit)
        case invalid(RuntimeProfileValidationError)
    }

    package static func validateDynamic(
        inputs: RuntimeProfileLimitInputs,
        capacities: RuntimeStorageCapacities
    ) -> RuntimeProfileValidationResult {
        guard inputs.profile == .dynamic else { return .invalid(.invariantViolation) }
        switch validateCommon(inputs: inputs, capacities: capacities) {
        case .valid(_, let audit):
            return .valid(audit)
        case .invalid(let error):
            return .invalid(error)
        }
    }

    package static func validateStatic<Metadata: RuntimeStaticCanvasAuditMetadata>(
        inputs: RuntimeProfileLimitInputs,
        capacities: RuntimeStorageCapacities,
        metadata: borrowing Metadata
    ) -> RuntimeProfileValidationResult {
        guard inputs.profile == .static else { return .invalid(.invariantViolation) }
        switch validateCommon(inputs: inputs, capacities: capacities) {
        case .valid(let limits, let audit):
            guard let staticLimits = limits.staticCanvas,
                metadata.callableCaseCount > 0,
                metadata.callableCaseCount <= staticLimits.maximumStaticCallableCases,
                metadata.declaredEntryCount == metadata.callableCaseCount,
                metadata.maximumDeclaredID == metadata.callableCaseCount
            else {
                return .invalid(.staticCanvasTableInvalid)
            }
            for id in 1 ... metadata.callableCaseCount {
                guard metadata.coverageMultiplicity(for: id) == 1,
                    let captureBytes = metadata.captureByteCount(for: id),
                    captureBytes <= staticLimits.maximumStaticCaptureBytes
                else {
                    return .invalid(.staticCanvasTableInvalid)
                }
            }
            return .valid(audit)
        case .invalid(let error):
            return .invalid(error)
        }
    }

    private static func validateCommon(
        inputs: RuntimeProfileLimitInputs,
        capacities: RuntimeStorageCapacities
    ) -> CommonValidation {
        guard let semantic = inputs.semantic,
            let layout = inputs.layout,
            let render = inputs.render,
            let renderWorkspace = inputs.renderWorkspace,
            let execution = inputs.execution,
            let observableState = inputs.observableState,
            let interaction = inputs.interaction,
            let drawing = inputs.drawing
        else {
            return .invalid(.invalidLimits)
        }
        guard
            let limits = RuntimeProfileLimits(
                semantic: semantic,
                layout: layout,
                render: render,
                renderWorkspace: renderWorkspace,
                renderSink: inputs.renderSink,
                maximumOrdinaryRenderOperations: inputs.maximumOrdinaryRenderOperations,
                execution: execution,
                observableState: observableState,
                interaction: interaction,
                drawing: drawing,
                staticCanvas: inputs.staticCanvas,
                profile: inputs.profile
            )
        else {
            return .invalid(.incompatibleLimits)
        }

        guard let semanticCandidate = capacities.semanticCandidate,
            let semanticPublished = capacities.semanticPublished,
            let layoutCandidate = capacities.layoutCandidate,
            let renderCapacity = capacities.render,
            let concreteRenderWorkspace = capacities.renderWorkspace,
            let canvasCallableOccurrences = capacities.canvasCallableOccurrences,
            let pathPoints = capacities.pathPoints,
            let pathSubpaths = capacities.pathSubpaths,
            let drawingPlanStrokes = capacities.drawingPlanStrokes,
            let drawingPlanPoints = capacities.drawingPlanPoints,
            let drawingPlanSubpaths = capacities.drawingPlanSubpaths,
            let normalizedStrokeOperations = capacities.normalizedStrokeOperations,
            let observableLiveLocations = capacities.observableLiveLocations,
            let observableLiveRegistrations = capacities.observableLiveRegistrations,
            let observableCandidateAssociations = capacities.observableCandidateAssociations,
            let interactionCandidateActions = capacities.interactionCandidateActions,
            let interactionCandidateHitRegions = capacities.interactionCandidateHitRegions,
            let interactionCommittedActions = capacities.interactionCommittedActions,
            let interactionCommittedHitRegions = capacities.interactionCommittedHitRegions,
            let admissionQueue = capacities.admissionQueue,
            let sealedBatch = capacities.sealedBatch,
            let pointerStates = capacities.pointerStates,
            capacities.coordinatorStatePresent,
            capacities.failureStatePresent,
            let byteCounts = capacities.byteCounts
        else {
            return .invalid(.missingStorage)
        }
        let staticCanvasCaptureBytes: UInt16
        let requiredStaticCanvasCaptureBytes: UInt16
        if inputs.profile == .static {
            guard let configured = capacities.staticCanvasCaptureBytes,
                let staticLimits = limits.staticCanvas
            else {
                return .invalid(.missingStorage)
            }
            staticCanvasCaptureBytes = configured
            requiredStaticCanvasCaptureBytes = staticLimits.maximumStaticCaptureBytes
        } else {
            staticCanvasCaptureBytes = 0
            requiredStaticCanvasCaptureBytes = 0
        }

        guard covers(semanticCandidate, limits.semantic),
            covers(semanticPublished, limits.semantic),
            covers(layoutCandidate, limits.layout),
            covers(renderCapacity, limits.render),
            concreteRenderWorkspace == limits.renderWorkspace,
            canvasCallableOccurrences >= limits.drawing.maximumCanvasOccurrences,
            staticCanvasCaptureBytes >= requiredStaticCanvasCaptureBytes,
            pathPoints >= limits.drawing.maximumLivePathPoints,
            pathSubpaths >= limits.drawing.maximumLivePathSubpaths,
            drawingPlanStrokes >= limits.drawing.maximumPlanStrokes,
            drawingPlanPoints >= limits.drawing.maximumPlanPoints,
            drawingPlanSubpaths >= limits.drawing.maximumPlanSubpaths,
            normalizedStrokeOperations >= limits.drawing.maximumNormalizedStrokeOperations,
            observableLiveLocations >= limits.observableState.maximumLocations,
            observableLiveRegistrations >= limits.observableState.maximumRegistrations,
            observableCandidateAssociations >= limits.observableState.maximumStagedAssociations,
            interactionCandidateActions >= limits.interaction.maximumActions,
            interactionCandidateHitRegions >= limits.interaction.maximumHitRegions,
            interactionCommittedActions >= limits.interaction.maximumActions,
            interactionCommittedHitRegions >= limits.interaction.maximumHitRegions,
            covers(admissionQueue, limits.execution),
            covers(sealedBatch, limits.execution),
            pointerStates >= limits.execution.maximumActiveInputSources
        else {
            return .invalid(.insufficientStorage)
        }

        switch RuntimeStorageAudit.checked(
            profile: inputs.profile,
            limits: limits,
            byteCounts: byteCounts
        ) {
        case .valid(let audit):
            return .valid(limits, audit)
        case .invalid(let error):
            return .invalid(error)
        }
    }

    private static func covers(
        _ capacity: SemanticExpansionLimits,
        _ limits: SemanticExpansionLimits
    ) -> Bool {
        capacity.maximumDepth >= limits.maximumDepth
            && capacity.maximumSemanticNodes >= limits.maximumSemanticNodes
            && capacity.maximumBodyEvaluations >= limits.maximumBodyEvaluations
            && capacity.maximumModifierApplications >= limits.maximumModifierApplications
            && capacity.maximumActionOccurrences >= limits.maximumActionOccurrences
    }

    private static func covers(_ capacity: LayoutLimits, _ limits: LayoutLimits) -> Bool {
        capacity.maximumScopes >= limits.maximumScopes
            && capacity.maximumDepth >= limits.maximumDepth
            && capacity.maximumTextScalars >= limits.maximumTextScalars
            && capacity.maximumTextLines >= limits.maximumTextLines
            && capacity.maximumPositionedGlyphs >= limits.maximumPositionedGlyphs
    }

    private static func covers(_ capacity: RenderLimits, _ limits: RenderLimits) -> Bool {
        capacity.maximumOperations >= limits.maximumOperations
            && capacity.maximumPositionedGlyphs >= limits.maximumPositionedGlyphs
            && capacity.maximumClipDepth >= limits.maximumClipDepth
    }

    private static func covers(_ capacity: ExecutionLimits, _ limits: ExecutionLimits) -> Bool {
        capacity.maximumInputEvents >= limits.maximumInputEvents
            && capacity.maximumStateChangeFacts >= limits.maximumStateChangeFacts
            && capacity.maximumCompletionFacts >= limits.maximumCompletionFacts
            && capacity.maximumSemanticActions >= limits.maximumSemanticActions
            && capacity.maximumActiveInputSources >= limits.maximumActiveInputSources
            && capacity.maximumCommittedActions >= limits.maximumCommittedActions
    }
}
