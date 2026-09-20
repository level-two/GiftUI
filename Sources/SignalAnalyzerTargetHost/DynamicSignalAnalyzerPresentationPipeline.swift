import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUILayout
import GiftUIObservableState
import GiftUIReferenceTextResources
import GiftUIRenderCore
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import GiftUISemanticCore
import SignalAnalyzerPresentation

package struct DynamicSignalAnalyzerPresentationSummary: Equatable, Sendable {
    package let semantic: SemanticExpansionSummary
    package let retainedSemanticIdentities: UInt16
    package let recordedTraversalIdentities: UInt16
    package let layout: LayoutSummary
    package let drawing: DrawingPlanSummary
    package let render: RenderPlanHeader
}

package enum DynamicSignalAnalyzerPresentationFailure: Equatable, Sendable {
    case observable(ObservableStateError)
    case semantic(SemanticExpansionError)
    case layout(LayoutError)
    case drawing(DrawingProductionError)
    case render(RenderProductionError)
    case invariantViolation
}

package enum DynamicSignalAnalyzerPresentationResult: Equatable, Sendable {
    case success(DynamicSignalAnalyzerPresentationSummary)
    case failure(DynamicSignalAnalyzerPresentationFailure)
}

/// Owns the production Dynamic semantic, layout, Drawing, and combined-render
/// workspaces used by a target host. Endpoint offer and lifecycle coordination
/// remain with the enclosing host owner.
package struct DynamicSignalAnalyzerPresentationPipeline {
    private let limits: RuntimeProfileLimits
    private let proposal: ProposedSize
    private let surfaceBounds: Rect
    private let maximumRecordedTraversalIdentities: UInt16
    private let root:
        DynamicObservableRootAdapter<
            SignalAnalyzerViewModel,
            DynamicSemanticIdentity
        >
    private var reconciler:
        DynamicObservableStateReconciler<
            SignalAnalyzerViewModel,
            DynamicSemanticIdentity
        >
    private var semanticWorkspace: DynamicSemanticExpansionWorkspace
    private var semanticStorage: DynamicSemanticHostStorage
    private var layoutWorkspace: DynamicLayoutWorkspace
    private var layoutValidationWorkspace: DynamicLayoutWorkspace
    private var layoutSink: ResolvedRenderLayoutResultSink<DynamicResolvedLayoutStorage>
    private var drawingWorkspace: DynamicDrawingPlanWorkspace
    private var renderWorkspace: DynamicRenderWorkspace

    package init?(
        limits: RuntimeProfileLimits,
        maximumRecordedTraversalIdentities: UInt16,
        logicalWidth: UInt16,
        logicalHeight: UInt16
    ) {
        guard maximumRecordedTraversalIdentities >= limits.maximumSemanticStructuralOccurrences,
            let proposal = ProposedSize(
                width: Int32(logicalWidth),
                height: Int32(logicalHeight)
            ),
            let size = Size(width: Int32(logicalWidth), height: Int32(logicalHeight)),
            let surfaceBounds = Rect(origin: Point(x: 0, y: 0), size: size)
        else { return nil }

        let root = DynamicObservableRootAdapter<
            SignalAnalyzerViewModel,
            DynamicSemanticIdentity
        >(capacity: limits.observableState.maximumLocations)
        self.limits = limits
        self.proposal = proposal
        self.surfaceBounds = surfaceBounds
        self.maximumRecordedTraversalIdentities = maximumRecordedTraversalIdentities
        self.root = root
        reconciler = DynamicObservableStateReconciler(root: root)
        semanticWorkspace = DynamicSemanticExpansionWorkspace(
            maximumPathComponents: limits.semantic.maximumDepth,
            maximumIdentities: maximumRecordedTraversalIdentities
        )
        semanticStorage = DynamicSemanticHostStorage(
            limits: limits.semantic,
            maximumStructuralOccurrences: limits.maximumSemanticStructuralOccurrences,
            canvasCapacity: limits.drawing.maximumCanvasOccurrences
        )
        layoutWorkspace = DynamicLayoutWorkspace(limits: limits.layout)
        layoutValidationWorkspace = DynamicLayoutWorkspace(limits: limits.layout)
        layoutSink = ResolvedRenderLayoutResultSink(
            storage: DynamicResolvedLayoutStorage(limits: limits.layout)
        )
        drawingWorkspace = DynamicDrawingPlanWorkspace(capacity: limits.drawing)
        renderWorkspace = DynamicRenderWorkspace(
            capacity: limits.render,
            structuralCapacity: limits.renderWorkspace
        )
    }

    package mutating func derive(
        model: SignalAnalyzerViewModel,
        cycle: RunCycleID,
        semanticRevision: SemanticRevision
    ) -> DynamicSignalAnalyzerPresentationResult {
        drawingWorkspace.reset()
        guard reconciler.beginCandidate() == .success(.candidateStarted) else {
            return .failure(.invariantViolation)
        }
        var binding = ObservableStateBindingDecorator(reconciler: reconciler)
        let semanticResult = expandSemanticTreeWithStateBinding(
            SignalAnalyzerView(viewModel: model),
            limits: limits.semantic,
            workspace: &semanticWorkspace,
            sink: &semanticStorage,
            stateBinding: &binding
        )
        let semantic: SemanticExpansionSummary
        switch semanticResult {
        case .success(let summary):
            semantic = summary
        case .semanticFailure(let error):
            _ = reconciler.finishCandidate(.discard)
            return .failure(.semantic(error))
        case .bindingFailure(let error):
            _ = reconciler.finishCandidate(.discard)
            return .failure(.observable(error))
        }
        guard case .success = reconciler.finishCandidate(.publish) else {
            return .failure(.invariantViolation)
        }

        var validation = LayoutSemanticValidation(limits: limits.layout)
        if let error = validation.validate(
            semantic: semanticStorage,
            metrics: GiftUIReferenceTextResources.targetPackage.metrics,
            workspace: &layoutValidationWorkspace
        ) {
            layoutValidationWorkspace.resetLayout()
            return .failure(.layout(error))
        }
        layoutValidationWorkspace.resetLayout()

        let layoutResult = layout(
            semantic: semanticStorage,
            metrics: GiftUIReferenceTextResources.targetPackage.metrics,
            proposal: proposal,
            limits: limits.layout,
            workspace: &layoutWorkspace,
            sink: &layoutSink
        )
        let layoutSummary: LayoutSummary
        switch layoutResult {
        case .success(let summary):
            layoutSummary = summary
        case .failure(let error):
            return .failure(.layout(error))
        }

        let drawingResult = CanvasPlanProducer.derive(
            source: &semanticStorage,
            layout: layoutSink.renderView,
            executionContext: ExecutionContext(
                cycle: cycle,
                semanticRevision: semanticRevision,
                candidateFrame: nil,
                phase: .deriving
            ),
            limits: limits.drawing,
            workspace: &drawingWorkspace
        )
        let drawing: DrawingPlanSummary
        switch drawingResult {
        case .success(let summary):
            drawing = summary
        case .failure(let error):
            return .failure(.drawing(error))
        }

        let renderResult = CanvasRenderProducer.preflight(
            semantic: semanticStorage.renderView,
            layout: layoutSink.renderView,
            textMetrics: GiftUIReferenceTextResources.targetPackage.metrics,
            drawingPlan: drawingWorkspace,
            surfaceBounds: surfaceBounds,
            damageMode: .initializeCompleteSurface,
            rootForeground: .white,
            limits: limits.render,
            configuredSinkCapacity: limits.renderSink,
            workspace: &renderWorkspace
        )
        let render: RenderPlanHeader
        switch renderResult {
        case .success(let header):
            render = header
        case .failure(let error):
            return .failure(.render(error))
        }

        return .success(
            DynamicSignalAnalyzerPresentationSummary(
                semantic: semantic,
                retainedSemanticIdentities: semanticStorage.semanticScopeCount,
                recordedTraversalIdentities: semanticWorkspace.recordedIdentityCount,
                layout: layoutSummary,
                drawing: drawing,
                render: render
            )
        )
    }
}
