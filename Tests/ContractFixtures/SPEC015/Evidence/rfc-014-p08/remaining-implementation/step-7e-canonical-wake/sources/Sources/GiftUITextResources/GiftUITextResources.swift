import GiftUI

package struct TextResourceDigest: Equatable, Hashable, Sendable {
    package let word0: UInt32
    package let word1: UInt32
    package let word2: UInt32
    package let word3: UInt32
    package let word4: UInt32
    package let word5: UInt32
    package let word6: UInt32
    package let word7: UInt32

    package init(
        word0: UInt32,
        word1: UInt32,
        word2: UInt32,
        word3: UInt32,
        word4: UInt32,
        word5: UInt32,
        word6: UInt32,
        word7: UInt32
    ) {
        self.word0 = word0
        self.word1 = word1
        self.word2 = word2
        self.word3 = word3
        self.word4 = word4
        self.word5 = word5
        self.word6 = word6
        self.word7 = word7
    }
}

package struct FontResourceID: RawRepresentable, Equatable, Hashable, Sendable {
    package let rawValue: TextResourceDigest

    package init(rawValue: TextResourceDigest) {
        self.rawValue = rawValue
    }
}

package struct FontInstanceID: Equatable, Hashable, Sendable {
    package let resource: FontResourceID
    package let instanceIndex: UInt16

    package init(resource: FontResourceID, instanceIndex: UInt16) {
        self.resource = resource
        self.instanceIndex = instanceIndex
    }
}

package struct GlyphID: RawRepresentable, Equatable, Hashable, Sendable {
    package let rawValue: UInt16

    package init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

package struct RasterRealizationID:
    RawRepresentable, Equatable, Hashable, Sendable
{
    package let rawValue: UInt16

    package init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

package enum TextRasterKind: UInt8, Equatable, Sendable {
    case monochromeBitmap1 = 0
    case packagedOutline = 1
}

package struct FontLineMetrics: Equatable, Sendable {
    package let ascent: GeometryScalar
    package let descent: GeometryScalar
    package let lineGap: GeometryScalar

    package init(
        ascent: GeometryScalar,
        descent: GeometryScalar,
        lineGap: GeometryScalar
    ) {
        self.ascent = ascent
        self.descent = descent
        self.lineGap = lineGap
    }
}

package struct GlyphMetrics: Equatable, Sendable {
    package let advanceX: GeometryScalar
    package let offsetX: GeometryScalar
    package let offsetY: GeometryScalar
    package let inkSize: Size

    package init(
        advanceX: GeometryScalar,
        offsetX: GeometryScalar,
        offsetY: GeometryScalar,
        inkSize: Size
    ) {
        self.advanceX = advanceX
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.inkSize = inkSize
    }
}

package struct FontInstanceDescriptor: Equatable, Sendable {
    package let id: FontInstanceID
    package let lineMetrics: FontLineMetrics
    package let replacementGlyph: GlyphID
    package let glyphCount: UInt16
    package let mappingCount: UInt16

    package init(
        id: FontInstanceID,
        lineMetrics: FontLineMetrics,
        replacementGlyph: GlyphID,
        glyphCount: UInt16,
        mappingCount: UInt16
    ) {
        self.id = id
        self.lineMetrics = lineMetrics
        self.replacementGlyph = replacementGlyph
        self.glyphCount = glyphCount
        self.mappingCount = mappingCount
    }
}

package struct RasterRealizationDescriptor: Equatable, Sendable {
    package let id: RasterRealizationID
    package let instance: FontInstanceID
    package let kind: TextRasterKind
    package let glyphCount: UInt16
    package let payloadByteCount: UInt32
    package let payloadDigest: TextResourceDigest

    package init(
        id: RasterRealizationID,
        instance: FontInstanceID,
        kind: TextRasterKind,
        glyphCount: UInt16,
        payloadByteCount: UInt32,
        payloadDigest: TextResourceDigest
    ) {
        self.id = id
        self.instance = instance
        self.kind = kind
        self.glyphCount = glyphCount
        self.payloadByteCount = payloadByteCount
        self.payloadDigest = payloadDigest
    }
}

package struct TextResourceDescriptor: Equatable, Sendable {
    package let schemaVersion: UInt16
    package let resource: FontResourceID
    package let instanceCount: UInt16
    package let realizationCount: UInt16
    package let canonicalManifestByteCount: UInt32

    package init(
        schemaVersion: UInt16,
        resource: FontResourceID,
        instanceCount: UInt16,
        realizationCount: UInt16,
        canonicalManifestByteCount: UInt32
    ) {
        self.schemaVersion = schemaVersion
        self.resource = resource
        self.instanceCount = instanceCount
        self.realizationCount = realizationCount
        self.canonicalManifestByteCount = canonicalManifestByteCount
    }
}

package enum GlyphMapping: Equatable, Sendable {
    case exact(GlyphID)
    case replacement(GlyphID)
}

package struct ScalarGlyphMappingRecord: Equatable, Sendable {
    package let scalarValue: UInt32
    package let glyph: GlyphID

    package init(scalarValue: UInt32, glyph: GlyphID) {
        self.scalarValue = scalarValue
        self.glyph = glyph
    }
}

package struct GlyphRasterRecord: Equatable, Sendable {
    package let glyph: GlyphID
    package let offset: UInt32
    package let byteCount: UInt32
    package let rowByteCount: UInt16
    package let pixelWidth: UInt16
    package let pixelHeight: UInt16

    package init(
        glyph: GlyphID,
        offset: UInt32,
        byteCount: UInt32,
        rowByteCount: UInt16,
        pixelWidth: UInt16,
        pixelHeight: UInt16
    ) {
        self.glyph = glyph
        self.offset = offset
        self.byteCount = byteCount
        self.rowByteCount = rowByteCount
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
    }
}

package protocol CanonicalTextMetricsView {
    var descriptor: TextResourceDescriptor { get }
    func instance(at index: UInt16) -> FontInstanceDescriptor?
    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord?
    func mapScalar(
        _ scalarValue: UInt32,
        in instance: FontInstanceID
    ) -> GlyphMapping?
    func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics?
}

package protocol TextRasterResourceView {
    var descriptor: TextResourceDescriptor { get }
    func realization(at index: UInt16) -> RasterRealizationDescriptor?
    func record(
        for glyph: GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord?
    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool
    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result?
}

package struct TextResourcePackage<Metrics, Raster>
where Metrics: CanonicalTextMetricsView, Raster: TextRasterResourceView {
    package let metrics: Metrics
    package let raster: Raster

    package init(metrics: Metrics, raster: Raster) {
        self.metrics = metrics
        self.raster = raster
    }
}

package enum TextResourceValidationError: UInt8, Equatable, Sendable {
    case unsupportedSchema = 0
    case capacityExceeded = 1
    case invalidCount = 2
    case invalidIdentity = 3
    case incompatibleViews = 4
    case malformedMetrics = 5
    case malformedMapping = 6
    case malformedRasterRecord = 7
    case integrityMismatch = 8
}

package enum TextResourceValidationResult: Equatable, Sendable {
    case valid
    case invalid(TextResourceValidationError)
}

package enum TextResourceValidator {
    package static func validate<M, R>(
        _ resourcePackage: borrowing TextResourcePackage<M, R>,
        requiring requiredRealization: RasterRealizationID
    ) -> TextResourceValidationResult
    where M: CanonicalTextMetricsView, R: TextRasterResourceView {
        let metricsDescriptor = resourcePackage.metrics.descriptor
        let rasterDescriptor = resourcePackage.raster.descriptor
        var predicates = _TextResourceValidationPredicates()

        predicates.unsupportedSchema =
            metricsDescriptor.schemaVersion != 1
            || rasterDescriptor.schemaVersion != 1
        predicates.capacityExceeded =
            !isWithinCapacity(
                instanceCount: metricsDescriptor.instanceCount,
                glyphCount: 0,
                mappingCount: 0,
                realizationCount: metricsDescriptor.realizationCount,
                canonicalManifestByteCount:
                    metricsDescriptor.canonicalManifestByteCount,
                payloadByteCount: 0
            )
            || !isWithinCapacity(
                instanceCount: rasterDescriptor.instanceCount,
                glyphCount: 0,
                mappingCount: 0,
                realizationCount: rasterDescriptor.realizationCount,
                canonicalManifestByteCount:
                    rasterDescriptor.canonicalManifestByteCount,
                payloadByteCount: 0
            )
        predicates.invalidCount =
            metricsDescriptor.instanceCount == 0
            || metricsDescriptor.realizationCount == 0
            || metricsDescriptor.canonicalManifestByteCount == 0
            || rasterDescriptor.instanceCount == 0
            || rasterDescriptor.realizationCount == 0
            || rasterDescriptor.canonicalManifestByteCount == 0
            || metricsDescriptor.instanceCount != rasterDescriptor.instanceCount
            || metricsDescriptor.realizationCount
                != rasterDescriptor.realizationCount
            || metricsDescriptor.canonicalManifestByteCount
                != rasterDescriptor.canonicalManifestByteCount
        predicates.incompatibleViews = metricsDescriptor != rasterDescriptor

        var canonicalInstance: FontInstanceDescriptor?
        let instanceTraversalCount =
            metricsDescriptor.instanceCount > 1
            ? UInt16(1) : metricsDescriptor.instanceCount
        var instanceOrdinal: UInt16 = 0
        while instanceOrdinal < instanceTraversalCount {
            guard
                let instance = resourcePackage.metrics.instance(
                    at: instanceOrdinal
                )
            else {
                predicates.invalidCount = true
                instanceOrdinal += 1
                continue
            }
            if canonicalInstance != nil {
                predicates.invalidIdentity = true
            } else {
                canonicalInstance = instance
            }
            predicates.capacityExceeded =
                predicates.capacityExceeded
                || !isWithinCapacity(
                    instanceCount: 1,
                    glyphCount: instance.glyphCount,
                    mappingCount: instance.mappingCount,
                    realizationCount: 1,
                    canonicalManifestByteCount: 1,
                    payloadByteCount: 0
                )
            predicates.invalidCount =
                predicates.invalidCount
                || instance.glyphCount == 0
                || instance.mappingCount == 0
            predicates.invalidIdentity =
                predicates.invalidIdentity
                || instance.id.resource != metricsDescriptor.resource
                || instance.id.instanceIndex != instanceOrdinal
                || instance.replacementGlyph.rawValue >= instance.glyphCount

            let line = instance.lineMetrics
            var lineSum = GeometryArithmetic.add(line.ascent, line.descent)
            if let partial = lineSum {
                lineSum = GeometryArithmetic.add(partial, line.lineGap)
            }
            predicates.malformedMetrics =
                predicates.malformedMetrics
                || line.ascent <= 0
                || line.descent < 0
                || line.lineGap < 0
                || lineSum == nil
                || lineSum == 0

            let mappingTraversalCount =
                instance.mappingCount > 256
                ? UInt16(256) : instance.mappingCount
            var mappingOrdinal: UInt16 = 0
            var precedingScalar: UInt32?
            while mappingOrdinal < mappingTraversalCount {
                guard
                    let mapping = resourcePackage.metrics.mapping(
                        at: mappingOrdinal,
                        in: instance.id
                    )
                else {
                    predicates.invalidCount = true
                    mappingOrdinal += 1
                    continue
                }
                predicates.malformedMapping =
                    predicates.malformedMapping
                    || !isValidUnicodeScalar(mapping.scalarValue)
                    || mapping.scalarValue == 0x0a
                    || mapping.scalarValue == 0x0d
                    || mapping.glyph.rawValue >= instance.glyphCount
                if let precedingScalar,
                    mapping.scalarValue <= precedingScalar
                {
                    predicates.malformedMapping = true
                }
                precedingScalar = mapping.scalarValue
                mappingOrdinal += 1
            }
            if instance.mappingCount <= 256,
                resourcePackage.metrics.mapping(
                    at: instance.mappingCount,
                    in: instance.id
                ) != nil
            {
                predicates.invalidCount = true
            }

            let glyphTraversalCount =
                instance.glyphCount > 256
                ? UInt16(256) : instance.glyphCount
            var glyphOrdinal: UInt16 = 0
            while glyphOrdinal < glyphTraversalCount {
                let glyph = GlyphID(rawValue: glyphOrdinal)
                guard
                    let glyphMetrics = resourcePackage.metrics.metrics(
                        for: glyph,
                        in: instance.id
                    )
                else {
                    predicates.invalidCount = true
                    glyphOrdinal += 1
                    continue
                }
                predicates.malformedMetrics =
                    predicates.malformedMetrics
                    || glyphMetrics.advanceX < 0
                    || GeometryArithmetic.add(
                        glyphMetrics.offsetX,
                        glyphMetrics.inkSize.width
                    ) == nil
                    || GeometryArithmetic.add(
                        glyphMetrics.offsetY,
                        glyphMetrics.inkSize.height
                    ) == nil
                glyphOrdinal += 1
            }
            if instance.glyphCount <= 256,
                resourcePackage.metrics.metrics(
                    for: GlyphID(rawValue: instance.glyphCount),
                    in: instance.id
                ) != nil
            {
                predicates.invalidCount = true
            }
            instanceOrdinal += 1
        }
        if metricsDescriptor.instanceCount <= 1,
            resourcePackage.metrics.instance(
                at: metricsDescriptor.instanceCount
            ) != nil
        {
            predicates.invalidCount = true
        }

        let realizationTraversalCount =
            metricsDescriptor.realizationCount > 2
            ? UInt16(2) : metricsDescriptor.realizationCount
        var realizationOrdinal: UInt16 = 0
        var anyAvailablePayload = false
        var requiredIsCatalogued = false
        var requiredIsAvailable = false
        while realizationOrdinal < realizationTraversalCount {
            guard
                let realization = resourcePackage.raster.realization(
                    at: realizationOrdinal
                )
            else {
                predicates.invalidCount = true
                realizationOrdinal += 1
                continue
            }
            if realization.id == requiredRealization {
                requiredIsCatalogued = true
            }
            if realization.id == requiredRealization {
                requiredIsAvailable = resourcePackage.raster
                    .isPayloadAvailable(for: realization.id)
            }
            let isAvailable = resourcePackage.raster.isPayloadAvailable(
                for: realization.id
            )
            anyAvailablePayload = anyAvailablePayload || isAvailable
            predicates.capacityExceeded =
                predicates.capacityExceeded
                || !isWithinCapacity(
                    instanceCount: 1,
                    glyphCount: realization.glyphCount,
                    mappingCount: 0,
                    realizationCount: 1,
                    canonicalManifestByteCount: 1,
                    payloadByteCount: realization.payloadByteCount
                )
            predicates.invalidCount =
                predicates.invalidCount
                || realization.glyphCount == 0
            predicates.invalidIdentity =
                predicates.invalidIdentity
                || realization.id.rawValue != realizationOrdinal
                || realization.instance.resource != rasterDescriptor.resource
                || realization.instance.instanceIndex != 0
            if let canonicalInstance {
                predicates.incompatibleViews =
                    predicates.incompatibleViews
                    || realization.instance != canonicalInstance.id
                    || realization.glyphCount != canonicalInstance.glyphCount
            } else {
                predicates.incompatibleViews = true
            }

            let recordTraversalCount =
                realization.glyphCount > 256
                ? UInt16(256) : realization.glyphCount
            var recordOrdinal: UInt16 = 0
            var expectedOffset: UInt32 = 0
            var payloadSHA256 = _TextResourceSHA256()
            var payloadBytesBorrowed: UInt32 = 0
            while recordOrdinal < recordTraversalCount {
                let glyph = GlyphID(rawValue: recordOrdinal)
                guard
                    let record = resourcePackage.raster.record(
                        for: glyph,
                        realization: realization.id
                    )
                else {
                    predicates.invalidCount = true
                    recordOrdinal += 1
                    continue
                }
                predicates.invalidIdentity =
                    predicates.invalidIdentity
                    || record.glyph != glyph
                let end = record.offset.addingReportingOverflow(record.byteCount)
                predicates.malformedRasterRecord =
                    predicates.malformedRasterRecord
                    || record.offset != expectedOffset
                    || end.overflow
                    || (!end.overflow
                        && end.partialValue > realization.payloadByteCount)
                if !end.overflow {
                    expectedOffset = end.partialValue
                }

                let glyphMetrics: GlyphMetrics?
                if let canonicalInstance {
                    glyphMetrics = resourcePackage.metrics.metrics(
                        for: glyph,
                        in: canonicalInstance.id
                    )
                } else {
                    glyphMetrics = nil
                }
                if glyphMetrics == nil {
                    predicates.incompatibleViews = true
                }
                if let glyphMetrics {
                    let dimensionsMatch =
                        glyphMetrics.inkSize.width
                        == Int32(record.pixelWidth)
                        && glyphMetrics.inkSize.height
                            == Int32(record.pixelHeight)
                    switch realization.kind {
                    case .monochromeBitmap1:
                        let expectedRowBytes =
                            (UInt32(record.pixelWidth) + 7) / 8
                        let expectedByteCount =
                            expectedRowBytes
                            .multipliedReportingOverflow(
                                by: UInt32(record.pixelHeight)
                            )
                        predicates.malformedRasterRecord =
                            predicates.malformedRasterRecord
                            || !dimensionsMatch
                            || UInt32(record.rowByteCount) != expectedRowBytes
                            || expectedByteCount.overflow
                            || (!expectedByteCount.overflow
                                && expectedByteCount.partialValue
                                    != record.byteCount)
                    case .packagedOutline:
                        predicates.malformedRasterRecord =
                            predicates.malformedRasterRecord
                            || !dimensionsMatch
                            || record.rowByteCount != 0
                    }
                }

                if isAvailable {
                    var invocationCount: UInt8 = 0
                    let borrowed: Bool? = resourcePackage.raster.withPayload(
                        for: record,
                        realization: realization.id
                    ) { bytes in
                        invocationCount &+= 1
                        if UInt32(exactly: bytes.count) != record.byteCount {
                            predicates.incompatibleViews = true
                        }
                        if let count = UInt32(exactly: bytes.count) {
                            let total =
                                payloadBytesBorrowed
                                .addingReportingOverflow(count)
                            if total.overflow {
                                predicates.capacityExceeded = true
                            } else {
                                payloadBytesBorrowed = total.partialValue
                            }
                        } else {
                            predicates.capacityExceeded = true
                        }
                        for byte in bytes {
                            payloadSHA256.update(with: byte)
                        }
                        if let glyphMetrics {
                            switch realization.kind {
                            case .monochromeBitmap1:
                                if !isStructurallyValidMonochromeBitmap(
                                    record: record,
                                    metrics: glyphMetrics,
                                    bytes: bytes
                                ) {
                                    predicates.malformedRasterRecord = true
                                }
                            case .packagedOutline:
                                if !isStructurallyValidPackagedOutline(
                                    record: record,
                                    metrics: glyphMetrics,
                                    bytes: bytes
                                ) {
                                    predicates.malformedRasterRecord = true
                                }
                            }
                        }
                        return true
                    }
                    if borrowed != true || invocationCount != 1 {
                        predicates.incompatibleViews = true
                    }
                }
                recordOrdinal += 1
            }
            if realization.glyphCount <= 256,
                resourcePackage.raster.record(
                    for: GlyphID(rawValue: realization.glyphCount),
                    realization: realization.id
                ) != nil
            {
                predicates.invalidCount = true
            }
            predicates.malformedRasterRecord =
                predicates.malformedRasterRecord
                || expectedOffset != realization.payloadByteCount
            if isAvailable {
                predicates.integrityMismatch =
                    predicates.integrityMismatch
                    || payloadSHA256.finalize() != realization.payloadDigest
            }
            realizationOrdinal += 1
        }
        if metricsDescriptor.realizationCount <= 2,
            resourcePackage.raster.realization(
                at: metricsDescriptor.realizationCount
            ) != nil
        {
            predicates.invalidCount = true
        }
        if resourcePackage.raster.isPayloadAvailable(
            for: RasterRealizationID(
                rawValue: metricsDescriptor.realizationCount
            )
        ) {
            predicates.invalidIdentity = true
        }
        predicates.incompatibleViews =
            predicates.incompatibleViews
            || !anyAvailablePayload
            || !requiredIsCatalogued
            || !requiredIsAvailable

        if let manifest = canonicalManifestDigest(of: resourcePackage) {
            predicates.capacityExceeded =
                predicates.capacityExceeded
                || manifest.byteCount > 16_384
            predicates.integrityMismatch =
                predicates.integrityMismatch
                || manifest.byteCount
                    != metricsDescriptor.canonicalManifestByteCount
                || manifest.digest != metricsDescriptor.resource.rawValue
        } else {
            predicates.invalidCount = true
        }

        return predicates.result
    }
}

private struct _TextResourceValidationPredicates {
    var unsupportedSchema = false
    var capacityExceeded = false
    var invalidCount = false
    var invalidIdentity = false
    var incompatibleViews = false
    var malformedMetrics = false
    var malformedMapping = false
    var malformedRasterRecord = false
    var integrityMismatch = false

    var result: TextResourceValidationResult {
        if unsupportedSchema { return .invalid(.unsupportedSchema) }
        if capacityExceeded { return .invalid(.capacityExceeded) }
        if invalidCount { return .invalid(.invalidCount) }
        if invalidIdentity { return .invalid(.invalidIdentity) }
        if incompatibleViews { return .invalid(.incompatibleViews) }
        if malformedMetrics { return .invalid(.malformedMetrics) }
        if malformedMapping { return .invalid(.malformedMapping) }
        if malformedRasterRecord { return .invalid(.malformedRasterRecord) }
        if integrityMismatch { return .invalid(.integrityMismatch) }
        return .valid
    }
}

package extension CanonicalTextMetricsView {
    func mapScalar(
        _ scalarValue: UInt32,
        in instance: FontInstanceID
    ) -> GlyphMapping? {
        guard TextResourceValidator.isValidUnicodeScalar(scalarValue),
            scalarValue != 0x0a,
            scalarValue != 0x0d,
            instance.resource == descriptor.resource,
            instance.instanceIndex < descriptor.instanceCount,
            let instanceDescriptor = self.instance(
                at: instance.instanceIndex
            ),
            instanceDescriptor.id == instance,
            instanceDescriptor.glyphCount > 0,
            instanceDescriptor.glyphCount <= 256,
            instanceDescriptor.mappingCount <= 256,
            instanceDescriptor.replacementGlyph.rawValue
                < instanceDescriptor.glyphCount
        else {
            return nil
        }

        var ordinal: UInt16 = 0
        while ordinal < instanceDescriptor.mappingCount {
            guard let record = mapping(at: ordinal, in: instance) else {
                return nil
            }
            if record.scalarValue == scalarValue {
                guard record.glyph.rawValue < instanceDescriptor.glyphCount else {
                    return nil
                }
                return .exact(record.glyph)
            }
            if record.scalarValue > scalarValue {
                break
            }
            ordinal += 1
        }
        return .replacement(instanceDescriptor.replacementGlyph)
    }
}

package extension GlyphMetrics {
    func checkedInkRectangle(at logicalOrigin: Point) -> Rect? {
        guard let x = GeometryArithmetic.add(logicalOrigin.x, offsetX),
            let y = GeometryArithmetic.add(logicalOrigin.y, offsetY)
        else {
            return nil
        }
        return Rect(origin: Point(x: x, y: y), size: inkSize)
    }

    func checkedAdvancedOrigin(from logicalOrigin: Point) -> Point? {
        guard let x = GeometryArithmetic.add(logicalOrigin.x, advanceX) else {
            return nil
        }
        return Point(x: x, y: logicalOrigin.y)
    }
}

package extension TextResourceValidator {
    static func isWithinCapacity(
        instanceCount: UInt16,
        glyphCount: UInt16,
        mappingCount: UInt16,
        realizationCount: UInt16,
        canonicalManifestByteCount: UInt32,
        payloadByteCount: UInt32
    ) -> Bool {
        instanceCount <= 1
            && glyphCount <= 256
            && mappingCount <= 256
            && realizationCount <= 2
            && canonicalManifestByteCount <= 16_384
            && payloadByteCount <= 65_536
    }

    static func withPayloadSlice<Result>(
        for record: GlyphRasterRecord,
        cataloguedRecord: GlyphRasterRecord?,
        realization: RasterRealizationID,
        cataloguedRealization: RasterRealizationDescriptor?,
        isAvailable: Bool,
        payload: UnsafeRawBufferPointer?,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        guard let cataloguedRecord,
            let cataloguedRealization,
            let payload,
            isAvailable,
            record == cataloguedRecord,
            realization == cataloguedRealization.id,
            record.glyph.rawValue < cataloguedRealization.glyphCount,
            cataloguedRealization.payloadByteCount <= 65_536,
            let payloadCount = UInt32(exactly: payload.count),
            payloadCount == cataloguedRealization.payloadByteCount,
            record.offset <= cataloguedRealization.payloadByteCount
        else {
            return nil
        }
        let end = record.offset.addingReportingOverflow(record.byteCount)
        guard !end.overflow,
            end.partialValue <= cataloguedRealization.payloadByteCount
        else {
            return nil
        }
        let startIndex = Int(record.offset)
        let endIndex = Int(end.partialValue)
        let slice = UnsafeRawBufferPointer(
            rebasing: payload[startIndex ..< endIndex]
        )
        return try body(slice)
    }

    static func isValidUnicodeScalar(_ scalarValue: UInt32) -> Bool {
        scalarValue <= 0x10_ffff
            && !(0xd800 ... 0xdfff).contains(scalarValue)
    }

    static func isValid(
        _ glyph: GlyphID,
        in instance: FontInstanceDescriptor
    ) -> Bool {
        glyph.rawValue < instance.glyphCount
    }

    static func isValid(
        _ realization: RasterRealizationID,
        in descriptor: TextResourceDescriptor
    ) -> Bool {
        realization.rawValue < descriptor.realizationCount
    }

    static func recordsFormGapFreePartition<R>(
        for realization: RasterRealizationDescriptor,
        in raster: borrowing R
    ) -> Bool where R: TextRasterResourceView {
        var expectedOffset: UInt32 = 0
        var glyphOrdinal: UInt32 = 0
        while glyphOrdinal < UInt32(realization.glyphCount) {
            let glyph = GlyphID(rawValue: UInt16(glyphOrdinal))
            guard
                let record = raster.record(
                    for: glyph,
                    realization: realization.id
                ),
                record.glyph == glyph,
                record.offset == expectedOffset
            else {
                return false
            }
            let nextOffset = expectedOffset.addingReportingOverflow(
                record.byteCount
            )
            guard !nextOffset.overflow,
                nextOffset.partialValue <= realization.payloadByteCount
            else {
                return false
            }
            expectedOffset = nextOffset.partialValue
            glyphOrdinal += 1
        }
        return expectedOffset == realization.payloadByteCount
    }

    static func isStructurallyValidMonochromeBitmap(
        record: GlyphRasterRecord,
        metrics: GlyphMetrics,
        bytes: UnsafeRawBufferPointer
    ) -> Bool {
        guard Int(record.byteCount) == bytes.count,
            metrics.inkSize.width == Int32(record.pixelWidth),
            metrics.inkSize.height == Int32(record.pixelHeight)
        else {
            return false
        }
        let expectedRowBytes = (UInt32(record.pixelWidth) + 7) / 8
        guard UInt32(record.rowByteCount) == expectedRowBytes else {
            return false
        }
        let expectedByteCount = expectedRowBytes.multipliedReportingOverflow(
            by: UInt32(record.pixelHeight)
        )
        guard !expectedByteCount.overflow,
            expectedByteCount.partialValue == record.byteCount
        else {
            return false
        }

        let usedBits = record.pixelWidth & 7
        guard usedBits != 0 else { return true }
        let unusedBits = UInt8(8 - usedBits)
        let unusedMask = UInt8((UInt16(1) << unusedBits) - 1)
        var row: UInt32 = 0
        while row < UInt32(record.pixelHeight) {
            let lastByte = Int(row * expectedRowBytes + expectedRowBytes - 1)
            guard bytes[lastByte] & unusedMask == 0 else { return false }
            row += 1
        }
        return true
    }

    static func monochromeBitmapCoverage(
        x: UInt16,
        y: UInt16,
        record: GlyphRasterRecord,
        bytes: UnsafeRawBufferPointer
    ) -> Bool? {
        guard x < record.pixelWidth,
            y < record.pixelHeight,
            UInt32(record.rowByteCount) * UInt32(record.pixelHeight)
                == record.byteCount,
            Int(record.byteCount) == bytes.count
        else {
            return nil
        }
        let byteIndex =
            UInt32(y) * UInt32(record.rowByteCount)
            + UInt32(x / 8)
        let mask = UInt8(0x80 >> UInt8(x & 7))
        return bytes[Int(byteIndex)] & mask != 0
    }

    static func isStructurallyValidPackagedOutline(
        record: GlyphRasterRecord,
        metrics: GlyphMetrics,
        bytes: UnsafeRawBufferPointer
    ) -> Bool {
        guard record.rowByteCount == 0,
            Int(record.byteCount) == bytes.count,
            metrics.inkSize.width == Int32(record.pixelWidth),
            metrics.inkSize.height == Int32(record.pixelHeight),
            bytes.count >= 5,
            bytes[0] == 1,
            readUInt16(bytes, at: 1) != 0,
            readUInt16(bytes, at: 3) != 0
        else {
            return false
        }
        if bytes.count == 5 {
            return true
        }

        var index = 5
        var expectsMove = true
        var sawTerminator = false
        while index < bytes.count {
            let opcode = bytes[index]
            index += 1
            if opcode == 5 || opcode == 6 {
                guard !expectsMove else { return false }
                expectsMove = true
                sawTerminator = true
                continue
            }
            guard opcode >= 1, opcode <= 4,
                index < bytes.count
            else {
                return false
            }
            let operandCount = Int(bytes[index])
            index += 1
            switch opcode {
            case 1:
                guard expectsMove, operandCount == 1 else { return false }
                expectsMove = false
            case 2:
                guard !expectsMove, operandCount == 1 else { return false }
            case 3:
                guard !expectsMove, operandCount > 0 else { return false }
            default:
                guard !expectsMove, operandCount == 3 else { return false }
            }
            let operandBytes = operandCount.multipliedReportingOverflow(by: 4)
            guard !operandBytes.overflow,
                operandBytes.partialValue <= bytes.count - index
            else {
                return false
            }
            var operand = 0
            while operand < operandCount {
                let x = readUInt16(bytes, at: index)
                let y = readUInt16(bytes, at: index + 2)
                let isImpliedPoint = x == 0x7fff && y == 0x7fff
                if isImpliedPoint && opcode != 3 {
                    return false
                }
                index += 4
                operand += 1
            }
            sawTerminator = false
        }
        return expectsMove && sawTerminator
    }

    private static func readUInt16(
        _ bytes: UnsafeRawBufferPointer,
        at index: Int
    ) -> UInt16 {
        (UInt16(bytes[index]) << 8) | UInt16(bytes[index + 1])
    }
}

package extension TextResourceValidator {
    /// Visits the schema-version-1 canonical manifest without materializing it.
    ///
    /// The callback receives each byte exactly once and in canonical order.
    /// `nil` means a declared table entry was unavailable, so no digest may be
    /// certified from the supplied views.
    static func forEachCanonicalManifestByte<M, R>(
        in resourcePackage: borrowing TextResourcePackage<M, R>,
        _ body: (UInt8) -> Void
    ) -> UInt32?
    where M: CanonicalTextMetricsView, R: TextRasterResourceView {
        var byteCount: UInt32 = 0

        @inline(__always)
        func emit(_ byte: UInt8) {
            body(byte)
            byteCount &+= 1
        }

        @inline(__always)
        func emitUInt16(_ value: UInt16) {
            emit(UInt8(truncatingIfNeeded: value >> 8))
            emit(UInt8(truncatingIfNeeded: value))
        }

        @inline(__always)
        func emitUInt32(_ value: UInt32) {
            emit(UInt8(truncatingIfNeeded: value >> 24))
            emit(UInt8(truncatingIfNeeded: value >> 16))
            emit(UInt8(truncatingIfNeeded: value >> 8))
            emit(UInt8(truncatingIfNeeded: value))
        }

        @inline(__always)
        func emitInt32(_ value: Int32) {
            emitUInt32(UInt32(bitPattern: value))
        }

        @inline(__always)
        func emitDigest(_ digest: TextResourceDigest) {
            emitUInt32(digest.word0)
            emitUInt32(digest.word1)
            emitUInt32(digest.word2)
            emitUInt32(digest.word3)
            emitUInt32(digest.word4)
            emitUInt32(digest.word5)
            emitUInt32(digest.word6)
            emitUInt32(digest.word7)
        }

        emit(0x47) // G
        emit(0x69) // i
        emit(0x66) // f
        emit(0x74) // t
        emit(0x55) // U
        emit(0x49) // I
        emit(0x54) // T
        emit(0x65) // e
        emit(0x78) // x
        emit(0x74) // t
        emit(0x52) // R
        emit(0x65) // e
        emit(0x73) // s
        emit(0x6f) // o
        emit(0x75) // u
        emit(0x72) // r
        emit(0x63) // c
        emit(0x65) // e
        emit(0x73) // s
        emit(0x2f) // /
        emit(0x76) // v
        emit(0x31) // 1

        let descriptor = resourcePackage.metrics.descriptor
        emitUInt16(descriptor.schemaVersion)
        emitUInt16(descriptor.instanceCount)

        var instanceOrdinal: UInt32 = 0
        while instanceOrdinal < UInt32(descriptor.instanceCount) {
            let index = UInt16(instanceOrdinal)
            guard let instance = resourcePackage.metrics.instance(at: index) else {
                return nil
            }
            emitUInt16(instance.id.instanceIndex)
            emitInt32(instance.lineMetrics.ascent)
            emitInt32(instance.lineMetrics.descent)
            emitInt32(instance.lineMetrics.lineGap)
            emitUInt16(instance.replacementGlyph.rawValue)
            emitUInt16(instance.glyphCount)
            emitUInt16(instance.mappingCount)

            var mappingOrdinal: UInt32 = 0
            while mappingOrdinal < UInt32(instance.mappingCount) {
                guard
                    let mapping = resourcePackage.metrics.mapping(
                        at: UInt16(mappingOrdinal),
                        in: instance.id
                    )
                else {
                    return nil
                }
                emitUInt32(mapping.scalarValue)
                emitUInt16(mapping.glyph.rawValue)
                mappingOrdinal += 1
            }

            var glyphOrdinal: UInt32 = 0
            while glyphOrdinal < UInt32(instance.glyphCount) {
                let glyph = GlyphID(rawValue: UInt16(glyphOrdinal))
                guard
                    let metrics = resourcePackage.metrics.metrics(
                        for: glyph,
                        in: instance.id
                    )
                else {
                    return nil
                }
                emitUInt16(glyph.rawValue)
                emitInt32(metrics.advanceX)
                emitInt32(metrics.offsetX)
                emitInt32(metrics.offsetY)
                emitInt32(metrics.inkSize.width)
                emitInt32(metrics.inkSize.height)
                glyphOrdinal += 1
            }
            instanceOrdinal += 1
        }

        emitUInt16(descriptor.realizationCount)
        var realizationOrdinal: UInt32 = 0
        while realizationOrdinal < UInt32(descriptor.realizationCount) {
            guard
                let realization = resourcePackage.raster.realization(
                    at: UInt16(realizationOrdinal)
                )
            else {
                return nil
            }
            emitUInt16(realization.id.rawValue)
            emitUInt16(realization.instance.instanceIndex)
            emit(realization.kind.rawValue)
            emitUInt16(realization.glyphCount)
            emitUInt32(realization.payloadByteCount)
            emitDigest(realization.payloadDigest)

            var glyphOrdinal: UInt32 = 0
            while glyphOrdinal < UInt32(realization.glyphCount) {
                let glyph = GlyphID(rawValue: UInt16(glyphOrdinal))
                guard
                    let record = resourcePackage.raster.record(
                        for: glyph,
                        realization: realization.id
                    )
                else {
                    return nil
                }
                emitUInt16(record.glyph.rawValue)
                emitUInt32(record.offset)
                emitUInt32(record.byteCount)
                emitUInt16(record.rowByteCount)
                emitUInt16(record.pixelWidth)
                emitUInt16(record.pixelHeight)
                glyphOrdinal += 1
            }
            realizationOrdinal += 1
        }
        return byteCount
    }

    /// Reconstructs and hashes the canonical manifest in one streaming pass.
    static func canonicalManifestDigest<M, R>(
        of resourcePackage: borrowing TextResourcePackage<M, R>
    ) -> (byteCount: UInt32, digest: TextResourceDigest)?
    where M: CanonicalTextMetricsView, R: TextRasterResourceView {
        var sha256 = _TextResourceSHA256()
        guard
            let byteCount = forEachCanonicalManifestByte(
                in: resourcePackage,
                { sha256.update(with: $0) }
            )
        else {
            return nil
        }
        return (byteCount, sha256.finalize())
    }

    /// Hashes exact borrowed bytes without depending on their address or on
    /// the host representation of any resource struct.
    static func sha256(
        of bytes: UnsafeRawBufferPointer
    ) -> TextResourceDigest {
        var sha256 = _TextResourceSHA256()
        for byte in bytes {
            sha256.update(with: byte)
        }
        return sha256.finalize()
    }
}

private struct _TextResourceSHA256 {
    private var h0: UInt32 = 0x6a09_e667
    private var h1: UInt32 = 0xbb67_ae85
    private var h2: UInt32 = 0x3c6e_f372
    private var h3: UInt32 = 0xa54f_f53a
    private var h4: UInt32 = 0x510e_527f
    private var h5: UInt32 = 0x9b05_688c
    private var h6: UInt32 = 0x1f83_d9ab
    private var h7: UInt32 = 0x5be0_cd19

    private var w0: UInt32 = 0
    private var w1: UInt32 = 0
    private var w2: UInt32 = 0
    private var w3: UInt32 = 0
    private var w4: UInt32 = 0
    private var w5: UInt32 = 0
    private var w6: UInt32 = 0
    private var w7: UInt32 = 0
    private var w8: UInt32 = 0
    private var w9: UInt32 = 0
    private var w10: UInt32 = 0
    private var w11: UInt32 = 0
    private var w12: UInt32 = 0
    private var w13: UInt32 = 0
    private var w14: UInt32 = 0
    private var w15: UInt32 = 0

    private var pendingWord: UInt32 = 0
    private var pendingByteCount: UInt8 = 0
    private var blockWordCount: UInt8 = 0
    private var totalByteCount: UInt64 = 0

    mutating func update(with byte: UInt8) {
        totalByteCount &+= 1
        pendingWord = (pendingWord << 8) | UInt32(byte)
        pendingByteCount &+= 1
        if pendingByteCount == 4 {
            append(word: pendingWord)
            pendingWord = 0
            pendingByteCount = 0
        }
    }

    mutating func finalize() -> TextResourceDigest {
        let messageBitCount = totalByteCount &* 8
        update(with: 0x80)
        while totalByteCount & 63 != 56 {
            update(with: 0)
        }
        update(with: UInt8(truncatingIfNeeded: messageBitCount >> 56))
        update(with: UInt8(truncatingIfNeeded: messageBitCount >> 48))
        update(with: UInt8(truncatingIfNeeded: messageBitCount >> 40))
        update(with: UInt8(truncatingIfNeeded: messageBitCount >> 32))
        update(with: UInt8(truncatingIfNeeded: messageBitCount >> 24))
        update(with: UInt8(truncatingIfNeeded: messageBitCount >> 16))
        update(with: UInt8(truncatingIfNeeded: messageBitCount >> 8))
        update(with: UInt8(truncatingIfNeeded: messageBitCount))
        return TextResourceDigest(
            word0: h0, word1: h1, word2: h2, word3: h3,
            word4: h4, word5: h5, word6: h6, word7: h7
        )
    }

    private mutating func append(word: UInt32) {
        setWord(Int(blockWordCount), word)
        blockWordCount &+= 1
        if blockWordCount == 16 {
            compressBlock()
            blockWordCount = 0
        }
    }

    private mutating func compressBlock() {
        var a = h0
        var b = h1
        var c = h2
        var d = h3
        var e = h4
        var f = h5
        var g = h6
        var h = h7
        var round = 0
        while round < 64 {
            let schedule: UInt32
            if round < 16 {
                schedule = word(round)
            } else {
                let s0 =
                    rotateRight(word((round - 15) & 15), by: 7)
                    ^ rotateRight(word((round - 15) & 15), by: 18)
                    ^ (word((round - 15) & 15) >> 3)
                let s1 =
                    rotateRight(word((round - 2) & 15), by: 17)
                    ^ rotateRight(word((round - 2) & 15), by: 19)
                    ^ (word((round - 2) & 15) >> 10)
                schedule =
                    word((round - 16) & 15) &+ s0
                    &+ word((round - 7) & 15) &+ s1
                setWord(round & 15, schedule)
            }
            let upperSigma1 =
                rotateRight(e, by: 6)
                ^ rotateRight(e, by: 11) ^ rotateRight(e, by: 25)
            let choose = (e & f) ^ ((~e) & g)
            let temporary1 =
                h &+ upperSigma1 &+ choose
                &+ Self.roundConstant(round) &+ schedule
            let upperSigma0 =
                rotateRight(a, by: 2)
                ^ rotateRight(a, by: 13) ^ rotateRight(a, by: 22)
            let majority = (a & b) ^ (a & c) ^ (b & c)
            let temporary2 = upperSigma0 &+ majority
            h = g
            g = f
            f = e
            e = d &+ temporary1
            d = c
            c = b
            b = a
            a = temporary1 &+ temporary2
            round += 1
        }
        h0 &+= a
        h1 &+= b
        h2 &+= c
        h3 &+= d
        h4 &+= e
        h5 &+= f
        h6 &+= g
        h7 &+= h
    }

    @inline(__always)
    private func rotateRight(_ value: UInt32, by count: UInt32) -> UInt32 {
        (value >> count) | (value << (32 - count))
    }

    private func word(_ index: Int) -> UInt32 {
        switch index {
        case 0: w0
        case 1: w1
        case 2: w2
        case 3: w3
        case 4: w4
        case 5: w5
        case 6: w6
        case 7: w7
        case 8: w8
        case 9: w9
        case 10: w10
        case 11: w11
        case 12: w12
        case 13: w13
        case 14: w14
        default: w15
        }
    }

    private mutating func setWord(_ index: Int, _ value: UInt32) {
        switch index {
        case 0: w0 = value
        case 1: w1 = value
        case 2: w2 = value
        case 3: w3 = value
        case 4: w4 = value
        case 5: w5 = value
        case 6: w6 = value
        case 7: w7 = value
        case 8: w8 = value
        case 9: w9 = value
        case 10: w10 = value
        case 11: w11 = value
        case 12: w12 = value
        case 13: w13 = value
        case 14: w14 = value
        default: w15 = value
        }
    }

    private static func roundConstant(_ index: Int) -> UInt32 {
        switch index {
        case 0: 0x428a_2f98
        case 1: 0x7137_4491
        case 2: 0xb5c0_fbcf
        case 3: 0xe9b5_dba5
        case 4: 0x3956_c25b
        case 5: 0x59f1_11f1
        case 6: 0x923f_82a4
        case 7: 0xab1c_5ed5
        case 8: 0xd807_aa98
        case 9: 0x1283_5b01
        case 10: 0x2431_85be
        case 11: 0x550c_7dc3
        case 12: 0x72be_5d74
        case 13: 0x80de_b1fe
        case 14: 0x9bdc_06a7
        case 15: 0xc19b_f174
        case 16: 0xe49b_69c1
        case 17: 0xefbe_4786
        case 18: 0x0fc1_9dc6
        case 19: 0x240c_a1cc
        case 20: 0x2de9_2c6f
        case 21: 0x4a74_84aa
        case 22: 0x5cb0_a9dc
        case 23: 0x76f9_88da
        case 24: 0x983e_5152
        case 25: 0xa831_c66d
        case 26: 0xb003_27c8
        case 27: 0xbf59_7fc7
        case 28: 0xc6e0_0bf3
        case 29: 0xd5a7_9147
        case 30: 0x06ca_6351
        case 31: 0x1429_2967
        case 32: 0x27b7_0a85
        case 33: 0x2e1b_2138
        case 34: 0x4d2c_6dfc
        case 35: 0x5338_0d13
        case 36: 0x650a_7354
        case 37: 0x766a_0abb
        case 38: 0x81c2_c92e
        case 39: 0x9272_2c85
        case 40: 0xa2bf_e8a1
        case 41: 0xa81a_664b
        case 42: 0xc24b_8b70
        case 43: 0xc76c_51a3
        case 44: 0xd192_e819
        case 45: 0xd699_0624
        case 46: 0xf40e_3585
        case 47: 0x106a_a070
        case 48: 0x19a4_c116
        case 49: 0x1e37_6c08
        case 50: 0x2748_774c
        case 51: 0x34b0_bcb5
        case 52: 0x391c_0cb3
        case 53: 0x4ed8_aa4a
        case 54: 0x5b9c_ca4f
        case 55: 0x682e_6ff3
        case 56: 0x748f_82ee
        case 57: 0x78a5_636f
        case 58: 0x84c8_7814
        case 59: 0x8cc7_0208
        case 60: 0x90be_fffa
        case 61: 0xa450_6ceb
        case 62: 0xbef9_a3f7
        default: 0xc671_78f2
        }
    }
}
