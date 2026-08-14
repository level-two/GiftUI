@MainActor
package struct ObserveSignalCaptureUseCase {
    private let repository: any SignalAcquisitionRepository

    package init(repository: any SignalAcquisitionRepository) {
        self.repository = repository
    }

    package func start(sink: some SignalCaptureSink) {
        repository.startObservingCapture(sink: sink)
    }

    package func stop() {
        repository.stopObservingCapture()
    }
}
