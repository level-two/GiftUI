import SignalAnalyzerPresentation
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFTopologyWriterRejectsWrongRegionWithoutMutation() {
    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
    var bytes = [UInt8](repeating: 0xA5, count: table.regionByteCount)
    bytes.withUnsafeMutableBytes { region in
        let short = UnsafeMutableRawBufferPointer(rebasing: region[..<3_023])
        #expect(
            StaticSignalAnalyzerNRFTopologyWriter.populateShape(
                variant: .normal,
                in: short
            ) == nil
        )
    }
    #expect(bytes.allSatisfy { $0 == 0xA5 })
}

@Test func staticNRFTopologyWriterUsesExactVariantScopeCounts() {
    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
    for (variant, count) in [
        (StaticSignalAnalyzerNRFSemanticVariant.normal, UInt16(92)),
        (.diagnostic, UInt16(92)),
    ] {
        var bytes = [UInt8](repeating: 0, count: table.regionByteCount)
        bytes.withUnsafeMutableBytes { region in
            #expect(
                StaticSignalAnalyzerNRFTopologyWriter.populateShape(
                    variant: variant,
                    in: region
                ) == count
            )
            #expect(table.scope(at: 0, in: region)?.parent == table.missingOrdinal)
            #expect(table.scope(at: count - 1, in: region) != nil)
            #expect(
                StaticSignalAnalyzerNRFTopologyWriter.populateBindings(
                    scopeCount: count,
                    in: region
                )
            )
            #expect(table.actionScope(at: 0, in: region) == 16)
            #expect(table.scope(at: 28, in: region)?.payload0 == 1)
            #expect(
                StaticSignalAnalyzerNRFTopologyWriter.populateInvariantPrimitives(
                    scopeCount: count,
                    in: region
                )
            )
            #expect(table.scope(at: 3, in: region)?.payload0 == 0)
            #expect(table.scope(at: 5, in: region)?.payload0 == 4)
            #expect(
                StaticSignalAnalyzerNRFTopologyWriter.populateInvariantLayoutModifiers(
                    scopeCount: count,
                    in: region
                )
            )
            #expect(
                table.scope(at: 27, in: region)?.payload0
                    == UInt32(SignalAnalyzerLayoutConstraints.reference.gridWidth))
            #expect(
                table.scope(at: 27, in: region)?.payload1
                    == UInt32(SignalAnalyzerLayoutConstraints.reference.gridHeight))
            #expect(
                StaticSignalAnalyzerNRFTopologyWriter.populateInvariantStyles(
                    scopeCount: count,
                    in: region
                )
            )
            #expect(table.scope(at: 2, in: region)?.payload0 == 16_777_215)
            #expect(table.scope(at: 44, in: region)?.flags == 17)
            #expect(table.scope(at: 44, in: region)?.payload0 == 8_421_504)
            #expect(table.scope(at: 12, in: region)?.flags == 17)
            #expect(
                !StaticSignalAnalyzerNRFTopologyWriter.populateInvariantStyles(
                    scopeCount: count,
                    in: region
                )
            )
            #expect(
                !StaticSignalAnalyzerNRFTopologyWriter.populateInvariantLayoutModifiers(
                    scopeCount: count,
                    in: region
                )
            )
            #expect(
                !StaticSignalAnalyzerNRFTopologyWriter.populateInvariantPrimitives(
                    scopeCount: count,
                    in: region
                )
            )
            #expect(
                !StaticSignalAnalyzerNRFTopologyWriter.populateBindings(
                    scopeCount: count,
                    in: region
                )
            )
        }
    }
}

@Test func staticNRFTopologyBindingsRejectUnpopulatedShapeWithoutMutation() {
    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
    var bytes = [UInt8](repeating: 0, count: table.regionByteCount)
    bytes.withUnsafeMutableBytes { region in
        #expect(
            !StaticSignalAnalyzerNRFTopologyWriter.populateBindings(
                scopeCount: 92,
                in: region
            )
        )
    }
    #expect(bytes.allSatisfy { $0 == 0 })
}
