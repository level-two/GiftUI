import GiftUI
import SignalAnalyzerDomain

extension SignalAnalyzerDiagnostic {
    package var boundedText: BoundedText {
        withUTF8 { bytes in
            guard let text = BoundedText(utf8: bytes) else {
                preconditionFailure("SignalAnalyzerDiagnostic invariant violated")
            }
            return text
        }
    }
}
