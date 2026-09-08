import GiftUIExecution

struct ObservableStateTargetLookupSlot<StructuralIdentity>:
    ObservableStateTargetView, Equatable, Sendable
where StructuralIdentity: Equatable & Sendable {
    private struct Entry: Equatable, Sendable {
        let identity: StructuralIdentity
        let ordinal: UInt16
        let generation: ObservableTargetGeneration

        func matches(_ identity: StructuralIdentity, _ ordinal: UInt16) -> Bool {
            self.identity == identity && self.ordinal == ordinal
        }
    }

    private enum Candidate: Equatable, Sendable {
        case inactive
        case open
        case preserved(Entry)
        case candidateOnly(Entry)
    }

    private var live: Entry?
    private var candidate: Candidate = .inactive

    init() {
        live = nil
    }

    init(
        liveIdentity: StructuralIdentity,
        ordinal: UInt16,
        generation: ObservableTargetGeneration
    ) {
        live = Entry(
            identity: liveIdentity,
            ordinal: ordinal,
            generation: generation
        )
    }

    mutating func beginCandidate() -> ObservableStateError? {
        guard candidate == .inactive else { return .reentrancyViolation }
        candidate = .open
        return nil
    }

    mutating func recordSuccessfulEncounter(
        identity: StructuralIdentity,
        ordinal: UInt16,
        candidateOnlyGeneration: ObservableTargetGeneration?
    ) -> ObservableStateResult {
        guard candidate == .open else {
            return .failure(.invariantViolation)
        }

        if let live, live.matches(identity, ordinal) {
            guard candidateOnlyGeneration == nil else {
                return .failure(.invariantViolation)
            }
            candidate = .preserved(live)
            return .success(.preserved)
        }

        guard live == nil, let candidateOnlyGeneration else {
            return .failure(.invariantViolation)
        }
        candidate = .candidateOnly(
            Entry(
                identity: identity,
                ordinal: ordinal,
                generation: candidateOnlyGeneration
            )
        )
        return .success(.materialized)
    }

    mutating func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> ObservableStateError? {
        guard candidate != .inactive else { return .invariantViolation }
        defer { candidate = .inactive }

        guard disposition == .publish else { return nil }
        switch candidate {
        case .inactive:
            return .invariantViolation
        case .open:
            live = nil
        case .preserved(let entry), .candidateOnly(let entry):
            live = entry
        }
        return nil
    }

    borrowing func targetGeneration(
        structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        guard let live, live.matches(structuralIdentity, declarationOrdinal)
        else { return nil }
        return live.generation
    }

    borrowing func publishableTargetGeneration(
        structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        let entry: Entry
        switch candidate {
        case .preserved(let value), .candidateOnly(let value):
            entry = value
        case .inactive, .open:
            return nil
        }
        guard entry.matches(structuralIdentity, declarationOrdinal) else {
            return nil
        }
        return entry.generation
    }
}
