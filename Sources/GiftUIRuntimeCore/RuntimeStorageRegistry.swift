package enum RuntimeStorageFamily: UInt8, CaseIterable, Equatable, Sendable {
    case semanticCandidate = 0
    case semanticPublished = 1
    case layoutCandidate = 2
    case renderWorkspace = 3
    case canvasCallable = 4
    case pathWorkspace = 5
    case drawingPlan = 6
    case observableLive = 7
    case observableCandidate = 8
    case interactionCandidate = 9
    case interactionCommitted = 10
    case admissionQueue = 11
    case sealedBatch = 12
    case pointerState = 13
    case coordinatorState = 14
    case failureState = 15

    package var isAttemptLocal: Bool {
        switch self {
        case .semanticCandidate, .layoutCandidate, .renderWorkspace, .canvasCallable,
            .pathWorkspace, .drawingPlan, .observableCandidate, .interactionCandidate:
            true
        case .semanticPublished, .observableLive, .interactionCommitted, .admissionQueue,
            .sealedBatch, .pointerState, .coordinatorState, .failureState:
            false
        }
    }
}

package enum RuntimeStorageLimit: UInt8, CaseIterable, Equatable, Sendable {
    case semanticCandidateDepth = 0
    case semanticCandidateNodes
    case semanticCandidateBodies
    case semanticCandidateModifiers
    case semanticCandidateActions
    case semanticPublishedDepth
    case semanticPublishedNodes
    case semanticPublishedBodies
    case semanticPublishedModifiers
    case semanticPublishedActions
    case layoutScopes
    case layoutDepth
    case layoutTextScalars
    case layoutTextLines
    case layoutGlyphs
    case renderOperations
    case renderGlyphs
    case renderClipDepth
    case renderSemanticScopes
    case renderLayoutScopes
    case renderTraversalDepth
    case renderTextLines
    case canvasOccurrences
    case pathPoints
    case pathSubpaths
    case drawingPlanStrokes
    case drawingPlanPoints
    case drawingPlanSubpaths
    case drawingPlanOperations
    case observableLiveLocations
    case observableLiveRegistrations
    case observableCandidateAssociations
    case interactionCandidateActions
    case interactionCandidateHitRegions
    case interactionCommittedActions
    case interactionCommittedHitRegions
    case admissionInputEvents
    case admissionStateChanges
    case admissionCompletions
    case admissionSemanticActions
    case admissionActiveInputSources
    case admissionCommittedActions
    case sealedInputEvents
    case sealedStateChanges
    case sealedCompletions
    case sealedSemanticActions
    case sealedActiveInputSources
    case sealedCommittedActions
    case pointerStates
    case coordinatorState
    case failureState

    package var family: RuntimeStorageFamily {
        switch self {
        case .semanticCandidateDepth, .semanticCandidateNodes, .semanticCandidateBodies,
            .semanticCandidateModifiers, .semanticCandidateActions:
            .semanticCandidate
        case .semanticPublishedDepth, .semanticPublishedNodes, .semanticPublishedBodies,
            .semanticPublishedModifiers, .semanticPublishedActions:
            .semanticPublished
        case .layoutScopes, .layoutDepth, .layoutTextScalars, .layoutTextLines, .layoutGlyphs:
            .layoutCandidate
        case .renderOperations, .renderGlyphs, .renderClipDepth, .renderSemanticScopes,
            .renderLayoutScopes, .renderTraversalDepth, .renderTextLines:
            .renderWorkspace
        case .canvasOccurrences:
            .canvasCallable
        case .pathPoints, .pathSubpaths:
            .pathWorkspace
        case .drawingPlanStrokes, .drawingPlanPoints, .drawingPlanSubpaths,
            .drawingPlanOperations:
            .drawingPlan
        case .observableLiveLocations, .observableLiveRegistrations:
            .observableLive
        case .observableCandidateAssociations:
            .observableCandidate
        case .interactionCandidateActions, .interactionCandidateHitRegions:
            .interactionCandidate
        case .interactionCommittedActions, .interactionCommittedHitRegions:
            .interactionCommitted
        case .admissionInputEvents, .admissionStateChanges, .admissionCompletions,
            .admissionSemanticActions, .admissionActiveInputSources,
            .admissionCommittedActions:
            .admissionQueue
        case .sealedInputEvents, .sealedStateChanges, .sealedCompletions,
            .sealedSemanticActions, .sealedActiveInputSources, .sealedCommittedActions:
            .sealedBatch
        case .pointerStates:
            .pointerState
        case .coordinatorState:
            .coordinatorState
        case .failureState:
            .failureState
        }
    }

    package func capacity(in limits: RuntimeProfileLimits) -> UInt16 {
        switch self {
        case .semanticCandidateDepth, .semanticPublishedDepth:
            limits.semantic.maximumDepth
        case .semanticCandidateNodes, .semanticPublishedNodes:
            limits.semantic.maximumSemanticNodes
        case .semanticCandidateBodies, .semanticPublishedBodies:
            limits.semantic.maximumBodyEvaluations
        case .semanticCandidateModifiers, .semanticPublishedModifiers:
            limits.semantic.maximumModifierApplications
        case .semanticCandidateActions, .semanticPublishedActions:
            limits.semantic.maximumActionOccurrences
        case .layoutScopes:
            limits.layout.maximumScopes
        case .layoutDepth:
            limits.layout.maximumDepth
        case .layoutTextScalars:
            limits.layout.maximumTextScalars
        case .layoutTextLines:
            limits.layout.maximumTextLines
        case .layoutGlyphs:
            limits.layout.maximumPositionedGlyphs
        case .renderOperations:
            limits.render.maximumOperations
        case .renderGlyphs:
            limits.render.maximumPositionedGlyphs
        case .renderClipDepth:
            limits.render.maximumClipDepth
        case .renderSemanticScopes:
            limits.renderWorkspace.maximumSemanticScopes
        case .renderLayoutScopes:
            limits.renderWorkspace.maximumLayoutScopes
        case .renderTraversalDepth:
            limits.renderWorkspace.maximumTraversalDepth
        case .renderTextLines:
            limits.renderWorkspace.maximumTextLines
        case .canvasOccurrences:
            limits.drawing.maximumCanvasOccurrences
        case .pathPoints:
            limits.drawing.maximumLivePathPoints
        case .pathSubpaths:
            limits.drawing.maximumLivePathSubpaths
        case .drawingPlanStrokes:
            limits.drawing.maximumPlanStrokes
        case .drawingPlanPoints:
            limits.drawing.maximumPlanPoints
        case .drawingPlanSubpaths:
            limits.drawing.maximumPlanSubpaths
        case .drawingPlanOperations:
            limits.drawing.maximumNormalizedStrokeOperations
        case .observableLiveLocations:
            limits.observableState.maximumLocations
        case .observableLiveRegistrations:
            limits.observableState.maximumRegistrations
        case .observableCandidateAssociations:
            limits.observableState.maximumStagedAssociations
        case .interactionCandidateActions, .interactionCommittedActions:
            limits.interaction.maximumActions
        case .interactionCandidateHitRegions, .interactionCommittedHitRegions:
            limits.interaction.maximumHitRegions
        case .admissionInputEvents, .sealedInputEvents:
            limits.execution.maximumInputEvents
        case .admissionStateChanges, .sealedStateChanges:
            limits.execution.maximumStateChangeFacts
        case .admissionCompletions, .sealedCompletions:
            limits.execution.maximumCompletionFacts
        case .admissionSemanticActions, .sealedSemanticActions:
            limits.execution.maximumSemanticActions
        case .admissionActiveInputSources, .sealedActiveInputSources, .pointerStates:
            limits.execution.maximumActiveInputSources
        case .admissionCommittedActions, .sealedCommittedActions:
            limits.execution.maximumCommittedActions
        case .coordinatorState, .failureState:
            1
        }
    }
}

package extension RuntimeProfileLimitInputs {
    init(validated limits: RuntimeProfileLimits, profile: RuntimeProfileKind) {
        self.init(
            semantic: limits.semantic,
            layout: limits.layout,
            render: limits.render,
            renderWorkspace: limits.renderWorkspace,
            renderSink: limits.renderSink,
            maximumOrdinaryRenderOperations: limits.maximumOrdinaryRenderOperations,
            execution: limits.execution,
            observableState: limits.observableState,
            interaction: limits.interaction,
            drawing: limits.drawing,
            staticCanvas: limits.staticCanvas,
            profile: profile
        )
    }
}

package extension RuntimeStorageCapacities {
    init(exact limits: RuntimeProfileLimits, byteCounts: RuntimeStorageByteCounts) {
        self.init(
            semanticCandidate: limits.semantic,
            semanticPublished: limits.semantic,
            layoutCandidate: limits.layout,
            render: limits.render,
            renderWorkspace: limits.renderWorkspace,
            canvasCallableOccurrences: limits.drawing.maximumCanvasOccurrences,
            staticCanvasCaptureBytes: limits.staticCanvas?.maximumStaticCaptureBytes,
            pathPoints: limits.drawing.maximumLivePathPoints,
            pathSubpaths: limits.drawing.maximumLivePathSubpaths,
            drawingPlanStrokes: limits.drawing.maximumPlanStrokes,
            drawingPlanPoints: limits.drawing.maximumPlanPoints,
            drawingPlanSubpaths: limits.drawing.maximumPlanSubpaths,
            normalizedStrokeOperations: limits.drawing.maximumNormalizedStrokeOperations,
            observableLiveLocations: limits.observableState.maximumLocations,
            observableLiveRegistrations: limits.observableState.maximumRegistrations,
            observableCandidateAssociations: limits.observableState.maximumStagedAssociations,
            interactionCandidateActions: limits.interaction.maximumActions,
            interactionCandidateHitRegions: limits.interaction.maximumHitRegions,
            interactionCommittedActions: limits.interaction.maximumActions,
            interactionCommittedHitRegions: limits.interaction.maximumHitRegions,
            admissionQueue: limits.execution,
            sealedBatch: limits.execution,
            pointerStates: limits.execution.maximumActiveInputSources,
            coordinatorStatePresent: true,
            failureStatePresent: true,
            byteCounts: byteCounts
        )
    }
}
