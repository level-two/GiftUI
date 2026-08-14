import SignalAnalyzerData
import SignalAnalyzerDomain
import SignalAnalyzerPresentation

@MainActor
final class DependencyContainer {
    let viewModel: SignalAnalyzerViewModel

    init() {
        let dataSource = MockSignalDataSource()
        let repository = DefaultSignalAcquisitionRepository(dataSource: dataSource)

        viewModel = SignalAnalyzerViewModel(
            observeCapture: ObserveSignalCaptureUseCase(repository: repository),
            observeAcquisitionState: ObserveAcquisitionStateUseCase(repository: repository),
            startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
            stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
            clearCapture: ClearSignalCaptureUseCase(repository: repository)
        )
    }
}
