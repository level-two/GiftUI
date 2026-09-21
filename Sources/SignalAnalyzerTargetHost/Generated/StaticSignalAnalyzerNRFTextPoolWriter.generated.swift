// Allocation-free UTF-8 to scalar-pool encoding for generated Static text.

import GiftUI

package enum StaticSignalAnalyzerNRFTextPoolWriter {
    /// Returns the scalar count. The caller owns the next free ordinal and
    /// writes that range into the matching text scope record.
    package static func append(
        _ text: BoundedText,
        at start: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == table.regionByteCount,
            start <= table.maximumScalarCount
        else { return nil }
        return text.withUTF8 { bytes in
            var count: UInt16 = 0
            for byte in bytes where byte & 0xC0 != 0x80 {
                guard count < table.maximumScalarCount - start else { return nil }
                count += 1
            }
            var offset = 0
            var ordinal = start
            while offset < bytes.count {
                let lead = bytes[offset]
                let width: Int
                var scalar: UInt32
                if lead < 0x80 {
                    width = 1
                    scalar = UInt32(lead)
                } else if lead < 0xE0 {
                    width = 2
                    scalar = UInt32(lead & 0x1F)
                } else if lead < 0xF0 {
                    width = 3
                    scalar = UInt32(lead & 0x0F)
                } else {
                    width = 4
                    scalar = UInt32(lead & 0x07)
                }
                guard offset + width <= bytes.count else { return nil }
                var continuation = 1
                while continuation < width {
                    scalar = (scalar << 6) | UInt32(bytes[offset + continuation] & 0x3F)
                    continuation += 1
                }
                guard table.storeScalar(scalar, at: ordinal, in: region) else {
                    return nil
                }
                ordinal += 1
                offset += width
            }
            return count
        }
    }
}
