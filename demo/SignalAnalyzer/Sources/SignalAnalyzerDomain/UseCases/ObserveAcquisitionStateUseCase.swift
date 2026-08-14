@MainActor
package struct ObserveAcquisitionStateUseCase {
    private let repository: any SignalAcquisitionRepository

    package init(repository: any SignalAcquisitionRepository) {
        self.repository = repository
    }

    package func start(sink: some AcquisitionStateSink) {
        repository.startObservingAcquisitionState(sink: sink)
    }

    package func stop() {
        repository.stopObservingAcquisitionState()
    }
}
