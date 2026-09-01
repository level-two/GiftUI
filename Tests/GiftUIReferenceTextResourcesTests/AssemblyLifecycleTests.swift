@testable import GiftUIReferenceTextResources
@testable import GiftUITextResources
import Testing

private struct ContractLocalAssembly<M, R>
where M: CanonicalTextMetricsView, R: TextRasterResourceView {
    private(set) var validationCount = 0
    private(set) var consumerCount = 0
    private var admittedPackage: TextResourcePackage<M, R>?
    private var teardownRequested = false

    mutating func assemble(
        _ candidate: consuming TextResourcePackage<M, R>,
        requiring realization: RasterRealizationID
    ) -> TextResourceValidationResult {
        validationCount += 1
        let result = TextResourceValidator.validate(
            candidate,
            requiring: realization
        )
        if result == .valid {
            admittedPackage = candidate
            teardownRequested = false
        } else {
            admittedPackage = nil
        }
        return result
    }

    func withAdmittedPackage<Result>(
        _ body: (borrowing TextResourcePackage<M, R>) throws -> Result
    ) rethrows -> Result? {
        guard let admittedPackage else { return nil }
        return try body(admittedPackage)
    }

    mutating func attachConsumer() -> Bool {
        guard admittedPackage != nil, !teardownRequested else { return false }
        consumerCount += 1
        return true
    }

    mutating func detachConsumer() {
        guard consumerCount > 0 else { return }
        consumerCount -= 1
        if consumerCount == 0, teardownRequested {
            admittedPackage = nil
        }
    }

    mutating func requestTearDown() {
        teardownRequested = true
        if consumerCount == 0 {
            admittedPackage = nil
        }
    }
}

@Test
func buildValidationSeesBothPayloadsBeforeTargetAssembly() {
    let results = GiftUIReferenceTextResources.validateCompletePackage()
    #expect(results.bitmap == .valid)
    #expect(results.outline == .valid)

    let resourcePackage = GiftUIReferenceTextResources.completePackage
    #expect(
        resourcePackage.raster.isPayloadAvailable(
            for: RasterRealizationID(rawValue: 0)
        )
    )
    #expect(
        resourcePackage.raster.isPayloadAvailable(
            for: RasterRealizationID(rawValue: 1)
        )
    )
}

@Test
func targetAssemblyPublishesOnlyAfterSelectedRealizationValidation() {
    let complete = GiftUIReferenceTextResources.completePackage
    let candidate = TextResourcePackage(
        metrics: complete.metrics,
        raster: BitmapOnlyLinkedRaster(base: complete.raster)
    )
    var assembly = ContractLocalAssembly<
        GiftUIReferenceTextMetricsView,
        BitmapOnlyLinkedRaster
    >()
    var consumerInvocationCount = 0

    let before: Void? = assembly.withAdmittedPackage { _ in
        consumerInvocationCount += 1
    }
    #expect(before == nil)
    #expect(consumerInvocationCount == 0)

    let result = assembly.assemble(
        candidate,
        requiring: RasterRealizationID(rawValue: 0)
    )
    #expect(result == .valid)
    #expect(assembly.validationCount == 1)
    let firstConsumerAttached = assembly.attachConsumer()
    let secondConsumerAttached = assembly.attachConsumer()
    #expect(firstConsumerAttached)
    #expect(secondConsumerAttached)

    let borrowedByteCount = assembly.withAdmittedPackage { admitted in
        consumerInvocationCount += 1
        let instance = admitted.metrics.instance(at: 0)!
        let record = admitted.raster.record(
            for: GlyphID(rawValue: 0),
            realization: RasterRealizationID(rawValue: 0)
        )!
        #expect(
            admitted.metrics.metrics(
                for: record.glyph,
                in: instance.id
            ) != nil
        )
        return admitted.raster.withPayload(
            for: record,
            realization: RasterRealizationID(rawValue: 0)
        ) { bytes in bytes.count }
    }
    #expect(borrowedByteCount!! == Int(candidate.raster.record(
        for: GlyphID(rawValue: 0),
        realization: RasterRealizationID(rawValue: 0)
    )!.byteCount))
    #expect(consumerInvocationCount == 1)

    assembly.requestTearDown()
    #expect(assembly.withAdmittedPackage { _ in true } == true)
    assembly.detachConsumer()
    #expect(assembly.withAdmittedPackage { _ in true } == true)
    assembly.detachConsumer()
    #expect(assembly.withAdmittedPackage { _ in true } == nil)
}

@Test
func omittedUnselectedPayloadIsCatalogueUnavailabilityNotPartialAssembly() {
    let complete = GiftUIReferenceTextResources.completePackage
    let bitmapOnly = TextResourcePackage(
        metrics: complete.metrics,
        raster: BitmapOnlyLinkedRaster(base: complete.raster)
    )
    #expect(TextResourceValidator.validate(
        bitmapOnly,
        requiring: RasterRealizationID(rawValue: 0)
    ) == .valid)
    #expect(!bitmapOnly.raster.isPayloadAvailable(
        for: RasterRealizationID(rawValue: 1)
    ))
    #expect(bitmapOnly.raster.record(
        for: GlyphID(rawValue: 0),
        realization: RasterRealizationID(rawValue: 1)
    ) != nil)
    let outlineRecord = bitmapOnly.raster.record(
        for: GlyphID(rawValue: 0),
        realization: RasterRealizationID(rawValue: 1)
    )!
    var invocationCount = 0
    let unavailableResult: Void? = bitmapOnly.raster.withPayload(
        for: outlineRecord,
        realization: RasterRealizationID(rawValue: 1)
    ) { _ in invocationCount += 1 }
    #expect(unavailableResult == nil)
    #expect(invocationCount == 0)
}

@Test
func failedAssemblyExposesNoPartialMetricsOrRealization() {
    let complete = GiftUIReferenceTextResources.completePackage
    let unavailable = TextResourcePackage(
        metrics: complete.metrics,
        raster: UnavailableSelectedRaster(base: complete.raster)
    )
    var assembly = ContractLocalAssembly<
        GiftUIReferenceTextMetricsView,
        UnavailableSelectedRaster
    >()
    let result = assembly.assemble(
        unavailable,
        requiring: RasterRealizationID(rawValue: 0)
    )
    #expect(result == .invalid(.incompatibleViews))
    #expect(assembly.validationCount == 1)
    #expect(assembly.withAdmittedPackage { _ in true } == nil)
}

private struct UnavailableSelectedRaster: TextRasterResourceView {
    let base: GiftUIReferenceTextRasterView

    var descriptor: TextResourceDescriptor { base.descriptor }

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        base.realization(at: index)
    }

    func record(
        for glyph: GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        base.record(for: glyph, realization: realization)
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        realization.rawValue == 1
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        guard realization.rawValue == 1 else { return nil }
        return try base.withPayload(
            for: record,
            realization: realization,
            body
        )
    }
}

private struct BitmapOnlyLinkedRaster: TextRasterResourceView {
    let base: GiftUIReferenceTextRasterView

    var descriptor: TextResourceDescriptor { base.descriptor }

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        base.realization(at: index)
    }

    func record(
        for glyph: GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        return base.record(for: glyph, realization: realization)
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        realization.rawValue == 0
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        guard realization.rawValue == 0 else { return nil }
        return try base.withPayload(
            for: record,
            realization: realization,
            body
        )
    }
}
