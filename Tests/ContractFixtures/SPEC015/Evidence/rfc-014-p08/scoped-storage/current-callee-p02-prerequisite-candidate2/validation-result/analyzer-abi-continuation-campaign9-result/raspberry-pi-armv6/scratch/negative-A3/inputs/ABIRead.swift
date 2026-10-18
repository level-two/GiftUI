import SignalAnalyzerDomain

@inlinable package func serializedABIRead(
    _ state: AcquisitionState, _ transition: SignalTransition
) -> Int {
    state == .running ? transition.channelID.rawValue : 0
}
