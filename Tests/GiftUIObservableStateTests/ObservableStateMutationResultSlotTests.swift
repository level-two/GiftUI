import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIObservableState

private final class MutationSlotModel: _GiftUIObservableReference {
    let identity: UInt16

    init(identity: UInt16) {
        self.identity = identity
    }

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

private final class MutationSlotBox {
    var slot = ObservableStateMutationResultSlot()
    var nextResult: ObservableStateResult = .success(.replaced)
}

@Test
func firstFailureSurvivesLaterFailureAndSuccessUntilConsumed() {
    var slot = ObservableStateMutationResultSlot()
    #expect(slot.beginCycle(phase: .mutating) == nil)
    #expect(
        slot.record(.failure(.staleAttachment))
            == .cycleLocal
    )
    #expect(
        slot.record(.failure(.invariantViolation))
            == .cycleLocal
    )
    #expect(slot.record(.success(.replaced)) == .none)
    #expect(slot.pendingFailure == .staleAttachment)
    #expect(slot.consumeAfterOperation() == .staleAttachment)
    #expect(slot.pendingFailure == nil)
    #expect(slot.consumeAfterOperation() == nil)
}

@Test
func eachEnclosingOperationConsumesAndClearsBeforeDerivation() {
    var slot = ObservableStateMutationResultSlot()
    #expect(slot.beginCycle(phase: .mutating) == nil)
    _ = slot.record(.failure(.duplicateOwner))
    #expect(slot.prepareForDerivation() == .invariantViolation)
    #expect(slot.consumeAfterOperation() == .duplicateOwner)

    _ = slot.record(.failure(.replacementStagingCapacityExhausted))
    #expect(
        slot.consumeAfterOperation()
            == .replacementStagingCapacityExhausted
    )
    #expect(slot.pendingFailure == nil)
    #expect(slot.prepareForDerivation() == nil)
    #expect(!slot.cycleActive)
}

@Test
func boundSetterStoresExactFirstFailureForCoordinatorConsumption() {
    let initial = MutationSlotModel(identity: 1)
    let live = MutationSlotModel(identity: 2)
    let box = MutationSlotBox()
    var state = State(wrappedValue: initial)
    _ = state._giftUIBind(
        read: { live },
        replace: { _ in
            _ = box.slot.record(box.nextResult)
        }
    )
    #expect(box.slot.beginCycle(phase: .mutating) == nil)

    box.nextResult = .failure(.incompatibleAssociation)
    state.wrappedValue = MutationSlotModel(identity: 3)
    box.nextResult = .success(.replaced)
    state.wrappedValue = MutationSlotModel(identity: 4)

    #expect(box.slot.pendingFailure == .incompatibleAssociation)
    #expect(box.slot.consumeAfterOperation() == .incompatibleAssociation)
}

@Test
func sinkFailureStoresSamePackageFailureBeforeReturning() {
    var slot = ObservableStateMutationResultSlot()
    #expect(slot.beginCycle(phase: .mutating) == nil)
    let disposition = ObservableStateReportDisposition(.reentrancyViolation)
    #expect(slot.recordReportDisposition(disposition) == .cycleLocal)
    #expect(disposition.ownerResult == .failure(.reentrancyViolation))
    #expect(slot.pendingFailure == .reentrancyViolation)
    #expect(slot.consumeAfterOperation() == .reentrancyViolation)
}

@Test
func failureOutsideCycleRoutesDirectlyToOwnerAdapter() {
    var slot = ObservableStateMutationResultSlot()
    #expect(
        slot.record(.failure(.invalidPhaseContained))
            == .ownerAdapter(.invalidPhaseContained)
    )
    #expect(slot.pendingFailure == nil)
    #expect(slot.record(.success(.coalesced)) == .none)
    #expect(slot.pendingFailure == nil)
}

@Test
func mutationResultSlotIsBoundedInlineStateOnly() {
    #expect(MemoryLayout<ObservableStateMutationResultSlot>.size <= 3)
    #expect(MemoryLayout<ObservableStateMutationResultSlot>.stride <= 4)
}
