import GiftUI
import GiftUIBackendIntegration
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import GiftUISemanticCore
import GiftUITextResources
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
    case runtime(RuntimeOwnerFailure)
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
    case rejected(SignalAnalyzerRuntimeCondition, mutationApplied: Bool)
    case unavailable(mutationApplied: Bool)
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
    private(set) var candidateIsActive = false
    private(set) var candidateDiscardCount: UInt16 = 0
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
        let result = base.beginCandidate()
        if result == .success(.candidateStarted) { candidateIsActive = true }
        return result
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
        let result = base.finishCandidate(disposition)
        if case .success = result {
            candidateIsActive = false
            if disposition == .discard, candidateDiscardCount < UInt16.max {
                candidateDiscardCount += 1
            }
        }
        return result
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
package struct DynamicSignalAnalyzerPresentationPipeline<Metrics: CanonicalTextMetricsView> {
    private let textMetrics: Metrics
    private let lineHeight: GeometryScalar
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
    private var layoutSink: ResolvedRenderLayoutResultSink<DynamicResolvedLayoutStorage>
    private var drawingWorkspace: DynamicDrawingPlanWorkspace
    private var renderWorkspace: DynamicRenderWorkspace
    private var interaction: DynamicInteractionState<DynamicSemanticIdentity>
    private var actionGenerations: RuntimeActionGenerationAllocator<DynamicSemanticIdentity>
    private var interactionCaptures: DynamicSignalAnalyzerInteractionCaptures
    package private(set) var lastFailureCleanupActions: RuntimeCleanupActions = []
    package var observableCandidateDiscardCount: UInt16 { reconciler.candidateDiscardCount }

    package init?(
        textMetrics: Metrics,
        limits: RuntimeProfileLimits,
        maximumRecordedTraversalIdentities: UInt16,
        logicalWidth: UInt16,
        logicalHeight: UInt16
    ) {
        guard let instance = textMetrics.instance(at: 0),
            instance.id.resource == textMetrics.descriptor.resource,
            instance.id.instanceIndex == 0,
            let lineHeight = GeometryArithmetic.add(
                instance.lineMetrics.ascent, instance.lineMetrics.descent),
            lineHeight > 0,
            maximumRecordedTraversalIdentities >= limits.maximumSemanticStructuralOccurrences,
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
        self.textMetrics = textMetrics
        self.lineHeight = lineHeight
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

    private var attemptSemantic: SemanticExpansionSummary?
    private var attemptLayout: LayoutSummary?
    private var attemptDrawing: DrawingPlanSummary?
    private var attemptRender: RenderPlanHeader?
    private var attemptInteractionOccurrenceCount: UInt16 = 0

    package var applicationIsDirty: Bool { root.isDirty }

    package mutating func prepareAttempt() {
        lastFailureCleanupActions = []
        attemptSemantic = nil
        attemptLayout = nil
        attemptDrawing = nil
        attemptRender = nil
        attemptInteractionOccurrenceCount = 0
    }

    package var preparedSummary: DynamicSignalAnalyzerPresentationSummary? {
        guard let semantic = attemptSemantic, let layout = attemptLayout,
            let drawing = attemptDrawing, let render = attemptRender
        else { return nil }
        return DynamicSignalAnalyzerPresentationSummary(
            semantic: semantic, retainedSemanticIdentities: semanticStorage.semanticScopeCount,
            recordedTraversalIdentities: semanticWorkspace.recordedIdentityCount,
            layout: layout, drawing: drawing, render: render,
            interactionOccurrenceCount: attemptInteractionOccurrenceCount)
    }

    package mutating func expandSemantics(
        model: SignalAnalyzerViewModel,
        injectingFailure: DynamicSignalAnalyzerPresentationFailure? = nil
    ) -> DynamicSignalAnalyzerPresentationFailure? {
        prepareAttempt()
        drawingWorkspace.reset()
        var completed = false
        defer {
            if !completed {
                cleanupFailedDerivation(
                    stage: .observableBindingOrSemanticExpansion,
                    acquired: [
                        .releaseCanvasCallable, .discardSemanticCandidate,
                        .discardObservableCandidate, .resetAttemptStorage,
                    ])
            }
        }
        if case .observable(let error) = injectingFailure {
            return .observable(error)
        }
        switch reconciler.beginCandidate() {
        case .success(.candidateStarted): break
        case .failure(let error): return .observable(error)
        case .success: return .invariantViolation
        }
        var binding = ObservableStateBindingDecorator(reconciler: reconciler)
        let semanticResult = expandSemanticTreeWithStateBinding(
            SignalAnalyzerView(
                viewModel: model,
                layout: SignalAnalyzerLayoutConstraints(
                    width: surfaceBounds.size.width, height: surfaceBounds.size.height,
                    lineHeight: lineHeight
                )
            ),
            limits: limits.semantic,
            workspace: &semanticWorkspace,
            sink: &semanticStorage,
            stateBinding: &binding
        )
        reconciler = binding.reconciler
        switch semanticResult {
        case .success(let summary):
            attemptSemantic = summary
        case .semanticFailure(let error):
            return .semantic(error)
        case .bindingFailure(let error):
            return .observable(error)
        }
        if case .semantic(let error) = injectingFailure {
            return .semantic(error)
        }
        completed = true
        return nil
    }

    package mutating func resolveLayout(
        injectingFailure: DynamicSignalAnalyzerPresentationFailure? = nil
    ) -> DynamicSignalAnalyzerPresentationFailure? {
        if case .layout(let error) = injectingFailure { return .layout(error) }
        let layoutResult = layout(
            semantic: semanticStorage,
            metrics: textMetrics,
            proposal: proposal,
            limits: limits.layout,
            workspace: &layoutWorkspace,
            sink: &layoutSink
        )
        switch layoutResult {
        case .success(let summary):
            attemptLayout = summary
        case .failure(let error):
            return .layout(error)
        }

        return nil
    }

    package mutating func invokeCanvases(
        cycle: RunCycleID, semanticRevision: SemanticRevision,
        injectingFailure: DynamicSignalAnalyzerPresentationFailure? = nil
    ) -> DynamicSignalAnalyzerPresentationFailure? {
        if case .drawing(let error) = injectingFailure { return .drawing(error) }
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
        // The Drawing owner releases every callable on success or failure.
        switch drawingResult {
        case .success(let summary):
            attemptDrawing = summary
        case .failure(let error):
            return .drawing(error)
        }

        return nil
    }

    package mutating func preflightRender(
        injectingFailure: DynamicSignalAnalyzerPresentationFailure? = nil
    ) -> DynamicSignalAnalyzerPresentationFailure? {
        if case .render(let error) = injectingFailure { return .render(error) }
        let renderResult = CanvasRenderProducer.preflight(
            semantic: semanticStorage.renderView,
            layout: layoutSink.renderView,
            textMetrics: textMetrics,
            drawingPlan: drawingWorkspace,
            surfaceBounds: surfaceBounds,
            damageMode: .initializeCompleteSurface,
            rootForeground: .white,
            limits: limits.render,
            configuredSinkCapacity: limits.renderSink,
            workspace: &renderWorkspace
        )
        switch renderResult {
        case .success(let header):
            attemptRender = header
        case .failure(let error):
            return .render(error)
        }

        return nil
    }

    package mutating func buildInteraction(
        injectingFailure: DynamicSignalAnalyzerPresentationFailure? = nil
    ) -> DynamicSignalAnalyzerPresentationFailure? {
        if case .interaction(let error) = injectingFailure {
            return .interaction(error)
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
            return .interaction(.missingModelTarget)
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
            return .interaction(error)
        case .ownerFailure(let failure):
            return .runtime(failure)
        case .executionFailure(let error):
            return .execution(error)
        }
        attemptInteractionOccurrenceCount = occurrences.interactionOccurrenceCount
        return nil
    }

    package mutating func publishObservableCandidate() -> DynamicSignalAnalyzerPresentationFailure?
    {
        guard case .success = reconciler.finishCandidate(.publish) else {
            return .observable(.invariantViolation)
        }
        return nil
    }

    package func freezeApplicationMutation() { root.setExecutionPhase(.deriving) }
    package func finalizeApplicationOpportunity() { root.setExecutionPhase(.idle) }

    /// Explicit recording-harness helper; live opportunities use the common runner.
    package mutating func derive(
        model: SignalAnalyzerViewModel, cycle: RunCycleID,
        semanticRevision: SemanticRevision,
        injectingFailure: DynamicSignalAnalyzerPresentationFailure? = nil
    ) -> DynamicSignalAnalyzerPresentationResult {
        var stage = RuntimeCoordinatorStage.observableBindingOrSemanticExpansion
        var acquired: RuntimeCleanupActions = []
        var completed = false
        defer { if !completed { cleanupFailedDerivation(stage: stage, acquired: acquired) } }
        if let failure = expandSemantics(model: model, injectingFailure: injectingFailure) {
            return .failure(failure)
        }
        acquired = [
            .discardObservableCandidate, .discardSemanticCandidate,
            .releaseCanvasCallable, .resetAttemptStorage,
        ]
        stage = .layout
        acquired.insert(.resetLayoutCandidate)
        if let failure = resolveLayout(injectingFailure: injectingFailure) {
            return .failure(failure)
        }
        stage = .canvasInvocationOrPlan
        acquired.insert(.resetDrawingPlan)
        if let failure = invokeCanvases(
            cycle: cycle, semanticRevision: semanticRevision,
            injectingFailure: injectingFailure)
        {
            return .failure(failure)
        }
        acquired.remove(.releaseCanvasCallable)
        stage = .combinedRenderPreflight
        acquired.insert(.resetRenderWorkspace)
        if let failure = preflightRender(injectingFailure: injectingFailure) {
            return .failure(failure)
        }
        stage = .interactionBuildOrGeneration
        if let failure = buildInteraction(injectingFailure: injectingFailure) {
            return .failure(failure)
        }
        acquired.insert(.discardInteractionCandidate)
        if let failure = publishObservableCandidate() { return .failure(failure) }
        guard let summary = preparedSummary else { return .failure(.invariantViolation) }
        completed = true
        return .success(summary)
    }

    private mutating func cleanupFailedDerivation(
        stage: RuntimeCoordinatorStage, acquired: RuntimeCleanupActions
    ) {
        var remaining = acquired
        if !reconciler.candidateIsActive { remaining.remove(.discardObservableCandidate) }
        var tracker = RuntimeCleanupTracker(
            plan: RuntimeCoordinatorCleanupOracle.plan(after: stage), acquired: remaining
        )
        while let action = tracker.takeNext() {
            cleanup(action)
        }
    }

    package func applySealedFacts(
        from admission: DynamicSignalAnalyzerHostFactAdmission
    ) -> DynamicSignalAnalyzerFactApplicationResult {
        guard root.isActive else { return .unavailable(mutationApplied: false) }
        root.setExecutionPhase(.mutating)
        defer { root.setExecutionPhase(.idle) }

        var mutationApplied = false
        var factCount: UInt16 = 0
        var changed = false
        while let (_, _, fact) = admission.takeNextSealed() {
            let nextCount = factCount.addingReportingOverflow(1)
            guard !nextCount.overflow else { return .unavailable(mutationApplied: mutationApplied) }
            factCount = nextCount.partialValue
            guard let application = root.withModel({ model in model.apply(fact) }) else {
                return .unavailable(mutationApplied: mutationApplied)
            }
            switch application {
            case .applied(let factChanged):
                mutationApplied = true
                changed = changed || factChanged
            case .rejected(let condition):
                return .rejected(condition, mutationApplied: mutationApplied)
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
                textMetrics: textMetrics,
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

extension DynamicSignalAnalyzerPresentationPipeline {
    package mutating func cleanup(_ action: RuntimeCleanupAction) {
        lastFailureCleanupActions.insert(RuntimeCleanupActions(rawValue: 1 << action.rawValue))
        switch action {
        case .releaseCanvasCallable:
            var index: UInt16 = 0
            while index < semanticStorage.canvasOccurrenceCount {
                if let identity = semanticStorage.canvasIdentity(at: index) {
                    semanticStorage.releaseCanvas(at: identity)
                }
                index += 1
            }
        case .discardInteractionCandidate:
            interaction.resolveCandidate(.discard)
            actionGenerations.resolveCandidate(committed: false)
        case .resetRenderWorkspace: renderWorkspace.reset()
        case .resetDrawingPlan: drawingWorkspace.reset()
        case .resetLayoutCandidate: layoutSink.discard()
        case .discardSemanticCandidate: semanticStorage.discardExpansion()
        case .discardObservableCandidate:
            if reconciler.candidateIsActive { _ = reconciler.finishCandidate(.discard) }
        case .resetAttemptStorage: semanticWorkspace.resetExpansion()
        case .commitInteractionCandidate: break
        }
    }
}
