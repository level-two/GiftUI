import GiftUI
import GiftUICapabilities
import GiftUIHostConfiguration
import GiftUIRasterCore
import GiftUIReferenceTextResources
import GiftUIRenderCore
import GiftUIRuntimeCore
import GiftUISurfaceCore
import GiftUITextResources

private struct StaticSignalAnalyzerNRFComponentGraph: HostComponentGraphView {
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

/// Produces the immutable Static nRF assembly report before any device or
/// application owner is constructed.
package enum StaticSignalAnalyzerNRFAssembly {
    package static func validate() -> HostValidationResult {
        let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
        guard hasExactGeneratedProjection(preset) else {
            return .invalid(stage: .runtimeProfile, error: .invariantViolation)
        }
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
            componentGraph: StaticSignalAnalyzerNRFComponentGraph(),
            textResourceValidation: textValidation,
            selectedTextRasterRealization: RasterRealizationID(rawValue: 0),
            capabilityRequirement: preset.capabilityRequirement,
            capabilityContributions: capability.contributions,
            capabilityWorkspace: RasterPresentationResolverWorkspace()!,
            endpoint: HostEndpointConfiguration(
                effectivePresentation: capability.effective,
                descriptor: descriptor,
                payloadLimits: payloadLimits,
                surfaceWritableCapacityBytes: 3_840,
                displaySubmissionLifetime: .synchronousBorrow,
                displayHandoff: .synchronous,
                displayMaximumInFlightPayloads: 1,
                displayMaximumInFlightBytes: 3_840,
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

    private static func hasExactGeneratedProjection(
        _ preset: GeneratedSignalAnalyzerPreset
    ) -> Bool {
        guard let root = preset.staticRoot else { return false }
        return preset.kind == .nrf52840Static
            && preset.profile == .static
            && preset.raster.logicalWidth == 480
            && preset.raster.logicalHeight == 320
            && preset.raster.regionHeight == 4
            && preset.raster.bytesPerRow == 960
            && preset.raster.maximumRasterBytes == 3_840
            && preset.raster.maximumPayloadBytes == 3_840
            && preset.raster.maximumInFlightPayloads == 1
            && root.structuralIdentity == 1_410_692_621
            && root.declarationOrdinal == 0
            && root.modelStorageSlots == 2
            && root.locationCapacity == 1
            && root.registrationCapacity == 1
            && root.replacementCapacity == 1
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
                size: Size(width: 480, height: 320)!
            )!,
            encoding: .rgb565BigEndian,
            bytesPerRow: 960,
            realization: .tiled,
            regionWidth: 480,
            regionHeight: 4
        )
    }

    private static func payloadLimits() -> RasterPayloadLimits? {
        RasterPayloadLimits(
            maximumRasterBytes: 3_840,
            maximumPayloadBytes: 3_840,
            maximumRegionsPerPayload: 1,
            maximumRegionSubmissionsPerFrame: 80,
            maximumTileVisitsPerFrame: 80,
            maximumInFlightPayloads: 1,
            maximumGlyphRasterBytes: 3_840,
            maximumStrokeWorkspaceBytes: 3_840
        )
    }

    private static func capability(
        for preset: GeneratedSignalAnalyzerPreset
    ) -> (
        contributions: RasterPresentationContributions,
        effective: EffectiveRasterPresentation
    )? {
        let bytes = CapabilityByteCount(rawValue: 3_840)
        guard
            let realization = RasterRealizationContribution(
                kind: .tiled,
                operations: preset.capabilityRequirement.operations,
                operationStream: .synchronousBorrowedOneShot,
                encodings: .rgb565BigEndian,
                producedSubmissionLifetimes: .synchronousBorrow,
                maximumExtent: preset.capabilityRequirement.extent,
                maximumRegionWidth: 480,
                maximumRegionHeight: 4,
                rowByteAlignment: 2,
                maximumRasterBytes: bytes,
                maximumPayloadBytes: bytes
            ),
            let render = RenderProducerContribution(
                operations: preset.capabilityRequirement.operations,
                operationStream: .synchronousBorrowedOneShot
            ),
            let backend = RasterBackendContribution(primary: realization, alternate: nil),
            let display = SurfaceDisplayContribution(
                extent: preset.capabilityRequirement.extent,
                encodings: .rgb565BigEndian,
                acceptedSubmissionLifetimes: .synchronousBorrow,
                handoffs: .synchronous,
                maximumRegionWidth: 480,
                maximumRegionHeight: 4,
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
