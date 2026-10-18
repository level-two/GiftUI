import SignalAnalyzerDomain

package func abiSemanticChecks() -> Int {
    let a = SignalAnalyzerDiagnostic(exactUTF8: [UInt8(65)])!
    let a2 = SignalAnalyzerDiagnostic(exactUTF8: [UInt8(65)])!
    let b = SignalAnalyzerDiagnostic(exactUTF8: [UInt8(66)])!
    precondition(AcquisitionState.idle == .idle)
    precondition(AcquisitionState.running == .running)
    precondition(AcquisitionState.stopped == .stopped)
    precondition(AcquisitionState.failed(a) == .failed(a2))
    precondition(AcquisitionState.failed(a) != .failed(b))
    precondition(AcquisitionState.idle != .running)
    precondition(AcquisitionState.running != .stopped)
    precondition(AcquisitionState.stopped != .failed(a))
    precondition(AcquisitionState.idle != .failed(a))
    let transition = SignalTransition(channelID: SignalChannelID(rawValue: 1), timestamp: .zero, level: .high)
    precondition(transition == SignalTransition(channelID: SignalChannelID(rawValue: 1), timestamp: .zero, level: .high))
    precondition(transition != SignalTransition(channelID: SignalChannelID(rawValue: 2), timestamp: .zero, level: .high))
    precondition(transition != SignalTransition(channelID: SignalChannelID(rawValue: 1), timestamp: .seconds(1), level: .high))
    precondition(transition != SignalTransition(channelID: SignalChannelID(rawValue: 1), timestamp: .zero, level: .low))
    precondition(transition.channelID.rawValue == 1)
    precondition(transition.timestamp == .zero)
    precondition(transition.level == .high)
    precondition(a.utf8ByteCount == 1)
    precondition(a.withUTF8 { $0.count == 1 && $0[0] == 65 })
    return 18
}
