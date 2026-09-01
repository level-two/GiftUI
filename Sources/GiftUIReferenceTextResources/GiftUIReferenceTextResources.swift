import GiftUITextResources

package struct GiftUIReferenceTextMetricsView: CanonicalTextMetricsView {
    package init() {}

    package var descriptor: TextResourceDescriptor {
        _GiftUIReferenceGeneratedCatalogue.descriptor
    }

    package func instance(at index: UInt16) -> FontInstanceDescriptor? {
        guard index == 0 else { return nil }
        return _GiftUIReferenceGeneratedCatalogue.instanceDescriptor
    }

    package func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
        guard instance == _GiftUIReferenceGeneratedCatalogue.instanceID else {
            return nil
        }
        return _GiftUIReferenceGeneratedCatalogue.mapping(at: index)
    }

    package func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        guard instance == _GiftUIReferenceGeneratedCatalogue.instanceID,
              glyph.rawValue < _GiftUIReferenceGeneratedCatalogue.glyphCount else {
            return nil
        }
        return _GiftUIReferenceGeneratedCatalogue.metrics(for: glyph)
    }
}

package struct GiftUIReferenceTextRasterView: TextRasterResourceView {
    package init() {}

    package var descriptor: TextResourceDescriptor {
        _GiftUIReferenceGeneratedCatalogue.descriptor
    }

    package func realization(
        at index: UInt16
    ) -> RasterRealizationDescriptor? {
        _GiftUIReferenceGeneratedCatalogue.realization(
            at: index,
            instance: _GiftUIReferenceGeneratedCatalogue.instanceID
        )
    }

    package func record(
        for glyph: GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        guard realization.rawValue < descriptor.realizationCount,
              glyph.rawValue < _GiftUIReferenceGeneratedCatalogue.glyphCount else {
            return nil
        }
        return _GiftUIReferenceGeneratedCatalogue.record(
            for: glyph,
            realization: realization
        )
    }

    package func isPayloadAvailable(
        for realization: RasterRealizationID
    ) -> Bool {
        realization.rawValue < descriptor.realizationCount
    }

    package func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        let cataloguedRealization = self.realization(at: realization.rawValue)
        let cataloguedRecord = self.record(
            for: record.glyph,
            realization: realization
        )
        switch realization.rawValue {
        case 0:
            guard record == cataloguedRecord,
                  realization == cataloguedRealization?.id else { return nil }
            return try _GiftUIReferenceGeneratedBitmapPayload.withRecordBytes(
                for: record.glyph,
                expectedByteCount: record.byteCount,
                body
            )
        case 1:
            guard record == cataloguedRecord,
                  realization == cataloguedRealization?.id else { return nil }
            return try _GiftUIReferenceGeneratedOutlinePayload.withRecordBytes(
                for: record.glyph,
                expectedByteCount: record.byteCount,
                body
            )
        default:
            return nil
        }
    }
}

package enum GiftUIReferenceTextResources {
    package static var completePackage: TextResourcePackage<
        GiftUIReferenceTextMetricsView,
        GiftUIReferenceTextRasterView
    > {
        TextResourcePackage(
            metrics: GiftUIReferenceTextMetricsView(),
            raster: GiftUIReferenceTextRasterView()
        )
    }

    package static func validateCompletePackage() -> (
        bitmap: TextResourceValidationResult,
        outline: TextResourceValidationResult
    ) {
        let resourcePackage = completePackage
        return (
            bitmap: TextResourceValidator.validate(
                resourcePackage,
                requiring: RasterRealizationID(rawValue: 0)
            ),
            outline: TextResourceValidator.validate(
                resourcePackage,
                requiring: RasterRealizationID(rawValue: 1)
            )
        )
    }
}
