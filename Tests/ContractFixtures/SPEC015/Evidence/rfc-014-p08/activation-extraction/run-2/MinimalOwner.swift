struct MinimalSpanOwner: ~Copyable, ~Escapable {
    private let anchor: Span<UInt8>
    private var active = false
    @_lifetime(copy span)
    init(span: Span<UInt8>) { anchor = span }
    @_lifetime(self: copy self)
    mutating func activate() { active = true }
    borrowing func read() -> UInt8 {
        precondition(active)
        return readActivationSpan(anchor)
    }
}
@inline(never)
func readActivationSpan(_ span: borrowing Span<UInt8>) -> UInt8 { span[0] }
