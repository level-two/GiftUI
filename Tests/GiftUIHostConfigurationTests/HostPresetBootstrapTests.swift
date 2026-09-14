import GiftUICapabilities
import GiftUIRuntimeCore
import GiftUITextResources
import Testing

@testable import GiftUIHostConfiguration

private enum BootstrapActivationFailure: Equatable, Sendable {
    case unavailable
}

private final class BootstrapProbe {
    var validationCount = 0
    var constructionCount = 0
    var auditCount = 0
    var teardownCount = 0
}

private struct CountingBootstrapValidator: MVPHostConfigurationValidator, ~Copyable {
    var base:
        CheckedMVPHostConfigurationValidator<
            HostValidatorGraphFixture, HostValidatorPolicyFixture
        >
    let probe: BootstrapProbe

    var structuralConfiguration: HostStructuralConfiguration {
        base.structuralConfiguration
    }
    var componentGraph: HostValidatorGraphFixture { base.componentGraph }
    var textResourceValidation: TextResourceValidationResult {
        base.textResourceValidation
    }
    var capabilityRequirement: RasterPresentationRequirement {
        base.capabilityRequirement
    }
    var capabilityContributions: RasterPresentationContributions {
        base.capabilityContributions
    }
    var capabilityWorkspace: RasterPresentationResolverWorkspace {
        get { base.capabilityWorkspace }
        set { base.capabilityWorkspace = newValue }
    }
    var endpoint: HostEndpointConfiguration { base.endpoint }
    var actionAndModel: HostActionModelConfiguration { base.actionAndModel }
    var inputAndWake: HostInputWakeConfiguration { base.inputAndWake }
    var residualPolicyTable: HostValidatorPolicyFixture {
        base.residualPolicyTable
    }

    mutating func validate() -> HostValidationResult {
        probe.validationCount += 1
        return base.validate()
    }
}

private struct PresetBootstrapValidator: MVPHostConfigurationValidator, ~Copyable {
    var base: CountingBootstrapValidator
    let report: HostAssemblyReport

    var structuralConfiguration: HostStructuralConfiguration { base.structuralConfiguration }
    var componentGraph: HostValidatorGraphFixture { base.componentGraph }
    var textResourceValidation: TextResourceValidationResult { base.textResourceValidation }
    var capabilityRequirement: RasterPresentationRequirement { base.capabilityRequirement }
    var capabilityContributions: RasterPresentationContributions {
        base.capabilityContributions
    }
    var capabilityWorkspace: RasterPresentationResolverWorkspace {
        get { base.capabilityWorkspace }
        set { base.capabilityWorkspace = newValue }
    }
    var endpoint: HostEndpointConfiguration { base.endpoint }
    var actionAndModel: HostActionModelConfiguration { base.actionAndModel }
    var inputAndWake: HostInputWakeConfiguration { base.inputAndWake }
    var residualPolicyTable: HostValidatorPolicyFixture { base.residualPolicyTable }

    mutating func validate() -> HostValidationResult {
        base.probe.validationCount += 1
        return .valid(report)
    }
}

private struct BootstrapInstance: MVPHostInstance {
    let assemblyReport: HostAssemblyReport
    let probe: BootstrapProbe
    private(set) var lifecycleState = MVPHostLifecycleState.valid

    mutating func activate() -> HostActivationResult<BootstrapActivationFailure> {
        lifecycleState = .active
        return .active
    }

    mutating func runOpportunity() -> HostOpportunityResult {
        .invalidLifecycle
    }

    mutating func teardown() {
        probe.teardownCount += 1
        lifecycleState = .quiescent
    }
}

private struct BootstrapFactory: MVPValidatedHostInstanceFactory {
    let probe: BootstrapProbe
    let endpoint: HostEndpointConfiguration
    let ownerOverride: HostOwnerOverride?
    let reportIsCorrupted: Bool
    let endpointIsCorrupted: Bool

    mutating func construct(
        validatedBy report: HostAssemblyReport
    ) -> BootstrapInstance {
        probe.constructionCount += 1
        return BootstrapInstance(assemblyReport: report, probe: probe)
    }

    func audit(
        _ instance: borrowing BootstrapInstance
    ) -> HostConstructedInstanceAudit {
        probe.auditCount += 1
        return HostConstructedInstanceAudit(
            assemblyReport: reportIsCorrupted
                ? corruptedReport(instance.assemblyReport)
                : instance.assemblyReport,
            endpoint: endpointIsCorrupted
                ? makeHostEndpointFixture(displayMaximumInFlightBytes: 3_839)
                : endpoint,
            owners: exactOwnerCounts(overriding: ownerOverride)
        )
    }
}

private enum HostOwnerOverride: CaseIterable {
    case runtime
    case endpoint
    case resourcePackage
    case capabilitySnapshot
    case rootModelTarget
    case actionHandler
    case applicationExecutor
    case wakeIntegration
    case residualPolicyTable
}

@Test func invalidValidationNeverConstructsOrAuditsAnInstance() {
    let probe = BootstrapProbe()
    let endpoint = exactBootstrapEndpoint()
    let result = HostPresetBootstrap.construct(
        validator: CountingBootstrapValidator(
            base: makeValidHostValidator(
                textResourceValidation: .invalid(.invalidIdentity)
            ),
            probe: probe
        ),
        factory: BootstrapFactory(
            probe: probe,
            endpoint: endpoint,
            ownerOverride: nil,
            reportIsCorrupted: false,
            endpointIsCorrupted: false
        ),
        expectedEndpoint: endpoint
    )

    guard case .invalid(let validation) = result else {
        Issue.record("invalid configuration must expose no instance")
        return
    }
    #expect(
        validation
            == .invalid(
                stage: .textResources,
                error: .invalidTextResources(.invalidIdentity)
            )
    )
    #expect(probe.validationCount == 1)
    #expect(probe.constructionCount == 0)
    #expect(probe.auditCount == 0)
    #expect(probe.teardownCount == 0)
}

@Test func validValidationConstructsAndAuditsExactlyOneInstance() {
    let probe = BootstrapProbe()
    let endpoint = exactBootstrapEndpoint()
    let result = HostPresetBootstrap.construct(
        validator: CountingBootstrapValidator(
            base: makeValidHostValidator(endpoint: endpoint),
            probe: probe
        ),
        factory: BootstrapFactory(
            probe: probe,
            endpoint: endpoint,
            ownerOverride: nil,
            reportIsCorrupted: false,
            endpointIsCorrupted: false
        ),
        expectedEndpoint: endpoint
    )

    guard case .constructed(let instance) = result else {
        Issue.record("valid configuration must expose one instance")
        return
    }
    #expect(instance.lifecycleState == .valid)
    #expect(
        instance.assemblyReport.capabilitySnapshot.rasterPresentation
            == instance.assemblyReport.effectivePresentation
    )
    #expect(instance.assemblyReport.effectivePresentation == endpoint.effectivePresentation)
    #expect(probe.constructionCount == 1)
    #expect(probe.validationCount == 1)
    #expect(probe.auditCount == 1)
    #expect(probe.teardownCount == 0)
}

@Test func structuralAndCapabilityGatesBlockLiveConstructionIndependently() {
    let endpoint = exactBootstrapEndpoint()

    let capabilityProbe = BootstrapProbe()
    let capabilityResult = HostPresetBootstrap.construct(
        validator: CountingBootstrapValidator(
            base: makeValidHostValidator(
                capabilityContributions: RasterPresentationContributions()
            ),
            probe: capabilityProbe
        ),
        factory: BootstrapFactory(
            probe: capabilityProbe,
            endpoint: endpoint,
            ownerOverride: nil,
            reportIsCorrupted: false,
            endpointIsCorrupted: false
        ),
        expectedEndpoint: endpoint
    )
    guard case .invalid(let capabilityFailure) = capabilityResult else {
        Issue.record("valid B2 with unavailable capability must expose no instance")
        return
    }
    #expect(
        capabilityFailure
            == .invalid(
                stage: .capability,
                error: .capabilityUnavailable(
                    .missingContributor(role: .renderProducer)
                )
            )
    )
    #expect(capabilityProbe.validationCount == 1)
    #expect(capabilityProbe.constructionCount == 0)
    #expect(capabilityProbe.auditCount == 0)

    var incompleteRecords = makeHostValidatorGraph().records
    incompleteRecords.removeLast()
    let structuralProbe = BootstrapProbe()
    let structuralResult = HostPresetBootstrap.construct(
        validator: CountingBootstrapValidator(
            base: makeValidHostValidator(
                componentGraph: HostValidatorGraphFixture(
                    records: incompleteRecords
                )
            ),
            probe: structuralProbe
        ),
        factory: BootstrapFactory(
            probe: structuralProbe,
            endpoint: endpoint,
            ownerOverride: nil,
            reportIsCorrupted: false,
            endpointIsCorrupted: false
        ),
        expectedEndpoint: endpoint
    )
    guard case .invalid(let structuralFailure) = structuralResult else {
        Issue.record("invalid B2 with valid capability must expose no instance")
        return
    }
    #expect(
        structuralFailure
            == .invalid(
                stage: .graph,
                error: .missingRole(.residualPolicy)
            )
    )
    #expect(structuralProbe.validationCount == 1)
    #expect(structuralProbe.constructionCount == 0)
    #expect(structuralProbe.auditCount == 0)
}

@Test(
    arguments: [
        MVPHostKind.macOSDynamic, .macOSStatic, .raspberryPiDynamic,
        .nrf52840Static,
    ]
)
private func eachConcretePresetConstructionSeamValidatesAndConstructsOnlyItsKind(
    kind: MVPHostKind
) {
    let probe = BootstrapProbe()
    let endpoint = exactBootstrapEndpoint()
    let baseReport = validBootstrapReport(endpoint: endpoint)
    let report = HostAssemblyReport(
        kind: kind,
        profile: kind == .macOSDynamic || kind == .raspberryPiDynamic ? .dynamic : .static,
        storageAudit: baseReport.storageAudit,
        capabilitySnapshot: baseReport.capabilitySnapshot,
        effectivePresentation: baseReport.effectivePresentation,
        drawingPlanOperationLimit: baseReport.drawingPlanOperationLimit,
        minimumSinkOperationCapacity: baseReport.minimumSinkOperationCapacity,
        cardinality: baseReport.cardinality,
        minimumFrameIntervalMicroseconds: baseReport.minimumFrameIntervalMicroseconds,
        maximumFactServiceLatencyMicroseconds: baseReport.maximumFactServiceLatencyMicroseconds,
        minimumAcceptedTransitionSpacingMicroseconds:
            baseReport.minimumAcceptedTransitionSpacingMicroseconds,
        maximumCompactFactsPerServiceWindow: baseReport.maximumCompactFactsPerServiceWindow,
        maximumRetryableRefusals: baseReport.maximumRetryableRefusals
    )
    let validator = PresetBootstrapValidator(
        base: CountingBootstrapValidator(
            base: makeValidHostValidator(endpoint: endpoint),
            probe: probe
        ),
        report: report
    )
    let factory = BootstrapFactory(
        probe: probe,
        endpoint: endpoint,
        ownerOverride: nil,
        reportIsCorrupted: false,
        endpointIsCorrupted: false
    )
    let result = constructPreset(
        kind,
        validator: validator,
        factory: factory,
        endpoint: endpoint
    )

    guard case .constructed(let instance) = result else {
        Issue.record("matching preset must construct")
        return
    }
    #expect(instance.assemblyReport.kind == kind)
    #expect(probe.validationCount == 1)
    #expect(probe.constructionCount == 1)
    #expect(probe.auditCount == 1)
}

@Test func concretePresetRejectsMismatchedValidatedReportBeforeLiveConstruction() {
    let probe = BootstrapProbe()
    let endpoint = exactBootstrapEndpoint()
    let validator = PresetBootstrapValidator(
        base: CountingBootstrapValidator(
            base: makeValidHostValidator(endpoint: endpoint),
            probe: probe
        ),
        report: validBootstrapReport(endpoint: endpoint)
    )
    let result = SignalAnalyzerHostPresetConstruction.macOSDynamic(
        validator: validator,
        factory: BootstrapFactory(
            probe: probe,
            endpoint: endpoint,
            ownerOverride: nil,
            reportIsCorrupted: false,
            endpointIsCorrupted: false
        ),
        expectedEndpoint: endpoint
    )

    guard case .invalid(let failure) = result else {
        Issue.record("mismatched preset must fail closed")
        return
    }
    #expect(failure == .invalid(stage: .runtimeProfile, error: .profileMismatch))
    #expect(probe.validationCount == 1)
    #expect(probe.constructionCount == 0)
    #expect(probe.auditCount == 0)
}

private func validBootstrapReport(
    endpoint: HostEndpointConfiguration
) -> HostAssemblyReport {
    var validator = makeValidHostValidator(endpoint: endpoint)
    guard case .valid(let report) = validator.validate() else {
        fatalError("valid bootstrap fixture must produce a report")
    }
    return report
}

private func constructPreset<Validator: ~Copyable, Factory>(
    _ kind: MVPHostKind,
    validator: consuming Validator,
    factory: consuming Factory,
    endpoint: HostEndpointConfiguration
) -> HostPresetConstructionResult<Factory.Instance>
where
    Validator: MVPHostConfigurationValidator,
    Factory: MVPValidatedHostInstanceFactory
{
    switch kind {
    case .macOSDynamic:
        SignalAnalyzerHostPresetConstruction.macOSDynamic(
            validator: consume validator,
            factory: consume factory,
            expectedEndpoint: endpoint
        )
    case .macOSStatic:
        SignalAnalyzerHostPresetConstruction.macOSStatic(
            validator: consume validator,
            factory: consume factory,
            expectedEndpoint: endpoint
        )
    case .raspberryPiDynamic:
        SignalAnalyzerHostPresetConstruction.raspberryPiDynamic(
            validator: consume validator,
            factory: consume factory,
            expectedEndpoint: endpoint
        )
    case .nrf52840Static:
        SignalAnalyzerHostPresetConstruction.nrf52840Static(
            validator: consume validator,
            factory: consume factory,
            expectedEndpoint: endpoint
        )
    }
}

@Test(arguments: HostOwnerOverride.allCases)
private func everyIncorrectOwnerCardinalityDiscardsAndTearsDown(
    override: HostOwnerOverride
) {
    let probe = BootstrapProbe()
    let endpoint = exactBootstrapEndpoint()
    let result = HostPresetBootstrap.construct(
        validator: makeValidHostValidator(endpoint: endpoint),
        factory: BootstrapFactory(
            probe: probe,
            endpoint: endpoint,
            ownerOverride: override,
            reportIsCorrupted: false,
            endpointIsCorrupted: false
        ),
        expectedEndpoint: endpoint
    )

    guard case .invalid(let validation) = result else {
        Issue.record("incorrect owner cardinality must expose no instance")
        return
    }
    #expect(
        validation
            == .invalid(
                stage: .graph,
                error: .invariantViolation
            )
    )
    #expect(probe.constructionCount == 1)
    #expect(probe.auditCount == 1)
    #expect(probe.teardownCount == 1)
}

@Test(arguments: [(true, false), (false, true)])
func reportOrEndpointMismatchDiscardsAndTearsDown(
    reportIsCorrupted: Bool,
    endpointIsCorrupted: Bool
) {
    let probe = BootstrapProbe()
    let endpoint = exactBootstrapEndpoint()
    let result = HostPresetBootstrap.construct(
        validator: makeValidHostValidator(endpoint: endpoint),
        factory: BootstrapFactory(
            probe: probe,
            endpoint: endpoint,
            ownerOverride: nil,
            reportIsCorrupted: reportIsCorrupted,
            endpointIsCorrupted: endpointIsCorrupted
        ),
        expectedEndpoint: endpoint
    )

    guard case .invalid(let validation) = result else {
        Issue.record("post-construction mismatch must expose no instance")
        return
    }
    #expect(
        validation
            == (reportIsCorrupted
                ? .invalid(stage: .graph, error: .invariantViolation)
                : .invalid(stage: .endpoint, error: .invalidEndpointDescriptor))
    )
    #expect(probe.teardownCount == 1)
}

private func exactBootstrapEndpoint() -> HostEndpointConfiguration {
    makeHostEndpointFixture()
}

private func exactOwnerCounts(
    overriding override: HostOwnerOverride?
) -> HostConstructedOwnerCardinality {
    func count(_ field: HostOwnerOverride) -> UInt8 {
        override == field ? 0 : 1
    }
    return HostConstructedOwnerCardinality(
        runtimeCount: count(.runtime),
        endpointCount: count(.endpoint),
        resourcePackageCount: count(.resourcePackage),
        capabilitySnapshotCount: count(.capabilitySnapshot),
        rootModelTargetCount: count(.rootModelTarget),
        actionHandlerCount: count(.actionHandler),
        applicationExecutorCount: count(.applicationExecutor),
        wakeIntegrationCount: count(.wakeIntegration),
        residualPolicyTableCount: count(.residualPolicyTable)
    )
}

private func corruptedReport(_ report: HostAssemblyReport) -> HostAssemblyReport {
    HostAssemblyReport(
        kind: report.kind,
        profile: report.profile,
        storageAudit: report.storageAudit,
        capabilitySnapshot: report.capabilitySnapshot,
        effectivePresentation: report.effectivePresentation,
        drawingPlanOperationLimit: report.drawingPlanOperationLimit,
        minimumSinkOperationCapacity: report.minimumSinkOperationCapacity,
        cardinality: report.cardinality,
        minimumFrameIntervalMicroseconds: report.minimumFrameIntervalMicroseconds,
        maximumFactServiceLatencyMicroseconds:
            report.maximumFactServiceLatencyMicroseconds,
        minimumAcceptedTransitionSpacingMicroseconds:
            report.minimumAcceptedTransitionSpacingMicroseconds,
        maximumCompactFactsPerServiceWindow:
            report.maximumCompactFactsPerServiceWindow,
        maximumRetryableRefusals: report.maximumRetryableRefusals - 1
    )
}
