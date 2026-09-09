import Testing

@testable import GiftUILayout

@Test
func layoutErrorsHaveExactRawValuesAndLayout() {
    #expect(LayoutError.invalidDeclaration.rawValue == 0)
    #expect(LayoutError.arithmeticOverflow.rawValue == 1)
    #expect(LayoutError.capacityExhausted.rawValue == 2)
    #expect(LayoutError.reentrancyViolation.rawValue == 3)
    #expect(LayoutError.invariantViolation.rawValue == 4)
    #expect(MemoryLayout<LayoutError>.size == 1)
    #expect(MemoryLayout<LayoutError>.stride == 1)
}
