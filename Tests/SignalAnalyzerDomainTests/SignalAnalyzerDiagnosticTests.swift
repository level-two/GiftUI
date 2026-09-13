import SignalAnalyzerDomain
import Testing

@Test
func exactDiagnosticAcceptsEveryBoundAndPreservesBorrowedBytes() {
    let empty = SignalAnalyzerDiagnostic(exactUTF8: [UInt8]())
    #expect(empty?.utf8ByteCount == 0)

    let maximum = Array(repeating: UInt8(ascii: "a"), count: 96)
    let diagnostic = SignalAnalyzerDiagnostic(exactUTF8: maximum)
    #expect(diagnostic?.utf8ByteCount == 96)
    #expect(diagnostic?.withUTF8(Array.init) == maximum)
    #expect(SignalAnalyzerDiagnostic(exactUTF8: maximum + [UInt8(ascii: "b")]) == nil)
}

@Test
func truncationEndsAtUnicodeScalarBoundaries() {
    let cases: [([UInt8], Int)] = [
        (Array(repeating: UInt8(ascii: "a"), count: 97), 96),
        (Array(repeating: UInt8(ascii: "a"), count: 95) + [0xC2, 0xA2, 0x62], 95),
        (Array(repeating: UInt8(ascii: "a"), count: 94) + [0xE2, 0x82, 0xAC], 94),
        (Array(repeating: UInt8(ascii: "a"), count: 93) + [0xF0, 0x9F, 0x98, 0x80], 93),
    ]

    for (bytes, expectedCount) in cases {
        guard case .truncated(let diagnostic) = SignalAnalyzerDiagnostic.truncating(utf8: bytes)
        else {
            Issue.record("expected truncation")
            continue
        }
        #expect(diagnostic.utf8ByteCount == expectedCount)
        #expect(diagnostic.withUTF8(Array.init) == Array(bytes.prefix(expectedCount)))
    }
}

@Test
func exactAndTruncatingConstructionAcceptOneThroughFourByteScalars() {
    let scalars: [[UInt8]] = [
        [0x41],
        [0xC2, 0xA2],
        [0xE2, 0x82, 0xAC],
        [0xF0, 0x9F, 0x98, 0x80],
    ]
    let bytes = scalars.flatMap { $0 }
    let exact = SignalAnalyzerDiagnostic(exactUTF8: bytes)
    #expect(exact?.withUTF8(Array.init) == bytes)
    #expect(SignalAnalyzerDiagnostic.truncating(utf8: bytes) == .exact(exact!))
}

@Test
func malformedUTF8IsNeverRepaired() {
    let malformed: [[UInt8]] = [
        [0x80], [0xC0, 0x80], [0xC2], [0xE0, 0x80, 0x80], [0xED, 0xA0, 0x80],
        [0xE2, 0x82], [0xF0, 0x80, 0x80, 0x80], [0xF4, 0x90, 0x80, 0x80],
        [0xF0, 0x9F, 0x98], [0xF5, 0x80, 0x80, 0x80],
    ]
    for bytes in malformed {
        #expect(SignalAnalyzerDiagnostic(exactUTF8: bytes) == nil)
        #expect(SignalAnalyzerDiagnostic.truncating(utf8: bytes) == .invalidUTF8)
    }
}

@Test
func diagnosticIsInlineValueStorageAndBorrowCallsExactlyOnce() {
    #expect(MemoryLayout<SignalAnalyzerDiagnostic>.size <= 100)
    var source = [UInt8(ascii: "o"), UInt8(ascii: "n"), UInt8(ascii: "c"), UInt8(ascii: "e")]
    let diagnostic = SignalAnalyzerDiagnostic(exactUTF8: source)!
    source[0] = UInt8(ascii: "x")
    var calls = 0
    let retained = diagnostic.withUTF8 { bytes in
        calls += 1
        return Array(bytes)
    }
    #expect(calls == 1)
    #expect(retained == Array("once".utf8))
    #expect(diagnostic == SignalAnalyzerDiagnostic(exactUTF8: Array("once".utf8)))
    #expect(diagnostic != SignalAnalyzerDiagnostic(exactUTF8: Array("once!".utf8)))
}
