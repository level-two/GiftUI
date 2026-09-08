import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIObservableState

private func reservation(
    _ result: ObservableStateAttachmentReservationResult
) -> ObservableStateAttachmentReservation? {
    guard case .success(let reservation) = result else { return nil }
    return reservation
}

private func activate(
    _ attachment: _GiftUIObservationAttachment,
    in lifecycle: inout ObservableStateRegistrationLifecycle
) {
    #expect(lifecycle.beginAttachment(attachment) == nil)
    #expect(lifecycle.acceptAttachmentReturn(attachment) == nil)
}

@Test
func attachmentGenerationsBeginAtZeroAndAdvanceRuntimeWide() {
    var allocator = ObservableStateAttachmentGenerationAllocator()
    let first = reservation(allocator.reserve(slot: 7))
    let second = reservation(allocator.reserve(slot: 2))

    #expect(first?.attachment.slot == 7)
    #expect(first?.attachment.generation == 0)
    #expect(first?.targetGeneration == ObservableTargetGeneration(rawValue: 0))
    #expect(second?.attachment.slot == 2)
    #expect(second?.attachment.generation == 1)
    #expect(second?.targetGeneration == ObservableTargetGeneration(rawValue: 1))
}

@Test
func recycledSlotIsProtectedByTheCompleteFreshAttachment() {
    var allocator = ObservableStateAttachmentGenerationAllocator()
    let former = reservation(allocator.reserve(slot: 4))!
    let replacement = reservation(allocator.reserve(slot: 4))!
    var lifecycle = ObservableStateRegistrationLifecycle()

    activate(former.attachment, in: &lifecycle)
    #expect(lifecycle.retire(attachment: former.attachment) == nil)
    activate(replacement.attachment, in: &lifecycle)

    #expect(former.attachment.slot == replacement.attachment.slot)
    #expect(former.attachment != replacement.attachment)
    #expect(former.targetGeneration != replacement.targetGeneration)
    #expect(lifecycle.acceptReport(former.attachment) == .staleAttachment)
    #expect(lifecycle.acceptReport(replacement.attachment) == nil)
}

@Test
func generationMaximumIsIssuedOnceThenExhaustionIsPermanent() {
    var allocator = ObservableStateAttachmentGenerationAllocator(
        nextGeneration: .max
    )
    let maximum = reservation(allocator.reserve(slot: .max))

    #expect(maximum?.attachment.generation == .max)
    #expect(
        allocator.reserve(slot: 0)
            == .failure(.registrationGenerationExhausted)
    )
    #expect(
        allocator.reserve(slot: 1)
            == .failure(.registrationGenerationExhausted)
    )
}

@Test
func initialAndReplacementExhaustionFailClosed() {
    var initialAllocator = ObservableStateAttachmentGenerationAllocator(
        nextGeneration: nil
    )
    let vacant = ObservableStateRegistrationLifecycle()
    #expect(
        initialAllocator.reserve(slot: 0)
            == .failure(.registrationGenerationExhausted)
    )
    #expect(!vacant.isActive)

    let former = _GiftUIObservationAttachment(slot: 3, generation: 19)
    var live = ObservableStateRegistrationLifecycle()
    activate(former, in: &live)
    var replacementAllocator = ObservableStateAttachmentGenerationAllocator(
        nextGeneration: nil
    )

    #expect(
        replacementAllocator.reserve(slot: 3)
            == .failure(.registrationGenerationExhausted)
    )
    #expect(live.acceptReport(former) == nil)
    #expect(live.isActive)
}

@Test
func allocatorAndReservationAreFiniteSendableValues() {
    func requireSendable<Value: Sendable>(_: Value.Type) {}

    requireSendable(ObservableStateAttachmentReservation.self)
    requireSendable(ObservableStateAttachmentReservationResult.self)
    requireSendable(ObservableStateAttachmentGenerationAllocator.self)
    #expect(
        MemoryLayout<ObservableStateAttachmentReservation>.size
            <= MemoryLayout<UInt64>.size
    )
    #expect(
        MemoryLayout<ObservableStateAttachmentGenerationAllocator>.size
            <= MemoryLayout<UInt64>.size
    )
}
