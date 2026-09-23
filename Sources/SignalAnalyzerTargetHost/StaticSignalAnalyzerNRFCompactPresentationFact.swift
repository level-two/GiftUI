import SignalAnalyzerDomain

package enum StaticSignalAnalyzerNRFCompactPresentationPayload: Equatable, Sendable {
    case captureMutation(StaticSignalAnalyzerNRFCompactCaptureFact)
    case acquisitionState(AcquisitionState)
}

/// One target compact fact slot. Failed acquisition state retains the exact
/// bounded portable diagnostic inline rather than borrowing model storage.
package struct StaticSignalAnalyzerNRFCompactPresentationFact: Equatable, Sendable {
    package static let maximumStride = 112

    package let sequence: UInt32
    package let payload: StaticSignalAnalyzerNRFCompactPresentationPayload

    package init?(
        sequence: UInt32,
        payload: StaticSignalAnalyzerNRFCompactPresentationPayload
    ) {
        guard sequence != 0 else { return nil }
        self.sequence = sequence
        self.payload = payload
    }
}
