#if GIFTUI_NRF_EMBEDDED
    /// Exposes the generated reference bitmap payload through the common
    /// glyph raster interface, with only the one Static nRF realization.
    package struct StaticSignalAnalyzerNRFEmbeddedFontRaster:
        TextRasterResourceView
    {
        package let descriptor = TextResourceDescriptor(instanceCount: 1)

        package func realization(at index: UInt16) -> RasterRealizationDescriptor? {
            guard index == 0 else { return nil }
            return RasterRealizationDescriptor(
                id: RasterRealizationID(rawValue: 0),
                instance: FontInstanceID(rawValue: 0),
                kind: .monochromeBitmap1,
                glyphCount: StaticSignalAnalyzerNRFReferenceMetrics.glyphCount,
                payloadByteCount: _GiftUIReferenceGeneratedBitmapPayload.byteCount,
                payloadDigest: _GiftUIReferenceGeneratedBitmapPayload.digest
            )
        }

        package func record(
            for glyph: GlyphID, realization: RasterRealizationID
        ) -> GlyphRasterRecord? {
            guard realization.rawValue == 0 else { return nil }
            return StaticSignalAnalyzerNRFReferenceMetrics.bitmapRecord(for: glyph)
        }

        package func isPayloadAvailable(
            for realization: RasterRealizationID
        ) -> Bool {
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
            return try _GiftUIReferenceGeneratedBitmapPayload.withRecordBytes(
                for: record.glyph, expectedByteCount: record.byteCount, body
            )
        }
    }
#endif
