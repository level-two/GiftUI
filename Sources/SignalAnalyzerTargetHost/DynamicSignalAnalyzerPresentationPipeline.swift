import GiftUI
import GiftUIBackendIntegration
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIReferenceTextResources
import GiftUIRenderCore
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import GiftUISemanticCore
import SignalAnalyzerHost
import SignalAnalyzerPresentation

package struct DynamicSignalAnalyzerPresentationSummary: Equatable, Sendable {
    package let semantic: SemanticExpansionSummary
    package let retainedSemanticIdentities: UInt16
    package let recordedTraversalIdentities: UInt16
    package let layout: LayoutSummary
    package let drawing: DrawingPlanSummary
    package let render: RenderPlanHeader
    package let interactionOccurrenceCount: UInt16
}

package enum DynamicSignalAnalyzerPresentationFailure: Equatable, Sendable {
    case observable(ObservableStateError)
    case semantic(SemanticExpansionError)
    case layout(LayoutError)
    case drawing(DrawingProductionError)
    case render(RenderProductionError)
    case interaction(InteractionError)
    case execution(ExecutionError)
    case invariantViolation
}

package enum DynamicSignalAnalyzerPresentationResult: Equatable, Sendable {
    case success(DynamicSignalAnalyzerPresentationSummary)
    case failure(DynamicSignalAnalyzerPresentationFailure)
}

package struct DynamicSignalAnalyzerFactApplicationSummary: Equatable, Sendable {
    package let factCount: UInt16
    package let changed: Bool
}

package enum DynamicSignalAnalyzerFactApplicationResult: Equatable, Sendable {
    case applied(DynamicSignalAnalyzerFactApplicationSummary)
    case rejected(SignalAnalyzerRuntimeCondition)
    case unavailable
}

private struct DynamicSignalAnalyzerInteractionOccurrences:
    RuntimeInteractionOccurrenceView
{
    private let values: [RuntimeInteractionOccurrence<DynamicSemanticIdentity>]

    init?(
        semantic: borrowing DynamicSemanticHostStorage,
        layout: borrowing DynamicResolvedLayoutView,
        capacity: UInt16
    ) {
        guard semantic.actionOccurrenceCount <= capacity else { return nil }
        var values: [RuntimeInteractionOccurrence<DynamicSemanticIdentity>] = []
        values.reserveCapacity(Int(capacity))
        var index: UInt16 = 0
        while index < semantic.actionOccurrenceCount {
            guard let action = semantic.action(at: index),
                let layoutIdentity = semantic.layoutIdentity(for: action.identity),
                let bounds = layout.bounds(of: layoutIdentity),
                let clip = layout.clip(of: layoutIdentity)
            else { return nil }
            values.append(
                RuntimeInteractionOccurrence(
                    identity: action.identity,
                    isEnabled: semantic.isActionEnabled(at: action.identity),
                    bounds: bounds,
                    clip: clip,
                    paintOrder: index,
                    action: action.action
                )
            )
            index += 1
        }
        self.values = values
    }

    var interactionOccurrenceCount: UInt16 { UInt16(values.count) }

    borrowing func interactionOccurrence(
        at index: UInt16
    ) -> RuntimeInteractionOccurrence<DynamicSemanticIdentity>? {
        guard Int(index) < values.count else { return nil }
        return values[Int(index)]
    }
}

private struct DynamicSignalAnalyzerObservableReconciler:
    ObservableStateReconciler, ObservableStateTargetView
{
    typealias StructuralIdentity = DynamicSemanticIdentity

    private var base:
        DynamicObservableStateReconciler<
            SignalAnalyzerViewModel,
            DynamicSemanticIdentity
        >
    private(set) var candidateTarget: (identity: DynamicSemanticIdentity, ordinal: UInt16)?

    init(
        base: DynamicObservableStateReconciler<
            SignalAnalyzerViewModel,
            DynamicSemanticIdentity
        >
    ) {
        self.base = base
    }

    mutating func beginCandidate() -> ObservableStateResult {
        candidateTarget = nil
        return base.beginCandidate()
    }

    mutating func encounter<Model: _GiftUIObservableReference>(
        structuralIdentity: DynamicSemanticIdentity,
        declarationOrdinal: UInt16,
        state: inout State<Model>
    ) -> ObservableStateResult {
        let result = base.encounter(
            structuralIdentity: structuralIdentity,
            declarationOrdinal: declarationOrdinal,
            state: &state
        )
        switch result {
        case .success(.materialized), .success(.preserved):
            let target = (structuralIdentity, declarationOrdinal)
            guard
                candidateTarget == nil
                    || (candidateTarget!.identity == target.0
                        && candidateTarget!.ordinal == target.1)
            else { return .failure(.invariantViolation) }
            candidateTarget = target
        case .success, .failure:
            break
        }
        return result
    }

    mutating func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> ObservableStateResult {
        base.finishCandidate(disposition)
    }

    borrowing func targetGeneration(
        structuralIdentity: DynamicSemanticIdentity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        base.targetGeneration(
            structuralIdentity: structuralIdentity,
            declarationOrdinal: declarationOrdinal
        )
    }

    borrowing func publishableTargetGeneration(
        structuralIdentity: DynamicSemanticIdentity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        base.publishableTargetGeneration(
            structuralIdentity: structuralIdentity,
            declarationOrdinal: declarationOrdinal
        )
    }
}

private struct DynamicSignalAnalyzerInteractionCaptures:
    RuntimeInteractionCaptureCancellation
{
    private var capture = PointerActionCapture<DynamicSemanticIdentity>()

    mutating func cancelAllInteractionCaptures() {
        capture.cancel()
    }
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
    private var reconciler: DynamicSignalAnalyzerObservableReconciler
    private var semanticWorkspace: DynamicSemanticExpansionWorkspace
    private var semanticStorage: DynamicSemanticHostStorage
    private var layoutWorkspace: DynamicLayoutWorkspace
    private var layoutValidationWorkspace: DynamicLayoutWorkspace
    private var layoutSink: ResolvedRenderLayoutResultSink<DynamicResolvedLayoutStorage>
    private var drawingWorkspace: DynamicDrawingPlanWorkspace
    private var renderWorkspace: DynamicRenderWorkspace
    private var interaction: DynamicInteractionState<DynamicSemanticIdentity>
    private var actionGenerations: RuntimeActionGenerationAllocator<DynamicSemanticIdentity>
    private var interactionCaptures: DynamicSignalAnalyzerInteractionCaptures

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
        reconciler = DynamicSignalAnalyzerObservableReconciler(
            base: DynamicObservableStateReconciler(root: root)
        )
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
        interaction = DynamicInteractionState(
            candidateRecords: DynamicInteractionCandidateStorage(
                capacity: limits.interaction.maximumActions
            ),
            candidateHitRegions: DynamicInteractionHitStorage(
                capacity: limits.interaction.maximumHitRegions
            ),
            candidateCommittedRecords: DynamicInteractionCommittedStorage(
                capacity: limits.interaction.maximumActions
            ),
            committedRecords: DynamicInteractionCommittedStorage(
                capacity: limits.interaction.maximumActions
            ),
            committedHitRegions: DynamicInteractionHitStorage(
                capacity: limits.interaction.maximumHitRegions
            )
        )
        actionGenerations = RuntimeActionGenerationAllocator()
        interactionCaptures = DynamicSignalAnalyzerInteractionCaptures()
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
        reconciler = binding.reconciler
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

        let layoutView = layoutSink.renderView
        guard
            let occurrences = DynamicSignalAnalyzerInteractionOccurrences(
                semantic: semanticStorage,
                layout: layoutView,
                capacity: limits.interaction.maximumActions
            ),
            let observableTarget = publishableObservableTarget()
        else {
            _ = reconciler.finishCandidate(.discard)
            return .failure(.interaction(.missingModelTarget))
        }
        switch RuntimeInteractionCandidateTransaction.build(
            occurrences: occurrences,
            limits: limits.interaction,
            rootIdentity: observableTarget.identity,
            rootStateOrdinal: observableTarget.ordinal,
            interaction: &interaction,
            observable: &reconciler,
            generations: &actionGenerations,
            captures: &interactionCaptures
        ) {
        case .ready:
            break
        case .ownerFailure(.interaction(let error)):
            return .failure(.interaction(error))
        case .ownerFailure:
            return .failure(.invariantViolation)
        case .executionFailure(let error):
            return .failure(.execution(error))
        }
        guard case .success = reconciler.finishCandidate(.publish) else {
            interaction.resolveCandidate(.discard)
            actionGenerations.resolveCandidate(committed: false)
            _ = reconciler.finishCandidate(.discard)
            return .failure(.invariantViolation)
        }

        return .success(
            DynamicSignalAnalyzerPresentationSummary(
                semantic: semantic,
                retainedSemanticIdentities: semanticStorage.semanticScopeCount,
                recordedTraversalIdentities: semanticWorkspace.recordedIdentityCount,
                layout: layoutSummary,
                drawing: drawing,
                render: render,
                interactionOccurrenceCount: occurrences.interactionOccurrenceCount
            )
        )
    }

    package func applySealedFacts(
        from admission: DynamicSignalAnalyzerHostFactAdmission
    ) -> DynamicSignalAnalyzerFactApplicationResult {
        guard root.isActive else { return .unavailable }
        root.setExecutionPhase(.mutating)
        defer { root.setExecutionPhase(.idle) }

        var factCount: UInt16 = 0
        var changed = false
        while let (_, _, fact) = admission.takeNextSealed() {
            let nextCount = factCount.addingReportingOverflow(1)
            guard !nextCount.overflow else { return .unavailable }
            factCount = nextCount.partialValue
            guard let application = root.withModel({ model in model.apply(fact) }) else {
                return .unavailable
            }
            switch application {
            case .applied(let factChanged):
                changed = changed || factChanged
            case .rejected(let condition):
                return .rejected(condition)
            }
        }
        return .applied(
            DynamicSignalAnalyzerFactApplicationSummary(
                factCount: factCount,
                changed: changed
            )
        )
    }

    package func beginApplicationMutation() -> Bool {
        guard root.isActive else { return false }
        root.setExecutionPhase(.mutating)
        return true
    }

    package func endApplicationMutation() -> Bool? {
        guard root.isActive else { return nil }
        let changed = root.isDirty
        root.setExecutionPhase(.idle)
        return changed
    }

    package mutating func resolveInteraction(
        offer: FrameOfferResult,
        presentationRevision: PresentationRevision
    ) -> RuntimeInteractionCandidateResolution {
        RuntimeInteractionCandidateTransaction.resolve(
            offer: offer,
            presentationRevision: presentationRevision,
            interaction: &interaction,
            generations: &actionGenerations
        )
    }

    package mutating func offer<Endpoint: RasterBackendEndpoint>(
        endpoint: inout Endpoint,
        provenance: FrameProvenance,
        expectedHeader: RenderPlanHeader
    ) -> FrameOfferResult where Endpoint.Sink: RasterOfferSessionSink {
        endpoint.offer(provenance: provenance) { sink in
            switch CanvasRenderProducer.produce(
                semantic: semanticStorage.renderView,
                layout: layoutSink.renderView,
                textMetrics: GiftUIReferenceTextResources.targetPackage.metrics,
                drawingPlan: drawingWorkspace,
                surfaceBounds: surfaceBounds,
                damageMode: .initializeCompleteSurface,
                rootForeground: .white,
                limits: limits.render,
                expectedHeader: expectedHeader,
                workspace: &renderWorkspace,
                sink: &sink
            ) {
            case .success(let header):
                return header == expectedHeader ? .complete : .contractViolation
            case .failure(let error):
                sink.retainProducerError(error)
                switch error {
                case .capacityExhausted: return .insufficientCapacity
                case .sinkRefused: return .endpointRefused
                default: return .producerFailed
                }
            }
        }
    }

    package var committedActionCount: UInt16 {
        interaction.committedRecordCount
    }

    package var committedHitRegionCount: UInt16 {
        interaction.committedHitRegionCount
    }

    package borrowing func committedAction(
        at index: UInt16
    ) -> BoundActionRecord<DynamicSemanticIdentity>? {
        interaction.committedRecord(at: index)
    }

    package borrowing func resolveDown(
        at point: Point
    ) -> PointerGestureOutcome<DynamicSemanticIdentity> {
        interaction.resolveDown(at: point)
    }

    package borrowing func resolveMove(
        _ captured: CapturedAction<DynamicSemanticIdentity>,
        at point: Point
    ) -> PointerGestureOutcome<DynamicSemanticIdentity> {
        interaction.resolveMove(captured, at: point)
    }

    package borrowing func resolveUp(
        _ captured: CapturedAction<DynamicSemanticIdentity>,
        at point: Point
    ) -> PointerGestureOutcome<DynamicSemanticIdentity> {
        interaction.resolveUp(captured, at: point)
    }

    package mutating func dispatch(
        _ captured: CapturedAction<DynamicSemanticIdentity>
    ) -> InteractionDispatchResult {
        var dispatcher = DynamicSignalAnalyzerActionDispatcher.make(
            records: interaction,
            root: root
        )
        return dispatcher.dispatch(captured)
    }

    private borrowing func publishableObservableTarget()
        -> (identity: DynamicSemanticIdentity, ordinal: UInt16)?
    {
        guard let target = reconciler.candidateTarget,
            reconciler.publishableTargetGeneration(
                structuralIdentity: target.identity,
                declarationOrdinal: target.ordinal
            ) != nil
        else { return nil }
        return target
    }
}
