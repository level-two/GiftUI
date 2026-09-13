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
