import GiftUIRasterCore
import GiftUITextResources

package struct RasterTextResourceFacts: Equatable, Sendable {
    package let descriptor: TextResourceDescriptor
    package let realization: RasterRealizationDescriptor
    package let greatestGlyphRasterBytes: UInt32
    package let requiredStrokeWorkspaceBytes: UInt32
}

package enum RasterTextResourceValidationResult: Equatable, Sendable {
    case compatible(RasterTextResourceFacts)
    case failure(RasterBackendError)
}

package enum RasterGlyphRecordLookup: Equatable, Sendable {
    case available(GlyphRasterRecord)
    case incompatibleResource
}

package enum RasterTextResourceValidator {
    package static func validate<R: TextRasterResourceView>(
        _ raster: borrowing R,
        prevalidation: TextResourceValidationResult,
        expectedDescriptor: TextResourceDescriptor,
        selectedRealization: RasterRealizationDescriptor,
        payloadLimits: RasterPayloadLimits,
        requiredStrokeWorkspaceBytes: UInt32
    ) -> RasterTextResourceValidationResult {
        guard prevalidation == .valid else {
            return .failure(.incompatibleResource)
        }
        guard raster.descriptor == expectedDescriptor,
            selectedRealization.id.rawValue < expectedDescriptor.realizationCount,
            raster.realization(at: selectedRealization.id.rawValue)
                == selectedRealization,
            raster.isPayloadAvailable(for: selectedRealization.id)
        else {
            return .failure(.incompatibleResource)
        }

        var greatestGlyphRasterBytes: UInt32 = 0
        var glyphOrdinal: UInt16 = 0
        while glyphOrdinal < selectedRealization.glyphCount {
            let glyph = GlyphID(rawValue: glyphOrdinal)
            guard
                case .available(let record) = record(
                    for: glyph,
                    in: raster,
                    selectedRealization: selectedRealization
                )
            else {
                return .failure(.incompatibleResource)
            }
            let end = record.offset.addingReportingOverflow(record.byteCount)
            guard !end.overflow,
                end.partialValue <= selectedRealization.payloadByteCount
            else {
                return .failure(.incompatibleResource)
            }
            if record.byteCount > greatestGlyphRasterBytes {
                greatestGlyphRasterBytes = record.byteCount
            }
            glyphOrdinal += 1
        }

        guard payloadLimits.admitsGlyphRasterBytes(greatestGlyphRasterBytes),
            payloadLimits.admitsStrokeWorkspaceBytes(requiredStrokeWorkspaceBytes)
        else {
            return .failure(.capacityExhausted)
        }

        return .compatible(
            RasterTextResourceFacts(
                descriptor: expectedDescriptor,
                realization: selectedRealization,
                greatestGlyphRasterBytes: greatestGlyphRasterBytes,
                requiredStrokeWorkspaceBytes: requiredStrokeWorkspaceBytes
            )
        )
    }

    package static func record<R: TextRasterResourceView>(
        for glyph: GlyphID,
        in raster: borrowing R,
        selectedRealization: RasterRealizationDescriptor
    ) -> RasterGlyphRecordLookup {
        guard glyph.rawValue < selectedRealization.glyphCount,
            let record = raster.record(
                for: glyph,
                realization: selectedRealization.id
            ),
            record.glyph == glyph
        else {
            return .incompatibleResource
        }
        return .available(record)
    }
}
