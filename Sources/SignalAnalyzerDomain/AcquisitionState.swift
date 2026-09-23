/// Portable acquisition state shared by host and Embedded Swift model storage.
package enum AcquisitionState: Equatable, Sendable {
    case idle
    case running
    case stopped
    case failed(SignalAnalyzerDiagnostic)
}
