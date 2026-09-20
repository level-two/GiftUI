import GiftUIExecution
import GiftUIRuntimeCore
import Testing

@testable import GiftUIHostConfiguration

@Test func allGeneratedWorkloadsPassCompleteStructuralValidation() {
    for preset in [
        GeneratedSignalAnalyzerPresets.macOSDynamic(),
        GeneratedSignalAnalyzerPresets.macOSStatic(),
        GeneratedSignalAnalyzerPresets.raspberryPiDynamic(),
        GeneratedSignalAnalyzerPresets.nrf52840Static(),
    ] {
        #expect(
            SignalAnalyzerWorkloadStartupValidation.validate(
                configuration: structuralConfiguration(preset)
            ) == nil
        )
    }
}

@Test func schemaAndMalformedCountsFailBeforeCapacityComparison() {
    let preset = GeneratedSignalAnalyzerPresets.macOSDynamic()
    #expect(
        validate(preset, workload: workload(preset.workload, schemaVersion: 1))
            == .invalidWorkload
    )

    let malformed = [
        workload(preset.workload, semanticNodeOccurrences: 0),
        workload(preset.workload, renderSemanticScopeOccurrences: 0),
        workload(preset.workload, layoutScopeOccurrences: 0),
        workload(preset.workload, maximumRenderTraversalDepth: 0),
        workload(preset.workload, renderTextLineCount: 0),
        workload(preset.workload, positionedGlyphCount: 0),
        workload(preset.workload, ordinaryRenderOperations: 0),
        workload(preset.workload, inputEventsPerOpportunity: 0),
        workload(preset.workload, semanticActionsPerOpportunity: 0),
        workload(preset.workload, completionFactsPerOpportunity: 0),
    ]
    for candidate in malformed {
        #expect(validate(preset, workload: candidate) == .invalidWorkload)
    }
}

@Test func everyManifestSourceCountMustEqualItsOwningLimit() {
    let preset = GeneratedSignalAnalyzerPresets.macOSDynamic()
    let mismatches = [
        workload(preset.workload, semanticNodeOccurrences: 61),
        workload(preset.workload, renderSemanticScopeOccurrences: 61),
        workload(preset.workload, layoutScopeOccurrences: 31),
        workload(preset.workload, maximumRenderTraversalDepth: 5),
        workload(preset.workload, renderTextLineCount: 20),
        workload(preset.workload, positionedGlyphCount: 138),
        workload(preset.workload, ordinaryRenderOperations: 29),
        workload(preset.workload, inputEventsPerOpportunity: 5),
        workload(preset.workload, semanticActionsPerOpportunity: 5),
        workload(preset.workload, completionFactsPerOpportunity: 2),
    ]
    for candidate in mismatches {
        #expect(
            validate(preset, workload: candidate)
                == .insufficientWorkloadCapacity
        )
    }
}

@Test func everyHostCardinalityAndPacingConstantIsRequired() {
    let preset = GeneratedSignalAnalyzerPresets.macOSDynamic()
    let cardinality = preset.cardinality
    let invalidCardinalities = [
        hostCardinality(cardinality, actionCaseCount: 5),
        hostCardinality(cardinality, rootModelLocationCount: 2),
        hostCardinality(cardinality, activeRegistrationCount: 2),
        hostCardinality(cardinality, stagedAssociationCount: 2),
        hostCardinality(cardinality, snapshotFactCapacity: 2),
        hostCardinality(cardinality, compactFactCapacity: 31),
        hostCardinality(cardinality, reservedFailureFactCapacity: 2),
        hostCardinality(cardinality, normalizedInputSourceCapacity: 2),
    ]
    for candidate in invalidCardinalities {
        #expect(
            SignalAnalyzerWorkloadStartupValidation.validate(
                configuration: structuralConfiguration(preset, cardinality: candidate)
            ) == .invalidWorkload
        )
    }

    let pacing = preset.pacing
    let invalidPacing = [
        hostPacing(pacing, minimumFrameIntervalMicroseconds: 250_001),
        hostPacing(pacing, maximumFactServiceLatencyMicroseconds: 250_001),
        hostPacing(pacing, minimumAcceptedTransitionSpacingMicroseconds: 50_001),
        hostPacing(pacing, maximumTransitionFactsPerServiceWindow: 21),
        hostPacing(pacing, maximumBootstrapFactsPerServiceWindow: 3),
        hostPacing(pacing, maximumActionInducedFactsPerServiceWindow: 7),
        hostPacing(pacing, maximumRetryableRefusals: 4),
    ]
    for candidate in invalidPacing {
        #expect(
            SignalAnalyzerWorkloadStartupValidation.validate(
                configuration: structuralConfiguration(preset, pacing: candidate)
            ) == .invalidPacingPolicy
        )
    }
}

@Test func executionFactStorageMustAdmitTheSeparateOneThirtyTwoOneStores() {
    let preset = GeneratedSignalAnalyzerPresets.macOSDynamic()
    let source = preset.runtimeLimits
    let execution = ExecutionLimits(
        maximumInputEvents: source.execution.maximumInputEvents,
        maximumStateChangeFacts: 33,
        maximumCompletionFacts: source.execution.maximumCompletionFacts,
        maximumSemanticActions: source.execution.maximumSemanticActions,
        maximumActiveInputSources: source.execution.maximumActiveInputSources,
        maximumCommittedActions: source.execution.maximumCommittedActions
    )!
    let limits = RuntimeProfileLimits(
        semantic: source.semantic,
        maximumSemanticStructuralOccurrences:
            source.maximumSemanticStructuralOccurrences,
        layout: source.layout,
        render: source.render,
        renderWorkspace: source.renderWorkspace,
        renderSink: source.renderSink,
        maximumOrdinaryRenderOperations: source.maximumOrdinaryRenderOperations,
        execution: execution,
        observableState: source.observableState,
        interaction: source.interaction,
        drawing: source.drawing,
        staticCanvas: source.staticCanvas,
        profile: preset.profile
    )!
    let candidateWorkload = workload(
        preset.workload,
        requiredRuntimeLimits: limits
    )

    #expect(
        SignalAnalyzerWorkloadStartupValidation.validate(
            configuration: structuralConfiguration(
                preset,
                workload: candidateWorkload,
                limits: limits
            )
        ) == .insufficientWorkloadCapacity
    )
}

private func validate(
    _ preset: GeneratedSignalAnalyzerPreset,
    workload: SignalAnalyzerHostWorkload
) -> HostConfigurationError? {
    SignalAnalyzerWorkloadStartupValidation.validate(
        configuration: structuralConfiguration(preset, workload: workload)
    )
}

private func structuralConfiguration(
    _ preset: GeneratedSignalAnalyzerPreset,
    workload: SignalAnalyzerHostWorkload? = nil,
    cardinality: SignalAnalyzerHostCardinality? = nil,
    pacing: HostPacingPolicy? = nil,
    limits: RuntimeProfileLimits? = nil
) -> HostStructuralConfiguration {
    let selectedLimits = limits ?? preset.runtimeLimits
    let audit: RuntimeStorageAudit
    switch preset.validatedStorageAudit() {
    case .valid(let value): audit = value
    case .invalid: fatalError("generated fixture audit must be valid")
    }
    return HostStructuralConfiguration(
        kind: preset.kind,
        profile: preset.profile,
        runtimeLimits: selectedLimits,
        runtimeAudit: audit,
        cardinality: cardinality ?? preset.cardinality,
        workload: workload ?? preset.workload,
        pacing: pacing ?? preset.pacing
    )
}

private func workload(
    _ source: SignalAnalyzerHostWorkload,
    schemaVersion: UInt16? = nil,
    requiredRuntimeLimits: RuntimeProfileLimits? = nil,
    semanticNodeOccurrences: UInt16? = nil,
    semanticStructuralOccurrences: UInt16? = nil,
    renderSemanticScopeOccurrences: UInt16? = nil,
    layoutScopeOccurrences: UInt16? = nil,
    maximumRenderTraversalDepth: UInt16? = nil,
    renderTextLineCount: UInt16? = nil,
    positionedGlyphCount: UInt16? = nil,
    ordinaryRenderOperations: UInt16? = nil,
    inputEventsPerOpportunity: UInt16? = nil,
    semanticActionsPerOpportunity: UInt16? = nil,
    completionFactsPerOpportunity: UInt16? = nil
) -> SignalAnalyzerHostWorkload {
    SignalAnalyzerHostWorkload(
        schemaVersion: schemaVersion ?? source.schemaVersion,
        requiredRuntimeLimits: requiredRuntimeLimits ?? source.requiredRuntimeLimits,
        semanticNodeOccurrences: semanticNodeOccurrences ?? source.semanticNodeOccurrences,
        semanticStructuralOccurrences:
            semanticStructuralOccurrences ?? source.semanticStructuralOccurrences,
        renderSemanticScopeOccurrences:
            renderSemanticScopeOccurrences ?? source.renderSemanticScopeOccurrences,
        layoutScopeOccurrences: layoutScopeOccurrences ?? source.layoutScopeOccurrences,
        maximumRenderTraversalDepth:
            maximumRenderTraversalDepth ?? source.maximumRenderTraversalDepth,
        renderTextLineCount: renderTextLineCount ?? source.renderTextLineCount,
        positionedGlyphCount: positionedGlyphCount ?? source.positionedGlyphCount,
        ordinaryRenderOperations:
            ordinaryRenderOperations ?? source.ordinaryRenderOperations,
        inputEventsPerOpportunity:
            inputEventsPerOpportunity ?? source.inputEventsPerOpportunity,
        semanticActionsPerOpportunity:
            semanticActionsPerOpportunity ?? source.semanticActionsPerOpportunity,
        completionFactsPerOpportunity:
            completionFactsPerOpportunity ?? source.completionFactsPerOpportunity,
        drawing: source.drawing
    )
}

private func hostCardinality(
    _ source: SignalAnalyzerHostCardinality,
    actionCaseCount: UInt16? = nil,
    rootModelLocationCount: UInt16? = nil,
    activeRegistrationCount: UInt16? = nil,
    stagedAssociationCount: UInt16? = nil,
    snapshotFactCapacity: UInt16? = nil,
    compactFactCapacity: UInt16? = nil,
    reservedFailureFactCapacity: UInt16? = nil,
    normalizedInputSourceCapacity: UInt16? = nil
) -> SignalAnalyzerHostCardinality {
    SignalAnalyzerHostCardinality(
        actionCaseCount: actionCaseCount ?? source.actionCaseCount,
        rootModelLocationCount: rootModelLocationCount ?? source.rootModelLocationCount,
        activeRegistrationCount: activeRegistrationCount ?? source.activeRegistrationCount,
        stagedAssociationCount: stagedAssociationCount ?? source.stagedAssociationCount,
        snapshotFactCapacity: snapshotFactCapacity ?? source.snapshotFactCapacity,
        compactFactCapacity: compactFactCapacity ?? source.compactFactCapacity,
        reservedFailureFactCapacity:
            reservedFailureFactCapacity ?? source.reservedFailureFactCapacity,
        normalizedInputSourceCapacity:
            normalizedInputSourceCapacity ?? source.normalizedInputSourceCapacity
    )
}

private func hostPacing(
    _ source: HostPacingPolicy,
    minimumFrameIntervalMicroseconds: UInt32? = nil,
    maximumFactServiceLatencyMicroseconds: UInt32? = nil,
    minimumAcceptedTransitionSpacingMicroseconds: UInt32? = nil,
    maximumTransitionFactsPerServiceWindow: UInt16? = nil,
    maximumBootstrapFactsPerServiceWindow: UInt8? = nil,
    maximumActionInducedFactsPerServiceWindow: UInt8? = nil,
    maximumRetryableRefusals: UInt8? = nil
) -> HostPacingPolicy {
    HostPacingPolicy(
        minimumFrameIntervalMicroseconds:
            minimumFrameIntervalMicroseconds ?? source.minimumFrameIntervalMicroseconds,
        maximumFactServiceLatencyMicroseconds:
            maximumFactServiceLatencyMicroseconds
            ?? source.maximumFactServiceLatencyMicroseconds,
        minimumAcceptedTransitionSpacingMicroseconds:
            minimumAcceptedTransitionSpacingMicroseconds
            ?? source.minimumAcceptedTransitionSpacingMicroseconds,
        maximumTransitionFactsPerServiceWindow:
            maximumTransitionFactsPerServiceWindow
            ?? source.maximumTransitionFactsPerServiceWindow,
        maximumBootstrapFactsPerServiceWindow:
            maximumBootstrapFactsPerServiceWindow
            ?? source.maximumBootstrapFactsPerServiceWindow,
        maximumActionInducedFactsPerServiceWindow:
            maximumActionInducedFactsPerServiceWindow
            ?? source.maximumActionInducedFactsPerServiceWindow,
        maximumRetryableRefusals:
            maximumRetryableRefusals ?? source.maximumRetryableRefusals
    )!
}
