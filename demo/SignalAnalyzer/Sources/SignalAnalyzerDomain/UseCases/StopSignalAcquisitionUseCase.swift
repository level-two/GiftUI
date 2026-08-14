@MainActor
package struct StopSignalAcquisitionUseCase {
    private let repository: any SignalAcquisitionRepository

    package init(repository: any SignalAcquisitionRepository) {
        self.repository = repository
    }

    package func execute() {
        repository.stop()
    }
}
