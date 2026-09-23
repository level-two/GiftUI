/// Target-safe realization of the approved 98 by 32-byte layout scope region.
package enum StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec {
    package static let recordByteCount = 32
    package static let regionByteCount = 3_136

    package struct Record: Equatable {
        package let identity: UInt16
        package let idealWidth: Int16
        package let idealHeight: Int16
        package let width: Int16
        package let height: Int16
        package let originX: Int16?
        package let originY: Int16?
        package let clipX: Int16?
        package let clipY: Int16?
        package let clipWidth: Int16?
        package let clipHeight: Int16?
    }

    package static func stage(
        identity: UInt16,
        idealWidth: Int16, idealHeight: Int16,
        width: Int16, height: Int16,
        at index: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let offset = slot(index, in: region), identity != 0,
            idealWidth >= 0, idealHeight >= 0,
            width >= 0, height >= 0,
            region[offset ..< offset + recordByteCount].allSatisfy({ $0 == 0 })
        else { return false }
        write(identity, at: offset, in: region)
        write(UInt16(bitPattern: idealWidth), at: offset + 4, in: region)
        write(UInt16(bitPattern: idealHeight), at: offset + 6, in: region)
        write(UInt16(bitPattern: width), at: offset + 8, in: region)
        write(UInt16(bitPattern: height), at: offset + 10, in: region)
        region[offset + 2] = 1
        return true
    }

    package static func place(
        identity: UInt16,
        originX: Int16, originY: Int16,
        width: Int16, height: Int16,
        clipX: Int16, clipY: Int16,
        clipWidth: Int16, clipHeight: Int16,
        at index: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard let offset = slot(index, in: region),
            region[offset + 2] == 1,
            word(at: offset, in: region) == identity,
            word(at: offset + 8, in: region) == UInt16(bitPattern: width),
            word(at: offset + 10, in: region) == UInt16(bitPattern: height),
            width >= 0, height >= 0,
            clipWidth >= 0, clipHeight >= 0
        else { return false }
        write(UInt16(bitPattern: originX), at: offset + 12, in: region)
        write(UInt16(bitPattern: originY), at: offset + 14, in: region)
        write(UInt16(bitPattern: clipX), at: offset + 16, in: region)
        write(UInt16(bitPattern: clipY), at: offset + 18, in: region)
        write(UInt16(bitPattern: clipWidth), at: offset + 20, in: region)
        write(UInt16(bitPattern: clipHeight), at: offset + 22, in: region)
        region[offset + 2] = 3
        return true
    }

    package static func read(
        at index: UInt16,
        in region: UnsafeMutableRawBufferPointer
    ) -> Record? {
        guard let offset = slot(index, in: region),
            region[offset + 2] == 1 || region[offset + 2] == 3,
            region[offset + 3] == 0,
            region[offset + 24 ..< offset + recordByteCount].allSatisfy({ $0 == 0 }),
            let identity = word(at: offset, in: region), identity != 0,
            let idealWidth = signed(at: offset + 4, in: region), idealWidth >= 0,
            let idealHeight = signed(at: offset + 6, in: region), idealHeight >= 0,
            let width = signed(at: offset + 8, in: region), width >= 0,
            let height = signed(at: offset + 10, in: region), height >= 0
        else { return nil }
        if region[offset + 2] == 1 {
            guard region[offset + 12 ..< offset + 24].allSatisfy({ $0 == 0 })
            else { return nil }
            return Record(
                identity: identity, idealWidth: idealWidth,
                idealHeight: idealHeight, width: width, height: height,
                originX: nil, originY: nil, clipX: nil, clipY: nil,
                clipWidth: nil, clipHeight: nil
            )
        }
        guard let originX = signed(at: offset + 12, in: region),
            let originY = signed(at: offset + 14, in: region),
            let clipX = signed(at: offset + 16, in: region),
            let clipY = signed(at: offset + 18, in: region),
            let clipWidth = signed(at: offset + 20, in: region), clipWidth >= 0,
            let clipHeight = signed(at: offset + 22, in: region), clipHeight >= 0
        else { return nil }
        return Record(
            identity: identity, idealWidth: idealWidth,
            idealHeight: idealHeight, width: width, height: height,
            originX: originX, originY: originY, clipX: clipX, clipY: clipY,
            clipWidth: clipWidth, clipHeight: clipHeight
        )
    }

    private static func slot(
        _ index: UInt16, in region: UnsafeMutableRawBufferPointer
    ) -> Int? {
        guard region.count == regionByteCount,
            index < 98
        else { return nil }
        return Int(index) * recordByteCount
    }

    private static func word(
        at offset: Int, in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        guard offset >= 0 && offset + 1 < region.count else { return nil }
        return UInt16(region[offset]) | UInt16(region[offset + 1]) << 8
    }

    private static func signed(
        at offset: Int, in region: UnsafeMutableRawBufferPointer
    ) -> Int16? {
        word(at: offset, in: region).map { Int16(bitPattern: $0) }
    }

    private static func write(
        _ value: UInt16, at offset: Int,
        in region: UnsafeMutableRawBufferPointer
    ) {
        region[offset] = UInt8(truncatingIfNeeded: value)
        region[offset + 1] = UInt8(truncatingIfNeeded: value >> 8)
    }
}
