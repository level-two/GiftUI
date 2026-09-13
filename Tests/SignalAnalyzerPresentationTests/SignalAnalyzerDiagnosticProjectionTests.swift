import GiftUI
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

@Test
func diagnosticProjectionPreservesExactUTF8Bytes() {
    let source: [UInt8] = [0x45, 0x72, 0x72, 0x6F, 0x72, 0x3A, 0x20, 0xE2, 0x82, 0xAC]
    let diagnostic = SignalAnalyzerDiagnostic(exactUTF8: source)!
    let projected = diagnostic.boundedText
    #expect(projected.utf8ByteCount == diagnostic.utf8ByteCount)
    #expect(projected.withUTF8(Array.init) == source)
}
