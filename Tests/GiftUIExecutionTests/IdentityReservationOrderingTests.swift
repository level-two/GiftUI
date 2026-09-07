import GiftUI
import Testing

@testable import GiftUIExecution

private enum ReservationEvent: Equatable {
    case reservedCycle(RunCycleID)
    case reservedAction(ActionGeneration)
    case reservedSemantic(SemanticRevision)
    case publishedSemantic(SemanticRevision)
    case reservedCandidate(CandidateFrameID)
    case reservedPresentation(PresentationRevision)
    case offered(CandidateFrameID, PresentationRevision)
    case committedPresentation(PresentationRevision)
    case abortedCandidate(CandidateFrameID)
    case retiredAction(ActionGeneration)
    case retiredCandidate(CandidateFrameID)
    case retiredPresentation(PresentationRevision)
    case identityExhausted(ExecutionPhase)
}

private struct ReservationFixture {
    var cycles = RunCycleIDAllocator()
    var semantics = SemanticRevisionAllocator()
    var candidates = CandidateFrameIDAllocator()
    var presentations = PresentationRevisionAllocator()
    var actions = ActionGenerationAllocator()
    var events: [ReservationEvent] = []

    mutating func reserveAcceptedCandidate() -> Bool {
        guard let cycle = cycles.reserve() else {
            events.append(.identityExhausted(.idle))
            return false
        }
        events.append(.reservedCycle(cycle))

        guard let action = actions.reserve() else {
            events.append(.identityExhausted(.deriving))
            return false
        }
        events.append(.reservedAction(action))

        guard let semantic = semantics.reserve() else {
            events.append(.retiredAction(action))
            events.append(.identityExhausted(.deriving))
            return false
        }
        events.append(.reservedSemantic(semantic))
        events.append(.publishedSemantic(semantic))

        guard let candidate = candidates.reserve() else {
            events.append(.identityExhausted(.publishing))
            return false
        }
        events.append(.reservedCandidate(candidate))

        guard let presentation = presentations.reserve() else {
            events.append(.abortedCandidate(candidate))
            events.append(.retiredCandidate(candidate))
            events.append(.identityExhausted(.publishing))
            return false
        }
        events.append(.reservedPresentation(presentation))
        events.append(.offered(candidate, presentation))
        events.append(.committedPresentation(presentation))
        return true
    }

    mutating func reserveAbortedCandidate() -> Bool {
        guard let cycle = cycles.reserve(),
            let action = actions.reserve(),
            let semantic = semantics.reserve(),
            let candidate = candidates.reserve(),
            let presentation = presentations.reserve()
        else { return false }

        events.append(.reservedCycle(cycle))
        events.append(.reservedAction(action))
        events.append(.reservedSemantic(semantic))
        events.append(.publishedSemantic(semantic))
        events.append(.reservedCandidate(candidate))
        events.append(.reservedPresentation(presentation))
        events.append(.offered(candidate, presentation))
        events.append(.abortedCandidate(candidate))
        events.append(.retiredAction(action))
        events.append(.retiredCandidate(candidate))
        events.append(.retiredPresentation(presentation))
        return true
    }
}

@Test
func acceptedCandidateUsesTheExactReservationAndCommitOrder() {
    var fixture = ReservationFixture()

    let accepted = fixture.reserveAcceptedCandidate()
    #expect(accepted)
    #expect(
        fixture.events == [
            .reservedCycle(RunCycleID(rawValue: 0)),
            .reservedAction(ActionGeneration(rawValue: 0)),
            .reservedSemantic(SemanticRevision(rawValue: 0)),
            .publishedSemantic(SemanticRevision(rawValue: 0)),
            .reservedCandidate(CandidateFrameID(rawValue: 0)),
            .reservedPresentation(PresentationRevision(rawValue: 0)),
            .offered(CandidateFrameID(rawValue: 0), PresentationRevision(rawValue: 0)),
            .committedPresentation(PresentationRevision(rawValue: 0)),
        ]
    )
}

@Test
func abortedCandidatePermanentlyRetiresEveryCycleLocalReservation() {
    var fixture = ReservationFixture()

    let aborted = fixture.reserveAbortedCandidate()
    #expect(aborted)
    #expect(
        fixture.events.suffix(4) == [
            .abortedCandidate(CandidateFrameID(rawValue: 0)),
            .retiredAction(ActionGeneration(rawValue: 0)),
            .retiredCandidate(CandidateFrameID(rawValue: 0)),
            .retiredPresentation(PresentationRevision(rawValue: 0)),
        ])

    fixture.events.removeAll(keepingCapacity: true)
    let accepted = fixture.reserveAcceptedCandidate()
    #expect(accepted)
    #expect(fixture.events.contains(.reservedCycle(RunCycleID(rawValue: 1))))
    #expect(fixture.events.contains(.reservedAction(ActionGeneration(rawValue: 1))))
    #expect(fixture.events.contains(.reservedSemantic(SemanticRevision(rawValue: 1))))
    #expect(fixture.events.contains(.reservedCandidate(CandidateFrameID(rawValue: 1))))
    #expect(fixture.events.contains(.reservedPresentation(PresentationRevision(rawValue: 1))))
}

@Test
func prePublicationExhaustionPublishesNoSemanticRevision() {
    var cycleExhausted = ReservationFixture(
        cycles: RunCycleIDAllocator(nextRawValue: nil)
    )
    let cycleResult = cycleExhausted.reserveAcceptedCandidate()
    #expect(!cycleResult)
    #expect(cycleExhausted.events == [.identityExhausted(.idle)])

    var actionExhausted = ReservationFixture(
        actions: ActionGenerationAllocator(nextRawValue: nil)
    )
    let actionResult = actionExhausted.reserveAcceptedCandidate()
    #expect(!actionResult)
    #expect(
        actionExhausted.events == [
            .reservedCycle(RunCycleID(rawValue: 0)),
            .identityExhausted(.deriving),
        ])

    var semanticExhausted = ReservationFixture(
        semantics: SemanticRevisionAllocator(nextRawValue: nil)
    )
    let semanticResult = semanticExhausted.reserveAcceptedCandidate()
    #expect(!semanticResult)
    #expect(
        semanticExhausted.events == [
            .reservedCycle(RunCycleID(rawValue: 0)),
            .reservedAction(ActionGeneration(rawValue: 0)),
            .retiredAction(ActionGeneration(rawValue: 0)),
            .identityExhausted(.deriving),
        ])
}

@Test
func postPublicationExhaustionPreservesPublicationAndAbortsOnlyAllocatedCandidate() {
    var candidateExhausted = ReservationFixture(
        candidates: CandidateFrameIDAllocator(nextRawValue: nil)
    )
    let candidateResult = candidateExhausted.reserveAcceptedCandidate()
    #expect(!candidateResult)
    #expect(
        candidateExhausted.events.suffix(2) == [
            .publishedSemantic(SemanticRevision(rawValue: 0)),
            .identityExhausted(.publishing),
        ])
    #expect(!candidateExhausted.events.contains(.reservedCandidate(CandidateFrameID(rawValue: 0))))

    var presentationExhausted = ReservationFixture(
        presentations: PresentationRevisionAllocator(nextRawValue: nil)
    )
    let presentationResult = presentationExhausted.reserveAcceptedCandidate()
    #expect(!presentationResult)
    #expect(
        presentationExhausted.events.suffix(4) == [
            .reservedCandidate(CandidateFrameID(rawValue: 0)),
            .abortedCandidate(CandidateFrameID(rawValue: 0)),
            .retiredCandidate(CandidateFrameID(rawValue: 0)),
            .identityExhausted(.publishing),
        ])
    #expect(
        presentationExhausted.events.contains(.publishedSemantic(SemanticRevision(rawValue: 0))))
    #expect(
        !presentationExhausted.events.contains(
            .offered(CandidateFrameID(rawValue: 0), PresentationRevision(rawValue: 0))))
}
