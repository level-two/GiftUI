import SignalAnalyzerDomain

@MainActor
package final class DefaultSignalAcquisitionRepository:
    SignalAcquisitionRepository,
    SignalTransitionSink
{
    private let dataSource: any SignalDataSource
    private let channels: [SignalChannel]
    private let maximumCaptureDuration: Duration

    private weak var captureSink: (any SignalCaptureSink)?
    private weak var stateSink: (any AcquisitionStateSink)?
    private var transitions: [SignalTransition] = []
    private var captureDuration: Duration = .zero
    private var acquisitionState: AcquisitionState = .idle
    private var sourceIsActive = false

    package init(
        dataSource: any SignalDataSource,
        channels: [SignalChannel] = SignalChannel.standard,
        maximumCaptureDuration: Duration = .seconds(30)
    ) {
        self.dataSource = dataSource
        self.channels = channels
        self.maximumCaptureDuration = maximumCaptureDuration
    }

    package func startObservingCapture(sink: some SignalCaptureSink) {
        captureSink = sink
        sink.receive(currentCapture)
    }

    package func stopObservingCapture() {
        captureSink = nil
    }

    package func startObservingAcquisitionState(sink: some AcquisitionStateSink) {
        stateSink = sink
        sink.receive(acquisitionState)
    }

    package func stopObservingAcquisitionState() {
        stateSink = nil
    }

    package func start() throws {
        guard !sourceIsActive else { return }
        sourceIsActive = true

        do {
            try dataSource.start(sink: self)
            setState(.running)
        } catch {
            sourceIsActive = false
            setState(.failed(error.localizedDescription))
            throw error
        }
    }

    package func stop() {
        guard sourceIsActive else { return }
        sourceIsActive = false
        dataSource.stop()
        setState(.stopped)
    }

    package func clear() {
        transitions.removeAll(keepingCapacity: true)
        captureDuration = .zero
        captureSink?.receive(currentCapture)
    }

    package func receive(_ transition: SignalTransition) {
        transitions.append(transition)
        if transitions.count > 1,
           transitions[transitions.count - 2].timestamp > transition.timestamp {
            transitions.sort { $0.timestamp < $1.timestamp }
        }

        captureDuration = max(captureDuration, transition.timestamp)
        let cutoff = captureDuration - maximumCaptureDuration
        if cutoff > .zero {
            transitions.removeAll { $0.timestamp < cutoff }
        }
        captureSink?.receive(currentCapture)
    }

    private var currentCapture: SignalCapture {
        SignalCapture(
            channels: channels,
            transitions: transitions,
            duration: captureDuration
        )
    }

    private func setState(_ newState: AcquisitionState) {
        acquisitionState = newState
        stateSink?.receive(newState)
    }
}
