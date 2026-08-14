@MainActor
package protocol SignalCaptureSink: AnyObject {
    func receive(_ capture: SignalCapture)
}

@MainActor
package protocol AcquisitionStateSink: AnyObject {
    func receive(_ state: AcquisitionState)
}

@MainActor
package protocol SignalAcquisitionRepository: AnyObject {
    func startObservingCapture(sink: some SignalCaptureSink)
    func stopObservingCapture()
    func startObservingAcquisitionState(sink: some AcquisitionStateSink)
    func stopObservingAcquisitionState()
    func start() throws
    func stop()
    func clear()
}
