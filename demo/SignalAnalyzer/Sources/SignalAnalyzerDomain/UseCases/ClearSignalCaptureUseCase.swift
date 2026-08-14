@MainActor
package struct ClearSignalCaptureUseCase {
    private let repository: any SignalAcquisitionRepository

    package init(repository: any SignalAcquisitionRepository) {
        self.repository = repository
    }

    package func execute() {
        repository.clear()
    }
}
