import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
@testable import GiftUIRuntimeCore
import GiftUIRuntimeStatic
@testable import GiftUISemanticCore
#if GIFTUI_DYNAMIC_PROFILE
import GiftUIRuntimeDynamic
private typealias Candidate = DynamicInteractionCandidateStorage<SemanticCompleteIdentity>
private typealias Committed = DynamicInteractionCommittedStorage<SemanticCompleteIdentity>
private typealias Hits = DynamicInteractionHitStorage<SemanticCompleteIdentity>
#else
private typealias Candidate = StaticSixInteractionCandidateStorage<SemanticCompleteIdentity>
private typealias Committed = StaticSixInteractionCommittedStorage<SemanticCompleteIdentity>
private typealias Hits = StaticSixInteractionHitStorage<SemanticCompleteIdentity>
#endif
private typealias Keys = InteractionOwnedKeyState<Candidate, Committed, Hits>
private func storage(key: UInt16 = 34, pool: UInt32 = 204) -> Keys {
    #if GIFTUI_DYNAMIC_PROFILE
    let state = InteractionState(candidateRecords: Candidate(capacity: 6), candidateHitRegions: Hits(capacity: 6), candidateCommittedRecords: Committed(capacity: 6), committedRecords: Committed(capacity: 6), committedHitRegions: Hits(capacity: 6))
    #else
    let state = InteractionState(candidateRecords: Candidate(capacity: 6)!, candidateHitRegions: Hits(capacity: 6)!, candidateCommittedRecords: Committed(capacity: 6)!, committedRecords: Committed(capacity: 6)!, committedHitRegions: Hits(capacity: 6)!)
    #endif
    return Keys(state: state, maximumComponentsPerKey: key, maximumComponents: pool)!
}
private enum Action: UInt16, GiftUIAction { case set = 1; case reset = 2 }
private enum Roles: SemanticDeclarationRoles {
    static func role<V>(of type: V.Type) -> SemanticRecordingRole? { V.self == Action.self ? .init(rawValue: 9) : nil }
    static func modifierDiscriminator<V>(of type: V.Type) -> UInt16 { 0 }
}
private struct Backing: ~Copyable {
    var metadata: InlineArray<2, SemanticRecordBankMetadata> = .init(repeating: .init())
    var records: InlineArray<12, SemanticRuntimeRecord> = .init(repeating: .init())
    var paths: InlineArray<48, SemanticPathEntry> = .init(repeating: .init())
    var payloads: InlineArray<12, SemanticRecordPayload?> = .init(repeating: nil)
    var scalars: InlineArray<2, UInt32> = .init(repeating: 0)
    mutating func withStore<Result>(owner: SemanticRecordOwnerIdentity, _ body: (borrowing SemanticRecordStore) throws(SemanticExpansionError) -> Result) throws(SemanticExpansionError) -> Result {
        var m = metadata.mutableSpan; var r = records.mutableSpan; var p = paths.mutableSpan; var v = payloads.mutableSpan; var s = scalars.mutableSpan
        return try withSemanticRecordStore(metadata: &m, records: &r, paths: &p, payloads: &v, scalars: &s, limits: .init(records: 6, paths: 24, depth: 34, fanout: 5, payloads: 6, textScalars: 1, payloadBytes: 1024)!, owner: owner, body)
    }
}
private func emit(_ store: borrowing SemanticRecordStore, branch: UInt8, role: UInt16 = 2, modifier: UInt16 = 0, actionRole: UInt16 = 9, code: UInt16 = 1) throws(SemanticExpansionError) {
    let bank = store.expansionBank(try store.beginCandidate())!
    for component in [SemanticPathComponent(kind: .root), .init(kind: .declarationRole, role: 1), .init(kind: .conditionalBranch, ordinal: branch), .init(kind: .declarationRole, role: role, modifier: modifier)] {
        if let error = bank.enter(component, limits: store.limits) { throw error }
        if component.kind == .declarationRole, let error = bank.appendRecord(limits: store.limits) { throw error }
    }
    let empty: InlineArray<0, UInt32> = .init(repeating: 0)
    if let error = bank.store(.standard(.action(role: actionRole, code: code)), kind: .action, text: empty.span, limits: store.limits) { throw error }
    for _ in 0..<4 { bank.leave() }
    bank.metadata.pointee.phase = .candidate
}
private let rect = Rect(origin: .init(x: 0, y: 0), size: .init(width: 10, height: 10)!)!
private let limits = InteractionLimits(maximumActions: 6, maximumHitRegions: 6)!
private func expect(_ yes: Bool, _ count: inout UInt32) { count += 1; precondition(yes) }
private func append<C, R, H>(_ state: inout InteractionOwnedKeyState<C, R, H>, _ identity: SemanticCompleteIdentity, target: UInt32 = 1, action: UInt16 = 1, enabled: Bool = true, order: UInt16 = 0) -> InteractionCandidateAppendResult where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
    R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
    H: InteractionHitRegionStorage & ~Copyable & ~Escapable,
    C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    state.append(identity: identity, isEnabled: enabled, bounds: rect, clip: rect, paintOrder: order, action: .init(code: action), targetGeneration: .init(rawValue: target))
}
private func key(_ child: UInt8 = 0, role: UInt16 = 2, modifier: UInt16 = 0) -> SemanticCompleteIdentity {
    var key = SemanticCompleteIdentity()
    precondition(key.append(.init(kind: .root)))
    precondition(key.append(.init(kind: .fixedChild, ordinal: child)))
    precondition(key.append(.init(kind: .declarationRole, role: role, modifier: modifier)))
    return key
}
private func keyChecks() -> UInt32 {
    var checks: UInt32 = 0
    for (keyLimit, poolLimit) in [(UInt16(3), UInt32(6)), (UInt16(2), UInt32(6)), (UInt16(3), UInt32(5))] {
        var state = storage(key: keyLimit, pool: poolLimit)
        expect(state.beginCandidate(limits: limits) == nil, &checks)
        let first = append(&state, key())
        if keyLimit == 2 { expect(first == .failure(.capacityExhausted), &checks) }
        else {
            expect(first == .requiresGeneration, &checks)
            expect(state.assignGeneration(.init(rawValue: 1), to: key()) == nil, &checks)
            let second = append(&state, key(1), order: 1)
            expect(second == (poolLimit == 5 ? .failure(.capacityExhausted) : .requiresGeneration), &checks)
            if poolLimit == 6 { expect(state.assignGeneration(.init(rawValue: 2), to: key(1)) == nil, &checks) }
        }
        if keyLimit == 3 && poolLimit == 6 {
            expect(state.finishCandidate() == nil, &checks)
            state.resolveCandidate(.commit(.init(rawValue: 1)))
            expect(state.committedComponents == 6 && state.committedRecordCount == 2, &checks)
        } else {
            expect(state.finishCandidate() == .capacityExhausted, &checks)
            state.resolveCandidate(.commit(.init(rawValue: 1)))
            expect(state.committedRecordCount == 0, &checks)
            state.resolveCandidate(.discard)
        }
        expect(state.beginCandidate(limits: limits) == nil, &checks)
        state.resolveCandidate(.discard)
    }
    var state = storage()
    expect(state.beginCandidate(limits: limits) == nil, &checks)
    expect(append(&state, key()) == .requiresGeneration, &checks)
    expect(state.assignGeneration(.init(rawValue: 1), to: key()) == nil, &checks)
    expect(state.finishCandidate() == nil, &checks); state.resolveCandidate(.commit(.init(rawValue: 1)))
    let captured = CapturedAction(identity: key(), generation: ActionGeneration(rawValue: 1))
    expect(state.resolveUp(captured, at: .init(x: 1, y: 1)) == .activationAdmitted(captured), &checks)
    for variant in 0..<6 {
        expect(state.beginCandidate(limits: limits) == nil, &checks)
        let identity = variant == 0 ? key(1) : variant == 1 ? key(role: 3) : variant == 2 ? key(modifier: 1) : key()
        expect(append(&state, identity, target: variant == 3 ? 2 : 1, action: variant == 4 ? 2 : 1, enabled: variant != 5) == .requiresGeneration, &checks)
        expect(state.assignGeneration(.init(rawValue: UInt32(variant + 2)), to: identity) == nil, &checks)
        expect(state.finishCandidate() == nil, &checks)
        state.resolveCandidate(.discard)
        expect(state.resolveUp(captured, at: .init(x: 1, y: 1)) == .activationAdmitted(captured), &checks)
    }
    expect(state.beginCandidate(limits: limits) == nil, &checks)
    expect(append(&state, key(), action: 2) == .requiresGeneration, &checks)
    expect(state.assignGeneration(.init(rawValue: 9), to: key()) == nil, &checks)
    expect(state.finishCandidate() == nil, &checks); state.resolveCandidate(.commit(.init(rawValue: 2)))
    expect(state.resolveUp(captured, at: .init(x: 1, y: 1)) == .cancelled, &checks)
    // Pool first excess after a prior accepted presentation cannot replace it.
    var bounded = storage(key: 3, pool: 5)
    expect(bounded.beginCandidate(limits: limits) == nil, &checks)
    expect(append(&bounded, key()) == .requiresGeneration, &checks)
    expect(bounded.assignGeneration(.init(rawValue: 1), to: key()) == nil, &checks)
    expect(bounded.finishCandidate() == nil, &checks); bounded.resolveCandidate(.commit(.init(rawValue: 1)))
    expect(bounded.beginCandidate(limits: limits) == nil, &checks)
    expect(append(&bounded, key()) == .preserved, &checks)
    expect(append(&bounded, key(1), order: 1) == .failure(.capacityExhausted), &checks)
    expect(bounded.finishCandidate() == .capacityExhausted, &checks)
    bounded.resolveCandidate(.commit(.init(rawValue: 2)))
    expect(bounded.committedRevision == .init(rawValue: 1) && bounded.committedComponents == 3, &checks)
    expect(bounded.resolveUp(captured, at: .init(x: 1, y: 1)) == .activationAdmitted(captured), &checks)
    bounded.resolveCandidate(.discard)
    // Duplicate/geometry precedence over the same boundary's first-excess pool.
    var tiny = storage(key: 3, pool: 3); expect(tiny.beginCandidate(limits: limits) == nil, &checks)
    expect(append(&tiny, key()) == .requiresGeneration, &checks)
    expect(append(&tiny, key(), order: 7) == .failure(.invalidIdentity), &checks)
    tiny.resolveCandidate(.discard)
    return checks
}
private func bankChecks(_ store: borrowing SemanticRecordStore) throws(SemanticExpansionError) -> UInt32 {
    var checks: UInt32 = 0; var state = storage(); var generations = RuntimeActionGenerationAllocator<SemanticCompleteIdentity>()
    var captured: CapturedAction<SemanticCompleteIdentity>?
    var stale: SemanticRecordReference?
    for iteration in 0..<12 {
        try emit(store, branch: iteration == 0 || iteration == 11 ? 0 : 1)
        expect(state.beginCandidate(limits: limits) == nil, &checks)
        try store.withCandidateView { (view) throws(SemanticExpansionError) in
            let ref = view.reference(at: 1)!; let identity = view.completeIdentity(for: ref)!
            if let stale { expect(view.record(stale) == nil, &checks) }
            stale = ref
            let result = state.append(record: ref, in: view, isEnabled: true, bounds: rect, clip: rect, paintOrder: 0, action: .init(code: 1), targetGeneration: .init(rawValue: 1))
            expect(result == (iteration == 11 ? .preserved : .requiresGeneration), &checks)
            if result == .requiresGeneration { expect(state.assignGeneration(generations.generation(for: identity)!, to: identity) == nil, &checks) }
        }
        expect(state.finishCandidate() == nil, &checks)
        // Semantic publication always happens; every middle offer is refused.
        try store.publishCandidate()
        let disposition: FrameOfferDisposition = iteration == 0 || iteration == 11 ? .accepted : (iteration % 2 == 0 ? .retryableRefusal : .backpressured)
        let resolution = RuntimeInteractionCandidateTransaction.resolve(offer: FrameOfferResult(disposition: disposition, failure: nil)!, presentationRevision: .init(rawValue: UInt32(iteration + 1)), interaction: &state, generations: &generations)
        expect(resolution == (disposition == .accepted ? .committed(.init(rawValue: UInt32(iteration + 1))) : .discarded), &checks)
        if iteration == 0 { if case .captured(let value) = state.resolveDown(at: .init(x: 1, y: 1)) { captured = value } }
        expect(captured != nil, &checks)
        expect(state.resolveUp(captured!, at: .init(x: 1, y: 1)) == .activationAdmitted(captured!), &checks)
        expect(state.committedComponents == 4, &checks)
    }
    expect(generations.committedReservationCount == 1 && generations.retiredReservationCount == 10, &checks)
    return checks
}
private func hostChecks<C, R, H>(_ scope: borrowing ObservableModelScope<RootModel, RootSchema>, _ root: borrowing ObservableStateRootScope<RootModel, UInt8>, _ trace: UnsafeMutablePointer<RootTrace>, _ store: borrowing SemanticRecordStore, _ state: inout InteractionOwnedKeyState<C, R, H>) throws(ObservableStateError) -> UInt32 where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
    R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
    H: InteractionHitRegionStorage & ~Copyable & ~Escapable,
    C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    var checks: UInt32 = 0; var initial = State<RootSchema>(seed: RootSeed(trace: trace))
    do throws(SemanticExpansionError) { try emit(store, branch: 0) } catch { throw .invariantViolation }
    expect(state.beginCandidate(limits: limits) == nil, &checks)
    var identity: SemanticCompleteIdentity?
    try scope.withFrame { () throws(ObservableStateError) in
        try scope.withDiscovery {
            expect(root.beginCandidate() == .success(.candidateStarted), &checks)
            expect(root.encounter(identity: 1, ordinal: 0, state: &initial) == .success(.materialized), &checks)
        }
        do throws(SemanticExpansionError) {
            for invalid in 0..<2 {
                try store.discardCandidate()
                try emit(store, branch: 0, actionRole: invalid == 0 ? 8 : 9, code: 99)
                try store.withCandidateView { view in
                    let expected: InteractionError = invalid == 0 ? .incompatibleActionDomain : .invalidActionValue
                    if invalid == 0 {
                        expect(RuntimeRecordInteractionBridge.appendProjected(record: view.reference(at: 1)!, semantic: view, root: root, rootIdentity: 1, rootOrdinal: 0, actionType: Action.self, roles: Roles.self, isEnabled: true, bounds: rect, clip: rect, paintOrder: 0, interaction: &state, projection: { value in if case .standard(let standard) = value { return standard }; return nil }) == .failure(expected), &checks)
                    } else {
                        expect(RuntimeRecordInteractionBridge.append(record: view.reference(at: 1)!, semantic: view, root: root, rootIdentity: 1, rootOrdinal: 0, actionType: Action.self, roles: Roles.self, isEnabled: true, bounds: rect, clip: rect, paintOrder: 0, interaction: &state) == .failure(expected), &checks)
                    }
                    expect(state.finishCandidate() == expected, &checks)
                }
                state.resolveCandidate(.discard)
                expect(state.beginCandidate(limits: limits) == nil, &checks)
            }
            try store.discardCandidate(); try emit(store, branch: 0)
            try store.withCandidateView { view in
                let record = view.reference(at: 1)!; identity = view.completeIdentity(for: record)
                expect(RuntimeRecordInteractionBridge.append(record: record, semantic: view, root: root, rootIdentity: 1, rootOrdinal: 0, actionType: Action.self, roles: Roles.self, isEnabled: true, bounds: rect, clip: rect, paintOrder: 0, interaction: &state) == .requiresGeneration, &checks)
            }
        } catch { throw .invariantViolation }
        expect(state.assignGeneration(.init(rawValue: 1), to: identity!) == nil, &checks)
        expect(state.finishCandidate() == nil, &checks)
        try scope.withDiscovery { expect(root.finishCandidate(.publish) == .success(.associationsCommitted), &checks) }
    }
    do throws(SemanticExpansionError) { try store.publishCandidate() } catch { throw .invariantViolation }
    state.resolveCandidate(.commit(.init(rawValue: 1)))
    let captured = CapturedAction(identity: identity!, generation: ActionGeneration(rawValue: 1))
    let target = StaticObservableRootTargetAccess(root: root, identity: UInt8(1), ordinal: 0)
    var operations = 0
    expect(RuntimeRecordInteractionBridge.dispatch(captured, records: state, target: target, actionType: Action.self, operation: { action in operations += 1; return .set(action == .set ? 31 : 0) }) == .interaction(.dispatched), &checks)
    expect(operations == 1 && trace.pointee.reports == 1, &checks)
    try scope.withFrame {
        expect(RuntimeRecordInteractionBridge.dispatch(captured, records: state, target: target, actionType: Action.self, operation: { _ in operations += 1; return .set(99) }) == .observableFailure(.invalidPhaseContained), &checks)
    }
    expect(operations == 1 && trace.pointee.reports == 1, &checks)
    let a = root.modelKey(identity: 1, ordinal: 0)!
    var transfer = try scope.retain(a); var independent = try scope.retain(a)
    expect(root.replace(identity: 1, ordinal: 0, transferring: &transfer, seed: RootSeed(trace: trace, value: 9)) == .failure(.retainedModel), &checks)
    expect(RuntimeRecordInteractionBridge.dispatch(captured, records: state, target: target, actionType: Action.self, operation: { _ in operations += 1; return .set(32) }) == .interaction(.dispatched), &checks)
    try scope.release(&independent)
    expect(root.replace(identity: 1, ordinal: 0, transferring: &transfer, seed: RootSeed(trace: trace, value: 9)) == .success(.replaced), &checks)
    let before = operations
    expect(RuntimeRecordInteractionBridge.dispatch(captured, records: state, target: target, actionType: Action.self, operation: { _ in operations += 1; return .set(33) }) == .interaction(.cancelled), &checks)
    expect(operations == before, &checks)
    let b = root.modelKey(identity: 1, ordinal: 0)!
    var retainedB = try scope.retain(b)
    let oldTarget = target.currentGeneration()!
    // Rebind the same key to B and accept; its action generation must change.
    expect(state.beginCandidate(limits: limits) == nil, &checks)
    expect(append(&state, identity!, target: oldTarget.rawValue) == .requiresGeneration, &checks)
    expect(state.assignGeneration(.init(rawValue: 2), to: identity!) == nil, &checks)
    expect(state.finishCandidate() == nil, &checks); state.resolveCandidate(.commit(.init(rawValue: 2)))
    expect(state.resolveUp(captured, at: .init(x: 1, y: 1)) == .cancelled, &checks)
    let newCapture = CapturedAction(identity: identity!, generation: ActionGeneration(rawValue: 2))
    expect(RuntimeRecordInteractionBridge.dispatch(newCapture, records: state, target: target, actionType: Action.self, operation: { _ in operations += 1; return .set(34) }) == .interaction(.dispatched), &checks)
    let destructed = trace.pointee.destructions
    try scope.withFrame { () throws(ObservableStateError) in
        try scope.withDiscovery {
            expect(root.beginCandidate() == .success(.candidateStarted), &checks)
            expect(root.finishCandidate(.publish) == .success(.associationsCommitted), &checks)
        }
    }
    expect(trace.pointee.destructions == destructed && target.currentGeneration() == nil, &checks)
    expect(RuntimeRecordInteractionBridge.dispatch(newCapture, records: state, target: target, actionType: Action.self, operation: { _ in operations += 1; return .set(35) }) == .interaction(.cancelled), &checks)
    try scope.release(&retainedB)
    expect(trace.pointee.destructions == destructed + 1, &checks)
    // Missing current candidate target outranks a bad code or exhausted key pool.
    do throws(SemanticExpansionError) {
        try emit(store, branch: 1, code: 99)
        expect(state.beginCandidate(limits: limits) == nil, &checks)
        try store.withCandidateView { view in
            expect(RuntimeRecordInteractionBridge.append(record: view.reference(at: 1)!, semantic: view, root: root, rootIdentity: 1, rootOrdinal: 0, actionType: Action.self, roles: Roles.self, isEnabled: true, bounds: rect, clip: rect, paintOrder: 0, interaction: &state) == .failure(.missingModelTarget), &checks)
        }
        state.resolveCandidate(.discard); try store.discardCandidate()
    } catch { throw .invariantViolation }
    return checks
}
@_cdecl("giftui_p05_interaction") public func giftuiP05Interaction() -> UInt32 {
    var checks = keyChecks()
    do throws(SemanticExpansionError) {
        var namespace = SemanticRecordOwnerNamespace(); var backing = Backing()
        checks += try backing.withStore(owner: namespace.issue()) { (store) throws(SemanticExpansionError) in try bankChecks(store) }
        checks += try backing.withStore(owner: namespace.issue()) { (store) throws(SemanticExpansionError) in
            do throws(ObservableStateError) {
                var models = ObservableModelOwnerNamespace()
                var root = StaticObservableRootAdapter<RootModel, UInt8>(identity: try models.issue(), schema: 7, needsCapture: true)!
                return try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
                    trace.initialize(repeating: RootTrace()); defer { trace.deinitialize() }
                    return try root.withLifetime { (scope, root) throws(ObservableStateError) in var state = storage(); return try hostChecks(scope, root, trace.baseAddress!, store, &state) }
                }
            } catch { preconditionFailure() }
        }
    } catch { preconditionFailure() }
    return checks
}

// Reuse all existing typed model/root/semantic dispatch and replacement oracles
// with scoped banks; only the storage permission differs from the owned control.
func so03RecordOperations<C, R, H>(_ state: inout InteractionOwnedKeyState<C, R, H>) -> UInt32
where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
    R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
    H: InteractionHitRegionStorage & ~Copyable & ~Escapable,
    C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity
{
    var checks: UInt32 = 0
    var namespace = SemanticRecordOwnerNamespace()
    var backing = Backing()
    do throws(SemanticExpansionError) {
        checks += try backing.withStore(owner: namespace.issue()) { (store) throws(SemanticExpansionError) in
            do throws(ObservableStateError) {
                var owners = ObservableModelOwnerNamespace()
                var adapter = StaticObservableRootAdapter<RootModel, UInt8>(identity: try owners.issue(), schema: 7, needsCapture: true)!
                return try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
                    trace.initialize(repeating: RootTrace()); defer { trace.deinitialize() }
                    return try adapter.withLifetime { (scope, root) throws(ObservableStateError) in
                        try hostChecks(scope, root, trace.baseAddress!, store, &state)
                    }
                }
            } catch { preconditionFailure() }
        }
    } catch { preconditionFailure() }
    state.resetAllStorage()
    var canvas = Backing()
    do throws(SemanticExpansionError) {
        checks += try canvas.withStore(owner: namespace.issue()) { (store) throws(SemanticExpansionError) in
            let bank = store.expansionBank(try store.beginCandidate())!
            for component in [SemanticPathComponent(kind: .root), .init(kind: .declarationRole, role: 1), .init(kind: .declarationRole, role: 2)] {
                if let error = bank.enter(component, limits: store.limits) { throw error }
            }
            if let error = bank.appendRecord(limits: store.limits) { throw error }
            let empty: InlineArray<0, UInt32> = .init(repeating: 0)
            if let error = bank.store(.standard(.action(role: 9, code: 1)), kind: .action,
                text: empty.span, limits: store.limits) { throw error }
            for _ in 0..<3 { bank.leave() }
            bank.metadata.pointee.phase = .candidate
            do throws(ObservableStateError) {
                var owners = ObservableModelOwnerNamespace()
                var adapter = StaticObservableRootAdapter<RootModel, UInt8>(identity: try owners.issue(), schema: 7, needsCapture: true)!
                return try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
                    trace.initialize(repeating: RootTrace()); defer { trace.deinitialize() }
                    return try adapter.withLifetime { (scope, root) throws(ObservableStateError) in
                        var initial = State<RootSchema>(seed: RootSeed(trace: trace.baseAddress!))
                        return try scope.withFrame { () throws(ObservableStateError) in
                            try scope.withDiscovery {
                                precondition(root.beginCandidate() == .success(.candidateStarted))
                                precondition(root.encounter(identity: 1, ordinal: 0, state: &initial) == .success(.materialized))
                            }
                            precondition(state.beginCandidate(limits: limits) == nil)
                            do throws(SemanticExpansionError) {
                                try store.withCandidateView { view in
                                    let reference = view.reference(at: 0)!
                                    precondition(RuntimeRecordInteractionBridge.append(record: reference,
                                        semantic: view, root: root, rootIdentity: 1, rootOrdinal: 0,
                                        actionType: Action.self, roles: Roles.self, isEnabled: true,
                                        bounds: rect, clip: rect, paintOrder: 0, interaction: &state) == .requiresGeneration)
                                    precondition(state.assignGeneration(.init(rawValue: 1), to: view.completeIdentity(for: reference)!) == nil)
                                }
                            } catch { throw .invariantViolation }
                            precondition(state.finishCandidate() == nil)
                            state.resolveCandidate(.discard)
                            try scope.withDiscovery { precondition(root.finishCandidate(.publish) == .success(.associationsCommitted)) }
                            return 7
                        }
                    }
                }
            } catch { preconditionFailure() }
        }
    } catch { preconditionFailure() }
    state.resetAllStorage()
    return checks
}
