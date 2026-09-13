import GiftUICapabilities
import GiftUIFailureCore
import GiftUIHostConfiguration
import GiftUIRuntimeCore
import GiftUITextResources

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

func verifyHostConfigurationSurface() {
    requireSendable(MVPHostKind.self)
    requireSendable(HostResidualPolicyContext.self)
    requireSendable(HostValidationStage.self)
    requireSendable(HostConfigurationError.self)
    requireSendable(HostAssemblyReport.self)
    requireSendable(HostValidationResult.self)
    requireSendable(MVPHostLifecycleState.self)
    requireSendable(HostActivationResult<CompileActivationFailure>.self)
    requireSendable(HostOpportunityResult.self)

    var instance = CompileHostInstance()
    var validator = CompileValidator()
    _ = instance.activate()
    _ = instance.runOpportunity()
    instance.teardown()
    _ = validator.validate()
    _ = CompileResidualPolicy()
}
