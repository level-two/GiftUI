package enum PiScreenFramebufferProjection {
    package static func present(
        bytes: UnsafeRawBufferPointer,
        regions: [PiScreenPayloadRegion],
        transform: PiScreenAspectFitTransform,
        layout: PiScreenFramebufferLayout,
        destination: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let source = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
            return regions.isEmpty
        }
        guard destination.count >= Int(layout.mappedBytes),
            let destinationBase = destination.baseAddress?.assumingMemoryBound(to: UInt8.self)
        else { return false }
        for region in regions {
            guard
                let physical = transform.physicalBounds(
                    origin: region.origin,
                    pixelCount: region.pixelCount
                ),
                physical.minX >= 0, physical.minY >= 0,
                physical.maxX <= Int32(layout.width),
                physical.maxY <= Int32(layout.height)
            else { return false }
            let byteCount = UInt32(region.pixelCount).multipliedReportingOverflow(by: 2)
            guard !byteCount.overflow,
                region.byteOffset <= UInt32(bytes.count),
                byteCount.partialValue <= UInt32(bytes.count) - region.byteOffset
            else { return false }
            let physicalWidth = Int(physical.size.width)
            let destinationByteWidth = UInt64(physicalWidth) * 2
            let isDoubleWidth = physicalWidth == Int(region.pixelCount) * 2
            var firstDestinationRow: UnsafeMutablePointer<UInt8>?
            for physicalY in physical.minY ..< physical.maxY {
                let rowOffset =
                    UInt64(physicalY) * UInt64(layout.bytesPerRow)
                    + UInt64(physical.minX) * 2
                guard rowOffset + destinationByteWidth <= UInt64(layout.mappedBytes),
                    let destinationOffset = Int(exactly: rowOffset)
                else { return false }
                let destinationRow = destinationBase.advanced(by: destinationOffset)
                if let firstDestinationRow {
                    UnsafeMutableRawPointer(destinationRow).copyMemory(
                        from: firstDestinationRow,
                        byteCount: Int(destinationByteWidth)
                    )
                    continue
                }
                if isDoubleWidth {
                    for sourcePixel in 0 ..< Int(region.pixelCount) {
                        let sourceOffset = Int(region.byteOffset) + sourcePixel * 2
                        let targetOffset = sourcePixel * 4
                        let low = source[sourceOffset + 1]
                        let high = source[sourceOffset]
                        destinationRow[targetOffset] = low
                        destinationRow[targetOffset + 1] = high
                        destinationRow[targetOffset + 2] = low
                        destinationRow[targetOffset + 3] = high
                    }
                } else {
                    for relativeX in 0 ..< physicalWidth {
                        let sourcePixel = Int(
                            Int64(relativeX) * Int64(region.pixelCount)
                                / Int64(physical.size.width)
                        )
                        let sourceOffset = Int(region.byteOffset) + sourcePixel * 2
                        let targetOffset = relativeX * 2
                        destinationRow[targetOffset] = source[sourceOffset + 1]
                        destinationRow[targetOffset + 1] = source[sourceOffset]
                    }
                }
                firstDestinationRow = destinationRow
            }
        }
        return true
    }
}
