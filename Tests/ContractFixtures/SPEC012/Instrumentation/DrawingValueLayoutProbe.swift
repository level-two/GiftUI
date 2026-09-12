import GiftUIDrawing
import GiftUIRenderCore

package enum DrawingValueLayoutProbe {
    @inline(__always)
    private static func size<T>(of _: T.Type) -> UInt32 {
        UInt32(MemoryLayout<T>.size)
    }

    @inline(__always)
    private static func stride<T>(of _: T.Type) -> UInt32 {
        UInt32(MemoryLayout<T>.stride)
    }

    @inline(__always)
    private static func alignment<T>(of _: T.Type) -> UInt32 {
        UInt32(MemoryLayout<T>.alignment)
    }

    @inline(never) package static func drawingLimitsSize() -> UInt32 {
        size(of: DrawingLimits.self)
    }
    @inline(never) package static func drawingLimitsStride() -> UInt32 {
        stride(of: DrawingLimits.self)
    }
    @inline(never) package static func drawingLimitsAlignment() -> UInt32 {
        alignment(of: DrawingLimits.self)
    }

    @inline(never) package static func staticCanvasLimitsSize() -> UInt32 {
        size(of: StaticCanvasLimits.self)
    }
    @inline(never) package static func staticCanvasLimitsStride() -> UInt32 {
        stride(of: StaticCanvasLimits.self)
    }
    @inline(never) package static func staticCanvasLimitsAlignment() -> UInt32 {
        alignment(of: StaticCanvasLimits.self)
    }

    @inline(never) package static func subpathRangeSize() -> UInt32 {
        size(of: SubpathRange.self)
    }
    @inline(never) package static func subpathRangeStride() -> UInt32 {
        stride(of: SubpathRange.self)
    }
    @inline(never) package static func subpathRangeAlignment() -> UInt32 {
        alignment(of: SubpathRange.self)
    }

    @inline(never) package static func drawingPlanSummarySize() -> UInt32 {
        size(of: DrawingPlanSummary.self)
    }
    @inline(never) package static func drawingPlanSummaryStride() -> UInt32 {
        stride(of: DrawingPlanSummary.self)
    }
    @inline(never) package static func drawingPlanSummaryAlignment() -> UInt32 {
        alignment(of: DrawingPlanSummary.self)
    }

    @inline(never) package static func straightLineStrokeHeaderSize() -> UInt32 {
        size(of: StraightLineStrokeHeader.self)
    }
    @inline(never) package static func straightLineStrokeHeaderStride() -> UInt32 {
        stride(of: StraightLineStrokeHeader.self)
    }
    @inline(never) package static func straightLineStrokeHeaderAlignment() -> UInt32 {
        alignment(of: StraightLineStrokeHeader.self)
    }

    @inline(never) package static func drawingProductionErrorSize() -> UInt32 {
        size(of: DrawingProductionError.self)
    }
    @inline(never) package static func drawingProductionErrorStride() -> UInt32 {
        stride(of: DrawingProductionError.self)
    }
    @inline(never) package static func drawingProductionErrorAlignment() -> UInt32 {
        alignment(of: DrawingProductionError.self)
    }

    @inline(never) package static func drawingPlanResultSize() -> UInt32 {
        size(of: DrawingPlanResult.self)
    }
    @inline(never) package static func drawingPlanResultStride() -> UInt32 {
        stride(of: DrawingPlanResult.self)
    }
    @inline(never) package static func drawingPlanResultAlignment() -> UInt32 {
        alignment(of: DrawingPlanResult.self)
    }
}
