import GiftUI
import GiftUIExecution
import GiftUISemanticCore

/// The configured component pools are independent of the two semantic banks.
/// The selected storage types own complete inline keys (including the endpoint
/// role); no reference or ordinal from a semantic bank is retained here.
@usableFromInline
package struct InteractionOwnedKeyState<Candidate, Committed, Hits>: ~Copyable, ~Escapable,
    InteractionCandidateBuilder, InteractionCommittedActionView, InteractionGestureResolver
where
    Candidate: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
    Committed: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
    Hits: InteractionHitRegionStorage & ~Copyable & ~Escapable,
    Candidate.Identity == SemanticCompleteIdentity,
    Committed.Identity == SemanticCompleteIdentity, Hits.Identity == SemanticCompleteIdentity
{
    @usableFromInline
    package typealias Identity = SemanticCompleteIdentity
    @usableFromInline
    internal var state: InteractionState<Candidate, Committed, Hits>
    @usableFromInline
    internal let maximumComponentsPerKey: UInt16
    @usableFromInline
    internal let maximumComponents: UInt32
    @usableFromInline
    internal var configuredComponentsPerKey: UInt16
    @usableFromInline
    internal var configuredComponents: UInt32
    @usableFromInline
    internal var candidateComponents: UInt32 = 0
    @usableFromInline
    package internal(set) var committedComponents: UInt32 = 0
    @usableFromInline
    internal var isStaging = false
    @usableFromInline
    internal var failure: InteractionError?
    @inlinable
    @_lifetime(copy state)
    package init?(
        state: consuming InteractionState<Candidate, Committed, Hits>,
        maximumComponentsPerKey: UInt16, maximumComponents: UInt32
    ) {
        guard maximumComponentsPerKey > 0,
            maximumComponentsPerKey <= SemanticCompleteIdentity.capacity, maximumComponents > 0
        else { return nil }
        self.state = consume state
        self.maximumComponentsPerKey = maximumComponentsPerKey
        self.maximumComponents = maximumComponents
        configuredComponentsPerKey = maximumComponentsPerKey
        configuredComponents = maximumComponents
    }

    package var identityCapacities: (perKey: UInt16, perBank: UInt32) {
        (maximumComponentsPerKey, maximumComponents)
    }

    package mutating func configureIdentityLimits(perKey: UInt16, perBank: UInt32) -> Bool {
        guard !isStaging, committedComponents == 0, perKey > 0, perKey <= maximumComponentsPerKey,
            perBank > 0, perBank <= maximumComponents
        else { return false }
        configuredComponentsPerKey = perKey
        configuredComponents = perBank
        return true
    }

    @inlinable
    package mutating func beginCandidate(limits: InteractionLimits) -> InteractionError? {
        if let error = state.beginCandidate(limits: limits) { return error }
        candidateComponents = 0
        failure = nil
        isStaging = true
        return nil
    }
    @inlinable
    package mutating func rejectCandidate(_ error: InteractionError)
        -> InteractionCandidateAppendResult
    {
        guard isStaging else { return .failure(.invalidPhase) }
        if failure == nil { failure = error }
        return .failure(failure!)
    }
    /// Validates while the caller holds the candidate-bank borrow and copies its
    /// complete key synchronously. A stale/wrong-bank reference never stages.
    @inline(__always)
    @inlinable
    package mutating func append(
        record: SemanticRecordReference, in view: borrowing SemanticRecordView,
        isEnabled: Bool, bounds: Rect, clip: Rect, paintOrder: UInt16,
        action: BoundedApplicationAction, targetGeneration: ObservableTargetGeneration
    ) -> InteractionCandidateAppendResult {
        guard isStaging else { return .failure(.invalidPhase) }
        if let failure { return .failure(failure) }
        guard view.isCandidate, view.record(record)?.kind == .action,
            let identity = view.completeIdentity(for: record)
        else { return rejectCandidate(.invalidIdentity) }
        return append(
            identity: identity, isEnabled: isEnabled, bounds: bounds, clip: clip,
            paintOrder: paintOrder, action: action, targetGeneration: targetGeneration)
    }
    @inlinable
    @inline(__always)
    package mutating func append(
        identity: Identity, isEnabled: Bool, bounds: Rect, clip: Rect, paintOrder: UInt16,
        action: BoundedApplicationAction, targetGeneration: ObservableTargetGeneration
    ) -> InteractionCandidateAppendResult {
        guard isStaging else { return .failure(.invalidPhase) }
        if let failure { return .failure(failure) }
        if let error = appendFailure(
            identity: identity, bounds: bounds, clip: clip, paintOrder: paintOrder)
        {
            return rejectCandidate(error)
        }
        let next = candidateComponents + UInt32(identity.count)
        let result = state.append(
            identity: identity, isEnabled: isEnabled, bounds: bounds, clip: clip,
            paintOrder: paintOrder, action: action, targetGeneration: targetGeneration)
        switch result {
        case .failure(let error): return rejectCandidate(error)
        case .preserved, .requiresGeneration:
            candidateComponents = next
            return result
        }
    }
    @inlinable
    package borrowing func appendFailure(
        identity: Identity, bounds: Rect, clip: Rect, paintOrder: UInt16
    ) -> InteractionError? {
        guard isStaging else { return .invalidPhase }
        if let failure { return failure }
        var failures = InteractionVisibleFailures()
        if let error = state.appendFailure(
            identity: identity, bounds: bounds, clip: clip, paintOrder: paintOrder)
        {
            failures.insert(error)
        }
        if identity.count < 2 || identity.component(at: 0)?.kind != .root
            || identity.component(at: identity.count - 1)?.kind != .declarationRole
        {
            failures.insert(.invalidIdentity)
        }
        let next = candidateComponents.addingReportingOverflow(UInt32(identity.count))
        let keyLimit = configuredComponentsPerKey
        let poolLimit = configuredComponents
        if identity.count > keyLimit || next.overflow
            || next.partialValue > poolLimit
        {
            failures.insert(.capacityExhausted)
        }
        return InteractionFailurePrecedence.select(from: failures)
    }

    @inlinable
    package mutating func assignGeneration(_ generation: ActionGeneration, to identity: Identity)
        -> InteractionError?
    {
        if let failure { return failure }
        if let error = state.assignGeneration(generation, to: identity) {
            failure = error
            return error
        }
        return nil
    }
    @inlinable
    package mutating func finishCandidate() -> InteractionError? {
        if let failure { return failure }
        if let error = state.finishCandidate() {
            failure = error
            return error
        }
        isStaging = false
        return nil
    }
    @inlinable
    package mutating func resolveCandidate(_ disposition: InteractionCandidateDisposition) {
        let ready = state.candidateIsReadyForOffer && failure == nil
        // A rejected append poisons the whole candidate even if a caller asks
        // to commit; no partial routing can become current.
        if case .commit = disposition, !ready { return }
        state.resolveCandidate(disposition)
        if case .commit = disposition { committedComponents = candidateComponents }
        candidateComponents = 0
        failure = nil
        isStaging = false
    }
    /// The containing runtime must establish quiescence before clearing routing.
    package mutating func resetAllStorage() {
        state.resetAllStorage()
        candidateComponents = 0
        committedComponents = 0
        isStaging = false
        failure = nil
    }

    package var committedRevision: PresentationRevision? { state.committedRevision }
    package var committedRecordCount: UInt16 { state.committedRecordCount }
    @usableFromInline
    package borrowing func committedRecord(for identity: Identity) -> BoundActionRecord<Identity>? {
        state.committedRecord(for: identity)
    }
    @inlinable
    @inline(__always)
    package borrowing func resolveDown(at point: Point) -> PointerGestureOutcome<Identity> {
        state.resolveDown(at: point)
    }
    @inlinable
    package borrowing func resolveMove(_ captured: CapturedAction<Identity>, at point: Point)
        -> PointerGestureOutcome<Identity>
    { state.resolveMove(captured, at: point) }
    @inlinable
    @inline(__always)
    package borrowing func resolveUp(_ captured: CapturedAction<Identity>, at point: Point)
        -> PointerGestureOutcome<Identity>
    { state.resolveUp(captured, at: point) }
}

// Conditional ownership preserves the existing owned bank aliases.
extension InteractionOwnedKeyState: Copyable
where
    Candidate: Copyable & ~Escapable, Committed: Copyable & ~Escapable, Hits: Copyable & ~Escapable
{}
extension InteractionOwnedKeyState: Escapable
where
    Candidate: Escapable & ~Copyable, Committed: Escapable & ~Copyable, Hits: Escapable & ~Copyable
{}

// Instrumentation is confined to owned banks; it exports fixed value facts only.
extension InteractionOwnedKeyState
where
    Candidate: InteractionOwnedBankMeasurementSource,
    Committed: InteractionOwnedBankMeasurementSource,
    Hits: InteractionOwnedBankMeasurementSource
{
    package borrowing func ownedStorageMeasurement() -> InteractionOwnedStorageMeasurement {
        state.ownedStorageMeasurement()
    }
}
