package struct HostConstructedOwnerCardinality: Equatable, Sendable {
    package let runtimeCount: UInt8
    package let endpointCount: UInt8
    package let resourcePackageCount: UInt8
    package let capabilitySnapshotCount: UInt8
    package let rootModelTargetCount: UInt8
    package let actionHandlerCount: UInt8
    package let applicationExecutorCount: UInt8
    package let wakeIntegrationCount: UInt8
    package let residualPolicyTableCount: UInt8

    package var isExact: Bool {
        runtimeCount == 1
            && endpointCount == 1
            && resourcePackageCount == 1
            && capabilitySnapshotCount == 1
            && rootModelTargetCount == 1
            && actionHandlerCount == 1
            && applicationExecutorCount == 1
            && wakeIntegrationCount == 1
            && residualPolicyTableCount == 1
    }
}

package struct HostConstructedInstanceAudit: Equatable, Sendable {
    package let assemblyReport: HostAssemblyReport
    package let endpoint: HostEndpointConfiguration
    package let owners: HostConstructedOwnerCardinality
}

package protocol MVPValidatedHostInstanceFactory: ~Copyable {
    associatedtype Instance: MVPHostInstance

    mutating func construct(
        validatedBy report: HostAssemblyReport
    ) -> Instance

    borrowing func audit(
        _ instance: borrowing Instance
    ) -> HostConstructedInstanceAudit
}

package enum HostPresetConstructionResult<Instance>
where Instance: MVPHostInstance {
    case invalid(HostValidationResult)
    case constructed(Instance)
}

package enum HostPresetBootstrap {
    package static func construct<Validator: ~Copyable, Factory: ~Copyable>(
        validator: consuming Validator,
        factory: consuming Factory,
        expectedEndpoint: HostEndpointConfiguration
    ) -> HostPresetConstructionResult<Factory.Instance>
    where
        Validator: MVPHostConfigurationValidator,
        Factory: MVPValidatedHostInstanceFactory
    {
        var validator = consume validator
        switch validator.validate() {
        case .invalid(let stage, let error):
            return .invalid(.invalid(stage: stage, error: error))
        case .valid(let report):
            var factory = consume factory
            var instance = factory.construct(validatedBy: report)
            let audit = factory.audit(instance)
            guard audit.assemblyReport == report, audit.owners.isExact else {
                instance.teardown()
                return .invalid(
                    .invalid(
                        stage: .graph,
                        error: .invariantViolation
                    )
                )
            }
            guard audit.endpoint == expectedEndpoint,
                audit.endpoint.effectivePresentation == report.effectivePresentation
            else {
                instance.teardown()
                return .invalid(
                    .invalid(
                        stage: .endpoint,
                        error: .invalidEndpointDescriptor
                    )
                )
            }
            return .constructed(instance)
        }
    }
}
