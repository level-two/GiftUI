import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIObservableState

@Test func replacementBridgePreservesTheInternalFocusedTransaction() {
    let former = _GiftUIObservationAttachment(slot: 0, generation: 0)
    var bridge = ObservableStateReplacementBridge(
        liveAttachment: former,
        isDirty: false
    )

    #expect(
        bridge.beginReplacement(
            executionPhase: .mutating,
            isCompatible: true,
            candidateAlreadyOwned: false,
            registrationCapacityAvailable: true,
            replacementStagingAvailable: true,
            slot: 0,
            candidateGeneration: ObservableTargetGeneration(rawValue: 4)
        ) == nil
    )
    let candidate = _GiftUIObservationAttachment(slot: 0, generation: 4)
    #expect(bridge.pendingAttachment == candidate)
    #expect(bridge.acceptAttachmentReturn(candidate) == nil)
    #expect(
        bridge.commit()
            == .success(
                ObservableStateReplacementBridgeCommit(
                    formerAttachment: former,
                    activeAttachment: candidate,
                    targetGeneration: ObservableTargetGeneration(rawValue: 4)
                )
            )
    )
    #expect(bridge.liveAttachment == candidate)
    #expect(bridge.isDirty)
    bridge.clearDirtyAfterPublication()
    #expect(!bridge.isDirty)
    #expect(
        bridge.acceptLiveReport(candidate, executionPhase: .mutating)
            == .dirtied
    )
    #expect(
        bridge.acceptLiveReport(candidate, executionPhase: .mutating)
            == .coalesced
    )
    #expect(bridge.retireLive() == nil)
    #expect(
        bridge.acceptLiveReport(candidate, executionPhase: .mutating)
            == .staleAttachment
    )
}

@Test func replacementBridgeDiscardsPoisonedCandidateAndPreservesLive() {
    let former = _GiftUIObservationAttachment(slot: 0, generation: 2)
    var bridge = ObservableStateReplacementBridge(
        liveAttachment: former,
        isDirty: true
    )
    _ = bridge.beginReplacement(
        executionPhase: .mutating,
        isCompatible: true,
        candidateAlreadyOwned: false,
        registrationCapacityAvailable: true,
        replacementStagingAvailable: true,
        slot: 0,
        candidateGeneration: ObservableTargetGeneration(rawValue: 3)
    )
    let candidate = _GiftUIObservationAttachment(slot: 0, generation: 3)

    #expect(bridge.acceptCandidateReport(candidate) == .staleAttachment)
    #expect(bridge.acceptAttachmentReturn(candidate) == .staleAttachment)
    #expect(bridge.commit() == .failure(.staleAttachment))
    #expect(bridge.discardCandidate() == candidate)
    #expect(bridge.liveAttachment == former)
    #expect(bridge.isDirty)
}
