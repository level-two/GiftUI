import SignalAnalyzerDomain
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFEmbeddedSemanticRegionPublishesOnlyValidatedRevisions() {
    let capturePointer = UnsafeMutableRawPointer.allocate(
        byteCount: StaticSignalAnalyzerNRFCaptureRegions.requiredByteCount,
        alignment: 8
    )
    defer { capturePointer.deallocate() }
    guard
        let captures = StaticSignalAnalyzerNRFCaptureRegions(
            storage: UnsafeMutableRawBufferPointer(
                start: capturePointer,
                count: StaticSignalAnalyzerNRFCaptureRegions.requiredByteCount
            )
        )
    else {
        Issue.record("The exact capture region must construct")
        return
    }
    var model = StaticSignalAnalyzerNRFModelLocation()
    let generation = model.activate()
    #expect(generation == 0)
    var candidateBytes = [UInt8](repeating: 0, count: 3_024)
    var publishedBytes = [UInt8](repeating: 0, count: 3_024)
    candidateBytes.withUnsafeMutableBytes { candidate in
        publishedBytes.withUnsafeMutableBytes { published in
            let normalText = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.stage(
                variant: .normal, model: model, capture: captures, in: candidate
            )
            #expect(normalText != nil)
            #expect(
                StaticSignalAnalyzerNRFPackedSemanticRecords.utf8TableSummary(
                    in: candidate
                )?.scopeCount == 96
            )
            let overlap = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: 1, candidate: candidate, published: candidate
            )
            #expect(!overlap)
            let first = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: 1, candidate: candidate, published: published
            )
            #expect(first)
            #expect(StaticSignalAnalyzerNRFEmbeddedSemanticRegion.verifyPublished(published))
            let repeated = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: 1, candidate: candidate, published: published
            )
            #expect(!repeated)
            let previous = [UInt8](published)
            candidate[StaticSignalAnalyzerNRFPackedSemanticRecords.scopeOffset + 6 * 24 + 12] = 1
            let corrupt = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: 2, candidate: candidate, published: published
            )
            #expect(!corrupt)
            #expect([UInt8](published) == previous)

            let diagnostic = SignalAnalyzerDiagnostic(exactUTF8: [0x45, 0x52, 0x52])!
            let began = model.beginMutation()
            let installed = model.setAcquisitionState(.failed(diagnostic))
            let ended = model.endMutation()
            #expect(began && installed && ended)
            let diagnosticText = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.stage(
                variant: .diagnostic, model: model, capture: captures, in: candidate
            )
            #expect(diagnosticText != nil)
            #expect(
                StaticSignalAnalyzerNRFPackedSemanticRecords.utf8TableSummary(
                    in: candidate
                )?.scopeCount == 98
            )
            let next = StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: 2, candidate: candidate, published: published
            )
            #expect(next)
            #expect(StaticSignalAnalyzerNRFEmbeddedSemanticRegion.verifyPublished(published))
            #expect(published[6] == 2)
            #expect(published[7] == 1)
            #expect(published[28] == 2)
        }
    }
    model.retire()
}
