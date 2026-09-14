import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIRuntimeCore
import SignalAnalyzerDomain
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

private final class AnalyzerTargetBox {
    weak var model: SignalAnalyzerViewModel?
    var generation: ObservableTargetGeneration?

    init(model: SignalAnalyzerViewModel?, generation: ObservableTargetGeneration?) {
        self.model = model
        self.generation = generation
    }
}

private struct AnalyzerTargetAccess: ActionModelTargetAccess {
    let box: AnalyzerTargetBox

    func currentGeneration() -> ObservableTargetGeneration? { box.generation }

    mutating func withCurrentModel(
        matching generation: ObservableTargetGeneration,
        _ body: (borrowing SignalAnalyzerViewModel) -> Void
    ) -> Bool {
        guard box.generation == generation, let model = box.model else { return false }
        body(model)
        return true
    }
}

private let analyzerActionBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 4, height: 4)!
)!

private func analyzerActionRecord(
    code: UInt16,
    actionGeneration: UInt32 = 8,
    targetGeneration: UInt32 = 12,
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
    var dispatcher = RuntimeInteractionDispatcher(
        records: AnalyzerActionRecords(record: analyzerActionRecord(code: code)),
        handler: SignalAnalyzerActionHandler(),
        targetAccess: AnalyzerTargetAccess(
            box: AnalyzerTargetBox(
                model: model,
                generation: ObservableTargetGeneration(rawValue: 12)
            )
        )
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
    var dispatcher = RuntimeInteractionDispatcher(
        records: AnalyzerActionRecords(record: analyzerActionRecord(code: code)),
        handler: SignalAnalyzerActionHandler(),
        targetAccess: AnalyzerTargetAccess(
            box: AnalyzerTargetBox(
                model: model,
                generation: ObservableTargetGeneration(rawValue: 12)
            )
        )
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
        (recordGeneration: UInt32(9), targetGeneration: UInt32(12)),
        (recordGeneration: UInt32(8), targetGeneration: UInt32(13)),
    ] {
        let repository = ActionRepository()
        let model = makeActionModel(repository: repository)
        var dispatcher = RuntimeInteractionDispatcher(
            records: AnalyzerActionRecords(
                record: analyzerActionRecord(
                    code: SignalAnalyzerAction.start.rawValue,
                    actionGeneration: fixture.recordGeneration
                )
            ),
            handler: SignalAnalyzerActionHandler(),
            targetAccess: AnalyzerTargetAccess(
                box: AnalyzerTargetBox(
                    model: model,
                    generation: ObservableTargetGeneration(
                        rawValue: fixture.targetGeneration
                    )
                )
            )
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
    let target = AnalyzerTargetBox(
        model: former,
        generation: ObservableTargetGeneration(rawValue: 12)
    )
    var dispatcher = RuntimeInteractionDispatcher(
        records: AnalyzerActionRecords(
            record: analyzerActionRecord(code: SignalAnalyzerAction.start.rawValue)
        ),
        handler: SignalAnalyzerActionHandler(),
        targetAccess: AnalyzerTargetAccess(box: target)
    )
    let captured = CapturedAction(
        identity: UInt16(4),
        generation: ActionGeneration(rawValue: 8)
    )

    target.generation = ObservableTargetGeneration(rawValue: 13)
    target.model = nil
    former = nil

    #expect(weakFormer == nil)
    #expect(dispatcher.dispatch(captured) == .cancelled)
    #expect(repository.calls.isEmpty)
}

private func makeActionModel(repository: ActionRepository) -> SignalAnalyzerViewModel {
    SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
}
