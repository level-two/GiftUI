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

package enum TileFrameCompletionResult: Equatable, Sendable {
    case completed(responsibilityTransferred: Bool)
    case frameEnd(DisplayTransferResult)
}

private enum TileWriterFillResult {
    case empty
    case payload(bytes: UInt32, regions: UInt16, finishedTile: Bool)
    case writerFailure
    case workFailure(RasterBackendError)
    case arithmeticOverflow
}

package enum RGB565TilePayloadEmitter {
    package static func finish<Target>(
        reservation: DisplayReservationID,
        target: inout Target,
        work: inout RasterWorkTracker
    ) -> TileFrameCompletionResult where Target: DisplayTarget {
        let result = target.finishFrame(reservation)
        switch result {
        case .completed:
            return .completed(
                responsibilityTransferred: work.presentationResponsibilityAccepted
            )
        case .failureBeforeAcceptance:
            _ = work.recordFailure(.displayFailure)
            if work.presentationResponsibilityAccepted {
                return .frameEnd(
                    .failureAfterAcceptance(.invariantViolation)
                )
            }
            return .frameEnd(result)
        case .failureAfterAcceptance:
            work.acceptPresentationResponsibility()
            _ = work.recordFailure(.displayFailure)
            return .frameEnd(result)
        }
    }

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
        let scanEnd = workspace.lastAffectedPixel.map { $0 + 1 } ?? 0
        var cursor = workspace.firstAffectedPixel ?? 0
        if work.isDraining {
            return drain(
                workspace,
                pixelCapacity: scanEnd,
                cursor: &cursor,
                work: &work
            )
        }
        var totalPayloads: UInt32 = 0
        var totalRegions: UInt32 = 0
        var totalBytes: UInt32 = 0

        while cursor < scanEnd {
            let fill: TileWriterFillResult? = target.withWriter(
                for: reservation
            ) { writer in
                fillWriter(
                    &workspace,
                    tile: tile,
                    pixelCapacity: scanEnd,
                    cursor: &cursor,
                    writer: &writer,
                    work: &work
                )
            }
            guard let fill else { return .writerUnavailable }
            switch fill {
            case .empty:
                cursor = scanEnd
            case .writerFailure:
                return .writerFailure
            case .workFailure(let error):
                return .workFailure(error)
            case .arithmeticOverflow:
                return .arithmeticOverflow
            case .payload(let bytes, let regions, _):
                guard let payloads = add(totalPayloads, 1),
                    let regionCount = add(totalRegions, UInt32(regions)),
                    let byteCount = add(totalBytes, bytes)
                else { return .arithmeticOverflow }
                totalPayloads = payloads
                totalRegions = regionCount
                totalBytes = byteCount
                let transfer = target.submitPayload(reservation)
                switch transfer {
                case .completed:
                    work.acceptPresentationResponsibility()
                case .failureBeforeAcceptance:
                    _ = work.recordFailure(.displayFailure)
                    if work.presentationResponsibilityAccepted {
                        return drain(
                            workspace,
                            pixelCapacity: scanEnd,
                            cursor: &cursor,
                            work: &work,
                            initialPayloads: totalPayloads,
                            initialRegions: totalRegions,
                            initialBytes: totalBytes
                        )
                    }
                    return .payloadTransfer(transfer)
                case .failureAfterAcceptance:
                    work.acceptPresentationResponsibility()
                    _ = work.recordFailure(.displayFailure)
                    return drain(
                        workspace,
                        pixelCapacity: scanEnd,
                        cursor: &cursor,
                        work: &work,
                        initialPayloads: totalPayloads,
                        initialRegions: totalRegions,
                        initialBytes: totalBytes
                    )
                }
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

    private static func drain<Storage>(
        _ workspace: borrowing RGB565TileWorkspace<Storage>,
        pixelCapacity: UInt32,
        cursor: inout UInt32,
        work: inout RasterWorkTracker,
        initialPayloads: UInt32 = 0,
        initialRegions: UInt32 = 0,
        initialBytes: UInt32 = 0
    ) -> TilePayloadEmissionResult where Storage: RGB565TileStorage {
        var totalPayloads = initialPayloads
        var totalRegions = initialRegions
        var totalBytes = initialBytes
        var payloadBytes: UInt32 = 0
        var payloadRegions: UInt16 = 0
        let width = UInt32(workspace.descriptor.regionWidth)

        while cursor < pixelCapacity {
            guard
                let run = workspace.storage.nextAffectedRun(
                    startingAt: cursor,
                    before: pixelCapacity,
                    rowWidth: width
                )
            else { break }
            let row = run.lowerBound / width
            let startX = run.lowerBound % width
            let endX = run.upperBound - row * width
            let runBytes = (endX - startX).multipliedReportingOverflow(by: 2)
            guard !runBytes.overflow,
                runBytes.partialValue <= work.limits.maximumPayloadBytes
            else {
                _ = work.recordFailure(.capacityExhausted)
                cursor = row * width + endX
                continue
            }
            let nextBytes = payloadBytes.addingReportingOverflow(
                runBytes.partialValue
            )
            if nextBytes.overflow
                || nextBytes.partialValue > work.limits.maximumPayloadBytes
                || payloadRegions == work.limits.maximumRegionsPerPayload
            {
                guard
                    let updated = recordDrainedPayload(
                        bytes: payloadBytes,
                        regions: payloadRegions,
                        totals: (totalPayloads, totalRegions, totalBytes),
                        work: &work
                    )
                else { return .arithmeticOverflow }
                (totalPayloads, totalRegions, totalBytes) = updated
                payloadBytes = 0
                payloadRegions = 0
            }
            payloadBytes += runBytes.partialValue
            payloadRegions += 1
            cursor = run.upperBound
        }
        if payloadRegions > 0 {
            guard
                let updated = recordDrainedPayload(
                    bytes: payloadBytes,
                    regions: payloadRegions,
                    totals: (totalPayloads, totalRegions, totalBytes),
                    work: &work
                )
            else { return .arithmeticOverflow }
            (totalPayloads, totalRegions, totalBytes) = updated
        }
        return .completed(
            TilePayloadEmissionSummary(
                payloads: totalPayloads,
                regions: totalRegions,
                bytes: totalBytes,
                responsibilityTransferred: true
            )
        )
    }

    private static func recordDrainedPayload(
        bytes: UInt32,
        regions: UInt16,
        totals: (UInt32, UInt32, UInt32),
        work: inout RasterWorkTracker
    ) -> (UInt32, UInt32, UInt32)? {
        _ = work.recordPayload(bytes: bytes, regions: regions)
        _ = work.recordInFlight(payloads: 1, bytes: bytes)
        guard let payloads = add(totals.0, 1),
            let regionCount = add(totals.1, UInt32(regions)),
            let byteCount = add(totals.2, bytes)
        else { return nil }
        return (payloads, regionCount, byteCount)
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
            let width = UInt32(workspace.descriptor.regionWidth)
            guard
                let run = workspace.storage.nextAffectedRun(
                    startingAt: cursor,
                    before: pixelCapacity,
                    rowWidth: width
                )
            else {
                if !wroteRegion { return .empty }
                return finishWriter(&writer, finishedTile: true, work: &work)
            }
            let row = run.lowerBound / width
            let startX = run.lowerBound % width
            let endX = run.upperBound - row * width
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
            let rowOffset = row.multipliedReportingOverflow(
                by: workspace.descriptor.bytesPerRow
            )
            let columnOffset = startX.multipliedReportingOverflow(by: 2)
            let byteOffset = rowOffset.partialValue.addingReportingOverflow(
                columnOffset.partialValue
            )
            let lastByteOffset = byteOffset.partialValue.addingReportingOverflow(
                runBytes.partialValue - 1
            )
            guard !rowOffset.overflow, !columnOffset.overflow,
                !byteOffset.overflow, !lastByteOffset.overflow
            else {
                writer.discard()
                return .arithmeticOverflow
            }
            var x = startX
            while x < endX {
                let offset = byteOffset.partialValue + (x - startX) * 2
                guard let (byte0, byte1) = workspace.storage.pixelBytes(at: offset),
                    writer.writePixel(
                        mostSignificantByte: byte0,
                        leastSignificantByte: byte1
                    )
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
            cursor = run.upperBound
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
