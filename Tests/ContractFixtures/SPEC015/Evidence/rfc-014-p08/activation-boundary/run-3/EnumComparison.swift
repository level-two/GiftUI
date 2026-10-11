enum PrimitiveSpanOwner: ~Copyable, ~Escapable {
    case inert(Span<UInt8>)
    case active(Span<UInt8>)
    @_lifetime(copy span)
    init(span: Span<UInt8>) { self = .inert(span) }
    @_lifetime(self: copy self)
    mutating func activate() {
        switch consume self {
        case .inert(let span): self = .active(span)
        case .active(let span): self = .active(span)
        }
    }
    @_lifetime(self: copy self)
    mutating func read() -> UInt8 {
        switch consume self {
        case .inert(let span):
            let value = readActivationSpan(span)
            self = .inert(span)
            return value
        case .active(let span):
            let value = readActivationSpan(span)
            self = .active(span)
            return value
        }
    }
}
@inline(never)
func readActivationSpan(_ span: borrowing Span<UInt8>) -> UInt8 { span[0] }
@main struct EnumComparisonMain {
    static func main() {
        let expected = UInt8(truncatingIfNeeded: CommandLine.arguments.count) | 1
        let valid = invokeActivationCallback {
            let marker: InlineArray<1, UInt8> = [expected]
            var owner = PrimitiveSpanOwner(span: marker.span)
            owner.activate()
            return Int(owner.read())
        }
        precondition(valid == Int(expected))
        var escaped: PrimitiveSpanOwner? = nil
        _ = invokeActivationCallback {
            let marker: InlineArray<1, UInt8> = [expected]
            var owner = PrimitiveSpanOwner(span: marker.span)
            owner.activate()
            escaped = consume owner
            return 1
        }
        var owner = escaped.take()!
        precondition(owner.read() == expected)
    }
}
