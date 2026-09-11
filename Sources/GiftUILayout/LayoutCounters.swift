package struct LayoutCounters: Equatable, Sendable {
    package private(set) var scopeCount: UInt16 = 0
    package private(set) var currentDepth: UInt16 = 0
    package private(set) var maximumObservedDepth: UInt16 = 0
    package private(set) var textScalarCount: UInt16 = 0
    package private(set) var textLineCount: UInt16 = 0
    package private(set) var positionedGlyphCount: UInt16 = 0

    private let limits: LayoutLimits
    private var firstFailure: LayoutError?

    package init(limits: LayoutLimits) {
        self.limits = limits
    }

    package mutating func reserveScope() -> LayoutError? {
        guard let next = reserve(after: scopeCount, limit: limits.maximumScopes) else {
            return record(.capacityExhausted)
        }
        scopeCount = next
        return nil
    }

    package mutating func enterScope() -> LayoutError? {
        guard firstFailure == nil else { return firstFailure }
        guard let next = incremented(currentDepth), next <= limits.maximumDepth else {
            return record(.capacityExhausted)
        }
        currentDepth = next
        if next > maximumObservedDepth {
            maximumObservedDepth = next
        }
        return nil
    }

    package mutating func leaveScope() -> LayoutError? {
        guard firstFailure == nil else { return firstFailure }
        guard currentDepth > 0 else { return record(.invariantViolation) }
        currentDepth -= 1
        return nil
    }

    package mutating func reserveTextScalar() -> LayoutError? {
        guard
            let next = reserve(
                after: textScalarCount,
                limit: limits.maximumTextScalars
            )
        else { return record(.capacityExhausted) }
        textScalarCount = next
        return nil
    }

    package mutating func reserveTextLine() -> LayoutError? {
        guard
            let next = reserve(
                after: textLineCount,
                limit: limits.maximumTextLines
            )
        else { return record(.capacityExhausted) }
        textLineCount = next
        return nil
    }

    package mutating func reservePositionedGlyph() -> LayoutError? {
        guard
            let next = reserve(
                after: positionedGlyphCount,
                limit: limits.maximumPositionedGlyphs
            )
        else { return record(.capacityExhausted) }
        positionedGlyphCount = next
        return nil
    }

    package mutating func finish(expectedScopeCount: UInt16) -> LayoutError? {
        guard firstFailure == nil else { return firstFailure }
        guard currentDepth == 0, scopeCount == expectedScopeCount else {
            return record(.invariantViolation)
        }
        return nil
    }

    private func reserve(
        after count: UInt16,
        limit: UInt16
    ) -> UInt16? {
        guard firstFailure == nil,
            let next = incremented(count),
            next <= limit
        else { return nil }
        return next
    }

    private func incremented(_ value: UInt16) -> UInt16? {
        let result = value.addingReportingOverflow(1)
        return result.overflow ? nil : result.partialValue
    }

    private mutating func record(_ error: LayoutError) -> LayoutError {
        if firstFailure == nil {
            firstFailure = error
        }
        return firstFailure ?? error
    }
}
