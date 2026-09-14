import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIRuntimeDynamic

private final class DynamicTargetModel: _GiftUIObservableReference {
    let identity: UInt8
    private var attachment: _GiftUIObservationAttachment?

    init(identity: UInt8) {
        self.identity = identity
    }

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        attachment = sink.attachment
        return attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        guard self.attachment == attachment else { return }
        self.attachment = nil
    }
}

@Test func dynamicTargetAccessIsWeakAndRevalidatesTheGeneration() {
    var root: DynamicObservableRootAdapter<DynamicTargetModel, UInt16>? =
        DynamicObservableRootAdapter(capacity: 1)
    var state = State(wrappedValue: DynamicTargetModel(identity: 1))
    _ = root?.beginCandidate()
    _ = root?.encounter(
        structuralIdentity: 41,
        declarationOrdinal: 0,
        state: &state,
        replacementRoute: { _ in }
    )
    _ = root?.finishCandidate(.publish)
    var access = DynamicObservableRootTargetAccess(root: root!)

    #expect(access.currentGeneration() == ObservableTargetGeneration(rawValue: 0))
    var identities: [UInt8] = []
    #expect(
        !access.withCurrentModel(
            matching: ObservableTargetGeneration(rawValue: 1)
        ) { identities.append($0.identity) }
    )
    #expect(
        access.withCurrentModel(
            matching: ObservableTargetGeneration(rawValue: 0)
        ) { identities.append($0.identity) }
    )
    #expect(identities == [1])

    root = nil
    #expect(access.currentGeneration() == nil)
    #expect(
        !access.withCurrentModel(
            matching: ObservableTargetGeneration(rawValue: 0)
        ) { identities.append($0.identity) }
    )
    #expect(identities == [1])
}
