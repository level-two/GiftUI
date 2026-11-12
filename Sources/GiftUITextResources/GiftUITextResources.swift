import GiftUI

@usableFromInline
package struct TextResourceDigest: Equatable, Hashable, Sendable {
    @usableFromInline
    package let word0: UInt32
    @usableFromInline
    package let word1: UInt32
    @usableFromInline
    package let word2: UInt32
    @usableFromInline
    package let word3: UInt32
    @usableFromInline
    package let word4: UInt32
    @usableFromInline
    package let word5: UInt32
    @usableFromInline
    package let word6: UInt32
    @usableFromInline
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

@usableFromInline
package struct FontResourceID: RawRepresentable, Equatable, Hashable, Sendable {
    @usableFromInline
    package let rawValue: TextResourceDigest

    @usableFromInline
    package init(rawValue: TextResourceDigest) {
        self.rawValue = rawValue
    }
}

@usableFromInline
package struct FontInstanceID: Equatable, Hashable, Sendable {
    @usableFromInline
    package let resource: FontResourceID
    @usableFromInline
    package let instanceIndex: UInt16

    package init(resource: FontResourceID, instanceIndex: UInt16) {
        self.resource = resource
        self.instanceIndex = instanceIndex
    }
}

@usableFromInline
package struct GlyphID: RawRepresentable, Equatable, Hashable, Sendable {
    @usableFromInline
    package let rawValue: UInt16

    @usableFromInline
    package init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

@usableFromInline
package struct RasterRealizationID:
    RawRepresentable, Equatable, Hashable, Sendable
{
    @usableFromInline
    package let rawValue: UInt16

    @usableFromInline
    package init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

package enum TextRasterKind: UInt8, Equatable, Sendable {
    case monochromeBitmap1 = 0
    case packagedOutline = 1
}

@usableFromInline
package struct FontLineMetrics: Equatable, Sendable {
    @usableFromInline
    package let ascent: GeometryScalar
    @usableFromInline
    package let descent: GeometryScalar
    @usableFromInline
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

@usableFromInline
package struct GlyphMetrics: Equatable, Sendable {
    @usableFromInline
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

@usableFromInline
package struct FontInstanceDescriptor: Equatable, Sendable {
    @usableFromInline
    package let id: FontInstanceID
    @usableFromInline
    package let lineMetrics: FontLineMetrics
    package let replacementGlyph: GlyphID
    @usableFromInline
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

@usableFromInline
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

@usableFromInline
package struct TextResourceDescriptor: Equatable, Sendable {
    package let schemaVersion: UInt16
    @usableFromInline
    package let resource: FontResourceID
    @usableFromInline
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

@usableFromInline
package enum GlyphMapping: Equatable, Sendable {
    case exact(GlyphID)
    case replacement(GlyphID)
}

@usableFromInline
package struct ScalarGlyphMappingRecord: Equatable, Sendable {
    package let scalarValue: UInt32
    package let glyph: GlyphID

    package init(scalarValue: UInt32, glyph: GlyphID) {
        self.scalarValue = scalarValue
        self.glyph = glyph
    }
}

@usableFromInline
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

@usableFromInline
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

@usableFromInline
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

@usableFromInline
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

@usableFromInline
package enum TextResourceValidationResult: Equatable, Sendable {
    case valid
    case invalid(TextResourceValidationError)
}

package enum TextResourceValidator {
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    package static func instancesMatch(_ lhs: FontInstanceID, _ rhs: FontInstanceID) -> Bool {
        lhs == rhs
    }

    package static func validate<M, R>(
        _ resourcePackage: borrowing TextResourcePackage<M, R>,
        requiring requiredRealization: RasterRealizationID
    ) -> TextResourceValidationResult
    where M: CanonicalTextMetricsView, R: TextRasterResourceView {
        var engine = TextResourceValidationEngine(requiring: requiredRealization)
        while true {
            switch engine.request() {
            case .metricsDescriptor: engine.acceptDescriptor(resourcePackage.metrics.descriptor)
            case .rasterDescriptor: engine.acceptDescriptor(resourcePackage.raster.descriptor)
            case .instance(let index):
                engine.acceptInstance(resourcePackage.metrics.instance(at: index))
            case .mapping(let index, let instance):
                engine.acceptMapping(resourcePackage.metrics.mapping(at: index, in: instance))
            case .metrics(let glyph, let instance):
                engine.acceptMetrics(resourcePackage.metrics.metrics(for: glyph, in: instance))
            case .realization(let index):
                engine.acceptRealization(resourcePackage.raster.realization(at: index))
            case .available(let id):
                engine.acceptAvailability(resourcePackage.raster.isPayloadAvailable(for: id))
            case .record(let glyph, let id):
                engine.acceptRecord(resourcePackage.raster.record(for: glyph, realization: id))
            case .payload(let record, let id):
                let borrowed: Bool? = resourcePackage.raster.withPayload(
                    for: record, realization: id
                ) { bytes in
                    engine.acceptPayloadBytes(bytes)
                    return true
                }
                engine.finishPayload(borrowed)
            case .manifest: engine.acceptManifest(canonicalManifestDigest(of: resourcePackage))
            case .finished: return engine.result()
            }
        }

    }
}

// One bounded policy engine owns validation state. Adapters only perform the
// ordered synchronous queries requested here; no resource borrow is retained.
internal struct TextResourceValidationEngine {
    internal enum Request {
        case metricsDescriptor, rasterDescriptor
        case instance(UInt16)
        case mapping(UInt16, FontInstanceID)
        case metrics(GlyphID, FontInstanceID)
        case realization(UInt16)
        case available(RasterRealizationID)
        case record(GlyphID, RasterRealizationID)
        case payload(GlyphRasterRecord, RasterRealizationID)
        case manifest, finished
    }
    private enum Phase {
        case metricsDescriptor, rasterDescriptor, instance, mapping, mappingTail
        case metrics, metricsTail, instanceTail, realization, requiredAvailable
        case available, record, recordMetrics, payload, recordTail
        case realizationTail, availabilityTail, manifest, done
    }
    private var phase: Phase = .metricsDescriptor
    private var predicates = _TextResourceValidationPredicates()
    private var metricsDescriptor: TextResourceDescriptor?
    private var rasterDescriptor: TextResourceDescriptor?
    private let requiredRealization: RasterRealizationID
    private var canonicalInstance: FontInstanceDescriptor?
    private var instance: FontInstanceDescriptor?
    private var realization: RasterRealizationDescriptor?
    private var record: GlyphRasterRecord?
    private var glyphMetrics: GlyphMetrics?
    private var instanceOrdinal: UInt16 = 0
    private var mappingOrdinal: UInt16 = 0
    private var glyphOrdinal: UInt16 = 0
    private var realizationOrdinal: UInt16 = 0
    private var recordOrdinal: UInt16 = 0
    private var precedingScalar: UInt32?
    private var anyAvailablePayload = false
    private var requiredIsCatalogued = false
    private var requiredIsAvailable = false
    private var isAvailable = false
    private var expectedOffset: UInt32 = 0
    private var payloadSHA256 = _TextResourceSHA256()
    private var payloadBytesBorrowed: UInt32 = 0
    private var invocationCount: UInt8 = 0

    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal init(requiring realization: RasterRealizationID) {
        requiredRealization = realization
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal func request() -> Request {
        switch phase {
        case .metricsDescriptor: return .metricsDescriptor
        case .rasterDescriptor: return .rasterDescriptor
        case .instance: return .instance(instanceOrdinal)
        case .instanceTail: return .instance(metricsDescriptor!.instanceCount)
        case .mapping: return .mapping(mappingOrdinal, instance!.id)
        case .mappingTail: return .mapping(instance!.mappingCount, instance!.id)
        case .metrics: return .metrics(GlyphID(rawValue: glyphOrdinal), instance!.id)
        case .metricsTail: return .metrics(GlyphID(rawValue: instance!.glyphCount), instance!.id)
        case .realization: return .realization(realizationOrdinal)
        case .realizationTail: return .realization(metricsDescriptor!.realizationCount)
        case .requiredAvailable, .available: return .available(realization!.id)
        case .availabilityTail:
            return .available(RasterRealizationID(rawValue: metricsDescriptor!.realizationCount))
        case .record: return .record(GlyphID(rawValue: recordOrdinal), realization!.id)
        case .recordTail:
            return .record(GlyphID(rawValue: realization!.glyphCount), realization!.id)
        case .recordMetrics:
            return .metrics(GlyphID(rawValue: recordOrdinal), canonicalInstance!.id)
        case .payload: return .payload(record!, realization!.id)
        case .manifest: return .manifest
        case .done: return .finished
        }
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal func result() -> TextResourceValidationResult {
        precondition(phase == .done)
        return predicates.result
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptDescriptor(_ descriptor: TextResourceDescriptor) {
        if phase == .metricsDescriptor {
            metricsDescriptor = descriptor
            phase = .rasterDescriptor
            return
        }
        precondition(phase == .rasterDescriptor)
        rasterDescriptor = descriptor
        let metricsDescriptor = self.metricsDescriptor!
        let rasterDescriptor = descriptor
        predicates.unsupportedSchema =
            metricsDescriptor.schemaVersion != 1
            || rasterDescriptor.schemaVersion != 1
        predicates.capacityExceeded =
            !TextResourceValidator.isWithinCapacity(
                instanceCount: metricsDescriptor.instanceCount,
                glyphCount: 0,
                mappingCount: 0,
                realizationCount: metricsDescriptor.realizationCount,
                canonicalManifestByteCount:
                    metricsDescriptor.canonicalManifestByteCount,
                payloadByteCount: 0
            )
            || !TextResourceValidator.isWithinCapacity(
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
        nextInstance()
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    private mutating func nextInstance() {
        let descriptor = metricsDescriptor!
        if instanceOrdinal < min(descriptor.instanceCount, 1) {
            phase = .instance
        } else if descriptor.instanceCount <= 1 {
            phase = .instanceTail
        } else {
            nextRealization()
        }
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptInstance(_ value: FontInstanceDescriptor?) {
        if phase == .instanceTail {
            if case .some = value { predicates.invalidCount = true }
            nextRealization()
            return
        }
        precondition(phase == .instance)
        guard let instance = value else {
            predicates.invalidCount = true
            instanceOrdinal += 1
            nextInstance()
            return
        }
        self.instance = instance
        let metricsDescriptor = self.metricsDescriptor!
        if case .some = canonicalInstance {
            predicates.invalidIdentity = true
        } else {
            canonicalInstance = instance
        }
        predicates.capacityExceeded =
            predicates.capacityExceeded
            || !TextResourceValidator.isWithinCapacity(
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
        let malformedLineMetrics: Bool
        if predicates.malformedMetrics
            || line.ascent <= 0
            || line.descent < 0
            || line.lineGap < 0
        {
            malformedLineMetrics = true
        } else if case .none = lineSum {
            malformedLineMetrics = true
        } else {
            malformedLineMetrics = lineSum == 0
        }
        predicates.malformedMetrics = malformedLineMetrics
        mappingOrdinal = 0
        precedingScalar = nil
        nextMapping()
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    private mutating func nextMapping() {
        if mappingOrdinal < min(instance!.mappingCount, 256) {
            phase = .mapping
        } else if instance!.mappingCount <= 256 {
            phase = .mappingTail
        } else {
            glyphOrdinal = 0
            nextMetrics()
        }
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptMapping(_ value: ScalarGlyphMappingRecord?) {
        if phase == .mappingTail {
            if case .some = value { predicates.invalidCount = true }
            glyphOrdinal = 0
            nextMetrics()
            return
        }
        precondition(phase == .mapping)
        if let mapping = value {
            let instance = self.instance!
            predicates.malformedMapping =
                predicates.malformedMapping
                || !TextResourceValidator.isValidUnicodeScalar(mapping.scalarValue)
                || mapping.scalarValue == 0x0a
                || mapping.scalarValue == 0x0d
                || mapping.glyph.rawValue >= instance.glyphCount
            if let precedingScalar,
                mapping.scalarValue <= precedingScalar
            {
                predicates.malformedMapping = true
            }
            precedingScalar = mapping.scalarValue
        } else {
            predicates.invalidCount = true
        }
        mappingOrdinal += 1
        nextMapping()
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    private mutating func nextMetrics() {
        if glyphOrdinal < min(instance!.glyphCount, 256) {
            phase = .metrics
        } else if instance!.glyphCount <= 256 {
            phase = .metricsTail
        } else {
            instanceOrdinal += 1
            nextInstance()
        }
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptMetrics(_ value: GlyphMetrics?) {
        if phase == .recordMetrics {
            glyphMetrics = value
            finishRecordMetrics()
            return
        }
        if phase == .metricsTail {
            if case .some = value { predicates.invalidCount = true }
            instanceOrdinal += 1
            nextInstance()
            return
        }
        precondition(phase == .metrics)
        if let glyphMetrics = value {
            let malformedGlyphMetrics: Bool
            if predicates.malformedMetrics || glyphMetrics.advanceX < 0 {
                malformedGlyphMetrics = true
            } else if case .none = GeometryArithmetic.add(
                glyphMetrics.offsetX,
                glyphMetrics.inkSize.width
            ) {
                malformedGlyphMetrics = true
            } else if case .none = GeometryArithmetic.add(
                glyphMetrics.offsetY,
                glyphMetrics.inkSize.height
            ) {
                malformedGlyphMetrics = true
            } else {
                malformedGlyphMetrics = false
            }
            predicates.malformedMetrics = malformedGlyphMetrics
        } else {
            predicates.invalidCount = true
        }
        glyphOrdinal += 1
        nextMetrics()
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    private mutating func nextRealization() {
        let descriptor = metricsDescriptor!
        if realizationOrdinal < min(descriptor.realizationCount, 2) {
            phase = .realization
        } else if descriptor.realizationCount <= 2 {
            phase = .realizationTail
        } else {
            phase = .availabilityTail
        }
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptRealization(_ value: RasterRealizationDescriptor?) {
        if phase == .realizationTail {
            if case .some = value { predicates.invalidCount = true }
            phase = .availabilityTail
            return
        }
        precondition(phase == .realization)
        guard let realization = value else {
            predicates.invalidCount = true
            realizationOrdinal += 1
            nextRealization()
            return
        }
        self.realization = realization
        if realization.id == requiredRealization {
            requiredIsCatalogued = true
            phase = .requiredAvailable
        } else {
            phase = .available
        }
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptAvailability(_ value: Bool) {
        if phase == .requiredAvailable {
            requiredIsAvailable = value
            phase = .available
            return
        }
        if phase == .availabilityTail {
            if value { predicates.invalidIdentity = true }
            predicates.incompatibleViews =
                predicates.incompatibleViews
                || !anyAvailablePayload
                || !requiredIsCatalogued
                || !requiredIsAvailable
            phase = .manifest
            return
        }
        precondition(phase == .available)
        isAvailable = value
        let isAvailable = value
        let realization = self.realization!
        let rasterDescriptor = self.rasterDescriptor!
        anyAvailablePayload = anyAvailablePayload || isAvailable
        predicates.capacityExceeded =
            predicates.capacityExceeded
            || !TextResourceValidator.isWithinCapacity(
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
        recordOrdinal = 0
        expectedOffset = 0
        payloadSHA256 = _TextResourceSHA256()
        payloadBytesBorrowed = 0
        nextRecord()
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    private mutating func nextRecord() {
        if recordOrdinal < min(realization!.glyphCount, 256) {
            phase = .record
        } else if realization!.glyphCount <= 256 {
            phase = .recordTail
        } else {
            finishRealization()
        }
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptRecord(_ value: GlyphRasterRecord?) {
        if phase == .recordTail {
            if case .some = value { predicates.invalidCount = true }
            finishRealization()
            return
        }
        precondition(phase == .record)
        guard let record = value else {
            predicates.invalidCount = true
            recordOrdinal += 1
            nextRecord()
            return
        }
        self.record = record
        let glyph = GlyphID(rawValue: recordOrdinal)
        let realization = self.realization!
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
        if case .some = canonicalInstance {
            phase = .recordMetrics
        } else {
            glyphMetrics = nil
            finishRecordMetrics()
        }
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    private mutating func finishRecordMetrics() {
        let glyphMetrics = self.glyphMetrics
        let record = self.record!
        let realization = self.realization!
        if case .none = glyphMetrics {
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
            invocationCount = 0
            phase = .payload
        } else {
            recordOrdinal += 1
            nextRecord()
        }
    }
    // Each callback is consumed synchronously. Only scalar hash/validation
    // state survives it, never the borrowed payload or its address.
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptPayloadBytes(_ bytes: UnsafeRawBufferPointer) {
        precondition(phase == .payload)
        let record = self.record!
        let realization = self.realization!
        let glyphMetrics = self.glyphMetrics
        if invocationCount < 2 {
            invocationCount += 1
        }
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
                if !TextResourceValidator.isStructurallyValidMonochromeBitmap(
                    record: record,
                    metrics: glyphMetrics,
                    bytes: bytes
                ) {
                    predicates.malformedRasterRecord = true
                }
            case .packagedOutline:
                if !TextResourceValidator.isStructurallyValidPackagedOutline(
                    record: record,
                    metrics: glyphMetrics,
                    bytes: bytes
                ) {
                    predicates.malformedRasterRecord = true
                }
            }
        }
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func finishPayload(_ borrowed: Bool?) {
        precondition(phase == .payload)
        if borrowed != true || invocationCount != 1 {
            predicates.incompatibleViews = true
        }
        recordOrdinal += 1
        nextRecord()
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    private mutating func finishRealization() {
        let realization = self.realization!
        predicates.malformedRasterRecord =
            predicates.malformedRasterRecord
            || expectedOffset != realization.payloadByteCount
        if isAvailable {
            predicates.integrityMismatch =
                predicates.integrityMismatch
                || payloadSHA256.finalize() != realization.payloadDigest
        }
        realizationOrdinal += 1
        nextRealization()
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptManifest(
        _ manifest: (byteCount: UInt32, digest: TextResourceDigest)?
    ) {
        precondition(phase == .manifest)
        let metricsDescriptor = self.metricsDescriptor!
        if let manifest {
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
        phase = .done
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
        var engine = TextResourceManifestEngine(hashing: false)
        while true {
            switch engine.request() {
            case .byte(let byte): body(byte)
            case .descriptor: engine.acceptDescriptor(resourcePackage.metrics.descriptor)
            case .instance(let index):
                engine.acceptInstance(resourcePackage.metrics.instance(at: index))
            case .mapping(let index, let instance):
                engine.acceptMapping(resourcePackage.metrics.mapping(at: index, in: instance))
            case .metrics(let glyph, let instance):
                engine.acceptMetrics(resourcePackage.metrics.metrics(for: glyph, in: instance))
            case .realization(let index):
                engine.acceptRealization(resourcePackage.raster.realization(at: index))
            case .record(let glyph, let id):
                engine.acceptRecord(resourcePackage.raster.record(for: glyph, realization: id))
            case .finished: return engine.byteCount()
            }
        }
    }

    /// Reconstructs and hashes the canonical manifest in one streaming pass.
    static func canonicalManifestDigest<M, R>(
        of resourcePackage: borrowing TextResourcePackage<M, R>
    ) -> (byteCount: UInt32, digest: TextResourceDigest)?
    where M: CanonicalTextMetricsView, R: TextRasterResourceView {
        var engine = TextResourceManifestEngine(hashing: true)
        while true {
            switch engine.request() {
            case .byte: break
            case .descriptor: engine.acceptDescriptor(resourcePackage.metrics.descriptor)
            case .instance(let index):
                engine.acceptInstance(resourcePackage.metrics.instance(at: index))
            case .mapping(let index, let instance):
                engine.acceptMapping(resourcePackage.metrics.mapping(at: index, in: instance))
            case .metrics(let glyph, let instance):
                engine.acceptMetrics(resourcePackage.metrics.metrics(for: glyph, in: instance))
            case .realization(let index):
                engine.acceptRealization(resourcePackage.raster.realization(at: index))
            case .record(let glyph, let id):
                engine.acceptRecord(resourcePackage.raster.record(for: glyph, realization: id))
            case .finished: return engine.digest()
            }
        }
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

// This independent full traversal deliberately does not reuse the validator's
// capped scan. Its pending emission holds one scalar, never a resource borrow.
internal struct TextResourceManifestEngine {
    internal enum Request {
        case byte(UInt8)
        case descriptor
        case instance(UInt16)
        case mapping(UInt16, FontInstanceID)
        case metrics(GlyphID, FontInstanceID)
        case realization(UInt16)
        case record(GlyphID, RasterRealizationID)
        case finished
    }
    private enum Phase {
        case header, descriptor, descriptorFields, instance, instanceFields
        case mapping, mappingFields, metrics, metricsFields
        case realizationCount, realization, realizationFields, record, recordFields, done
    }
    private var phase: Phase = .header
    private var field: UInt8 = 0
    private var pending: UInt32 = 0
    private var pendingBytes: UInt8 = 0
    private var descriptor: TextResourceDescriptor?
    private var instance: FontInstanceDescriptor?
    private var mapping: ScalarGlyphMappingRecord?
    private var metrics: GlyphMetrics?
    private var realization: RasterRealizationDescriptor?
    private var record: GlyphRasterRecord?
    private var instanceOrdinal: UInt32 = 0
    private var mappingOrdinal: UInt32 = 0
    private var glyphOrdinal: UInt32 = 0
    private var realizationOrdinal: UInt32 = 0
    private var failed = false
    private var count: UInt32 = 0
    private let hashing: Bool
    private var sha256 = _TextResourceSHA256()
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal init(hashing: Bool) { self.hashing = hashing }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    private mutating func emit(_ value: UInt32, bytes: UInt8) {
        pending = value
        pendingBytes = bytes
        field += 1
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func request() -> Request {
        while true {
            if pendingBytes != 0 {
                pendingBytes -= 1
                let byte = UInt8(truncatingIfNeeded: pending >> (UInt32(pendingBytes) * 8))
                count &+= 1
                if hashing { sha256.update(with: byte) }
                return .byte(byte)
            }
            switch phase {
            case .header:
                let byte: UInt8
                switch field {
                case 0: byte = 71
                case 1: byte = 105
                case 2: byte = 102
                case 3: byte = 116
                case 4: byte = 85
                case 5: byte = 73
                case 6: byte = 84
                case 7: byte = 101
                case 8: byte = 120
                case 9: byte = 116
                case 10: byte = 82
                case 11: byte = 101
                case 12: byte = 115
                case 13: byte = 111
                case 14: byte = 117
                case 15: byte = 114
                case 16: byte = 99
                case 17: byte = 101
                case 18: byte = 115
                case 19: byte = 47
                case 20: byte = 118
                case 21: byte = 49
                default:
                    phase = .descriptor
                    field = 0
                    continue
                }
                field += 1
                count &+= 1
                if hashing { sha256.update(with: byte) }
                return .byte(byte)
            case .descriptor: return .descriptor
            case .descriptorFields:
                switch field {
                case 0: emit(UInt32(descriptor!.schemaVersion), bytes: 2)
                case 1: emit(UInt32(descriptor!.instanceCount), bytes: 2)
                default:
                    field = 0
                    phase = .instance
                }
            case .instance:
                if instanceOrdinal < UInt32(descriptor!.instanceCount) {
                    return .instance(UInt16(instanceOrdinal))
                }
                phase = .realizationCount
                field = 0
            case .instanceFields:
                let value = instance!
                switch field {
                case 0: emit(UInt32(value.id.instanceIndex), bytes: 2)
                case 1: emit(UInt32(bitPattern: value.lineMetrics.ascent), bytes: 4)
                case 2: emit(UInt32(bitPattern: value.lineMetrics.descent), bytes: 4)
                case 3: emit(UInt32(bitPattern: value.lineMetrics.lineGap), bytes: 4)
                case 4: emit(UInt32(value.replacementGlyph.rawValue), bytes: 2)
                case 5: emit(UInt32(value.glyphCount), bytes: 2)
                case 6: emit(UInt32(value.mappingCount), bytes: 2)
                default:
                    field = 0
                    mappingOrdinal = 0
                    phase = .mapping
                }
            case .mapping:
                if mappingOrdinal < UInt32(instance!.mappingCount) {
                    return .mapping(UInt16(mappingOrdinal), instance!.id)
                }
                glyphOrdinal = 0
                phase = .metrics
            case .mappingFields:
                switch field {
                case 0: emit(mapping!.scalarValue, bytes: 4)
                case 1: emit(UInt32(mapping!.glyph.rawValue), bytes: 2)
                default:
                    mappingOrdinal += 1
                    field = 0
                    phase = .mapping
                }
            case .metrics:
                if glyphOrdinal < UInt32(instance!.glyphCount) {
                    return .metrics(GlyphID(rawValue: UInt16(glyphOrdinal)), instance!.id)
                }
                instanceOrdinal += 1
                phase = .instance
            case .metricsFields:
                let value = metrics!
                switch field {
                case 0: emit(glyphOrdinal, bytes: 2)
                case 1: emit(UInt32(bitPattern: value.advanceX), bytes: 4)
                case 2: emit(UInt32(bitPattern: value.offsetX), bytes: 4)
                case 3: emit(UInt32(bitPattern: value.offsetY), bytes: 4)
                case 4: emit(UInt32(bitPattern: value.inkSize.width), bytes: 4)
                case 5: emit(UInt32(bitPattern: value.inkSize.height), bytes: 4)
                default:
                    glyphOrdinal += 1
                    field = 0
                    phase = .metrics
                }
            case .realizationCount:
                emit(UInt32(descriptor!.realizationCount), bytes: 2)
                field = 0
                phase = .realization
            case .realization:
                if realizationOrdinal < UInt32(descriptor!.realizationCount) {
                    return .realization(UInt16(realizationOrdinal))
                }
                phase = .done
            case .realizationFields:
                let value = realization!
                switch field {
                case 0: emit(UInt32(value.id.rawValue), bytes: 2)
                case 1: emit(UInt32(value.instance.instanceIndex), bytes: 2)
                case 2: emit(UInt32(value.kind.rawValue), bytes: 1)
                case 3: emit(UInt32(value.glyphCount), bytes: 2)
                case 4: emit(value.payloadByteCount, bytes: 4)
                case 5: emit(value.payloadDigest.word0, bytes: 4)
                case 6: emit(value.payloadDigest.word1, bytes: 4)
                case 7: emit(value.payloadDigest.word2, bytes: 4)
                case 8: emit(value.payloadDigest.word3, bytes: 4)
                case 9: emit(value.payloadDigest.word4, bytes: 4)
                case 10: emit(value.payloadDigest.word5, bytes: 4)
                case 11: emit(value.payloadDigest.word6, bytes: 4)
                case 12: emit(value.payloadDigest.word7, bytes: 4)
                default:
                    glyphOrdinal = 0
                    field = 0
                    phase = .record
                }
            case .record:
                if glyphOrdinal < UInt32(realization!.glyphCount) {
                    return .record(GlyphID(rawValue: UInt16(glyphOrdinal)), realization!.id)
                }
                realizationOrdinal += 1
                phase = .realization
            case .recordFields:
                let value = record!
                switch field {
                case 0: emit(UInt32(value.glyph.rawValue), bytes: 2)
                case 1: emit(value.offset, bytes: 4)
                case 2: emit(value.byteCount, bytes: 4)
                case 3: emit(UInt32(value.rowByteCount), bytes: 2)
                case 4: emit(UInt32(value.pixelWidth), bytes: 2)
                case 5: emit(UInt32(value.pixelHeight), bytes: 2)
                default:
                    glyphOrdinal += 1
                    field = 0
                    phase = .record
                }
            case .done: return .finished
            }
        }
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptDescriptor(_ value: TextResourceDescriptor) {
        precondition(phase == .descriptor)
        descriptor = value
        phase = .descriptorFields
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptInstance(_ value: FontInstanceDescriptor?) {
        precondition(phase == .instance)
        guard let value else {
            fail()
            return
        }
        instance = value
        phase = .instanceFields
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptMapping(_ value: ScalarGlyphMappingRecord?) {
        precondition(phase == .mapping)
        guard let value else {
            fail()
            return
        }
        mapping = value
        phase = .mappingFields
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptMetrics(_ value: GlyphMetrics?) {
        precondition(phase == .metrics)
        guard let value else {
            fail()
            return
        }
        metrics = value
        phase = .metricsFields
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptRealization(_ value: RasterRealizationDescriptor?) {
        precondition(phase == .realization)
        guard let value else {
            fail()
            return
        }
        realization = value
        phase = .realizationFields
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func acceptRecord(_ value: GlyphRasterRecord?) {
        precondition(phase == .record)
        guard let value else {
            fail()
            return
        }
        record = value
        phase = .recordFields
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    private mutating func fail() {
        failed = true
        phase = .done
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal func byteCount() -> UInt32? {
        precondition(phase == .done)
        return failed ? nil : count
    }
    #if GIFTUI_TEXT_ENGINE_QUALIFICATION
        @_noAllocation
    #endif
    internal mutating func digest() -> (byteCount: UInt32, digest: TextResourceDigest)? {
        precondition(phase == .done && hashing)
        guard !failed else { return nil }
        return (count, sha256.finalize())
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
