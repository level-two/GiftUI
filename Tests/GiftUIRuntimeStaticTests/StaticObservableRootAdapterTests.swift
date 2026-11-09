import GiftUI
import GiftUIExecution
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeStatic

private enum StaticRootSchema: _GiftUIModelSchema {
    struct Seed {
        let identity: UInt8
    }
}

private struct StaticRootModel: ObservableStateModel {
    typealias Schema = StaticRootSchema

    let identity: UInt8
    private(set) var attachment: _GiftUIObservationAttachment?

    static func materialize(_ seed: Schema.Seed) -> Self {
        Self(identity: seed.identity)
    }

    var isEmptyReplacement: Bool { false }

    mutating func attach(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        attachment = sink.attachment
        return attachment
    }

    mutating func detach(_ attachment: _GiftUIObservationAttachment) -> Bool {
        guard self.attachment == attachment else { return false }
        self.attachment = nil
        return true
    }

    mutating func reportChange() -> _GiftUIObservableChangeReportOutcome { .dirtied }
}

private enum StaticRootReadDomain: _GiftUIReadDomain {
    typealias Slot = ObservableModelReadSlot<StaticRootModel>
}

private func modelIdentity(
    at index: Int,
    slots: Span<StaticRootReadDomain.Slot>
) -> UInt8? {
    guard index >= 0, index < slots.count else { return nil }
    return slots[index].model.pointee?.identity
}

private func nextOwner() throws -> ObservableModelOwnerIdentity {
    var namespace = ObservableModelOwnerNamespace()
    return try namespace.issue()
}

@Test func staticRootAdapterPreservesThePublishedModelAcrossRepeatedDiscovery() throws {
    var storage = StaticObservableRootAdapter<StaticRootModel, UInt32>(
        identity: try nextOwner(), schema: 0x51, needsCapture: false
    )!

    try storage.withLifetime { (scope, root) throws(ObservableStateError) in
        #expect(root.beginCandidate() == .success(.candidateStarted))
        var initial = State<StaticRootSchema>(seed: .init(identity: 7))
        #expect(root.encounter(identity: 3, ordinal: 0, state: &initial) == .success(.materialized))
        #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
        #expect(root.generation(identity: 3, ordinal: 0) == 0)

        #expect(root.beginCandidate() == .success(.candidateStarted))
        var repeated = State<StaticRootSchema>(seed: .init(identity: 8))
        #expect(root.encounter(identity: 3, ordinal: 0, state: &repeated) == .success(.preserved))
        #expect(root.finishCandidate(.publish) == .success(.unchanged))

        let identity: UInt8?
        do throws(_GiftUIAccessFailure) {
            identity = try scope.withRead(StaticRootReadDomain.self) { read in
                modelIdentity(at: 0, slots: read.slots)
            }
        } catch {
            throw ObservableStateError(accessFailure: error)
        }
        #expect(identity == 7)
    }
}

@Test func staticRootAdapterDiscardsAnInitialRegistration() throws {
    var storage = StaticObservableRootAdapter<StaticRootModel, UInt32>(
        identity: try nextOwner(), schema: 0x52, needsCapture: false
    )!

    try storage.withLifetime { (scope, root) throws(ObservableStateError) in
        #expect(root.beginCandidate() == .success(.candidateStarted))
        var state = State<StaticRootSchema>(seed: .init(identity: 11))
        #expect(root.encounter(identity: 4, ordinal: 0, state: &state) == .success(.materialized))
        let initialAttachment = root.generation(identity: 4, ordinal: 0)
        #expect(root.finishCandidate(.discard) == .success(.candidateDiscarded))
        #expect(root.generation(identity: 4, ordinal: 0) == nil)

        #expect(root.beginCandidate() == .success(.candidateStarted))
        var reinserted = State<StaticRootSchema>(seed: .init(identity: 12))
        #expect(
            root.encounter(identity: 4, ordinal: 0, state: &reinserted) == .success(.materialized))
        #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
        #expect(root.generation(identity: 4, ordinal: 0) == initialAttachment.map { $0 + 1 })

        let model: UInt8?
        do throws(_GiftUIAccessFailure) {
            model = try scope.withRead(StaticRootReadDomain.self) { read in
                modelIdentity(at: 0, slots: read.slots)
            }
        } catch {
            throw ObservableStateError(accessFailure: error)
        }
        #expect(model == 12)
    }
}

@Test func staticRootAdapterIssuesAFreshGenerationAfterRemoval() throws {
    var storage = StaticObservableRootAdapter<StaticRootModel, UInt32>(
        identity: try nextOwner(), schema: 0x53, needsCapture: false
    )!

    try storage.withLifetime { (_, root) throws(ObservableStateError) in
        #expect(root.beginCandidate() == .success(.candidateStarted))
        var state = State<StaticRootSchema>(seed: .init(identity: 1))
        #expect(root.encounter(identity: 5, ordinal: 0, state: &state) == .success(.materialized))
        #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
        let originalGeneration = root.generation(identity: 5, ordinal: 0)

        #expect(root.beginCandidate() == .success(.candidateStarted))
        #expect(root.finishCandidate(.publish) == .success(.candidateDiscarded))
        #expect(root.generation(identity: 5, ordinal: 0) == nil)

        #expect(root.beginCandidate() == .success(.candidateStarted))
        var reinserted = State<StaticRootSchema>(seed: .init(identity: 2))
        #expect(
            root.encounter(identity: 5, ordinal: 0, state: &reinserted) == .success(.materialized))
        #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
        #expect(root.generation(identity: 5, ordinal: 0) == originalGeneration.map { $0 + 1 })
    }
}
