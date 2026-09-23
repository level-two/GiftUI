import SignalAnalyzerDomain

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
        let scopeCount: UInt16 = variant == .normal ? 96 : 98
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
        guard textCount == (variant == .normal ? 20 : 21) else { return nil }
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
        case 6: fixed("DIGITAL SIGNAL ANALYZER")
        case 8: fixed("Four-channel acquisition")
        case 13: status(model.acquisitionState)
        case 25: seconds(model.visibleRange.lowerBound)
        case 28:
            seconds(
                model.visibleRange.lowerBound
                    + (model.visibleRange.upperBound - model.visibleRange.lowerBound) / 2)
        case 31: seconds(model.visibleRange.upperBound)
        case 36: fixed("CH1")
        case 40: level(channel: 1, model: model, capture: capture)
        case 45: fixed("CH2")
        case 49: level(channel: 2, model: model, capture: capture)
        case 54: fixed("CH3")
        case 58: level(channel: 3, model: model, capture: capture)
        case 63: fixed("CH4")
        case 67: level(channel: 4, model: model, capture: capture)
        case 75: fixed("Start")
        case 79: fixed("Stop")
        case 82: fixed("Clear")
        case 87: fixed("1 s")
        case 91: fixed("2 s")
        case 95: fixed("5 s")
        case 97 where variant == .diagnostic: model.errorMessage
        default: nil
        }
    }

    private static func fixed(_ text: StaticString) -> SignalAnalyzerDiagnostic? {
        text.withUTF8Buffer { SignalAnalyzerDiagnostic(exactUTF8: $0) }
    }

    private static func status(_ state: AcquisitionState) -> SignalAnalyzerDiagnostic? {
        switch state {
        case .idle: fixed("READY")
        case .running: fixed("RUNNING")
        case .stopped: fixed("STOPPED")
        case .failed: fixed("FAILED")
        }
    }

    private static func level(
        channel: Int,
        model: borrowing StaticSignalAnalyzerNRFModelLocation,
        capture: borrowing StaticSignalAnalyzerNRFCaptureRegions
    ) -> SignalAnalyzerDiagnostic? {
        let channelID = SignalChannelID(rawValue: channel)
        guard var current = model.capture.baselineLevels[channelID] else { return nil }
        var index = 0
        while index < Int(model.capture.count) {
            guard let transition = capture.load(from: .snapshot, at: index)?.transition
            else { return nil }
            if transition.channelID == channelID { current = transition.level }
            index += 1
        }
        return current == .low ? fixed("LOW") : fixed("HIGH")
    }

    private static func seconds(_ duration: Duration) -> SignalAnalyzerDiagnostic? {
        let components = duration.components
        let hundredths: Int64
        if components.seconds < 0 {
            hundredths = 0
        } else {
            let seconds = components.seconds.multipliedReportingOverflow(by: 100)
            if seconds.overflow {
                hundredths = .max
            } else {
                let fractional = max(0, components.attoseconds / 10_000_000_000_000_000)
                let result = seconds.partialValue.addingReportingOverflow(fractional)
                hundredths = result.overflow ? .max : result.partialValue
            }
        }
        var storage = (
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0)
        )
        var count = 0
        withUnsafeMutableBytes(of: &storage) { bytes in
            var whole = hundredths / 100
            repeat {
                bytes[count] = 48 + UInt8(whole % 10)
                count += 1
                whole /= 10
            } while whole > 0
            bytes[0 ..< count].reverse()
            bytes[count] = 46
            bytes[count + 1] = 48 + UInt8((hundredths % 100) / 10)
            bytes[count + 2] = 48 + UInt8(hundredths % 10)
            bytes[count + 3] = 32
            bytes[count + 4] = 115
            count += 5
        }
        return withUnsafeBytes(of: storage) { bytes in
            SignalAnalyzerDiagnostic(exactUTF8: bytes.prefix(count))
        }
    }
}
