import GiftUI
import GiftUISemanticCore
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
        guard var captures = StaticSignalAnalyzerNRFCaptureRegions(storage: captureBytes)
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

        func check(
            _ variant: StaticSignalAnalyzerNRFSemanticVariant,
            channelOne: String
        ) {
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
                let modifiersPopulated = StaticSignalAnalyzerNRFModelModifierWriter.populate(
                    model: model, capture: captures, in: region
                )
                #expect(modifiersPopulated)
                let textBytes = StaticSignalAnalyzerNRFModelTextWriter.populate(
                    variant: variant, model: model, capture: captures, in: region
                )
                #expect(textBytes != nil)
                if let textBytes {
                    #expect(
                        table.validateUTF8Topology(
                            scopeCount: count, textByteCount: textBytes, in: region
                        )
                    )
                    #expect(
                        StaticSignalAnalyzerNRFEmbeddedSemanticValidator.validate(
                            variant: variant, textByteCount: textBytes, in: region
                        )
                    )
                }
                let labels = SignalAnalyzerRulerLabels(visibleRange: model.visibleRange)
                let selectedWindow: VisibleTimeWindow =
                    model.visibleWindowRawValue == 2 ? .fiveSeconds : .twoSeconds
                let controls = SignalAnalyzerControlState(
                    acquisitionState: model.acquisitionState,
                    selectedWindow: selectedWindow
                )
                let statusColor: Color
                switch model.acquisitionState {
                case .idle, .stopped: statusColor = .white
                case .running: statusColor = .green
                case .failed: statusColor = .red
                }
                let statusPayload = StaticSignalAnalyzerNRFModifierPayload(
                    modifier: .passthrough,
                    renderScope: .foregroundStyle(statusColor)
                )
                #expect(table.scope(at: 12, in: region)?.flags == statusPayload?.flags)
                #expect(table.scope(at: 12, in: region)?.payload0 == statusPayload?.payload0)
                #expect(
                    table.scope(at: 39, in: region)?.payload0
                        == (channelOne == "HIGH" ? 0x00_FF_00 : 0xFF_80_00)
                )
                let startFlags = table.scope(at: 72, in: region)?.flags ?? 0
                let stopFlags = table.scope(at: 76, in: region)?.flags ?? 0
                #expect((startFlags & 0x40 != 0) == controls.startDisabled)
                #expect((stopFlags & 0x40 != 0) == controls.stopDisabled)
                #expect(
                    table.scope(at: model.visibleWindowRawValue == 2 ? 92 : 88, in: region)?
                        .flags == 65
                )
                #expect(text(6, in: region) == "DIGITAL SIGNAL ANALYZER")
                #expect(text(13, in: region) == portable(controls.statusText))
                #expect(text(25, in: region) == portable(labels.lowerBound))
                #expect(text(28, in: region) == portable(labels.midpoint))
                #expect(text(31, in: region) == portable(labels.upperBound))
                #expect(text(40, in: region) == channelOne)
                #expect(text(67, in: region) == "LOW")
                #expect(text(75, in: region) == "Start")
                #expect(text(95, in: region) == "5 s")
                if variant == .diagnostic {
                    #expect(text(97, in: region) == String(repeating: "E", count: 96))
                }
                region[table.scopeOffset + 6 * table.scopeStride + 12] = 1
                if let textBytes {
                    #expect(
                        !StaticSignalAnalyzerNRFEmbeddedSemanticValidator.validate(
                            variant: variant, textByteCount: textBytes, in: region
                        )
                    )
                }
            }
        }

        check(.normal, channelOne: "LOW")
        let first = SignalTransition(
            channelID: SignalChannelID(rawValue: 1),
            timestamp: .seconds(3), level: .high
        )
        guard let record = StaticSignalAnalyzerNRFCaptureRecord(first),
            captures.store(record, in: .admission, at: 0),
            let snapshot = StaticSignalAnalyzerNRFCaptureSnapshotView(
                storage: captureBytes, revision: 1, count: 1,
                duration: .seconds(3), retainedLowerBound: .zero,
                baselineLevels: .allLow
            )
        else {
            Issue.record("The model snapshot fixture must fit")
            return
        }
        let beganRunning = model.beginMutation()
        let installed = model.installCaptureSnapshot(snapshot, in: &captures)
        let running = model.setAcquisitionState(.running)
        let selected = withUnsafeMutablePointer(to: &model) { location in
            StaticSignalAnalyzerNRFModelHandle(
                location: location, generation: location.pointee.activeGeneration!
            )?.dispatch(actionRawValue: 5)
        }
        let endedRunning = model.endMutation()
        #expect(beganRunning && installed && running && endedRunning)
        #expect(selected == .visibleWindowChanged)
        check(.normal, channelOne: "HIGH")
        let diagnostic = SignalAnalyzerDiagnostic(
            exactUTF8: [UInt8](repeating: 0x45, count: 96)
        )!
        let began = model.beginMutation()
        let changed = model.setAcquisitionState(.failed(diagnostic))
        let ended = model.endMutation()
        #expect(began && changed && ended)
        check(.diagnostic, channelOne: "HIGH")
        model.retire()
    }
}
