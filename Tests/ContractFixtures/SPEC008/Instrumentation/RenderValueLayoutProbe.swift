import GiftUI
import GiftUIRenderCore
import GiftUIRenderLowering

package enum RenderValueLayoutProbe {
    @inline(__always)
    private static func size<T>(of type: T.Type) -> UInt32 {
        UInt32(MemoryLayout<T>.size)
    }

    @inline(__always)
    private static func stride<T>(of type: T.Type) -> UInt32 {
        UInt32(MemoryLayout<T>.stride)
    }

    @inline(__always)
    private static func alignment<T>(of type: T.Type) -> UInt32 {
        UInt32(MemoryLayout<T>.alignment)
    }

    @inline(never) package static func colorSize() -> UInt32 { size(of: Color.self) }
    @inline(never) package static func colorStride() -> UInt32 { stride(of: Color.self) }
    @inline(never) package static func colorAlignment() -> UInt32 { alignment(of: Color.self) }

    @inline(never) package static func boundedTextSize() -> UInt32 {
        size(of: BoundedText.self)
    }
    @inline(never) package static func boundedTextStride() -> UInt32 {
        stride(of: BoundedText.self)
    }
    @inline(never) package static func boundedTextAlignment() -> UInt32 {
        alignment(of: BoundedText.self)
    }

    @inline(never) package static func renderLimitsSize() -> UInt32 {
        size(of: RenderLimits.self)
    }
    @inline(never) package static func renderLimitsStride() -> UInt32 {
        stride(of: RenderLimits.self)
    }
    @inline(never) package static func renderLimitsAlignment() -> UInt32 {
        alignment(of: RenderLimits.self)
    }

    @inline(never) package static func renderWorkspaceCapacitySize() -> UInt32 {
        size(of: RenderWorkspaceCapacity.self)
    }
    @inline(never) package static func renderWorkspaceCapacityStride() -> UInt32 {
        stride(of: RenderWorkspaceCapacity.self)
    }
    @inline(never) package static func renderWorkspaceCapacityAlignment() -> UInt32 {
        alignment(of: RenderWorkspaceCapacity.self)
    }

    @inline(never) package static func renderWorkspaceVisitSize() -> UInt32 {
        size(of: RenderWorkspaceVisit.self)
    }
    @inline(never) package static func renderWorkspaceVisitStride() -> UInt32 {
        stride(of: RenderWorkspaceVisit.self)
    }
    @inline(never) package static func renderWorkspaceVisitAlignment() -> UInt32 {
        alignment(of: RenderWorkspaceVisit.self)
    }

    @inline(never) package static func renderSinkCapacitySize() -> UInt32 {
        size(of: RenderSinkCapacity.self)
    }
    @inline(never) package static func renderSinkCapacityStride() -> UInt32 {
        stride(of: RenderSinkCapacity.self)
    }
    @inline(never) package static func renderSinkCapacityAlignment() -> UInt32 {
        alignment(of: RenderSinkCapacity.self)
    }

    @inline(never) package static func renderDamageModeSize() -> UInt32 {
        size(of: RenderDamageMode.self)
    }
    @inline(never) package static func renderDamageModeStride() -> UInt32 {
        stride(of: RenderDamageMode.self)
    }
    @inline(never) package static func renderDamageModeAlignment() -> UInt32 {
        alignment(of: RenderDamageMode.self)
    }

    @inline(never) package static func renderPlanHeaderSize() -> UInt32 {
        size(of: RenderPlanHeader.self)
    }
    @inline(never) package static func renderPlanHeaderStride() -> UInt32 {
        stride(of: RenderPlanHeader.self)
    }
    @inline(never) package static func renderPlanHeaderAlignment() -> UInt32 {
        alignment(of: RenderPlanHeader.self)
    }

    @inline(never) package static func positionedGlyphSize() -> UInt32 {
        size(of: PositionedGlyph.self)
    }
    @inline(never) package static func positionedGlyphStride() -> UInt32 {
        stride(of: PositionedGlyph.self)
    }
    @inline(never) package static func positionedGlyphAlignment() -> UInt32 {
        alignment(of: PositionedGlyph.self)
    }

    @inline(never) package static func fillRectOperationSize() -> UInt32 {
        size(of: FillRectOperation.self)
    }
    @inline(never) package static func fillRectOperationStride() -> UInt32 {
        stride(of: FillRectOperation.self)
    }
    @inline(never) package static func fillRectOperationAlignment() -> UInt32 {
        alignment(of: FillRectOperation.self)
    }

    @inline(never) package static func positionedGlyphHeaderSize() -> UInt32 {
        size(of: PositionedGlyphOperationHeader.self)
    }
    @inline(never) package static func positionedGlyphHeaderStride() -> UInt32 {
        stride(of: PositionedGlyphOperationHeader.self)
    }
    @inline(never) package static func positionedGlyphHeaderAlignment() -> UInt32 {
        alignment(of: PositionedGlyphOperationHeader.self)
    }

    @inline(never) package static func renderProductionErrorSize() -> UInt32 {
        size(of: RenderProductionError.self)
    }
    @inline(never) package static func renderProductionErrorStride() -> UInt32 {
        stride(of: RenderProductionError.self)
    }
    @inline(never) package static func renderProductionErrorAlignment() -> UInt32 {
        alignment(of: RenderProductionError.self)
    }

    @inline(never) package static func renderProductionResultSize() -> UInt32 {
        size(of: RenderProductionResult.self)
    }
    @inline(never) package static func renderProductionResultStride() -> UInt32 {
        stride(of: RenderProductionResult.self)
    }
    @inline(never) package static func renderProductionResultAlignment() -> UInt32 {
        alignment(of: RenderProductionResult.self)
    }
}
