import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIRuntimeCore
import GiftUISemanticCore
import Testing

private struct LimitInputs {
    var semanticNodes: UInt16 = 8
    var semanticActions: UInt16 = 2
    var layoutScopes: UInt16 = 8
    var layoutLines: UInt16 = 4
    var layoutGlyphs: UInt16 = 8
    var renderOperations: UInt16 = 8
    var renderGlyphs: UInt16 = 8
    var workspaceSemanticScopes: UInt16 = 16
    var workspaceLayoutScopes: UInt16 = 8
    var workspaceTraversalDepth: UInt16 = 8
    var workspaceTextLines: UInt16 = 4
    var sinkOperations: UInt16 = 8
    var sinkGlyphs: UInt16 = 8
    var ordinaryOperations: UInt16 = 4
    var executionInputs: UInt16 = 4
    var executionSemanticActions: UInt16 = 2
    var executionCommittedActions: UInt16 = 2
    var interactionActions: UInt16 = 2
    var interactionHitRegions: UInt16 = 2
    var canvasOccurrences: UInt16 = 2
    var normalizedStrokes: UInt16 = 4
}

private func makeLimits(
    _ inputs: LimitInputs = LimitInputs(),
    profile: RuntimeProfileKind = .dynamic,
    includeStaticCanvas: Bool = false
) -> RuntimeProfileLimits? {
    let semantic = SemanticExpansionLimits(
        maximumDepth: 8,
        maximumSemanticNodes: inputs.semanticNodes,
        maximumBodyEvaluations: 8,
        maximumModifierApplications: 8,
        maximumActionOccurrences: inputs.semanticActions
    )!
    let layout = LayoutLimits(
        maximumScopes: inputs.layoutScopes,
        maximumDepth: 8,
        maximumTextScalars: 16,
        maximumTextLines: inputs.layoutLines,
        maximumPositionedGlyphs: inputs.layoutGlyphs
    )!
    let render = RenderLimits(
        maximumOperations: inputs.renderOperations,
        maximumPositionedGlyphs: inputs.renderGlyphs,
        maximumClipDepth: 8
    )!
    let renderWorkspace = RenderWorkspaceCapacity(
        maximumSemanticScopes: inputs.workspaceSemanticScopes,
        maximumLayoutScopes: inputs.workspaceLayoutScopes,
        maximumTraversalDepth: inputs.workspaceTraversalDepth,
        maximumTextLines: inputs.workspaceTextLines
    )!
    let execution = ExecutionLimits(
        maximumInputEvents: inputs.executionInputs,
        maximumStateChangeFacts: 2,
        maximumCompletionFacts: 0,
        maximumSemanticActions: inputs.executionSemanticActions,
        maximumActiveInputSources: 2,
        maximumCommittedActions: inputs.executionCommittedActions
    )!
    let interaction = InteractionLimits(
        maximumActions: inputs.interactionActions,
        maximumHitRegions: inputs.interactionHitRegions
    )!
    let drawing = DrawingLimits(
        maximumLineWidth: 8,
        maximumCanvasOccurrences: inputs.canvasOccurrences,
        maximumLivePathPoints: 8,
        maximumLivePathSubpaths: 4,
        maximumPlanStrokes: 4,
        maximumPlanPoints: 8,
        maximumPlanSubpaths: 4,
        maximumNormalizedStrokeOperations: inputs.normalizedStrokes
    )!

    return RuntimeProfileLimits(
        semantic: semantic,
        layout: layout,
        render: render,
        renderWorkspace: renderWorkspace,
        renderSink: RenderSinkCapacity(
            maximumOperations: inputs.sinkOperations,
            maximumPositionedGlyphs: inputs.sinkGlyphs
        ),
        maximumOrdinaryRenderOperations: inputs.ordinaryOperations,
        execution: execution,
        observableState: ObservableStateLimits(
            maximumLocations: 2,
            maximumRegistrations: 2,
            maximumStagedAssociations: 2
        )!,
        interaction: interaction,
        drawing: drawing,
        staticCanvas: includeStaticCanvas
            ? StaticCanvasLimits(maximumStaticCallableCases: 2, maximumStaticCaptureBytes: 16)!
            : nil,
        profile: profile
    )
}

@Test
func matchingDynamicAndStaticLimitsPreserveEveryInputValue() {
    let dynamic = makeLimits()
    let staticProfile = makeLimits(profile: .static, includeStaticCanvas: true)

    #expect(dynamic != nil)
    #expect(staticProfile != nil)
    #expect(dynamic?.semantic.maximumSemanticNodes == 8)
    #expect(dynamic?.renderWorkspace.maximumSemanticScopes == 16)
    #expect(dynamic?.renderWorkspace.maximumTraversalDepth == 8)
    #expect(dynamic?.maximumOrdinaryRenderOperations == 4)
    #expect(dynamic?.staticCanvas == nil)
    #expect(staticProfile?.staticCanvas?.maximumStaticCallableCases == 2)
}

@Test
func renderWorkspaceStructuralValuesAreNotDerivedFromSemanticLimits() {
    var inputs = LimitInputs()
    inputs.semanticNodes = 32
    inputs.workspaceSemanticScopes = 3
    inputs.workspaceTraversalDepth = 2

    let limits = makeLimits(inputs)

    #expect(limits != nil)
    #expect(limits?.renderWorkspace.maximumSemanticScopes == 3)
    #expect(limits?.renderWorkspace.maximumTraversalDepth == 2)
}

@Test
func zeroOrdinaryOperationsAreValidForDrawingOnlyFixtures() {
    var inputs = LimitInputs()
    inputs.ordinaryOperations = 0
    inputs.renderOperations = inputs.normalizedStrokes
    inputs.sinkOperations = inputs.normalizedStrokes

    #expect(makeLimits(inputs) != nil)
}

@Test(arguments: [
    "semantic-actions",
    "committed-actions",
    "execution-inputs",
    "render-glyphs",
    "sink-glyphs",
    "workspace-scopes",
    "workspace-lines",
    "semantic-canvas",
    "layout-canvas",
    "ordinary-render",
    "ordinary-sink",
    "combined-render",
    "combined-sink",
    "combined-overflow",
])
func eachCrossRelationRejectsItsFirstIncompatibleValue(relation: String) {
    var inputs = LimitInputs()
    switch relation {
    case "semantic-actions":
        inputs.semanticActions = 3
    case "committed-actions":
        inputs.executionCommittedActions = 1
    case "execution-inputs":
        inputs.executionInputs = 1
    case "render-glyphs":
        inputs.renderGlyphs = 7
    case "sink-glyphs":
        inputs.sinkGlyphs = 7
    case "workspace-scopes":
        inputs.workspaceLayoutScopes = 7
    case "workspace-lines":
        inputs.workspaceTextLines = 3
    case "semantic-canvas":
        inputs.semanticNodes = 1
    case "layout-canvas":
        inputs.layoutScopes = 1
        inputs.workspaceLayoutScopes = 1
    case "ordinary-render":
        inputs.ordinaryOperations = 9
    case "ordinary-sink":
        inputs.ordinaryOperations = 9
        inputs.renderOperations = 13
    case "combined-render":
        inputs.renderOperations = 7
    case "combined-sink":
        inputs.sinkOperations = 7
    case "combined-overflow":
        inputs.ordinaryOperations = .max
        inputs.renderOperations = .max
        inputs.sinkOperations = .max
    default:
        Issue.record("unregistered relation")
    }

    #expect(makeLimits(inputs) == nil)
}

@Test
func containedInteractionRelationRejectsMoreHitRegionsThanActions() {
    #expect(InteractionLimits(maximumActions: 1, maximumHitRegions: 2) == nil)
}

@Test
func staticCanvasPresenceMustMatchTheSelectedProfileExactly() {
    #expect(makeLimits(profile: .dynamic, includeStaticCanvas: true) == nil)
    #expect(makeLimits(profile: .static, includeStaticCanvas: false) == nil)
    #expect(makeLimits(profile: .dynamic, includeStaticCanvas: false) != nil)
    #expect(makeLimits(profile: .static, includeStaticCanvas: true) != nil)
}

@Test
func runtimeProfileValidationRawValuesRemainExact() {
    #expect(RuntimeProfileKind.dynamic.rawValue == 0)
    #expect(RuntimeProfileKind.static.rawValue == 1)
    #expect(RuntimeProfileValidationError.invalidLimits.rawValue == 0)
    #expect(RuntimeProfileValidationError.incompatibleLimits.rawValue == 1)
    #expect(RuntimeProfileValidationError.missingStorage.rawValue == 2)
    #expect(RuntimeProfileValidationError.insufficientStorage.rawValue == 3)
    #expect(RuntimeProfileValidationError.arithmeticOverflow.rawValue == 4)
    #expect(RuntimeProfileValidationError.staticCanvasTableInvalid.rawValue == 5)
    #expect(RuntimeProfileValidationError.invariantViolation.rawValue == 6)
}
