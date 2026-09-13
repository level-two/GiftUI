import GiftUIFailureCore
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
    #expect(report.minimumSinkOperationCapacity == 35)
    #expect(report.cardinality == preset.cardinality)
    #expect(report.minimumFrameIntervalMicroseconds == 250_000)
    #expect(report.maximumFactServiceLatencyMicroseconds == 250_000)
    #expect(report.minimumAcceptedTransitionSpacingMicroseconds == 50_000)
    #expect(report.maximumCompactFactsPerServiceWindow == 28)
    #expect(report.maximumRetryableRefusals == 3)
}
