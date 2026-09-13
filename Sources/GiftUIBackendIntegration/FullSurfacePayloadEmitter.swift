import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore

package enum FullSurfaceEmissionResult: Equatable, Sendable {
    case completed(responsibilityTransferred: Bool)
    case invalidGeometry
    case writerUnavailable
    case writerFailure
    case payloadTransfer(DisplayTransferResult)
    case frameEnd(DisplayTransferResult)
}

package enum FullSurfacePayloadEmitter {
    package static func finish<Surface, Target>(
        surface: inout Surface,
        header: RenderPlanHeader,
        reservation: DisplayReservationID,
        target: inout Target
    ) -> FullSurfaceEmissionResult
    where Surface: FullSurfaceReadableRaster, Target: DisplayTarget {
        guard header.surfaceBounds == surface.descriptor.bounds,
            contains(surface.descriptor.bounds, header.damageBounds)
        else { return .invalidGeometry }

        let damage = header.damageBounds
        guard damage.size.width > 0, damage.size.height > 0 else {
            return finishFrame(
                surface: &surface,
                reservation: reservation,
                target: &target,
                responsibilityTransferred: false
            )
        }

        let bytesPerPixel: UInt32 =
            surface.descriptor.encoding == .rgba8888
            ? 4
            : 2
        guard let pixelCount = UInt16(exactly: damage.size.width) else {
            return .invalidGeometry
        }
        let wrotePayload: Bool? = surface.withBytes { bytes in
            target.withWriter(for: reservation) { writer in
                var y = damage.minY
                while y < damage.maxY {
                    guard
                        writer.beginRegion(
                            origin: Point(x: damage.minX, y: y),
                            pixelCount: pixelCount,
                            encoding: surface.descriptor.encoding
                        )
                    else {
                        writer.discard()
                        return false
                    }
                    let rowOffset = UInt32(y).multipliedReportingOverflow(
                        by: surface.descriptor.bytesPerRow
                    )
                    let columnOffset = UInt32(damage.minX)
                        .multipliedReportingOverflow(by: bytesPerPixel)
                    guard !rowOffset.overflow, !columnOffset.overflow else {
                        writer.discard()
                        return false
                    }
                    let start = rowOffset.partialValue.addingReportingOverflow(
                        columnOffset.partialValue
                    )
                    let count = UInt32(pixelCount).multipliedReportingOverflow(
                        by: bytesPerPixel
                    )
                    guard !start.overflow, !count.overflow else {
                        writer.discard()
                        return false
                    }
                    let end = start.partialValue.addingReportingOverflow(
                        count.partialValue
                    )
                    guard let bufferCount = UInt32(exactly: bytes.count),
                        !end.overflow,
                        end.partialValue <= bufferCount
                    else {
                        writer.discard()
                        return false
                    }
                    var index = Int(start.partialValue)
                    while index < Int(end.partialValue) {
                        guard writer.write(byte: bytes[index]) else {
                            writer.discard()
                            return false
                        }
                        index += 1
                    }
                    guard writer.endRegion() else {
                        writer.discard()
                        return false
                    }
                    y += 1
                }
                guard writer.finish() else {
                    writer.discard()
                    return false
                }
                return true
            }
        }
        guard let wrotePayload else { return .writerUnavailable }
        guard wrotePayload else { return .writerFailure }

        let transfer = target.submitPayload(reservation)
        switch transfer {
        case .completed:
            guard surface.acceptPresentationResponsibility() else {
                return .payloadTransfer(
                    .failureAfterAcceptance(.invariantViolation)
                )
            }
            return finishFrame(
                surface: &surface,
                reservation: reservation,
                target: &target,
                responsibilityTransferred: true
            )
        case .failureBeforeAcceptance:
            return .payloadTransfer(transfer)
        case .failureAfterAcceptance:
            _ = surface.acceptPresentationResponsibility()
            _ = target.finishFrame(reservation)
            _ = surface.finishFrame()
            return .payloadTransfer(transfer)
        }
    }

    private static func finishFrame<Surface, Target>(
        surface: inout Surface,
        reservation: DisplayReservationID,
        target: inout Target,
        responsibilityTransferred: Bool
    ) -> FullSurfaceEmissionResult
    where Surface: FullSurfaceReadableRaster, Target: DisplayTarget {
        let result = target.finishFrame(reservation)
        switch result {
        case .completed:
            guard surface.finishFrame() else {
                return .frameEnd(.failureAfterAcceptance(.invariantViolation))
            }
            return .completed(
                responsibilityTransferred: responsibilityTransferred
            )
        case .failureBeforeAcceptance:
            return .frameEnd(result)
        case .failureAfterAcceptance:
            _ = surface.acceptPresentationResponsibility()
            _ = surface.finishFrame()
            return .frameEnd(result)
        }
    }

    private static func contains(_ outer: Rect, _ inner: Rect) -> Bool {
        inner.minX >= outer.minX && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX && inner.maxY <= outer.maxY
    }
}
