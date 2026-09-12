import GiftUI
import GiftUIExecution
import GiftUILayout

package struct InteractionState<CandidateRecords, CommittedRecords, HitRegions>:
    InteractionCandidateBuilder
where
    CandidateRecords: InteractionCandidateRecordStorage,
    CommittedRecords: InteractionCommittedRecordStorage,
    HitRegions: InteractionHitRegionStorage,
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
    private var committedRecords: CommittedRecords
    private var committedHitRegions: HitRegions
    private var limits: InteractionLimits?
    private var phase: Phase = .idle
    private var candidateError: InteractionError?
    private var committedPresentationRevision: PresentationRevision?

    package init(
        candidateRecords: consuming CandidateRecords,
        candidateHitRegions: consuming HitRegions,
        committedRecords: consuming CommittedRecords,
        committedHitRegions: consuming HitRegions
    ) {
        self.candidateRecords = candidateRecords
        self.candidateHitRegions = candidateHitRegions
        self.committedRecords = committedRecords
        self.committedHitRegions = committedHitRegions
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
        self.limits = limits
        candidateError = nil
        phase = .staging
        return nil
    }

    package mutating func append(
        identity: Identity,
        isEnabled: Bool,
        bounds: Rect,
        clip: Rect,
        paintOrder: UInt16,
        action: BoundedApplicationAction,
        targetGeneration: ObservableTargetGeneration
    ) -> InteractionCandidateAppendResult {
        guard phase == .staging, let limits else {
            return .failure(.invalidPhase)
        }
        if let candidateError {
            return .failure(candidateError)
        }
        guard !containsCandidate(identity: identity) else {
            return failCandidate(.invalidIdentity)
        }
        guard paintOrder == candidateRecords.count else {
            return failCandidate(.invalidGeometry)
        }
        guard candidateRecords.count < limits.maximumActions else {
            return failCandidate(.capacityExhausted)
        }
        guard let hitBounds = LayoutGeometry.intersection(bounds, clip) else {
            return failCandidate(.invalidGeometry)
        }
        let isEmpty = hitBounds.size.width == 0 || hitBounds.size.height == 0
        if !isEmpty, candidateHitRegions.count >= limits.maximumHitRegions {
            return failCandidate(.capacityExhausted)
        }

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
        guard candidateRecords.count <= committedRecords.capacity,
            candidateHitRegions.count <= committedHitRegions.capacity
        else {
            candidateError = .capacityExhausted
            return .capacityExhausted
        }
        phase = .readyForOffer
        return nil
    }

    package mutating func resolveCandidate(
        _ disposition: InteractionCandidateDisposition
    ) {}
}
