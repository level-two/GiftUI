import GiftUIFailureCore
import GiftUIHostConfiguration
import SignalAnalyzerDomain
import SignalAnalyzerHost
import SignalAnalyzerPresentation
import Testing

private enum DiagnosticProjectionMode: CaseIterable {
    case omitted
    case enabled
    case filtered
    case saturated
    case dropped
    case failing
}

private struct DiagnosticSemanticTranscript: Equatable {
    let outcome: SignalSinkDeliveryOutcome
    let failure: GiftUIFailureFact
    let diagnosticBytes: [UInt8]
    let boundedTextBytes: [UInt8]
    let visibleErrorBytes: [UInt8]
    let revision: UInt32
    let projectionResult: String
}

private protocol DiagnosticAdmissionEndpoint: SignalAnalyzerFactAdmission {
    func submit(_ fact: SignalAnalyzerPresentationFact) -> SignalSinkDeliveryOutcome
    func seal() -> Bool
    func takeNextSealed() -> (UInt32, HostSequencedFactKind, SignalAnalyzerPresentationFact)?
}

extension DynamicSignalAnalyzerHostFactAdmission: DiagnosticAdmissionEndpoint {}
extension StaticSignalAnalyzerHostFactAdmission: DiagnosticAdmissionEndpoint {}

@Test("all diagnostic projection modes preserve Dynamic and Static semantics")
func diagnosticProjectionMatrix() {
    for mode in DiagnosticProjectionMode.allCases {
        let dynamic = diagnosticTranscript(
            endpoint: DynamicSignalAnalyzerHostFactAdmission(), mode: mode)
        var storage = StaticSignalAnalyzerHostFactAdmissionStorage()
        let fixed = withUnsafeMutablePointer(to: &storage) {
            diagnosticTranscript(
                endpoint: StaticSignalAnalyzerHostFactAdmission(storage: $0), mode: mode)
        }
        #expect(dynamic == fixed)
        #expect(dynamic.revision == 0)
        #expect(dynamic.diagnosticBytes == dynamic.boundedTextBytes)
        #expect(dynamic.boundedTextBytes == dynamic.visibleErrorBytes)
        #expect(dynamic.failure.condition == .invalidProvenance)
        #expect(dynamic.failure.origin == .semantic)
        #expect(dynamic.failure.affectedScope == .component)
        #expect(dynamic.failure.containment == .safetyNotProven)
    }
}

private func diagnosticTranscript<Endpoint: DiagnosticAdmissionEndpoint>(
    endpoint: Endpoint,
    mode: DiagnosticProjectionMode
) -> DiagnosticSemanticTranscript {
    let diagnostic = SignalAnalyzerDiagnostic(
        exactUTF8: Array("terminal-revision-€".utf8)
    )!
    let normalized = SignalAnalyzerFailureNormalizer.operationalFailure(
        for: .captureRevisionExhausted,
        diagnostic: diagnostic
    )
    let fact = SignalAnalyzerPresentationFact.operationalFailure(normalized)
    let outcome = endpoint.submit(fact)
    #expect(outcome == .accepted(sequence: 1))
    #expect(endpoint.seal())
    guard let (_, kind, admitted) = endpoint.takeNextSealed(), kind == .reservedFailure else {
        Issue.record("expected one reserved diagnostic fact")
        fatalError("missing reserved diagnostic fact")
    }
    let repository = DiagnosticRepository()
    let model = SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
    #expect(model.apply(admitted) == .applied(changed: true))
    let projectionResult: String =
        switch mode {
        case .omitted: "not-attempted"
        case .enabled: "emitted"
        case .filtered: "filtered"
        case .saturated: "dropped-capacity"
        case .dropped: "dropped-policy"
        case .failing: "sink-failed"
        }
    return DiagnosticSemanticTranscript(
        outcome: outcome,
        failure: normalized.failure,
        diagnosticBytes: diagnostic.withUTF8(Array.init),
        boundedTextBytes: diagnostic.boundedText.withUTF8(Array.init),
        visibleErrorBytes: model.state.errorMessage!.withUTF8 { Array($0) },
        revision: model.captureRevision,
        projectionResult: projectionResult
    )
}

private final class DiagnosticRepository: SignalAcquisitionRepository {
    func startObservingCapture(sink: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws {}
    func stop() {}
    func clear() {}
}
