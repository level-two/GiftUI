package enum HostApplicationStartupValidation {
    package static func validateActionAndModel(
        _ actionAndModel: HostActionModelConfiguration,
        structural: HostStructuralConfiguration
    ) -> HostConfigurationError? {
        guard actionAndModel.firstActionCode == 0,
            actionAndModel.lastActionCode == 5,
            structural.cardinality.actionCaseCount == 6,
            structural.workload.semanticActionsPerOpportunity == 6,
            actionAndModel.handlerCount == 1,
            actionAndModel.sourceMinimumTransitionSpacingMicroseconds
                == structural.pacing.minimumAcceptedTransitionSpacingMicroseconds,
            actionAndModel.maximumSourceCallbacksPerServiceWindow
                == structural.pacing.maximumTransitionFactsPerServiceWindow,
            actionAndModel.maximumCallbacksPerAction == 1,
            actionAndModel.maximumRepositoryCallbacksPerAction == 1,
            actionAndModel.maximumUseCaseCallbacksPerAction == 1,
            actionAndModel.maximumNonTransitionPublicationsPerAction == 1
        else { return .invalidActionDomain }
        guard actionAndModel.rootModelTargetCount == 1,
            structural.cardinality.rootModelLocationCount == 1,
            structural.cardinality.activeRegistrationCount == 1,
            structural.cardinality.stagedAssociationCount == 1,
            actionAndModel.applicationExecutorFactLimit
                == maximumFacts(in: structural.pacing),
            actionAndModel.factAdmissionAdapterCount == 1,
            actionAndModel.targetGenerationIsPublishable,
            actionAndModel.actionHandlerIsTotal,
            !actionAndModel.retainsOwnerReferences,
            !actionAndModel.callbacksAreReentrant
        else { return .invalidModelTarget }
        return nil
    }

    package static func validateInputAndWake(
        _ inputAndWake: HostInputWakeConfiguration,
        structural: HostStructuralConfiguration
    ) -> HostConfigurationError? {
        guard inputAndWake.normalizedInputSourceCount == 1,
            inputAndWake.normalizedInputSourceCount
                == structural.cardinality.normalizedInputSourceCapacity,
            inputAndWake.targetLocalPresentationGateCount == 1,
            structural.runtimeLimits.execution.maximumActiveInputSources == 1
        else { return .invalidInputIntegration }
        guard inputAndWake.wakeRequesterCount == 1,
            inputAndWake.applicationAndMutationDomainsAreDistinct,
            inputAndWake.wakeRequesterIsNonReentrant
        else { return .invalidWakeIntegration }
        return nil
    }

    private static func maximumFacts(
        in pacing: HostPacingPolicy
    ) -> UInt16 {
        UInt16(pacing.maximumBootstrapFactsPerServiceWindow)
            + UInt16(pacing.maximumActionInducedFactsPerServiceWindow)
            + pacing.maximumTransitionFactsPerServiceWindow
    }
}
