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

@ObservableStateHost
public struct PortableProfileHost: View {
    @State private var primary = PortableProfileModel()
    @GiftUI.State private var secondary = PortableProfileModel()

    public init() {}

    public var body: Never { fatalError() }
}
