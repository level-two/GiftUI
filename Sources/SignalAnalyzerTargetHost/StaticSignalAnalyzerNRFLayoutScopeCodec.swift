import GiftUI
import GiftUILayout

package struct StaticSignalAnalyzerNRFLayoutScopeRecord: Equatable {
    package let identity: UInt16
    package let measurement: LayoutMeasurement
    package let placement: LayoutPlacement?
}

/// One checked 32-byte scope slot in the audited 3,136-byte layout region.
/// Geometry is compact only after exact signed-16-bit representability checks.
package enum StaticSignalAnalyzerNRFLayoutScopeCodec {
    package static let recordByteCount = 32
    package static let maximumScopes = 98
    package static let regionByteCount = recordByteCount * maximumScopes

    package static func stage(
        identity: UInt16,
        measurement: LayoutMeasurement,
        at index: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let offset = offset(for: index, in: region),
            identity != 0,
            region[offset ..< (offset + recordByteCount)].allSatisfy({ $0 == 0 }),
            let idealWidth = packed(measurement.idealSize.width),
            let idealHeight = packed(measurement.idealSize.height),
            let resolvedWidth = packed(measurement.resolvedSize.width),
            let resolvedHeight = packed(measurement.resolvedSize.height)
        else { return false }
        write(identity, at: offset, in: region)
        write(idealWidth, at: offset + 4, in: region)
        write(idealHeight, at: offset + 6, in: region)
        write(resolvedWidth, at: offset + 8, in: region)
        write(resolvedHeight, at: offset + 10, in: region)
        region[offset + 2] = 1
        return true
    }

    package static func replaceMeasurement(
        _ measurement: LayoutMeasurement,
        for identity: UInt16,
        at index: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let offset = offset(for: index, in: region),
            region[offset + 2] == 1,
            word(at: offset, in: region) == identity,
            let idealWidth = packed(measurement.idealSize.width),
            let idealHeight = packed(measurement.idealSize.height),
            let resolvedWidth = packed(measurement.resolvedSize.width),
            let resolvedHeight = packed(measurement.resolvedSize.height)
        else { return false }
        write(idealWidth, at: offset + 4, in: region)
        write(idealHeight, at: offset + 6, in: region)
        write(resolvedWidth, at: offset + 8, in: region)
        write(resolvedHeight, at: offset + 10, in: region)
        return true
    }

    package static func place(
        _ placement: LayoutPlacement,
        for identity: UInt16,
        at index: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let offset = offset(for: index, in: region),
            region[offset + 2] == 1,
            word(at: offset, in: region) == identity,
            let stored = read(at: index, in: region),
            placement.bounds.size == stored.measurement.resolvedSize,
            let originX = packed(placement.bounds.origin.x),
            let originY = packed(placement.bounds.origin.y),
            let clipX = packed(placement.clip.origin.x),
            let clipY = packed(placement.clip.origin.y),
            let clipWidth = packed(placement.clip.size.width),
            let clipHeight = packed(placement.clip.size.height)
        else { return false }
        write(originX, at: offset + 12, in: region)
        write(originY, at: offset + 14, in: region)
        write(clipX, at: offset + 16, in: region)
        write(clipY, at: offset + 18, in: region)
        write(clipWidth, at: offset + 20, in: region)
        write(clipHeight, at: offset + 22, in: region)
        region[offset + 2] = 3
        return true
    }

    package static func read(
        at index: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFLayoutScopeRecord? {
        guard let offset = offset(for: index, in: region),
            region[offset + 2] == 1 || region[offset + 2] == 3,
            region[offset + 3] == 0,
            region[(offset + 24) ..< (offset + recordByteCount)].allSatisfy({ $0 == 0 }),
            let identity = word(at: offset, in: region), identity != 0,
            let idealWidth = signed(at: offset + 4, in: region),
            let idealHeight = signed(at: offset + 6, in: region),
            let resolvedWidth = signed(at: offset + 8, in: region),
            let resolvedHeight = signed(at: offset + 10, in: region),
            let idealSize = Size(width: idealWidth, height: idealHeight),
            let resolvedSize = Size(width: resolvedWidth, height: resolvedHeight)
        else { return nil }
        let measurement = LayoutMeasurement(
            idealSize: idealSize,
            resolvedSize: resolvedSize
        )
        guard region[offset + 2] == 3 else {
            guard region[(offset + 12) ..< (offset + 24)].allSatisfy({ $0 == 0 }) else {
                return nil
            }
            return StaticSignalAnalyzerNRFLayoutScopeRecord(
                identity: identity,
                measurement: measurement,
                placement: nil
            )
        }
        guard let originX = signed(at: offset + 12, in: region),
            let originY = signed(at: offset + 14, in: region),
            let clipX = signed(at: offset + 16, in: region),
            let clipY = signed(at: offset + 18, in: region),
            let clipWidth = signed(at: offset + 20, in: region),
            let clipHeight = signed(at: offset + 22, in: region),
            let bounds = Rect(
                origin: Point(x: originX, y: originY),
                size: resolvedSize
            ),
            let clipSize = Size(width: clipWidth, height: clipHeight),
            let clip = Rect(origin: Point(x: clipX, y: clipY), size: clipSize)
        else { return nil }
        return StaticSignalAnalyzerNRFLayoutScopeRecord(
            identity: identity,
            measurement: measurement,
            placement: LayoutPlacement(bounds: bounds, clip: clip)
        )
    }

    private static func offset(
        for index: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Int? {
        guard region.count == regionByteCount, Int(index) < maximumScopes else {
            return nil
        }
        return Int(index) * recordByteCount
    }

    private static func packed(_ value: GeometryScalar) -> UInt16? {
        Int16(exactly: value).map { UInt16(bitPattern: $0) }
    }

    private static func word(
        at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        guard offset >= 0, offset + 1 < region.count else { return nil }
        return UInt16(region[offset]) | (UInt16(region[offset + 1]) << 8)
    }

    private static func signed(
        at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) -> GeometryScalar? {
        word(at: offset, in: region).map { GeometryScalar(Int16(bitPattern: $0)) }
    }

    private static func write(
        _ value: UInt16,
        at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) {
        region[offset] = UInt8(truncatingIfNeeded: value)
        region[offset + 1] = UInt8(truncatingIfNeeded: value >> 8)
    }
}
