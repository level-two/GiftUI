import GiftUI
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

@Suite("Signal Analyzer Presentation values and actions")
struct SignalAnalyzerPresentationValueTests {
    @Test("visible windows and initial state are exact")
    func initialState() {
        let repository = PresentationRepositorySpy()
        let model = makeModel(repository: repository)

        #expect(VisibleTimeWindow.oneSecond.duration == .seconds(1))
        #expect(VisibleTimeWindow.twoSeconds.duration == .seconds(2))
        #expect(VisibleTimeWindow.fiveSeconds.duration == .seconds(5))
        #expect(model.state == SignalAnalyzerViewState())
        #expect(model.visibleRange == .zero ..< Duration.seconds(2))
    }

    @Test("six actions use one total exact dispatch")
    func actionDispatch() {
        let repository = PresentationRepositorySpy()
        let model = makeModel(repository: repository)
        var handler = SignalAnalyzerActionHandler()

        handler.handle(.start, model: model)
        handler.handle(.stop, model: model)
        handler.handle(.clear, model: model)
        handler.handle(.selectOneSecond, model: model)
        #expect(model.state.visibleWindow == .oneSecond)
        handler.handle(.selectTwoSeconds, model: model)
        #expect(model.state.visibleWindow == .twoSeconds)
        handler.handle(.selectFiveSeconds, model: model)
        #expect(model.state.visibleWindow == .fiveSeconds)

        #expect(repository.startCount == 1)
        #expect(repository.stopCount == 1)
        #expect(repository.clearCount == 1)
        #expect(SignalAnalyzerAction.allCasesByRawValue == [0, 1, 2, 3, 4, 5])
    }

    @Test("start failure exposes the exact bounded diagnostic")
    func startFailure() {
        let diagnostic = SignalAnalyzerDiagnostic(exactUTF8: Array("cannot start".utf8))!
        let repository = PresentationRepositorySpy()
        repository.startFailure = PresentationStartFailure(signalAnalyzerDiagnostic: diagnostic)
        let model = makeModel(repository: repository)

        model.startTapped()

        #expect(model.state.errorMessage == diagnostic)
    }

    @Test("changed intents report synchronously and proven no-ops do not")
    func changeReporting() {
        let repository = PresentationRepositorySpy()
        let model = makeModel(repository: repository)
        let attachment = _GiftUIObservationAttachment(slot: 3, generation: 7)
        var reports = 0
        let returned = model._giftUIAttachChangeSink(
            _GiftUIObservableChangeSink(
                attachment: attachment,
                reportRoute: { reported in
                    #expect(reported == attachment)
                    reports += 1
                    return reports == 1 ? .dirtied : .coalesced
                }
            )
        )
        #expect(returned == attachment)

        model.visibleDurationChanged(.oneSecond)
        model.visibleDurationChanged(.oneSecond)
        #expect(reports == 1)
        model._giftUIDetachChangeSink(attachment)
        model.visibleDurationChanged(.fiveSeconds)
        #expect(reports == 1)
    }

    private func makeModel(repository: PresentationRepositorySpy) -> SignalAnalyzerViewModel {
        SignalAnalyzerViewModel(
            startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
            stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
            clearCapture: ClearSignalCaptureUseCase(repository: repository)
        )
    }
}

private extension SignalAnalyzerAction {
    static var allCasesByRawValue: [UInt16] {
        [start, stop, clear, selectOneSecond, selectTwoSeconds, selectFiveSeconds].map(\.rawValue)
    }
}

private struct PresentationStartFailure: SignalAnalyzerDiagnosticError {
    let signalAnalyzerDiagnostic: SignalAnalyzerDiagnostic
}

private final class PresentationRepositorySpy: SignalAcquisitionRepository {
    var startCount = 0
    var stopCount = 0
    var clearCount = 0
    var startFailure: PresentationStartFailure?

    func startObservingCapture(sink: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}

    func start() throws {
        startCount += 1
        if let startFailure { throw startFailure }
    }

    func stop() { stopCount += 1 }
    func clear() { clearCount += 1 }
}
