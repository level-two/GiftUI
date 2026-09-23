#if GIFTUI_NRF_EMBEDDED
    package struct StaticSignalAnalyzerNRFEmbeddedTileRunSummary:
        Equatable, Sendable
    {
        package let runCount: UInt32
        package let byteCount: UInt32
    }

    /// Emits each affected horizontal run while the raster tile is borrowed.
    /// The callback must consume its payload synchronously.
    package enum StaticSignalAnalyzerNRFEmbeddedTileRuns {
        package static func emit(
            _ tile: borrowing RGB565TileWorkspace<StaticSignalAnalyzerNRFTileStorage>,
            _ consume: (
                UInt16, UInt16, UInt16, UnsafeRawBufferPointer
            ) -> Bool
        ) -> StaticSignalAnalyzerNRFEmbeddedTileRunSummary? {
            guard let bounds = tile.activeTile,
                bounds.minX == 0, bounds.size.width == 480,
                bounds.minY >= 0, bounds.maxY <= 320
            else { return nil }
            var runs: UInt32 = 0
            var bytes: UInt32 = 0
            var row: UInt32 = 0
            while row < UInt32(bounds.size.height) {
                var column: UInt32 = 0
                while column < 480 {
                    let pixelIndex = row * 480 + column
                    if !tile.storage.isAffected(pixelIndex: pixelIndex) {
                        column += 1
                        continue
                    }
                    let start = column
                    column += 1
                    while column < 480 {
                        guard
                            tile.storage.isAffected(
                                pixelIndex: row * 480 + column
                            )
                        else { break }
                        column += 1
                    }
                    let pixelCount = column - start
                    let byteCount = pixelCount * 2
                    let offset = row * 960 + start * 2
                    guard
                        let accepted = tile.storage.withBorrowedRun(
                            byteOffset: offset, byteCount: byteCount,
                            { borrowed in
                                consume(
                                    UInt16(start), UInt16(UInt32(bounds.minY) + row),
                                    UInt16(pixelCount), borrowed
                                )
                            }
                        ), accepted
                    else { return nil }
                    let nextRuns = runs.addingReportingOverflow(1)
                    let nextBytes = bytes.addingReportingOverflow(byteCount)
                    guard !nextRuns.overflow, !nextBytes.overflow else {
                        return nil
                    }
                    runs = nextRuns.partialValue
                    bytes = nextBytes.partialValue
                }
                row += 1
            }
            return StaticSignalAnalyzerNRFEmbeddedTileRunSummary(
                runCount: runs, byteCount: bytes
            )
        }
    }
#endif
