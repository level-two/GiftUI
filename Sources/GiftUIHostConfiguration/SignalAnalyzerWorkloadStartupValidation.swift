import GiftUIRuntimeCore

package enum SignalAnalyzerWorkloadStartupValidation {
    package static func validate(
        configuration: HostStructuralConfiguration
    ) -> HostConfigurationError? {
        let workload = configuration.workload
        let limits = configuration.runtimeLimits
        let cardinality = configuration.cardinality
        let pacing = configuration.pacing
        // SPEC-015 selects exactly these two finite repository compositions.
        let isCounter = cardinality.actionCaseCount == 2

        guard workload.schemaVersion == 4 else { return .invalidWorkload }
        guard workload.requiredPathEntries > 0,
            workload.requiredPayloadBytesPerBank > 0,
            workload.requiredInteractionIdentityComponents > 0,
            workload.requiredPathDepth > 0,
            workload.requiredPathChildFanout > 0,
            workload.requiredIdentityComponentsPerKey > 0,
            workload.semanticNodeOccurrences > 0,
            workload.semanticStructuralOccurrences > 0,
            workload.renderSemanticScopeOccurrences > 0,
            workload.layoutScopeOccurrences > 0,
            workload.maximumRenderTraversalDepth > 0,
            workload.renderTextLineCount > 0,
            workload.positionedGlyphCount > 0,
            workload.ordinaryRenderOperations > 0,
            workload.inputEventsPerOpportunity > 0,
            workload.semanticActionsPerOpportunity > 0,
            workload.completionFactsPerOpportunity > 0
        else { return .invalidWorkload }

        guard let pathEntries = UInt16(exactly: workload.requiredPathEntries),
            pathEntries <= limits.records.maximumPathEntries,
            workload.requiredPayloadBytesPerBank <= limits.records.maximumPayloadBytesPerBank,
            workload.requiredInteractionIdentityComponents
                <= limits.records.maximumInteractionIdentityComponents,
            workload.requiredPathDepth <= limits.records.maximumPathDepth,
            workload.requiredPathChildFanout <= limits.records.maximumPathChildFanout,
            workload.requiredIdentityComponentsPerKey
                <= limits.records.maximumIdentityComponentsPerKey,
            limits.models.maximumModelSlots == 2,
            limits.models.maximumOwningTickets == 4,
            limits.models.maximumFramePins == 2,
            limits.models.maximumModelCaptureBanks == (isCounter ? 0 : 1),
            workload.requiredRuntimeLimits == limits,
            workload.semanticNodeOccurrences == limits.semantic.maximumSemanticNodes,
            workload.semanticStructuralOccurrences
                == limits.maximumSemanticStructuralOccurrences,
            workload.renderSemanticScopeOccurrences
                == limits.renderWorkspace.maximumSemanticScopes,
            workload.layoutScopeOccurrences == limits.layout.maximumScopes,
            workload.layoutScopeOccurrences == limits.renderWorkspace.maximumLayoutScopes,
            workload.maximumRenderTraversalDepth
                == limits.renderWorkspace.maximumTraversalDepth,
            workload.renderTextLineCount == limits.layout.maximumTextLines,
            workload.renderTextLineCount == limits.renderWorkspace.maximumTextLines,
            workload.positionedGlyphCount == limits.layout.maximumPositionedGlyphs,
            workload.positionedGlyphCount == limits.render.maximumPositionedGlyphs,
            workload.positionedGlyphCount == limits.renderSink.maximumPositionedGlyphs,
            workload.ordinaryRenderOperations == limits.maximumOrdinaryRenderOperations,
            workload.inputEventsPerOpportunity == limits.execution.maximumInputEvents,
            workload.semanticActionsPerOpportunity
                == limits.semantic.maximumActionOccurrences,
            workload.semanticActionsPerOpportunity
                == limits.execution.maximumSemanticActions,
            workload.semanticActionsPerOpportunity
                == limits.execution.maximumCommittedActions,
            workload.semanticActionsPerOpportunity == limits.interaction.maximumActions,
            workload.semanticActionsPerOpportunity == limits.interaction.maximumHitRegions,
            workload.completionFactsPerOpportunity
                == limits.execution.maximumCompletionFacts
        else { return .insufficientWorkloadCapacity }

        guard isCounter || cardinality.actionCaseCount == 6,
            cardinality.rootModelLocationCount == 1,
            cardinality.activeRegistrationCount == 1,
            cardinality.stagedAssociationCount == 1,
            cardinality.snapshotFactCapacity == 1,
            cardinality.compactFactCapacity == 32,
            cardinality.reservedFailureFactCapacity == 1,
            cardinality.normalizedInputSourceCapacity == 1,
            workload.semanticActionsPerOpportunity == cardinality.actionCaseCount,
            limits.observableState.maximumLocations
                == cardinality.rootModelLocationCount,
            limits.observableState.maximumRegistrations
                == cardinality.activeRegistrationCount,
            limits.observableState.maximumStagedAssociations
                == cardinality.stagedAssociationCount,
            limits.execution.maximumActiveInputSources
                == cardinality.normalizedInputSourceCapacity
        else { return .invalidWorkload }

        let physicalFactCapacity = cardinality.snapshotFactCapacity
            .addingReportingOverflow(cardinality.compactFactCapacity)
        guard !physicalFactCapacity.overflow else { return .arithmeticOverflow }
        let totalPhysicalFactCapacity = physicalFactCapacity.partialValue
            .addingReportingOverflow(cardinality.reservedFailureFactCapacity)
        guard !totalPhysicalFactCapacity.overflow else { return .arithmeticOverflow }
        guard
            limits.execution.maximumStateChangeFacts
                >= totalPhysicalFactCapacity.partialValue
        else { return .insufficientWorkloadCapacity }

        let transitionAndBootstrap = pacing.maximumTransitionFactsPerServiceWindow
            .addingReportingOverflow(
                UInt16(pacing.maximumBootstrapFactsPerServiceWindow)
            )
        guard !transitionAndBootstrap.overflow else { return .arithmeticOverflow }
        let maximumFacts = transitionAndBootstrap.partialValue.addingReportingOverflow(
            UInt16(pacing.maximumActionInducedFactsPerServiceWindow)
        )
        guard !maximumFacts.overflow else { return .arithmeticOverflow }
        guard pacing.minimumFrameIntervalMicroseconds == 250_000,
            pacing.maximumFactServiceLatencyMicroseconds == 250_000,
            pacing.minimumAcceptedTransitionSpacingMicroseconds == 50_000,
            pacing.maximumTransitionFactsPerServiceWindow == 20,
            pacing.maximumBootstrapFactsPerServiceWindow == 2,
            pacing.maximumActionInducedFactsPerServiceWindow == 6,
            pacing.maximumRetryableRefusals == 3,
            maximumFacts.partialValue == 28,
            maximumFacts.partialValue <= cardinality.compactFactCapacity,
            cardinality.compactFactCapacity - maximumFacts.partialValue == 4
        else { return .invalidPacingPolicy }

        return SignalAnalyzerDrawingStartupValidation.validate(
            workload: workload,
            limits: limits,
            profile: configuration.profile
        )
    }
}
