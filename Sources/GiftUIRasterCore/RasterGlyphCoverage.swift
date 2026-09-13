import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUITextResources

package enum RasterGlyphResult: Equatable, Sendable {
    case completed(pixelCount: UInt32, payloadBytes: UInt32)
    case incompatibleResource
    case invalidGeometry
    case arithmeticOverflow
    case replacementRefused
}

package enum RasterGlyphCoverage {
    package static func rasterize<
        Metrics: CanonicalTextMetricsView,
        Raster: TextRasterResourceView
    >(
        _ glyph: PositionedGlyph,
        operation: PositionedGlyphOperationHeader,
        metrics: borrowing Metrics,
        raster: borrowing Raster,
        realization: RasterRealizationDescriptor,
        descriptor: RasterSurfaceDescriptor,
        damageBounds: Rect,
        _ replace: (Point, CanonicalEncodedPixel) -> Bool
    ) -> RasterGlyphResult {
        guard operation.instance == realization.instance,
            metrics.descriptor == raster.descriptor,
            metrics.descriptor.resource == operation.instance.resource,
            operation.instance.instanceIndex < metrics.descriptor.instanceCount,
            realization.id.rawValue < metrics.descriptor.realizationCount,
            let glyphMetrics = metrics.metrics(
                for: glyph.glyph,
                in: operation.instance
            ),
            glyph.glyph.rawValue < realization.glyphCount,
            let record = raster.record(
                for: glyph.glyph,
                realization: realization.id
            ),
            record.glyph == glyph.glyph,
            record.pixelWidth == UInt16(exactly: glyphMetrics.inkSize.width),
            record.pixelHeight == UInt16(exactly: glyphMetrics.inkSize.height),
            realization.kind == .monochromeBitmap1
        else {
            return .incompatibleResource
        }

        let payloadEnd = record.offset.addingReportingOverflow(record.byteCount)
        let expectedRowBytes = (UInt32(record.pixelWidth) + 7) / 8
        let expectedBytes = expectedRowBytes.multipliedReportingOverflow(
            by: UInt32(record.pixelHeight)
        )
        guard !payloadEnd.overflow,
            payloadEnd.partialValue <= realization.payloadByteCount,
            !expectedBytes.overflow,
            UInt32(record.rowByteCount) == expectedRowBytes,
            record.byteCount == expectedBytes.partialValue
        else {
            return .incompatibleResource
        }

        let originX = glyph.baseline.x.addingReportingOverflow(
            glyphMetrics.offsetX
        )
        let originY = glyph.baseline.y.addingReportingOverflow(
            glyphMetrics.offsetY
        )
        guard !originX.overflow, !originY.overflow,
            let inkBounds = Rect(
                origin: Point(
                    x: originX.partialValue,
                    y: originY.partialValue
                ),
                size: glyphMetrics.inkSize
            )
        else {
            return .invalidGeometry
        }
        guard contains(descriptor.bounds, damageBounds) else {
            return .invalidGeometry
        }
        guard
            let covered = RasterFillCoverage.intersection(
                inkBounds,
                operation.clip,
                damageBounds,
                descriptor.bounds
            )
        else {
            return .arithmeticOverflow
        }
        guard covered.size.width > 0, covered.size.height > 0 else {
            return .completed(pixelCount: 0, payloadBytes: 0)
        }

        let result: RasterGlyphResult? = raster.withPayload(
            for: record,
            realization: realization.id
        ) { bytes in
            guard bytes.count == Int(record.byteCount) else {
                return .incompatibleResource
            }
            return replaceCoveredBitmap(
                covered,
                inkOrigin: inkBounds.origin,
                record: record,
                bytes: bytes,
                color: operation.color,
                encoding: descriptor.encoding,
                replace
            )
        }
        return result ?? .incompatibleResource
    }

    private static func replaceCoveredBitmap(
        _ covered: Rect,
        inkOrigin: Point,
        record: GlyphRasterRecord,
        bytes: UnsafeRawBufferPointer,
        color: Color,
        encoding: CanonicalPixelEncoding,
        _ replace: (Point, CanonicalEncodedPixel) -> Bool
    ) -> RasterGlyphResult {
        let startX = covered.minX.subtractingReportingOverflow(inkOrigin.x)
        let startY = covered.minY.subtractingReportingOverflow(inkOrigin.y)
        guard !startX.overflow, !startY.overflow,
            let glyphStartX = UInt16(exactly: startX.partialValue),
            let glyphStartY = UInt16(exactly: startY.partialValue)
        else {
            return .arithmeticOverflow
        }
        let pixel = CanonicalEncodedPixel(color: color, encoding: encoding)
        var replaced: UInt32 = 0
        var absoluteY = covered.minY
        var glyphY = glyphStartY
        while absoluteY < covered.maxY {
            var absoluteX = covered.minX
            var glyphX = glyphStartX
            while absoluteX < covered.maxX {
                let byteIndex =
                    UInt32(glyphY) * UInt32(record.rowByteCount)
                    + UInt32(glyphX / 8)
                let mask = UInt8(0x80 >> UInt8(glyphX & 7))
                if bytes[Int(byteIndex)] & mask != 0 {
                    guard
                        replace(
                            Point(x: absoluteX, y: absoluteY),
                            pixel
                        )
                    else {
                        return .replacementRefused
                    }
                    let next = replaced.addingReportingOverflow(1)
                    guard !next.overflow else { return .arithmeticOverflow }
                    replaced = next.partialValue
                }
                absoluteX += 1
                glyphX += 1
            }
            absoluteY += 1
            glyphY += 1
        }
        return .completed(
            pixelCount: replaced,
            payloadBytes: record.byteCount
        )
    }

    private static func contains(_ outer: Rect, _ inner: Rect) -> Bool {
        inner.minX >= outer.minX && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX && inner.maxY <= outer.maxY
    }
}
