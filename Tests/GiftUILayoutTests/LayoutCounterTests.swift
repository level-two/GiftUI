import Testing

@testable import GiftUILayout

@Test
func everyLayoutCounterAcceptsEqualityAndRejectsOneOver() {
    var counters = LayoutCounters(limits: counterLimits(maximum: 1))

    #expect(counters.reserveScope() == nil)
    #expect(counters.enterScope() == nil)
    #expect(counters.reserveTextScalar() == nil)
    #expect(counters.reserveTextLine() == nil)
    #expect(counters.reservePositionedGlyph() == nil)
    #expect(counters.scopeCount == 1)
    #expect(counters.currentDepth == 1)
    #expect(counters.maximumObservedDepth == 1)
    #expect(counters.textScalarCount == 1)
    #expect(counters.textLineCount == 1)
    #expect(counters.positionedGlyphCount == 1)

    #expect(counters.reserveScope() == .capacityExhausted)
    #expect(counters.scopeCount == 1)
}

@Test
func layoutCountersKeepTheFirstFailureSticky() {
    var counters = LayoutCounters(limits: counterLimits(maximum: 1))

    #expect(counters.leaveScope() == .invariantViolation)
    #expect(counters.reserveScope() == .invariantViolation)
    #expect(counters.enterScope() == .invariantViolation)
    #expect(counters.scopeCount == 0)
    #expect(counters.currentDepth == 0)
}

@Test
func layoutCountersValidateBalancedDepthAndDeclaredScopeAgreement() {
    var balanced = LayoutCounters(limits: counterLimits(maximum: 2))
    #expect(balanced.reserveScope() == nil)
    #expect(balanced.enterScope() == nil)
    #expect(balanced.leaveScope() == nil)
    #expect(balanced.finish(expectedScopeCount: 1) == nil)

    var unbalanced = LayoutCounters(limits: counterLimits(maximum: 2))
    #expect(unbalanced.reserveScope() == nil)
    #expect(unbalanced.enterScope() == nil)
    #expect(unbalanced.finish(expectedScopeCount: 1) == .invariantViolation)

    var mismatched = LayoutCounters(limits: counterLimits(maximum: 2))
    #expect(mismatched.reserveScope() == nil)
    #expect(mismatched.finish(expectedScopeCount: 2) == .invariantViolation)
}

@Test
func layoutDepthTracksItsHighWaterAndRejectsOneOver() {
    var counters = LayoutCounters(limits: counterLimits(maximum: 2))

    #expect(counters.enterScope() == nil)
    #expect(counters.enterScope() == nil)
    #expect(counters.maximumObservedDepth == 2)
    #expect(counters.enterScope() == .capacityExhausted)
    #expect(counters.currentDepth == 2)
    #expect(counters.maximumObservedDepth == 2)
}

private func counterLimits(maximum: UInt16) -> LayoutLimits {
    LayoutLimits(
        maximumScopes: maximum,
        maximumDepth: maximum,
        maximumTextScalars: maximum,
        maximumTextLines: maximum,
        maximumPositionedGlyphs: maximum
    )!
}
