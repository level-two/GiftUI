import GiftUICapabilities
import GiftUIFailureCore
import GiftUIRuntimeCore
import GiftUITextResources
import Testing

@testable import GiftUIHostConfiguration

private enum CompileActivationFailure: UInt8, Equatable, Sendable {
    case failed
}

private struct CompileHostInstance: MVPHostInstance, ~Copyable {
    typealias ActivationFailure = CompileActivationFailure

    var lifecycleState: MVPHostLifecycleState { .valid }
    var assemblyReport: HostAssemblyReport { fatalError("compile-only surface") }

    mutating func activate() -> HostActivationResult<ActivationFailure> {
        .failure(.failed)
    }

    mutating func runOpportunity() -> HostOpportunityResult {
        .invalidLifecycle
    }

    mutating func teardown() {}
}

private struct CompileComponentGraph: HostComponentGraphView {
    var count: UInt8 { 0 }

    borrowing func record(at index: UInt8) -> HostComponentRecord? {
        _ = index
        return nil
    }
}

private struct CompileResidualPolicyTable: MVPHostResidualPolicyTable {
    var fatalHookIsAvailable: Bool { false }

    borrowing func allowed(
        for context: HostResidualPolicyContext
    ) -> GiftUIAllowedDispositions {
        _ = context
        return .quiesceAffectedScope
    }

    borrowing func selection(
        for context: HostResidualPolicyContext
    ) -> GiftUIResidualDisposition {
        _ = context
        return .quiesceAffectedScope
    }
}

private struct CompileValidator: MVPHostConfigurationValidator, ~Copyable {
    typealias ComponentGraph = CompileComponentGraph
    typealias ResidualPolicyTable = CompileResidualPolicyTable

    var structuralConfiguration: HostStructuralConfiguration {
        fatalError("compile-only surface")
    }
    var componentGraph: CompileComponentGraph { CompileComponentGraph() }
    var textResourceValidation: TextResourceValidationResult { .valid }
    var capabilityRequirement: RasterPresentationRequirement {
        fatalError("compile-only surface")
    }
    var capabilityContributions: RasterPresentationContributions {
        RasterPresentationContributions()
    }
    var capabilityWorkspace: RasterPresentationResolverWorkspace {
        get { RasterPresentationResolverWorkspace()! }
        set { _ = newValue }
    }
    var endpoint: HostEndpointConfiguration { fatalError("compile-only surface") }
    var actionAndModel: HostActionModelConfiguration { fatalError("compile-only surface") }
    var inputAndWake: HostInputWakeConfiguration { fatalError("compile-only surface") }
    var residualPolicyTable: CompileResidualPolicyTable { CompileResidualPolicyTable() }

    mutating func validate() -> HostValidationResult {
        .invalid(stage: .graph, error: .invariantViolation)
    }
}

private struct CompileResidualPolicy: MVPHostResidualPolicy {
    mutating func disposition(
        for input: GiftUIResidualPolicyInput<HostResidualPolicyContext>
    ) -> GiftUIResidualDisposition {
        _ = input
        return .quiesceAffectedScope
    }
}

private func requireSendable<T: Sendable>(_: T.Type) {}

@Test func hostConfigurationResultsPreserveEveryAssociatedPayloadFamily() {
    let runtime = HostConfigurationError.invalidRuntimeProfile(.missingStorage)
    let text = HostConfigurationError.invalidTextResources(.malformedMapping)
    let capability = HostConfigurationError.capabilityUnavailable(
        .missingContributor(role: .rasterBackend)
    )

    #expect(runtime == .invalidRuntimeProfile(.missingStorage))
    #expect(text == .invalidTextResources(.malformedMapping))
    #expect(
        capability
            == .capabilityUnavailable(
                .missingContributor(role: .rasterBackend)
            )
    )
    #expect(
        HostValidationResult.invalid(stage: .runtimeProfile, error: runtime)
            == .invalid(stage: .runtimeProfile, error: .invalidRuntimeProfile(.missingStorage))
    )
    #expect(
        HostActivationResult<CompileActivationFailure>.failure(.failed)
            == .failure(.failed)
    )
    #expect(HostOpportunityResult.invalidLifecycle == .invalidLifecycle)
}

@Test func hostConfigurationResultFamiliesAreSendable() {
    requireSendable(MVPHostKind.self)
    requireSendable(HostResidualPolicyContext.self)
    requireSendable(HostValidationStage.self)
    requireSendable(HostConfigurationError.self)
    requireSendable(HostAssemblyReport.self)
    requireSendable(HostValidationResult.self)
    requireSendable(MVPHostLifecycleState.self)
    requireSendable(HostActivationResult<CompileActivationFailure>.self)
    requireSendable(HostOpportunityResult.self)
}

@Test func exactNoncopyableHostProtocolsAcceptFiniteConformers() {
    var instance = CompileHostInstance()
    var validator = CompileValidator()
    var policy = CompileResidualPolicy()

    #expect(instance.lifecycleState == .valid)
    #expect(instance.activate() == .failure(.failed))
    #expect(instance.runOpportunity() == .invalidLifecycle)
    instance.teardown()
    #expect(
        validator.validate()
            == .invalid(stage: .graph, error: .invariantViolation)
    )
    let input = GiftUIResidualPolicyInput(
        outcome: .failure(
            GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .hostComposition,
                affectedScope: .runtime,
                containment: .safetyNotProven
            )
        ),
        context: HostResidualPolicyContext.safetyNotProven,
        allowed: .quiesceAffectedScope,
        attemptOrdinal: 0,
        attemptLimit: 1
    )!
    #expect(policy.disposition(for: input) == .quiesceAffectedScope)
}
