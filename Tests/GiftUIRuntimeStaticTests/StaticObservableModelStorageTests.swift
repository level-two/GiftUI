import GiftUI
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeStatic

private enum StaticStorageSchema: _GiftUIModelSchema {
    struct Seed {
        let identity: UInt8
        var reportDuringAttach = false
    }
}

private struct StaticStorageModel: ObservableStateModel, ObservableModelMutation {
    typealias Schema = StaticStorageSchema
    typealias Mutation = UInt8
    typealias Prepared = UInt8

    var identity: UInt8
    var reportDuringAttach: Bool
    private(set) var attachment: _GiftUIObservationAttachment?

    static func materialize(_ seed: Schema.Seed) -> Self {
        Self(identity: seed.identity, reportDuringAttach: seed.reportDuringAttach)
    }

    var isEmptyReplacement: Bool { false }

    mutating func attach(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        var sink = consume sink
        let attachment = sink.attachment
        if reportDuringAttach { _ = sink.reportChange() }
        self.attachment = attachment
        return attachment
    }

    mutating func detach(_ attachment: _GiftUIObservationAttachment) -> Bool {
        guard self.attachment == attachment else { return false }
        self.attachment = nil
        return true
    }

    mutating func reportChange() -> _GiftUIObservableChangeReportOutcome {
        .dirtied
    }

    borrowing func preflight(_ mutation: Mutation) throws(ObservableStateError) -> Prepared {
        mutation
    }

    mutating func commit(_ prepared: Prepared) -> Bool {
        identity = prepared
        return true
    }
}

private enum StaticStorageReadDomain: _GiftUIReadDomain {
    typealias Slot = ObservableModelReadSlot<StaticStorageModel>
}

private func modelIdentity(
    at index: Int,
    slots: Span<StaticStorageReadDomain.Slot>
) -> UInt8? {
    guard index >= 0, index < slots.count else { return nil }
    return slots[index].model.pointee?.identity
}

private func nextOwner() throws -> ObservableModelOwnerIdentity {
    var namespace = ObservableModelOwnerNamespace()
    return try namespace.issue()
}

@Test func staticModelStorageMaterializesAndPublishesTypedSeed() throws {
    var storage = StaticObservableRootAdapter<StaticStorageModel, UInt32>(
        identity: try nextOwner(), schema: 0x51, needsCapture: false
    )!

    try storage.withLifetime { (scope, root) throws(ObservableStateError) in
        #expect(root.beginCandidate() == .success(.candidateStarted))
        var state = State<StaticStorageSchema>(seed: .init(identity: 4))
        #expect(root.encounter(identity: 9, ordinal: 0, state: &state) == .success(.materialized))
        #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))

        let identity: UInt8?
        do throws(_GiftUIAccessFailure) {
            identity = try scope.withRead(StaticStorageReadDomain.self) { read in
                modelIdentity(at: 0, slots: read.slots)
            }
        } catch {
            throw ObservableStateError(accessFailure: error)
        }
        #expect(identity == 4)
        #expect(root.generation(identity: 9, ordinal: 0) == 0)
    }
}

@Test func staticModelStorageRejectsMutationReportedDuringAttachment() throws {
    var storage = StaticObservableRootAdapter<StaticStorageModel, UInt32>(
        identity: try nextOwner(), schema: 0x51, needsCapture: false
    )!

    try storage.withLifetime { (_, root) throws(ObservableStateError) in
        #expect(root.beginCandidate() == .success(.candidateStarted))
        var state = State<StaticStorageSchema>(
            seed: .init(identity: 5, reportDuringAttach: true)
        )
        #expect(
            root.encounter(identity: 9, ordinal: 0, state: &state)
                == .failure(.staleAttachment)
        )
        #expect(root.finishCandidate(.discard) == .success(.candidateDiscarded))
        #expect(root.modelKey(identity: 9, ordinal: 0) == nil)
    }
}

@Test func staticModelStorageStagesReplacementBeforeChangingTheLiveKey() throws {
    var storage = StaticObservableModelStorage<StaticStorageModel, StaticStorageSchema>(
        identity: try nextOwner(), schema: 0x51, needsCapture: false
    )!

    try storage.withLifetime { (scope) throws(ObservableStateError) in
        var ticket = try scope.materialize(StaticStorageModel.materialize(.init(identity: 1)))
        try scope.register(ticket)
        let originalKey = ticket.key
        let reservation = try scope.stageReplacement(
            transferring: ticket,
            seed: .init(identity: 2),
            registrationAvailable: true,
            stagingAvailable: true
        )
        #expect(ticket.key == originalKey)
        var replacement = try scope.commitReplacement(reservation, transferring: &ticket)
        #expect(replacement.key != originalKey)
        #expect(replacement.key._giftUISlot != originalKey._giftUISlot)
        try scope.release(&replacement)
    }
}

@Test func staticModelStorageOwnsOnlyInlineTypedOptionalStorage() throws {
    let owner = try nextOwner()
    let storage = StaticObservableModelStorage<StaticStorageModel, StaticStorageSchema>(
        identity: owner, schema: 0x51, needsCapture: false
    )!
    #expect(
        storage.storageLayout.modelBytes == MemoryLayout<InlineArray<2, StaticStorageModel?>>.size)
}
