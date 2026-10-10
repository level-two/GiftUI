import GiftUIObservableState
import GiftUIRuntimeDynamic
@main struct RootChecks {
    static func main() throws {
        let checks = try staticRootChecks()
        var namespace = ObservableModelOwnerNamespace()
        let root = DynamicObservableRootAdapter<RootModel, UInt8>(identity: try namespace.issue(), schema: 7, needsCapture: true)!
        let dynamicChecks = try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
            trace.initialize(repeating: RootTrace())
            defer { trace.deinitialize() }
            return try root.withLifetime { (scope, owner) throws(ObservableStateError) in try exerciseRoot(scope, owner, trace.baseAddress!) }
        }
        precondition(checks == dynamicChecks && checks > 60)
        print("P03 production root callbacks static=\(checks) dynamic=\(dynamicChecks) failures=0")
    }
}
