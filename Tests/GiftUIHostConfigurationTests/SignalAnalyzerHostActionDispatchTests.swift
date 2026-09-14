import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import SignalAnalyzerDomain
import SignalAnalyzerHost
import SignalAnalyzerPresentation
import Testing

private final class ActionRepository: SignalAcquisitionRepository {
    private(set) var calls: [String] = []

    func startObservingCapture(sink: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws { calls.append("start") }
    func stop() { calls.append("stop") }
    func clear() { calls.append("clear") }
}

private struct AnalyzerActionRecords: InteractionCommittedActionView {
    let record: BoundActionRecord<UInt16>?

    func committedRecord(for identity: UInt16) -> BoundActionRecord<UInt16>? {
        guard record?.identity == identity else { return nil }
        return record
    }
}

private let analyzerActionBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 4, height: 4)!
)!

private func analyzerActionRecord(
    code: UInt16,
    actionGeneration: UInt32 = 8,
    targetGeneration: UInt32 = 0,
    enabled: Bool = true
) -> BoundActionRecord<UInt16> {
    BoundActionRecord(
        identity: 4,
        generation: ActionGeneration(rawValue: actionGeneration),
        isEnabled: enabled,
        hitBounds: analyzerActionBounds,
        paintOrder: 0,
        action: BoundedApplicationAction(code: code),
        targetGeneration: ObservableTargetGeneration(rawValue: targetGeneration)
    )
}

@Test(arguments: Array(UInt16(0) ... UInt16(5)))
func everyAnalyzerActionCodeDispatchesToTheExactCurrentModel(code: UInt16) {
    let repository = ActionRepository()
    let model = makeActionModel(repository: repository)
    let root = makeActionRoot(model)
    var dispatcher = DynamicSignalAnalyzerActionDispatcher.make(
        records: AnalyzerActionRecords(record: analyzerActionRecord(code: code)),
        root: root
    )

    let result = dispatcher.dispatch(
        CapturedAction(
            identity: 4,
            generation: ActionGeneration(rawValue: 8)
        )
    )

    #expect(result == .dispatched)
    switch SignalAnalyzerAction(rawValue: code)! {
    case .start: #expect(repository.calls == ["start"])
    case .stop: #expect(repository.calls == ["stop"])
    case .clear: #expect(repository.calls == ["clear"])
    case .selectOneSecond: #expect(model.state.visibleWindow == .oneSecond)
    case .selectTwoSeconds: #expect(model.state.visibleWindow == .twoSeconds)
    case .selectFiveSeconds: #expect(model.state.visibleWindow == .fiveSeconds)
    }
}

@Test(arguments: [UInt16(6), UInt16.max])
func invalidAnalyzerActionCodesFailClosed(code: UInt16) {
    let repository = ActionRepository()
    let model = makeActionModel(repository: repository)
    let root = makeActionRoot(model)
    var dispatcher = DynamicSignalAnalyzerActionDispatcher.make(
        records: AnalyzerActionRecords(record: analyzerActionRecord(code: code)),
        root: root
    )

    #expect(
        dispatcher.dispatch(
            CapturedAction(identity: 4, generation: ActionGeneration(rawValue: 8))
        ) == .failure(.invariantViolation)
    )
    #expect(repository.calls.isEmpty)
    #expect(model.state == SignalAnalyzerViewState())
}

@Test func staleActionAndTargetGenerationsCancelBeforeBorrowingTheModel() {
    for fixture in [
        (recordGeneration: UInt32(9), targetGeneration: UInt32(0)),
        (recordGeneration: UInt32(8), targetGeneration: UInt32(1)),
    ] {
        let repository = ActionRepository()
        let model = makeActionModel(repository: repository)
        let root = makeActionRoot(model)
        var dispatcher = DynamicSignalAnalyzerActionDispatcher.make(
            records: AnalyzerActionRecords(
                record: analyzerActionRecord(
                    code: SignalAnalyzerAction.start.rawValue,
                    actionGeneration: fixture.recordGeneration,
                    targetGeneration: fixture.targetGeneration
                )
            ),
            root: root
        )

        #expect(
            dispatcher.dispatch(
                CapturedAction(identity: 4, generation: ActionGeneration(rawValue: 8))
            ) == .cancelled
        )
        #expect(repository.calls.isEmpty)
    }
}

@Test func replacementBetweenCaptureAndDispatchCancelsAndRetainsNeitherModel() {
    let repository = ActionRepository()
    var former: SignalAnalyzerViewModel? = makeActionModel(repository: repository)
    weak let weakFormer = former
    let root = makeActionRoot(former!)
    var dispatcher = DynamicSignalAnalyzerActionDispatcher.make(
        records: AnalyzerActionRecords(
            record: analyzerActionRecord(code: SignalAnalyzerAction.start.rawValue)
        ),
        root: root
    )
    let captured = CapturedAction(
        identity: UInt16(4),
        generation: ActionGeneration(rawValue: 8)
    )

    root.setExecutionPhase(.mutating)
    #expect(
        root.replace(with: makeActionModel(repository: repository))
            == .success(.replaced)
    )
    former = nil

    #expect(weakFormer == nil)
    #expect(dispatcher.dispatch(captured) == .cancelled)
    #expect(repository.calls.isEmpty)
}

private func makeActionRoot(
    _ model: SignalAnalyzerViewModel
) -> DynamicObservableRootAdapter<SignalAnalyzerViewModel, UInt16> {
    let root = DynamicObservableRootAdapter<SignalAnalyzerViewModel, UInt16>(capacity: 1)
    var state = State(wrappedValue: model)
    #expect(root.beginCandidate() == .success(.candidateStarted))
    #expect(
        root.encounter(
            structuralIdentity: 1,
            declarationOrdinal: 0,
            state: &state,
            replacementRoute: { _ in }
        ) == .success(.materialized)
    )
    #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
    return root
}

private func makeActionModel(repository: ActionRepository) -> SignalAnalyzerViewModel {
    SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
}
