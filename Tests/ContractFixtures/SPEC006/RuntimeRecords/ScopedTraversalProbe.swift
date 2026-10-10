import GiftUI
import GiftUIObservableState
import GiftUIRuntimeStatic
import GiftUISemanticCore

@ObservableStateHost
private struct RecordParent: View {
    typealias Domain = RootDomain
    @State<RootSchema> private var model: _GiftUIModelKey<RootSchema>?
    let seed: RootSeed
    init(candidate: _GiftUIModelKey<RootSchema>, seed: RootSeed) {
        _model = State<RootSchema>(candidate: candidate)
        self.seed = seed
    }
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<RootDomain>) throws(_GiftUIAccessFailure) -> some View<RootDomain> {
        let value = try RootDomain.value(_model._giftUIKey(), read)
        precondition(value == 31)
        seed.trace.pointee.parentBodies += 1
        return RecordChild(seed: seed).disabled(false)
    }
}
@ObservableStateHost
private struct RecordChild: View {
    typealias Domain = RootDomain
    @State<RootSchema> private var model: _GiftUIModelKey<RootSchema>?
    let trace: UnsafeMutablePointer<RootTrace>
    init(seed: RootSeed) { _model = State<RootSchema>(seed: seed); trace = seed.trace }
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<RootDomain>) throws(_GiftUIAccessFailure) -> some View<RootDomain> {
        let value = try RootDomain.value(_model._giftUIKey(), read)
        precondition(value == 37)
        trace.pointee.childBodies += 1
        return Text<RootDomain>(BoundedText(Int32(value)))
    }
}


// This step isolates the scoped join. P04's record bank replaces this test-only
// workspace/sink in record tests; these counters do not prove exact identity.
private struct Workspace: SemanticExpansionWorkspace {
    typealias Identity = UInt64
    let maximumPathComponents: UInt16 = 16
    let maximumIdentities: UInt16 = 64
    var isExpanding = false
    var path: UInt64 = 0
    mutating func beginExpansion() -> Bool { guard !isExpanding else { return false }; isExpanding = true; return true }
    mutating func enter(_ component: UInt64, _ identity: inout UInt64?) -> SemanticExpansionError? {
        if path > UInt64.max >> 4 { return .capacityExhausted }
        path = (path << 4) | component; identity = path; return nil
    }
    mutating func enterRoot<D: View>(_ type: D.Type, identity: inout UInt64?) -> SemanticExpansionError? { enter(1, &identity) }
    mutating func enterCustomBody<D: View>(_ type: D.Type, identity: inout UInt64?) -> SemanticExpansionError? { enter(2, &identity) }
    mutating func enterFixedChild(_ index: UInt8, identity: inout UInt64?) -> SemanticExpansionError? { enter(3 + UInt64(index), &identity) }
    mutating func enterConditionalBranch(_ index: UInt8, identity: inout UInt64?) -> SemanticExpansionError? { enter(8 + UInt64(index), &identity) }
    mutating func enterOptionalPresence(identity: inout UInt64?) -> SemanticExpansionError? { enter(10, &identity) }
    mutating func enterDeclarationRole<D>(_ type: D.Type, identity: inout UInt64?) -> SemanticExpansionError? { enter(11, &identity) }
    mutating func leavePathComponent() { path >>= 4 }
    mutating func completeExpansion() {}
    mutating func discardExpansion() { path = 0 }
    mutating func resetExpansion() { path = 0; isExpanding = false }
}
private struct Sink: SemanticExpansionSink {
    typealias Identity = UInt64
    let maximumStructuralOccurrences: UInt16 = 64
    let maximumBodyEvaluations: UInt16 = 16
    let maximumSemanticOccurrences: UInt16 = 16
    let maximumModifierApplications: UInt16 = 16
    let maximumActionOccurrences: UInt16 = 16
    var bodies: UInt16 = 0
    var primitives: UInt16 = 0
    var discarded: UInt16 = 0
    var published: UInt16 = 0
    mutating func beginExpansion() -> Bool { bodies = 0; primitives = 0; return true }
    mutating func stageStructuralOccurrence(identity: borrowing UInt64) -> Bool { true }
    mutating func stageBodyEvaluation(identity: borrowing UInt64) -> Bool { bodies += 1; return true }
    mutating func stageSemanticOccurrence<P: _GiftUISemanticPrimitivePayload>(identity: borrowing UInt64, payload: borrowing P) -> Bool { primitives += 1; return true }
    mutating func stageModifierApplication<P: _GiftUISemanticModifierPayload>(identity: borrowing UInt64, payload: borrowing P, chainIndex: UInt16) -> Bool { true }
    mutating func stageActionOccurrence<A: GiftUIAction>(identity: borrowing UInt64, action: borrowing A) -> Bool { true }
    mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool { published += 1; return true }
    mutating func discardExpansion() { discarded += 1 }
    mutating func resetExpansion() {}
}
private struct AccessFailure: View {
    typealias Domain = RootDomain
    let trace: UnsafeMutablePointer<RootTrace>
    let fails: Bool
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<RootDomain>) throws(_GiftUIAccessFailure) -> some View<RootDomain> {
        trace.pointee.childBodies += 1
        if fails { throw .staleModel }
        return Text<RootDomain>("later")
    }
}
private func exercise(
    _ scope: borrowing ObservableModelScope<RootModel, RootSchema>,
    _ root: borrowing ObservableStateRootScope<RootModel, UInt64>,
    _ trace: UnsafeMutablePointer<RootTrace>, failure: Bool
) throws(ObservableStateError) -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ condition: Bool) { checks += 1; precondition(condition) }
    var ticket = try scope.materialize(RootModel.materialize(RootSeed(trace: trace, value: 31, fault: failure ? 1 : 0)))
    let key = ticket.key
    expect(root.offerCandidate(&ticket) == .success(.unchanged))
    let declaration = RecordParent(candidate: key, seed: RootSeed(trace: trace, value: 37))
    let limits = SemanticExpansionLimits(maximumDepth: 16, maximumSemanticNodes: 16, maximumBodyEvaluations: 16, maximumModifierApplications: 16, maximumActionOccurrences: 16)!
    try scope.withFrame { () throws(ObservableStateError) in
        try scope.withDiscovery { expect(root.beginCandidate() == .success(.candidateStarted)) }
        var workspace = Workspace(); var sink = Sink()
        let binding = ObservableSemanticBodyBinding(models: scope.borrowedScope(), root: root.borrowedRoot(), domain: RootDomain.self)
        let result = expandSemanticTreeWithStateBinding(declaration, limits: limits, workspace: &workspace, sink: &sink, stateBinding: consume binding)
        if failure { expect(result == .bindingFailure(.duplicateOwner)) }
        else {
            guard case .success(let summary) = result else { preconditionFailure() }
            expect(summary.bodyEvaluationCount == 2 && summary.semanticNodeCount == 1 && summary.modifierApplicationCount == 1)
        }
        expect(trace.pointee.parentBodies == (failure ? 0 : 1))
        expect(trace.pointee.childBodies == (failure ? 0 : 1))
        expect(sink.bodies == (failure ? 0 : 2))
        expect(sink.primitives == (failure ? 0 : 1))
        expect(sink.published == (failure ? 0 : 1))
        expect(sink.discarded == (failure ? 1 : 0))
        expect(!workspace.isExpanding)
        try scope.withDiscovery { expect(root.finishCandidate(failure ? .discard : .publish) == .success(failure ? .candidateDiscarded : .associationsCommitted)) }
        // A checked body failure must suppress every later sibling and discard
        // the candidate without becoming a semantic capacity/invariant failure.
        let children = ViewBuilder.buildBlock(AccessFailure(trace: trace, fails: true), AccessFailure(trace: trace, fails: false))
        let before = trace.pointee.childBodies
        let nextBinding = ObservableSemanticBodyBinding(models: scope.borrowedScope(), root: root.borrowedRoot(), domain: RootDomain.self)
        let failed = expandSemanticTreeWithStateBinding(children, limits: limits, workspace: &workspace, sink: &sink, stateBinding: consume nextBinding)
        expect(failed == .accessFailure(.staleModel))
        expect(trace.pointee.childBodies == before + 1)
        expect(sink.bodies == 1 && sink.primitives == 0)
        expect(sink.discarded == (failure ? 2 : 1))
    }
    return checks
}
@_cdecl("giftui_p04_scoped_traversal")
public func giftuiP04ScopedTraversal() -> UInt32 {
    do throws(ObservableStateError) {
        var namespace = ObservableModelOwnerNamespace()
        var checks: UInt32 = 0
        for failure in [false, true] {
            var root = StaticObservableRootAdapter<RootModel, UInt64>(identity: try namespace.issue(), schema: 7, needsCapture: false)!
            checks += try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
                trace.initialize(repeating: RootTrace()); defer { trace.deinitialize() }
                return try root.withLifetime { (scope, owner) throws(ObservableStateError) in
                    try exercise(scope, owner, trace.baseAddress!, failure: failure)
                }
            }
        }
        return checks
    } catch { return 0 }
}
