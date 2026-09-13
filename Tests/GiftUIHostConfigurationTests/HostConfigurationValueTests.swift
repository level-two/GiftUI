import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIRasterCore
import GiftUIRuntimeCore
import GiftUISurfaceCore
import GiftUITextResources
import Testing

@testable import GiftUIHostConfiguration

@Test func pacingRejectsEveryZeroField() {
    let valid: (UInt32, UInt32, UInt32, UInt16, UInt8, UInt8, UInt8) = (
        250_000, 250_000, 50_000, 20, 2, 6, 3
    )
    let candidates = [
        (0, valid.1, valid.2, valid.3, valid.4, valid.5, valid.6),
        (valid.0, 0, valid.2, valid.3, valid.4, valid.5, valid.6),
        (valid.0, valid.1, 0, valid.3, valid.4, valid.5, valid.6),
        (valid.0, valid.1, valid.2, 0, valid.4, valid.5, valid.6),
        (valid.0, valid.1, valid.2, valid.3, 0, valid.5, valid.6),
        (valid.0, valid.1, valid.2, valid.3, valid.4, 0, valid.6),
        (valid.0, valid.1, valid.2, valid.3, valid.4, valid.5, 0),
    ]

    for candidate in candidates {
        #expect(
            HostPacingPolicy(
                minimumFrameIntervalMicroseconds: candidate.0,
                maximumFactServiceLatencyMicroseconds: candidate.1,
                minimumAcceptedTransitionSpacingMicroseconds: candidate.2,
                maximumTransitionFactsPerServiceWindow: candidate.3,
                maximumBootstrapFactsPerServiceWindow: candidate.4,
                maximumActionInducedFactsPerServiceWindow: candidate.5,
                maximumRetryableRefusals: candidate.6
            ) == nil
        )
    }
}

@Test func pacingAcceptsRepresentableBoundariesAndRejectsEachOverflowStep() {
    #expect(
        HostPacingPolicy(
            minimumFrameIntervalMicroseconds: 1,
            maximumFactServiceLatencyMicroseconds: 1,
            minimumAcceptedTransitionSpacingMicroseconds: 1,
            maximumTransitionFactsPerServiceWindow: 1,
            maximumBootstrapFactsPerServiceWindow: 1,
            maximumActionInducedFactsPerServiceWindow: 1,
            maximumRetryableRefusals: 1
        ) != nil
    )
    #expect(
        HostPacingPolicy(
            minimumFrameIntervalMicroseconds: .max,
            maximumFactServiceLatencyMicroseconds: .max,
            minimumAcceptedTransitionSpacingMicroseconds: .max,
            maximumTransitionFactsPerServiceWindow: UInt16.max - 2,
            maximumBootstrapFactsPerServiceWindow: 1,
            maximumActionInducedFactsPerServiceWindow: 1,
            maximumRetryableRefusals: .max
        ) != nil
    )
    #expect(
        HostPacingPolicy(
            minimumFrameIntervalMicroseconds: 1,
            maximumFactServiceLatencyMicroseconds: 1,
            minimumAcceptedTransitionSpacingMicroseconds: 1,
            maximumTransitionFactsPerServiceWindow: .max,
            maximumBootstrapFactsPerServiceWindow: 1,
            maximumActionInducedFactsPerServiceWindow: 1,
            maximumRetryableRefusals: 1
        ) == nil
    )
    #expect(
        HostPacingPolicy(
            minimumFrameIntervalMicroseconds: 1,
            maximumFactServiceLatencyMicroseconds: 1,
            minimumAcceptedTransitionSpacingMicroseconds: 1,
            maximumTransitionFactsPerServiceWindow: UInt16.max - 1,
            maximumBootstrapFactsPerServiceWindow: 1,
            maximumActionInducedFactsPerServiceWindow: 1,
            maximumRetryableRefusals: 1
        ) == nil
    )
}

@Test func generatedPresetsPreserveExactHostValueFamilies() {
    let presets = [
        GeneratedSignalAnalyzerPresets.macOSDynamic(),
        GeneratedSignalAnalyzerPresets.macOSStatic(),
        GeneratedSignalAnalyzerPresets.raspberryPiDynamic(),
        GeneratedSignalAnalyzerPresets.nrf52840Static(),
    ]
    let expectedKinds: [MVPHostKind] = [
        .macOSDynamic, .macOSStatic, .raspberryPiDynamic, .nrf52840Static,
    ]
    let expectedProfiles: [RuntimeProfileKind] = [
        .dynamic, .static, .dynamic, .static,
    ]

    for index in presets.indices {
        let preset = presets[index]
        #expect(preset.kind == expectedKinds[index])
        #expect(preset.profile == expectedProfiles[index])
        #expect(preset.cardinality.actionCaseCount == 6)
        #expect(preset.cardinality.rootModelLocationCount == 1)
        #expect(preset.cardinality.activeRegistrationCount == 1)
        #expect(preset.cardinality.stagedAssociationCount == 1)
        #expect(preset.cardinality.snapshotFactCapacity == 1)
        #expect(preset.cardinality.compactFactCapacity == 32)
        #expect(preset.cardinality.reservedFailureFactCapacity == 1)
        #expect(preset.cardinality.normalizedInputSourceCapacity == 1)
        #expect(preset.pacing.minimumFrameIntervalMicroseconds == 250_000)
        #expect(preset.pacing.maximumFactServiceLatencyMicroseconds == 250_000)
        #expect(preset.pacing.minimumAcceptedTransitionSpacingMicroseconds == 50_000)
        #expect(preset.pacing.maximumTransitionFactsPerServiceWindow == 20)
        #expect(preset.pacing.maximumBootstrapFactsPerServiceWindow == 2)
        #expect(preset.pacing.maximumActionInducedFactsPerServiceWindow == 6)
        #expect(preset.pacing.maximumRetryableRefusals == 3)

        let maximumFacts =
            preset.pacing.maximumTransitionFactsPerServiceWindow
            + UInt16(preset.pacing.maximumBootstrapFactsPerServiceWindow)
            + UInt16(preset.pacing.maximumActionInducedFactsPerServiceWindow)
        #expect(maximumFacts == 28)
        #expect(preset.cardinality.compactFactCapacity - maximumFacts == 4)
    }
}

@Test func structuralActionAndInputValuesPreserveExactFields() {
    let preset = GeneratedSignalAnalyzerPresets.macOSDynamic()
    guard case .valid(let audit) = preset.validatedStorageAudit() else {
        Issue.record("generated preset must provide its exact storage audit")
        return
    }
    let structural = HostStructuralConfiguration(
        kind: preset.kind,
        profile: preset.profile,
        runtimeLimits: preset.runtimeLimits,
        runtimeAudit: audit,
        cardinality: preset.cardinality,
        workload: preset.workload,
        pacing: preset.pacing
    )
    let action = HostActionModelConfiguration(
        firstActionCode: 0,
        lastActionCode: 5,
        handlerCount: 1,
        rootModelTargetCount: 1,
        sourceMinimumTransitionSpacingMicroseconds: 50_000,
        maximumSourceCallbacksPerServiceWindow: 20,
        maximumCallbacksPerAction: 1,
        maximumRepositoryCallbacksPerAction: 1,
        maximumUseCaseCallbacksPerAction: 1,
        maximumNonTransitionPublicationsPerAction: 1,
        applicationExecutorFactLimit: 28,
        factAdmissionAdapterCount: 1,
        targetGenerationIsPublishable: true,
        actionHandlerIsTotal: true,
        retainsOwnerReferences: false,
        callbacksAreReentrant: false
    )
    let input = HostInputWakeConfiguration(
        normalizedInputSourceCount: 1,
        targetLocalPresentationGateCount: 1,
        wakeRequesterCount: 1,
        applicationAndMutationDomainsAreDistinct: true,
        wakeRequesterIsNonReentrant: true
    )

    #expect(structural.kind == .macOSDynamic)
    #expect(structural.runtimeAudit == audit)
    #expect(structural.workload == preset.workload)
    #expect(action.firstActionCode == 0)
    #expect(action.lastActionCode == 5)
    #expect(action.handlerCount == 1)
    #expect(action.rootModelTargetCount == 1)
    #expect(action.sourceMinimumTransitionSpacingMicroseconds == 50_000)
    #expect(action.maximumSourceCallbacksPerServiceWindow == 20)
    #expect(action.maximumCallbacksPerAction == 1)
    #expect(action.maximumRepositoryCallbacksPerAction == 1)
    #expect(action.maximumUseCaseCallbacksPerAction == 1)
    #expect(action.maximumNonTransitionPublicationsPerAction == 1)
    #expect(action.applicationExecutorFactLimit == 28)
    #expect(action.factAdmissionAdapterCount == 1)
    #expect(action.targetGenerationIsPublishable)
    #expect(action.actionHandlerIsTotal)
    #expect(!action.retainsOwnerReferences)
    #expect(!action.callbacksAreReentrant)
    #expect(input.normalizedInputSourceCount == 1)
    #expect(input.targetLocalPresentationGateCount == 1)
    #expect(input.wakeRequesterCount == 1)
    #expect(input.applicationAndMutationDomainsAreDistinct)
    #expect(input.wakeRequesterIsNonReentrant)
}

@Test func endpointConfigurationPreservesTheExactInertProjection() {
    let effective = resolveNRFPresentation()
    guard let effective else {
        Issue.record("exact nRF capability projection must resolve")
        return
    }
    let descriptor = RasterSurfaceDescriptor(
        bounds: Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 480, height: 320)!
        )!,
        encoding: .rgb565BigEndian,
        bytesPerRow: 960,
        realization: .tiled,
        regionWidth: 480,
        regionHeight: 4
    )!
    let payload = RasterPayloadLimits(
        maximumRasterBytes: 3_840,
        maximumPayloadBytes: 3_840,
        maximumRegionsPerPayload: 1,
        maximumRegionSubmissionsPerFrame: 80,
        maximumTileVisitsPerFrame: 80,
        maximumInFlightPayloads: 1,
        maximumGlyphRasterBytes: 3_840,
        maximumStrokeWorkspaceBytes: 3_840
    )!
    let endpoint = HostEndpointConfiguration(
        effectivePresentation: effective,
        descriptor: descriptor,
        payloadLimits: payload,
        surfaceWritableCapacityBytes: 3_840,
        displaySubmissionLifetime: .synchronousBorrow,
        displayHandoff: .synchronous,
        displayMaximumInFlightPayloads: 1,
        displayMaximumInFlightBytes: 3_840,
        textRasterRealization: RasterRealizationID(rawValue: 1),
        healthOwnerCount: 1,
        endpointAndDisplayShareHealthOwner: true
    )

    #expect(endpoint.effectivePresentation == effective)
    #expect(endpoint.descriptor == descriptor)
    #expect(endpoint.payloadLimits == payload)
    #expect(endpoint.surfaceWritableCapacityBytes == 3_840)
    #expect(endpoint.displaySubmissionLifetime == .synchronousBorrow)
    #expect(endpoint.displayHandoff == .synchronous)
    #expect(endpoint.displayMaximumInFlightPayloads == 1)
    #expect(endpoint.displayMaximumInFlightBytes == 3_840)
    #expect(endpoint.textRasterRealization == RasterRealizationID(rawValue: 1))
    #expect(endpoint.healthOwnerCount == 1)
    #expect(endpoint.endpointAndDisplayShareHealthOwner)
}

private func resolveNRFPresentation() -> EffectiveRasterPresentation? {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    let extent = preset.capabilityRequirement.extent
    let realization = RasterRealizationContribution(
        kind: .tiled,
        operations: preset.capabilityRequirement.operations,
        operationStream: .synchronousBorrowedOneShot,
        encodings: .rgb565BigEndian,
        producedSubmissionLifetimes: .synchronousBorrow,
        maximumExtent: extent,
        maximumRegionWidth: 480,
        maximumRegionHeight: 4,
        rowByteAlignment: 2,
        maximumRasterBytes: .init(rawValue: 3_840),
        maximumPayloadBytes: .init(rawValue: 3_840)
    )!
    var contributions = RasterPresentationContributions()
    _ = contributions.insert(
        .renderProducer(
            RenderProducerContribution(
                operations: preset.capabilityRequirement.operations,
                operationStream: .synchronousBorrowedOneShot
            )!
        )
    )
    _ = contributions.insert(
        .rasterBackend(RasterBackendContribution(primary: realization, alternate: nil)!)
    )
    _ = contributions.insert(
        .surfaceDisplay(
            SurfaceDisplayContribution(
                extent: extent,
                encodings: .rgb565BigEndian,
                acceptedSubmissionLifetimes: .synchronousBorrow,
                handoffs: .synchronous,
                maximumRegionWidth: 480,
                maximumRegionHeight: 4,
                rowByteAlignment: 2,
                maximumInFlightCount: 1,
                maximumInFlightBytes: .init(rawValue: 3_840)
            )!
        )
    )
    _ = contributions.insert(
        .hostResourcePolicy(
            RasterPresentationPolicy(
                maximumRasterBytes: .init(rawValue: 3_840),
                maximumPayloadBytes: .init(rawValue: 3_840),
                maximumInFlightBytes: .init(rawValue: 3_840),
                allowedRealizations: .tiled,
                allowedEncodings: .rgb565BigEndian,
                preferredRealization: .tiled,
                preferredEncoding: .rgb565BigEndian
            )!
        )
    )
    var workspace = RasterPresentationResolverWorkspace()!
    guard
        case .available(let effective) = RasterPresentationResolver.resolve(
            requirement: preset.capabilityRequirement,
            contributions: contributions,
            workspace: &workspace
        )
    else { return nil }
    return effective
}
