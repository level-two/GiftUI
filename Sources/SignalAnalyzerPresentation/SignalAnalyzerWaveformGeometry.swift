import GiftUI
import SignalAnalyzerDomain

package struct SignalAnalyzerRulerLabels: Equatable, Sendable {
    package let lowerBound: BoundedText
    package let midpoint: BoundedText
    package let upperBound: BoundedText

    package init(visibleRange: Range<Duration>) {
        let span = visibleRange.upperBound - visibleRange.lowerBound
        lowerBound = SignalAnalyzerWaveformGeometry.formattedSeconds(visibleRange.lowerBound)
        midpoint = SignalAnalyzerWaveformGeometry.formattedSeconds(
            visibleRange.lowerBound + span / 2
        )
        upperBound = SignalAnalyzerWaveformGeometry.formattedSeconds(visibleRange.upperBound)
    }
}

package enum SignalAnalyzerWaveformGeometry {
    package static let canvasOccurrenceCount = 5
    package static let strokeCount = 5
    package static let gridSubpathCount = 12
    package static let gridPointCount = 24
    package static let maximumLiveTracePointCount = 202
    package static let snapshotPointCount = 832
    package static let snapshotSubpathCount = 16

    package static func startingLevel(
        capture: SignalCapture,
        channelID: SignalChannelID,
        visibleLowerBound: Duration
    ) -> DigitalLevel {
        var result = capture.baselineLevel(for: channelID)
        for transition in capture.transitions
        where transition.channelID == channelID && transition.timestamp <= visibleLowerBound {
            result = transition.level
        }
        return result
    }

    package static func tracePointCount(
        capture: SignalCapture,
        channelID: SignalChannelID,
        visibleRange: Range<Duration>
    ) -> Int {
        var count = 2
        for transition in capture.transitions
        where transition.channelID == channelID
            && transition.timestamp > visibleRange.lowerBound
            && transition.timestamp <= visibleRange.upperBound
        {
            count += 2
        }
        return count
    }

    package static func x(
        for timestamp: Duration,
        visibleRange: Range<Duration>,
        width: GeometryScalar
    ) -> GeometryScalar {
        guard width > 0 else { return 0 }
        let span = milliseconds(visibleRange.upperBound - visibleRange.lowerBound)
        guard span > 0 else { return 0 }
        let elapsed = milliseconds(timestamp - visibleRange.lowerBound)
        let boundedElapsed = min(span, max(0, elapsed))
        return GeometryScalar(boundedElapsed * Int64(width) / span)
    }

    package static func y(
        for level: DigitalLevel,
        height: GeometryScalar
    ) -> GeometryScalar {
        switch level {
        case .high: max(1, height / 4)
        case .low: min(height - 1, max(2, height - height / 4))
        }
    }

    package static func formattedSeconds(_ duration: Duration) -> BoundedText {
        let totalHundredths = hundredths(duration)
        let whole = totalHundredths / 100
        let fractional = totalHundredths % 100
        var storage = (
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0)
        )
        var count = 0
        withUnsafeMutableBytes(of: &storage) { bytes in
            var magnitude = whole
            repeat {
                bytes[count] = UInt8(ascii: "0") + UInt8(magnitude % 10)
                count += 1
                magnitude /= 10
            } while magnitude > 0
            bytes[0 ..< count].reverse()
            bytes[count] = UInt8(ascii: ".")
            count += 1
            bytes[count] = UInt8(ascii: "0") + UInt8(fractional / 10)
            count += 1
            bytes[count] = UInt8(ascii: "0") + UInt8(fractional % 10)
            count += 1
            bytes[count] = UInt8(ascii: " ")
            count += 1
            bytes[count] = UInt8(ascii: "s")
            count += 1
        }
        return withUnsafeBytes(of: storage) { bytes in
            BoundedText(utf8: bytes.prefix(count))!
        }
    }

    private static func hundredths(_ duration: Duration) -> Int64 {
        let components = duration.components
        guard components.seconds >= 0 else { return 0 }
        let seconds = components.seconds.multipliedReportingOverflow(by: 100)
        guard !seconds.overflow else { return .max }
        let fractional = max(0, components.attoseconds / 10_000_000_000_000_000)
        let result = seconds.partialValue.addingReportingOverflow(fractional)
        return result.overflow ? .max : result.partialValue
    }

    private static func milliseconds(_ duration: Duration) -> Int64 {
        let components = duration.components
        let seconds = components.seconds.multipliedReportingOverflow(by: 1_000)
        guard !seconds.overflow else { return components.seconds < 0 ? .min : .max }
        let fractional = components.attoseconds / 1_000_000_000_000_000
        let result = seconds.partialValue.addingReportingOverflow(fractional)
        return result.overflow ? (seconds.partialValue < 0 ? .min : .max) : result.partialValue
    }
}
