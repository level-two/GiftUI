import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIObservableState

private struct InteractionDiscardProbe:
    ObservableStateInteractionCandidateDiscarder
{
    var discardCount: UInt16 = 0

    mutating func discardInteractionCandidate() {
        discardCount += 1
    }
}

private final class TargetLifetimeModel: _GiftUIObservableReference {
    private(set) var detachments: [_GiftUIObservationAttachment] = []

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        detachments.append(attachment)
    }
}

private func reserveTarget(
    _ allocator: inout ObservableStateAttachmentGenerationAllocator,
    slot: UInt16
) -> ObservableStateAttachmentReservation {
    guard case .success(let reservation) = allocator.reserve(slot: slot) else {
        fatalError("fixture target reservation failed")
    }
    return reservation
}

private func cleanup(
    _ result: ObservableStateTargetLifetimeFinishResult
) -> ObservableStateTargetLifetimeCleanup? {
    guard case .success(let cleanup) = result else { return nil }
    return cleanup
}

@Test
func candidateDiscardDetachesRetiresAndForcesInteractionDiscard() {
    var allocator = ObservableStateAttachmentGenerationAllocator()
    let candidate = reserveTarget(&allocator, slot: 1)
    let model = TargetLifetimeModel()
    var lifetime = ObservableStateTargetLifetime<UInt16>()
    var interaction = InteractionDiscardProbe()

    #expect(lifetime.beginCandidate() == nil)
    #expect(
        lifetime.recordCandidateOnlyEncounter(
            identity: 7,
            ordinal: 0,
            reservation: candidate
        ) == .success(.materialized)
    )
    let constructedGeneration = lifetime.buildInteractionCandidate { view in
        view.publishableTargetGeneration(
            structuralIdentity: 7,
            declarationOrdinal: 0
        )
    }
    #expect(constructedGeneration == candidate.targetGeneration)
    let attached = model._giftUIAttachChangeSink(
        _GiftUIObservableChangeSink(
            attachment: candidate.attachment,
            reportRoute: { _ in .staleAttachment }
        )
    )
    #expect(attached == candidate.attachment)

    let discarded = cleanup(
        lifetime.finishCandidate(.discard, interaction: &interaction)
    )
    #expect(discarded?.attachmentToDetach == candidate.attachment)
    #expect(discarded?.retiredGeneration == candidate.targetGeneration)
    model._giftUIDetachChangeSink(discarded!.attachmentToDetach!)
    #expect(model.detachments == [candidate.attachment])
    #expect(interaction.discardCount == 1)
    #expect(lifetime.targetGeneration(identity: 7, ordinal: 0) == nil)

    let next = reserveTarget(&allocator, slot: 1)
    #expect(next.attachment.generation == candidate.attachment.generation + 1)
    #expect(next.targetGeneration != candidate.targetGeneration)
}

@Test
func publishedRemovalRetiresTheLiveAttachmentAndGeneration() {
    var allocator = ObservableStateAttachmentGenerationAllocator()
    let live = reserveTarget(&allocator, slot: 2)
    var lifetime = ObservableStateTargetLifetime(
        liveIdentity: UInt16(9),
        ordinal: 1,
        reservation: live
    )
    var interaction = InteractionDiscardProbe()

    #expect(lifetime.beginCandidate() == nil)
    let removal = cleanup(
        lifetime.finishCandidate(.publish, interaction: &interaction)
    )
    #expect(removal?.attachmentToDetach == live.attachment)
    #expect(removal?.retiredGeneration == live.targetGeneration)
    #expect(interaction.discardCount == 0)
    #expect(lifetime.targetGeneration(identity: 9, ordinal: 1) == nil)

    let replacement = reserveTarget(&allocator, slot: 2)
    #expect(replacement.targetGeneration != live.targetGeneration)
}

@Test
func preservedDiscardKeepsLiveAndStillDiscardsInteractionCandidate() {
    var allocator = ObservableStateAttachmentGenerationAllocator()
    let live = reserveTarget(&allocator, slot: 4)
    var lifetime = ObservableStateTargetLifetime(
        liveIdentity: UInt16(12),
        ordinal: 3,
        reservation: live
    )
    var interaction = InteractionDiscardProbe()

    #expect(lifetime.beginCandidate() == nil)
    #expect(
        lifetime.recordPreservedEncounter(identity: 12, ordinal: 3)
            == .success(.preserved)
    )
    let discarded = cleanup(
        lifetime.finishCandidate(.discard, interaction: &interaction)
    )
    #expect(discarded?.attachmentToDetach == nil)
    #expect(discarded?.retiredGeneration == nil)
    #expect(interaction.discardCount == 1)
    #expect(
        lifetime.targetGeneration(identity: 12, ordinal: 3)
            == live.targetGeneration
    )
}

@Test
func publishedCandidateBecomesLiveWithoutInteractionDiscard() {
    var allocator = ObservableStateAttachmentGenerationAllocator()
    let candidate = reserveTarget(&allocator, slot: 5)
    var lifetime = ObservableStateTargetLifetime<UInt16>()
    var interaction = InteractionDiscardProbe()

    #expect(lifetime.beginCandidate() == nil)
    #expect(
        lifetime.recordCandidateOnlyEncounter(
            identity: 15,
            ordinal: 2,
            reservation: candidate
        ) == .success(.materialized)
    )
    let published = cleanup(
        lifetime.finishCandidate(.publish, interaction: &interaction)
    )
    #expect(published?.attachmentToDetach == nil)
    #expect(published?.retiredGeneration == nil)
    #expect(interaction.discardCount == 0)
    #expect(
        lifetime.targetGeneration(identity: 15, ordinal: 2)
            == candidate.targetGeneration
    )
}
