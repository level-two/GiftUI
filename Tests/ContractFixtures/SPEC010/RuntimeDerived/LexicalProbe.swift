import GiftUI
import GiftUIObservableState
import GiftUIRuntimeStatic

@ObservableStateHost
private struct LexicalParent: View {
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
        return LexicalChild(seed: seed).disabled(false)
    }
}
@ObservableStateHost
private struct LexicalChild: View {
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

// Fixture traversal emits no semantic records. It drives the production root's
// scoped evaluator through the actual generated and modifier forwarding calls.
private struct ScopedWalker: ~Copyable, ~Escapable, _GiftUISemanticTraversalVisitor {
    typealias Domain = RootDomain
    let scope: ObservableModelScope<RootModel, RootSchema>
    let root: ObservableStateRootScope<RootModel, UInt8>
    let trace: UnsafeMutablePointer<RootTrace>
    var nextIdentity: UInt8 = 1
    var failure: ObservableStateError?
    @_lifetime(copy scope, copy root, borrow trace)
    init(scope: consuming ObservableModelScope<RootModel, RootSchema>, root: consuming ObservableStateRootScope<RootModel, UInt8>, trace: borrowing UnsafeMutablePointer<RootTrace>) {
        self.scope = consume scope; self.root = consume root; self.trace = copy trace
    }
    mutating func visitCustomView<D: View>(_ declaration: borrowing D,
        body: (borrowing _GiftUIFrameRead<RootDomain>) throws(_GiftUIAccessFailure) -> D.Body
    ) where D.Domain == RootDomain, D.Body.Domain == RootDomain {
        guard failure == nil else { return }
        do throws(_GiftUIAccessFailure) {
            let expanded = try scope.withRead(RootDomain.self, body)
            expanded._giftUITraverse(&self)
        } catch { failure = ObservableStateError(accessFailure: error) }
    }
    mutating func visitStatefulCustomView<D: View & _GiftUIObservableStateHost>(_ declaration: borrowing D,
        body: (borrowing D, borrowing _GiftUIFrameRead<RootDomain>) throws(_GiftUIAccessFailure) -> D.Body
    ) where D.Domain == RootDomain, D.Body.Domain == RootDomain {
        guard failure == nil else { return }
        let identity = nextIdentity; nextIdentity += 1
        do throws(ObservableStateError) {
            let expanded = try root.evaluate(declaration, identity: identity, body: body)
            expanded._giftUITraverse(&self)
        } catch { failure = error }
    }
    mutating func child<C: View>(_ value: borrowing C) where C.Domain == RootDomain {
        if failure == nil { value._giftUITraverse(&self) }
    }
    mutating func visitEmpty() {}
    mutating func visitFixed<A: View, B: View>(_ a: borrowing A, _ b: borrowing B) where A.Domain == RootDomain, B.Domain == RootDomain { child(a); child(b) }
    mutating func visitFixed<A: View, B: View, C: View>(_ a: borrowing A, _ b: borrowing B, _ c: borrowing C) where A.Domain == RootDomain, B.Domain == RootDomain, C.Domain == RootDomain { child(a); child(b); child(c) }
    mutating func visitFixed<A: View, B: View, C: View, D: View>(_ a: borrowing A, _ b: borrowing B, _ c: borrowing C, _ d: borrowing D) where A.Domain == RootDomain, B.Domain == RootDomain, C.Domain == RootDomain, D.Domain == RootDomain { child(a); child(b); child(c); child(d) }
    mutating func visitFixed<A: View, B: View, C: View, D: View, E: View>(_ a: borrowing A, _ b: borrowing B, _ c: borrowing C, _ d: borrowing D, _ e: borrowing E) where A.Domain == RootDomain, B.Domain == RootDomain, C.Domain == RootDomain, D.Domain == RootDomain, E.Domain == RootDomain { child(a); child(b); child(c); child(d); child(e) }
    mutating func visitConditionalFirst<A: View, B: View>(_ value: borrowing A, second: B.Type) where A.Domain == RootDomain, B.Domain == RootDomain { child(value) }
    mutating func visitConditionalSecond<A: View, B: View>(first: A.Type, _ value: borrowing B) where A.Domain == RootDomain, B.Domain == RootDomain { child(value) }
    mutating func visitOptionalAbsent<C: View>(_ value: C.Type) where C.Domain == RootDomain {}
    mutating func visitOptionalPresent<C: View>(_ value: borrowing C) where C.Domain == RootDomain { child(value) }
    mutating func visitPrimitive<P: _GiftUISemanticPrimitivePayload>(_ payload: borrowing P) { if failure == nil { trace.pointee.leaves += 1 } }
    mutating func visitPrimitive<C: View, P: _GiftUISemanticPrimitivePayload>(content: borrowing C, payload: borrowing P) where C.Domain == RootDomain { visitPrimitive(payload); child(content) }
    mutating func visitActionPrimitive<P: _GiftUISemanticActionPayload>(_ payload: borrowing P) {}
    mutating func visitActionPrimitive<C: View, P: _GiftUISemanticActionPayload>(content: borrowing C, payload: borrowing P) where C.Domain == RootDomain { child(content) }
    mutating func visitModifier<C: View, P: _GiftUISemanticModifierPayload>(content: borrowing C, payload: borrowing P) where C.Domain == RootDomain { child(content) }
}

package func exerciseLexical(_ scope: borrowing ObservableModelScope<RootModel, RootSchema>, _ root: borrowing ObservableStateRootScope<RootModel, UInt8>, _ trace: UnsafeMutablePointer<RootTrace>, failure: Bool) throws(ObservableStateError) -> UInt32 {
    var ticket = try scope.materialize(RootModel.materialize(RootSeed(trace: trace, value: 31, fault: failure ? 1 : 0)))
    let key = ticket.key
    precondition(root.offerCandidate(&ticket) == .success(.unchanged))
    do throws(ObservableStateError) { try scope.validateTicket(ticket); preconditionFailure() } catch { precondition(error == .staleModel) }
    let declaration = LexicalParent(candidate: key, seed: RootSeed(trace: trace, value: 37))
    try scope.withFrame { () throws(ObservableStateError) in
        try scope.withDiscovery { precondition(root.beginCandidate() == .success(.candidateStarted)) }
        var walker = ScopedWalker(scope: scope.borrowedScope(), root: root.borrowedRoot(), trace: trace)
        declaration._giftUITraverse(&walker)
        precondition(walker.failure == (failure ? .duplicateOwner : nil))
        precondition(trace.pointee.parentBodies == (failure ? 0 : 1))
        precondition(trace.pointee.childBodies == (failure ? 0 : 1))
        precondition(trace.pointee.leaves == (failure ? 0 : 1))
        try scope.withDiscovery {
            precondition(root.finishCandidate(failure ? .discard : .publish) == .success(failure ? .candidateDiscarded : .associationsCommitted))
        }
    }
    precondition(trace.pointee.attachments == (failure ? 1 : 2))
    precondition(trace.pointee.materializations == (failure ? 1 : 2))
    precondition(root.modelKey(identity: 1, ordinal: 0) == (failure ? nil : key))
    if failure { precondition(trace.pointee.destructions == 1) }
    else {
        precondition(root.modelKey(identity: 2, ordinal: 0) != nil)
        // Preserved candidate descriptors do not reattach or retain another claim.
        var repeated = try scope.retain(key)
        precondition(root.offerCandidate(&repeated) == .success(.unchanged))
        try scope.withFrame { () throws(ObservableStateError) in
            try scope.withDiscovery { precondition(root.beginCandidate() == .success(.candidateStarted)) }
            var walker = ScopedWalker(scope: scope.borrowedScope(), root: root.borrowedRoot(), trace: trace)
            declaration._giftUITraverse(&walker)
            precondition(walker.failure == nil)
            try scope.withDiscovery { precondition(root.finishCandidate(.publish) == .success(.unchanged)) }
        }
        precondition(trace.pointee.attachments == 2 && trace.pointee.materializations == 2)
    }
    return failure ? 12 : 17
}
package func staticLexicalChecks() throws(ObservableStateError) -> UInt32 {
    var namespace = ObservableModelOwnerNamespace()
    var checks: UInt32 = 0
    for failure in [false, true] {
        var root = StaticObservableRootAdapter<RootModel, UInt8>(identity: try namespace.issue(), schema: 7, needsCapture: false)!
        checks += try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
            trace.initialize(repeating: RootTrace()); defer { trace.deinitialize() }
            return try root.withLifetime { (scope, owner) throws(ObservableStateError) in try exerciseLexical(scope, owner, trace.baseAddress!, failure: failure) }
        }
    }
    return checks
}
@_cdecl("giftui_p03_lexical") public func giftuiP03Lexical() -> UInt32 {
    do { return try staticLexicalChecks() } catch { return 0 }
}
