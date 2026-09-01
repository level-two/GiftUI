import Testing
@testable import GiftUIReferenceTextResources
@testable import GiftUITextResources

@Test
func completeReferencePackageValidatesEveryRequiredRealization() {
    let results = GiftUIReferenceTextResources.validateCompletePackage()

    #expect(results.bitmap == .valid)
    #expect(results.outline == .valid)
}

@Test
func everyGeneratedRecordBorrowsItsExactStructurallyValidBytes() {
    let resourcePackage = GiftUIReferenceTextResources.completePackage
    let instance = resourcePackage.metrics.instance(at: 0)!

    for realizationIndex: UInt16 in 0 ..< 2 {
        let realization = resourcePackage.raster.realization(
            at: realizationIndex
        )!
        for glyphValue: UInt16 in 0 ..< instance.glyphCount {
            let glyph = GlyphID(rawValue: glyphValue)
            let record = resourcePackage.raster.record(
                for: glyph,
                realization: realization.id
            )!
            let metrics = resourcePackage.metrics.metrics(
                for: glyph,
                in: instance.id
            )!
            let isValid = resourcePackage.raster.withPayload(
                for: record,
                realization: realization.id
            ) { bytes in
                guard bytes.count == Int(record.byteCount) else {
                    return false
                }
                switch realization.kind {
                case .monochromeBitmap1:
                    return TextResourceValidator
                        .isStructurallyValidMonochromeBitmap(
                            record: record,
                            metrics: metrics,
                            bytes: bytes
                        )
                case .packagedOutline:
                    return TextResourceValidator
                        .isStructurallyValidPackagedOutline(
                            record: record,
                            metrics: metrics,
                            bytes: bytes
                        )
                }
            }
            #expect(
                isValid == true,
                "invalid realization \(realizationIndex), glyph \(glyphValue)"
            )
        }
    }
}
