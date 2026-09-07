import Testing

@testable import GiftUIExecution

private let phases: [ExecutionPhase] = [
    .idle,
    .admitting,
    .mutating,
    .deriving,
    .publishing,
    .offering,
    .finalizing,
]

private let legalTransitions: Set<UInt16> = [
    transitionKey(.idle, .admitting),
    transitionKey(.admitting, .mutating),
    transitionKey(.admitting, .finalizing),
    transitionKey(.mutating, .deriving),
    transitionKey(.mutating, .finalizing),
    transitionKey(.deriving, .publishing),
    transitionKey(.deriving, .offering),
    transitionKey(.deriving, .finalizing),
    transitionKey(.publishing, .offering),
    transitionKey(.publishing, .finalizing),
    transitionKey(.offering, .finalizing),
    transitionKey(.finalizing, .idle),
]

private func transitionKey(_ from: ExecutionPhase, _ to: ExecutionPhase) -> UInt16 {
    UInt16(from.rawValue) << 8 | UInt16(to.rawValue)
}

private func machine(in phase: ExecutionPhase) -> ExecutionPhaseMachine {
    var machine = ExecutionPhaseMachine()
    var allocator = RunCycleIDAllocator()
    guard phase != .idle else { return machine }
    precondition(machine.beginCycle(reservingFrom: &allocator) == nil)
    guard phase != .admitting else { return machine }
    precondition(machine.transition(to: .mutating) == nil)
    guard phase != .mutating else { return machine }
    precondition(machine.transition(to: .deriving) == nil)
    guard phase != .deriving else { return machine }
    if phase == .publishing {
        precondition(machine.transition(to: .publishing) == nil)
        return machine
    }
    if phase == .offering {
        precondition(machine.transition(to: .offering) == nil)
        return machine
    }
    precondition(machine.transition(to: .finalizing) == nil)
    return machine
}

@Test
func phaseMachineAcceptsExactlyTheClosedTransitionGraph() {
    for current in phases {
        for next in phases {
            var subject = machine(in: current)
            let original = subject.context
            let result = subject.transition(to: next)
            let expected = legalTransitions.contains(transitionKey(current, next))

            #expect((result == nil) == expected)
            if expected {
                #expect(subject.context.phase == next)
            } else {
                #expect(result == .invalidPhase)
                #expect(subject.context == original)
            }
        }
    }
}

@Test
func nestedEntryPreservesActiveCycleAndDoesNotConsumeAnotherIdentity() {
    var allocator = RunCycleIDAllocator()
    var machine = ExecutionPhaseMachine()

    #expect(machine.beginCycle(reservingFrom: &allocator) == nil)
    let active = machine.context
    #expect(machine.beginCycle(reservingFrom: &allocator) == .reentrancyViolation)
    #expect(machine.context == active)

    var nextMachine = ExecutionPhaseMachine()
    #expect(nextMachine.beginCycle(reservingFrom: &allocator) == nil)
    #expect(nextMachine.context.cycle == RunCycleID(rawValue: 1))
}

@Test
func idleCycleIdentityExhaustionKeepsExactIdleContext() {
    var allocator = RunCycleIDAllocator(nextRawValue: nil)
    var machine = ExecutionPhaseMachine()

    #expect(machine.beginCycle(reservingFrom: &allocator) == .identityExhausted)
    #expect(
        machine.context
            == ExecutionContext(
                cycle: nil,
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .idle
            )
    )
}

@Test
func contextTracksPublicationAndCandidateUntilFinalizedIdle() {
    var allocator = RunCycleIDAllocator()
    var machine = ExecutionPhaseMachine()
    let semantic = SemanticRevision(rawValue: 13)
    let candidate = CandidateFrameID(rawValue: 21)

    #expect(machine.beginCycle(reservingFrom: &allocator) == nil)
    #expect(machine.transition(to: .mutating) == nil)
    #expect(machine.transition(to: .deriving) == nil)
    #expect(machine.recordCandidateFrame(candidate) == nil)
    #expect(machine.transition(to: .publishing) == nil)
    #expect(machine.recordPublishedSemanticRevision(semantic) == nil)
    #expect(machine.context.cycle == RunCycleID(rawValue: 0))
    #expect(machine.context.semanticRevision == semantic)
    #expect(machine.context.candidateFrame == candidate)
    #expect(machine.context.phase == .publishing)
    #expect(machine.transition(to: .offering) == nil)
    #expect(machine.transition(to: .finalizing) == nil)
    #expect(machine.context.candidateFrame == candidate)
    #expect(machine.transition(to: .idle) == nil)
    #expect(machine.context.cycle == nil)
    #expect(machine.context.semanticRevision == semantic)
    #expect(machine.context.candidateFrame == nil)
    #expect(machine.context.phase == .idle)
}

@Test
func correlationUpdatesRejectTheWrongPhaseWithoutChangingContext() {
    var machine = ExecutionPhaseMachine()
    let original = machine.context

    #expect(
        machine.recordPublishedSemanticRevision(SemanticRevision(rawValue: 1))
            == .invalidPhase
    )
    #expect(machine.recordCandidateFrame(CandidateFrameID(rawValue: 2)) == .invalidPhase)
    #expect(machine.context == original)
}
