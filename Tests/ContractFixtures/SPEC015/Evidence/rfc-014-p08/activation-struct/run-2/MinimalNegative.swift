@main struct MinimalNegative {
    static func main() {
        let expected = UInt8(truncatingIfNeeded: CommandLine.arguments.count) | 1
        var escaped: MinimalSpanOwner? = nil
        _ = invokeActivationCallback {
            let marker: InlineArray<1, UInt8> = [expected]
            var owner = MinimalSpanOwner(span: marker.span)
            owner.activate()
            escaped = consume owner
            return 1
        }
        let owner = escaped.take()!
        precondition(owner.read() == expected)
    }
}
