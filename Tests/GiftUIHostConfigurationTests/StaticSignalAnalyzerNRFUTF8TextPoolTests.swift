import GiftUI
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFUTF8PoolRetainsExactBoundedBytes() {
    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
    let pool = StaticSignalAnalyzerNRFUTF8TextPool.self
    let text = BoundedText("Aé😀")!
    var bytes = [UInt8](repeating: 0, count: table.regionByteCount)
    bytes.withUnsafeMutableBytes { region in
        #expect(pool.append(text, at: 4, in: region) == 7)
        text.withUTF8 { expected in
            for index in expected.indices {
                #expect(pool.byte(at: UInt16(4 + index), in: region) == expected[index])
            }
        }
        #expect(pool.append(BoundedText("")!, at: pool.maximumByteCount, in: region) == 0)
        #expect(
            pool.append(
                BoundedText("Z")!,
                at: pool.maximumByteCount - 1,
                in: region
            ) == 1
        )
        #expect(pool.byte(at: pool.maximumByteCount - 1, in: region) == 90)
    }
}

@Test func staticNRFUTF8PoolAdmitsMaximumDiagnosticAndRejectsOverflowAtomically() {
    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
    let pool = StaticSignalAnalyzerNRFUTF8TextPool.self
    let diagnostic = BoundedText(utf8: [UInt8](repeating: 120, count: 96))!
    var bytes = [UInt8](repeating: 0xA5, count: table.regionByteCount)
    bytes.withUnsafeMutableBytes { region in
        #expect(pool.append(diagnostic, at: 200, in: region) == 96)
        #expect(pool.byte(at: 200, in: region) == 120)
        #expect(pool.byte(at: 295, in: region) == 120)
        #expect(pool.append(diagnostic, at: pool.maximumByteCount - 95, in: region) == nil)
        #expect(pool.append(BoundedText("a")!, at: pool.maximumByteCount + 1, in: region) == nil)
        let short = UnsafeMutableRawBufferPointer(rebasing: region[..<3_023])
        #expect(pool.append(BoundedText("a")!, at: 0, in: short) == nil)
    }
    #expect(bytes[table.scalarOffset + 200] == 120)
    #expect(bytes[table.scalarOffset + 295] == 120)
    #expect(bytes[table.scalarOffset + 296] == 0xA5)
    #expect(bytes[table.scalarOffset + Int(pool.maximumByteCount) - 1] == 0xA5)
}
