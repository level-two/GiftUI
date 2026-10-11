@inline(never)
func invokeActivationCallback(_ body: () -> Int) -> Int { body() }
@inline(never)
func readActivationSpan(_ span: borrowing Span<UInt8>) -> UInt8 { span[0] }
@main struct PrimitiveNegative {
    static func main() {
        let expected = UInt8(truncatingIfNeeded: CommandLine.arguments.count)
        var escaped: Span<UInt8>? = nil
        _ = invokeActivationCallback {
            let marker: InlineArray<1, UInt8> = [expected]
            escaped = marker.span
            return 1
        }
        precondition(readActivationSpan(escaped!) == expected)
    }
}
