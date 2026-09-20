nonisolated(unsafe) private var giftUIStaticInput:
    StaticSignalAnalyzerNRFInputABI?

@_cdecl("giftui_signal_analyzer_input_initialize")
public func giftUISignalAnalyzerInputInitialize(_ source: UInt16) -> Int32 {
    giftUIStaticInput = StaticSignalAnalyzerNRFInputABI(sourceRawValue: source)
    return 0
}

@_cdecl("giftui_signal_analyzer_input_install_presentation")
public func giftUISignalAnalyzerInputInstallPresentation(
    _ revision: UInt32
) -> Int32 {
    guard var input = giftUIStaticInput else { return -1 }
    input.installPhysicalPresentation(rawValue: revision)
    giftUIStaticInput = input
    return 0
}

@_cdecl("giftui_signal_analyzer_input_admit")
public func giftUISignalAnalyzerInputAdmit(
    _ phase: UInt8,
    _ x: UInt16,
    _ y: UInt16,
    _ observedPresentationRevision: UInt32,
    _ priorPhysicalSequenceIsComplete: UInt8
) -> Int32 {
    guard var input = giftUIStaticInput else { return -1 }
    let outcome = input.admit(
        phaseRawValue: phase,
        x: x,
        y: y,
        observedPresentationRevisionRawValue: observedPresentationRevision,
        priorPhysicalSequenceIsCompleteRawValue: priorPhysicalSequenceIsComplete
    )
    giftUIStaticInput = input
    return outcome?.packedValue ?? -1
}

@_cdecl("giftui_signal_analyzer_input_pending_count")
public func giftUISignalAnalyzerInputPendingCount() -> UInt16 {
    giftUIStaticInput?.pendingCount ?? 0
}

@_cdecl("giftui_signal_analyzer_input_quiesce")
public func giftUISignalAnalyzerInputQuiesce() {
    guard var input = giftUIStaticInput else { return }
    input.quiesce()
    giftUIStaticInput = input
}
