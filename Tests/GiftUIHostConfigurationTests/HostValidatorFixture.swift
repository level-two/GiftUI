import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIRuntimeCore
import GiftUISurfaceCore
import GiftUITextResources

@testable import GiftUIHostConfiguration

struct HostValidatorGraphFixture: HostComponentGraphView {
    let records: [HostComponentRecord]
    var count: UInt8 { UInt8(records.count) }

    func record(at index: UInt8) -> HostComponentRecord? {
        guard Int(index) < records.count else { return nil }
        return records[Int(index)]
    }
}

struct HostValidatorPolicyFixture: MVPHostResidualPolicyTable {
    var fatalHookIsAvailable: Bool { false }

    func allowed(
        for context: HostResidualPolicyContext
    ) -> GiftUIAllowedDispositions {
        switch context {
        case .presentationBackpressure, .presentationRetryableRefusal:
            [.requestPacedRetry, .quiesceAffectedScope]
        case .containedCandidateFailure:
            [.continueOperation, .quiesceAffectedScope]
        case .staleInputOrRegistration:
            .continueOperation
        case .safetyNotProven:
            [.quiesceAffectedScope, .invokeFatalHook]
        case .startupValidation, .activation, .presentationUnavailable,
            .backendOperationalFailure:
            .quiesceAffectedScope
        }
    }

    func selection(
        for context: HostResidualPolicyContext
    ) -> GiftUIResidualDisposition {
        switch context {
        case .presentationBackpressure, .presentationRetryableRefusal:
            .requestPacedRetry
        case .containedCandidateFailure, .staleInputOrRegistration:
            .continueOperation
        case .startupValidation, .activation, .presentationUnavailable,
            .backendOperationalFailure, .safetyNotProven:
            .quiesceAffectedScope
        }
    }
}

func makeHostValidatorGraph() -> HostValidatorGraphFixture {
    HostValidatorGraphFixture(
        records: (UInt8(0) ... 17).map { rawValue in
            HostComponentRecord(
                role: HostComponentRole(rawValue: rawValue)!,
                dependencies: rawValue == 0
                    ? HostComponentRoleSet(rawValue: 0)
                    : HostComponentRoleSet(
                        HostComponentRole(rawValue: rawValue - 1)!
                    )
            )
        }
    )
}

func makeValidHostValidator(
    runtimeProfileValidation: RuntimeProfileValidationResult? = nil,
    textResourceValidation: TextResourceValidationResult = .valid,
    capabilityContributions: RasterPresentationContributions? = nil,
    capabilityWorkspace: RasterPresentationResolverWorkspace? = nil
) -> CheckedMVPHostConfigurationValidator<
    HostValidatorGraphFixture, HostValidatorPolicyFixture
> {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    let validatedAudit = preset.validatedStorageAudit()
    let audit: RuntimeStorageAudit
    switch validatedAudit {
    case .valid(let value):
        audit = value
    case .invalid:
        fatalError("generated fixture audit must be valid")
    }
    let capability = makeHostCapabilityFixture(requirement: preset.capabilityRequirement)
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

    return CheckedMVPHostConfigurationValidator(
        structuralConfiguration: HostStructuralConfiguration(
            kind: preset.kind,
            profile: preset.profile,
            runtimeLimits: preset.runtimeLimits,
            runtimeAudit: audit,
            cardinality: preset.cardinality,
            workload: preset.workload,
            pacing: preset.pacing
        ),
        runtimeProfileValidation: runtimeProfileValidation ?? validatedAudit,
        componentGraph: makeHostValidatorGraph(),
        textResourceValidation: textResourceValidation,
        capabilityRequirement: preset.capabilityRequirement,
        capabilityContributions: capabilityContributions ?? capability.contributions,
        capabilityWorkspace: capabilityWorkspace ?? RasterPresentationResolverWorkspace()!,
        endpoint: HostEndpointConfiguration(
            effectivePresentation: capability.effective,
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
        ),
        actionAndModel: HostActionModelConfiguration(
            firstActionCode: 0,
            lastActionCode: 5,
            handlerCount: 1,
            rootModelTargetCount: 1,
            maximumNonTransitionPublicationsPerAction: 1
        ),
        inputAndWake: HostInputWakeConfiguration(
            normalizedInputSourceCount: 1,
            targetLocalPresentationGateCount: 1,
            wakeRequesterCount: 1,
            applicationAndMutationDomainsAreDistinct: true,
            wakeRequesterIsNonReentrant: true
        ),
        residualPolicyTable: HostValidatorPolicyFixture()
    )
}

func makeHostCapabilityValues(
    requirement: RasterPresentationRequirement
) -> [RasterPresentationContribution] {
    let extent = requirement.extent
    let realization = RasterRealizationContribution(
        kind: .tiled,
        operations: requirement.operations,
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
    return [
        .renderProducer(
            RenderProducerContribution(
                operations: requirement.operations,
                operationStream: .synchronousBorrowedOneShot
            )!
        ),
        .rasterBackend(
            RasterBackendContribution(primary: realization, alternate: nil)!
        ),
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
        ),
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
        ),
    ]
}

func makeHostCapabilityContributions(
    _ values: [RasterPresentationContribution]
) -> RasterPresentationContributions {
    var contributions = RasterPresentationContributions()
    for value in values {
        _ = contributions.insert(value)
    }
    return contributions
}

private func makeHostCapabilityFixture(
    requirement: RasterPresentationRequirement
) -> (
    contributions: RasterPresentationContributions,
    effective: EffectiveRasterPresentation
) {
    let contributions = makeHostCapabilityContributions(
        makeHostCapabilityValues(requirement: requirement)
    )
    var workspace = RasterPresentationResolverWorkspace()!
    guard
        case .available(let effective) = RasterPresentationResolver.resolve(
            requirement: requirement,
            contributions: contributions,
            workspace: &workspace
        )
    else {
        fatalError("exact fixture capability must resolve")
    }
    return (contributions, effective)
}
