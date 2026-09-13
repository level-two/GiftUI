import GiftUICapabilities
import GiftUIFailureCore
import GiftUIRuntimeCore
import GiftUITextResources

package struct CheckedMVPHostConfigurationValidator<Graph, Policy>:
    MVPHostConfigurationValidator, ~Copyable
where
    Graph: HostComponentGraphView,
    Policy: MVPHostResidualPolicyTable
{
    package let structuralConfiguration: HostStructuralConfiguration
    package let runtimeProfileValidation: RuntimeProfileValidationResult
    package let componentGraph: Graph
    package let textResourceValidation: TextResourceValidationResult
    package let selectedTextRasterRealization: RasterRealizationID
    package let capabilityRequirement: RasterPresentationRequirement
    package let capabilityContributions: RasterPresentationContributions
    package var capabilityWorkspace: RasterPresentationResolverWorkspace
    package let endpoint: HostEndpointConfiguration
    package let actionAndModel: HostActionModelConfiguration
    package let inputAndWake: HostInputWakeConfiguration
    package let residualPolicyTable: Policy
    package private(set) var validationAccessLedger: HostValidationAccessLedger
    private var stateGuard: HostValidationStateGuard

    package init(
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
        stateGuard = HostValidationStateGuard()
    }

    package mutating func validate() -> HostValidationResult {
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
