import SignalAnalyzerPresentation
import Testing

@Test
func presentationBoundaryIsAvailable() {
    #expect(
        SignalAnalyzerPresentationBoundary.owner
            == "SignalAnalyzerDomain/SignalAnalyzerPresentation"
    )
}
