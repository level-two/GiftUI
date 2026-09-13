import GiftUI
import GiftUIFailureCore
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

@Suite("Signal Analyzer mutation-phase fact application")
struct SignalAnalyzerFactApplicationTests {
    @Test("snapshot atomically replaces capture revision and visible range")
    func snapshot() {
        let model = makeFactModel()
        let capture = SignalCapture(
            transitions: [factTransition(17_300)],
            duration: .milliseconds(17_300)
        )!

        #expect(
            model.apply(.captureSnapshot(revision: 9, capture: capture)) == .applied(changed: true))
        #expect(model.captureRevision == 9)
        #expect(model.state.capture == capture)
        #expect(
            model.visibleRange == Duration.milliseconds(15_300) ..< Duration.milliseconds(17_300))
    }

    @Test("exact mutation replays and mismatch leaves model unchanged")
    func mutationAndMismatch() {
        let model = makeFactModel()
        let change = SignalCaptureChange.insertAndTrim(
            baseRevision: 0,
            insertionIndex: 0,
            transition: factTransition(1),
            evictedPrefixCount: 0,
            duration: .milliseconds(1),
            retainedLowerBound: .zero,
            baselines: .allLow
        )
        #expect(
            model.apply(.captureMutation(revision: 1, change: change)) == .applied(changed: true))
        let retainedState = model.state

        #expect(
            model.apply(.captureMutation(revision: 3, change: change))
                == .rejected(.captureRevisionMismatch))
        #expect(model.state == retainedState)
        #expect(model.captureRevision == 1)
    }

    @Test("state and operational failures preserve exact semantic diagnostics")
    func failures() {
        let model = makeFactModel()
        let diagnostic = SignalAnalyzerDiagnostic(exactUTF8: Array("semantic failure".utf8))!
        #expect(model.apply(.acquisitionState(.failed(diagnostic))) == .applied(changed: true))
        #expect(model.state.errorMessage == diagnostic)

        let second = SignalAnalyzerDiagnostic(exactUTF8: Array("operational failure".utf8))!
        let failure = SignalAnalyzerOperationalFailure(
            failure: GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .presentationIntegration,
                affectedScope: .component,
                containment: .contained
            ),
            diagnostic: second
        )
        #expect(model.apply(.operationalFailure(failure)) == .applied(changed: true))
        #expect(model.state.acquisitionState == .failed(second))
        #expect(model.state.errorMessage == second)
    }

    @Test("only observable changes report dirty")
    func reporting() {
        let model = makeFactModel()
        let attachment = _GiftUIObservationAttachment(slot: 2, generation: 4)
        var reports = 0
        _ = model._giftUIAttachChangeSink(
            _GiftUIObservableChangeSink(
                attachment: attachment,
                reportRoute: { _ in
                    reports += 1
                    return reports == 1 ? .dirtied : .coalesced
                }
            )
        )

        #expect(model.apply(.acquisitionState(.idle)) == .applied(changed: false))
        #expect(reports == 0)
        #expect(model.apply(.acquisitionState(.running)) == .applied(changed: true))
        #expect(reports == 1)
        #expect(model.apply(.acquisitionState(.running)) == .applied(changed: false))
        #expect(reports == 1)
    }
}

private func makeFactModel() -> SignalAnalyzerViewModel {
    let repository = FactRepository()
    return SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
}

private func factTransition(_ milliseconds: Int) -> SignalTransition {
    SignalTransition(
        channelID: SignalChannelID(rawValue: 1),
        timestamp: .milliseconds(milliseconds),
        level: .high
    )
}

private final class FactRepository: SignalAcquisitionRepository {
    func startObservingCapture(sink: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws {}
    func stop() {}
    func clear() {}
}
