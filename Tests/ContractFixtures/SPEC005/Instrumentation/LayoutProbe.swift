#if !GIFTUI_LAYOUT_PROBE_LOCAL
import GiftUITextResources
#endif

public enum GiftUITextResourceLayoutProbe {
    @inline(never) public static func digestSize() -> UInt32 { UInt32(MemoryLayout<TextResourceDigest>.size) }
    @inline(never) public static func digestStride() -> UInt32 { UInt32(MemoryLayout<TextResourceDigest>.stride) }
    @inline(never) public static func digestAlignment() -> UInt32 { UInt32(MemoryLayout<TextResourceDigest>.alignment) }
    @inline(never) public static func resourceIDSize() -> UInt32 { UInt32(MemoryLayout<FontResourceID>.size) }
    @inline(never) public static func resourceIDStride() -> UInt32 { UInt32(MemoryLayout<FontResourceID>.stride) }
    @inline(never) public static func resourceIDAlignment() -> UInt32 { UInt32(MemoryLayout<FontResourceID>.alignment) }
    @inline(never) public static func instanceIDSize() -> UInt32 { UInt32(MemoryLayout<FontInstanceID>.size) }
    @inline(never) public static func instanceIDStride() -> UInt32 { UInt32(MemoryLayout<FontInstanceID>.stride) }
    @inline(never) public static func instanceIDAlignment() -> UInt32 { UInt32(MemoryLayout<FontInstanceID>.alignment) }
    @inline(never) public static func glyphIDSize() -> UInt32 { UInt32(MemoryLayout<GlyphID>.size) }
    @inline(never) public static func glyphIDStride() -> UInt32 { UInt32(MemoryLayout<GlyphID>.stride) }
    @inline(never) public static func glyphIDAlignment() -> UInt32 { UInt32(MemoryLayout<GlyphID>.alignment) }
    @inline(never) public static func realizationIDSize() -> UInt32 { UInt32(MemoryLayout<RasterRealizationID>.size) }
    @inline(never) public static func realizationIDStride() -> UInt32 { UInt32(MemoryLayout<RasterRealizationID>.stride) }
    @inline(never) public static func realizationIDAlignment() -> UInt32 { UInt32(MemoryLayout<RasterRealizationID>.alignment) }
    @inline(never) public static func rasterKindSize() -> UInt32 { UInt32(MemoryLayout<TextRasterKind>.size) }
    @inline(never) public static func rasterKindStride() -> UInt32 { UInt32(MemoryLayout<TextRasterKind>.stride) }
    @inline(never) public static func rasterKindAlignment() -> UInt32 { UInt32(MemoryLayout<TextRasterKind>.alignment) }
    @inline(never) public static func lineMetricsSize() -> UInt32 { UInt32(MemoryLayout<FontLineMetrics>.size) }
    @inline(never) public static func lineMetricsStride() -> UInt32 { UInt32(MemoryLayout<FontLineMetrics>.stride) }
    @inline(never) public static func lineMetricsAlignment() -> UInt32 { UInt32(MemoryLayout<FontLineMetrics>.alignment) }
    @inline(never) public static func glyphMetricsSize() -> UInt32 { UInt32(MemoryLayout<GlyphMetrics>.size) }
    @inline(never) public static func glyphMetricsStride() -> UInt32 { UInt32(MemoryLayout<GlyphMetrics>.stride) }
    @inline(never) public static func glyphMetricsAlignment() -> UInt32 { UInt32(MemoryLayout<GlyphMetrics>.alignment) }
    @inline(never) public static func instanceDescriptorSize() -> UInt32 { UInt32(MemoryLayout<FontInstanceDescriptor>.size) }
    @inline(never) public static func instanceDescriptorStride() -> UInt32 { UInt32(MemoryLayout<FontInstanceDescriptor>.stride) }
    @inline(never) public static func instanceDescriptorAlignment() -> UInt32 { UInt32(MemoryLayout<FontInstanceDescriptor>.alignment) }
    @inline(never) public static func realizationDescriptorSize() -> UInt32 { UInt32(MemoryLayout<RasterRealizationDescriptor>.size) }
    @inline(never) public static func realizationDescriptorStride() -> UInt32 { UInt32(MemoryLayout<RasterRealizationDescriptor>.stride) }
    @inline(never) public static func realizationDescriptorAlignment() -> UInt32 { UInt32(MemoryLayout<RasterRealizationDescriptor>.alignment) }
    @inline(never) public static func resourceDescriptorSize() -> UInt32 { UInt32(MemoryLayout<TextResourceDescriptor>.size) }
    @inline(never) public static func resourceDescriptorStride() -> UInt32 { UInt32(MemoryLayout<TextResourceDescriptor>.stride) }
    @inline(never) public static func resourceDescriptorAlignment() -> UInt32 { UInt32(MemoryLayout<TextResourceDescriptor>.alignment) }
    @inline(never) public static func glyphMappingSize() -> UInt32 { UInt32(MemoryLayout<GlyphMapping>.size) }
    @inline(never) public static func glyphMappingStride() -> UInt32 { UInt32(MemoryLayout<GlyphMapping>.stride) }
    @inline(never) public static func glyphMappingAlignment() -> UInt32 { UInt32(MemoryLayout<GlyphMapping>.alignment) }
    @inline(never) public static func mappingRecordSize() -> UInt32 { UInt32(MemoryLayout<ScalarGlyphMappingRecord>.size) }
    @inline(never) public static func mappingRecordStride() -> UInt32 { UInt32(MemoryLayout<ScalarGlyphMappingRecord>.stride) }
    @inline(never) public static func mappingRecordAlignment() -> UInt32 { UInt32(MemoryLayout<ScalarGlyphMappingRecord>.alignment) }
    @inline(never) public static func rasterRecordSize() -> UInt32 { UInt32(MemoryLayout<GlyphRasterRecord>.size) }
    @inline(never) public static func rasterRecordStride() -> UInt32 { UInt32(MemoryLayout<GlyphRasterRecord>.stride) }
    @inline(never) public static func rasterRecordAlignment() -> UInt32 { UInt32(MemoryLayout<GlyphRasterRecord>.alignment) }
    @inline(never) public static func validationErrorSize() -> UInt32 { UInt32(MemoryLayout<TextResourceValidationError>.size) }
    @inline(never) public static func validationErrorStride() -> UInt32 { UInt32(MemoryLayout<TextResourceValidationError>.stride) }
    @inline(never) public static func validationErrorAlignment() -> UInt32 { UInt32(MemoryLayout<TextResourceValidationError>.alignment) }
    @inline(never) public static func validationResultSize() -> UInt32 { UInt32(MemoryLayout<TextResourceValidationResult>.size) }
    @inline(never) public static func validationResultStride() -> UInt32 { UInt32(MemoryLayout<TextResourceValidationResult>.stride) }
    @inline(never) public static func validationResultAlignment() -> UInt32 { UInt32(MemoryLayout<TextResourceValidationResult>.alignment) }
}
