import Foundation
import SignalAnalyzerDomain

@MainActor
package final class DefaultSignalAcquisitionRepository:
    SignalAcquisitionRepository,
    SignalTransitionSink
{
    private let dataSource: any SignalDataSource
    private let channels: [SignalChannel]
    private let maximumCaptureDuration: Duration
    private let maximumTransitionCount: Int
    private let diagnosticHandler: @MainActor (String) -> Void

    private weak var captureSink: (any SignalCaptureSink)?
    private weak var stateSink: (any AcquisitionStateSink)?
    private var transitions: [SignalTransition] = []
    private var captureDuration: Duration = .zero
    private var retainedLowerBound: Duration = .zero
    private var baselineLevels: [SignalChannelID: DigitalLevel]
    private var currentLevels: [SignalChannelID: DigitalLevel]
    private var captureEpochSourceTimestamp: Duration = .zero
    private var latestAcceptedSourceTimestamp: Duration = .zero
    private var acquisitionState: AcquisitionState = .idle
    private var sourceIsActive = false
    private var pendingStartFailure: SignalAcquisitionRepositoryError?

    package init(
        dataSource: any SignalDataSource,
        channels: [SignalChannel] = SignalChannel.standard,
        maximumCaptureDuration: Duration = .seconds(30),
        maximumTransitionCount: Int = 2_404,
        diagnosticHandler: @escaping @MainActor (String) -> Void = { _ in }
    ) {
        precondition(maximumTransitionCount > 0)
        self.dataSource = dataSource
        self.channels = channels
        self.maximumCaptureDuration = maximumCaptureDuration
        self.maximumTransitionCount = maximumTransitionCount
        self.diagnosticHandler = diagnosticHandler
        let initialLevels = Dictionary(
            uniqueKeysWithValues: channels.map { ($0.id, DigitalLevel.low) }
        )
        self.baselineLevels = initialLevels
        self.currentLevels = initialLevels
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
        pendingStartFailure = nil

        do {
            try dataSource.start(sink: self)
        } catch {
            sourceIsActive = false
            dataSource.stop()
            let message = diagnosticMessage(for: error)
            setState(.failed(message))
            throw SignalAcquisitionRepositoryError(message: message)
        }

        if let pendingStartFailure {
            throw pendingStartFailure
        }
        setState(.running)
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
        retainedLowerBound = .zero
        baselineLevels = currentLevels
        captureEpochSourceTimestamp = latestAcceptedSourceTimestamp
        captureSink?.receive(currentCapture)
    }

    package func receive(_ transition: SignalTransition) {
        guard sourceIsActive else {
            diagnosticHandler("Dropped transition from an inactive source generation.")
            return
        }

        guard channels.contains(where: { $0.id == transition.channelID }) else {
            failSourceContract(
                "Received transition for invalid channel \(transition.channelID.rawValue).")
            return
        }
        guard transition.timestamp >= .zero else {
            failSourceContract("Received transition with a negative timestamp.")
            return
        }

        let epochTimestamp = transition.timestamp - captureEpochSourceTimestamp
        guard epochTimestamp >= retainedLowerBound else {
            diagnosticHandler("Dropped transition older than the retained lower bound.")
            return
        }

        let retainedTransition = SignalTransition(
            channelID: transition.channelID,
            timestamp: epochTimestamp,
            level: transition.level
        )
        let insertionIndex =
            transitions.firstIndex {
                $0.timestamp > retainedTransition.timestamp
            } ?? transitions.endIndex
        transitions.insert(retainedTransition, at: insertionIndex)

        latestAcceptedSourceTimestamp = max(latestAcceptedSourceTimestamp, transition.timestamp)
        captureDuration = max(captureDuration, retainedTransition.timestamp)
        currentLevels[transition.channelID] = levelAtCaptureEnd(for: transition.channelID)

        let cutoff = max(.zero, captureDuration - maximumCaptureDuration)
        evictTransitions(while: { $0.timestamp < cutoff })
        retainedLowerBound = max(retainedLowerBound, cutoff)

        while transitions.count > maximumTransitionCount {
            let evicted = transitions.removeFirst()
            baselineLevels[evicted.channelID] = evicted.level
            retainedLowerBound = max(retainedLowerBound, evicted.timestamp)
        }
        captureSink?.receive(currentCapture)
    }

    private var currentCapture: SignalCapture {
        SignalCapture(
            channels: channels,
            transitions: transitions,
            duration: captureDuration,
            retainedLowerBound: retainedLowerBound,
            baselineLevels: baselineLevels
        )
    }

    private func evictTransitions(while shouldEvict: (SignalTransition) -> Bool) {
        while let first = transitions.first, shouldEvict(first) {
            baselineLevels[first.channelID] = first.level
            transitions.removeFirst()
        }
    }

    private func levelAtCaptureEnd(for channelID: SignalChannelID) -> DigitalLevel {
        transitions.last(where: { $0.channelID == channelID })?.level
            ?? baselineLevels[channelID]
            ?? .low
    }

    private func failSourceContract(_ message: String) {
        sourceIsActive = false
        dataSource.stop()
        let failure = SignalAcquisitionRepositoryError(message: message)
        pendingStartFailure = failure
        diagnosticHandler(message)
        setState(.failed(message))
    }

    private func diagnosticMessage(for error: any Error) -> String {
        let message = error.localizedDescription
        return message.isEmpty ? "Signal source failed to start." : message
    }

    private func setState(_ newState: AcquisitionState) {
        acquisitionState = newState
        stateSink?.receive(newState)
    }
}

private struct SignalAcquisitionRepositoryError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}
