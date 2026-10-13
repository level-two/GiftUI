// Exact RFC-015 field sets, initializer signatures and conditional extensions; inert witnesses.
package struct InteractionState<C, R, H>: ~Copyable, ~Escapable,
    InteractionCandidateBuilder, InteractionCommittedActionView,
    InteractionGestureResolver
where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
      R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
      H: InteractionHitRegionStorage & ~Copyable & ~Escapable,
      C.Identity == R.Identity, C.Identity == H.Identity {
    package typealias Identity = C.Identity
    private var candidateRecords: C
    private var candidateHitRegions: H
    private var candidateCommittedRecords: R
    private var committedRecords: R
    private var committedHitRegions: H
    private enum Phase: UInt8 { case idle, staging, readyForOffer }
    private var limits: InteractionLimits?
    private var phase: Phase = .idle
    private var candidateError: InteractionError?
    private var committedPresentationRevision: PresentationRevision?
    @_lifetime(copy candidateRecords, copy candidateHitRegions,
               copy candidateCommittedRecords, copy committedRecords,
               copy committedHitRegions)
    package init(candidateRecords: consuming C, candidateHitRegions: consuming H,
                 candidateCommittedRecords: consuming R,
                 committedRecords: consuming R, committedHitRegions: consuming H) {
        self.candidateRecords = candidateRecords
        self.candidateHitRegions = candidateHitRegions
        self.candidateCommittedRecords = candidateCommittedRecords
        self.committedRecords = committedRecords
        self.committedHitRegions = committedHitRegions
    }
    // Every bank contributes an observable owned value to the external client result.
    @inline(never) package borrowing func probe() -> UInt64 {
        (candidateRecords.record(at: 0)?.value ?? 0)
            &+ (candidateHitRegions.region(at: 0)?.value ?? 0)
            &+ (candidateCommittedRecords.record(at: 0)?.value ?? 0)
            &+ (committedRecords.record(at: 0)?.value ?? 0)
            &+ (committedHitRegions.region(at: 0)?.value ?? 0)
    }
    package mutating func beginCandidate(limits: InteractionLimits) -> InteractionError? { nil }
    package mutating func append(identity: Identity, isEnabled: Bool, bounds: Rect, clip: Rect,
        paintOrder: UInt16, action: BoundedApplicationAction,
        targetGeneration: ObservableTargetGeneration) -> InteractionCandidateAppendResult { .init() }
    package mutating func assignGeneration(_ generation: ActionGeneration, to identity: Identity) -> InteractionError? { nil }
    package mutating func finishCandidate() -> InteractionError? { nil }
    package mutating func resolveCandidate(_ disposition: InteractionCandidateDisposition) {}
    package borrowing func resolveDown(at point: Point) -> PointerGestureOutcome<Identity> { .init() }
    package borrowing func resolveMove(_ captured: CapturedAction<Identity>, at point: Point) -> PointerGestureOutcome<Identity> { .init() }
    package borrowing func resolveUp(_ captured: CapturedAction<Identity>, at point: Point) -> PointerGestureOutcome<Identity> { .init() }
    package borrowing func committedRecord(for identity: Identity) -> BoundActionRecord<Identity>? { nil }
}

package struct InteractionOwnedKeyState<C, R, H>: ~Copyable, ~Escapable,
    InteractionCandidateBuilder, InteractionCommittedActionView,
    InteractionGestureResolver
where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
      R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
      H: InteractionHitRegionStorage & ~Copyable & ~Escapable,
      C.Identity == SemanticCompleteIdentity,
      R.Identity == SemanticCompleteIdentity,
      H.Identity == SemanticCompleteIdentity {
    package typealias Identity = SemanticCompleteIdentity
    private var state: InteractionState<C, R, H>
    private let maximumComponentsPerKey: UInt16
    private let maximumComponents: UInt32
    private var configuredComponentsPerKey: UInt16
    private var configuredComponents: UInt32
    private var candidateComponents: UInt32 = 0
    package private(set) var committedComponents: UInt32 = 0
    private var isStaging: Bool = false
    private var failure: InteractionError?
    @_lifetime(copy state)
    package init?(state: consuming InteractionState<C, R, H>,
                  maximumComponentsPerKey: UInt16, maximumComponents: UInt32) {
        guard maximumComponentsPerKey > 0, maximumComponents > 0 else { return nil }
        self.state = state
        self.maximumComponentsPerKey = maximumComponentsPerKey
        self.maximumComponents = maximumComponents
        self.configuredComponentsPerKey = maximumComponentsPerKey
        self.configuredComponents = maximumComponents
    }
    @inline(never) package borrowing func probe() -> UInt64 { state.probe() }
    package mutating func beginCandidate(limits: InteractionLimits) -> InteractionError? { nil }
    package mutating func append(identity: Identity, isEnabled: Bool, bounds: Rect, clip: Rect,
        paintOrder: UInt16, action: BoundedApplicationAction,
        targetGeneration: ObservableTargetGeneration) -> InteractionCandidateAppendResult { .init() }
    package mutating func assignGeneration(_ generation: ActionGeneration, to identity: Identity) -> InteractionError? { nil }
    package mutating func finishCandidate() -> InteractionError? { nil }
    package mutating func resolveCandidate(_ disposition: InteractionCandidateDisposition) {}
    package borrowing func resolveDown(at point: Point) -> PointerGestureOutcome<Identity> { .init() }
    package borrowing func resolveMove(_ captured: CapturedAction<Identity>, at point: Point) -> PointerGestureOutcome<Identity> { .init() }
    package borrowing func resolveUp(_ captured: CapturedAction<Identity>, at point: Point) -> PointerGestureOutcome<Identity> { .init() }
    package borrowing func committedRecord(for identity: Identity) -> BoundActionRecord<Identity>? { nil }
}


extension InteractionState: Copyable
where C: Copyable & ~Escapable, R: Copyable & ~Escapable,
      H: Copyable & ~Escapable {}
extension InteractionState: Escapable
where C: Escapable & ~Copyable, R: Escapable & ~Copyable,
      H: Escapable & ~Copyable {}
extension InteractionOwnedKeyState: Copyable
where C: Copyable & ~Escapable, R: Copyable & ~Escapable,
      H: Copyable & ~Escapable {}
extension InteractionOwnedKeyState: Escapable
where C: Escapable & ~Copyable, R: Escapable & ~Copyable,
      H: Escapable & ~Copyable {}
