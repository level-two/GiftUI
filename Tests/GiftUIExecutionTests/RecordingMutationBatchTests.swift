import Testing

@testable import GiftUIExecution

private struct MutationFixtureOwner: RecordingMutationOwner {
    var events: [UInt8] = []
    var knownAction = true
    var currentActionGeneration = ActionGeneration(rawValue: 4)
    var enabled = true
    var currentTargetGeneration = ObservableTargetGeneration(rawValue: 6)

    mutating func apply(stateChange: borrowing UInt8) {
        events.append(10 + stateChange)
    }

    mutating func apply(completion: borrowing UInt8) {
        events.append(20 + completion)
    }

    func actionGeneration(
        for identity: borrowing UInt8
    ) -> ActionGeneration? {
        guard knownAction, identity == 1 else { return nil }
        return currentActionGeneration
    }

    func isActionEnabled(_ identity: borrowing UInt8) -> Bool? {
        guard knownAction, identity == 1 else { return nil }
        return enabled
    }

    func targetGeneration(
        for identity: borrowing UInt8
    ) -> ObservableTargetGeneration? {
        guard knownAction, identity == 1 else { return nil }
        return currentTargetGeneration
    }

    mutating func dispatch(_ identity: borrowing UInt8) {
        events.append(30 + identity)
    }
}

private func action(
    identity: UInt8 = 1,
    actionGeneration: UInt32 = 4,
    targetGeneration: UInt32 = 6
) -> RecordingSemanticAction<UInt8> {
    RecordingSemanticAction(
        identity: identity,
        actionGeneration: ActionGeneration(rawValue: actionGeneration),
        targetGeneration: ObservableTargetGeneration(rawValue: targetGeneration)
    )
}

@Test
func sealedMutationAppliesEachCategoryExactlyOnceInOrder() {
    var batch = RecordingMutationBatch(
        firstStateChange: UInt8(1),
        secondStateChange: UInt8(2),
        firstCompletion: UInt8(1),
        secondCompletion: UInt8(2),
        firstAction: action(),
        secondAction: action()
    )!
    var owner = MutationFixtureOwner()

    #expect(owner.events.isEmpty)
    #expect(batch.apply(phase: .mutating, to: &owner) == nil)
    #expect(owner.events == [11, 12, 21, 22, 31, 31])
    let afterFirstApplication = owner.events
    for laterPhase in [
        ExecutionPhase.idle,
        .admitting,
        .deriving,
        .publishing,
        .offering,
        .finalizing,
    ] {
        #expect(batch.apply(phase: laterPhase, to: &owner) == .invalidPhase)
        #expect(owner.events == afterFirstApplication)
    }
    #expect(
        batch.apply(phase: .mutating, to: &owner) == .reentrancyViolation
    )
    #expect(owner.events == afterFirstApplication)
}

@Test
func constructionAndAdmissionNeverDispatchAnAction() {
    var batch = RecordingMutationBatch<UInt8, UInt8, UInt8>(
        firstAction: action()
    )!
    var owner = MutationFixtureOwner()

    #expect(owner.events.isEmpty)
    #expect(batch.apply(phase: .admitting, to: &owner) == .invalidPhase)
    #expect(owner.events.isEmpty)
}

@Test
func actionDispatchRequiresEveryCurrentIdentityAndGenerationProof() {
    var cases: [MutationFixtureOwner] = []
    var missing = MutationFixtureOwner()
    missing.knownAction = false
    cases.append(missing)
    var wrongActionGeneration = MutationFixtureOwner()
    wrongActionGeneration.currentActionGeneration = ActionGeneration(rawValue: 5)
    cases.append(wrongActionGeneration)
    var disabled = MutationFixtureOwner()
    disabled.enabled = false
    cases.append(disabled)
    var wrongTargetGeneration = MutationFixtureOwner()
    wrongTargetGeneration.currentTargetGeneration = ObservableTargetGeneration(rawValue: 7)
    cases.append(wrongTargetGeneration)

    for var owner in cases {
        var batch = RecordingMutationBatch<UInt8, UInt8, UInt8>(
            firstAction: action()
        )!
        #expect(batch.apply(phase: .mutating, to: &owner) == nil)
        #expect(owner.events.isEmpty)
    }

    var valid = MutationFixtureOwner()
    var validBatch = RecordingMutationBatch<UInt8, UInt8, UInt8>(
        firstAction: action()
    )!
    #expect(validBatch.apply(phase: .mutating, to: &valid) == nil)
    #expect(valid.events == [31])
}

@Test
func boundedCategoryStorageRejectsEveryNonPrefixShape() {
    #expect(
        RecordingMutationBatch<UInt8, UInt8, UInt8>(
            secondStateChange: 1
        ) == nil
    )
    #expect(
        RecordingMutationBatch<UInt8, UInt8, UInt8>(
            secondCompletion: 1
        ) == nil
    )
    #expect(
        RecordingMutationBatch<UInt8, UInt8, UInt8>(
            secondAction: action()
        ) == nil
    )
}
