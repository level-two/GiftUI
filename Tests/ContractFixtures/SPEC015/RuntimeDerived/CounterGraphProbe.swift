import GiftUIHostConfiguration
import GiftUIObservableState
import GiftUISemanticCore

// Malformed views are confined to this negative fixture, never accepted by a
// production assembly initializer. Every mutation starts from the actual table.
private struct CounterInvalidGraph: HostComponentGraphView {
    let mode: UInt8
    var count: UInt8 { mode == 0 ? 17 : mode == 7 ? 19 : 18 }
    func record(at index: UInt8) -> HostComponentRecord? {
        let base = CounterHostGraph()
        if mode == 1 && index == 17 { return base.record(at: 16) }
        if mode == 2 && index == 1 { return base.record(at: 2) }
        if mode == 3 && index == 10 { return nil }
        guard let original = base.record(at: index) else { return nil }
        if index == 0 {
            if mode == 4 { return .init(role: original.role, dependencies: .init(rawValue: 1)) }
            if mode == 5 { return .init(role: original.role, dependencies: .init(rawValue: 2)) }
            if mode == 6 { return .init(role: original.role, dependencies: .init(rawValue: 1 << 31)) }
        }
        return original
    }
}
package func p08CounterGraph() -> Int {
    // Independent expected vector from the reviewed actual-owner inventory:
    // endpoint6 needs backing0, text1 and configuration2–5; wake16 retains
    // audit0 and capability2–5 in its full report. Operation-only peers add no edge.
    let expectedMasks: InlineArray<18, UInt32> = [0, 0, 0, 0, 0, 0, 63, 0, 0, 0, 0, 1, 0, 0, 1, 0, 61, 0]
    for index: UInt8 in 0..<18 {
        let record = CounterHostGraph().record(at: index)!
        precondition(record.role.rawValue == index)
        precondition(record.dependencies.rawValue == expectedMasks[Int(index)])
    }
    precondition(HostComponentGraphValidation.validate(CounterHostGraph()) == nil)
    precondition(CounterHostGraph().record(at: 18) == nil)
    for mode: UInt8 in 0...7 { precondition(HostComponentGraphValidation.validate(CounterInvalidGraph(mode: mode)) != nil) }
    var modelOwners = ObservableModelOwnerNamespace()
    var semanticOwners = SemanticRecordOwnerNamespace()
    var count = 46
    do {
        var profile = StaticCounterProfileStorage(modelOwner: try modelOwners.issue(), semanticOwner: try semanticOwners.issue())
        guard case .valid(let audit) = profile.audit() else { preconditionFailure("counter graph audit") }
        func reject(_ negative: CounterConstructionNegative, profile: borrowing StaticCounterProfileStorage) {
            let graph = CounterHostGraph(negative: negative)
            precondition(HostComponentGraphValidation.validate(graph) == nil)
            var observation = CounterConstructionObservation()
            precondition(CounterHostAssembly.validate(audit, kind: .macOSStatic, negative: negative, observation: &observation) == nil)
            precondition(observation.result == .invalid(stage: .graph, error: .invalidGraph))
            precondition(observation.hasNoLaterReads)
            precondition(profile.control.applicationConstructions == 0 && profile.control.finalized == 0 && profile.control.wake == nil)
            count += 5
        }
        for origin: UInt8 in 0...5 { reject(.omitted(.rasterEndpoint, origin), profile: profile) }
        reject(.omitted(.factAdmission, 0), profile: profile)
        reject(.omitted(.rootModelTarget, 0), profile: profile)
        for origin: UInt8 in [0, 2, 3, 4, 5] { reject(.omitted(.wakeRequester, origin), profile: profile) }
        reject(.hiddenSelectedText, profile: profile)
        reject(.hiddenRetainedReport, profile: profile)
        reject(.undeclaredBoundText, profile: profile)
        var positive = CounterConstructionObservation()
        precondition(CounterHostAssembly.validate(audit, kind: .macOSStatic, negative: nil, observation: &positive) != nil)
        guard case .valid? = positive.result else { preconditionFailure("counter graph positive") }
        precondition(positive.runtimeReads == 1 && positive.textReads == 1 && positive.workloadReads == 1 && positive.capabilityReads == 1 && positive.endpointReads == 1 && positive.applicationReads == 1 && positive.inputReads == 1 && positive.policyReads == 1)
        precondition(profile.control.applicationConstructions == 0 && profile.control.finalized == 0 && profile.control.wake == nil)
        count += 4
    } catch { preconditionFailure("counter graph profile identities") }
    return count
}
