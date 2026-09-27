import GiftUITextResources

/// The Pi's 240 px logical display uses 7x14 bitmap glyphs derived from
/// Terminus 8x14 by removing each glyph's unused rightmost column.
/// It has its own canonical identity and validated bitmap payload.
package struct GiftUIPiCompactTextMetricsView: CanonicalTextMetricsView {
    package init() {}

    package var descriptor: TextResourceDescriptor {
        _GiftUIPiCompactGeneratedCatalogue.descriptor
    }

    package func instance(at index: UInt16) -> FontInstanceDescriptor? {
        index == 0 ? _GiftUIPiCompactGeneratedCatalogue.instanceDescriptor : nil
    }

    package func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
        guard instance == _GiftUIPiCompactGeneratedCatalogue.instanceID else {
            return nil
        }
        return _GiftUIPiCompactGeneratedCatalogue.mapping(at: index)
    }

    package func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        guard instance == _GiftUIPiCompactGeneratedCatalogue.instanceID,
            glyph.rawValue < _GiftUIPiCompactGeneratedCatalogue.glyphCount
        else { return nil }
        return _GiftUIPiCompactGeneratedCatalogue.metrics(for: glyph)
    }
}

package struct GiftUIPiCompactTextRasterView: TextRasterResourceView {
    package init() {}

    package var descriptor: TextResourceDescriptor {
        _GiftUIPiCompactGeneratedCatalogue.descriptor
    }

    package func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        _GiftUIPiCompactGeneratedCatalogue.realization(
            at: index,
            instance: _GiftUIPiCompactGeneratedCatalogue.instanceID
        )
    }

    package func record(
        for glyph: GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        guard realization.rawValue == 0,
            glyph.rawValue < _GiftUIPiCompactGeneratedCatalogue.glyphCount
        else { return nil }
        return _GiftUIPiCompactGeneratedCatalogue.record(
            for: glyph,
            realization: realization
        )
    }

    package func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        realization.rawValue == 0
    }

    package func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        guard realization.rawValue == 0,
            record == self.record(for: record.glyph, realization: realization)
        else { return nil }
        return try _GiftUIPiCompactGeneratedBitmapPayload.withRecordBytes(
            for: record.glyph,
            expectedByteCount: record.byteCount,
            body
        )
    }
}

package enum GiftUIPiCompactTextResources {
    package static var targetPackage:
        TextResourcePackage<
            GiftUIPiCompactTextMetricsView,
            GiftUIPiCompactTextRasterView
        >
    {
        TextResourcePackage(
            metrics: GiftUIPiCompactTextMetricsView(),
            raster: GiftUIPiCompactTextRasterView()
        )
    }
}
