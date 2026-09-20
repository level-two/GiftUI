// Generated from the two portable Signal Analyzer Canvas expressions.
// Keep this output synchronized with the SPEC-001 Static Canvas manifest.

import GiftUI
import GiftUIDrawing
import GiftUIRuntimeStatic
import SignalAnalyzerDomain
import SignalAnalyzerPresentation

package struct StaticSignalAnalyzerNRFGridCanvasCapture: Sendable {
    package init() {}
}

package struct StaticSignalAnalyzerNRFTraceCanvasCapture: Sendable {
    fileprivate let model: StaticCanvasObservableModelHandle<SignalAnalyzerViewModel>
    fileprivate let channelRawValue: Int64
    fileprivate let visibleLowerMilliseconds: Int64
    fileprivate let visibleUpperMilliseconds: Int64

    package init?(
        model: StaticCanvasObservableModelHandle<SignalAnalyzerViewModel>,
        channelID: SignalChannelID,
        visibleRange: Range<Duration>
    ) {
        guard channelID.isStandard,
            let lower = Self.exactMilliseconds(visibleRange.lowerBound),
            let upper = Self.exactMilliseconds(visibleRange.upperBound),
            lower >= 0,
            lower < upper
        else { return nil }

        self.model = model
        channelRawValue = Int64(channelID.rawValue)
        visibleLowerMilliseconds = lower
        visibleUpperMilliseconds = upper
    }

    private static func exactMilliseconds(_ duration: Duration) -> Int64? {
        let components = duration.components
        let milliseconds = components.seconds.multipliedReportingOverflow(by: 1_000)
        guard !milliseconds.overflow,
            components.attoseconds.isMultiple(of: 1_000_000_000_000_000)
        else { return nil }
        let fractional = components.attoseconds / 1_000_000_000_000_000
        let result = milliseconds.partialValue.addingReportingOverflow(fractional)
        return result.overflow ? nil : result.partialValue
    }
}

package struct StaticSignalAnalyzerNRFCanvasCaptureStorage: Sendable {
    fileprivate let model: StaticCanvasObservableModelHandle<SignalAnalyzerViewModel>?
    fileprivate let channelRawValue: Int64
    fileprivate let visibleLowerMilliseconds: Int64
    fileprivate let visibleUpperMilliseconds: Int64

    package init(_: StaticSignalAnalyzerNRFGridCanvasCapture) {
        model = nil
        channelRawValue = 0
        visibleLowerMilliseconds = 0
        visibleUpperMilliseconds = 0
    }

    package init(_ capture: StaticSignalAnalyzerNRFTraceCanvasCapture) {
        model = capture.model
        channelRawValue = capture.channelRawValue
        visibleLowerMilliseconds = capture.visibleLowerMilliseconds
        visibleUpperMilliseconds = capture.visibleUpperMilliseconds
    }
}

package struct StaticSignalAnalyzerNRFCanvasCallableTable: StaticCanvasCallableTable {
    package let callableCaseCount: UInt16 = 2

    package init() {}

    package func captureByteCount(for id: UInt16) -> UInt16? {
        switch id {
        case 1: UInt16(MemoryLayout<StaticSignalAnalyzerNRFGridCanvasCapture>.size)
        case 2: UInt16(MemoryLayout<StaticSignalAnalyzerNRFTraceCanvasCapture>.size)
        default: nil
        }
    }

    package mutating func invoke(
        id: UInt16,
        captures: borrowing StaticSignalAnalyzerNRFCanvasCaptureStorage,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        switch id {
        case 1:
            try drawSignalAnalyzerGrid(context: &context, size: size)
        case 2:
            guard let model = captures.model,
                let channel = Int(exactly: captures.channelRawValue),
                captures.visibleLowerMilliseconds >= 0,
                captures.visibleLowerMilliseconds < captures.visibleUpperMilliseconds
            else { throw .invariantViolation }
            let channelID = SignalChannelID(rawValue: channel)
            guard channelID.isStandard else { throw .invariantViolation }
            let visibleRange =
                Duration.milliseconds(captures.visibleLowerMilliseconds)
                    ..< Duration.milliseconds(captures.visibleUpperMilliseconds)
            try model.withModel { model throws(DrawingError) in
                try drawSignalAnalyzerTrace(
                    context: &context,
                    size: size,
                    channelID: channelID,
                    capture: model.state.capture,
                    visibleRange: visibleRange
                )
            }
        default:
            throw .invariantViolation
        }
    }
}
