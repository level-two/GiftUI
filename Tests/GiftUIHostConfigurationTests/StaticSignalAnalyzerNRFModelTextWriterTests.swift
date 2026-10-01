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
                let count: UInt16 = variant == .normal ? 91 : 93
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
                #expect(table.scope(at: 11, in: region)?.flags == statusPayload?.flags)
                #expect(table.scope(at: 11, in: region)?.payload0 == statusPayload?.payload0)
                #expect(
                    table.scope(at: 68, in: region)?.payload0
                        == (channelOne == "HIGH" ? 0x00_FF_00 : 0xFF_80_00)
                )
                #expect(table.scope(at: 31, in: region)?.flags == 1)
                #expect(
                    table.scope(at: 55, in: region)?.flags
                        == (model.visibleWindowRawValue == 2 ? 65 : 1))
                #expect(text(8, in: region) == "DIGITAL SIGNAL ANALYZER")
                #expect(text(12, in: region) == portable(controls.statusText))
                #expect(text(45, in: region) == portable(labels.lowerBound))
                #expect(text(49, in: region) == portable(labels.midpoint))
                #expect(text(53, in: region) == portable(labels.upperBound))
                #expect(text(69, in: region) == channelOne)
                #expect(text(90, in: region) == "LOW")
                #expect(text(21, in: region) == portable(controls.recordingLabel))
                #expect(text(38, in: region) == "-")
                #expect(text(62, in: region) == "+")
                if variant == .diagnostic {
                    #expect(text(92, in: region) == String(repeating: "E", count: 96))
                }
                region[table.scopeOffset + 8 * table.scopeStride + 12] = 1
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
