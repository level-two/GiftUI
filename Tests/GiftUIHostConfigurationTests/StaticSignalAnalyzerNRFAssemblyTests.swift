import GiftUICapabilities
import GiftUIHostConfiguration
import GiftUIInteraction
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

@Test func staticNRFApplicationStorageUsesValidatedGeneratedOwners() {
    guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate(),
        var storage = StaticSignalAnalyzerNRFApplicationStorage(
            assemblyReport: report,
            inputSourceRawValue: 51
        )
    else {
        Issue.record("Static nRF application storage did not construct")
        return
    }

    #expect(storage.assemblyReport == report)
    #expect(storage.root.targetGeneration() == nil)
    #expect(storage.input.pendingCount == 0)
    #expect(
        storage.interaction.beginCandidate(
            limits: InteractionLimits(maximumActions: 6, maximumHitRegions: 6)!
        ) == nil
    )
    storage.interaction.resolveCandidate(.discard)
    #expect(
        storage.interaction.beginCandidate(
            limits: InteractionLimits(maximumActions: 7, maximumHitRegions: 7)!
        ) == .capacityExhausted
    )
}

@Test func staticNRFApplicationStorageRejectsAnotherTargetReport() {
    guard case .valid(let report) = DynamicSignalAnalyzerPiAssembly.validate() else {
        Issue.record("Dynamic Pi assembly did not validate")
        return
    }

    let storage = StaticSignalAnalyzerNRFApplicationStorage(
        assemblyReport: report,
        inputSourceRawValue: 51
    )
    switch consume storage {
    case nil:
        break
    case .some:
        Issue.record("Static nRF storage accepted another target report")
    }
}

private extension RuntimeProfileValidationResult {
    var audit: RuntimeStorageAudit? {
        guard case .valid(let audit) = self else { return nil }
        return audit
    }
}
