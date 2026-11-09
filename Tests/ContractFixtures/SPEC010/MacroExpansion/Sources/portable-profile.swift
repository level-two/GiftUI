import GiftUI

public struct PortableProfileModel: _GiftUIObservableReference {
    public init() {}

    public mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    public mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

public enum PortableProfileSchema: _GiftUIModelSchema {
    public typealias Seed = PortableProfileModel
}

@ObservableStateHost
public struct PortableProfileHost: View {
    public typealias Domain = _GiftUIEmptyReadDomain

    @State<PortableProfileSchema> private var primary: _GiftUIModelKey<PortableProfileSchema>?
    @GiftUI.State<PortableProfileSchema> private var secondary:
        _GiftUIModelKey<PortableProfileSchema>?

    public init() {
        _primary = State<PortableProfileSchema>(seed: PortableProfileModel())
        _secondary = State<PortableProfileSchema>(seed: PortableProfileModel())
    }

    public func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)
        throws(_GiftUIAccessFailure) -> EmptyView<Domain>
    {
        EmptyView()
    }
}
