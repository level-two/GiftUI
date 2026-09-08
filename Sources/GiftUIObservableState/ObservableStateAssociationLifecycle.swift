struct ObservableStateAssociationLifecycle<StructuralIdentity, ModelDiscriminator>:
    Equatable, Sendable
where
    StructuralIdentity: Equatable & Sendable,
    ModelDiscriminator: Equatable & Sendable
{
    private enum Published: Equatable, Sendable {
        case vacant
        case live(StructuralIdentity, UInt16, ModelDiscriminator)
        case retired
        case shutdown
    }

    private enum Candidate: Equatable, Sendable {
        case inactive
        case preserved
        case materialized(StructuralIdentity, UInt16, ModelDiscriminator)
        case removalStaged
    }

    enum Cleanup: UInt8, Equatable, Sendable {
        case none = 0
        case detachCandidate = 1
        case detachLive = 2
    }

    private var published: Published = .vacant
    private var candidate: Candidate = .inactive

    var isLive: Bool {
        if case .live = published { return true }
        return false
    }

    var isShutdown: Bool {
        published == .shutdown
    }

    var admitsReport: Bool {
        isLive
    }

    mutating func prepareCandidate() -> ObservableStateError? {
        guard candidate == .inactive else { return .reentrancyViolation }
        switch published {
        case .vacant, .retired:
            return nil
        case .live:
            candidate = .removalStaged
            return nil
        case .shutdown:
            return .invalidPhaseSafetyNotProven
        }
    }

    mutating func encounter(
        structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16,
        modelDiscriminator: ModelDiscriminator,
        candidateModelAlreadyOwned: Bool
    ) -> ObservableStateResult {
        switch published {
        case .shutdown:
            return .failure(.invalidPhaseSafetyNotProven)
        case .live(let identity, let ordinal, let discriminator):
            guard identity == structuralIdentity,
                ordinal == declarationOrdinal,
                discriminator == modelDiscriminator
            else {
                return .failure(.incompatibleAssociation)
            }
            guard candidate == .removalStaged else {
                return .failure(.invariantViolation)
            }
            candidate = .preserved
            return .success(.preserved)
        case .vacant, .retired:
            guard candidate == .inactive else {
                return .failure(.invariantViolation)
            }
            guard !candidateModelAlreadyOwned else {
                return .failure(.duplicateOwner)
            }
            candidate = .materialized(
                structuralIdentity,
                declarationOrdinal,
                modelDiscriminator
            )
            return .success(.materialized)
        }
    }

    mutating func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> Cleanup {
        switch disposition {
        case .discard:
            let cleanup: Cleanup =
                if case .materialized = candidate {
                    .detachCandidate
                } else {
                    .none
                }
            candidate = .inactive
            return cleanup
        case .publish:
            switch candidate {
            case .inactive:
                return .none
            case .preserved:
                candidate = .inactive
                return .none
            case .materialized(let identity, let ordinal, let discriminator):
                published = .live(identity, ordinal, discriminator)
                candidate = .inactive
                return .none
            case .removalStaged:
                published = .retired
                candidate = .inactive
                return .detachLive
            }
        }
    }

    mutating func shutdown() -> Cleanup {
        guard published != .shutdown else { return .none }
        let cleanup: Cleanup
        if case .materialized = candidate {
            cleanup = .detachCandidate
        } else if case .live = published {
            cleanup = .detachLive
        } else {
            cleanup = .none
        }
        candidate = .inactive
        published = .shutdown
        return cleanup
    }
}
