import GiftUI
import GiftUIHostConfiguration
import GiftUILayout
import GiftUIObservableState
import GiftUIReferenceTextResources
import GiftUIRuntimeDynamic
import GiftUISemanticCore
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

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
    #expect(summary.modifierApplicationCount == 5)
    #expect(summary.actionOccurrenceCount == 6)
    #expect(summary.maximumObservedDepth == 26)
    #expect(storage.semanticScopeCount == 80)
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
    #expect(summary.modifierApplicationCount == 5)
    #expect(summary.actionOccurrenceCount == 6)
    #expect(summary.maximumObservedDepth == 26)
    #expect(storage.semanticScopeCount == 81)
    #expect(storage.canvasOccurrenceCount == 5)
}

@Test func signalAnalyzerDynamicSemanticJoinFitsApprovedPreset() throws {
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
        Issue.record("approved state-bound Signal Analyzer expansion failed: \(result)")
        return
    }
    #expect(reconciler.finishCandidate(.publish) == .success(.associationsCommitted))
    #expect(summary.semanticNodeCount == 47)
    #expect(summary.maximumObservedDepth == 26)
    #expect(storage.semanticScopeCount == 80)
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
        maximumIdentities: 512
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
    #expect(semanticWorkspace.recordedIdentityCount == 158)
    #expect(reconciler.finishCandidate(.publish) == .success(.associationsCommitted))
    #expect(semanticStorage.semanticScopeCount == 81)
    #expect(preset.runtimeLimits.renderWorkspace.maximumSemanticScopes == 62)
    #expect(
        semanticStorage.semanticScopeCount
            > preset.runtimeLimits.renderWorkspace.maximumSemanticScopes
    )

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

    let approvedLimits = preset.runtimeLimits.layout
    var layoutWorkspace = DynamicLayoutWorkspace(limits: approvedLimits)
    var validationWorkspace = DynamicLayoutWorkspace(limits: approvedLimits)
    var validation = LayoutSemanticValidation(limits: approvedLimits)
    let validationError = validation.validate(
        semantic: semanticStorage,
        metrics: GiftUIReferenceTextResources.targetPackage.metrics,
        workspace: &validationWorkspace
    )
    #expect(validationError == nil)
    validationWorkspace.resetLayout()
    var layoutSink = ResolvedRenderLayoutResultSink(
        storage: DynamicResolvedLayoutStorage(limits: approvedLimits)
    )
    let layoutResult = layout(
        semantic: semanticStorage,
        metrics: GiftUIReferenceTextResources.targetPackage.metrics,
        proposal: ProposedSize(width: 240, height: 240)!,
        limits: approvedLimits,
        workspace: &layoutWorkspace,
        sink: &layoutSink
    )

    guard case .success(let summary) = layoutResult else {
        Issue.record("approved layout stage failed: \(layoutResult)")
        return
    }
    #expect(summary.scopeCount == 53)
    #expect(summary.textScalarCount == 129)
    #expect(summary.textLineCount == 21)
    #expect(summary.positionedGlyphCount == 129)
    #expect(summary.maximumObservedDepth == 6)
    #expect(!layoutWorkspace.isLayoutActive)
    #expect(!layoutSink.isLayoutActive)
    #expect(layoutSink.renderView.layoutScopeCount == summary.scopeCount)
    #expect(layoutSink.renderView.renderSnapshotVersion == 1)
    #expect(layoutSink.renderView.rootBounds.size.width == 240)
}

private func makeSemanticJoinModel(failsStart: Bool = false) -> SignalAnalyzerViewModel {
    let repository = SemanticJoinRepository(failsStart: failsStart)
    return SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
}
