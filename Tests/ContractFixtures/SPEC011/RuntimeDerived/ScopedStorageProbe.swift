import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore

// Closed fixture-private access construction from actual typed mutable spans.
// These are minimal SO-03 lifetime inputs, not the SO-04 physical owner/session.
private struct SO03Candidate: ~Copyable, ~Escapable, InteractionCandidateRecordStorage {
    typealias Identity = SemanticCompleteIdentity
    private var slots: MutableSpan<InteractionCandidateRecord<Identity>?>
    private(set) var count: UInt16 = 0
    var capacity: UInt16 { UInt16(slots.count) }
    @_lifetime(copy slots)
    init(slots: consuming MutableSpan<InteractionCandidateRecord<Identity>?>) {
        self.slots = consume slots
    }
    mutating func reset() {
        for index in 0..<Int(count) { slots[index] = nil }
        count = 0
    }
    borrowing func record(at index: UInt16) -> InteractionCandidateRecord<Identity>? {
        guard index < count else { return nil }
        return slots[Int(index)]
    }
    mutating func append(_ record: consuming InteractionCandidateRecord<Identity>) -> Bool {
        guard count < capacity else { return false }
        slots[Int(count)] = consume record
        count += 1
        return true
    }
    mutating func replace(at index: UInt16, with record: consuming InteractionCandidateRecord<Identity>) -> Bool {
        guard index < count else { return false }
        slots[Int(index)] = consume record
        return true
    }
}
private struct SO03Committed: ~Copyable, ~Escapable, InteractionCommittedRecordStorage {
    typealias Identity = SemanticCompleteIdentity
    private var slots: MutableSpan<BoundActionRecord<Identity>?>
    private(set) var count: UInt16 = 0
    var capacity: UInt16 { UInt16(slots.count) }
    @_lifetime(copy slots)
    init(slots: consuming MutableSpan<BoundActionRecord<Identity>?>) {
        self.slots = consume slots
    }
    mutating func reset() {
        for index in 0..<Int(count) { slots[index] = nil }
        count = 0
    }
    borrowing func record(at index: UInt16) -> BoundActionRecord<Identity>? {
        guard index < count else { return nil }
        return slots[Int(index)]
    }
    mutating func append(_ record: consuming BoundActionRecord<Identity>) -> Bool {
        guard count < capacity else { return false }
        slots[Int(count)] = consume record
        count += 1
        return true
    }
    mutating func exchangeContents(with other: inout Self) {
        precondition(capacity == other.capacity)
        let priorSlots = consume slots
        let priorCount = count
        slots = consume other.slots
        count = other.count
        other.slots = consume priorSlots
        other.count = priorCount
    }
}
private struct SO03Hits: ~Copyable, ~Escapable, InteractionHitRegionStorage {
    typealias Identity = SemanticCompleteIdentity
    private var slots: MutableSpan<InteractionHitRegion<Identity>?>
    private(set) var count: UInt16 = 0
    var capacity: UInt16 { UInt16(slots.count) }
    @_lifetime(copy slots)
    init(slots: consuming MutableSpan<InteractionHitRegion<Identity>?>) {
        self.slots = consume slots
    }
    mutating func reset() {
        for index in 0..<Int(count) { slots[index] = nil }
        count = 0
    }
    borrowing func region(at index: UInt16) -> InteractionHitRegion<Identity>? {
        guard index < count else { return nil }
        return slots[Int(index)]
    }
    mutating func append(_ record: consuming InteractionHitRegion<Identity>) -> Bool {
        guard count < capacity else { return false }
        slots[Int(count)] = consume record
        count += 1
        return true
    }
    mutating func exchangeContents(with other: inout Self) {
        precondition(capacity == other.capacity)
        let priorSlots = consume slots
        let priorCount = count
        slots = consume other.slots
        count = other.count
        other.slots = consume priorSlots
        other.count = priorCount
    }
}
private typealias SO03Keys = InteractionOwnedKeyState<SO03Candidate, SO03Committed, SO03Hits>
private typealias SO03State = InteractionState<SO03Candidate, SO03Committed, SO03Hits>
private typealias SO03OwnedCandidate = StaticSixInteractionCandidateStorage<SemanticCompleteIdentity>
private typealias SO03OwnedCommitted = StaticSixInteractionCommittedStorage<SemanticCompleteIdentity>
private typealias SO03OwnedHits = StaticSixInteractionHitStorage<SemanticCompleteIdentity>
private typealias SO03OwnedKeys = InteractionOwnedKeyState<SO03OwnedCandidate, SO03OwnedCommitted, SO03OwnedHits>

@_lifetime(copy c, copy h0, copy r0, copy r1, copy h1)
private func so03GenericUnion<C, R, H>(c: consuming C, h0: consuming H,
    r0: consuming R, r1: consuming R, h1: consuming H) -> InteractionOwnedKeyState<C, R, H>?
where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
    R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
    H: InteractionHitRegionStorage & ~Copyable & ~Escapable,
    C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity,
    H.Identity == SemanticCompleteIdentity
{
    InteractionOwnedKeyState(state: InteractionState(candidateRecords: consume c,
        candidateHitRegions: consume h0, candidateCommittedRecords: consume r0,
        committedRecords: consume r1, committedHitRegions: consume h1),
        maximumComponentsPerKey: 34, maximumComponents: 204)
}

// Each escape cell differs from its positive twin only by removal of its named
// independent input from this declared output lifetime. Generic cells pass
// through the complete generic union above; direct cells invoke the actual init.
#if SO03_ESCAPE && SO03_INPUT_C
@_lifetime(copy h0, copy r0, copy r1, copy h1)
#elseif SO03_ESCAPE && SO03_INPUT_H0
@_lifetime(copy c, copy r0, copy r1, copy h1)
#elseif SO03_ESCAPE && SO03_INPUT_R0
@_lifetime(copy c, copy h0, copy r1, copy h1)
#elseif SO03_ESCAPE && SO03_INPUT_R1
@_lifetime(copy c, copy h0, copy r0, copy h1)
#elseif SO03_ESCAPE && SO03_INPUT_H1
@_lifetime(copy c, copy h0, copy r0, copy r1)
#else
@_lifetime(copy c, copy h0, copy r0, copy r1, copy h1)
#endif
private func so03Union(c: consuming SO03Candidate, h0: consuming SO03Hits,
    r0: consuming SO03Committed, r1: consuming SO03Committed, h1: consuming SO03Hits) -> SO03Keys?
{
    #if SO03_GENERIC
    return so03GenericUnion(c: consume c, h0: consume h0, r0: consume r0,
        r1: consume r1, h1: consume h1)
    #else
    return SO03Keys(state: InteractionState(candidateRecords: consume c,
        candidateHitRegions: consume h0, candidateCommittedRecords: consume r0,
        committedRecords: consume r1, committedHitRegions: consume h1),
        maximumComponentsPerKey: 34, maximumComponents: 204)
    #endif
}

#if SO03_COPY_NEGATIVE
private func so03ForbiddenCopy(_ state: borrowing SO03Keys) -> UInt16 {
    let duplicate = copy state
    return duplicate.committedRecordCount
}
#endif

private func so03OwnedReturn() -> SO03OwnedKeys? {
    let state = InteractionState(candidateRecords: SO03OwnedCandidate(capacity: 6)!,
        candidateHitRegions: SO03OwnedHits(capacity: 6)!,
        candidateCommittedRecords: SO03OwnedCommitted(capacity: 6)!,
        committedRecords: SO03OwnedCommitted(capacity: 6)!, committedHitRegions: SO03OwnedHits(capacity: 6)!)
    let optional = SO03OwnedKeys(state: copy state, maximumComponentsPerKey: 34, maximumComponents: 204)
    return copy optional
}
private func so03Move(c: consuming SO03Candidate, h0: consuming SO03Hits,
    r0: consuming SO03Committed, r1: consuming SO03Committed, h1: consuming SO03Hits) -> UInt16
{
    let state = InteractionState(candidateRecords: consume c, candidateHitRegions: consume h0,
        candidateCommittedRecords: consume r0, committedRecords: consume r1, committedHitRegions: consume h1)
    var moved = consume state
    moved.resetAllStorage()
    return moved.committedRecordCount
}
private func so03Failable(c: consuming SO03Candidate, h0: consuming SO03Hits,
    r0: consuming SO03Committed, r1: consuming SO03Committed, h1: consuming SO03Hits) -> Bool
{
    let state = InteractionState(candidateRecords: consume c, candidateHitRegions: consume h0,
        candidateCommittedRecords: consume r0, committedRecords: consume r1, committedHitRegions: consume h1)
    let optional = SO03Keys(state: consume state, maximumComponentsPerKey: 0, maximumComponents: 204)
    switch consume optional { case .none: return true; case .some: return false }
}

private func so03Key() -> SemanticCompleteIdentity {
    var result = SemanticCompleteIdentity()
    precondition(result.append(.init(kind: .root)))
    precondition(result.append(.init(kind: .declarationRole, role: 2)))
    return result
}
private let so03Rect = Rect(origin: .init(x: 0, y: 0), size: .init(width: 10, height: 10)!)!
private struct SO03Occurrences: RuntimeInteractionOccurrenceView {
    typealias Identity = SemanticCompleteIdentity
    var fail = false
    var interactionOccurrenceCount: UInt16 { 1 }
    borrowing func interactionOccurrence(at index: UInt16) -> RuntimeInteractionOccurrence<Identity>? {
        guard !fail && index == 0 else { return nil }
        return .init(identity: so03Key(), isEnabled: true, bounds: so03Rect, clip: so03Rect,
            paintOrder: 0, action: .init(code: 1))
    }
}
private struct SO03Observable: ObservableStateReconciler, ObservableStateTargetView {
    typealias StructuralIdentity = SemanticCompleteIdentity
    var discarded = 0
    mutating func beginCandidate() -> ObservableStateResult { .success(.candidateStarted) }
    mutating func encounter<Model: _GiftUIModelSchema>(structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16, state: inout State<Model>) -> ObservableStateResult { .success(.preserved) }
    mutating func finishCandidate(_ disposition: ObservableStateCandidateDisposition) -> ObservableStateResult {
        if disposition == .discard { discarded += 1 }
        return .success(disposition == .discard ? .candidateDiscarded : .associationsCommitted)
    }
    borrowing func targetGeneration(structuralIdentity: StructuralIdentity, declarationOrdinal: UInt16) -> ObservableTargetGeneration? { .init(rawValue: 1) }
    borrowing func publishableTargetGeneration(structuralIdentity: StructuralIdentity, declarationOrdinal: UInt16) -> ObservableTargetGeneration? { .init(rawValue: 1) }
}
private struct SO03Captures: RuntimeInteractionCaptureCancellation {
    var cancellations = 0
    mutating func cancelAllInteractionCaptures() { cancellations += 1 }
}

// This reference-contract value and owned target exercise the retained dispatcher
// independently of the unchanged, unresolved analyzer factory integration.
private struct SO03Model: _GiftUIObservableReference {
    mutating func _giftUIAttachChangeSink(_ sink: consuming _GiftUIObservableChangeSink) -> _GiftUIObservationAttachment? { nil }
    mutating func _giftUIDetachChangeSink(_ attachment: _GiftUIObservationAttachment) {}
}
private enum SO03Action: UInt16, GiftUIAction { case activate = 1 }
private struct SO03Handler: GiftUIActionHandler {
    typealias Action = SO03Action
    typealias Model = SO03Model
    var invoked: UnsafeMutablePointer<UInt32>
    mutating func handle(_ action: Action, model: borrowing Model) { invoked.pointee += 1 }
}
private struct SO03Target: ActionModelTargetAccess {
    typealias Model = SO03Model
    borrowing func currentGeneration() -> ObservableTargetGeneration? { .init(rawValue: 1) }
    mutating func withCurrentModel(matching generation: ObservableTargetGeneration,
        _ body: (borrowing Model) -> Void) -> Bool {
        guard generation.rawValue == 1 else { return false }
        body(SO03Model())
        return true
    }
}
#if SO03_DISPATCHER_SCOPED_NEGATIVE
private func so03ForbiddenRetainedDispatcher(_ records: borrowing SO03Keys,
    _ handler: SO03Handler, _ target: SO03Target) {
    _ = RuntimeInteractionDispatcher(records: records, handler: handler, targetAccess: target)
}
#endif
private func so03RetainedOwnedChecks() -> UInt32 {
    var records = so03OwnedReturn()!
    precondition(records.beginCandidate(limits: .init(maximumActions: 2, maximumHitRegions: 2)!) == nil)
    precondition(records.append(identity: so03Key(), isEnabled: true, bounds: so03Rect, clip: so03Rect,
        paintOrder: 0, action: .init(code: 1), targetGeneration: .init(rawValue: 1)) == .requiresGeneration)
    precondition(records.assignGeneration(.init(rawValue: 1), to: so03Key()) == nil)
    precondition(records.finishCandidate() == nil)
    records.resolveCandidate(.commit(.init(rawValue: 1)))
    var invoked: UInt32 = 0
    return withUnsafeMutablePointer(to: &invoked) { calls in
        var dispatcher = RuntimeInteractionDispatcher(records: copy records,
            handler: SO03Handler(invoked: calls), targetAccess: SO03Target())
        var duplicate = copy dispatcher
        let captured = CapturedAction(identity: so03Key(), generation: ActionGeneration(rawValue: 1))
        precondition(dispatcher.dispatch(captured) == .dispatched)
        precondition(duplicate.dispatch(captured) == .dispatched)
        precondition(calls.pointee == 2)
        return 7
    }
}

private func so03Operations(_ state: inout SO03Keys) -> UInt32 {
    var observable = SO03Observable(), generations = RuntimeActionGenerationAllocator<SemanticCompleteIdentity>()
    var captures = SO03Captures()
    let limits = InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!
    precondition(RuntimeInteractionCandidateTransaction.build(occurrences: SO03Occurrences(), limits: limits,
        rootIdentity: so03Key(), rootStateOrdinal: 0, interaction: &state, observable: &observable,
        generations: &generations, captures: &captures) == .ready)
    precondition(RuntimeInteractionCandidateTransaction.resolve(offer: .init(disposition: .accepted, failure: nil)!,
        presentationRevision: .init(rawValue: 1), interaction: &state, generations: &generations) == .committed(.init(rawValue: 1)))
    var capture = PointerActionCapture<SemanticCompleteIdentity>()
    let down = ExecutionGestureAdapter.down(at: .init(x: 1, y: 1), capture: &capture, resolver: state)
    guard case .captured = down else { preconditionFailure() }
    guard case .continued = ExecutionGestureAdapter.move(at: .init(x: 1, y: 1), capture: &capture, resolver: state) else { preconditionFailure() }
    guard case .activationAdmitted = ExecutionGestureAdapter.up(at: .init(x: 1, y: 1), capture: &capture, resolver: state) else { preconditionFailure() }
    precondition(RuntimeInteractionCandidateCoordinator.build(occurrences: SO03Occurrences(fail: true), limits: limits,
        rootIdentity: so03Key(), rootStateOrdinal: 0, interaction: &state, observable: &observable,
        generations: &generations) == .ownerFailure(.interaction(.invalidIdentity)))
    precondition(observable.discarded == 1)
    precondition(RuntimeInteractionCandidateTransaction.build(occurrences: SO03Occurrences(), limits: limits,
        rootIdentity: so03Key(), rootStateOrdinal: 0, interaction: &state, observable: &observable,
        generations: &generations, captures: &captures) == .ready)
    precondition(RuntimeInteractionCandidateTransaction.resolve(offer: .init(disposition: .retryableRefusal, failure: nil)!,
        presentationRevision: .init(rawValue: 2), interaction: &state, generations: &generations) == .discarded)
    precondition(state.committedRevision == .init(rawValue: 1))
    state.resetAllStorage()
    return 10 + so03RecordOperations(&state)
}

private func so03ScopedChecks(_ mode: UInt8) -> UInt32 {
    precondition(so03OwnedReturn() != nil)
    var c: InlineArray<6, InteractionCandidateRecord<SemanticCompleteIdentity>?> = .init(repeating: nil)
    var h0: InlineArray<6, InteractionHitRegion<SemanticCompleteIdentity>?> = .init(repeating: nil)
    var r0: InlineArray<6, BoundActionRecord<SemanticCompleteIdentity>?> = .init(repeating: nil)
    var r1: InlineArray<6, BoundActionRecord<SemanticCompleteIdentity>?> = .init(repeating: nil)
    var h1: InlineArray<6, InteractionHitRegion<SemanticCompleteIdentity>?> = .init(repeating: nil)
    if mode == 0 {
        precondition(so03Move(c: SO03Candidate(slots: c.mutableSpan), h0: SO03Hits(slots: h0.mutableSpan),
            r0: SO03Committed(slots: r0.mutableSpan), r1: SO03Committed(slots: r1.mutableSpan), h1: SO03Hits(slots: h1.mutableSpan)) == 0)
        return 1
    }
    if mode == 1 {
        precondition(so03Failable(c: SO03Candidate(slots: c.mutableSpan), h0: SO03Hits(slots: h0.mutableSpan),
            r0: SO03Committed(slots: r0.mutableSpan), r1: SO03Committed(slots: r1.mutableSpan), h1: SO03Hits(slots: h1.mutableSpan)))
        return 1
    }
    let optional = so03Union(c: SO03Candidate(slots: c.mutableSpan), h0: SO03Hits(slots: h0.mutableSpan),
        r0: SO03Committed(slots: r0.mutableSpan), r1: SO03Committed(slots: r1.mutableSpan), h1: SO03Hits(slots: h1.mutableSpan))
    var state = optional!
    let checks = so03Operations(&state)
    state.resetAllStorage()
    return checks + so03RetainedOwnedChecks()
}

public func giftuiSO03ScopedStorage() -> UInt32 {
    so03ScopedChecks(0) + so03ScopedChecks(1) + so03ScopedChecks(2)
}
