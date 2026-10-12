import GiftUI
import GiftUITextResources

package struct RenderSinkCapacity: Equatable, Sendable {
    package let maximumOperations: UInt16
    package let maximumPositionedGlyphs: UInt16

    package init(
        maximumOperations: UInt16,
        maximumPositionedGlyphs: UInt16
    ) {
        self.maximumOperations = maximumOperations
        self.maximumPositionedGlyphs = maximumPositionedGlyphs
    }
}

package enum RenderDamageMode: UInt8, Equatable, Sendable {
    case rootIntersection = 0
    case initializeCompleteSurface = 1
}

package struct RenderPlanHeader: Equatable, Sendable {
    package let surfaceBounds: Rect
    package let damageBounds: Rect
    package let operationCount: UInt16
    package let positionedGlyphCount: UInt16
    package let maximumObservedClipDepth: UInt16

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

package struct PositionedGlyph: Equatable, Sendable {
    package let glyph: GlyphID
    package let baseline: Point

    package init(glyph: GlyphID, baseline: Point) {
        self.glyph = glyph
        self.baseline = baseline
    }
}

package struct FillRectOperation: Equatable, Sendable {
    package let bounds: Rect
    package let clip: Rect
    package let color: Color

    package init(bounds: Rect, clip: Rect, color: Color) {
        self.bounds = bounds
        self.clip = clip
        self.color = color
    }
}

package struct PositionedGlyphOperationHeader: Equatable, Sendable {
    package let instance: FontInstanceID
    package let clip: Rect
    package let color: Color
    package let glyphCount: UInt16

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

package enum RenderProductionError: UInt8, Equatable, Sendable {
    case invalidInput = 0
    case arithmeticOverflow = 1
    case capacityExhausted = 2
    case incompatibleTextResource = 3
    case sinkRefused = 4
    case reentrancyViolation = 5
    case invariantViolation = 6
}
