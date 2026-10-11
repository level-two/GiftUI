@main struct MinimalPositive {
    static func main() {
        let expected = UInt8(truncatingIfNeeded: CommandLine.arguments.count) | 1
        let actual = invokeActivationCallback {
            let marker: InlineArray<1, UInt8> = [expected]
            var owner = MinimalSpanOwner(span: marker.span)
            owner.activate()
            return Int(owner.read())
        }
        precondition(actual == Int(expected))
        print("invariant private struct span positive passed")
    }
}
