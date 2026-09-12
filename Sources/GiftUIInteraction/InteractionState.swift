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

        let record = InteractionCandidateRecord(
            identity: identity,
            generation: nil,
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
        return .requiresGeneration
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
        candidateRecords.reset()
        candidateHitRegions.reset()
        limits = nil
        phase = .idle
        return .failure(error)
    }

    package mutating func assignGeneration(
        _ generation: ActionGeneration,
        to identity: Identity
    ) -> InteractionError? {
        .invalidPhase
    }

    package mutating func finishCandidate() -> InteractionError? {
        .invalidPhase
    }

    package mutating func resolveCandidate(
        _ disposition: InteractionCandidateDisposition
    ) {}
}
