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
    let overriddenContext: HostResidualPolicyContext?
    let overriddenAllowed: GiftUIAllowedDispositions?
    let overriddenSelection: GiftUIResidualDisposition?
    let fatalHookIsAvailable: Bool

    init(
        overriddenContext: HostResidualPolicyContext? = nil,
        overriddenAllowed: GiftUIAllowedDispositions? = nil,
        overriddenSelection: GiftUIResidualDisposition? = nil,
        fatalHookIsAvailable: Bool = false
    ) {
        self.overriddenContext = overriddenContext
        self.overriddenAllowed = overriddenAllowed
        self.overriddenSelection = overriddenSelection
        self.fatalHookIsAvailable = fatalHookIsAvailable
    }

    func allowed(
        for context: HostResidualPolicyContext
    ) -> GiftUIAllowedDispositions {
        if context == overriddenContext, let overriddenAllowed {
            return overriddenAllowed
        }
        return switch context {
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
        if context == overriddenContext, let overriddenSelection {
            return overriddenSelection
        }
        return switch context {
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
    componentGraph: HostValidatorGraphFixture? = nil,
    runtimeProfileValidation: RuntimeProfileValidationResult? = nil,
    workload: SignalAnalyzerHostWorkload? = nil,
    textResourceValidation: TextResourceValidationResult = .valid,
    selectedTextRasterRealization: RasterRealizationID = RasterRealizationID(
        rawValue: 1
    ),
    capabilityContributions: RasterPresentationContributions? = nil,
    capabilityWorkspace: RasterPresentationResolverWorkspace? = nil,
    endpoint: HostEndpointConfiguration? = nil,
    actionAndModel: HostActionModelConfiguration? = nil,
    inputAndWake: HostInputWakeConfiguration? = nil,
    residualPolicyTable: HostValidatorPolicyFixture = HostValidatorPolicyFixture()
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
    let defaultEndpoint = makeHostEndpointFixture(
        effectivePresentation: capability.effective,
        textRasterRealization: RasterRealizationID(rawValue: 1)
    )

    return CheckedMVPHostConfigurationValidator(
        structuralConfiguration: HostStructuralConfiguration(
            kind: preset.kind,
            profile: preset.profile,
            runtimeLimits: preset.runtimeLimits,
            runtimeAudit: audit,
            cardinality: preset.cardinality,
            workload: workload ?? preset.workload,
            pacing: preset.pacing
        ),
        runtimeProfileValidation: runtimeProfileValidation ?? validatedAudit,
        componentGraph: componentGraph ?? makeHostValidatorGraph(),
        textResourceValidation: textResourceValidation,
        selectedTextRasterRealization: selectedTextRasterRealization,
        capabilityRequirement: preset.capabilityRequirement,
        capabilityContributions: capabilityContributions ?? capability.contributions,
        capabilityWorkspace: capabilityWorkspace ?? RasterPresentationResolverWorkspace()!,
        endpoint: endpoint ?? defaultEndpoint,
        actionAndModel: actionAndModel ?? makeHostActionModelFixture(),
        inputAndWake: inputAndWake ?? makeHostInputWakeFixture(),
        residualPolicyTable: residualPolicyTable
    )
}

func makeHostActionModelFixture(
    firstActionCode: UInt16 = 0,
    lastActionCode: UInt16 = 5,
    handlerCount: UInt8 = 1,
    rootModelTargetCount: UInt8 = 1,
    maximumNonTransitionPublicationsPerAction: UInt8 = 1
) -> HostActionModelConfiguration {
    HostActionModelConfiguration(
        firstActionCode: firstActionCode,
        lastActionCode: lastActionCode,
        handlerCount: handlerCount,
        rootModelTargetCount: rootModelTargetCount,
        maximumNonTransitionPublicationsPerAction:
            maximumNonTransitionPublicationsPerAction
    )
}

func makeHostInputWakeFixture(
    normalizedInputSourceCount: UInt16 = 1,
    targetLocalPresentationGateCount: UInt8 = 1,
    wakeRequesterCount: UInt8 = 1,
    applicationAndMutationDomainsAreDistinct: Bool = true,
    wakeRequesterIsNonReentrant: Bool = true
) -> HostInputWakeConfiguration {
    HostInputWakeConfiguration(
        normalizedInputSourceCount: normalizedInputSourceCount,
        targetLocalPresentationGateCount: targetLocalPresentationGateCount,
        wakeRequesterCount: wakeRequesterCount,
        applicationAndMutationDomainsAreDistinct:
            applicationAndMutationDomainsAreDistinct,
        wakeRequesterIsNonReentrant: wakeRequesterIsNonReentrant
    )
}

func makeHostEndpointFixture(
    effectivePresentation: EffectiveRasterPresentation? = nil,
    descriptor: RasterSurfaceDescriptor? = nil,
    payloadLimits: RasterPayloadLimits? = nil,
    surfaceWritableCapacityBytes: UInt32 = 3_840,
    displaySubmissionLifetime: SubmissionLifetime = .synchronousBorrow,
    displayHandoff: SubmissionHandoff = .synchronous,
    displayMaximumInFlightPayloads: UInt8 = 1,
    displayMaximumInFlightBytes: UInt32 = 3_840,
    textRasterRealization: RasterRealizationID = RasterRealizationID(rawValue: 1),
    healthOwnerCount: UInt8 = 1,
    endpointAndDisplayShareHealthOwner: Bool = true
) -> HostEndpointConfiguration {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    let effective =
        effectivePresentation
        ?? makeHostCapabilityFixture(
            requirement: preset.capabilityRequirement
        ).effective
    let defaultDescriptor = RasterSurfaceDescriptor(
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
    let defaultPayload = RasterPayloadLimits(
        maximumRasterBytes: 3_840,
        maximumPayloadBytes: 3_840,
        maximumRegionsPerPayload: 1,
        maximumRegionSubmissionsPerFrame: 80,
        maximumTileVisitsPerFrame: 80,
        maximumInFlightPayloads: 1,
        maximumGlyphRasterBytes: 3_840,
        maximumStrokeWorkspaceBytes: 3_840
    )!

    return HostEndpointConfiguration(
        effectivePresentation: effective,
        descriptor: descriptor ?? defaultDescriptor,
        payloadLimits: payloadLimits ?? defaultPayload,
        surfaceWritableCapacityBytes: surfaceWritableCapacityBytes,
        displaySubmissionLifetime: displaySubmissionLifetime,
        displayHandoff: displayHandoff,
        displayMaximumInFlightPayloads: displayMaximumInFlightPayloads,
        displayMaximumInFlightBytes: displayMaximumInFlightBytes,
        textRasterRealization: textRasterRealization,
        healthOwnerCount: healthOwnerCount,
        endpointAndDisplayShareHealthOwner: endpointAndDisplayShareHealthOwner
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
