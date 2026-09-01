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
        requiring realization: RasterRealizationID
    ) -> TextResourceValidationResult
    where M: CanonicalTextMetricsView, R: TextRasterResourceView {
        // Milestone 1 exposes the exact admission seam but admits no package.
        // Milestone 2 replaces this fail-closed result with complete validation.
        .invalid(.integrityMismatch)
    }
}
