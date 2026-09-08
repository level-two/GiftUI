import GiftUIExecution
import Testing

@testable import GiftUIObservableState

private struct DirtyWakeRequester: ExecutionWakeRequester, Sendable {
    private(set) var requestCount: UInt16 = 0
    private(set) var reasons: ExecutionWakeReasons = []

    mutating func requestWake(for reasons: ExecutionWakeReasons) {
        requestCount += 1
        self.reasons.formUnion(reasons)
    }
}

@Test
func dirtyLocationsShareOneWakeAndTriggerCompleteRootDerivation() {
    var derivation = ObservableStateDirtyDerivation(
        requester: DirtyWakeRequester()
    )
    #expect(
        derivation.recordChangedMutation(at: .first)
            == .success(.dirtied)
    )
    #expect(
        derivation.recordChangedMutation(at: .first)
            == .success(.coalesced)
    )
    #expect(
        derivation.recordChangedMutation(at: .second)
            == .success(.dirtied)
    )
    #expect(derivation.dirtyLocations == [.first, .second])
    #expect(derivation.requester.requestCount == 1)
    #expect(derivation.requester.reasons == .semanticDirty)

    #expect(derivation.takeWakeAtIdle() == .semanticDirty)
    #expect(derivation.freezeAndDeriveCompleteRoot() == nil)
    #expect(derivation.mutationFrozen)
    #expect(derivation.representedDirtyLocations == [.first, .second])
    #expect(derivation.completeRootDerivationCount == 1)
    #expect(derivation.lastDerivedLocationCount == 2)
}

@Test
func successfulPublicationClearsExactlyRepresentedDirtiness() {
    var derivation = ObservableStateDirtyDerivation(
        requester: DirtyWakeRequester()
    )
    _ = derivation.recordChangedMutation(at: .first)
    _ = derivation.takeWakeAtIdle()
    #expect(derivation.freezeAndDeriveCompleteRoot() == nil)
    #expect(derivation.finishDerivation(published: true) == nil)

    #expect(derivation.dirtyLocations.isEmpty)
    #expect(derivation.representedDirtyLocations.isEmpty)
    #expect(!derivation.mutationFrozen)
    #expect(!derivation.semanticWakeOutstanding)
    #expect(derivation.requester.requestCount == 1)
}

@Test
func frameRefusalDoesNotRestoreDirtinessAfterPublication() {
    var derivation = ObservableStateDirtyDerivation(
        requester: DirtyWakeRequester()
    )
    _ = derivation.recordChangedMutation(at: .second)
    _ = derivation.takeWakeAtIdle()
    #expect(derivation.freezeAndDeriveCompleteRoot() == nil)
    #expect(derivation.finishDerivation(published: true) == nil)
    let beforeRefusal = derivation.dirtyLocations

    #expect(derivation.finishFrame(accepted: false) == beforeRefusal)
    #expect(derivation.dirtyLocations.isEmpty)
    #expect(!derivation.semanticWakeOutstanding)
    #expect(derivation.requester.requestCount == 1)
}

@Test
func derivationFailureRetainsDirtyAndSchedulesRecoveryWithoutReplay() {
    var derivation = ObservableStateDirtyDerivation(
        requester: DirtyWakeRequester()
    )
    _ = derivation.recordChangedMutation(at: .first)
    _ = derivation.takeWakeAtIdle()
    #expect(derivation.appliedMutationCount == 1)
    #expect(derivation.freezeAndDeriveCompleteRoot() == nil)
    #expect(derivation.finishDerivation(published: false) == nil)

    #expect(derivation.dirtyLocations == .first)
    #expect(derivation.semanticWakeOutstanding)
    #expect(derivation.requester.requestCount == 2)
    #expect(derivation.takeWakeAtIdle() == .semanticDirty)
    #expect(derivation.freezeAndDeriveCompleteRoot() == nil)
    #expect(derivation.appliedMutationCount == 1)
    #expect(derivation.completeRootDerivationCount == 2)
    #expect(derivation.finishDerivation(published: true) == nil)
    #expect(derivation.appliedMutationCount == 1)
    #expect(derivation.dirtyLocations.isEmpty)
}

@Test
func mutationFreezeRejectsFurtherMutationAndRepeatedFreeze() {
    var derivation = ObservableStateDirtyDerivation(
        requester: DirtyWakeRequester()
    )
    _ = derivation.recordChangedMutation(at: .first)
    _ = derivation.takeWakeAtIdle()
    #expect(derivation.freezeAndDeriveCompleteRoot() == nil)
    #expect(
        derivation.recordChangedMutation(at: .second)
            == .failure(.invalidPhaseSafetyNotProven)
    )
    #expect(
        derivation.freezeAndDeriveCompleteRoot()
            == .reentrancyViolation
    )
    #expect(derivation.appliedMutationCount == 1)
    #expect(derivation.dirtyLocations == .first)
}
