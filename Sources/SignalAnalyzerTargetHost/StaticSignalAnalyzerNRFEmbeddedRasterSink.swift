#if GIFTUI_NRF_EMBEDDED
    /// Rasterizes the shared operation stream into the one caller-owned tile.
    /// The tile consumer currently records bounded visits; the display join
    /// will replace that consumer with synchronous RGB565 submission.
    package struct StaticSignalAnalyzerNRFEmbeddedRasterSink: DrawingOperationSink {
        package var capacity: RenderSinkCapacity { counts.capacity }
        package private(set) var paintedPixels: UInt32 = 0
        package private(set) var tileVisits: UInt32 = 0
        package private(set) var isFinished = false

        private var counts = StaticSignalAnalyzerNRFEmbeddedCountingSink()
        private var tile: RGB565TileWorkspace<StaticSignalAnalyzerNRFTileStorage>
        private var header: RenderPlanHeader?
        private var glyphHeader: PositionedGlyphOperationHeader?
        private let metrics = StaticSignalAnalyzerNRFEmbeddedFontMetrics()
        private let raster = StaticSignalAnalyzerNRFEmbeddedFontRaster()
        private let realization: RasterRealizationDescriptor

        package init?(
            rasterRegion: UnsafeMutableRawBufferPointer,
            coverageRegion: UnsafeMutableRawBufferPointer
        ) {
            guard
                let bounds = Rect(
                    origin: Point(x: 0, y: 0),
                    size: Size(width: 480, height: 320)!
                ),
                let descriptor = RasterSurfaceDescriptor(
                    bounds: bounds, encoding: .rgb565BigEndian,
                    bytesPerRow: 960, realization: .tiled,
                    regionWidth: 480, regionHeight: 4
                ),
                let storage = StaticSignalAnalyzerNRFTileStorage(
                    region: rasterRegion, coverage: coverageRegion
                ),
                let tile = RGB565TileWorkspace(
                    descriptor: descriptor, storage: storage
                ),
                let realization = StaticSignalAnalyzerNRFEmbeddedFontRaster()
                    .realization(at: 0)
            else { return nil }
            self.tile = tile
            self.realization = realization
        }

        package mutating func begin(_ header: RenderPlanHeader) -> Bool {
            guard header.surfaceBounds == tile.descriptor.bounds,
                counts.begin(header)
            else { return false }
            self.header = header
            return true
        }

        package mutating func fillRect(_ operation: FillRectOperation) -> Bool {
            guard let header else { return false }
            var workspace = tile
            var pixels = paintedPixels
            var visits = tileVisits
            let descriptor = workspace.descriptor
            let result = OperationMajorTileTraversal.visit(
                operationClip: operation.clip,
                damageBounds: header.damageBounds,
                workspace: &workspace,
                { damage, replace in
                    switch RasterFillCoverage.rasterize(
                        operation, descriptor: descriptor,
                        damageBounds: damage, replace
                    ) {
                    case .completed(let count):
                        let next = pixels.addingReportingOverflow(count)
                        guard !next.overflow else { return false }
                        pixels = next.partialValue
                        return true
                    default: return false
                    }
                },
                { _ in
                    let next = visits.addingReportingOverflow(1)
                    guard !next.overflow else { return false }
                    visits = next.partialValue
                    return true
                }
            )
            guard case .completed = result, counts.fillRect(operation) else {
                return false
            }
            tile = workspace
            paintedPixels = pixels
            tileVisits = visits
            return true
        }

        package mutating func beginPositionedGlyphs(
            _ operation: PositionedGlyphOperationHeader
        ) -> Bool {
            guard glyphHeader == nil,
                counts.beginPositionedGlyphs(operation)
            else { return false }
            glyphHeader = operation
            return true
        }

        package mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool {
            guard let header, let glyphHeader else { return false }
            var workspace = tile
            var pixels = paintedPixels
            var visits = tileVisits
            let descriptor = workspace.descriptor
            let result = OperationMajorTileTraversal.visit(
                operationClip: glyphHeader.clip,
                damageBounds: header.damageBounds,
                workspace: &workspace,
                { damage, replace in
                    switch RasterGlyphCoverage.rasterize(
                        glyph, operation: glyphHeader,
                        metrics: metrics, raster: raster,
                        realization: realization,
                        descriptor: descriptor,
                        damageBounds: damage, replace
                    ) {
                    case .completed(let count, _):
                        let next = pixels.addingReportingOverflow(count)
                        guard !next.overflow else { return false }
                        pixels = next.partialValue
                        return true
                    default: return false
                    }
                },
                { _ in
                    let next = visits.addingReportingOverflow(1)
                    guard !next.overflow else { return false }
                    visits = next.partialValue
                    return true
                }
            )
            guard case .completed = result, counts.positionedGlyph(glyph) else {
                return false
            }
            tile = workspace
            paintedPixels = pixels
            tileVisits = visits
            return true
        }

        package mutating func endPositionedGlyphs() -> Bool {
            guard glyphHeader != nil, counts.endPositionedGlyphs() else {
                return false
            }
            glyphHeader = nil
            return true
        }

        package mutating func straightLineStroke<Stroke: StraightLineStrokeView>(
            _ stroke: borrowing Stroke
        ) -> Bool {
            guard let header else { return false }
            let strokeView = copy stroke
            var workspace = tile
            var pixels = paintedPixels
            var visits = tileVisits
            let descriptor = workspace.descriptor
            let result = OperationMajorTileTraversal.visit(
                operationClip: strokeView.header.inheritedClip,
                damageBounds: header.damageBounds,
                workspace: &workspace,
                { damage, replace in
                    switch RasterStrokeCoverage.rasterize(
                        strokeView, descriptor: descriptor,
                        damageBounds: damage, replace
                    ) {
                    case .completed(let count):
                        let next = pixels.addingReportingOverflow(count)
                        guard !next.overflow else { return false }
                        pixels = next.partialValue
                        return true
                    default: return false
                    }
                },
                { _ in
                    let next = visits.addingReportingOverflow(1)
                    guard !next.overflow else { return false }
                    visits = next.partialValue
                    return true
                }
            )
            guard case .completed = result,
                counts.straightLineStroke(stroke)
            else { return false }
            tile = workspace
            paintedPixels = pixels
            tileVisits = visits
            return true
        }

        package mutating func finish() -> Bool {
            guard glyphHeader == nil, counts.finish() else { return false }
            isFinished = true
            return true
        }

        package mutating func discard() {
            counts.discard()
            isFinished = false
            header = nil
            glyphHeader = nil
        }
    }
#endif
