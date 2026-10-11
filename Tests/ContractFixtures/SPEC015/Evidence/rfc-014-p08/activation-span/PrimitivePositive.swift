@inline(never)
func invokeActivationCallback(_ body: () -> Int) -> Int { body() }
@inline(never)
func readActivationSpan(_ span: borrowing Span<UInt8>) -> UInt8 { span[0] }
@main struct PrimitivePositive {
    static func main() {
        let expected = UInt8(truncatingIfNeeded: CommandLine.arguments.count)
        let actual = invokeActivationCallback {
            let marker: InlineArray<1, UInt8> = [expected]
            let span = marker.span
            return Int(readActivationSpan(span))
        }
        precondition(actual == Int(expected))
        print("direct callback-local span positive passed")
    }
}
