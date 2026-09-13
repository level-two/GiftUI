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
        guard validateWorkload() else {
            return .invalid(
                stage: .workload,
                error: .insufficientWorkloadCapacity
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
        let expectedProfile: RuntimeProfileKind =
            switch configuration.kind {
            case .macOSDynamic, .raspberryPiDynamic: .dynamic
            case .macOSStatic, .nrf52840Static: .static
            }
        guard configuration.profile == expectedProfile,
            configuration.runtimeAudit.profile == expectedProfile
        else { return .profileMismatch }
        guard configuration.runtimeAudit.limits == configuration.runtimeLimits
        else {
            return .invalidRuntimeProfile(.invariantViolation)
        }
        return nil
    }

    private borrowing func validateWorkload() -> Bool {
        let configuration = structuralConfiguration
        let workload = configuration.workload
        let cardinality = configuration.cardinality
        guard workload.schemaVersion == 2,
            workload.requiredRuntimeLimits == configuration.runtimeLimits,
            workload.drawing.canvasOccurrences > 0,
            workload.drawing.maximumLivePathPoints > 0,
            workload.drawing.maximumLivePathSubpaths > 0,
            workload.drawing.submittedStrokes > 0,
            workload.drawing.snapshottedPoints > 0,
            workload.drawing.snapshottedSubpaths > 0,
            workload.drawing.normalizedStrokeOperations > 0,
            cardinality.actionCaseCount == 6,
            cardinality.rootModelLocationCount == 1,
            cardinality.activeRegistrationCount == 1,
            cardinality.stagedAssociationCount == 1,
            cardinality.snapshotFactCapacity == 1,
            cardinality.compactFactCapacity == 32,
            cardinality.reservedFailureFactCapacity == 1,
            cardinality.normalizedInputSourceCapacity == 1,
            workload.semanticActionsPerOpportunity == 6
        else { return false }

        let pacing = configuration.pacing
        let sum1 = pacing.maximumTransitionFactsPerServiceWindow
            .addingReportingOverflow(
                UInt16(pacing.maximumBootstrapFactsPerServiceWindow)
            )
        guard !sum1.overflow else { return false }
        let sum2 = sum1.partialValue.addingReportingOverflow(
            UInt16(pacing.maximumActionInducedFactsPerServiceWindow)
        )
        guard !sum2.overflow,
            sum2.partialValue <= cardinality.compactFactCapacity
        else { return false }

        let operations = workload.ordinaryRenderOperations
            .addingReportingOverflow(
                workload.drawing.normalizedStrokeOperations
            )
        guard !operations.overflow,
            operations.partialValue
                <= configuration.runtimeLimits.render.maximumOperations,
            operations.partialValue
                <= configuration.runtimeLimits.renderSink.maximumOperations
        else { return false }

        switch configuration.profile {
        case .dynamic:
            return workload.drawing.staticCallableCases == nil
                && workload.drawing.maximumStaticCaptureBytes == nil
        case .static:
            guard let cases = workload.drawing.staticCallableCases,
                let bytes = workload.drawing.maximumStaticCaptureBytes,
                let limits = configuration.runtimeLimits.staticCanvas
            else { return false }
            return cases > 0 && bytes > 0
                && cases <= limits.maximumStaticCallableCases
                && bytes <= limits.maximumStaticCaptureBytes
        }
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
