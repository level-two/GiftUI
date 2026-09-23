// Allocation-free UTF-8 byte packing for generated Static text.

#if !GIFTUI_NRF_EMBEDDED
import GiftUI
#endif

package enum StaticSignalAnalyzerNRFUTF8TextPool {
    package static let maximumByteCount: UInt16 = UInt16(
        StaticSignalAnalyzerNRFPackedSemanticRecords.actionOffset
            - StaticSignalAnalyzerNRFPackedSemanticRecords.scalarOffset
    )

    /// Copies a whole byte value or leaves the borrowed region unchanged.
    /// The returned byte count is the length of this text's contiguous range.
    package static func appendBytes(
        _ bytes: UnsafeBufferPointer<UInt8>,
        at start: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == table.regionByteCount,
            start <= maximumByteCount,
            bytes.count <= Int(maximumByteCount - start)
        else { return nil }
        var index = 0
        while index < bytes.count {
            region[table.scalarOffset + Int(start) + index] = bytes[index]
            index += 1
        }
        return UInt16(bytes.count)
    }

    #if !GIFTUI_NRF_EMBEDDED
    package static func append(
        _ text: BoundedText,
        at start: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        return text.withUTF8 { bytes in
            appendBytes(bytes, at: start, in: region)
        }
    }
    #endif

    package static func byte(
        at offset: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt8? {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == table.regionByteCount,
            offset < maximumByteCount
        else { return nil }
        return region[table.scalarOffset + Int(offset)]
    }

    /// Validates one contiguous range and returns its Unicode scalar count.
    package static func scalarCount(
        from start: UInt16,
        byteCount: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        guard start <= maximumByteCount,
            byteCount <= maximumByteCount - start
        else { return nil }
        let end = start + byteCount
        var offset = start
        var count: UInt16 = 0
        while offset < end {
            guard let decoded = decode(at: offset, before: end, in: region) else {
                return nil
            }
            offset += decoded.width
            count += 1
        }
        return count
    }

    /// Looks up a scalar by ordinal without allocating an intermediate string.
    package static func scalar(
        at ordinal: UInt16,
        from start: UInt16,
        byteCount: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt32? {
        guard start <= maximumByteCount,
            byteCount <= maximumByteCount - start
        else { return nil }
        let end = start + byteCount
        var offset = start
        var current: UInt16 = 0
        while offset < end {
            guard let decoded = decode(at: offset, before: end, in: region) else {
                return nil
            }
            if current == ordinal { return decoded.scalar }
            offset += decoded.width
            current += 1
        }
        return nil
    }

    private static func decode(
        at offset: UInt16,
        before end: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> (scalar: UInt32, width: UInt16)? {
        guard let lead = byte(at: offset, in: region) else { return nil }
        let width: UInt16
        let minimum: UInt32
        var scalar: UInt32
        switch lead {
        case 0x00 ... 0x7F:
            width = 1
            minimum = 0
            scalar = UInt32(lead)
        case 0xC2 ... 0xDF:
            width = 2
            minimum = 0x80
            scalar = UInt32(lead & 0x1F)
        case 0xE0 ... 0xEF:
            width = 3
            minimum = 0x800
            scalar = UInt32(lead & 0x0F)
        case 0xF0 ... 0xF4:
            width = 4
            minimum = 0x1_0000
            scalar = UInt32(lead & 0x07)
        default:
            return nil
        }
        guard width <= end - offset else { return nil }
        var continuation: UInt16 = 1
        while continuation < width {
            guard let next = byte(at: offset + continuation, in: region),
                next & 0xC0 == 0x80
            else { return nil }
            scalar = (scalar << 6) | UInt32(next & 0x3F)
            continuation += 1
        }
        guard scalar >= minimum, scalar <= 0x10_FFFF,
            !(0xD800 ... 0xDFFF).contains(scalar)
        else { return nil }
        return (scalar, width)
    }
}
