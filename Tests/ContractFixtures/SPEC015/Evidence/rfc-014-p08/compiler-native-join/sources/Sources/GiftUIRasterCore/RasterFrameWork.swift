import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import GiftUISurfaceCore

package struct RasterFrameWorkBounds: Equatable, Sendable {
    package let damagedRows: UInt32
    package let damagedPixels: UInt32
    package let tileRows: UInt32
    package let tileVisits: UInt32
    package let regionSubmissions: UInt32
}

package enum RasterFrameWorkCalculation: Equatable, Sendable {
    case admitted(RasterFrameWorkBounds)
    case arithmeticOverflow
    case capacityExceeded
    case invalidHeader
}

package enum RasterFrameWorkCalculator {
    package static func constructionBounds(
        descriptor: RasterSurfaceDescriptor,
        sinkCapacity: RenderSinkCapacity,
        limits: RasterPayloadLimits
    ) -> RasterFrameWorkCalculation {
        calculate(
            damageWidth: UInt32(descriptor.capabilityExtent.width),
            damageHeight: UInt32(descriptor.capabilityExtent.height),
            operationCount: UInt32(sinkCapacity.maximumOperations),
            regionHeight: UInt32(descriptor.regionHeight),
            limits: limits
        )
    }

    package static func headerBounds(
        _ header: RenderPlanHeader,
        descriptor: RasterSurfaceDescriptor,
        sinkCapacity: RenderSinkCapacity,
        limits: RasterPayloadLimits
    ) -> RasterFrameWorkCalculation {
        guard header.surfaceBounds == descriptor.bounds,
            contains(descriptor.bounds, header.damageBounds),
            header.operationCount <= sinkCapacity.maximumOperations,
            header.positionedGlyphCount <= sinkCapacity.maximumPositionedGlyphs
        else {
            return .invalidHeader
        }

        return calculate(
            damageWidth: UInt32(header.damageBounds.size.width),
            damageHeight: UInt32(header.damageBounds.size.height),
            operationCount: UInt32(header.operationCount),
            regionHeight: UInt32(descriptor.regionHeight),
            limits: limits
        )
    }

    package static func calculate(
        damageWidth: UInt32,
        damageHeight: UInt32,
        operationCount: UInt32,
        regionHeight: UInt32,
        limits: RasterPayloadLimits
    ) -> RasterFrameWorkCalculation {
        guard damageWidth > 0, damageHeight > 0 else {
            return .admitted(
                RasterFrameWorkBounds(
                    damagedRows: 0,
                    damagedPixels: 0,
                    tileRows: 0,
                    tileVisits: 0,
                    regionSubmissions: 0
                )
            )
        }
        guard regionHeight > 0 else { return .invalidHeader }

        let damagedPixels = damageWidth.multipliedReportingOverflow(by: damageHeight)
        guard !damagedPixels.overflow else { return .arithmeticOverflow }

        let rowsForCeiling = damageHeight.addingReportingOverflow(regionHeight - 1)
        guard !rowsForCeiling.overflow else { return .arithmeticOverflow }
        let tileRows = rowsForCeiling.partialValue / regionHeight

        let tileVisits = operationCount.multipliedReportingOverflow(by: tileRows)
        guard !tileVisits.overflow else { return .arithmeticOverflow }

        let regionSubmissions = operationCount.multipliedReportingOverflow(
            by: damagedPixels.partialValue
        )
        guard !regionSubmissions.overflow else { return .arithmeticOverflow }

        guard limits.admitsTileVisits(tileVisits.partialValue),
            limits.admitsRegionSubmissions(regionSubmissions.partialValue)
        else {
            return .capacityExceeded
        }

        return .admitted(
            RasterFrameWorkBounds(
                damagedRows: damageHeight,
                damagedPixels: damagedPixels.partialValue,
                tileRows: tileRows,
                tileVisits: tileVisits.partialValue,
                regionSubmissions: regionSubmissions.partialValue
            )
        )
    }

    private static func contains(_ outer: Rect, _ inner: Rect) -> Bool {
        inner.minX >= outer.minX && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX && inner.maxY <= outer.maxY
    }
}
