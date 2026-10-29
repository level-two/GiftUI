import GiftUIHostConfiguration

// This fixture is compiled with the actual Counter types. It is a graph-only
// oracle, not a replacement for the complete Static allocation boundary.
package func counterGraphAllocationProbe() -> Int {
    guard case .none = HostComponentGraphValidation.validate(CounterHostGraph()) else { return 0 }
    for mode: UInt8 in 0...7 {
        let failure = HostComponentGraphValidation.validate(CounterInvalidGraph(mode: mode))
        switch mode {
        case 0:
            guard case .missingRole(.residualPolicy)? = failure else { return 0 }
        case 1:
            guard case .duplicateRole(.wakeRequester)? = failure else { return 0 }
        case 3:
            guard case .missingRole(.useCaseSet)? = failure else { return 0 }
        default:
            guard case .invalidGraph? = failure else { return 0 }
        }
    }
    return 9
}

package func counterGraphRoleMappingProbe() -> Int {
    for wide: UInt16 in 0...255 {
        let raw = UInt8(wide)
        let actual = HostComponentRole(rawValue: raw)
        switch raw {
        case 0:
            guard case .runtimeProfile? = actual else { return 0 }
        case 1:
            guard case .textResourcePackage? = actual else { return 0 }
        case 2:
            guard case .renderProducerContribution? = actual else { return 0 }
        case 3:
            guard case .rasterBackendContribution? = actual else { return 0 }
        case 4:
            guard case .surfaceDisplayContribution? = actual else { return 0 }
        case 5:
            guard case .hostResourcePolicyContribution? = actual else { return 0 }
        case 6:
            guard case .rasterEndpoint? = actual else { return 0 }
        case 7:
            guard case .applicationExecutor? = actual else { return 0 }
        case 8:
            guard case .signalSource? = actual else { return 0 }
        case 9:
            guard case .signalRepository? = actual else { return 0 }
        case 10:
            guard case .useCaseSet? = actual else { return 0 }
        case 11:
            guard case .factAdmission? = actual else { return 0 }
        case 12:
            guard case .actionDomain? = actual else { return 0 }
        case 13:
            guard case .actionHandler? = actual else { return 0 }
        case 14:
            guard case .rootModelTarget? = actual else { return 0 }
        case 15:
            guard case .normalizedInput? = actual else { return 0 }
        case 16:
            guard case .wakeRequester? = actual else { return 0 }
        case 17:
            guard case .residualPolicy? = actual else { return 0 }
        default:
            guard case nil = actual else { return 0 }
        }
        if let actual {
            guard actual.rawValue == raw else { return 0 }
        }
    }
    return 256
}

@main struct Main {
    static func main() {
        let graphChecks = counterGraphAllocationProbe()
        precondition(graphChecks == 9)
        let mappingChecks = counterGraphRoleMappingProbe()
        precondition(mappingChecks == 256)
        let staticChecks = p08CounterStaticResourceEntryV1()
        precondition(staticChecks > 0)
        counterDiagnosticStaticResourceSummary(staticChecks)
        let modelChecks = p08CounterModel()
        let semanticChecks = p08CounterSemantic()
        let fixedStorageChecks = p08CounterFixedStorage()
        let coordinatorChecks = p08CounterCoordinator()
        let mixedStorageChecks = counterExerciseScopedStorage()
        let dynamicHostChecks = p08CounterDynamicHost()
        precondition(modelChecks > 0 && semanticChecks > 0 && fixedStorageChecks > 0 && coordinatorChecks > 0 && mixedStorageChecks > 0 && dynamicHostChecks > 0)
        print("P08_GROUPED_FUNCTIONAL", graphChecks, mappingChecks, staticChecks, modelChecks, semanticChecks, fixedStorageChecks, coordinatorChecks, mixedStorageChecks, dynamicHostChecks)
    }
}
