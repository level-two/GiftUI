import GiftUI
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

@Suite("Signal Analyzer portable hierarchy")
struct SignalAnalyzerViewHierarchyTests {
    @Test("root owns exactly one observable model and constructs after binding")
    func rootStateOwnership() {
        let repository = HierarchyRepository()
        let model = SignalAnalyzerViewModel(
            startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
            stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
            clearCapture: ClearSignalCaptureUseCase(repository: repository)
        )
        var view = SignalAnalyzerView(viewModel: model)
        var visitor = HierarchyStateVisitor(model: model)

        view._giftUIVisitObservableStateDeclarations(&visitor)

        #expect(visitor.ordinals == [0])
        _ = view.body
    }

    @Test(
        "status and acquisition controls follow the exact four-state matrix",
        arguments: [
            (AcquisitionState.idle, "READY", false, true),
            (.running, "RUNNING", true, false),
            (.stopped, "STOPPED", false, true),
            (.failed(hierarchyDiagnostic("failed")), "FAILED", false, true),
        ]
    )
    func acquisitionControls(
        state: AcquisitionState,
        expectedStatus: String,
        startDisabled: Bool,
        stopDisabled: Bool
    ) {
        let controls = SignalAnalyzerControlState(
            acquisitionState: state,
            selectedWindow: .twoSeconds
        )

        #expect(hierarchyText(controls.statusText) == expectedStatus)
        #expect(controls.startDisabled == startDisabled)
        #expect(controls.stopDisabled == stopDisabled)
    }

    @Test(
        "exactly the selected window control is disabled",
        arguments: [
            (VisibleTimeWindow.oneSecond, true, false, false),
            (.twoSeconds, false, true, false),
            (.fiveSeconds, false, false, true),
        ]
    )
    func windowControls(
        window: VisibleTimeWindow,
        oneSecondDisabled: Bool,
        twoSecondsDisabled: Bool,
        fiveSecondsDisabled: Bool
    ) {
        let controls = SignalAnalyzerControlState(
            acquisitionState: .idle,
            selectedWindow: window
        )

        #expect(controls.oneSecondDisabled == oneSecondDisabled)
        #expect(controls.twoSecondsDisabled == twoSecondsDisabled)
        #expect(controls.fiveSecondsDisabled == fiveSecondsDisabled)
    }
}

private func hierarchyDiagnostic(_ text: String) -> SignalAnalyzerDiagnostic {
    SignalAnalyzerDiagnostic(exactUTF8: Array(text.utf8))!
}

private func hierarchyText(_ text: BoundedText) -> String {
    text.withUTF8 { String(decoding: $0, as: UTF8.self) }
}

private struct HierarchyStateVisitor: _GiftUIObservableStateDeclarationVisitor {
    let model: SignalAnalyzerViewModel
    var ordinals: [UInt16] = []

    mutating func visit<Value: _GiftUIObservableReference>(
        _ state: inout State<Value>,
        declarationOrdinal: UInt16
    ) {
        ordinals.append(declarationOrdinal)
        let retainedModel = model
        _ = state._giftUIBind(
            read: { retainedModel as! Value },
            replace: { _ in }
        )
    }
}

private final class HierarchyRepository: SignalAcquisitionRepository {
    func startObservingCapture(sink: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws {}
    func stop() {}
    func clear() {}
}
