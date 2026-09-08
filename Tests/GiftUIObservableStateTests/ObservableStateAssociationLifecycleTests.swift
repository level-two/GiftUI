import GiftUI
import Testing

@testable import GiftUIObservableState

private final class FixtureAssociationModel: _GiftUIObservableReference {
    let identity: UInt16
    private(set) var attachCount: UInt16 = 0
    private(set) var detachCount: UInt16 = 0
    private(set) var applicationStartCount: UInt16 = 0
    private(set) var applicationStopCount: UInt16 = 0

    init(identity: UInt16) {
        self.identity = identity
    }

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        attachCount += 1
        return sink.attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        detachCount += 1
    }
}

private final class FixtureAssociationModelBox {
    var model: FixtureAssociationModel?
}

private struct FixtureAssociationSlot {
    typealias Lifecycle = ObservableStateAssociationLifecycle<UInt16, UInt16>

    var lifecycle = Lifecycle()
    var liveModel: FixtureAssociationModel?
    var candidateModel: FixtureAssociationModel?
    var candidateBox: FixtureAssociationModelBox?
    var nextGeneration: UInt32 = 0

    mutating func prepareCandidate() -> ObservableStateError? {
        candidateModel = nil
        candidateBox = nil
        return lifecycle.prepareCandidate()
    }

    mutating func encounter(
        _ state: inout State<FixtureAssociationModel>,
        structuralIdentity: UInt16,
        declarationOrdinal: UInt16,
        discriminator: UInt16,
        candidateAlreadyOwned: Bool = false
    ) -> ObservableStateResult {
        let result = lifecycle.encounter(
            structuralIdentity: structuralIdentity,
            declarationOrdinal: declarationOrdinal,
            modelDiscriminator: discriminator,
            candidateModelAlreadyOwned: candidateAlreadyOwned
        )
        guard
            result == .success(.materialized)
                || result == .success(.preserved)
        else { return result }

        let box = FixtureAssociationModelBox()
        guard
            let initializer = state._giftUIBind(
                read: { box.model! },
                replace: { box.model = $0 }
            )
        else {
            return .failure(.invariantViolation)
        }

        switch result {
        case .success(.preserved):
            box.model = liveModel
        case .success(.materialized):
            let attachment = _GiftUIObservationAttachment(
                slot: declarationOrdinal,
                generation: nextGeneration
            )
            nextGeneration += 1
            let returned = initializer._giftUIAttachChangeSink(
                _GiftUIObservableChangeSink(
                    attachment: attachment,
                    reportRoute: { _ in .staleAttachment }
                )
            )
            guard returned == attachment else {
                return .failure(.staleAttachment)
            }
            candidateModel = initializer
            box.model = initializer
        default:
            return .failure(.invariantViolation)
        }
        candidateBox = box
        return result
    }

    mutating func finish(
        _ disposition: ObservableStateCandidateDisposition
    ) {
        let cleanup = lifecycle.finishCandidate(disposition)
        switch (disposition, cleanup) {
        case (.publish, .none) where candidateModel != nil:
            liveModel = candidateModel
        case (.publish, .detachLive):
            detach(&liveModel)
        case (.discard, .detachCandidate):
            detach(&candidateModel)
        default:
            break
        }
        candidateModel = nil
        candidateBox = nil
    }

    mutating func shutdown() {
        switch lifecycle.shutdown() {
        case .none:
            break
        case .detachCandidate:
            detach(&candidateModel)
        case .detachLive:
            detach(&liveModel)
        }
        candidateModel = nil
        candidateBox = nil
    }

    private func detach(_ model: inout FixtureAssociationModel?) {
        guard let installedModel = model else { return }
        installedModel._giftUIDetachChangeSink(
            _GiftUIObservationAttachment(slot: 0, generation: 0)
        )
        model = nil
    }
}

@Test
func firstEncounterMaterializesAndPublishedEncounterPreservesIdentity() {
    var slot = FixtureAssociationSlot()
    let first = FixtureAssociationModel(identity: 1)
    var firstState = State(wrappedValue: first)

    #expect(slot.prepareCandidate() == nil)
    #expect(
        slot.encounter(
            &firstState,
            structuralIdentity: 8,
            declarationOrdinal: 0,
            discriminator: 21
        ) == .success(.materialized)
    )
    #expect(first.attachCount == 1)
    slot.finish(.publish)
    #expect(slot.liveModel === first)
    #expect(slot.lifecycle.isLive)
    #expect(slot.lifecycle.admitsReport)

    let repeatedInitializer = FixtureAssociationModel(identity: 2)
    var repeatedState = State(wrappedValue: repeatedInitializer)
    #expect(slot.prepareCandidate() == nil)
    #expect(
        slot.encounter(
            &repeatedState,
            structuralIdentity: 8,
            declarationOrdinal: 0,
            discriminator: 21
        ) == .success(.preserved)
    )
    #expect(repeatedInitializer.attachCount == 0)
    #expect(repeatedState.wrappedValue === first)
    slot.finish(.publish)
    #expect(slot.liveModel === first)
}

@Test
func declarationOrdinalDistinguishesLocationsAndIncompatibleTypeFailsClosed() {
    var firstSlot = FixtureAssociationSlot()
    var secondSlot = FixtureAssociationSlot()
    let first = FixtureAssociationModel(identity: 3)
    let second = FixtureAssociationModel(identity: 4)
    var firstState = State(wrappedValue: first)
    var secondState = State(wrappedValue: second)

    #expect(firstSlot.prepareCandidate() == nil)
    #expect(secondSlot.prepareCandidate() == nil)
    #expect(
        firstSlot.encounter(
            &firstState,
            structuralIdentity: 13,
            declarationOrdinal: 0,
            discriminator: 34
        ) == .success(.materialized)
    )
    #expect(
        secondSlot.encounter(
            &secondState,
            structuralIdentity: 13,
            declarationOrdinal: 1,
            discriminator: 34
        ) == .success(.materialized)
    )
    firstSlot.finish(.publish)
    secondSlot.finish(.publish)
    #expect(firstSlot.liveModel === first)
    #expect(secondSlot.liveModel === second)

    let incompatible = FixtureAssociationModel(identity: 5)
    var incompatibleState = State(wrappedValue: incompatible)
    #expect(firstSlot.prepareCandidate() == nil)
    #expect(
        firstSlot.encounter(
            &incompatibleState,
            structuralIdentity: 13,
            declarationOrdinal: 0,
            discriminator: 55
        ) == .failure(.incompatibleAssociation)
    )
    firstSlot.finish(.discard)
    #expect(firstSlot.liveModel === first)
    #expect(first.detachCount == 0)
    #expect(incompatible.attachCount == 0)
}

@Test
func duplicateOwnershipFailsBeforeAttachmentAndPreservesOriginalOwner() {
    var originalSlot = FixtureAssociationSlot()
    var duplicateSlot = FixtureAssociationSlot()
    let shared = FixtureAssociationModel(identity: 6)
    var originalState = State(wrappedValue: shared)

    #expect(originalSlot.prepareCandidate() == nil)
    #expect(
        originalSlot.encounter(
            &originalState,
            structuralIdentity: 21,
            declarationOrdinal: 0,
            discriminator: 1
        ) == .success(.materialized)
    )
    originalSlot.finish(.publish)

    var duplicateState = State(wrappedValue: shared)
    #expect(duplicateSlot.prepareCandidate() == nil)
    #expect(
        duplicateSlot.encounter(
            &duplicateState,
            structuralIdentity: 21,
            declarationOrdinal: 1,
            discriminator: 1,
            candidateAlreadyOwned: true
        ) == .failure(.duplicateOwner)
    )
    duplicateSlot.finish(.discard)
    #expect(shared.attachCount == 1)
    #expect(shared.detachCount == 0)
    #expect(originalSlot.liveModel === shared)
}

@Test
func removalPublishesRetirementAndReinsertionCreatesFreshState() {
    var slot = FixtureAssociationSlot()
    let original = FixtureAssociationModel(identity: 7)
    var originalState = State(wrappedValue: original)

    #expect(slot.prepareCandidate() == nil)
    #expect(
        slot.encounter(
            &originalState,
            structuralIdentity: 34,
            declarationOrdinal: 0,
            discriminator: 2
        ) == .success(.materialized)
    )
    slot.finish(.publish)

    #expect(slot.prepareCandidate() == nil)
    slot.finish(.publish)
    #expect(!slot.lifecycle.isLive)
    #expect(!slot.lifecycle.admitsReport)
    #expect(original.detachCount == 1)
    #expect(original.applicationStartCount == 0)
    #expect(original.applicationStopCount == 0)

    let replacement = FixtureAssociationModel(identity: 8)
    var replacementState = State(wrappedValue: replacement)
    #expect(slot.prepareCandidate() == nil)
    #expect(
        slot.encounter(
            &replacementState,
            structuralIdentity: 34,
            declarationOrdinal: 0,
            discriminator: 2
        ) == .success(.materialized)
    )
    slot.finish(.publish)
    #expect(slot.liveModel === replacement)
    #expect(replacement.attachCount == 1)
}

@Test
func discardedDerivationPreservesLiveAndDetachesCandidateOnlyState() {
    var liveSlot = FixtureAssociationSlot()
    let live = FixtureAssociationModel(identity: 9)
    var liveState = State(wrappedValue: live)
    #expect(liveSlot.prepareCandidate() == nil)
    #expect(
        liveSlot.encounter(
            &liveState,
            structuralIdentity: 55,
            declarationOrdinal: 0,
            discriminator: 3
        ) == .success(.materialized)
    )
    liveSlot.finish(.publish)

    #expect(liveSlot.prepareCandidate() == nil)
    liveSlot.finish(.discard)
    #expect(liveSlot.liveModel === live)
    #expect(live.detachCount == 0)

    var candidateSlot = FixtureAssociationSlot()
    let candidate = FixtureAssociationModel(identity: 10)
    var candidateState = State(wrappedValue: candidate)
    #expect(candidateSlot.prepareCandidate() == nil)
    #expect(
        candidateSlot.encounter(
            &candidateState,
            structuralIdentity: 56,
            declarationOrdinal: 0,
            discriminator: 3
        ) == .success(.materialized)
    )
    candidateSlot.finish(.discard)
    #expect(candidate.detachCount == 1)
    #expect(!candidateSlot.lifecycle.isLive)
}

@Test
func shutdownDetachesInstalledSinkOnceAndPermanentlyClosesTheSlot() {
    var slot = FixtureAssociationSlot()
    let model = FixtureAssociationModel(identity: 11)
    var state = State(wrappedValue: model)
    #expect(slot.prepareCandidate() == nil)
    #expect(
        slot.encounter(
            &state,
            structuralIdentity: 89,
            declarationOrdinal: 0,
            discriminator: 5
        ) == .success(.materialized)
    )
    slot.finish(.publish)

    slot.shutdown()
    slot.shutdown()
    #expect(model.detachCount == 1)
    #expect(model.applicationStartCount == 0)
    #expect(model.applicationStopCount == 0)
    #expect(slot.lifecycle.isShutdown)
    #expect(!slot.lifecycle.admitsReport)
    #expect(slot.prepareCandidate() == .invalidPhaseSafetyNotProven)

    var laterState = State(
        wrappedValue: FixtureAssociationModel(identity: 12)
    )
    #expect(
        slot.encounter(
            &laterState,
            structuralIdentity: 89,
            declarationOrdinal: 0,
            discriminator: 5
        ) == .failure(.invalidPhaseSafetyNotProven)
    )
}
