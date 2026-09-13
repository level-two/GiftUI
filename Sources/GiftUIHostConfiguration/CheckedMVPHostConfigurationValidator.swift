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
    package let capabilityRequirement: RasterPresentationRequirement
    package let capabilityContributions: RasterPresentationContributions
    package var capabilityWorkspace: RasterPresentationResolverWorkspace
    package let endpoint: HostEndpointConfiguration
    package let actionAndModel: HostActionModelConfiguration
    package let inputAndWake: HostInputWakeConfiguration
    package let residualPolicyTable: Policy
    private var stateGuard: HostValidationStateGuard

    package init(
        structuralConfiguration: HostStructuralConfiguration,
        runtimeProfileValidation: RuntimeProfileValidationResult,
        componentGraph: consuming Graph,
        textResourceValidation: TextResourceValidationResult,
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
        self.capabilityRequirement = capabilityRequirement
        self.capabilityContributions = capabilityContributions
        self.capabilityWorkspace = capabilityWorkspace
        self.endpoint = endpoint
        self.actionAndModel = actionAndModel
        self.inputAndWake = inputAndWake
        self.residualPolicyTable = consume residualPolicyTable
        stateGuard = HostValidationStateGuard()
    }

    package mutating func validate() -> HostValidationResult {
        if let repeated = stateGuard.begin() { return repeated }
        if let error = HostComponentGraphValidation.validate(componentGraph) {
            return .invalid(stage: .graph, error: error)
        }
        if let error = validateRuntimeProfile() {
            return .invalid(stage: .runtimeProfile, error: error)
        }
        if case .invalid(let error) = textResourceValidation {
            return .invalid(
                stage: .textResources,
                error: .invalidTextResources(error)
            )
        }
        if let error = validateWorkload() {
            return .invalid(
                stage: .workload,
                error: error
            )
        }

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
        guard endpoint.effectivePresentation == effective,
            endpoint.healthOwnerCount == 1,
            endpoint.endpointAndDisplayShareHealthOwner
        else {
            return .invalid(
                stage: .endpoint,
                error: .invalidEndpointDescriptor
            )
        }
        guard actionAndModel.firstActionCode == 0,
            actionAndModel.lastActionCode == 5,
            actionAndModel.handlerCount == 1,
            actionAndModel.rootModelTargetCount == 1,
            actionAndModel.maximumNonTransitionPublicationsPerAction == 1
        else {
            return .invalid(stage: .actionAndModel, error: .invalidActionDomain)
        }
        guard inputAndWake.normalizedInputSourceCount == 1,
            inputAndWake.targetLocalPresentationGateCount == 1
        else {
            return .invalid(stage: .inputAndWake, error: .invalidInputIntegration)
        }
        guard inputAndWake.wakeRequesterCount == 1,
            inputAndWake.applicationAndMutationDomainsAreDistinct,
            inputAndWake.wakeRequesterIsNonReentrant
        else {
            return .invalid(stage: .inputAndWake, error: .invalidWakeIntegration)
        }
        guard validatePolicy() else {
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

    private borrowing func validatePolicy() -> Bool {
        for rawValue in UInt8(0) ... 8 {
            let context = HostResidualPolicyContext(rawValue: rawValue)!
            let allowed = residualPolicyTable.allowed(for: context)
            let selection = residualPolicyTable.selection(for: context)
            let selected = GiftUIAllowedDispositions(
                rawValue: 1 << selection.rawValue
            )
            guard !allowed.isEmpty, allowed.contains(selected) else {
                return false
            }
            if selection == .invokeFatalHook,
                !residualPolicyTable.fatalHookIsAvailable
            {
                return false
            }
        }
        return true
    }
}
