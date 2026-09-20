nonisolated(unsafe) private var giftUIStaticInput =
    StaticSignalAnalyzerNRFFirmwareInputStorage()

@_cdecl("giftui_signal_analyzer_input_initialize")
public func giftUISignalAnalyzerInputInitialize(_ source: UInt16) -> Int32 {
    giftUIStaticInput.initialize(sourceRawValue: source) ? 0 : -1
}

@_cdecl("giftui_signal_analyzer_input_install_presentation")
public func giftUISignalAnalyzerInputInstallPresentation(
    _ revision: UInt32
) -> Int32 {
    giftUIStaticInput.installPhysicalPresentation(rawValue: revision) ? 0 : -1
}

@_cdecl("giftui_signal_analyzer_input_admit")
public func giftUISignalAnalyzerInputAdmit(
    _ phase: UInt8,
    _ x: UInt16,
    _ y: UInt16,
    _ observedPresentationRevision: UInt32,
    _ priorPhysicalSequenceIsComplete: UInt8
) -> Int32 {
    let outcome = giftUIStaticInput.admit(
        phaseRawValue: phase,
        x: x,
        y: y,
        observedPresentationRevisionRawValue: observedPresentationRevision,
        priorPhysicalSequenceIsCompleteRawValue: priorPhysicalSequenceIsComplete
    )
    return outcome?.packedValue ?? -1
}

@_cdecl("giftui_signal_analyzer_input_pending_count")
public func giftUISignalAnalyzerInputPendingCount() -> UInt16 {
    giftUIStaticInput.pendingCount
}

@_cdecl("giftui_signal_analyzer_input_quiesce")
public func giftUISignalAnalyzerInputQuiesce() {
    giftUIStaticInput.quiesce()
}
