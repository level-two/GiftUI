import GiftUI
import GiftUIExecution
import GiftUILayout

package struct InteractionState<CandidateRecords, CommittedRecords, HitRegions>: ~Copyable,
    ~Escapable,
    InteractionCandidateBuilder, InteractionCommittedActionView,
    InteractionGestureResolver
where
    CandidateRecords: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
    CommittedRecords: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
    HitRegions: InteractionHitRegionStorage & ~Copyable & ~Escapable,
    CandidateRecords.Identity == CommittedRecords.Identity,
    CandidateRecords.Identity == HitRegions.Identity
{
    package typealias Identity = CandidateRecords.Identity

    private enum Phase: UInt8 {
        case idle
        case staging
        case readyForOffer
    }

    private var candidateRecords: CandidateRecords
    private var candidateHitRegions: HitRegions
    private var candidateCommittedRecords: CommittedRecords
    private var committedRecords: CommittedRecords
    private var committedHitRegions: HitRegions
    private var limits: InteractionLimits?
    private var phase: Phase = .idle
    private var candidateError: InteractionError?
    private var committedPresentationRevision: PresentationRevision?

    @_lifetime(
        copy candidateRecords, copy candidateHitRegions, copy candidateCommittedRecords,
        copy committedRecords, copy committedHitRegions)
    package init(
        candidateRecords: consuming CandidateRecords,
        candidateHitRegions: consuming HitRegions,
        candidateCommittedRecords: consuming CommittedRecords,
        committedRecords: consuming CommittedRecords,
        committedHitRegions: consuming HitRegions
    ) {
        self.candidateRecords = consume candidateRecords
        self.candidateHitRegions = consume candidateHitRegions
        self.candidateCommittedRecords = consume candidateCommittedRecords
        self.committedRecords = consume committedRecords
        self.committedHitRegions = consume committedHitRegions
    }

    package mutating func beginCandidate(
        limits: InteractionLimits
    ) -> InteractionError? {
        guard phase == .idle else { return .reentrancyViolation }
        guard limits.maximumActions <= candidateRecords.capacity,
            limits.maximumHitRegions <= candidateHitRegions.capacity,
            limits.maximumActions <= committedRecords.capacity,
            limits.maximumHitRegions <= committedHitRegions.capacity
        else { return .capacityExhausted }
        candidateRecords.reset()
        candidateHitRegions.reset()
        candidateCommittedRecords.reset()
        self.limits = limits
        candidateError = nil
        phase = .staging
        return nil
    }

    @inlinable
    @inline(__always)
    package mutating func append(
        identity: Identity,
        isEnabled: Bool,
        bounds: Rect,
        clip: Rect,
        paintOrder: UInt16,
        action: BoundedApplicationAction,
        targetGeneration: ObservableTargetGeneration
    ) -> InteractionCandidateAppendResult {
        if let error = appendFailure(
            identity: identity, bounds: bounds, clip: clip, paintOrder: paintOrder)
        {
            guard phase == .staging else { return .failure(error) }
            return failCandidate(error)
        }
        let hitBounds = LayoutGeometry.intersection(bounds, clip)!
        let isEmpty = hitBounds.size.width == 0 || hitBounds.size.height == 0

        let preservedGeneration = matchingCommittedGeneration(
            identity: identity,
            isEnabled: isEnabled,
            hitBounds: hitBounds,
            paintOrder: paintOrder,
            action: action,
            targetGeneration: targetGeneration
        )
        let record = InteractionCandidateRecord(
            identity: identity,
            generation: preservedGeneration,
            isEnabled: isEnabled,
            hitBounds: hitBounds,
            paintOrder: paintOrder,
            action: action,
            targetGeneration: targetGeneration
        )
        guard candidateRecords.append(record) else {
            return failCandidate(.invariantViolation)
        }
        if !isEmpty {
            let region = InteractionHitRegion(
                identity: identity,
                bounds: hitBounds,
                paintOrder: paintOrder
            )
            guard candidateHitRegions.append(region) else {
                return failCandidate(.invariantViolation)
            }
        }
        return preservedGeneration == nil ? .requiresGeneration : .preserved
    }

    /// Shared nonmutating preflight lets the owning key adapter include its pool
    /// failure in the existing deterministic precedence without staging a record.
    package borrowing func appendFailure(
        identity: Identity, bounds: Rect, clip: Rect, paintOrder: UInt16
    ) -> InteractionError? {
        guard phase == .staging, let limits else { return .invalidPhase }
        if let candidateError { return candidateError }
        var failures = InteractionVisibleFailures()
        if containsCandidate(identity: identity) { failures.insert(.invalidIdentity) }
        if paintOrder != candidateRecords.count { failures.insert(.invalidGeometry) }
        if candidateRecords.count >= limits.maximumActions { failures.insert(.capacityExhausted) }
        let hitCount = candidateHitRegions.count
        if let hitBounds = LayoutGeometry.intersection(bounds, clip) {
            if hitBounds.size.width != 0 && hitBounds.size.height != 0
                && hitCount >= limits.maximumHitRegions
            {
                failures.insert(.capacityExhausted)
            }
        } else {
            failures.insert(.invalidGeometry)
        }
        return InteractionFailurePrecedence.select(from: failures)
    }

    @inlinable
    @inline(__always)
    private borrowing func matchingCommittedGeneration(
        identity: Identity,
        isEnabled: Bool,
        hitBounds: Rect,
        paintOrder: UInt16,
        action: BoundedApplicationAction,
        targetGeneration: ObservableTargetGeneration
    ) -> ActionGeneration? {
        var index: UInt16 = 0
        while index < committedRecords.count {
            guard let record = committedRecords.record(at: index) else {
                return nil
            }
            if record.identity == identity {
                guard record.isEnabled == isEnabled,
                    record.hitBounds == hitBounds,
                    record.paintOrder == paintOrder,
                    record.action == action,
                    record.targetGeneration == targetGeneration
                else { return nil }
                return record.generation
            }
            index += 1
        }
        return nil
    }

    @inlinable
    @inline(__always)
    private borrowing func containsCandidate(identity: borrowing Identity) -> Bool {
        let soughtIdentity = copy identity
        var index: UInt16 = 0
        while index < candidateRecords.count {
            if candidateRecords.record(at: index)?.identity == soughtIdentity {
                return true
            }
            index += 1
        }
        return false
    }

    private mutating func failCandidate(
        _ error: InteractionError
    ) -> InteractionCandidateAppendResult {
        if candidateError == nil {
            candidateError = error
        }
        return .failure(error)
    }

    package mutating func assignGeneration(
        _ generation: ActionGeneration,
        to identity: Identity
    ) -> InteractionError? {
        guard phase == .staging else { return .invalidPhase }
        if let candidateError { return candidateError }
        var index: UInt16 = 0
        while index < candidateRecords.count {
            guard var record = candidateRecords.record(at: index) else {
                candidateError = .invariantViolation
                return .invariantViolation
            }
            if record.identity == identity {
                guard record.generation == nil else {
                    candidateError = .invariantViolation
                    return .invariantViolation
                }
                record.generation = generation
                guard candidateRecords.replace(at: index, with: record) else {
                    candidateError = .invariantViolation
                    return .invariantViolation
                }
                return nil
            }
            index += 1
        }
        candidateError = .invalidIdentity
        return .invalidIdentity
    }

    package mutating func finishCandidate() -> InteractionError? {
        guard phase == .staging else { return .invalidPhase }
        if let candidateError { return candidateError }
        var index: UInt16 = 0
        while index < candidateRecords.count {
            guard let record = candidateRecords.record(at: index) else {
                candidateError = .invariantViolation
                return .invariantViolation
            }
            guard record.generation != nil else {
                candidateError = .invalidIdentity
                return .invalidIdentity
            }
            index += 1
        }
        guard candidateRecords.count <= candidateCommittedRecords.capacity,
            candidateRecords.count <= committedRecords.capacity,
            candidateHitRegions.count <= committedHitRegions.capacity
        else {
            candidateError = .capacityExhausted
            return .capacityExhausted
        }
        candidateCommittedRecords.reset()
        index = 0
        while index < candidateRecords.count {
            guard let candidate = candidateRecords.record(at: index),
                let generation = candidate.generation
            else {
                candidateError = .invariantViolation
                return .invariantViolation
            }
            let committed = BoundActionRecord(
                identity: candidate.identity,
                generation: generation,
                isEnabled: candidate.isEnabled,
                hitBounds: candidate.hitBounds,
                paintOrder: candidate.paintOrder,
                action: candidate.action,
                targetGeneration: candidate.targetGeneration
            )
            guard candidateCommittedRecords.append(committed) else {
                candidateError = .invariantViolation
                return .invariantViolation
            }
            index += 1
        }
        phase = .readyForOffer
        return nil
    }

    package mutating func resolveCandidate(
        _ disposition: InteractionCandidateDisposition
    ) {
        switch disposition {
        case .commit(let revision) where phase == .readyForOffer:
            committedRecords.exchangeContents(with: &candidateCommittedRecords)
            committedHitRegions.exchangeContents(with: &candidateHitRegions)
            committedPresentationRevision = revision
        case .discard where phase == .staging || phase == .readyForOffer:
            break
        default:
            return
        }
        candidateRecords.reset()
        candidateHitRegions.reset()
        candidateCommittedRecords.reset()
        limits = nil
        candidateError = nil
        phase = .idle
    }

    /// Called by the containing owner only before use or after quiescent teardown.
    /// Storage allocations and configured physical capacities remain unchanged.
    package mutating func resetAllStorage() {
        candidateRecords.reset()
        candidateHitRegions.reset()
        candidateCommittedRecords.reset()
        committedRecords.reset()
        committedHitRegions.reset()
        limits = nil
        candidateError = nil
        committedPresentationRevision = nil
        phase = .idle
    }

    package var committedRevision: PresentationRevision? {
        committedPresentationRevision
    }

    package var candidateIsReadyForOffer: Bool {
        phase == .readyForOffer
    }

    package var committedRecordCount: UInt16 {
        committedRecords.count
    }

    package var committedHitRegionCount: UInt16 {
        committedHitRegions.count
    }

    package borrowing func committedRecord(at index: UInt16)
        -> BoundActionRecord<Identity>?
    {
        committedRecords.record(at: index)
    }

    package borrowing func committedHitRegion(at index: UInt16)
        -> InteractionHitRegion<Identity>?
    {
        committedHitRegions.region(at: index)
    }

    @inlinable
    @inline(__always)
    package borrowing func resolveDown(
        at point: Point
    ) -> PointerGestureOutcome<Identity> {
        guard let record = topmostRecord(at: point) else { return .ignored }
        guard record.isEnabled else { return .ignored }
        return .captured(
            CapturedAction(
                identity: record.identity,
                generation: record.generation
            )
        )
    }

    @inlinable
    @inline(__always)
    private borrowing func topmostRecord(
        at point: Point
    ) -> BoundActionRecord<Identity>? {
        var best: InteractionHitRegion<Identity>?
        var index: UInt16 = 0
        while index < committedHitRegions.count {
            guard let region = committedHitRegions.region(at: index) else {
                return nil
            }
            if region.bounds.contains(point),
                best == nil || region.paintOrder > best!.paintOrder
            {
                best = region
            }
            index += 1
        }
        guard let best else { return nil }
        return record(identity: best.identity)
    }

    private borrowing func record(
        identity: Identity
    ) -> BoundActionRecord<Identity>? {
        var index: UInt16 = 0
        while index < committedRecords.count {
            guard let record = committedRecords.record(at: index) else {
                return nil
            }
            if record.identity == identity { return record }
            index += 1
        }
        return nil
    }

    package borrowing func committedRecord(
        for identity: Identity
    ) -> BoundActionRecord<Identity>? {
        record(identity: identity)
    }

    @inlinable
    @inline(__always)
    package borrowing func resolveMove(
        _ captured: CapturedAction<Identity>,
        at point: Point
    ) -> PointerGestureOutcome<Identity> {
        guard capturedRecord(captured, contains: point) != nil else {
            return .cancelled
        }
        return .continued(captured)
    }

    private borrowing func capturedRecord(
        _ captured: CapturedAction<Identity>,
        contains point: Point
    ) -> BoundActionRecord<Identity>? {
        guard let record = record(identity: captured.identity),
            record.generation == captured.generation,
            record.isEnabled,
            record.hitBounds.contains(point)
        else { return nil }
        return record
    }

    @inlinable
    @inline(__always)
    package borrowing func resolveUp(
        _ captured: CapturedAction<Identity>,
        at point: Point
    ) -> PointerGestureOutcome<Identity> {
        guard capturedRecord(captured, contains: point) != nil else {
            return .cancelled
        }
        return .activationAdmitted(captured)
    }
}

// Conditional ownership preserves the existing owned bank aliases.
extension InteractionState: Copyable
where
    CandidateRecords: Copyable & ~Escapable, CommittedRecords: Copyable & ~Escapable,
    HitRegions: Copyable & ~Escapable
{}
extension InteractionState: Escapable
where
    CandidateRecords: Escapable & ~Copyable, CommittedRecords: Escapable & ~Copyable,
    HitRegions: Escapable & ~Copyable
{}

// Instrumentation is confined to owned banks; it exports fixed value facts only.
extension InteractionState
where
    CandidateRecords: InteractionOwnedBankMeasurementSource,
    CommittedRecords: InteractionOwnedBankMeasurementSource,
    HitRegions: InteractionOwnedBankMeasurementSource
{
    package borrowing func ownedStorageMeasurement() -> InteractionOwnedStorageMeasurement {
        .init(
            candidate: candidateRecords.ownedInteractionBankMeasurement,
            candidateHits: candidateHitRegions.ownedInteractionBankMeasurement,
            prepared: candidateCommittedRecords.ownedInteractionBankMeasurement,
            committed: committedRecords.ownedInteractionBankMeasurement,
            committedHits: committedHitRegions.ownedInteractionBankMeasurement)
    }
}
