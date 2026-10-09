// Each branch is compiled independently after the positive candidate.
#if ESCAPE_RETURN
@lifetime(borrow raw)
func returnDeadCapture(_ raw: UnsafeMutableRawPointer) -> FrozenCapture {
    let owner = CaptureOwner(
        unsafeStorage: UnsafeMutableBufferPointer(
            start: raw.assumingMemoryBound(to: Transition.self), count: 404),
        revision: 1
    )
    return owner.view()
}
#endif

#if ESCAPE_OUTER
func storeOutsideCallback(_ owner: borrowing CaptureOwner) -> UInt64 {
    var escaped = owner.view()
    _ = owner.withView { view in
        escaped = view
        return 0
    }
    return checksum(escaped)
}
#endif

#if ESCAPE_CLOSURE
func retainCapture(_ owner: borrowing CaptureOwner) -> () -> UInt64 {
    let view = owner.view()
    return { checksum(view) }
}
#endif

#if OVERLAP_MUTATION
func mutateWhileBorrowed(_ owner: inout CaptureOwner) -> UInt64 {
    let view = owner.view()
    owner.replaceValues(revision: 2, level: 1)
    return checksum(view)
}
#endif

#if CURRENT_DECLARATION_SHAPE
// A copyable/escapable stored declaration matches today's View and stored
// Canvas requirement. This is a minimal type-system compatibility witness,
// not a replacement implementation of the GiftUI View protocol.
struct StoredDeclaration {
    let capture: FrozenCapture
}
#endif
