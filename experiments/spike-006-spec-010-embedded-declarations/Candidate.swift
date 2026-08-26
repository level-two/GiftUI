// SPIKE-006 disposable compile/link fixture for SPEC-010 declarations.

@_silgen_name("spike006_report")
func spike006Report(_ route: UInt32) -> UInt8

@propertyWrapper
public struct State<Value: _GiftUIObservableReference> {
    public init(wrappedValue: Value) {
        self.initialValue = wrappedValue
    }

    private let initialValue: Value

    public var wrappedValue: Value {
        get { initialValue }
        nonmutating set { _ = newValue }
    }
}

public struct _GiftUIObservableChangeSink: ~Copyable {
    let route: UInt32

    init(route: UInt32) {
        self.route = route
    }

    public mutating func reportChange() {
        _ = spike006Report(route)
    }
}

public protocol _GiftUIObservableReference {
    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment?

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    )
}

public struct _GiftUIObservationAttachment: Equatable, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

public struct ObservableModel: _GiftUIObservableReference {
    var value: Int32
    var attachment: _GiftUIObservationAttachment?

    public init(value: Int32) {
        self.value = value
        self.attachment = nil
    }

    public mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        var transferredSink = sink
        transferredSink.reportChange()
        let installed = _GiftUIObservationAttachment(rawValue: 7)
        attachment = installed
        return installed
    }

    public mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        if self.attachment == attachment {
            self.attachment = nil
        }
    }
}

public struct PortableFixture {
    @State public var model: ObservableModel

    public init(model: ObservableModel) {
        self._model = State(wrappedValue: model)
    }
}

@_cdecl("spike006_swift_run")
public func spike006SwiftRun(_ seed: UInt32) -> UInt32 {
    let fixture = PortableFixture(model: ObservableModel(value: 41))
    let installed = fixture.model._giftUIAttachChangeSink(
        _GiftUIObservableChangeSink(route: seed)
    )
    if let installed {
        fixture.model._giftUIDetachChangeSink(installed)
    }
    return seed ^ UInt32(bitPattern: fixture.model.value)
}
