// Allocation-free UTF-8 byte packing for generated Static text.

import GiftUI

package enum StaticSignalAnalyzerNRFUTF8TextPool {
    package static let maximumByteCount: UInt16 = UInt16(
        StaticSignalAnalyzerNRFPackedSemanticRecords.actionOffset
            - StaticSignalAnalyzerNRFPackedSemanticRecords.scalarOffset
    )

    /// Copies a whole bounded value or leaves the borrowed region unchanged.
    /// The returned byte count is the length of this text's contiguous range.
    package static func append(
        _ text: BoundedText,
        at start: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        guard region.count == table.regionByteCount,
            start <= maximumByteCount
        else { return nil }
        return text.withUTF8 { bytes in
            guard bytes.count <= Int(maximumByteCount - start) else { return nil }
            var index = 0
            while index < bytes.count {
                region[table.scalarOffset + Int(start) + index] = bytes[index]
                index += 1
            }
            return UInt16(bytes.count)
        }
    }

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
}
