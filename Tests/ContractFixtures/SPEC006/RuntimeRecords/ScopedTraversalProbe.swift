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

#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif

private struct PerturbRoot: View {
    typealias Domain = RootDomain
    let alternate: Bool
    let trace: UnsafeMutablePointer<RootTrace>
    @ViewBuilder func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<RootDomain>) throws(_GiftUIAccessFailure) -> some View<RootDomain> {
        if alternate { Text<RootDomain>("A"); Text<RootDomain>("😀") }
        else { Text<RootDomain>("B") }
    }
}
private struct ModifierRoot: View {
    typealias Domain = RootDomain
    let amount: GeometryScalar
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<RootDomain>) throws(_GiftUIAccessFailure) -> some View<RootDomain> {
        Text<RootDomain>("x").padding(amount).disabled(false)
    }
}
private enum RecordAction: UInt16, GiftUIAction { case increment = 1 }
private struct ActionRoot: View {
    typealias Domain = RootDomain
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<RootDomain>) throws(_GiftUIAccessFailure) -> some View<RootDomain> {
        try Button(action: RecordAction.increment) { Text<RootDomain>("+") }
    }
}
private struct UnknownRoot: View {
    typealias Domain = RootDomain
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<RootDomain>) throws(_GiftUIAccessFailure) -> some View<RootDomain> { Text<RootDomain>("unknown") }
}
// A static inferred Body witness names the opaque padding type without a
// runtime metatype operation. This declaration is never expanded by the test.
private struct PaddingRoleWitness: View {
    typealias Domain = RootDomain
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<RootDomain>) throws(_GiftUIAccessFailure) -> some View<RootDomain> {
        Text<RootDomain>("type").padding(0)
    }
}
private enum RecordRoles: SemanticDeclarationRoles {
    static func role<D>(of type: D.Type) -> SemanticRecordingRole? {
        let role: UInt16
        if D.self == RecordParent.self { role = 1 }
        else if D.self == RecordParent.Body.self { role = 2 }
        else if D.self == RecordChild.self { role = 3 }
        else if D.self == Text<RootDomain>.self { role = 4 }
        else if D.self == PerturbRoot.self { role = 5 }
        else if D.self == PerturbRoot.Body.self { role = 6 }
        else if D.self == TupleView<Text<RootDomain>, Text<RootDomain>>.self { role = 7 }
        else if D.self == ModifierRoot.self { role = 8 }
        else if D.self == ModifierRoot.Body.self { role = 9 }
        else if D.self == PaddingRoleWitness.Body.self { role = 10 }
        else if D.self == ActionRoot.self { role = 11 }
        else if D.self == ActionRoot.Body.self { role = 12 }
        else if D.self == RecordAction.self { role = 13 }
        else { return nil }
        return .init(rawValue: role)
    }
    static func modifierDiscriminator<D>(of type: D.Type) -> UInt16 {
        if D.self == RecordParent.Body.self || D.self == ModifierRoot.Body.self { return 1 }
        if D.self == PaddingRoleWitness.Body.self { return 2 }
        return 0
    }
}
private struct SemanticBacking: ~Copyable {
    var records: InlineArray<252, SemanticRuntimeRecord> = .init(repeating: .init())
    var paths: InlineArray<756, SemanticPathEntry> = .init(repeating: .init())
    var payloads: InlineArray<196, SemanticStandardPayload?> = .init(repeating: nil)
    var scalars: InlineArray<448, UInt32> = .init(repeating: 0)
}
private let semanticLimits = SemanticExpansionLimits(maximumDepth: 34, maximumSemanticNodes: 48, maximumBodyEvaluations: 14, maximumModifierApplications: 50, maximumActionOccurrences: 6)!
private func recordLimits() -> SemanticRecordLimits {
    SemanticRecordLimits(records: 126, paths: 378, depth: 34, fanout: 5, payloads: 98, textScalars: 224,
                         payloadBytes: UInt32(98 * MemoryLayout<SemanticStandardPayload?>.stride + 224 * 4))!
}
private func derivedChecks(_ store: borrowing SemanticRecordStore<SemanticStandardPayload>,
    _ scope: borrowing ObservableModelScope<RootModel, RootSchema>,
    _ root: borrowing ObservableStateRootScope<RootModel, SemanticCompleteIdentity>,
    _ trace: UnsafeMutablePointer<RootTrace>
) throws(ObservableStateError) -> UInt32 {
    var checks: UInt32 = 0
    var peakRecords: UInt16 = 0; var peakPaths: UInt16 = 0; var peakPayloads: UInt16 = 0
    var peakScalars: UInt16 = 0; var peakDepth: UInt16 = 0; var peakBytes: UInt32 = 0
    func observe(_ view: borrowing SemanticRecordView<SemanticStandardPayload>) {
        peakRecords = max(peakRecords, view.recordCount); peakPaths = max(peakPaths, view.pathCount)
        peakPayloads = max(peakPayloads, view.payloadCount); peakScalars = max(peakScalars, view.scalarCount)
        peakBytes = max(peakBytes, view.payloadBytes)
        for index in 0..<view.pathCount { peakDepth = max(peakDepth, view.path(at: index)!.depth) }
    }
    func expect(_ value: Bool) { checks += 1; precondition(value) }
    var ticket = try scope.materialize(RootModel.materialize(RootSeed(trace: trace, value: 31)))
    let key = ticket.key
    expect(root.offerCandidate(&ticket) == .success(.unchanged))
    try scope.withFrame { () throws(ObservableStateError) in
        try scope.withDiscovery { expect(root.beginCandidate() == .success(.candidateStarted)) }
        let declaration = RecordParent(candidate: key, seed: RootSeed(trace: trace, value: 37))
        let binding = ObservableSemanticBodyBinding(models: scope.borrowedScope(), root: root.borrowedRoot(), domain: RootDomain.self)
        let result = store.expand(declaration, roles: RecordRoles.self, codec: SemanticStandardPayloadCodec<RecordRoles>.self,
                                  limits: semanticLimits, binding: consume binding)
        guard case .success(let summary) = result else { preconditionFailure() }
        expect(summary.bodyEvaluationCount == 2 && summary.semanticNodeCount == 1 && summary.modifierApplicationCount == 1)
        expect(trace.pointee.parentBodies == 1 && trace.pointee.childBodies == 1)
        try scope.withDiscovery { expect(root.finishCandidate(.publish) == .success(.associationsCommitted)) }
        do throws(SemanticExpansionError) {
            try store.withCandidateView { (view) throws(SemanticExpansionError) in
                observe(view)
                expect(view.recordCount == 4 && view.pathCount == 7 && view.payloadCount == 2 && view.scalarCount == 2)
                expect(view.record(view.reference(at: 0)!)!.firstChild == 1)
                expect(view.record(view.reference(at: 1)!)!.firstChild == 2)
                expect(view.record(view.reference(at: 2)!)!.firstChild == 3)
                expect(view.payload(at: 0) == .text && view.payload(at: 1) == .disabled(false))
                expect(view.scalar(at: 0) == 51 && view.scalar(at: 1) == 55)
                var bodyKey = view.completeIdentity(for: view.reference(at: 0)!)!
                expect(bodyKey.append(.init(kind: .customBody)))
                expect(root.modelKey(identity: bodyKey, ordinal: 0) == key)
            }
            try store.publishCandidate()
            for alternate in [false, true, false] {
                let access = ObservableSemanticBodyBinding(models: scope.borrowedScope(), root: root.borrowedRoot(), domain: RootDomain.self)
                let result = store.expand(PerturbRoot(alternate: alternate, trace: trace), roles: RecordRoles.self,
                    codec: SemanticStandardPayloadCodec<RecordRoles>.self, limits: semanticLimits, binding: consume access)
                guard case .success(let summary) = result else { preconditionFailure() }
                expect(summary.bodyEvaluationCount == 1 && summary.semanticNodeCount == (alternate ? 2 : 1))
                try store.withCandidateView { (view) throws(SemanticExpansionError) in
                observe(view)
                    expect(view.recordCount == (alternate ? 5 : 3) && view.pathCount == (alternate ? 11 : 7))
                    expect(view.scalarCount == (alternate ? 2 : 1))
                    expect(view.scalar(at: 0) == (alternate ? 65 : 66))
                    if alternate { expect(view.scalar(at: 1) == 0x1F600) }
                }
                try store.publishCandidate()
            }
            var textIdentity: SemanticCompleteIdentity?
            for amount: GeometryScalar in [1, 9] {
                let access = ObservableSemanticBodyBinding(models: scope.borrowedScope(), root: root.borrowedRoot(), domain: RootDomain.self)
                let result = store.expand(ModifierRoot(amount: amount), roles: RecordRoles.self,
                    codec: SemanticStandardPayloadCodec<RecordRoles>.self, limits: semanticLimits, binding: consume access)
                guard case .success(let summary) = result else { preconditionFailure() }
                expect(summary.modifierApplicationCount == 2 && summary.semanticNodeCount == 1)
                try store.withCandidateView { (view) throws(SemanticExpansionError) in
                observe(view)
                    expect(view.recordCount == 4 && view.payloadCount == 3)
                    expect(view.record(view.reference(at: 2)!)!.modifierChainIndex == 0)
                    expect(view.record(view.reference(at: 1)!)!.modifierChainIndex == 1)
                    expect(view.payload(at: 0) == .text)
                    expect(view.payload(at: 1) == .padding(.init(edges: .all, length: amount)))
                    expect(view.payload(at: 2) == .disabled(false))
                    let current = view.completeIdentity(for: view.reference(at: 3)!)!
                    if let textIdentity { expect(textIdentity == current) } else { textIdentity = current }
                }
                try store.publishCandidate()
            }
            let actionAccess = ObservableSemanticBodyBinding(models: scope.borrowedScope(), root: root.borrowedRoot(), domain: RootDomain.self)
            let actionResult = store.expand(ActionRoot(), roles: RecordRoles.self, codec: SemanticStandardPayloadCodec<RecordRoles>.self, limits: semanticLimits, binding: consume actionAccess)
            guard case .success(let actionSummary) = actionResult else { preconditionFailure() }
            expect(actionSummary.semanticNodeCount == 2 && actionSummary.actionOccurrenceCount == 1)
            try store.withCandidateView { (view) throws(SemanticExpansionError) in
                observe(view)
                expect(view.recordCount == 3 && view.payloadCount == 2)
                expect(view.record(view.reference(at: 1)!)!.kind == .action)
                expect(view.record(view.reference(at: 1)!)!.firstChild == 2)
                expect(view.payload(at: 0) == .action(role: 13, code: 1) && view.payload(at: 1) == .text)
            }
            try store.publishCandidate()
            let invalid = ObservableSemanticBodyBinding(models: scope.borrowedScope(), root: root.borrowedRoot(), domain: RootDomain.self)
            let unknown = store.expand(UnknownRoot(), roles: RecordRoles.self, codec: SemanticStandardPayloadCodec<RecordRoles>.self, limits: semanticLimits, binding: consume invalid)
            expect(unknown == .semanticFailure(.invalidIdentity))
            try store.withPublishedView { (view) throws(SemanticExpansionError) in expect(view.payload(at: 0) == .action(role: 13, code: 1)) }
        } catch { preconditionFailure("record storage rejected admitted fixture") }
        // Reuse both semantic banks repeatedly, then revisit the State identity.
        // A new seed must not rematerialize the already-associated child.
        try scope.withDiscovery { expect(root.beginCandidate() == .success(.candidateStarted)) }
        let reused = ObservableSemanticBodyBinding(models: scope.borrowedScope(), root: root.borrowedRoot(), domain: RootDomain.self)
        let repeated = store.expand(RecordParent(candidate: key, seed: RootSeed(trace: trace, value: 99)), roles: RecordRoles.self,
            codec: SemanticStandardPayloadCodec<RecordRoles>.self, limits: semanticLimits, binding: consume reused)
        guard case .success = repeated else { preconditionFailure() }
        expect(trace.pointee.parentBodies == 2 && trace.pointee.childBodies == 2)
        expect(trace.pointee.materializations == 2 && trace.pointee.attachments == 2)
        try scope.withDiscovery { expect(root.finishCandidate(.publish) == .success(.unchanged)) }
        do throws(SemanticExpansionError) {
            try store.withCandidateView { (view) throws(SemanticExpansionError) in
                observe(view)
                expect(view.scalar(at: 0) == 51 && view.scalar(at: 1) == 55)
                var bodyKey = view.completeIdentity(for: view.reference(at: 0)!)!
                expect(bodyKey.append(.init(kind: .customBody)))
                expect(root.modelKey(identity: bodyKey, ordinal: 0) == key)
            }
            try store.publishCandidate()
        } catch { preconditionFailure() }
    }
    expect(peakRecords == 5 && peakPaths == 11 && peakPayloads == 3 && peakScalars == 2)
    expect(peakDepth <= 34 && peakBytes <= recordLimits().payloadBytes)
    #if !hasFeature(Embedded)
    print("record-high-water records=\(peakRecords) prefixes=\(peakPaths) payloads=\(peakPayloads) scalars=\(peakScalars) depth=\(peakDepth) payload-bytes=\(peakBytes)")
    #endif
    return checks
}
@_cdecl("giftui_p04_derived_records") public func giftuiP04DerivedRecords() -> UInt32 {
    do throws(ObservableStateError) {
        var modelNamespace = ObservableModelOwnerNamespace()
        var root = StaticObservableRootAdapter<RootModel, SemanticCompleteIdentity>(identity: try modelNamespace.issue(), schema: 7, needsCapture: false)!
        return try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
            trace.initialize(repeating: RootTrace()); defer { trace.deinitialize() }
            return try root.withLifetime { (scope, owner) throws(ObservableStateError) in
                do throws(SemanticExpansionError) {
                    var namespace = SemanticRecordOwnerNamespace()
                    var backing = SemanticBacking()
                    var storage = StaticSemanticRecordStorage(limits: recordLimits(), owner: try namespace.issue())
                    var records = backing.records.mutableSpan; var paths = backing.paths.mutableSpan
                    var payloads = backing.payloads.mutableSpan; var scalars = backing.scalars.mutableSpan
                    return try storage.withLifetime(records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) {
                        (store) throws(SemanticExpansionError) in
                        do throws(ObservableStateError) { return try derivedChecks(store, scope, owner, trace.baseAddress!) }
                        catch { preconditionFailure("owner failure") }
                    }
                } catch { preconditionFailure("storage activation failure") }
            }
        }
    } catch { return 0 }
}
#if !hasFeature(Embedded)
@_cdecl("giftui_p04_dynamic_records") public func giftuiP04DynamicRecords() -> UInt32 {
    do throws(ObservableStateError) {
        var modelNamespace = ObservableModelOwnerNamespace()
        var root = StaticObservableRootAdapter<RootModel, SemanticCompleteIdentity>(identity: try modelNamespace.issue(), schema: 7, needsCapture: false)!
        return try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
            trace.initialize(repeating: RootTrace()); defer { trace.deinitialize() }
            return try root.withLifetime { (scope, owner) throws(ObservableStateError) in
                do throws(SemanticExpansionError) {
                    var namespace = SemanticRecordOwnerNamespace()
                    let storage = DynamicSemanticRecordStorage<SemanticStandardPayload>(limits: recordLimits(), owner: try namespace.issue())
                    return try storage.withLifetime { (store) throws(SemanticExpansionError) in
                        do throws(ObservableStateError) { return try derivedChecks(store, scope, owner, trace.baseAddress!) }
                        catch { preconditionFailure("owner failure") }
                    }
                } catch { preconditionFailure("storage activation failure") }
            }
        }
    } catch { return 0 }
}
#endif
