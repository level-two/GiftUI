private struct BoundedTextStorage: Sendable {
    var word00: UInt32 = 0
    var word01: UInt32 = 0
    var word02: UInt32 = 0
    var word03: UInt32 = 0
    var word04: UInt32 = 0
    var word05: UInt32 = 0
    var word06: UInt32 = 0
    var word07: UInt32 = 0
    var word08: UInt32 = 0
    var word09: UInt32 = 0
    var word10: UInt32 = 0
    var word11: UInt32 = 0
    var word12: UInt32 = 0
    var word13: UInt32 = 0
    var word14: UInt32 = 0
    var word15: UInt32 = 0
    var word16: UInt32 = 0
    var word17: UInt32 = 0
    var word18: UInt32 = 0
    var word19: UInt32 = 0
    var word20: UInt32 = 0
    var word21: UInt32 = 0
    var word22: UInt32 = 0
    var word23: UInt32 = 0
}

public struct BoundedText: Equatable, Sendable {
    public static let maximumUTF8ByteCount: UInt16 = 96

    private var storage: BoundedTextStorage
    private var count: UInt16

    public var utf8ByteCount: UInt16 {
        count
    }

    public init?(_ content: StaticString) {
        guard
            let admitted = content.withUTF8Buffer({ buffer in
                let contentCount = buffer.last == 0 ? buffer.count - 1 : buffer.count
                return BoundedText(utf8: buffer.prefix(contentCount))
            })
        else {
            return nil
        }

        self = admitted
    }

    public init?<Source: Collection>(utf8: Source) where Source.Element == UInt8 {
        var admitted = BoundedTextStorage()
        var admittedCount = 0
        let fits = withUnsafeMutableBytes(of: &admitted) { rawBytes in
            let bytes = rawBytes.bindMemory(to: UInt8.self)
            for byte in utf8 {
                guard admittedCount < Int(Self.maximumUTF8ByteCount) else {
                    return false
                }
                bytes[admittedCount] = byte
                admittedCount += 1
            }
            return true
        }

        guard fits, Self.isWellFormedUTF8(admitted, count: admittedCount) else {
            return nil
        }

        storage = admitted
        count = UInt16(admittedCount)
    }

    public init(_ value: Int32) {
        var formatted = BoundedTextStorage()
        var formattedCount = 0
        withUnsafeMutableBytes(of: &formatted) { rawBytes in
            let bytes = rawBytes.bindMemory(to: UInt8.self)
            var magnitude = value.magnitude

            repeat {
                bytes[formattedCount] = UInt8(ascii: "0") + UInt8(magnitude % 10)
                formattedCount += 1
                magnitude /= 10
            } while magnitude != 0

            if value < 0 {
                bytes[formattedCount] = UInt8(ascii: "-")
                formattedCount += 1
            }

            var lower = 0
            var upper = formattedCount - 1
            while lower < upper {
                let temporary = bytes[lower]
                bytes[lower] = bytes[upper]
                bytes[upper] = temporary
                lower += 1
                upper -= 1
            }
        }

        storage = formatted
        count = UInt16(formattedCount)
    }

    public func withUTF8<Result>(
        _ body: (UnsafeBufferPointer<UInt8>) throws -> Result
    ) rethrows -> Result {
        try withUnsafeBytes(of: storage) { rawBytes in
            let bytes = rawBytes.bindMemory(to: UInt8.self)
            return try body(
                UnsafeBufferPointer(start: bytes.baseAddress, count: Int(count))
            )
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }

        return withUnsafeBytes(of: lhs.storage) { lhsRawBytes in
            withUnsafeBytes(of: rhs.storage) { rhsRawBytes in
                let lhsBytes = lhsRawBytes.bindMemory(to: UInt8.self)
                let rhsBytes = rhsRawBytes.bindMemory(to: UInt8.self)
                for index in 0 ..< Int(lhs.count) where lhsBytes[index] != rhsBytes[index] {
                    return false
                }
                return true
            }
        }
    }

    private static func isWellFormedUTF8(
        _ storage: BoundedTextStorage,
        count: Int
    ) -> Bool {
        withUnsafeBytes(of: storage) { rawBytes in
            let bytes = rawBytes.bindMemory(to: UInt8.self)
            var index = 0
            while index < count {
                let first = bytes[index]
                if first <= 0x7F {
                    index += 1
                    continue
                }

                if first >= 0xC2, first <= 0xDF {
                    guard index + 1 < count, isContinuation(bytes[index + 1]) else {
                        return false
                    }
                    index += 2
                    continue
                }

                if first >= 0xE0, first <= 0xEF {
                    guard index + 2 < count else {
                        return false
                    }
                    let second = bytes[index + 1]
                    guard isContinuation(second), isContinuation(bytes[index + 2]) else {
                        return false
                    }
                    guard first != 0xE0 || second >= 0xA0 else {
                        return false
                    }
                    guard first != 0xED || second <= 0x9F else {
                        return false
                    }
                    index += 3
                    continue
                }

                if first >= 0xF0, first <= 0xF4 {
                    guard index + 3 < count else {
                        return false
                    }
                    let second = bytes[index + 1]
                    guard isContinuation(second),
                        isContinuation(bytes[index + 2]),
                        isContinuation(bytes[index + 3])
                    else {
                        return false
                    }
                    guard first != 0xF0 || second >= 0x90 else {
                        return false
                    }
                    guard first != 0xF4 || second <= 0x8F else {
                        return false
                    }
                    index += 4
                    continue
                }

                return false
            }
            return true
        }
    }

    private static func isContinuation(_ byte: UInt8) -> Bool {
        byte >= 0x80 && byte <= 0xBF
    }
}
