#if !GIFTUI_HOST_AUDIT_COMPARISON_ORACLE
#error("Host validation oracle requires the matching defining-module audit comparison controls")
#endif
import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIRuntimeCore
import GiftUISurfaceCore
import GiftUITextResources
@testable import GiftUIHostConfiguration

// Host-only independent old/new oracle; allocating transcripts are not a Static allocation/resource probe.
final class P08HostValidationTrace { var events: [Int] = [] }


struct P08OriginalCheckedHostValidator<Graph, Policy>:
    MVPHostConfigurationValidator, ~Copyable
where
    Graph: HostComponentGraphView,
    Policy: MVPHostResidualPolicyTable
{
    let structuralConfiguration: HostStructuralConfiguration
    let runtimeProfileValidation: RuntimeProfileValidationResult
    let componentGraph: Graph
    let textResourceValidation: TextResourceValidationResult
    let selectedTextRasterRealization: RasterRealizationID
    let capabilityRequirement: RasterPresentationRequirement
    let capabilityContributions: RasterPresentationContributions
    var capabilityWorkspace: RasterPresentationResolverWorkspace
    let endpoint: HostEndpointConfiguration
    let actionAndModel: HostActionModelConfiguration
    let inputAndWake: HostInputWakeConfiguration
    let residualPolicyTable: Policy
    private(set) var validationAccessLedger: HostValidationAccessLedger
    private var stateGuard: P08OriginalHostValidationStateGuard

    init(
        structuralConfiguration: HostStructuralConfiguration,
        runtimeProfileValidation: RuntimeProfileValidationResult,
        componentGraph: consuming Graph,
        textResourceValidation: TextResourceValidationResult,
        selectedTextRasterRealization: RasterRealizationID,
        capabilityRequirement: RasterPresentationRequirement,
        capabilityContributions: RasterPresentationContributions,
        capabilityWorkspace: RasterPresentationResolverWorkspace,
        endpoint: HostEndpointConfiguration,
        actionAndModel: HostActionModelConfiguration,
        inputAndWake: HostInputWakeConfiguration,
        residualPolicyTable: consuming Policy
    ) {
        self.structuralConfiguration = structuralConfiguration
        self.runtimeProfileValidation = runtimeProfileValidation
        self.componentGraph = consume componentGraph
        self.textResourceValidation = textResourceValidation
        self.selectedTextRasterRealization = selectedTextRasterRealization
        self.capabilityRequirement = capabilityRequirement
        self.capabilityContributions = capabilityContributions
        self.capabilityWorkspace = capabilityWorkspace
        self.endpoint = endpoint
        self.actionAndModel = actionAndModel
        self.inputAndWake = inputAndWake
        self.residualPolicyTable = consume residualPolicyTable
        validationAccessLedger = HostValidationAccessLedger()
        stateGuard = P08OriginalHostValidationStateGuard()
    }

    mutating func validate() -> HostValidationResult {
        if let repeated = stateGuard.begin() { return repeated }
        guard enter(.graph) else { return orderViolation() }
        if let error = HostComponentGraphValidation.validate(componentGraph) {
            return .invalid(stage: .graph, error: error)
        }
        guard enter(.runtimeProfile) else { return orderViolation() }
        if let error = validateRuntimeProfile() {
            return .invalid(stage: .runtimeProfile, error: error)
        }
        guard enter(.textResources) else { return orderViolation() }
        if case .invalid(let error) = textResourceValidation {
            return .invalid(
                stage: .textResources,
                error: .invalidTextResources(error)
            )
        }
        guard enter(.workload) else { return orderViolation() }
        if let error = validateWorkload() {
            return .invalid(
                stage: .workload,
                error: error
            )
        }

        guard enter(.capability) else { return orderViolation() }
        let effective: EffectiveRasterPresentation
        switch RasterPresentationResolver.resolve(
            requirement: capabilityRequirement,
            contributions: capabilityContributions,
            workspace: &capabilityWorkspace
        ) {
        case .available(let value):
            effective = value
        case .unavailable(let error):
            return .invalid(
                stage: .capability,
                error: .capabilityUnavailable(error)
            )
        }
        guard enter(.endpoint) else { return orderViolation() }
        if let error = HostEndpointStartupValidation.validateInert(
            endpoint,
            effectivePresentation: effective,
            selectedTextRasterRealization: selectedTextRasterRealization
        ) {
            return .invalid(
                stage: .endpoint,
                error: error
            )
        }
        guard enter(.actionAndModel) else { return orderViolation() }
        if let error = HostApplicationStartupValidation.validateActionAndModel(
            actionAndModel,
            structural: structuralConfiguration
        ) {
            return .invalid(stage: .actionAndModel, error: error)
        }
        guard enter(.inputAndWake) else { return orderViolation() }
        if let error = HostApplicationStartupValidation.validateInputAndWake(
            inputAndWake,
            structural: structuralConfiguration
        ) {
            return .invalid(stage: .inputAndWake, error: error)
        }
        guard enter(.policy) else { return orderViolation() }
        guard HostResidualPolicyTableValidation.validate(residualPolicyTable)
        else {
            return .invalid(stage: .policy, error: .incompleteFailurePolicy)
        }

        let pacing = structuralConfiguration.pacing
        let maximumFacts =
            UInt16(pacing.maximumBootstrapFactsPerServiceWindow)
            + UInt16(pacing.maximumActionInducedFactsPerServiceWindow)
            + pacing.maximumTransitionFactsPerServiceWindow
        return .valid(
            HostAssemblyReport(
                kind: structuralConfiguration.kind,
                profile: structuralConfiguration.profile,
                storageAudit: structuralConfiguration.runtimeAudit,
                capabilitySnapshot: CapabilitySnapshot(
                    rasterPresentation: effective
                ),
                effectivePresentation: effective,
                drawingPlanOperationLimit:
                    structuralConfiguration.workload.drawing
                    .normalizedStrokeOperations,
                minimumSinkOperationCapacity:
                    structuralConfiguration.workload.ordinaryRenderOperations
                    + structuralConfiguration.workload.drawing
                    .normalizedStrokeOperations,
                cardinality: structuralConfiguration.cardinality,
                minimumFrameIntervalMicroseconds:
                    pacing.minimumFrameIntervalMicroseconds,
                maximumFactServiceLatencyMicroseconds:
                    pacing.maximumFactServiceLatencyMicroseconds,
                minimumAcceptedTransitionSpacingMicroseconds:
                    pacing.minimumAcceptedTransitionSpacingMicroseconds,
                maximumCompactFactsPerServiceWindow: maximumFacts,
                maximumRetryableRefusals: pacing.maximumRetryableRefusals
            )
        )
    }

    private mutating func enter(_ stage: HostValidationStage) -> Bool {
        validationAccessLedger.enter(stage)
    }

    private func orderViolation() -> HostValidationResult {
        .invalid(stage: .graph, error: .invariantViolation)
    }

    private borrowing func validateRuntimeProfile() -> HostConfigurationError? {
        let configuration = structuralConfiguration
        let validatedAudit: RuntimeStorageAudit
        switch runtimeProfileValidation {
        case .valid(let audit):
            validatedAudit = audit
        case .invalid(let error):
            return .invalidRuntimeProfile(error)
        }
        let expectedProfile: RuntimeProfileKind =
            switch configuration.kind {
            case .macOSDynamic, .raspberryPiDynamic: .dynamic
            case .macOSStatic, .nrf52840Static: .static
            }
        guard configuration.profile == expectedProfile,
            validatedAudit.profile == expectedProfile
        else { return .profileMismatch }
        guard validatedAudit == configuration.runtimeAudit,
            validatedAudit.limits == configuration.runtimeLimits
        else {
            return .invalidRuntimeProfile(.invariantViolation)
        }
        return nil
    }

    private borrowing func validateWorkload() -> HostConfigurationError? {
        let configuration = structuralConfiguration
        return SignalAnalyzerWorkloadStartupValidation.validate(
            configuration: configuration
        )
    }
}

struct P08OriginalHostValidationStateGuard: ~Copyable {
    private var hasBegun = false

    #if GIFTUI_STARTUP_QUALIFICATION
        @_noAllocation
    #endif
    init() {}

    #if GIFTUI_STARTUP_QUALIFICATION
        @_noAllocation
    #endif
    mutating func begin() -> HostValidationResult? {
        guard !hasBegun else {
            return .invalid(stage: .graph, error: .invariantViolation)
        }
        hasBegun = true
        return nil
    }
}

struct P08HostValidationInputs {
    var structuralConfiguration: HostStructuralConfiguration
    var runtimeProfileValidation: RuntimeProfileValidationResult
    var componentGraph: P08HostValidatorGraphFixture
    var textResourceValidation: TextResourceValidationResult
    var selectedTextRasterRealization: RasterRealizationID
    var capabilityRequirement: RasterPresentationRequirement
    var capabilityContributions: RasterPresentationContributions
    var capabilityWorkspace: RasterPresentationResolverWorkspace
    var endpoint: HostEndpointConfiguration
    var actionAndModel: HostActionModelConfiguration
    var inputAndWake: HostInputWakeConfiguration
    var residualPolicyTable: P08HostValidatorPolicyFixture
    func original() -> P08OriginalCheckedHostValidator<P08HostValidatorGraphFixture, P08HostValidatorPolicyFixture> {
        .init(
            structuralConfiguration: structuralConfiguration,
            runtimeProfileValidation: runtimeProfileValidation,
            componentGraph: componentGraph,
            textResourceValidation: textResourceValidation,
            selectedTextRasterRealization: selectedTextRasterRealization,
            capabilityRequirement: capabilityRequirement,
            capabilityContributions: capabilityContributions,
            capabilityWorkspace: capabilityWorkspace,
            endpoint: endpoint,
            actionAndModel: actionAndModel,
            inputAndWake: inputAndWake,
            residualPolicyTable: residualPolicyTable
        )
    }
    func candidate() -> CheckedMVPHostConfigurationValidator<P08HostValidatorGraphFixture, P08HostValidatorPolicyFixture> {
        .init(
            structuralConfiguration: structuralConfiguration,
            runtimeProfileValidation: runtimeProfileValidation,
            componentGraph: componentGraph,
            textResourceValidation: textResourceValidation,
            selectedTextRasterRealization: selectedTextRasterRealization,
            capabilityRequirement: capabilityRequirement,
            capabilityContributions: capabilityContributions,
            capabilityWorkspace: capabilityWorkspace,
            endpoint: endpoint,
            actionAndModel: actionAndModel,
            inputAndWake: inputAndWake,
            residualPolicyTable: residualPolicyTable
        )
    }
}



struct P08HostValidatorGraphFixture: HostComponentGraphView {
    let records: [HostComponentRecord]
    var trace: P08HostValidationTrace? = nil
    var count: UInt8 { trace?.events.append(1000); return UInt8(records.count) }

    func record(at index: UInt8) -> HostComponentRecord? {
        trace?.events.append(2000 + Int(index))
        guard Int(index) < records.count else { return nil }
        return records[Int(index)]
    }
}

struct P08HostValidatorPolicyFixture: MVPHostResidualPolicyTable {
    var trace: P08HostValidationTrace? = nil
    let overriddenContext: HostResidualPolicyContext?
    let overriddenAllowed: GiftUIAllowedDispositions?
    let overriddenSelection: GiftUIResidualDisposition?
    private let configuredFatalHook: Bool
    var fatalHookIsAvailable: Bool {
        trace?.events.append(5000)
        return configuredFatalHook
    }

    init(
        overriddenContext: HostResidualPolicyContext? = nil,
        overriddenAllowed: GiftUIAllowedDispositions? = nil,
        overriddenSelection: GiftUIResidualDisposition? = nil,
        fatalHookIsAvailable: Bool = false
    ) {
        self.overriddenContext = overriddenContext
        self.overriddenAllowed = overriddenAllowed
        self.overriddenSelection = overriddenSelection
        self.configuredFatalHook = fatalHookIsAvailable
    }

    func allowed(
        for context: HostResidualPolicyContext
    ) -> GiftUIAllowedDispositions {
        trace?.events.append(3000 + Int(context.rawValue))
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
        trace?.events.append(4000 + Int(context.rawValue))
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

func P08makeHostValidatorGraph() -> P08HostValidatorGraphFixture {
    P08HostValidatorGraphFixture(
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

func P08makeHostInputs(
    runtimeAudit: RuntimeStorageAudit,
    componentGraph: P08HostValidatorGraphFixture? = nil,
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
    residualPolicyTable: P08HostValidatorPolicyFixture = P08HostValidatorPolicyFixture()
) -> P08HostValidationInputs {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    let audit = runtimeAudit
    let validatedAudit = RuntimeProfileValidationResult.valid(audit)
    let capability = P08makeHostCapabilityFixture(requirement: preset.capabilityRequirement)
    let defaultEndpoint = P08makeHostEndpointFixture(
        effectivePresentation: capability.effective,
        textRasterRealization: RasterRealizationID(rawValue: 1)
    )

    return P08HostValidationInputs(
        structuralConfiguration: HostStructuralConfiguration(
            kind: preset.kind,
            profile: audit.profile,
            runtimeLimits: audit.limits,
            runtimeAudit: audit,
            cardinality: P08CounterWorkload.cardinality,
            workload: workload ?? P08CounterWorkload.value(audit.limits),
            pacing: P08CounterWorkload.pacing
        ),
        runtimeProfileValidation: runtimeProfileValidation ?? validatedAudit,
        componentGraph: componentGraph ?? P08makeHostValidatorGraph(),
        textResourceValidation: textResourceValidation,
        selectedTextRasterRealization: selectedTextRasterRealization,
        capabilityRequirement: preset.capabilityRequirement,
        capabilityContributions: capabilityContributions ?? capability.contributions,
        capabilityWorkspace: capabilityWorkspace ?? RasterPresentationResolverWorkspace()!,
        endpoint: endpoint ?? defaultEndpoint,
        actionAndModel: actionAndModel ?? P08makeHostActionModelFixture(lastActionCode: 1),
        inputAndWake: inputAndWake ?? P08makeHostInputWakeFixture(),
        residualPolicyTable: residualPolicyTable
    )
}

func P08makeHostActionModelFixture(
    firstActionCode: UInt16 = 0,
    lastActionCode: UInt16 = 5,
    handlerCount: UInt8 = 1,
    rootModelTargetCount: UInt8 = 1,
    sourceMinimumTransitionSpacingMicroseconds: UInt32 = 50_000,
    maximumSourceCallbacksPerServiceWindow: UInt16 = 20,
    maximumCallbacksPerAction: UInt8 = 1,
    maximumRepositoryCallbacksPerAction: UInt8 = 1,
    maximumUseCaseCallbacksPerAction: UInt8 = 1,
    maximumNonTransitionPublicationsPerAction: UInt8 = 1,
    applicationExecutorFactLimit: UInt16 = 28,
    factAdmissionAdapterCount: UInt8 = 1,
    targetGenerationIsPublishable: Bool = true,
    actionHandlerIsTotal: Bool = true,
    retainsOwnerReferences: Bool = false,
    callbacksAreReentrant: Bool = false
) -> HostActionModelConfiguration {
    HostActionModelConfiguration(
        firstActionCode: firstActionCode,
        lastActionCode: lastActionCode,
        handlerCount: handlerCount,
        rootModelTargetCount: rootModelTargetCount,
        sourceMinimumTransitionSpacingMicroseconds:
            sourceMinimumTransitionSpacingMicroseconds,
        maximumSourceCallbacksPerServiceWindow:
            maximumSourceCallbacksPerServiceWindow,
        maximumCallbacksPerAction: maximumCallbacksPerAction,
        maximumRepositoryCallbacksPerAction: maximumRepositoryCallbacksPerAction,
        maximumUseCaseCallbacksPerAction: maximumUseCaseCallbacksPerAction,
        maximumNonTransitionPublicationsPerAction:
            maximumNonTransitionPublicationsPerAction,
        applicationExecutorFactLimit: applicationExecutorFactLimit,
        factAdmissionAdapterCount: factAdmissionAdapterCount,
        targetGenerationIsPublishable: targetGenerationIsPublishable,
        actionHandlerIsTotal: actionHandlerIsTotal,
        retainsOwnerReferences: retainsOwnerReferences,
        callbacksAreReentrant: callbacksAreReentrant
    )
}

func P08makeHostInputWakeFixture(
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

func P08makeHostEndpointFixture(
    effectivePresentation: EffectiveRasterPresentation? = nil,
    descriptor: RasterSurfaceDescriptor? = nil,
    payloadLimits: RasterPayloadLimits? = nil,
    surfaceWritableCapacityBytes: UInt32 = 2_560,
    displaySubmissionLifetime: SubmissionLifetime = .synchronousBorrow,
    displayHandoff: SubmissionHandoff = .synchronous,
    displayMaximumInFlightPayloads: UInt8 = 1,
    displayMaximumInFlightBytes: UInt32 = 2_560,
    textRasterRealization: RasterRealizationID = RasterRealizationID(rawValue: 1),
    healthOwnerCount: UInt8 = 1,
    endpointAndDisplayShareHealthOwner: Bool = true
) -> HostEndpointConfiguration {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    let effective =
        effectivePresentation
        ?? P08makeHostCapabilityFixture(
            requirement: preset.capabilityRequirement
        ).effective
    let defaultDescriptor = RasterSurfaceDescriptor(
        bounds: Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 320, height: 240)!
        )!,
        encoding: .rgb565BigEndian,
        bytesPerRow: 640,
        realization: .tiled,
        regionWidth: 320,
        regionHeight: 4
    )!
    let defaultPayload = RasterPayloadLimits(
        maximumRasterBytes: 2_560,
        maximumPayloadBytes: 2_560,
        maximumRegionsPerPayload: 1,
        maximumRegionSubmissionsPerFrame: 80,
        maximumTileVisitsPerFrame: 80,
        maximumInFlightPayloads: 1,
        maximumGlyphRasterBytes: 2_560,
        maximumStrokeWorkspaceBytes: 2_560
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

func P08makeHostCapabilityValues(
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
        maximumRegionWidth: 320,
        maximumRegionHeight: 4,
        rowByteAlignment: 2,
        maximumRasterBytes: .init(rawValue: 2_560),
        maximumPayloadBytes: .init(rawValue: 2_560)
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
                maximumRegionWidth: 320,
                maximumRegionHeight: 4,
                rowByteAlignment: 2,
                maximumInFlightCount: 1,
                maximumInFlightBytes: .init(rawValue: 2_560)
            )!
        ),
        .hostResourcePolicy(
            RasterPresentationPolicy(
                maximumRasterBytes: .init(rawValue: 2_560),
                maximumPayloadBytes: .init(rawValue: 2_560),
                maximumInFlightBytes: .init(rawValue: 2_560),
                allowedRealizations: .tiled,
                allowedEncodings: .rgb565BigEndian,
                preferredRealization: .tiled,
                preferredEncoding: .rgb565BigEndian
            )!
        ),
    ]
}

func P08makeHostCapabilityContributions(
    _ values: [RasterPresentationContribution]
) -> RasterPresentationContributions {
    var contributions = RasterPresentationContributions()
    for value in values {
        _ = contributions.insert(value)
    }
    return contributions
}

private func P08makeHostCapabilityFixture(
    requirement: RasterPresentationRequirement
) -> (
    contributions: RasterPresentationContributions,
    effective: EffectiveRasterPresentation
) {
    let contributions = P08makeHostCapabilityContributions(
        P08makeHostCapabilityValues(requirement: requirement)
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

func P08invalidHostWorkload(_ value: SignalAnalyzerHostWorkload) -> SignalAnalyzerHostWorkload {
    .init(
        schemaVersion: 0,
        requiredPathEntries: value.requiredPathEntries,
        requiredPayloadBytesPerBank: value.requiredPayloadBytesPerBank,
        requiredInteractionIdentityComponents: value.requiredInteractionIdentityComponents,
        requiredPathDepth: value.requiredPathDepth,
        requiredPathChildFanout: value.requiredPathChildFanout,
        requiredIdentityComponentsPerKey: value.requiredIdentityComponentsPerKey,
        requiredRuntimeLimits: value.requiredRuntimeLimits,
        semanticNodeOccurrences: value.semanticNodeOccurrences,
        semanticStructuralOccurrences: value.semanticStructuralOccurrences,
        renderSemanticScopeOccurrences: value.renderSemanticScopeOccurrences,
        layoutScopeOccurrences: value.layoutScopeOccurrences,
        maximumRenderTraversalDepth: value.maximumRenderTraversalDepth,
        renderTextLineCount: value.renderTextLineCount,
        positionedGlyphCount: value.positionedGlyphCount,
        ordinaryRenderOperations: value.ordinaryRenderOperations,
        inputEventsPerOpportunity: value.inputEventsPerOpportunity,
        semanticActionsPerOpportunity: value.semanticActionsPerOpportunity,
        completionFactsPerOpportunity: value.completionFactsPerOpportunity,
        drawing: value.drawing
    )
}

package func p08HostValidationQualification() -> Int {
    p08WithCounterHostQualificationAudit { audit in
        p08HostValidationQualification(audit: audit)
    }
}

private func p08HostValidationQualification(audit: RuntimeStorageAudit) -> Int {
    var checks = 0
    func expect(_ condition: Bool) { precondition(condition); checks += 1 }
    let base = P08makeHostInputs(runtimeAudit: audit)
    checks += base.structuralConfiguration.runtimeAudit.qualifyHostStartupEquality(counterActualLimits(.dynamic))
    let invalidWorkload = P08invalidHostWorkload(base.structuralConfiguration.workload)
    for mask in 0..<512 {
        var inputs = base
        if mask & 1 != 0 {
            inputs.componentGraph = .init(records: Array(base.componentGraph.records.dropLast()))
        }
        if mask & 2 != 0 { inputs.runtimeProfileValidation = .invalid(.invalidLimits) }
        if mask & 4 != 0 { inputs.textResourceValidation = .invalid(.integrityMismatch) }
        if mask & 8 != 0 {
            let c = base.structuralConfiguration
            inputs.structuralConfiguration = .init(kind: c.kind, profile: c.profile,
                runtimeLimits: c.runtimeLimits, runtimeAudit: c.runtimeAudit,
                cardinality: c.cardinality, workload: invalidWorkload, pacing: c.pacing)
        }
        if mask & 16 != 0 { inputs.capabilityContributions = .init() }
        if mask & 32 != 0 { inputs.endpoint = P08makeHostEndpointFixture(healthOwnerCount: 0) }
        if mask & 64 != 0 { inputs.actionAndModel = P08makeHostActionModelFixture(firstActionCode: 1) }
        if mask & 128 != 0 { inputs.inputAndWake = P08makeHostInputWakeFixture(normalizedInputSourceCount: 0) }
        if mask & 256 != 0 {
            inputs.residualPolicyTable = .init(overriddenContext: .safetyNotProven,
                overriddenAllowed: .continueOperation)
        }
        let oldTrace = P08HostValidationTrace(), newTrace = P08HostValidationTrace()
        var oldInputs = inputs, newInputs = inputs
        oldInputs.componentGraph.trace = oldTrace
        oldInputs.residualPolicyTable.trace = oldTrace
        newInputs.componentGraph.trace = newTrace
        newInputs.residualPolicyTable.trace = newTrace
        var original = oldInputs.original(), candidate = newInputs.candidate()
        expect(original.validationAccessLedger == candidate.validationAccessLedger)
        let expected = original.validate(), actual = candidate.validate()
        expect(expected == actual)
        if mask == 0 {
            if case .valid = actual { checks += 1 } else { preconditionFailure("valid Host fixture rejected") }
        } else {
            let first = UInt8(mask.trailingZeroBitCount)
            if case .invalid(let stage, _) = actual {
                expect(stage.rawValue == first)
            } else { preconditionFailure("Host fault mask accepted") }
        }
        expect(original.validationAccessLedger == candidate.validationAccessLedger)
        expect(original.capabilityWorkspace == candidate.capabilityWorkspace)
        expect(oldTrace.events == newTrace.events)
        let oldLedger = original.validationAccessLedger, newLedger = candidate.validationAccessLedger
        let oldEvents = oldTrace.events, newEvents = newTrace.events
        let invariant = HostValidationResult.invalid(stage: .graph, error: .invariantViolation)
        expect(original.validate() == invariant)
        expect(candidate.validate() == invariant)
        expect(original.validationAccessLedger == oldLedger)
        expect(candidate.validationAccessLedger == newLedger)
        expect(oldTrace.events == oldEvents && newTrace.events == newEvents)
    }
    // Every local runtime/text error retains its exact payload at its stage.
    let runtimeErrors: [RuntimeProfileValidationError] = [.invalidLimits, .incompatibleLimits,
        .missingStorage, .insufficientStorage, .arithmeticOverflow, .staticCanvasTableInvalid,
        .invariantViolation]
    for error in runtimeErrors {
        var inputs = base; inputs.runtimeProfileValidation = .invalid(error)
        var original = inputs.original(), candidate = inputs.candidate()
        expect(original.validate() == candidate.validate())
        expect(candidate.validationAccessLedger.accessCount == 2)
    }
    let textErrors: [TextResourceValidationError] = [.unsupportedSchema, .capacityExceeded,
        .invalidCount, .invalidIdentity, .incompatibleViews, .malformedMetrics,
        .malformedMapping, .malformedRasterRecord, .integrityMismatch]
    for error in textErrors {
        var inputs = base; inputs.textResourceValidation = .invalid(error)
        var original = inputs.original(), candidate = inputs.candidate()
        expect(original.validate() == candidate.validate())
        expect(candidate.validationAccessLedger.accessCount == 3)
    }
    // Compatibility ledger replacement may clear observations, never begin-state.
    var guardState = HostValidationStateGuard()
    if case .none = guardState.begin() { checks += 1 } else { preconditionFailure("fresh Host guard rejected") }
    expect(guardState.enter(.graph))
    guardState.replaceLedger(.init())
    expect(guardState.ledgerValue().accessCount == 0)
    expect(guardState.begin() == .invalid(stage: .graph, error: .invariantViolation))
    typealias OldCounter = P08OriginalCheckedHostValidator<CounterHostGraph, FixedMVPHostResidualPolicyTable>
    typealias NewCounter = CheckedMVPHostConfigurationValidator<CounterHostGraph, FixedMVPHostResidualPolicyTable>
    expect(MemoryLayout<OldCounter>.size == MemoryLayout<NewCounter>.size)
    expect(MemoryLayout<OldCounter>.stride == MemoryLayout<NewCounter>.stride)
    expect(MemoryLayout<OldCounter>.alignment == MemoryLayout<NewCounter>.alignment)
    return checks
}
