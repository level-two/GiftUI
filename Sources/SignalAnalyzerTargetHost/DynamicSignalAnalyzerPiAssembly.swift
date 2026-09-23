import GiftUI
import GiftUICapabilities
import GiftUIHostConfiguration
import GiftUIRasterCore
import GiftUIReferenceTextResources
import GiftUIRenderCore
import GiftUIRuntimeCore
import GiftUISurfaceCore
import GiftUITextResources

private struct DynamicSignalAnalyzerPiComponentGraph: HostComponentGraphView {
    let count = HostComponentGraphValidation.requiredRoleCount

    func record(at index: UInt8) -> HostComponentRecord? {
        guard index < count, let role = HostComponentRole(rawValue: index) else {
            return nil
        }
        let dependencies =
            index == 0
            ? HostComponentRoleSet(rawValue: 0)
            : HostComponentRoleSet(HostComponentRole(rawValue: index - 1)!)
        return HostComponentRecord(role: role, dependencies: dependencies)
    }
}

/// Produces the immutable Dynamic Pi assembly report before any Linux device
/// owner is opened.
package enum DynamicSignalAnalyzerPiAssembly {
    package static func validate() -> HostValidationResult {
        let preset = GeneratedSignalAnalyzerPresets.raspberryPiDynamic()
        let runtimeValidation = preset.validatedStorageAudit()
        let audit: RuntimeStorageAudit
        switch runtimeValidation {
        case .valid(let value):
            audit = value
        case .invalid(let error):
            return .invalid(stage: .runtimeProfile, error: .invalidRuntimeProfile(error))
        }
        guard let capability = capability(for: preset),
            let descriptor = descriptor(),
            let payloadLimits = payloadLimits()
        else { return .invalid(stage: .capability, error: .invariantViolation) }

        let resources = GiftUIReferenceTextResources.targetPackage
        let textValidation = TextResourceValidator.validate(
            resources,
            requiring: RasterRealizationID(rawValue: 0)
        )
        var validator = CheckedMVPHostConfigurationValidator(
            structuralConfiguration: HostStructuralConfiguration(
                kind: preset.kind,
                profile: preset.profile,
                runtimeLimits: preset.runtimeLimits,
                runtimeAudit: audit,
                cardinality: preset.cardinality,
                workload: preset.workload,
                pacing: preset.pacing
            ),
            runtimeProfileValidation: runtimeValidation,
            componentGraph: DynamicSignalAnalyzerPiComponentGraph(),
            textResourceValidation: textValidation,
            selectedTextRasterRealization: RasterRealizationID(rawValue: 0),
            capabilityRequirement: preset.capabilityRequirement,
            capabilityContributions: capability.contributions,
            capabilityWorkspace: RasterPresentationResolverWorkspace()!,
            endpoint: HostEndpointConfiguration(
                effectivePresentation: capability.effective,
                descriptor: descriptor,
                payloadLimits: payloadLimits,
                surfaceWritableCapacityBytes: 7_680,
                displaySubmissionLifetime: .synchronousBorrow,
                displayHandoff: .synchronous,
                displayMaximumInFlightPayloads: 1,
                displayMaximumInFlightBytes: 7_680,
                textRasterRealization: RasterRealizationID(rawValue: 0),
                healthOwnerCount: 1,
                endpointAndDisplayShareHealthOwner: true
            ),
            actionAndModel: HostActionModelConfiguration(
                firstActionCode: 0,
                lastActionCode: 5,
                handlerCount: 1,
                rootModelTargetCount: 1,
                sourceMinimumTransitionSpacingMicroseconds:
                    preset.pacing.minimumAcceptedTransitionSpacingMicroseconds,
                maximumSourceCallbacksPerServiceWindow:
                    preset.pacing.maximumTransitionFactsPerServiceWindow,
                maximumCallbacksPerAction: 1,
                maximumRepositoryCallbacksPerAction: 1,
                maximumUseCaseCallbacksPerAction: 1,
                maximumNonTransitionPublicationsPerAction: 1,
                applicationExecutorFactLimit: maximumFacts(in: preset.pacing),
                factAdmissionAdapterCount: 1,
                targetGenerationIsPublishable: true,
                actionHandlerIsTotal: true,
                retainsOwnerReferences: false,
                callbacksAreReentrant: false
            ),
            inputAndWake: HostInputWakeConfiguration(
                normalizedInputSourceCount: 1,
                targetLocalPresentationGateCount: 1,
                wakeRequesterCount: 1,
                applicationAndMutationDomainsAreDistinct: true,
                wakeRequesterIsNonReentrant: true
            ),
            residualPolicyTable: FixedMVPHostResidualPolicyTable(
                fatalHookIsAvailable: false
            )
        )
        return validator.validate()
    }

    private static func maximumFacts(in pacing: HostPacingPolicy) -> UInt16 {
        pacing.maximumTransitionFactsPerServiceWindow
            + UInt16(pacing.maximumBootstrapFactsPerServiceWindow)
            + UInt16(pacing.maximumActionInducedFactsPerServiceWindow)
    }

    private static func descriptor() -> RasterSurfaceDescriptor? {
        RasterSurfaceDescriptor(
            bounds: Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 240, height: 240)!
            )!,
            encoding: .rgb565BigEndian,
            bytesPerRow: 480,
            realization: .tiled,
            regionWidth: 240,
            regionHeight: 16
        )
    }

    private static func payloadLimits() -> RasterPayloadLimits? {
        // Approved 150-operation stream over 15 tile rows and 57,600 pixels.
        RasterPayloadLimits(
            maximumRasterBytes: 7_680,
            maximumPayloadBytes: 7_680,
            maximumRegionsPerPayload: 16,
            maximumRegionSubmissionsPerFrame: 8_640_000,
            maximumTileVisitsPerFrame: 2_250,
            maximumInFlightPayloads: 1,
            maximumGlyphRasterBytes: 7_680,
            maximumStrokeWorkspaceBytes: 1
        )
    }

    private static func capability(
        for preset: GeneratedSignalAnalyzerPreset
    ) -> (
        contributions: RasterPresentationContributions,
        effective: EffectiveRasterPresentation
    )? {
        let bytes = CapabilityByteCount(rawValue: 7_680)
        guard
            let realization = RasterRealizationContribution(
                kind: .tiled,
                operations: preset.capabilityRequirement.operations,
                operationStream: .synchronousBorrowedOneShot,
                encodings: .rgb565BigEndian,
                producedSubmissionLifetimes: .synchronousBorrow,
                maximumExtent: preset.capabilityRequirement.extent,
                maximumRegionWidth: 240,
                maximumRegionHeight: 16,
                rowByteAlignment: 2,
                maximumRasterBytes: bytes,
                maximumPayloadBytes: bytes
            ),
            let render = RenderProducerContribution(
                operations: preset.capabilityRequirement.operations,
                operationStream: .synchronousBorrowedOneShot
            ), let backend = RasterBackendContribution(primary: realization, alternate: nil),
            let display = SurfaceDisplayContribution(
                extent: preset.capabilityRequirement.extent,
                encodings: .rgb565BigEndian,
                acceptedSubmissionLifetimes: .synchronousBorrow,
                handoffs: .synchronous,
                maximumRegionWidth: 240,
                maximumRegionHeight: 16,
                rowByteAlignment: 2,
                maximumInFlightCount: 1,
                maximumInFlightBytes: bytes
            ),
            let policy = RasterPresentationPolicy(
                maximumRasterBytes: bytes,
                maximumPayloadBytes: bytes,
                maximumInFlightBytes: bytes,
                allowedRealizations: .tiled,
                allowedEncodings: .rgb565BigEndian,
                preferredRealization: .tiled,
                preferredEncoding: .rgb565BigEndian
            )
        else { return nil }

        var contributions = RasterPresentationContributions()
        _ = contributions.insert(.renderProducer(render))
        _ = contributions.insert(.rasterBackend(backend))
        _ = contributions.insert(.surfaceDisplay(display))
        _ = contributions.insert(.hostResourcePolicy(policy))
        var workspace = RasterPresentationResolverWorkspace()!
        guard
            case .available(let effective) = RasterPresentationResolver.resolve(
                requirement: preset.capabilityRequirement,
                contributions: contributions,
                workspace: &workspace
            )
        else { return nil }
        return (contributions, effective)
    }
}
