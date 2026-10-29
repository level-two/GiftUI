import GiftUIHostConfiguration

// This fixture is compiled with the actual Counter types. It is a graph-only
// oracle, not a replacement for the complete Static allocation boundary.
@_noAllocation
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
