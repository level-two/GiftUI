import GiftUI
import Testing

@testable import GiftUIExecution

private func requireSendable<T: Sendable>(_: T.Type) {}

@Test
func executionOwnedAllocatorsReserveZeroThenExactSuccessors() {
    var cycles = RunCycleIDAllocator()
    var semantics = SemanticRevisionAllocator()
    var candidates = CandidateFrameIDAllocator()
    var presentations = PresentationRevisionAllocator()
    var actions = ActionGenerationAllocator()

    #expect(cycles.reserve() == RunCycleID(rawValue: 0))
    #expect(cycles.reserve() == RunCycleID(rawValue: 1))
    #expect(semantics.reserve() == SemanticRevision(rawValue: 0))
    #expect(semantics.reserve() == SemanticRevision(rawValue: 1))
    #expect(candidates.reserve() == CandidateFrameID(rawValue: 0))
    #expect(candidates.reserve() == CandidateFrameID(rawValue: 1))
    #expect(presentations.reserve() == PresentationRevision(rawValue: 0))
    #expect(presentations.reserve() == PresentationRevision(rawValue: 1))
    #expect(actions.reserve() == ActionGeneration(rawValue: 0))
    #expect(actions.reserve() == ActionGeneration(rawValue: 1))
}

@Test
func eachAllocatorPermanentlyExhaustsAfterReservingUInt32Max() {
    var cycles = RunCycleIDAllocator(nextRawValue: .max)
    var semantics = SemanticRevisionAllocator(nextRawValue: .max)
    var candidates = CandidateFrameIDAllocator(nextRawValue: .max)
    var presentations = PresentationRevisionAllocator(nextRawValue: .max)
    var actions = ActionGenerationAllocator(nextRawValue: .max)

    #expect(cycles.reserve() == RunCycleID(rawValue: .max))
    #expect(semantics.reserve() == SemanticRevision(rawValue: .max))
    #expect(candidates.reserve() == CandidateFrameID(rawValue: .max))
    #expect(presentations.reserve() == PresentationRevision(rawValue: .max))
    #expect(actions.reserve() == ActionGeneration(rawValue: .max))

    for _ in 0 ..< 2 {
        #expect(cycles.reserve() == nil)
        #expect(semantics.reserve() == nil)
        #expect(candidates.reserve() == nil)
        #expect(presentations.reserve() == nil)
        #expect(actions.reserve() == nil)
    }
}

@Test
func exhaustedAllocatorFailureMapsOnlyToIdentityExhausted() {
    var allocator = CandidateFrameIDAllocator(nextRawValue: nil)
    let result: RunCycleFailure<UInt8> =
        allocator.reserve() == nil
        ? .execution(.identityExhausted)
        : .execution(.invariantViolation)

    #expect(result == .execution(.identityExhausted))
    #expect(allocator.reserve() == nil)
}

@Test
func allocatorsAreIndependentFiniteSendableValues() {
    var first = ActionGenerationAllocator()
    var second = ActionGenerationAllocator()

    #expect(first.reserve() == ActionGeneration(rawValue: 0))
    #expect(first.reserve() == ActionGeneration(rawValue: 1))
    #expect(second.reserve() == ActionGeneration(rawValue: 0))
    #expect(first != second)

    requireSendable(RunCycleIDAllocator.self)
    requireSendable(SemanticRevisionAllocator.self)
    requireSendable(CandidateFrameIDAllocator.self)
    requireSendable(PresentationRevisionAllocator.self)
    requireSendable(ActionGenerationAllocator.self)
}
