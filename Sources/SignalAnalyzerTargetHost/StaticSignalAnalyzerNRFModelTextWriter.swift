import SignalAnalyzerDomain
import SignalAnalyzerPresentation

/// Lowers the portable Signal Analyzer text projection into the generated
/// scope table without constructing a String or retaining a model borrow.
package enum StaticSignalAnalyzerNRFModelTextWriter {
    package static func populate(
        variant: StaticSignalAnalyzerNRFSemanticVariant,
        model: borrowing StaticSignalAnalyzerNRFModelLocation,
        capture: borrowing StaticSignalAnalyzerNRFCaptureRegions,
        in region: UnsafeMutableRawBufferPointer
    ) -> UInt16? {
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        let pool = StaticSignalAnalyzerNRFUTF8TextPool.self
        guard region.count == table.regionByteCount else { return nil }
        let scopeCount: UInt16 = 92
        var ordinal: UInt16 = 0
        var required: UInt16 = 0
        var textCount: UInt16 = 0
        while ordinal < scopeCount {
            guard let record = table.scope(at: ordinal, in: region) else { return nil }
            if record.kind == .text {
                guard record.flags == 0, record.auxiliary == 0,
                    record.payload0 == 0, record.payload1 == 0,
                    record.payload2 == 0,
                    let value = value(
                        at: ordinal, variant: variant, model: model, capture: capture),
                    value.utf8ByteCount <= pool.maximumByteCount - required
                else { return nil }
                required += value.utf8ByteCount
                textCount += 1
            }
            ordinal += 1
        }
        guard textCount == (17) else { return nil }
        ordinal = 0
        var used: UInt16 = 0
        while ordinal < scopeCount {
            guard let old = table.scope(at: ordinal, in: region) else { return nil }
            if old.kind == .text {
                guard
                    let value = value(
                        at: ordinal, variant: variant, model: model, capture: capture
                    ),
                    let count = value.withUTF8({ bytes in
                        pool.appendBytes(bytes, at: used, in: region)
                    }),
                    table.storeScope(
                        StaticSignalAnalyzerNRFScopeRecord(
                            identity: old.identity,
                            parent: old.parent,
                            firstChild: old.firstChild,
                            nextSibling: old.nextSibling,
                            kind: .text,
                            flags: 0,
                            auxiliary: 0,
                            payload0: UInt32(used),
                            payload1: UInt32(count),
                            payload2: 0
                        ),
                        at: ordinal,
                        in: region
                    )
                else { return nil }
                used += count
            }
            ordinal += 1
        }
        return used == required ? used : nil
    }

    private static func value(
        at ordinal: UInt16,
        variant: StaticSignalAnalyzerNRFSemanticVariant,
        model: borrowing StaticSignalAnalyzerNRFModelLocation,
        capture: borrowing StaticSignalAnalyzerNRFCaptureRegions
    ) -> SignalAnalyzerDiagnostic? {
        switch ordinal {
        case 8: return fixed("DIGITAL SIGNAL ANALYZER")
        case 10: return fixed("Four-channel acquisition")
        case 13: return model.errorMessage ?? fixed("")
        case 22:
            if case .running = model.acquisitionState { return fixed("R") }
            return fixed("S")
        case 39: return fixed("-")
        case 63: return fixed("+")
        case 46: return seconds(model.visibleRange.lowerBound)
        case 50:
            return seconds(
                model.visibleRange.lowerBound
                    + (model.visibleRange.upperBound - model.visibleRange.lowerBound) / 2)
        case 54: return seconds(model.visibleRange.upperBound)
        case 66: return fixed("CH1")
        case 73: return fixed("CH2")
        case 80: return fixed("CH3")
        case 87: return fixed("CH4")
        case 70: return level(channel: 1, model: model, capture: capture)
        case 77: return level(channel: 2, model: model, capture: capture)
        case 84: return level(channel: 3, model: model, capture: capture)
        case 91: return level(channel: 4, model: model, capture: capture)
        default: return nil
        }
    }

    private static func fixed(_ text: StaticString) -> SignalAnalyzerDiagnostic? {
        text.withUTF8Buffer { SignalAnalyzerDiagnostic(exactUTF8: $0) }
    }

    private static func level(
        channel: Int,
        model: borrowing StaticSignalAnalyzerNRFModelLocation,
        capture: borrowing StaticSignalAnalyzerNRFCaptureRegions
    ) -> SignalAnalyzerDiagnostic? {
        let channelID = SignalChannelID(rawValue: channel)
        guard let current = model.capture.currentLevel(for: channelID, in: capture)
        else { return nil }
        return current == .low ? fixed("LOW") : fixed("HIGH")
    }

    private static func seconds(_ duration: Duration) -> SignalAnalyzerDiagnostic? {
        SignalAnalyzerTimelineFormatting.seconds(duration)
    }
}
