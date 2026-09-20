import GiftUI
import GiftUIBackendIntegration
import GiftUIDisplayCore
import GiftUIDrawing
import GiftUIExecution
import GiftUIFailureCore
import GiftUIHostConfiguration
import GiftUILayout
import GiftUIObservableState
import GiftUIPlatformRaspberryPi
import GiftUIRasterCore
import GiftUIReferenceTextResources
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIRuntimeDynamic
import GiftUISemanticCore
import GiftUISurfaceCore
import GiftUITextResources
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import SignalAnalyzerTargetHost
import Testing

@testable import GiftUICapabilities

private final class SemanticJoinRepository: SignalAcquisitionRepository {
    let failsStart: Bool

    init(failsStart: Bool = false) {
        self.failsStart = failsStart
    }

    func startObservingCapture(sink _: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink _: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws {
        if failsStart { throw SemanticJoinFailure.expected }
    }
    func stop() {}
    func clear() {}
}

private enum SemanticJoinFailure: Error {
    case expected
}

private struct EndpointFramebufferSink: PiScreenFramebufferSink {
    let acceptsPayload: Bool
    private(set) var payloadCount: UInt32 = 0
    private(set) var regionCount: UInt32 = 0
    private(set) var byteCount: UInt32 = 0

    init(acceptsPayload: Bool = true) {
        self.acceptsPayload = acceptsPayload
    }

    mutating func presentRGB565BigEndian(
        bytes: UnsafeRawBufferPointer,
        regions: [PiScreenPayloadRegion],
        transform: PiScreenAspectFitTransform
    ) -> Bool {
        guard transform.logicalWidth == 240, transform.logicalHeight == 240 else {
            return false
        }
        guard acceptsPayload else { return false }
        payloadCount += 1
        regionCount += UInt32(regions.count)
        byteCount += UInt32(bytes.count)
        return true
    }
}

@Test func dynamicPiEndpointFactoryStreamsTheProductionCandidate() throws {
    let preset = GeneratedSignalAnalyzerPresets.raspberryPiDynamic()
    let effective = dynamicPiEffectivePresentation(preset: preset)
    let provenance = FrameProvenance(
        cycle: RunCycleID(rawValue: 11),
        semanticRevision: SemanticRevision(rawValue: 12),
        candidateFrame: CandidateFrameID(rawValue: 13)
    )
    let layout = try #require(
        PiScreenFramebufferLayout(
            width: 480,
            height: 320,
            bitsPerPixel: 16,
            bytesPerRow: 960,
            mappedBytes: 307_200
        )
    )
    let target = try #require(
        PiScreenDisplayTarget(sink: EndpointFramebufferSink(), layout: layout)
    )
    var endpoint = try #require(
        DynamicSignalAnalyzerPiEndpointFactory.make(
            target: target,
            provenance: provenance,
            effectivePresentation: effective
        )
    )
    var pipeline = try #require(
        DynamicSignalAnalyzerPresentationPipeline(
            limits: preset.runtimeLimits,
            maximumRecordedTraversalIdentities: 203,
            logicalWidth: 240,
            logicalHeight: 240
        )
    )
    let model = makeSemanticJoinModel(failsStart: true)
    model.startTapped()
    let result = pipeline.derive(
        model: model,
        cycle: provenance.cycle,
        semanticRevision: provenance.semanticRevision
    )
    guard case .success(let summary) = result else {
        Issue.record("production presentation pipeline failed: \(result)")
        return
    }

    let offer = pipeline.offer(
        endpoint: &endpoint,
        provenance: provenance,
        expectedHeader: summary.render
    )
    #expect(offer == FrameOfferResult(disposition: .accepted, failure: nil)!)
    #expect(endpoint.sink.target.sink.payloadCount > 0)
    #expect(endpoint.sink.target.sink.regionCount > 0)
    #expect(endpoint.sink.target.sink.byteCount > 0)
}

@Test func dynamicPiInitialPresentationEnablesInputOnlyAfterAcceptedFrame() throws {
    let preset = GeneratedSignalAnalyzerPresets.raspberryPiDynamic()
    let provenance = FrameProvenance(
        cycle: RunCycleID(rawValue: 21),
        semanticRevision: SemanticRevision(rawValue: 22),
        candidateFrame: CandidateFrameID(rawValue: 23)
    )
    let layout = try #require(
        PiScreenFramebufferLayout(
            width: 480,
            height: 320,
            bitsPerPixel: 16,
            bytesPerRow: 960,
            mappedBytes: 307_200
        )
    )
    let target = try #require(
        PiScreenDisplayTarget(sink: EndpointFramebufferSink(), layout: layout)
    )
    var owner = try #require(
        DynamicSignalAnalyzerPiInitialPresentationOwner(
            target: target,
            limits: preset.runtimeLimits,
            maximumRecordedTraversalIdentities: 203,
            effectivePresentation: dynamicPiEffectivePresentation(preset: preset),
            provenance: provenance,
            presentationRevision: PresentationRevision(rawValue: 24)
        )
    )

    #expect(owner.state == .ready)
    #expect(!owner.inputIsEligible)
    #expect(owner.eligibleActionCount == 0)
    let model = makeSemanticJoinModel(failsStart: true)
    let result = owner.presentInitial(model: model)
    guard case .presented(let summary) = result else {
        Issue.record("initial presentation failed: \(result)")
        return
    }
    #expect(summary.interactionOccurrenceCount == 6)
    #expect(owner.state == .inputEligible)
    #expect(owner.inputIsEligible)
    #expect(owner.eligibleActionCount == 6)
    let action = try #require(
        (0 ..< owner.eligibleActionCount).compactMap { owner.eligibleAction(at: $0) }
            .first { $0.action.code == SignalAnalyzerAction.selectOneSecond.rawValue }
    )
    let point = Point(
        x: action.hitBounds.origin.x + action.hitBounds.size.width / 2,
        y: action.hitBounds.origin.y + action.hitBounds.size.height / 2
    )
    let source = InputSourceID(rawValue: 7)
    let sequence = PointerSequenceID(rawValue: 8)
    #expect(
        owner.handle(
            NormalizedPointerEvent(
                phase: .down,
                position: point,
                source: source,
                sequence: sequence,
                ordinal: InputOrdinal(rawValue: 0),
                presentationRevision: PresentationRevision(rawValue: 24)
            )
        ) == .captured
    )
    #expect(
        owner.handle(
            NormalizedPointerEvent(
                phase: .move,
                position: point,
                source: source,
                sequence: sequence,
                ordinal: InputOrdinal(rawValue: 1),
                presentationRevision: PresentationRevision(rawValue: 24)
            )
        ) == .continued
    )
    #expect(
        owner.handle(
            NormalizedPointerEvent(
                phase: .up,
                position: point,
                source: source,
                sequence: sequence,
                ordinal: InputOrdinal(rawValue: 2),
                presentationRevision: PresentationRevision(rawValue: 24)
            )
        ) == .dispatched(.dispatched)
    )
    #expect(model.state.visibleWindow == .oneSecond)
    #expect(
        owner.handle(
            NormalizedPointerEvent(
                phase: .down,
                position: point,
                source: source,
                sequence: PointerSequenceID(rawValue: 9),
                ordinal: InputOrdinal(rawValue: 0),
                presentationRevision: PresentationRevision(rawValue: 23)
            )
        ) == .rejected(.stalePresentation)
    )
    #expect(
        owner.presentInitial(model: makeSemanticJoinModel())
            == .failure(.invalidLifecycle)
    )

    owner.quiesce()
    #expect(owner.state == .quiescent)
    #expect(!owner.inputIsEligible)
    #expect(owner.eligibleActionCount == 0)
    #expect(
        owner.handle(
            NormalizedPointerEvent(
                phase: .down,
                position: point,
                source: source,
                sequence: PointerSequenceID(rawValue: 10),
                ordinal: InputOrdinal(rawValue: 0),
                presentationRevision: PresentationRevision(rawValue: 24)
            )
        ) == .rejected(.inputIneligible)
    )
}

@Test func dynamicPiInitialPresentationRefusalKeepsInputIneligible() throws {
    let preset = GeneratedSignalAnalyzerPresets.raspberryPiDynamic()
    let provenance = FrameProvenance(
        cycle: RunCycleID(rawValue: 31),
        semanticRevision: SemanticRevision(rawValue: 32),
        candidateFrame: CandidateFrameID(rawValue: 33)
    )
    let layout = try #require(
        PiScreenFramebufferLayout(
            width: 480,
            height: 320,
            bitsPerPixel: 16,
            bytesPerRow: 960,
            mappedBytes: 307_200
        )
    )
    let target = try #require(
        PiScreenDisplayTarget(
            sink: EndpointFramebufferSink(acceptsPayload: false),
            layout: layout
        )
    )
    var owner = try #require(
        DynamicSignalAnalyzerPiInitialPresentationOwner(
            target: target,
            limits: preset.runtimeLimits,
            maximumRecordedTraversalIdentities: 203,
            effectivePresentation: dynamicPiEffectivePresentation(preset: preset),
            provenance: provenance,
            presentationRevision: PresentationRevision(rawValue: 34)
        )
    )

    let result = owner.presentInitial(model: makeSemanticJoinModel(failsStart: true))
    guard case .failure(.offer(let offer)) = result else {
        Issue.record("refused presentation produced unexpected result: \(result)")
        return
    }
    #expect(offer.disposition == .failed)
    #expect(!owner.inputIsEligible)
    #expect(owner.eligibleActionCount == 0)
}

@Test func dynamicPiInputCoordinatorQueuesNormalizedSequenceUntilDrain() throws {
    let preset = GeneratedSignalAnalyzerPresets.raspberryPiDynamic()
    let revision = PresentationRevision(rawValue: 44)
    let provenance = FrameProvenance(
        cycle: RunCycleID(rawValue: 41),
        semanticRevision: SemanticRevision(rawValue: 42),
        candidateFrame: CandidateFrameID(rawValue: 43)
    )
    let layout = try #require(
        PiScreenFramebufferLayout(
            width: 480,
            height: 320,
            bitsPerPixel: 16,
            bytesPerRow: 960,
            mappedBytes: 307_200
        )
    )
    let target = try #require(
        PiScreenDisplayTarget(sink: EndpointFramebufferSink(), layout: layout)
    )
    var owner = try #require(
        DynamicSignalAnalyzerPiInitialPresentationOwner(
            target: target,
            limits: preset.runtimeLimits,
            maximumRecordedTraversalIdentities: 203,
            effectivePresentation: dynamicPiEffectivePresentation(preset: preset),
            provenance: provenance,
            presentationRevision: revision
        )
    )
    let model = makeSemanticJoinModel(failsStart: true)
    guard case .presented = owner.presentInitial(model: model) else {
        Issue.record("initial presentation did not establish input")
        return
    }
    let action = try #require(
        (0 ..< owner.eligibleActionCount).compactMap { owner.eligibleAction(at: $0) }
            .first { $0.action.code == SignalAnalyzerAction.selectOneSecond.rawValue }
    )
    let point = Point(
        x: action.hitBounds.origin.x + action.hitBounds.size.width / 2,
        y: action.hitBounds.origin.y + action.hitBounds.size.height / 2
    )
    let source = InputSourceID(rawValue: 17)
    var coordinator = DynamicSignalAnalyzerPiInputCoordinator(
        source: source,
        capacity: preset.runtimeLimits.execution.maximumInputEvents,
        context: ExecutionContext(
            cycle: provenance.cycle,
            semanticRevision: provenance.semanticRevision,
            candidateFrame: provenance.candidateFrame,
            phase: .idle
        )
    )

    #expect(
        coordinator.admit(
            phase: .down,
            position: point,
            source: source,
            observedPresentationRevision: nil
        ) == .dropped(.presentationNotEstablished)
    )
    coordinator.installPhysicalPresentation(revision)
    let down = coordinator.admit(
        phase: .down,
        position: point,
        source: source,
        observedPresentationRevision: revision
    )
    guard case .queued(let downEvent) = down else {
        Issue.record("normalized down was not queued: \(down)")
        return
    }
    let move = coordinator.admit(
        phase: .move,
        position: point,
        source: source,
        observedPresentationRevision: revision
    )
    let up = coordinator.admit(
        phase: .up,
        position: point,
        source: source,
        observedPresentationRevision: revision
    )
    guard case .queued(let moveEvent) = move, case .queued(let upEvent) = up else {
        Issue.record("normalized continuation was not queued")
        return
    }
    #expect(downEvent.ordinal.rawValue == 0)
    #expect(moveEvent.sequence == downEvent.sequence)
    #expect(moveEvent.ordinal.rawValue == 1)
    #expect(upEvent.sequence == downEvent.sequence)
    #expect(upEvent.ordinal.rawValue == 2)
    #expect(model.state.visibleWindow == .twoSeconds)

    #expect(
        coordinator.drain(into: &owner)
            == DynamicSignalAnalyzerPiInputDrainSummary(
                eventCount: 3,
                dispatchedActionCount: 1,
                cancelledOrRejectedCount: 0
            )
    )
    #expect(model.state.visibleWindow == .oneSecond)
    #expect(
        coordinator.admit(
            phase: .down,
            position: point,
            source: InputSourceID(rawValue: 18),
            observedPresentationRevision: revision
        ) == .dropped(.unknownSource)
    )
    #expect(
        coordinator.admit(
            phase: .down,
            position: point,
            source: source,
            observedPresentationRevision: PresentationRevision(rawValue: 43)
        ) == .dropped(.stalePresentation)
    )

    coordinator.quiesce()
    #expect(!coordinator.inputIsEligible)
    #expect(
        coordinator.admit(
            phase: .down,
            position: point,
            source: source,
            observedPresentationRevision: revision
        ) == .sourceQuiesced(.inputUnavailable)
    )
}

@Test func dynamicTargetHostPresentationPipelineUsesExactGeneratedLimits() throws {
    let preset = GeneratedSignalAnalyzerPresets.raspberryPiDynamic()
    var pipeline = try #require(
        DynamicSignalAnalyzerPresentationPipeline(
            limits: preset.runtimeLimits,
            maximumRecordedTraversalIdentities: 203,
            logicalWidth: preset.raster.logicalWidth,
            logicalHeight: preset.raster.logicalHeight
        )
    )
    let model = makeSemanticJoinModel(failsStart: true)
    model.startTapped()

    let result = pipeline.derive(
        model: model,
        cycle: RunCycleID(rawValue: 1),
        semanticRevision: SemanticRevision(rawValue: 1)
    )
    guard case .success(let summary) = result else {
        Issue.record("production presentation pipeline failed: \(result)")
        return
    }
    #expect(summary.semantic.semanticNodeCount == 48)
    #expect(summary.semantic.modifierApplicationCount == 50)
    #expect(summary.retainedSemanticIdentities == 126)
    #expect(summary.recordedTraversalIdentities == 203)
    #expect(summary.layout.scopeCount == 98)
    #expect(summary.layout.maximumObservedDepth == 13)
    #expect(summary.drawing.canvasOccurrenceCount == 5)
    #expect(summary.drawing.strokeCount == 5)
    #expect(summary.render.operationCount == 35)
    #expect(summary.render.positionedGlyphCount == 129)
    #expect(summary.render.maximumObservedClipDepth == 3)
    #expect(summary.interactionOccurrenceCount == 6)
    var endpoint = SemanticJoinEndpoint(
        capacity: preset.runtimeLimits.renderSink
    )
    let accepted = pipeline.offer(
        endpoint: &endpoint,
        provenance: FrameProvenance(
            cycle: RunCycleID(rawValue: 1),
            semanticRevision: SemanticRevision(rawValue: 1),
            candidateFrame: CandidateFrameID(rawValue: 1)
        ),
        expectedHeader: summary.render
    )
    #expect(accepted == FrameOfferResult(disposition: .accepted, failure: nil)!)
    #expect(endpoint.sink.publishedHeader == summary.render)
    #expect(endpoint.sink.publishedStrokeCount == 5)
    #expect(
        pipeline.resolveInteraction(
            offer: accepted,
            presentationRevision: PresentationRevision(rawValue: 1)
        ) == .committed(PresentationRevision(rawValue: 1))
    )
    #expect(pipeline.committedActionCount == 6)
    #expect(pipeline.committedHitRegionCount == 6)
    let firstGenerations = (0 ..< pipeline.committedActionCount).compactMap {
        pipeline.committedAction(at: $0)?.generation
    }

    let repeatedResult = pipeline.derive(
        model: model,
        cycle: RunCycleID(rawValue: 2),
        semanticRevision: SemanticRevision(rawValue: 2)
    )
    guard case .success(let repeatedSummary) = repeatedResult else {
        Issue.record("reused production presentation pipeline failed: \(repeatedResult)")
        return
    }
    #expect(repeatedSummary == summary)
    #expect(
        pipeline.resolveInteraction(
            offer: accepted,
            presentationRevision: PresentationRevision(rawValue: 2)
        ) == .committed(PresentationRevision(rawValue: 2))
    )
    let repeatedGenerations = (0 ..< pipeline.committedActionCount).compactMap {
        pipeline.committedAction(at: $0)?.generation
    }
    #expect(repeatedGenerations == firstGenerations)

    let windowAction = try #require(
        (0 ..< pipeline.committedActionCount).compactMap {
            pipeline.committedAction(at: $0)
        }.first { $0.action.code == SignalAnalyzerAction.selectOneSecond.rawValue }
    )
    let hitPoint = Point(
        x: windowAction.hitBounds.origin.x + windowAction.hitBounds.size.width / 2,
        y: windowAction.hitBounds.origin.y + windowAction.hitBounds.size.height / 2
    )
    guard case .captured(let captured) = pipeline.resolveDown(at: hitPoint) else {
        Issue.record("production interaction did not capture the one-second action")
        return
    }
    #expect(pipeline.resolveMove(captured, at: hitPoint) == .continued(captured))
    #expect(pipeline.resolveUp(captured, at: hitPoint) == .activationAdmitted(captured))
    #expect(pipeline.dispatch(captured) == .dispatched)
    #expect(model.state.visibleWindow == .oneSecond)
}

@Test func signalAnalyzerDynamicSemanticJoinMeasuresRealHierarchy() throws {
    let preset = GeneratedSignalAnalyzerPresets.raspberryPiDynamic()
    let measurementLimits = SemanticExpansionLimits(
        maximumDepth: 64,
        maximumSemanticNodes: 512,
        maximumBodyEvaluations: 512,
        maximumModifierApplications: 512,
        maximumActionOccurrences: 32
    )!
    let model = makeSemanticJoinModel()
    let root = DynamicObservableRootAdapter<
        SignalAnalyzerViewModel,
        DynamicSemanticIdentity
    >(capacity: preset.runtimeLimits.observableState.maximumLocations)
    var reconciler = DynamicObservableStateReconciler(root: root)
    var binding = ObservableStateBindingDecorator(reconciler: reconciler)
    var workspace = DynamicSemanticExpansionWorkspace(
        maximumPathComponents: 64,
        maximumIdentities: 2048
    )
    var storage = DynamicSemanticHostStorage(
        limits: measurementLimits,
        maximumStructuralOccurrences: 512,
        canvasCapacity: preset.runtimeLimits.drawing.maximumCanvasOccurrences
    )

    #expect(reconciler.beginCandidate() == .success(.candidateStarted))
    let result = expandSemanticTreeWithStateBinding(
        SignalAnalyzerView(viewModel: model),
        limits: measurementLimits,
        workspace: &workspace,
        sink: &storage,
        stateBinding: &binding
    )

    guard case .success(let summary) = result else {
        _ = reconciler.finishCandidate(.discard)
        Issue.record("state-bound Signal Analyzer expansion failed: \(result)")
        return
    }
    #expect(reconciler.finishCandidate(.publish) == .success(.associationsCommitted))
    #expect(summary.semanticNodeCount == 47)
    #expect(summary.bodyEvaluationCount == 14)
    #expect(summary.modifierApplicationCount == 49)
    #expect(summary.actionOccurrenceCount == 6)
    #expect(summary.maximumObservedDepth == 34)
    #expect(storage.semanticScopeCount == 124)
    #expect(storage.actionOccurrenceCount == 6)
    #expect(storage.canvasOccurrenceCount == 5)
    #expect(storage.hasPublishedResult)
    #expect(root.isActive)
}

@Test func signalAnalyzerDynamicSemanticJoinMeasuresDiagnosticHierarchy() throws {
    let preset = GeneratedSignalAnalyzerPresets.raspberryPiDynamic()
    let measurementLimits = SemanticExpansionLimits(
        maximumDepth: 64,
        maximumSemanticNodes: 512,
        maximumBodyEvaluations: 512,
        maximumModifierApplications: 512,
        maximumActionOccurrences: 32
    )!
    let model = makeSemanticJoinModel(failsStart: true)
    model.startTapped()
    let root = DynamicObservableRootAdapter<
        SignalAnalyzerViewModel,
        DynamicSemanticIdentity
    >(capacity: preset.runtimeLimits.observableState.maximumLocations)
    var reconciler = DynamicObservableStateReconciler(root: root)
    var binding = ObservableStateBindingDecorator(reconciler: reconciler)
    var workspace = DynamicSemanticExpansionWorkspace(
        maximumPathComponents: 64,
        maximumIdentities: 2048
    )
    var storage = DynamicSemanticHostStorage(
        limits: measurementLimits,
        maximumStructuralOccurrences: 512,
        canvasCapacity: preset.runtimeLimits.drawing.maximumCanvasOccurrences
    )

    #expect(reconciler.beginCandidate() == .success(.candidateStarted))
    let result = expandSemanticTreeWithStateBinding(
        SignalAnalyzerView(viewModel: model),
        limits: measurementLimits,
        workspace: &workspace,
        sink: &storage,
        stateBinding: &binding
    )
    guard case .success(let summary) = result else {
        Issue.record("diagnostic Signal Analyzer expansion failed: \(result)")
        return
    }
    #expect(reconciler.finishCandidate(.publish) == .success(.associationsCommitted))
    #expect(summary.semanticNodeCount == 48)
    #expect(summary.bodyEvaluationCount == 14)
    #expect(summary.modifierApplicationCount == 50)
    #expect(summary.actionOccurrenceCount == 6)
    #expect(summary.maximumObservedDepth == 34)
    #expect(storage.semanticScopeCount == 126)
    #expect(storage.canvasOccurrenceCount == 5)

    var foregrounds: [Color: UInt16] = [:]
    var backgrounds: [Color: UInt16] = [:]
    for ordinal in 0 ..< storage.semanticScopeCount {
        guard let identity = storage.semanticIdentity(at: ordinal) else {
            Issue.record("missing render identity at ordinal \(ordinal)")
            continue
        }
        switch storage.scope(at: identity) {
        case .foregroundStyle(let color):
            foregrounds[color, default: 0] += 1
        case .background(let color):
            backgrounds[color, default: 0] += 1
        default:
            break
        }
    }
    #expect(foregrounds.values.reduce(0, +) == 21)
    #expect(foregrounds[.white] == 12)
    #expect(foregrounds[.gray] == 4)
    #expect(foregrounds[.red] == 1)
    #expect(foregrounds[Color(red: 0, green: 128, blue: 255)] == 4)
    #expect(backgrounds.values.reduce(0, +) == 9)
    #expect(backgrounds[.black] == 1)
    #expect(backgrounds[Color(red: 8, green: 8, blue: 8)] == 4)
    #expect(backgrounds[Color(red: 16, green: 16, blue: 16)] == 1)
    #expect(backgrounds[Color(red: 24, green: 24, blue: 24)] == 1)
    #expect(backgrounds[Color(red: 32, green: 32, blue: 32)] == 1)
    #expect(backgrounds[Color(red: 48, green: 48, blue: 48)] == 1)
}

@Test func signalAnalyzerDynamicSemanticJoinAdmitsApprovedPreset() throws {
    let preset = GeneratedSignalAnalyzerPresets.raspberryPiDynamic()
    let model = makeSemanticJoinModel()
    let root = DynamicObservableRootAdapter<
        SignalAnalyzerViewModel,
        DynamicSemanticIdentity
    >(capacity: preset.runtimeLimits.observableState.maximumLocations)
    var reconciler = DynamicObservableStateReconciler(root: root)
    var binding = ObservableStateBindingDecorator(reconciler: reconciler)
    var workspace = DynamicSemanticExpansionWorkspace(
        maximumPathComponents: preset.runtimeLimits.semantic.maximumDepth,
        maximumIdentities: 512
    )
    var storage = DynamicSemanticHostStorage(
        limits: preset.runtimeLimits.semantic,
        maximumStructuralOccurrences:
            preset.runtimeLimits.maximumSemanticStructuralOccurrences,
        canvasCapacity: preset.runtimeLimits.drawing.maximumCanvasOccurrences
    )

    #expect(reconciler.beginCandidate() == .success(.candidateStarted))
    let result = expandSemanticTreeWithStateBinding(
        SignalAnalyzerView(viewModel: model),
        limits: preset.runtimeLimits.semantic,
        workspace: &workspace,
        sink: &storage,
        stateBinding: &binding
    )

    guard case .success(let summary) = result else {
        _ = reconciler.finishCandidate(.discard)
        Issue.record("approved preset rejected the Signal Analyzer: \(result)")
        return
    }
    #expect(summary.semanticNodeCount == 47)
    #expect(summary.modifierApplicationCount == 49)
    #expect(summary.maximumObservedDepth == 34)
    #expect(storage.semanticScopeCount == 124)
    #expect(reconciler.finishCandidate(.publish) == .success(.associationsCommitted))
    #expect(storage.hasPublishedResult)
    #expect(root.isActive)
}

@Test func signalAnalyzerDynamicLayoutJoinMeasuresDiagnosticMaximum() throws {
    let preset = GeneratedSignalAnalyzerPresets.raspberryPiDynamic()
    let model = makeSemanticJoinModel(failsStart: true)
    model.startTapped()
    let root = DynamicObservableRootAdapter<
        SignalAnalyzerViewModel,
        DynamicSemanticIdentity
    >(capacity: preset.runtimeLimits.observableState.maximumLocations)
    var reconciler = DynamicObservableStateReconciler(root: root)
    var binding = ObservableStateBindingDecorator(reconciler: reconciler)
    var semanticWorkspace = DynamicSemanticExpansionWorkspace(
        maximumPathComponents: preset.runtimeLimits.semantic.maximumDepth,
        maximumIdentities: 203
    )
    var semanticStorage = DynamicSemanticHostStorage(
        limits: preset.runtimeLimits.semantic,
        maximumStructuralOccurrences:
            preset.runtimeLimits.maximumSemanticStructuralOccurrences,
        canvasCapacity: preset.runtimeLimits.drawing.maximumCanvasOccurrences
    )

    #expect(reconciler.beginCandidate() == .success(.candidateStarted))
    let semanticResult = expandSemanticTreeWithStateBinding(
        SignalAnalyzerView(viewModel: model),
        limits: preset.runtimeLimits.semantic,
        workspace: &semanticWorkspace,
        sink: &semanticStorage,
        stateBinding: &binding
    )
    guard case .success = semanticResult else {
        Issue.record("approved semantic stage failed: \(semanticResult)")
        return
    }
    #expect(semanticWorkspace.recordedIdentityCount == 203)
    #expect(reconciler.finishCandidate(.publish) == .success(.associationsCommitted))
    #expect(semanticStorage.semanticScopeCount == 126)
    #expect(preset.runtimeLimits.renderWorkspace.maximumSemanticScopes == 98)

    var scopeIdentities: [DynamicSemanticIdentity] = []
    var ordinal: UInt16 = 0
    while let identity = semanticStorage.semanticIdentity(at: ordinal) {
        if semanticStorage.primitive(at: identity) != nil {
            let modifierCount = semanticStorage.modifierCount(of: identity) ?? 0
            var modifierIndex: UInt16 = 0
            while modifierIndex < modifierCount {
                if let scope = semanticStorage.modifierScope(
                    of: identity,
                    at: modifierIndex
                ) {
                    scopeIdentities.append(scope)
                }
                modifierIndex += 1
            }
            scopeIdentities.append(identity)
        }
        ordinal += 1
    }
    let duplicateScopeCount = scopeIdentities.enumerated().filter { index, identity in
        scopeIdentities[..<index].contains(identity)
    }.count
    #expect(duplicateScopeCount == 0)

    let layoutLimits = preset.runtimeLimits.layout
    var layoutWorkspace = DynamicLayoutWorkspace(limits: layoutLimits)
    var validationWorkspace = DynamicLayoutWorkspace(limits: layoutLimits)
    var validation = LayoutSemanticValidation(limits: layoutLimits)
    let validationError = validation.validate(
        semantic: semanticStorage,
        metrics: GiftUIReferenceTextResources.targetPackage.metrics,
        workspace: &validationWorkspace
    )
    #expect(validationError == nil)
    validationWorkspace.resetLayout()
    var layoutSink = ResolvedRenderLayoutResultSink(
        storage: DynamicResolvedLayoutStorage(limits: layoutLimits)
    )
    let layoutResult = layout(
        semantic: semanticStorage,
        metrics: GiftUIReferenceTextResources.targetPackage.metrics,
        proposal: ProposedSize(width: 240, height: 240)!,
        limits: layoutLimits,
        workspace: &layoutWorkspace,
        sink: &layoutSink
    )

    guard case .success(let summary) = layoutResult else {
        Issue.record("approved layout stage failed: \(layoutResult)")
        return
    }
    #expect(summary.scopeCount == 98)
    #expect(summary.textScalarCount == 129)
    #expect(summary.textLineCount == 21)
    #expect(summary.positionedGlyphCount == 129)
    #expect(summary.maximumObservedDepth == 13)
    #expect(!layoutWorkspace.isLayoutActive)
    #expect(!layoutSink.isLayoutActive)
    #expect(layoutSink.renderView.layoutScopeCount == summary.scopeCount)
    #expect(layoutSink.renderView.renderSnapshotVersion == 1)
    #expect(layoutSink.renderView.rootBounds.size.width == 240)

    let semanticRenderView = semanticStorage.renderView
    #expect(semanticRenderView.semanticScopeCount == summary.scopeCount)
    #expect(semanticRenderView.rootIdentity == layoutSink.renderView.rootIdentity)
    var pendingRenderScopes = [(semanticRenderView.rootIdentity, UInt16(1))]
    var visitedRenderScopes: [DynamicSemanticIdentity] = []
    var maximumRenderDepth: UInt16 = 0
    while let (identity, depth) = pendingRenderScopes.popLast() {
        #expect(!visitedRenderScopes.contains(identity))
        visitedRenderScopes.append(identity)
        maximumRenderDepth = max(maximumRenderDepth, depth)
        let childCount = try #require(semanticRenderView.childCount(of: identity))
        for childIndex in 0 ..< childCount {
            pendingRenderScopes.append(
                (
                    try #require(semanticRenderView.child(of: identity, at: childIndex)),
                    depth + 1
                )
            )
        }
    }
    #expect(visitedRenderScopes.count == 98)
    #expect(maximumRenderDepth == 13)
    let renderLimits = preset.runtimeLimits.render
    let renderWorkspaceCapacity = preset.runtimeLimits.renderWorkspace
    var renderWorkspace = DynamicRenderWorkspace(
        capacity: renderLimits,
        structuralCapacity: renderWorkspaceCapacity
    )
    var renderSink = RenderRecordingSink(
        storage: SemanticJoinRenderStorage(
            capacity: preset.runtimeLimits.renderSink
        )
    )
    let surfaceBounds = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 240, height: 240)!
    )!
    let renderResult = RenderProducer.produce(
        semantic: semanticRenderView,
        layout: layoutSink.renderView,
        textMetrics: GiftUIReferenceTextResources.targetPackage.metrics,
        surfaceBounds: surfaceBounds,
        damageMode: .initializeCompleteSurface,
        rootForeground: .white,
        limits: renderLimits,
        workspace: &renderWorkspace,
        sink: &renderSink
    )
    guard case .success(let header) = renderResult else {
        Issue.record("measured render projection failed: \(renderResult)")
        return
    }
    #expect(header.operationCount == 30)
    #expect(header.positionedGlyphCount == 129)
    #expect(header.maximumObservedClipDepth == 3)
    #expect(renderSink.storage.published.count > 0)

    #if GIFTUI_DYNAMIC_PROFILE
        var drawingWorkspace = DynamicDrawingPlanWorkspace(
            capacity: preset.runtimeLimits.drawing
        )
        var previousCanvasOrdinal: UInt16?
        for canvasIndex in 0 ..< semanticStorage.canvasOccurrenceCount {
            let canvasIdentity = try #require(
                semanticStorage.canvasIdentity(at: canvasIndex)
            )
            let canvasOrdinal = try #require(
                layoutSink.renderView.layoutOrdinal(of: canvasIdentity)
            )
            let canvasBounds = try #require(
                layoutSink.renderView.bounds(of: canvasIdentity)
            )
            #expect(canvasBounds.size.width > 0)
            #expect(canvasBounds.size.height >= 4)
            if let previousCanvasOrdinal {
                #expect(canvasOrdinal > previousCanvasOrdinal)
            }
            previousCanvasOrdinal = canvasOrdinal
        }
        let drawingResult = CanvasPlanProducer.derive(
            source: &semanticStorage,
            layout: layoutSink.renderView,
            executionContext: ExecutionContext(
                cycle: RunCycleID(rawValue: 1),
                semanticRevision: SemanticRevision(rawValue: 1),
                candidateFrame: nil,
                phase: .deriving
            ),
            limits: preset.runtimeLimits.drawing,
            workspace: &drawingWorkspace
        )
        guard case .success(let drawingSummary) = drawingResult else {
            Issue.record("measured Canvas plan failed: \(drawingResult)")
            return
        }
        #expect(drawingSummary.canvasOccurrenceCount == 5)
        #expect(drawingSummary.strokeCount == 5)
        #expect(drawingSummary.pointCount == 32)
        #expect(drawingSummary.subpathCount == 16)
        #expect(drawingSummary.normalizedStrokeOperationCount == 5)

        let canvasPreflight = CanvasRenderProducer.preflight(
            semantic: semanticRenderView,
            layout: layoutSink.renderView,
            textMetrics: GiftUIReferenceTextResources.targetPackage.metrics,
            drawingPlan: drawingWorkspace,
            surfaceBounds: surfaceBounds,
            damageMode: .initializeCompleteSurface,
            rootForeground: .white,
            limits: renderLimits,
            configuredSinkCapacity: preset.runtimeLimits.renderSink,
            workspace: &renderWorkspace
        )
        guard case .success(let canvasHeader) = canvasPreflight else {
            Issue.record("measured Canvas render preflight failed: \(canvasPreflight)")
            return
        }
        #expect(canvasHeader.operationCount == 35)
        #expect(canvasHeader.positionedGlyphCount == 129)
        #expect(canvasHeader.maximumObservedClipDepth == 3)

        var drawingSink = SemanticJoinDrawingSink(
            capacity: preset.runtimeLimits.renderSink
        )
        let canvasRenderResult = CanvasRenderProducer.produce(
            semantic: semanticRenderView,
            layout: layoutSink.renderView,
            textMetrics: GiftUIReferenceTextResources.targetPackage.metrics,
            drawingPlan: drawingWorkspace,
            surfaceBounds: surfaceBounds,
            damageMode: .initializeCompleteSurface,
            rootForeground: .white,
            limits: renderLimits,
            expectedHeader: canvasHeader,
            workspace: &renderWorkspace,
            sink: &drawingSink
        )
        #expect(canvasRenderResult == .success(canvasHeader))
        #expect(drawingSink.publishedHeader == canvasHeader)
        #expect(drawingSink.publishedStrokeCount == 5)
    #endif
}

private func makeSemanticJoinModel(failsStart: Bool = false) -> SignalAnalyzerViewModel {
    let repository = SemanticJoinRepository(failsStart: failsStart)
    return SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
}

private func dynamicPiEffectivePresentation(
    preset: GeneratedSignalAnalyzerPreset
) -> EffectiveRasterPresentation {
    EffectiveRasterPresentation(
        operations: preset.capabilityRequirement.operations,
        extent: preset.capabilityRequirement.extent,
        regionExtent: CapabilityExtent(width: 240, height: 16)!,
        rowBytes: CapabilityByteCount(rawValue: 480),
        operationStream: .synchronousBorrowedOneShot,
        encoding: .rgb565BigEndian,
        submissionLifetime: .synchronousBorrow,
        handoff: .synchronous,
        realization: .tiled,
        requiredRasterBytes: CapabilityByteCount(rawValue: 7_680),
        requiredPayloadBytes: CapabilityByteCount(rawValue: 7_680),
        inFlightCount: 1,
        requiredInFlightBytes: CapabilityByteCount(rawValue: 7_680)
    )
}

private struct SemanticJoinRenderStorage: RenderRecordingStorage {
    let capacity: RenderSinkCapacity
    var staged: [RenderRecordingEvent] = []
    var published: [RenderRecordingEvent] = []

    mutating func beginRecording(_ event: borrowing RenderRecordingEvent) -> Bool {
        staged = [copy event]
        return true
    }

    mutating func stage(_ event: borrowing RenderRecordingEvent) -> Bool {
        staged.append(copy event)
        return true
    }

    mutating func publishRecording() -> Bool {
        published = staged
        staged.removeAll(keepingCapacity: true)
        return true
    }

    mutating func discardRecording() {
        staged.removeAll(keepingCapacity: true)
    }
}

private struct SemanticJoinDrawingSink: RasterOfferSessionSink {
    let capacity: RenderSinkCapacity
    private var stagedHeader: RenderPlanHeader?
    private var stagedOperationCount: UInt16 = 0
    private var stagedGlyphCount: UInt16 = 0
    private var stagedStrokeCount: UInt16 = 0
    private(set) var publishedHeader: RenderPlanHeader?
    private(set) var publishedStrokeCount: UInt16 = 0
    private(set) var streamCompleted = false
    private(set) var retainedProducerError: RenderProductionError?

    var descriptor: RasterSurfaceDescriptor { fatalError("fixture-only") }
    var payloadLimits: RasterPayloadLimits { fatalError("fixture-only") }
    var failure: RasterBackendError? { nil }
    var isIdleForOffer: Bool { true }
    var presentationResponsibilityAccepted: Bool { streamCompleted }

    init(capacity: RenderSinkCapacity) {
        self.capacity = capacity
    }

    mutating func retainProducerError(_ error: RenderProductionError) {
        retainedProducerError = error
    }

    mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult {
        .reserved(DisplayReservationID(rawValue: 1))
    }

    mutating func cancelReservedFrame() {}
    mutating func finishTransferredFrameIfNeeded() { streamCompleted = true }
    borrowing func health() -> GiftUIOperationalHealth {
        GiftUIOperationalHealth()
    }

    mutating func begin(_ header: RenderPlanHeader) -> Bool {
        guard stagedHeader == nil, header.operationCount <= capacity.maximumOperations,
            header.positionedGlyphCount <= capacity.maximumPositionedGlyphs
        else { return false }
        stagedHeader = header
        stagedOperationCount = 0
        stagedGlyphCount = 0
        stagedStrokeCount = 0
        return true
    }

    mutating func fillRect(_: FillRectOperation) -> Bool {
        incrementOperation()
    }

    mutating func beginPositionedGlyphs(
        _: PositionedGlyphOperationHeader
    ) -> Bool {
        incrementOperation()
    }

    mutating func positionedGlyph(_: PositionedGlyph) -> Bool {
        guard stagedGlyphCount < capacity.maximumPositionedGlyphs else {
            return false
        }
        stagedGlyphCount += 1
        return true
    }

    mutating func endPositionedGlyphs() -> Bool {
        stagedHeader != nil
    }

    mutating func straightLineStroke<Stroke>(
        _ stroke: borrowing Stroke
    ) -> Bool where Stroke: StraightLineStrokeView {
        var pointIndex: UInt16 = 0
        while pointIndex < stroke.header.pointCount {
            guard stroke.point(at: pointIndex) != nil else { return false }
            pointIndex += 1
        }
        var subpathIndex: UInt16 = 0
        while subpathIndex < stroke.header.subpathCount {
            guard stroke.subpath(at: subpathIndex) != nil else { return false }
            subpathIndex += 1
        }
        guard incrementOperation() else { return false }
        stagedStrokeCount += 1
        return true
    }

    mutating func finish() -> Bool {
        guard let stagedHeader,
            stagedOperationCount == stagedHeader.operationCount,
            stagedGlyphCount == stagedHeader.positionedGlyphCount
        else { return false }
        publishedHeader = stagedHeader
        publishedStrokeCount = stagedStrokeCount
        streamCompleted = true
        self.stagedHeader = nil
        return true
    }

    mutating func discard() {
        stagedHeader = nil
        stagedOperationCount = 0
        stagedGlyphCount = 0
        stagedStrokeCount = 0
    }

    private mutating func incrementOperation() -> Bool {
        guard stagedHeader != nil,
            stagedOperationCount < capacity.maximumOperations
        else { return false }
        stagedOperationCount += 1
        return true
    }
}

private struct SemanticJoinEndpoint: RasterBackendEndpoint {
    let textMetrics = GiftUIReferenceTextResources.targetPackage.metrics
    let textRaster = GiftUIReferenceTextResources.targetPackage.raster
    let textRasterRealization = RasterRealizationID(rawValue: 0)
    private(set) var sink: SemanticJoinDrawingSink

    init(capacity: RenderSinkCapacity) {
        sink = SemanticJoinDrawingSink(capacity: capacity)
    }

    var effectivePresentation: EffectiveRasterPresentation {
        fatalError("fixture-only")
    }
    var descriptor: RasterSurfaceDescriptor { fatalError("fixture-only") }
    var payloadLimits: RasterPayloadLimits { fatalError("fixture-only") }

    mutating func offer(
        provenance: FrameProvenance,
        body: (inout SemanticJoinDrawingSink) -> FrameStreamResult
    ) -> FrameOfferResult {
        _ = provenance
        return body(&sink) == .complete && sink.streamCompleted
            ? FrameOfferResult(disposition: .accepted, failure: nil)!
            : FrameOfferResult(disposition: .failed, failure: .producerFailed)!
    }

    borrowing func health() -> GiftUIOperationalHealth {
        GiftUIOperationalHealth()
    }
}
