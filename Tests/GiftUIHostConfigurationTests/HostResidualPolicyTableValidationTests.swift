import GiftUIFailureCore
import GiftUIRuntimeCore
import Testing

@testable import GiftUIHostConfiguration

@Test func exactNineRowResidualPolicyTablePasses() {
    #expect(
        HostResidualPolicyTableValidation.validate(
            HostValidatorPolicyFixture()
        )
    )
}

@Test func everyPolicyRowRejectsAnIncorrectAllowedSetOrSelection() {
    for rawValue in UInt8(0) ... 8 {
        let context = HostResidualPolicyContext(rawValue: rawValue)!
        #expect(
            !HostResidualPolicyTableValidation.validate(
                HostValidatorPolicyFixture(
                    overriddenContext: context,
                    overriddenAllowed: GiftUIAllowedDispositions(rawValue: 0)
                )
            )
        )
        #expect(
            !HostResidualPolicyTableValidation.validate(
                HostValidatorPolicyFixture(
                    overriddenContext: context,
                    overriddenSelection: .invokeFatalHook,
                    fatalHookIsAvailable: true
                )
            )
        )
    }
}

@Test func invalidPolicyTableFailsAtTheFinalValidationStage() {
    var validator = makeValidHostValidator(
        residualPolicyTable: HostValidatorPolicyFixture(
            overriddenContext: .activation,
            overriddenAllowed: [.continueOperation, .quiesceAffectedScope]
        )
    )
    #expect(
        validator.validate()
            == .invalid(stage: .policy, error: .incompleteFailurePolicy)
    )
}

@Test func earlierStageFailuresPrecedeEveryLaterInvalidProjection() {
    var textBeforeCapability = makeValidHostValidator(
        textResourceValidation: .invalid(.invalidIdentity),
        capabilityContributions: .init()
    )
    #expect(
        textBeforeCapability.validate()
            == .invalid(
                stage: .textResources,
                error: .invalidTextResources(.invalidIdentity)
            )
    )

    var capabilityBeforeEndpoint = makeValidHostValidator(
        capabilityContributions: .init(),
        endpoint: makeHostEndpointFixture(displayMaximumInFlightBytes: 3_839)
    )
    guard case .invalid(let capabilityStage, _) = capabilityBeforeEndpoint.validate()
    else {
        Issue.record("capability must fail before endpoint")
        return
    }
    #expect(capabilityStage == .capability)

    var endpointBeforeAction = makeValidHostValidator(
        endpoint: makeHostEndpointFixture(displayMaximumInFlightBytes: 3_839),
        actionAndModel: makeHostActionModelFixture(firstActionCode: 1)
    )
    #expect(
        endpointBeforeAction.validate()
            == .invalid(
                stage: .endpoint,
                error: .invalidEndpointDescriptor
            )
    )

    var actionBeforeInput = makeValidHostValidator(
        actionAndModel: makeHostActionModelFixture(firstActionCode: 1),
        inputAndWake: makeHostInputWakeFixture(normalizedInputSourceCount: 0)
    )
    #expect(
        actionBeforeInput.validate()
            == .invalid(
                stage: .actionAndModel,
                error: .invalidActionDomain
            )
    )

    var inputBeforePolicy = makeValidHostValidator(
        inputAndWake: makeHostInputWakeFixture(normalizedInputSourceCount: 0),
        residualPolicyTable: HostValidatorPolicyFixture(
            overriddenContext: .activation,
            overriddenAllowed: .continueOperation
        )
    )
    #expect(
        inputBeforePolicy.validate()
            == .invalid(
                stage: .inputAndWake,
                error: .invalidInputIntegration
            )
    )
}

@Test func finalAssemblyReportContainsOnlyValidatedImmutableValues() {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    var validator = makeValidHostValidator()
    guard case .valid(let report) = validator.validate() else {
        Issue.record("exact fixture must produce a report")
        return
    }
    #expect(report.kind == preset.kind)
    #expect(report.profile == preset.profile)
    #expect(report.capabilitySnapshot.rasterPresentation == report.effectivePresentation)
    #expect(report.drawingPlanOperationLimit == 5)
    #expect(report.minimumSinkOperationCapacity == 150)
    #expect(report.cardinality == preset.cardinality)
    #expect(report.minimumFrameIntervalMicroseconds == 250_000)
    #expect(report.maximumFactServiceLatencyMicroseconds == 250_000)
    #expect(report.minimumAcceptedTransitionSpacingMicroseconds == 50_000)
    #expect(report.maximumCompactFactsPerServiceWindow == 28)
    #expect(report.maximumRetryableRefusals == 3)
}

@Test func validationAccessLedgerStopsAtEveryFirstFailure() {
    let validGraph = makeHostValidatorGraph()
    var graphFailure = makeValidHostValidator(
        componentGraph: HostValidatorGraphFixture(
            records: Array(validGraph.records.dropLast())
        )
    )
    _ = graphFailure.validate()
    expectAccessPrefix(graphFailure.validationAccessLedger, through: .graph)

    var runtimeFailure = makeValidHostValidator(
        runtimeProfileValidation: .invalid(.missingStorage)
    )
    _ = runtimeFailure.validate()
    expectAccessPrefix(runtimeFailure.validationAccessLedger, through: .runtimeProfile)

    var textFailure = makeValidHostValidator(
        textResourceValidation: .invalid(.invalidIdentity)
    )
    _ = textFailure.validate()
    expectAccessPrefix(textFailure.validationAccessLedger, through: .textResources)

    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    let workload = preset.workload
    var workloadFailure = makeValidHostValidator(
        workload: SignalAnalyzerHostWorkload(
            schemaVersion: 1,
            requiredRuntimeLimits: workload.requiredRuntimeLimits,
            semanticNodeOccurrences: workload.semanticNodeOccurrences,
            semanticStructuralOccurrences: workload.semanticStructuralOccurrences,
            renderSemanticScopeOccurrences: workload.renderSemanticScopeOccurrences,
            layoutScopeOccurrences: workload.layoutScopeOccurrences,
            maximumRenderTraversalDepth: workload.maximumRenderTraversalDepth,
            renderTextLineCount: workload.renderTextLineCount,
            positionedGlyphCount: workload.positionedGlyphCount,
            ordinaryRenderOperations: workload.ordinaryRenderOperations,
            inputEventsPerOpportunity: workload.inputEventsPerOpportunity,
            semanticActionsPerOpportunity: workload.semanticActionsPerOpportunity,
            completionFactsPerOpportunity: workload.completionFactsPerOpportunity,
            drawing: workload.drawing
        )
    )
    _ = workloadFailure.validate()
    expectAccessPrefix(workloadFailure.validationAccessLedger, through: .workload)

    var capabilityFailure = makeValidHostValidator(
        capabilityContributions: .init()
    )
    _ = capabilityFailure.validate()
    expectAccessPrefix(capabilityFailure.validationAccessLedger, through: .capability)

    var endpointFailure = makeValidHostValidator(
        endpoint: makeHostEndpointFixture(displayMaximumInFlightBytes: 3_839)
    )
    _ = endpointFailure.validate()
    expectAccessPrefix(endpointFailure.validationAccessLedger, through: .endpoint)

    var actionFailure = makeValidHostValidator(
        actionAndModel: makeHostActionModelFixture(firstActionCode: 1)
    )
    _ = actionFailure.validate()
    expectAccessPrefix(actionFailure.validationAccessLedger, through: .actionAndModel)

    var inputFailure = makeValidHostValidator(
        inputAndWake: makeHostInputWakeFixture(normalizedInputSourceCount: 0)
    )
    _ = inputFailure.validate()
    expectAccessPrefix(inputFailure.validationAccessLedger, through: .inputAndWake)

    var policyFailure = makeValidHostValidator(
        residualPolicyTable: HostValidatorPolicyFixture(
            overriddenContext: .activation,
            overriddenAllowed: .continueOperation
        )
    )
    _ = policyFailure.validate()
    expectAccessPrefix(policyFailure.validationAccessLedger, through: .policy)
}

@Test func successfulAndRepeatedValidationPreserveBoundedAccessEvidence() {
    var validator = makeValidHostValidator()
    guard case .valid = validator.validate() else {
        Issue.record("valid fixture must reach every stage")
        return
    }
    expectAccessPrefix(validator.validationAccessLedger, through: .policy)
    let completedLedger = validator.validationAccessLedger

    #expect(
        validator.validate()
            == .invalid(stage: .graph, error: .invariantViolation)
    )
    #expect(validator.validationAccessLedger == completedLedger)
}

private func expectAccessPrefix(
    _ ledger: HostValidationAccessLedger,
    through finalStage: HostValidationStage
) {
    #expect(ledger.accessCount == finalStage.rawValue + 1)
    #expect(ledger.sideEffectCount == 0)
    for rawValue in UInt8(0) ... 8 {
        let stage = HostValidationStage(rawValue: rawValue)!
        #expect(ledger.contains(stage) == (rawValue <= finalStage.rawValue))
    }
}
