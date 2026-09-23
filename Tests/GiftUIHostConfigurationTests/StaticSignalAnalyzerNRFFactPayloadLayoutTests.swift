import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import SignalAnalyzerTargetHost
import Testing

@Test func nRFFactPayloadLayoutHasBoundedInlineValues() {
    print(
        "nRF fact payload strides: diagnostic=\(MemoryLayout<SignalAnalyzerDiagnostic>.stride) "
            + "state=\(MemoryLayout<AcquisitionState>.stride) "
            + "mutation=\(MemoryLayout<SignalCaptureChange>.stride) "
            + "failure=\(MemoryLayout<SignalAnalyzerOperationalFailure>.stride)"
    )
    #expect(MemoryLayout<SignalAnalyzerDiagnostic>.stride <= 104)
    #expect(MemoryLayout<AcquisitionState>.stride <= 112)
    #expect(MemoryLayout<SignalCaptureChange>.stride <= 96)
    #expect(MemoryLayout<SignalAnalyzerOperationalFailure>.stride <= 128)
    #expect(MemoryLayout<StaticSignalAnalyzerNRFCompactPresentationFact>.stride <= 112)
    #expect(MemoryLayout<StaticSignalAnalyzerNRFOperationalFailureFact>.stride <= 112)
    print(
        "nRF compact presentation fact stride="
            + "\(MemoryLayout<StaticSignalAnalyzerNRFCompactPresentationFact>.stride)"
    )
}
