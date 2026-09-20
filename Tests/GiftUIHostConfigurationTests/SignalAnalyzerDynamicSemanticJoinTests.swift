import GiftUIHostConfiguration
import GiftUIObservableState
import GiftUIRuntimeDynamic
import GiftUISemanticCore
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

private final class SemanticJoinRepository: SignalAcquisitionRepository {
    func startObservingCapture(sink _: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink _: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws {}
    func stop() {}
    func clear() {}
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
    #expect(summary.modifierApplicationCount == 5)
    #expect(summary.actionOccurrenceCount == 6)
    #expect(summary.maximumObservedDepth == 26)
    #expect(storage.semanticScopeCount == 80)
    #expect(storage.actionOccurrenceCount == 6)
    #expect(storage.canvasOccurrenceCount == 5)
    #expect(storage.hasPublishedResult)
    #expect(root.isActive)
}

@Test func signalAnalyzerDynamicSemanticJoinRejectsApprovedPresetDepth() throws {
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

    #expect(result == .semanticFailure(.capacityExhausted))
    #expect(reconciler.finishCandidate(.discard) == .success(.candidateDiscarded))
    #expect(!storage.hasPublishedResult)
    #expect(!root.isActive)
}

private func makeSemanticJoinModel() -> SignalAnalyzerViewModel {
    let repository = SemanticJoinRepository()
    return SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
}
