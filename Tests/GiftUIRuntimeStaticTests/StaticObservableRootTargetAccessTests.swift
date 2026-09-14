import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIRuntimeStatic

private struct StaticTargetModel: _GiftUIObservableReference {
    let identity: UInt8
    private(set) var attachment: _GiftUIObservationAttachment?

    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        attachment = sink.attachment
        return attachment
    }

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        guard self.attachment == attachment else { return }
        self.attachment = nil
    }
}

@Test func copiedStaticTargetAccessPreservesTheTypedStorageIdentity() {
    var root = StaticObservableRootAdapter<StaticTargetModel, UInt32>(
        structuralIdentity: 0x5341_0400,
        declarationOrdinal: 0
    )
    _ = root.beginCandidate()
    _ = root.withEncounter(
        state: State(wrappedValue: StaticTargetModel(identity: 1)),
        replacementRoute: { _ in },
        reportRoute: { _ in .staleAttachment },
        body: { _ in () }
    )
    _ = root.finishCandidate(.publish)

    withUnsafeMutablePointer(to: &root) { pointer in
        var first = StaticObservableRootTargetAccess(root: pointer)
        var copy = first
        var identities: [UInt8] = []

        #expect(first.currentGeneration() == ObservableTargetGeneration(rawValue: 0))
        #expect(
            first.withCurrentModel(
                matching: ObservableTargetGeneration(rawValue: 0)
            ) { identities.append($0.identity) }
        )
        #expect(
            copy.withCurrentModel(
                matching: ObservableTargetGeneration(rawValue: 0)
            ) { identities.append($0.identity) }
        )
        #expect(
            !copy.withCurrentModel(
                matching: ObservableTargetGeneration(rawValue: 1)
            ) { identities.append($0.identity) }
        )
        #expect(identities == [1, 1])
    }
}
