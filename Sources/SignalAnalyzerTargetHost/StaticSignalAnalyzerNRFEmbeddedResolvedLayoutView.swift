/// A synchronous borrow of in-place published layout records.
/// It becomes invalid when the owning profile attempt resets either region.
package struct StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView {
    private let scopes: UnsafeMutableRawBufferPointer
    private let text: UnsafeMutableRawBufferPointer
    package let scopeCount: UInt16
    package let lineCount: UInt16
    package let glyphCount: UInt16
    package let rootIdentity: UInt16
    package let renderSnapshotVersion: UInt32

    package init(
        scopes: UnsafeMutableRawBufferPointer,
        text: UnsafeMutableRawBufferPointer,
        scopeCount: UInt16, lineCount: UInt16,
        glyphCount: UInt16, rootIdentity: UInt16,
        renderSnapshotVersion: UInt32 = 1
    ) {
        self.scopes = scopes
        self.text = text
        self.scopeCount = scopeCount
        self.lineCount = lineCount
        self.glyphCount = glyphCount
        self.rootIdentity = rootIdentity
        self.renderSnapshotVersion = renderSnapshotVersion
    }

    package var isPublished: Bool {
        text.count == StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.regionByteCount
            && text[StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.scratchOffset + 26] == 1
    }

    package func scope(
        at ordinal: UInt16
    ) -> StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.Record? {
        guard isPublished, ordinal < scopeCount else { return nil }
        return StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.read(
            at: ordinal, in: scopes
        )
    }

    package func scopeOrdinal(of identity: UInt16) -> UInt16? {
        guard isPublished else { return nil }
        var ordinal: UInt16 = 0
        while ordinal < scopeCount {
            if scope(at: ordinal)?.identity == identity { return ordinal }
            ordinal += 1
        }
        return nil
    }

    package func line(
        at ordinal: UInt16
    ) -> StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Line? {
        guard isPublished, ordinal < lineCount else { return nil }
        return StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.line(
            at: ordinal, in: text
        )
    }

    package func glyph(
        at ordinal: UInt16
    ) -> StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Glyph? {
        guard isPublished, ordinal < glyphCount else { return nil }
        return StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.glyph(
            at: ordinal, in: text
        )
    }
}

#if GIFTUI_NRF_EMBEDDED
    extension StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView:
        ResolvedRenderLayoutView
    {
        package typealias Identity = UInt16

        package var layoutScopeCount: UInt16 { scopeCount }

        package var rootBounds: Rect {
            bounds(of: rootIdentity)!
        }

        package func layoutIdentity(at ordinal: UInt16) -> UInt16? {
            scope(at: ordinal)?.identity
        }

        package func layoutOrdinal(of identity: UInt16) -> UInt16? {
            scopeOrdinal(of: identity)
        }

        package func bounds(of identity: UInt16) -> Rect? {
            guard let ordinal = scopeOrdinal(of: identity),
                let record = scope(at: ordinal),
                let x = record.originX, let y = record.originY,
                let size = Size(
                    width: GeometryScalar(record.width),
                    height: GeometryScalar(record.height)
                )
            else { return nil }
            return Rect(
                origin: Point(x: GeometryScalar(x), y: GeometryScalar(y)),
                size: size
            )
        }

        package func clip(of identity: UInt16) -> Rect? {
            guard let ordinal = scopeOrdinal(of: identity),
                let record = scope(at: ordinal),
                let x = record.clipX, let y = record.clipY,
                let width = record.clipWidth, let height = record.clipHeight,
                let size = Size(
                    width: GeometryScalar(width), height: GeometryScalar(height)
                )
            else { return nil }
            return Rect(
                origin: Point(x: GeometryScalar(x), y: GeometryScalar(y)),
                size: size
            )
        }

        package func textLineCount(of identity: UInt16) -> UInt16? {
            guard scopeOrdinal(of: identity) != nil else { return nil }
            var count: UInt16 = 0
            var ordinal: UInt16 = 0
            while ordinal < lineCount {
                if line(at: ordinal)?.identity == identity { count += 1 }
                ordinal += 1
            }
            return count
        }

        package func textLine(
            of identity: UInt16, at index: UInt16
        ) -> ResolvedRenderTextLine? {
            guard let scopeClip = clip(of: identity) else { return nil }
            var ordinal: UInt16 = 0
            while ordinal < lineCount {
                guard let record = line(at: ordinal) else { return nil }
                if record.identity == identity, record.lineIndex == index,
                    let size = Size(
                        width: GeometryScalar(record.width),
                        height: GeometryScalar(record.height)
                    ),
                    let bounds = Rect(
                        origin: Point(
                            x: GeometryScalar(record.x), y: GeometryScalar(record.y)
                        ), size: size
                    ), let lineClip = LayoutGeometry.intersection(scopeClip, bounds)
                {
                    var count: UInt16 = 0
                    var glyphOrdinal: UInt16 = 0
                    while glyphOrdinal < glyphCount {
                        if let glyph = glyph(at: glyphOrdinal),
                            glyph.identity == identity, glyph.lineIndex == index
                        {
                            count += 1
                        }
                        glyphOrdinal += 1
                    }
                    return ResolvedRenderTextLine(
                        lineIndex: index, bounds: bounds,
                        baseline: Point(
                            x: GeometryScalar(record.baselineX),
                            y: GeometryScalar(record.baselineY)
                        ), clip: lineClip, glyphCount: count
                    )
                }
                ordinal += 1
            }
            return nil
        }

        package func glyph(of identity: UInt16, at index: UInt16) -> ResolvedRenderGlyph? {
            var ordinal: UInt16 = 0
            var localIndex: UInt16 = 0
            while ordinal < glyphCount {
                guard let record = glyph(at: ordinal) else { return nil }
                if record.identity == identity {
                    if localIndex == index,
                        let line = textLine(of: identity, at: record.lineIndex)
                    {
                        return ResolvedRenderGlyph(
                            lineIndex: record.lineIndex, glyphIndex: index,
                            instance: FontInstanceID(rawValue: 0),
                            glyph: GlyphID(rawValue: record.glyphID),
                            baseline: Point(
                                x: GeometryScalar(record.baselineX),
                                y: GeometryScalar(record.baselineY)
                            ), clip: line.clip
                        )
                    }
                    localIndex += 1
                }
                ordinal += 1
            }
            return nil
        }
    }
#endif
