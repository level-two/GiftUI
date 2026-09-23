import SignalAnalyzerDomain

/// The separately reserved fact keeps normalized failure fields and the
/// complete diagnostic inline. Raw field values are build-local, as required
/// by the portable failure vocabulary.
package struct StaticSignalAnalyzerNRFOperationalFailureFact: Equatable, Sendable {
    package static let maximumStride = 112

    package let sequence: UInt32
    package let conditionRawValue: UInt16
    package let originRawValue: UInt8
    package let affectedScopeRawValue: UInt8
    package let containmentRawValue: UInt8
    package let diagnostic: SignalAnalyzerDiagnostic

    package init?(
        sequence: UInt32,
        conditionRawValue: UInt16,
        originRawValue: UInt8,
        affectedScopeRawValue: UInt8,
        containmentRawValue: UInt8,
        diagnostic: SignalAnalyzerDiagnostic
    ) {
        guard sequence != 0 else { return nil }
        self.sequence = sequence
        self.conditionRawValue = conditionRawValue
        self.originRawValue = originRawValue
        self.affectedScopeRawValue = affectedScopeRawValue
        self.containmentRawValue = containmentRawValue
        self.diagnostic = diagnostic
    }
}
