#if GIFTUI_NRF_EMBEDDED
    /// Checks the shared operation stream without retaining a frame. This is
    /// used by the target startup probe before the display endpoint is wired.
    package struct StaticSignalAnalyzerNRFEmbeddedCountingSink: DrawingOperationSink {
        package let capacity = RenderSinkCapacity(
            maximumOperations: 150, maximumPositionedGlyphs: 224
        )
        package private(set) var operationCount: UInt16 = 0
        package private(set) var glyphCount: UInt16 = 0
        package private(set) var strokeCount: UInt16 = 0
        package private(set) var fillCount: UInt16 = 0
        package private(set) var isFinished = false
        package private(set) var wasDiscarded = false
        private var header: RenderPlanHeader?
        private var pendingGlyphs: UInt16 = 0
        private var inGlyphs = false

        package init() {}

        package mutating func begin(_ header: RenderPlanHeader) -> Bool {
            guard self.header == nil, !isFinished, !wasDiscarded,
                header.operationCount <= capacity.maximumOperations,
                header.positionedGlyphCount <= capacity.maximumPositionedGlyphs
            else { return false }
            self.header = header
            return true
        }

        package mutating func fillRect(_ operation: FillRectOperation) -> Bool {
            _ = operation
            guard readyForOperation() else { return false }
            operationCount += 1
            fillCount += 1
            return true
        }

        package mutating func beginPositionedGlyphs(
            _ operation: PositionedGlyphOperationHeader
        ) -> Bool {
            guard readyForOperation(), operation.glyphCount > 0,
                let header,
                Int(glyphCount) + Int(operation.glyphCount)
                    <= Int(header.positionedGlyphCount)
            else { return false }
            operationCount += 1
            pendingGlyphs = operation.glyphCount
            inGlyphs = true
            return true
        }

        package mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool {
            _ = glyph
            guard inGlyphs, pendingGlyphs > 0 else { return false }
            pendingGlyphs -= 1
            glyphCount += 1
            return true
        }

        package mutating func endPositionedGlyphs() -> Bool {
            guard inGlyphs, pendingGlyphs == 0 else { return false }
            inGlyphs = false
            return true
        }

        package mutating func straightLineStroke<Stroke: StraightLineStrokeView>(
            _ stroke: borrowing Stroke
        ) -> Bool {
            guard readyForOperation(), stroke.header.pointCount > 0,
                stroke.header.subpathCount > 0
            else { return false }
            var index: UInt16 = 0
            while index < stroke.header.pointCount {
                guard stroke.point(at: index) != nil else { return false }
                index += 1
            }
            index = 0
            while index < stroke.header.subpathCount {
                guard stroke.subpath(at: index) != nil else { return false }
                index += 1
            }
            operationCount += 1
            strokeCount += 1
            return true
        }

        package mutating func finish() -> Bool {
            guard let header, !inGlyphs, !isFinished, !wasDiscarded,
                operationCount == header.operationCount,
                glyphCount == header.positionedGlyphCount
            else { return false }
            isFinished = true
            return true
        }

        package mutating func discard() {
            wasDiscarded = true
            isFinished = false
        }

        private func readyForOperation() -> Bool {
            guard let header, !inGlyphs, !isFinished, !wasDiscarded else {
                return false
            }
            return operationCount < header.operationCount
        }
    }
#endif
