import GiftUIObservableState
import GiftUIRuntimeDynamic
@main struct RootChecks {
    static func main() throws {
        let checks = try staticRootChecks()
        let lexicalChecks = try staticLexicalChecks()
        precondition(lexicalChecks == 29)
        print("P03 scoped generated lexical traversal checks=\(lexicalChecks) failures=0")
        var namespace = ObservableModelOwnerNamespace()
        let root = DynamicObservableRootAdapter<RootModel, UInt8>(identity: try namespace.issue(), schema: 7, needsCapture: true)!
        let dynamicChecks = try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
            trace.initialize(repeating: RootTrace())
            defer { trace.deinitialize() }
            return try root.withLifetime { (scope, owner) throws(ObservableStateError) in try exerciseRoot(scope, owner, trace.baseAddress!) }
        }
        var dynamicLexical: UInt32 = 0
        for failure in [false, true] {
            let lexicalRoot = DynamicObservableRootAdapter<RootModel, UInt8>(identity: try namespace.issue(), schema: 7, needsCapture: false)!
            dynamicLexical += try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
                trace.initialize(repeating: RootTrace()); defer { trace.deinitialize() }
                return try lexicalRoot.withLifetime { (scope, owner) throws(ObservableStateError) in try exerciseLexical(scope, owner, trace.baseAddress!, failure: failure) }
            }
        }
        precondition(dynamicLexical == lexicalChecks)
        print("P03 Dynamic scoped generated lexical checks=\(dynamicLexical) failures=0")
        precondition(checks == dynamicChecks && checks > 60)
        let entryChecks = try rootEntryPhaseChecks()
        precondition(entryChecks == 43)
        print("P03 root-entry phase and scoped-exit checks=\(entryChecks) failures=0")
        let retainingChecks = try retainingSinkChecks()
        precondition(retainingChecks == 37)
        print("P03 retaining-sink terminal teardown checks=\(retainingChecks) failures=0")
        let precedenceChecks = try rootGenerationPrecedenceChecks()
        precondition(precedenceChecks == 23)
        print("P03 root generation/capacity precedence checks=\(precedenceChecks) failures=0")
        print("P03 production root callbacks static=\(checks) dynamic=\(dynamicChecks) failures=0")
    }
}
