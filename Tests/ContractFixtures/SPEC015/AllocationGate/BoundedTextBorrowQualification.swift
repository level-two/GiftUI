import GiftUI

#if !hasFeature(Embedded)
    private enum P08BoundedTextBorrowError: Error {
        case selected
    }

    func p08BoundedTextBorrowQualification() -> Int {
        var checks = 0
        func check(_ condition: Bool) {
            precondition(condition)
            checks += 1
        }
        func digest(_ bytes: UnsafeBufferPointer<UInt8>) -> UInt32 {
            var value: UInt32 = 0
            for byte in bytes { value = (value &* 16_777_619) ^ UInt32(byte) }
            return value
        }
        func qualify(_ text: BoundedText, expected: [UInt8]) {
            let original = text
            var expectedDigest: UInt32 = 0
            for byte in expected {
                expectedDigest = (expectedDigest &* 16_777_619) ^ UInt32(byte)
            }
            check(Int(text.utf8ByteCount) == expected.count)
            var nonthrowCalls = 0
            let actual = text.withNonthrowingUTF8 { bytes in
                nonthrowCalls += 1
                check(bytes.count == expected.count)
                for index in expected.indices { check(bytes[index] == expected[index]) }
                return digest(bytes)
            }
            check(nonthrowCalls == 1)
            check(actual == expectedDigest)
            var publicCalls = 0
            let publicValue = text.withUTF8 { bytes in
                publicCalls += 1
                check(bytes.count == expected.count)
                for index in expected.indices { check(bytes[index] == expected[index]) }
                return digest(bytes)
            }
            check(publicCalls == 1)
            check(publicValue == expectedDigest)
            let optionalCount: UInt16? = text.withNonthrowingUTF8 { bytes in
                UInt16(bytes.count)
            }
            check(optionalCount == UInt16(expected.count))
            let nestedCount = text.withNonthrowingUTF8 { outer in
                text.withNonthrowingUTF8 { inner in
                    check(outer.count == inner.count)
                    for index in expected.indices { check(outer[index] == inner[index]) }
                    return inner.count
                }
            }
            check(nestedCount == expected.count)
            var throwingCalls = 0
            do {
                let _: Int = try text.withUTF8 { bytes in
                    throwingCalls += 1
                    check(bytes.count == expected.count)
                    throw P08BoundedTextBorrowError.selected
                }
                preconditionFailure("throwing callback returned")
            } catch P08BoundedTextBorrowError.selected {
                checks += 1
            } catch {
                preconditionFailure("callback error changed")
            }
            check(throwingCalls == 1)
            check(text == original)
        }

        check(BoundedText.maximumUTF8ByteCount == 96)
        check(MemoryLayout<BoundedText>.size == 98)
        check(MemoryLayout<BoundedText>.stride == 100)
        check(MemoryLayout<BoundedText>.alignment == 4)
        for count in 0 ... 96 {
            let bytes = (0 ..< count).map { UInt8(65 + $0 % 26) }
            guard let text = BoundedText(utf8: bytes) else {
                preconditionFailure("valid ASCII refused")
            }
            qualify(text, expected: bytes)
        }
        let multibyte: [[UInt8]] = [
            [0xC2, 0xA2], [0xE2, 0x82, 0xAC], [0xF0, 0x9F, 0x98, 0x80],
            [65, 0, 66], [10, 13],
            Array(repeating: [UInt8(0xF0), 0x9F, 0x98, 0x80], count: 24).flatMap { $0 },
            Array(repeating: [UInt8(0xC2), 0xA2], count: 48).flatMap { $0 },
        ]
        for bytes in multibyte {
            guard let text = BoundedText(utf8: bytes) else {
                preconditionFailure("valid Unicode refused")
            }
            qualify(text, expected: bytes)
        }
        let integers: [(Int32, StaticString)] = [
            (.min, "-2147483648"), (-1, "-1"), (0, "0"), (1, "1"),
            (.max, "2147483647"),
        ]
        for (value, expected) in integers {
            expected.withUTF8Buffer { bytes in
                qualify(BoundedText(value), expected: Array(bytes))
            }
        }
        let refused: [[UInt8]] = [
            [0x80], [0xC0, 0x80], [0xED, 0xA0, 0x80],
            [0xF4, 0x90, 0x80, 0x80], [0xE2, 0x82], Array(repeating: 65, count: 97),
        ]
        for bytes in refused { check(BoundedText(utf8: bytes) == nil) }
        return checks
    }
#endif
