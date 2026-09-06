import GiftUI
import Testing

private enum ExpectedFailure: Error, Equatable {
    case stopped
}

private func bytes(of text: BoundedText) -> [UInt8] {
    text.withUTF8(Array.init)
}

@Test
func boundedTextStoresItsMaximumPayloadInline() {
    let payload = Array(repeating: UInt8(ascii: "a"), count: 96)
    let text = BoundedText(utf8: payload)

    #expect(BoundedText.maximumUTF8ByteCount == 96)
    #expect(MemoryLayout<BoundedText>.size <= 100)
    #expect(MemoryLayout<BoundedText>.stride <= 100)
    #expect(text?.utf8ByteCount == 96)
    #expect(text.map(bytes) == payload)
    #expect(BoundedText(utf8: payload + [UInt8(ascii: "b")]) == nil)
}

@Test
func boundedTextAdmitsEmptyAndWellFormedUTF8Collections() {
    let empty = BoundedText(utf8: EmptyCollection<UInt8>())
    let scalarBytes: [UInt8] = [0x41, 0xC2, 0xB0, 0xE2, 0x82, 0xAC, 0xF0, 0x9F, 0x8E, 0x81]
    let scalars = BoundedText(utf8: scalarBytes[...])

    #expect(empty?.utf8ByteCount == 0)
    #expect(empty.map(bytes) == [])
    #expect(scalars?.utf8ByteCount == UInt16(scalarBytes.count))
    #expect(scalars.map(bytes) == scalarBytes)
}

@Test(
    arguments: [
        [0x80],
        [0xC0, 0x80],
        [0xE0, 0x80, 0x80],
        [0xED, 0xA0, 0x80],
        [0xF0, 0x80, 0x80, 0x80],
        [0xF4, 0x90, 0x80, 0x80],
        [0xF5, 0x80, 0x80, 0x80],
        [0xE2, 0x82],
        [0xF0, 0x9F, 0x8E],
    ] as [[UInt8]]
)
func boundedTextRejectsMalformedUTF8(_ malformed: [UInt8]) {
    #expect(BoundedText(utf8: malformed) == nil)
}

@Test
func boundedTextStaticStringDropsOnlyOneTrailingCNull() {
    let plain = BoundedText("gift")
    let terminated = BoundedText("gift\0")
    let embedded = BoundedText("gi\0ft")
    let twoTrailingNulls = BoundedText("gift\0\0")

    #expect(plain.map(bytes) == Array("gift".utf8))
    #expect(terminated == plain)
    #expect(embedded.map(bytes) == [103, 105, 0, 102, 116])
    #expect(twoTrailingNulls.map(bytes) == [103, 105, 102, 116, 0])
}

@Test(
    arguments: [
        (Int32.min, "-2147483648"),
        (-1, "-1"),
        (0, "0"),
        (1, "1"),
        (Int32.max, "2147483647"),
    ]
)
func boundedTextFormatsEveryInt32BoundaryAsASCII(_ value: Int32, _ expected: String) {
    let text = BoundedText(value)

    #expect(bytes(of: text) == Array(expected.utf8))
}

@Test
func boundedTextWithUTF8CallsItsBodyOnceAndPropagatesThrows() {
    let text = BoundedText("once")!
    var callCount = 0

    #expect(throws: ExpectedFailure.stopped) {
        try text.withUTF8 { buffer in
            callCount += 1
            #expect(Array(buffer) == Array("once".utf8))
            throw ExpectedFailure.stopped
        }
    }
    #expect(callCount == 1)
}

@Test
func boundedTextEqualityUsesOnlyAdmittedBytes() {
    let first = BoundedText(utf8: [1, 2, 3])
    let same = BoundedText(utf8: [1, 2, 3])
    let differentByte = BoundedText(utf8: [1, 2, 4])
    let differentLength = BoundedText(utf8: [1, 2])

    #expect(first == same)
    #expect(first != differentByte)
    #expect(first != differentLength)
}
