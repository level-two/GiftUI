import GiftUI
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFTextPoolWriterEncodesUnicodeScalarsWithoutExtraStorage() {
    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
    var bytes = [UInt8](repeating: 0, count: table.regionByteCount)
    bytes.withUnsafeMutableBytes { region in
        #expect(
            StaticSignalAnalyzerNRFTextPoolWriter.append(
                BoundedText("Aé😀")!,
                at: 4,
                in: region
            ) == 3
        )
        #expect(table.scalar(at: 4, in: region) == 65)
        #expect(table.scalar(at: 5, in: region) == 0xE9)
        #expect(table.scalar(at: 6, in: region) == 0x1_F600)
        #expect(
            StaticSignalAnalyzerNRFTextPoolWriter.append(
                BoundedText("Z")!,
                at: table.maximumScalarCount - 1,
                in: region
            ) == 1
        )
        #expect(table.scalar(at: table.maximumScalarCount - 1, in: region) == 90)
        #expect(
            StaticSignalAnalyzerNRFTextPoolWriter.append(
                BoundedText("")!,
                at: table.maximumScalarCount,
                in: region
            ) == 0
        )
    }
}

@Test func staticNRFTextPoolWriterRejectsOverflowBeforeMutation() {
    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
    var bytes = [UInt8](repeating: 0xA5, count: table.regionByteCount)
    bytes.withUnsafeMutableBytes { region in
        #expect(
            StaticSignalAnalyzerNRFTextPoolWriter.append(
                BoundedText("abc")!,
                at: table.maximumScalarCount - 2,
                in: region
            ) == nil
        )
        #expect(
            StaticSignalAnalyzerNRFTextPoolWriter.append(
                BoundedText("a")!,
                at: table.maximumScalarCount + 1,
                in: region
            ) == nil
        )
        let short = UnsafeMutableRawBufferPointer(rebasing: region[..<3_023])
        #expect(
            StaticSignalAnalyzerNRFTextPoolWriter.append(
                BoundedText("a")!,
                at: 0,
                in: short
            ) == nil
        )
    }
    #expect(bytes.allSatisfy { $0 == 0xA5 })
}
