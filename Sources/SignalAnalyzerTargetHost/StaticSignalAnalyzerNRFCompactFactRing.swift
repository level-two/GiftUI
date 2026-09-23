/// One 2,176-byte profile region: 32 compact facts followed by 128 bytes of
/// ring metadata/reserve. All mutable ring state lives in the lent region.
package struct StaticSignalAnalyzerNRFCompactFactRing: ~Copyable {
    package static let requiredByteCount = 2_176
    package static let capacity: UInt16 = 32
    private static let metadataOffset = 2_048

    private let storage: UnsafeMutableRawBufferPointer

    package init?(storage: UnsafeMutableRawBufferPointer) {
        guard storage.count == Self.requiredByteCount,
            let address = storage.baseAddress,
            UInt(bitPattern: address) & 7 == 0,
            MemoryLayout<StaticSignalAnalyzerNRFCompactCaptureFact>.stride == 64
        else { return nil }
        storage.initializeMemory(as: UInt8.self, repeating: 0)
        self.storage = storage
    }

    package var count: UInt16 {
        storage.baseAddress!.load(fromByteOffset: Self.metadataOffset, as: UInt16.self)
    }

    package mutating func append(_ fact: StaticSignalAnalyzerNRFCompactCaptureFact) -> Bool {
        let currentCount = count
        guard currentCount < Self.capacity else { return false }
        let tail = storage.baseAddress!.load(
            fromByteOffset: Self.metadataOffset + 2, as: UInt16.self
        )
        guard tail < Self.capacity else { return false }
        storage.baseAddress!.storeBytes(
            of: fact, toByteOffset: Int(tail) * 64,
            as: StaticSignalAnalyzerNRFCompactCaptureFact.self
        )
        storage.baseAddress!.storeBytes(
            of: currentCount + 1, toByteOffset: Self.metadataOffset, as: UInt16.self
        )
        storage.baseAddress!.storeBytes(
            of: (tail + 1) % Self.capacity,
            toByteOffset: Self.metadataOffset + 2, as: UInt16.self
        )
        return true
    }

    package mutating func takeFirst() -> StaticSignalAnalyzerNRFCompactCaptureFact? {
        let currentCount = count
        guard currentCount > 0, currentCount <= Self.capacity else { return nil }
        let head = storage.baseAddress!.load(
            fromByteOffset: Self.metadataOffset + 4, as: UInt16.self
        )
        guard head < Self.capacity else { return nil }
        let fact = storage.baseAddress!.load(
            fromByteOffset: Int(head) * 64,
            as: StaticSignalAnalyzerNRFCompactCaptureFact.self
        )
        storage.baseAddress!.storeBytes(
            of: currentCount - 1, toByteOffset: Self.metadataOffset, as: UInt16.self
        )
        storage.baseAddress!.storeBytes(
            of: (head + 1) % Self.capacity,
            toByteOffset: Self.metadataOffset + 4, as: UInt16.self
        )
        return fact
    }

    /// Seals only into an empty distinct ring; both regions stay caller-owned.
    package mutating func seal(into sealed: inout StaticSignalAnalyzerNRFCompactFactRing)
        -> Bool
    {
        guard count > 0, count <= Self.capacity, sealed.count == 0,
            storage.baseAddress != sealed.storage.baseAddress
        else { return false }
        let originalCount = count
        let head = storage.baseAddress!.load(
            fromByteOffset: Self.metadataOffset + 4, as: UInt16.self
        )
        guard head < Self.capacity else { return false }
        for index in 0 ..< Int(originalCount) {
            let source = (Int(head) + index) % Int(Self.capacity)
            let fact = storage.baseAddress!.load(
                fromByteOffset: source * 64,
                as: StaticSignalAnalyzerNRFCompactCaptureFact.self
            )
            guard sealed.append(fact) else { return false }
        }
        resetMetadata()
        return true
    }

    package mutating func discard() {
        resetMetadata()
    }

    private mutating func resetMetadata() {
        storage[Self.metadataOffset ..< Self.metadataOffset + 6]
            .initializeMemory(as: UInt8.self, repeating: 0)
    }
}
