// Compiled with audited production sources assembled by run.py.
// Never execute or dereference any escaped State produced here.
struct AuditModel: _GiftUIObservableReference {
    var value: UInt32 = 17
    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? { sink.attachment }
    mutating func _giftUIDetachChangeSink(_ attachment: _GiftUIObservationAttachment) {}
}

func escapeThroughResult() -> State<AuditModel>? {
    var storage = StaticObservableModelStorage<AuditModel>()
    let outcome = storage.withBoundState(
        State(wrappedValue: AuditModel()), replacementRoute: { _ in },
        body: { state in state }
    )
    switch outcome {
    case .bound(_, let escaped): return escaped
    case .failure: return nil
    }
}

func escapeThroughVoidCallback() -> State<AuditModel>? {
    var storage = StaticObservableModelStorage<AuditModel>()
    var escaped: State<AuditModel>?
    _ = storage.withBoundState(
        State(wrappedValue: AuditModel()), replacementRoute: { _ in },
        body: { state -> Void in escaped = state }
    )
    return escaped
}

func escapeThroughDelayedClosure() -> (() -> AuditModel)? {
    var storage = StaticObservableModelStorage<AuditModel>()
    var escaped: (() -> AuditModel)?
    _ = storage.withBoundState(
        State(wrappedValue: AuditModel()), replacementRoute: { _ in },
        body: { state -> Void in
            let copied = state
            escaped = { copied.wrappedValue }
        }
    )
    return escaped
}

// A fixed typed pointer route removes the capturing getter closure but does
// not change the copyable facade's ability to escape a Void callback.
struct SpecializedState {
    let model: UnsafePointer<UInt32>
    var wrappedValue: UInt32 { model.pointee }
}

func withSpecializedState(
    _ value: inout UInt32,
    body: (borrowing SpecializedState) -> Void
) {
    withUnsafePointer(to: &value) { pointer in
        body(SpecializedState(model: pointer))
    }
}

func escapeSpecializedRoute() -> SpecializedState? {
    var value: UInt32 = 17
    var escaped: SpecializedState?
    withSpecializedState(&value) { state in escaped = state }
    return escaped
}
