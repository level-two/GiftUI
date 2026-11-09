import GiftUI

struct Model: _GiftUIObservableReference {
    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

enum ModelSchema: _GiftUIModelSchema {
    typealias Seed = Model
}

var state = State<ModelSchema>(seed: Model())
_ = state._giftUIBinding
