package protocol SignalCaptureSink {
    func receive(_ publication: SignalCapturePublication) -> SignalSinkDeliveryOutcome
}

package protocol AcquisitionStateSink {
    func receive(_ state: AcquisitionState) -> SignalSinkDeliveryOutcome
}

package protocol SignalAcquisitionRepository {
    func startObservingCapture(sink: some SignalCaptureSink)
    func stopObservingCapture()
    func startObservingAcquisitionState(sink: some AcquisitionStateSink)
    func stopObservingAcquisitionState()
    func start() throws
    func stop()
    func clear()
}

package protocol SignalTransitionSink {
    func receive(_ transition: SignalTransition)
}

package protocol SignalDataSource {
    func start(sink: some SignalTransitionSink) throws
    func stop()
}

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

package struct StartSignalAcquisitionUseCase {
    private let repository: any SignalAcquisitionRepository

    package init(repository: any SignalAcquisitionRepository) {
        self.repository = repository
    }

    package func execute() throws {
        try repository.start()
    }
}

package struct StopSignalAcquisitionUseCase {
    private let repository: any SignalAcquisitionRepository

    package init(repository: any SignalAcquisitionRepository) {
        self.repository = repository
    }

    package func execute() {
        repository.stop()
    }
}

package struct ClearSignalCaptureUseCase {
    private let repository: any SignalAcquisitionRepository

    package init(repository: any SignalAcquisitionRepository) {
        self.repository = repository
    }

    package func execute() {
        repository.clear()
    }
}
