import GiftUI
import GiftUIExecution
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeStatic

private enum StaticTargetSchema: _GiftUIModelSchema {
    struct Seed {
        let identity: UInt8
    }
}

private struct StaticTargetModel: ObservableStateModel, ObservableModelMutation {
    typealias Schema = StaticTargetSchema
    typealias Mutation = UInt8
    typealias Prepared = UInt8

    var identity: UInt8
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

    mutating func detach(
        _ attachment: _GiftUIObservationAttachment
    ) -> Bool {
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

@Test func copiedStaticTargetAccessKeepsTheGenerationCheckedMutationRoute() throws {
    var ownerNamespace = ObservableModelOwnerNamespace()
    let owner = try ownerNamespace.issue()
    var storage = StaticObservableRootAdapter<StaticTargetModel, UInt32>(
        identity: owner,
        schema: 0x0400,
        needsCapture: false
    )!

    try storage.withLifetime { _, root in
        #expect(root.beginCandidate() == .success(.candidateStarted))
        var state = State<StaticTargetSchema>(seed: .init(identity: 1))
        #expect(root.encounter(identity: 7, ordinal: 0, state: &state) == .success(.materialized))
        #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))

        let first = StaticObservableRootTargetAccess(
            root: root, identity: 7, ordinal: 0
        )
        var copy = StaticObservableRootTargetAccess(
            root: root, identity: 7, ordinal: 0
        )
        let generation = ObservableTargetGeneration(rawValue: 0)

        #expect(first.currentGeneration() == generation)
        #expect(first.mutate(matching: generation, mutation: 2) == .success(.dirtied))
        #expect(copy.mutate(matching: generation, mutation: 3) == .success(.dirtied))
        #expect(
            copy.mutate(
                matching: ObservableTargetGeneration(rawValue: 1), mutation: 4
            ) == .failure(.staleModel)
        )
    }
}
