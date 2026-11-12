import GiftUI
import GiftUITextResources

@usableFromInline
package struct RenderSinkCapacity: Equatable, Sendable {
    @usableFromInline
    package let maximumOperations: UInt16
    @usableFromInline
    package let maximumPositionedGlyphs: UInt16

    #if GIFTUI_LIMITS_QUALIFICATION
        @_noAllocation
    #endif
    package init(
        maximumOperations: UInt16,
        maximumPositionedGlyphs: UInt16
    ) {
        self.maximumOperations = maximumOperations
        self.maximumPositionedGlyphs = maximumPositionedGlyphs
    }
}

@usableFromInline
package enum RenderDamageMode: UInt8, Equatable, Sendable {
    case rootIntersection = 0
    case initializeCompleteSurface = 1
}

@usableFromInline
package struct RenderPlanHeader: Equatable, Sendable {
    @usableFromInline
    package let surfaceBounds: Rect
    @usableFromInline
    package let damageBounds: Rect
    @usableFromInline
    package let operationCount: UInt16
    @usableFromInline
    package let positionedGlyphCount: UInt16
    package let maximumObservedClipDepth: UInt16

    @usableFromInline
    package init(
        surfaceBounds: Rect,
        damageBounds: Rect,
        operationCount: UInt16,
        positionedGlyphCount: UInt16,
        maximumObservedClipDepth: UInt16
    ) {
        self.surfaceBounds = surfaceBounds
        self.damageBounds = damageBounds
        self.operationCount = operationCount
        self.positionedGlyphCount = positionedGlyphCount
        self.maximumObservedClipDepth = maximumObservedClipDepth
    }
}

@usableFromInline
package struct PositionedGlyph: Equatable, Sendable {
    package let glyph: GlyphID
    package let baseline: Point

    @usableFromInline
    package init(glyph: GlyphID, baseline: Point) {
        self.glyph = glyph
        self.baseline = baseline
    }
}

@usableFromInline
package struct FillRectOperation: Equatable, Sendable {
    package let bounds: Rect
    package let clip: Rect
    package let color: Color

    @usableFromInline
    package init(bounds: Rect, clip: Rect, color: Color) {
        self.bounds = bounds
        self.clip = clip
        self.color = color
    }
}

@usableFromInline
package struct PositionedGlyphOperationHeader: Equatable, Sendable {
    package let instance: FontInstanceID
    package let clip: Rect
    package let color: Color
    package let glyphCount: UInt16

    @usableFromInline
    package init(
        instance: FontInstanceID,
        clip: Rect,
        color: Color,
        glyphCount: UInt16
    ) {
        self.instance = instance
        self.clip = clip
        self.color = color
        self.glyphCount = glyphCount
    }
}

@usableFromInline
package enum RenderProductionError: UInt8, Equatable, Sendable {
    case invalidInput = 0
    case arithmeticOverflow = 1
    case capacityExhausted = 2
    case incompatibleTextResource = 3
    case sinkRefused = 4
    case reentrancyViolation = 5
    case invariantViolation = 6
}
