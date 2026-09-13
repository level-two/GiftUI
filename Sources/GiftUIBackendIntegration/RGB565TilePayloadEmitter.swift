import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIRasterCore
import GiftUISurfaceCore

package struct TilePayloadEmissionSummary: Equatable, Sendable {
    package let payloads: UInt32
    package let regions: UInt32
    package let bytes: UInt32
    package let responsibilityTransferred: Bool
}

package enum TilePayloadEmissionResult: Equatable, Sendable {
    case completed(TilePayloadEmissionSummary)
    case inactiveWorkspace
    case writerUnavailable
    case writerFailure
    case workFailure(RasterBackendError)
    case payloadTransfer(DisplayTransferResult)
    case arithmeticOverflow
}

private enum TileWriterFillResult {
    case empty
    case payload(bytes: UInt32, regions: UInt16, finishedTile: Bool)
    case writerFailure
    case workFailure(RasterBackendError)
    case arithmeticOverflow
}

package enum RGB565TilePayloadEmitter {
    package static func submit<Storage, Target>(
        _ workspace: inout RGB565TileWorkspace<Storage>,
        reservation: DisplayReservationID,
        target: inout Target,
        work: inout RasterWorkTracker
    ) -> TilePayloadEmissionResult
    where Storage: RGB565TileStorage, Target: DisplayTarget {
        guard let tile = workspace.activeTile else { return .inactiveWorkspace }
        let rasterBytes = workspace.descriptor.bytesPerRow
            .multipliedReportingOverflow(by: UInt32(tile.size.height))
        guard !rasterBytes.overflow else { return .arithmeticOverflow }
        guard work.observeRasterBytes(rasterBytes.partialValue),
            work.recordTileVisits()
        else {
            return .workFailure(work.failure ?? .invariantViolation)
        }

        let pixelCapacity = UInt32(workspace.descriptor.regionWidth)
            .multipliedReportingOverflow(by: UInt32(tile.size.height))
        guard !pixelCapacity.overflow else { return .arithmeticOverflow }
        var cursor: UInt32 = 0
        var totalPayloads: UInt32 = 0
        var totalRegions: UInt32 = 0
        var totalBytes: UInt32 = 0

        while cursor < pixelCapacity.partialValue {
            let fill: TileWriterFillResult? = target.withWriter(
                for: reservation
            ) { writer in
                fillWriter(
                    &workspace,
                    tile: tile,
                    pixelCapacity: pixelCapacity.partialValue,
                    cursor: &cursor,
                    writer: &writer,
                    work: &work
                )
            }
            guard let fill else { return .writerUnavailable }
            switch fill {
            case .empty:
                cursor = pixelCapacity.partialValue
            case .writerFailure:
                return .writerFailure
            case .workFailure(let error):
                return .workFailure(error)
            case .arithmeticOverflow:
                return .arithmeticOverflow
            case .payload(let bytes, let regions, _):
                let transfer = target.submitPayload(reservation)
                switch transfer {
                case .completed:
                    work.acceptPresentationResponsibility()
                case .failureBeforeAcceptance:
                    return .payloadTransfer(transfer)
                case .failureAfterAcceptance:
                    work.acceptPresentationResponsibility()
                    return .payloadTransfer(transfer)
                }
                guard let payloads = add(totalPayloads, 1),
                    let regionCount = add(totalRegions, UInt32(regions)),
                    let byteCount = add(totalBytes, bytes)
                else { return .arithmeticOverflow }
                totalPayloads = payloads
                totalRegions = regionCount
                totalBytes = byteCount
            }
        }
        return .completed(
            TilePayloadEmissionSummary(
                payloads: totalPayloads,
                regions: totalRegions,
                bytes: totalBytes,
                responsibilityTransferred: work.presentationResponsibilityAccepted
            )
        )
    }

    private static func fillWriter<Storage, Writer>(
        _ workspace: inout RGB565TileWorkspace<Storage>,
        tile: Rect,
        pixelCapacity: UInt32,
        cursor: inout UInt32,
        writer: inout Writer,
        work: inout RasterWorkTracker
    ) -> TileWriterFillResult
    where Storage: RGB565TileStorage, Writer: DisplayPayloadWriter {
        var wroteRegion = false
        while cursor < pixelCapacity {
            while cursor < pixelCapacity,
                !workspace.storage.isAffected(pixelIndex: cursor)
            {
                cursor += 1
            }
            guard cursor < pixelCapacity else {
                if !wroteRegion { return .empty }
                return finishWriter(&writer, finishedTile: true, work: &work)
            }

            let width = UInt32(workspace.descriptor.regionWidth)
            let row = cursor / width
            let startX = cursor % width
            var endX = startX + 1
            while endX < width,
                workspace.storage.isAffected(pixelIndex: row * width + endX)
            {
                endX += 1
            }
            let runPixels = endX - startX
            let runBytes = runPixels.multipliedReportingOverflow(by: 2)
            guard !runBytes.overflow,
                let pixelCount = UInt16(exactly: runPixels)
            else {
                writer.discard()
                return .arithmeticOverflow
            }
            let remainingBytes = writer.capacityBytes.subtractingReportingOverflow(
                writer.writtenBytes
            )
            guard !remainingBytes.overflow else {
                writer.discard()
                return .writerFailure
            }
            let hasRegionCapacity = writer.writtenRegionCount < writer.regionCapacity
            if runBytes.partialValue > remainingBytes.partialValue
                || !hasRegionCapacity
            {
                guard wroteRegion else {
                    writer.discard()
                    return .writerFailure
                }
                return finishWriter(&writer, finishedTile: false, work: &work)
            }

            let originX = Int32(startX).addingReportingOverflow(tile.minX)
            let originY = Int32(row).addingReportingOverflow(tile.minY)
            guard !originX.overflow, !originY.overflow,
                writer.beginRegion(
                    origin: Point(
                        x: originX.partialValue,
                        y: originY.partialValue
                    ),
                    pixelCount: pixelCount,
                    encoding: .rgb565BigEndian
                )
            else {
                writer.discard()
                return .writerFailure
            }
            var x = startX
            while x < endX {
                let rowOffset = row.multipliedReportingOverflow(
                    by: workspace.descriptor.bytesPerRow
                )
                let columnOffset = x.multipliedReportingOverflow(by: 2)
                guard !rowOffset.overflow, !columnOffset.overflow else {
                    writer.discard()
                    return .arithmeticOverflow
                }
                let offset = rowOffset.partialValue.addingReportingOverflow(
                    columnOffset.partialValue
                )
                let nextOffset = offset.partialValue.addingReportingOverflow(1)
                guard !offset.overflow,
                    !nextOffset.overflow,
                    let byte0 = workspace.storage.byte(at: offset.partialValue),
                    let byte1 = workspace.storage.byte(
                        at: nextOffset.partialValue
                    ),
                    writer.write(byte: byte0),
                    writer.write(byte: byte1)
                else {
                    writer.discard()
                    return .writerFailure
                }
                x += 1
            }
            guard writer.endRegion() else {
                writer.discard()
                return .writerFailure
            }
            wroteRegion = true
            cursor = row * width + endX
        }
        return finishWriter(&writer, finishedTile: true, work: &work)
    }

    private static func finishWriter<Writer>(
        _ writer: inout Writer,
        finishedTile: Bool,
        work: inout RasterWorkTracker
    ) -> TileWriterFillResult where Writer: DisplayPayloadWriter {
        let bytes = writer.writtenBytes
        let regions = writer.writtenRegionCount
        guard work.recordPayload(bytes: bytes, regions: regions),
            work.recordInFlight(payloads: 1, bytes: bytes)
        else {
            writer.discard()
            return .workFailure(work.failure ?? .invariantViolation)
        }
        guard writer.finish() else {
            writer.discard()
            return .writerFailure
        }
        return .payload(
            bytes: bytes,
            regions: regions,
            finishedTile: finishedTile
        )
    }

    private static func add(_ lhs: UInt32, _ rhs: UInt32) -> UInt32? {
        let result = lhs.addingReportingOverflow(rhs)
        return result.overflow ? nil : result.partialValue
    }
}
