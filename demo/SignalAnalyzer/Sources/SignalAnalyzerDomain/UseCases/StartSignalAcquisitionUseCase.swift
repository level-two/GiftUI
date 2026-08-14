@MainActor
package struct StartSignalAcquisitionUseCase {
    private let repository: any SignalAcquisitionRepository

    package init(repository: any SignalAcquisitionRepository) {
        self.repository = repository
    }

    package func execute() throws {
        try repository.start()
    }
}
