struct PolicyRead: ~Escapable {
    let values: Span<UInt32>
    @_lifetime(copy values)
    init(_ values: Span<UInt32>) { self.values = values }
}
struct PolicyOwner: ~Copyable {
    let pointer: UnsafeBufferPointer<UInt32>
    @_lifetime(borrow self)
    borrowing func read() -> PolicyRead {
        PolicyRead(Span(_unsafeElements: pointer))
    }
}
