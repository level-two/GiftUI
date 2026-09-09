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

@Test
func layoutLimitsRequireEveryNonzeroCapacityAndFitTheirCeiling() {
    let valid = LayoutLimits(
        maximumScopes: 1,
        maximumDepth: 2,
        maximumTextScalars: 3,
        maximumTextLines: 4,
        maximumPositionedGlyphs: 5
    )

    #expect(valid?.maximumScopes == 1)
    #expect(valid?.maximumDepth == 2)
    #expect(valid?.maximumTextScalars == 3)
    #expect(valid?.maximumTextLines == 4)
    #expect(valid?.maximumPositionedGlyphs == 5)
    #expect(MemoryLayout<LayoutLimits>.size <= 10)

    for zeroIndex in 0 ..< 5 {
        var values: [UInt16] = [1, 1, 1, 1, 1]
        values[zeroIndex] = 0
        #expect(
            LayoutLimits(
                maximumScopes: values[0],
                maximumDepth: values[1],
                maximumTextScalars: values[2],
                maximumTextLines: values[3],
                maximumPositionedGlyphs: values[4]
            ) == nil
        )
    }
}

@Test
func layoutSummaryAndResultFitTheirExactCeilings() {
    #expect(LayoutResult.failure(.capacityExhausted) == .failure(.capacityExhausted))
    #expect(MemoryLayout<LayoutSummary>.size <= 28)
    #expect(MemoryLayout<LayoutResult>.size <= 32)
}
