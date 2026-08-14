import SignalAnalyzerDomain

@MainActor
package protocol SignalTransitionSink: AnyObject {
    func receive(_ transition: SignalTransition)
}

@MainActor
package protocol SignalDataSource {
    func start(sink: some SignalTransitionSink) throws
    func stop()
}
