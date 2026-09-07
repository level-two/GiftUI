package struct ExecutionPhaseMachine: Equatable, Sendable {
    private var cycle: RunCycleID?
    private var semanticRevision: SemanticRevision?
    private var candidateFrame: CandidateFrameID?
    private var phase: ExecutionPhase

    package init() {
        cycle = nil
        semanticRevision = nil
        candidateFrame = nil
        phase = .idle
    }

    package var context: ExecutionContext {
        ExecutionContext(
            cycle: cycle,
            semanticRevision: semanticRevision,
            candidateFrame: candidateFrame,
            phase: phase
        )
    }

    package mutating func beginCycle(
        reservingFrom allocator: inout RunCycleIDAllocator
    ) -> ExecutionError? {
        guard phase == .idle else { return .reentrancyViolation }
        guard let reservedCycle = allocator.reserve() else { return .identityExhausted }
        cycle = reservedCycle
        candidateFrame = nil
        phase = .admitting
        return nil
    }

    package mutating func transition(to next: ExecutionPhase) -> ExecutionError? {
        guard isLegalTransition(from: phase, to: next) else { return .invalidPhase }
        phase = next
        if next == .idle {
            cycle = nil
            candidateFrame = nil
        }
        return nil
    }

    package mutating func recordPublishedSemanticRevision(
        _ revision: SemanticRevision
    ) -> ExecutionError? {
        guard phase == .publishing else { return .invalidPhase }
        semanticRevision = revision
        return nil
    }

    package mutating func recordCandidateFrame(
        _ candidate: CandidateFrameID
    ) -> ExecutionError? {
        guard phase == .deriving || phase == .publishing else { return .invalidPhase }
        candidateFrame = candidate
        return nil
    }

    private func isLegalTransition(
        from current: ExecutionPhase,
        to next: ExecutionPhase
    ) -> Bool {
        switch (current, next) {
        case (.idle, .admitting),
            (.admitting, .mutating),
            (.admitting, .finalizing),
            (.mutating, .deriving),
            (.mutating, .finalizing),
            (.deriving, .publishing),
            (.deriving, .offering),
            (.deriving, .finalizing),
            (.publishing, .offering),
            (.publishing, .finalizing),
            (.offering, .finalizing),
            (.finalizing, .idle):
            true
        default:
            false
        }
    }
}
