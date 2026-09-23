import GiftUI
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFModelTextWriterMatchesPortableStatusRulerAndDiagnostic() {
    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
    var captureWords = [UInt64](
        repeating: 0,
        count: StaticSignalAnalyzerNRFCaptureRegions.requiredByteCount / 8
    )
    captureWords.withUnsafeMutableBytes { captureBytes in
        guard let captures = StaticSignalAnalyzerNRFCaptureRegions(storage: captureBytes)
        else {
            Issue.record("The capture fixture must be aligned")
            return
        }
        var model = StaticSignalAnalyzerNRFModelLocation()
        let generation = model.activate()
        #expect(generation != nil)

        func text(_ ordinal: UInt16, in region: UnsafeMutableRawBufferPointer) -> String? {
            guard let record = table.scope(at: ordinal, in: region),
                record.kind == .text,
                record.payload0 <= UInt32(table.maximumTextByteCount),
                record.payload1 <= UInt32(table.maximumTextByteCount) - record.payload0
            else { return nil }
            let start = table.scalarOffset + Int(record.payload0)
            let end = start + Int(record.payload1)
            return String(decoding: region[start ..< end], as: UTF8.self)
        }

        func portable(_ value: BoundedText) -> String {
            value.withUTF8 { String(decoding: $0, as: UTF8.self) }
        }

        func check(_ variant: StaticSignalAnalyzerNRFSemanticVariant) {
            var bytes = [UInt8](repeating: 0, count: table.regionByteCount)
            bytes.withUnsafeMutableBytes { region in
                let count: UInt16 = variant == .normal ? 96 : 98
                #expect(
                    StaticSignalAnalyzerNRFTopologyWriter.populateShape(
                        variant: variant, in: region
                    ) == count
                )
                #expect(
                    StaticSignalAnalyzerNRFTopologyWriter.populateBindings(
                        scopeCount: count, in: region
                    )
                )
                #expect(
                    StaticSignalAnalyzerNRFTopologyWriter.populateInvariantPrimitives(
                        scopeCount: count, in: region
                    )
                )
                #expect(
                    StaticSignalAnalyzerNRFTopologyWriter.populateInvariantLayoutModifiers(
                        scopeCount: count, in: region
                    )
                )
                #expect(
                    StaticSignalAnalyzerNRFTopologyWriter.populateInvariantStyles(
                        scopeCount: count, in: region
                    )
                )
                #expect(
                    StaticSignalAnalyzerNRFModelTextWriter.populate(
                        variant: variant, model: model, capture: captures, in: region
                    ) != nil
                )
                let labels = SignalAnalyzerRulerLabels(visibleRange: model.visibleRange)
                #expect(text(6, in: region) == "DIGITAL SIGNAL ANALYZER")
                #expect(text(13, in: region) == (variant == .normal ? "READY" : "FAILED"))
                #expect(text(25, in: region) == portable(labels.lowerBound))
                #expect(text(28, in: region) == portable(labels.midpoint))
                #expect(text(31, in: region) == portable(labels.upperBound))
                #expect(text(40, in: region) == "LOW")
                #expect(text(67, in: region) == "LOW")
                #expect(text(75, in: region) == "Start")
                #expect(text(95, in: region) == "5 s")
                if variant == .diagnostic {
                    #expect(text(97, in: region) == String(repeating: "E", count: 96))
                }
            }
        }

        check(.normal)
        let diagnostic = SignalAnalyzerDiagnostic(
            exactUTF8: [UInt8](repeating: 0x45, count: 96)
        )!
        let began = model.beginMutation()
        let changed = model.setAcquisitionState(.failed(diagnostic))
        let ended = model.endMutation()
        #expect(began && changed && ended)
        check(.diagnostic)
        model.retire()
    }
}
