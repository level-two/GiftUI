// Appended to the generated Swift amalgamation only for the macOS recorder.
// This injects a model fact; the production host still schedules and presents it.
@_cdecl("giftui_signal_analyzer_rehearsal_diagnostic")
public func giftUISignalAnalyzerRehearsalDiagnostic() -> UInt32 {
    guard let diagnostic = giftUIStaticSampleDiagnostic(),
        giftUIStaticModelLocation.beginMutation(),
        giftUIStaticModelLocation.setAcquisitionState(.failed(diagnostic)),
        giftUIStaticModelLocation.endMutation()
    else { return 0 }
    return 1
}

// Exercise the maximum bounded diagnostic through the real render handoff.
@_cdecl("giftui_signal_analyzer_rehearsal_maximum_diagnostic")
public func giftUISignalAnalyzerRehearsalMaximumDiagnostic() -> UInt32 {
    let text: StaticString = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    let diagnostic = text.withUTF8Buffer { SignalAnalyzerDiagnostic(exactUTF8: $0) }
    guard let diagnostic, diagnostic.utf8ByteCount == 96,
        giftUIStaticModelLocation.beginMutation(),
        giftUIStaticModelLocation.setAcquisitionState(.failed(diagnostic)),
        giftUIStaticModelLocation.endMutation()
    else { return 0 }
    return 1
}
