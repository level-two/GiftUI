#if GIFTUI_NRF_EMBEDDED
    /// Adapts the audited packed regions to the shared Layout algorithm.
    package struct StaticSignalAnalyzerNRFCommonLayoutWorkspace: LayoutWorkspace {
        package typealias Identity = UInt16
        package let maximumScopes: UInt16 = 98
        package let maximumDepth: UInt16 = 13
        package let maximumTextScalars: UInt16 = 224
        package let maximumTextLines: UInt16 = 128
        package let maximumPositionedGlyphs: UInt16 = 224
        package var packed: StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace

        package init(packed: StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace) {
            self.packed = packed
        }

        package var isLayoutActive: Bool { packed.isActive }
        package var scopeCount: UInt16 { packed.scopeCount }
        package var textLineCount: UInt16 { packed.textLineCount }
        package var positionedGlyphCount: UInt16 { packed.positionedGlyphCount }

        package mutating func acquireLayout() -> Bool { packed.acquire() }

        package mutating func appendScope(
            identity: borrowing UInt16, measurement: LayoutMeasurement
        ) -> Bool {
            guard let idealWidth = compact(measurement.idealSize.width),
                let idealHeight = compact(measurement.idealSize.height),
                let width = compact(measurement.resolvedSize.width),
                let height = compact(measurement.resolvedSize.height)
            else { return false }
            return packed.appendScope(
                identity: identity,
                idealWidth: idealWidth, idealHeight: idealHeight,
                width: width, height: height
            )
        }

        package func scopeIdentity(at index: UInt16) -> UInt16? {
            packed.scope(at: index)?.identity
        }

        package func measurement(for identity: borrowing UInt16) -> LayoutMeasurement? {
            guard let ordinal = packed.scopeOrdinal(of: identity),
                let record = packed.scope(at: ordinal),
                let ideal = Size(
                    width: GeometryScalar(record.idealWidth),
                    height: GeometryScalar(record.idealHeight)
                ),
                let resolved = Size(
                    width: GeometryScalar(record.width),
                    height: GeometryScalar(record.height)
                )
            else { return nil }
            return LayoutMeasurement(idealSize: ideal, resolvedSize: resolved)
        }

        package mutating func storeMeasurement(
            _ measurement: LayoutMeasurement, for identity: borrowing UInt16
        ) -> Bool {
            guard let idealWidth = compact(measurement.idealSize.width),
                let idealHeight = compact(measurement.idealSize.height),
                let width = compact(measurement.resolvedSize.width),
                let height = compact(measurement.resolvedSize.height)
            else { return false }
            return packed.replaceMeasurement(
                identity: identity,
                idealWidth: idealWidth, idealHeight: idealHeight,
                width: width, height: height
            )
        }

        package mutating func storePlacement(
            _ placement: LayoutPlacement, for identity: borrowing UInt16
        ) -> Bool {
            guard let originX = compact(placement.bounds.origin.x),
                let originY = compact(placement.bounds.origin.y),
                let width = compact(placement.bounds.size.width),
                let height = compact(placement.bounds.size.height),
                let clipX = compact(placement.clip.origin.x),
                let clipY = compact(placement.clip.origin.y),
                let clipWidth = compact(placement.clip.size.width),
                let clipHeight = compact(placement.clip.size.height)
            else { return false }
            return packed.placeScope(
                identity: identity,
                originX: originX, originY: originY,
                width: width, height: height,
                clipX: clipX, clipY: clipY,
                clipWidth: clipWidth, clipHeight: clipHeight
            )
        }

        package func placement(for identity: borrowing UInt16) -> LayoutPlacement? {
            guard let ordinal = packed.scopeOrdinal(of: identity),
                let record = packed.scope(at: ordinal),
                let x = record.originX, let y = record.originY,
                let clipX = record.clipX, let clipY = record.clipY,
                let clipWidth = record.clipWidth,
                let clipHeight = record.clipHeight,
                let bounds = Rect(
                    origin: Point(x: GeometryScalar(x), y: GeometryScalar(y)),
                    size: Size(
                        width: GeometryScalar(record.width),
                        height: GeometryScalar(record.height)
                    )!
                ),
                let clip = Rect(
                    origin: Point(
                        x: GeometryScalar(clipX), y: GeometryScalar(clipY)
                    ),
                    size: Size(
                        width: GeometryScalar(clipWidth),
                        height: GeometryScalar(clipHeight)
                    )!
                )
            else { return nil }
            return LayoutPlacement(bounds: bounds, clip: clip)
        }

        package mutating func appendTextLine(_ line: LayoutTextLine<UInt16>) -> Bool {
            guard line.clip == zeroRect,
                let x = compact(line.bounds.origin.x),
                let y = compact(line.bounds.origin.y),
                let width = compact(line.bounds.size.width),
                let height = compact(line.bounds.size.height),
                let baselineX = compact(line.baseline.x),
                let baselineY = compact(line.baseline.y)
            else { return false }
            return packed.appendTextLine(
                StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Line(
                    identity: line.identity, lineIndex: line.lineIndex,
                    x: x, y: y, width: width, height: height,
                    baselineX: baselineX, baselineY: baselineY
                )
            )
        }

        package func textLine(at index: UInt16) -> LayoutTextLine<UInt16>? {
            guard let record = packed.textLine(at: index),
                let bounds = Rect(
                    origin: Point(
                        x: GeometryScalar(record.x), y: GeometryScalar(record.y)
                    ),
                    size: Size(
                        width: GeometryScalar(record.width),
                        height: GeometryScalar(record.height)
                    )!
                )
            else { return nil }
            let clip =
                placement(for: record.identity).flatMap {
                    LayoutGeometry.intersection($0.clip, bounds)
                } ?? zeroRect
            return LayoutTextLine(
                identity: record.identity, lineIndex: record.lineIndex,
                bounds: bounds,
                baseline: Point(
                    x: GeometryScalar(record.baselineX),
                    y: GeometryScalar(record.baselineY)
                ), clip: clip
            )
        }

        package mutating func storeTextLine(
            _ line: LayoutTextLine<UInt16>, at index: UInt16
        ) -> Bool {
            guard let scope = placement(for: line.identity),
                line.clip == LayoutGeometry.intersection(scope.clip, line.bounds),
                let x = compact(line.bounds.origin.x),
                let y = compact(line.bounds.origin.y),
                let width = compact(line.bounds.size.width),
                let height = compact(line.bounds.size.height),
                let baselineX = compact(line.baseline.x),
                let baselineY = compact(line.baseline.y)
            else { return false }
            return packed.replaceTextLine(
                StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Line(
                    identity: line.identity, lineIndex: line.lineIndex,
                    x: x, y: y, width: width, height: height,
                    baselineX: baselineX, baselineY: baselineY
                ), at: index
            )
        }

        package mutating func appendPositionedGlyph(
            _ glyph: LayoutPositionedGlyph<UInt16>
        ) -> Bool {
            guard glyph.instance.rawValue == 0,
                glyph.clip == zeroRect,
                let baselineX = compact(glyph.baseline.x),
                let baselineY = compact(glyph.baseline.y)
            else { return false }
            return packed.appendGlyph(
                StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Glyph(
                    identity: glyph.identity, lineIndex: glyph.lineIndex,
                    glyphID: glyph.glyph.rawValue,
                    baselineX: baselineX, baselineY: baselineY
                ), glyphIndex: glyph.glyphIndex
            )
        }

        package func positionedGlyph(
            at index: UInt16
        ) -> LayoutPositionedGlyph<UInt16>? {
            guard let record = packed.glyph(at: index),
                let line = matchingLine(
                    identity: record.identity, lineIndex: record.lineIndex
                )
            else { return nil }
            var localIndex: UInt16 = 0
            var prior: UInt16 = 0
            while prior < index {
                if packed.glyph(at: prior)?.identity == record.identity {
                    localIndex += 1
                }
                prior += 1
            }
            return LayoutPositionedGlyph(
                identity: record.identity, lineIndex: record.lineIndex,
                glyphIndex: localIndex,
                instance: FontInstanceID(rawValue: 0),
                glyph: GlyphID(rawValue: record.glyphID),
                baseline: Point(
                    x: GeometryScalar(record.baselineX),
                    y: GeometryScalar(record.baselineY)
                ), clip: line.clip
            )
        }

        package mutating func storePositionedGlyph(
            _ glyph: LayoutPositionedGlyph<UInt16>, at index: UInt16
        ) -> Bool {
            guard let old = positionedGlyph(at: index),
                glyph.identity == old.identity,
                glyph.lineIndex == old.lineIndex,
                glyph.glyphIndex == old.glyphIndex,
                glyph.glyph == old.glyph,
                glyph.instance == old.instance,
                glyph.clip == old.clip,
                let baselineX = compact(glyph.baseline.x),
                let baselineY = compact(glyph.baseline.y)
            else { return false }
            return packed.replaceGlyphBaseline(
                StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Glyph(
                    identity: glyph.identity, lineIndex: glyph.lineIndex,
                    glyphID: glyph.glyph.rawValue,
                    baselineX: baselineX, baselineY: baselineY
                ), at: index
            )
        }

        package mutating func pushScope(_ identity: borrowing UInt16) -> Bool {
            packed.pushScope(identity)
        }

        package mutating func popScope() { packed.popScope() }

        package mutating func resetLayout() { packed.reset() }

        private func compact(_ value: GeometryScalar) -> Int16? {
            Int16(exactly: value)
        }

        private var zeroRect: Rect {
            Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 0, height: 0)!
            )!
        }

        private func matchingLine(
            identity: UInt16, lineIndex: UInt16
        ) -> LayoutTextLine<UInt16>? {
            var index: UInt16 = 0
            while index < packed.textLineCount {
                if let line = textLine(at: index),
                    line.identity == identity, line.lineIndex == lineIndex
                {
                    return line
                }
                index += 1
            }
            return nil
        }
    }
#endif
