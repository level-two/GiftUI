#if ESCAPE_RETURN
@_lifetime(borrow raw)
func returnLocal(_ raw: UnsafeMutableRawPointer) -> FrameRead {
    let p = raw.assumingMemoryBound(to: Transition.self)
    let local = ModelOwner(current: UnsafeMutableBufferPointer(start: p, count: 404),
                           frozen: UnsafeMutableBufferPointer(start: p + 404, count: 404), identity: 7)
    return local.read()
}
#endif
#if ESCAPE_OUTER
func storeOuter(_ outer: borrowing ModelOwner, _ raw: UnsafeMutableRawPointer) -> UInt32 {
    var escaped = outer.read()
    do {
        let p = raw.assumingMemoryBound(to: Transition.self)
        let inner = ModelOwner(current: UnsafeMutableBufferPointer(start: p, count: 404),
                               frozen: UnsafeMutableBufferPointer(start: p + 404, count: 404), identity: 7)
        escaped = inner.read()
    }
    return UInt32(scalarFailure(escaped, ModelKey(owner: 7, generation: 1, epoch: 0))?.rawValue ?? 0)
}
#endif
#if ESCAPE_CLOSURE
func escapingClosure(_ owner: borrowing ModelOwner) -> () -> UInt32 {
    let read = owner.read()
    return { UInt32(scalarFailure(read, ModelKey(owner: 7, generation: 1, epoch: 0))?.rawValue ?? 0) }
}
#endif
#if ESCAPE_FIELD
struct StoredFrame { let read: FrameRead }
#endif
#if ESCAPE_HELPER
@_lifetime(copy read)
func forward(_ read: borrowing FrameRead) -> FrameRead { read }
@_lifetime(borrow raw)
func nestedEscape(_ raw: UnsafeMutableRawPointer) -> FrameRead {
    let p = raw.assumingMemoryBound(to: Transition.self)
    let local = ModelOwner(current: UnsafeMutableBufferPointer(start: p, count: 404),
                           frozen: UnsafeMutableBufferPointer(start: p + 404, count: 404), identity: 7)
    return forward(local.read())
}
#endif
#if OVERLAP_MUTATION
func overlapping(_ owner: inout ModelOwner) -> UInt32 {
    let read = owner.read()
    owner.finish(published: false)
    return UInt32(scalarFailure(read, ModelKey(owner: 7, generation: 1, epoch: 0))?.rawValue ?? 0)
}
#endif
