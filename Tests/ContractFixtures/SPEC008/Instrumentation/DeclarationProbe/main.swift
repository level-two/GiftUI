import GiftUI

@_silgen_name("giftui_allocation_probe_reset")
private func resetAllocationCount()

@_silgen_name("giftui_allocation_probe_read")
private func readAllocationCount() -> UInt64

private struct ProbeResult {
    let caseCount: UInt32
    let mismatchCount: UInt32
    let bodyEvaluationCount: UInt32
    let primitiveVisitCount: UInt32
    let modifierVisitCount: UInt32
}

private struct DeclarationVisitor: _GiftUISemanticTraversalVisitor {
    var bodyEvaluationCount: UInt32 = 0
    var primitiveVisitCount: UInt32 = 0
    var modifierVisitCount: UInt32 = 0

    mutating func visitCustomView<Declaration: View>(
        _ declaration: borrowing Declaration,
        body: () -> Declaration.Body
    ) {
        bodyEvaluationCount &+= 1
        let evaluatedBody = body()
        evaluatedBody._giftUITraverse(&self)
    }

    mutating func visitStatefulCustomView<
        Declaration: View & _GiftUIObservableStateHost
    >(
        _ declaration: borrowing Declaration,
        body: (borrowing Declaration) -> Declaration.Body
    ) {
        bodyEvaluationCount &+= 1
        let evaluatedBody = body(declaration)
        evaluatedBody._giftUITraverse(&self)
    }

    mutating func visitEmpty() {}

    mutating func visitFixed<A: View, B: View>(
        _ a: borrowing A,
        _ b: borrowing B
    ) {}

    mutating func visitFixed<A: View, B: View, C: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C
    ) {}

    mutating func visitFixed<A: View, B: View, C: View, D: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D
    ) {}

    mutating func visitFixed<A: View, B: View, C: View, D: View, E: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D,
        _ e: borrowing E
    ) {}

    mutating func visitConditionalFirst<First: View, Second: View>(
        _ content: borrowing First,
        second: Second.Type
    ) {}

    mutating func visitConditionalSecond<First: View, Second: View>(
        first: First.Type,
        _ content: borrowing Second
    ) {}

    mutating func visitOptionalAbsent<Content: View>(_ content: Content.Type) {}

    mutating func visitOptionalPresent<Content: View>(
        _ content: borrowing Content
    ) {}

    mutating func visitPrimitive<Payload: _GiftUISemanticPrimitivePayload>(
        _ payload: borrowing Payload
    ) {
        primitiveVisitCount &+= 1
    }

    mutating func visitPrimitive<
        Content: View,
        Payload: _GiftUISemanticPrimitivePayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    ) {
        primitiveVisitCount &+= 1
        content._giftUITraverse(&self)
    }

    mutating func visitActionPrimitive<Payload: _GiftUISemanticActionPayload>(
        _ payload: borrowing Payload
    ) {}

    mutating func visitModifier<
        Content: View,
        Payload: _GiftUISemanticModifierPayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    ) {
        content._giftUITraverse(&self)
        modifierVisitCount &+= 1
    }
}

@inline(__always)
private func matches(_ text: BoundedText?, _ expected: StaticString) -> Bool {
    guard let text else { return false }
    return expected.withUTF8Buffer { expectedBuffer in
        let expectedCount = expectedBuffer.last == 0
            ? expectedBuffer.count - 1
            : expectedBuffer.count
        guard text.utf8ByteCount == UInt16(expectedCount) else { return false }
        return text.withUTF8 { actualBuffer in
            for index in 0 ..< expectedCount
            where actualBuffer[index] != expectedBuffer[index] {
                return false
            }
            return true
        }
    }
}

@inline(__always)
private func matchesTrailingNull(_ text: BoundedText?) -> Bool {
    guard let text, text.utf8ByteCount == 2 else { return false }
    return text.withUTF8 { buffer in
        buffer[0] == UInt8(ascii: "A") && buffer[1] == 0
    }
}

@inline(never)
private func exerciseDeclarations() -> ProbeResult {
    let maximum: StaticString =
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    let oversized: StaticString =
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    var malformed = (UInt8(0xF0), UInt8(0x9F), UInt8(0x8E))
    var mismatchCount: UInt32 = 0
    var caseCount: UInt32 = 0

    func check(_ condition: Bool) {
        caseCount &+= 1
        if !condition {
            mismatchCount &+= 1
        }
    }

    check(matches(BoundedText(""), ""))
    check(matches(BoundedText(maximum), maximum))
    check(BoundedText(oversized) == nil)
    check(withUnsafeBytes(of: &malformed) { BoundedText(utf8: $0) == nil })
    check(matches(BoundedText("A\0B"), "A\0B"))
    check(matchesTrailingNull(BoundedText("A\0\0")))
    check(matches(BoundedText("ASCII"), "ASCII"))
    check(matches(BoundedText("°"), "°"))
    check(matches(BoundedText("�"), "�"))
    check(matches(BoundedText(Int32.min), "-2147483648"))
    check(matches(BoundedText(-1), "-1"))
    check(matches(BoundedText(0), "0"))
    check(matches(BoundedText(1), "1"))
    check(matches(BoundedText(Int32.max), "2147483647"))

    var visitor = DeclarationVisitor()
    let declaration = Text("styled")
        .foregroundStyle(.red)
        .background(.blue)
        .foregroundStyle(.green)
    declaration._giftUITraverse(&visitor)
    Text(oversized)._giftUITraverse(&visitor)

    return ProbeResult(
        caseCount: caseCount,
        mismatchCount: mismatchCount,
        bodyEvaluationCount: visitor.bodyEvaluationCount,
        primitiveVisitCount: visitor.primitiveVisitCount,
        modifierVisitCount: visitor.modifierVisitCount
    )
}

private let warmupResult = exerciseDeclarations()
resetAllocationCount()
private let result = exerciseDeclarations()
private let allocationCount = readAllocationCount()

print("warmup_mismatch_count=\(warmupResult.mismatchCount)")
print("case_count=\(result.caseCount)")
print("mismatch_count=\(result.mismatchCount)")
print("allocation_count=\(allocationCount)")
print("trap_count=0")
print("body_evaluation_count=\(result.bodyEvaluationCount)")
print("primitive_visit_count=\(result.primitiveVisitCount)")
print("modifier_visit_count=\(result.modifierVisitCount)")
