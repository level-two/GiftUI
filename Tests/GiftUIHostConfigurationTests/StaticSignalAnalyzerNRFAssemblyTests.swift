import GiftUICapabilities
import GiftUIHostConfiguration
import GiftUIRuntimeCore
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFAssemblyValidatesExactGeneratedEndpointContract() {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate() else {
        Issue.record("Static nRF production assembly did not validate")
        return
    }

    #expect(report.kind == .nrf52840Static)
    #expect(report.profile == .static)
    #expect(report.storageAudit == preset.validatedStorageAudit().audit)
    #expect(report.effectivePresentation.extent == preset.capabilityRequirement.extent)
    #expect(report.effectivePresentation.realization == .tiled)
    #expect(report.effectivePresentation.regionExtent.width == 480)
    #expect(report.effectivePresentation.regionExtent.height == 4)
    #expect(report.effectivePresentation.requiredRasterBytes.rawValue == 3_840)
    #expect(report.effectivePresentation.requiredPayloadBytes.rawValue == 3_840)
    #expect(report.effectivePresentation.submissionLifetime == .synchronousBorrow)
    #expect(report.drawingPlanOperationLimit == 5)
    #expect(report.minimumSinkOperationCapacity == 35)
    #expect(report.cardinality == preset.cardinality)
    #expect(report.maximumCompactFactsPerServiceWindow == 28)
}

private extension RuntimeProfileValidationResult {
    var audit: RuntimeStorageAudit? {
        guard case .valid(let audit) = self else { return nil }
        return audit
    }
}
