#if GIFTUI_NRF_EMBEDDED
    /// Five generated Canvas occurrences over one published semantic region.
    /// Capture records stay in the caller-owned snapshot slot during derivation.
    package struct StaticSignalAnalyzerNRFEmbeddedCanvasSource:
        CanvasInvocationSource
    {
        package typealias Identity = UInt16
        package let canvasOccurrenceCount =
            StaticSignalAnalyzerNRFEmbeddedCanvasTable.occurrenceCount
        private let semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView
        private let captureState: StaticSignalAnalyzerNRFModelCaptureState
        private let captureRegion: UnsafeMutableRawBufferPointer
        private let callableRegion: UnsafeMutableRawBufferPointer
        private let modelGeneration: UInt32
        private var released: UInt8 = 0

        package init?(
            semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView,
            model: StaticSignalAnalyzerNRFModelLocation,
            captureRegion: UnsafeMutableRawBufferPointer,
            callableRegion: UnsafeMutableRawBufferPointer
        ) {
            guard StaticSignalAnalyzerNRFEmbeddedCanvasTable.callableCaseCount == 2,
                let generation = model.activeGeneration,
                StaticSignalAnalyzerNRFCaptureRegions(storage: captureRegion) != nil,
                StaticSignalAnalyzerNRFEmbeddedCanvasPayload.isEmpty(callableRegion)
            else { return nil }
            self.semantic = semantic
            captureState = model.capture
            self.captureRegion = captureRegion
            self.callableRegion = callableRegion
            modelGeneration = generation
            let visibleRange = model.visibleRange
            guard let lower = Self.exactMilliseconds(visibleRange.lowerBound),
                let upper = Self.exactMilliseconds(visibleRange.upperBound)
            else { return nil }
            var index: UInt16 = 0
            while index < canvasOccurrenceCount {
                guard canvasIdentity(at: index) != nil,
                    let callableID = StaticSignalAnalyzerNRFEmbeddedCanvasTable.callableID(
                        at: index
                    ),
                    let captureBytes =
                        StaticSignalAnalyzerNRFEmbeddedCanvasTable.captureByteCount(
                            for: callableID
                        ),
                    let channel = StaticSignalAnalyzerNRFEmbeddedCanvasTable.channel(
                        at: index
                    ),
                    (index == 0 && callableID == 1 && captureBytes == 0 && channel == 0)
                        || (index > 0 && callableID == 2 && captureBytes == 32
                            && channel == UInt8(index)),
                    index == 0
                        || StaticSignalAnalyzerNRFEmbeddedCanvasPayload.stageTrace(
                            .init(
                                modelToken: UInt64(generation) + 1,
                                channelRawValue: Int64(channel),
                                lowerMilliseconds: lower,
                                upperMilliseconds: upper
                            ), at: index, in: callableRegion
                        )
                else {
                    callableRegion.initializeMemory(as: UInt8.self, repeating: 0)
                    return nil
                }
                index += 1
            }
        }

        package func canvasIdentity(at index: UInt16) -> UInt16? {
            guard index < canvasOccurrenceCount else { return nil }
            var ordinal: UInt16 = 0
            while ordinal < semantic.scopeCount {
                guard let identity = semantic.semanticIdentity(at: ordinal),
                    let record = semantic.scope(at: identity)
                else { return nil }
                if record.kind == .canvas, record.payload0 == UInt32(index + 1) {
                    return identity
                }
                ordinal += 1
            }
            return nil
        }

        package mutating func invokeCanvas(
            at identity: UInt16, context: inout GraphicsContext, size: Size
        ) throws(DrawingError) {
            var index: UInt16 = 0
            while index < canvasOccurrenceCount {
                if canvasIdentity(at: index) == identity {
                    let bit = UInt8(1) << UInt8(index)
                    guard released & bit == 0 else { throw .invariantViolation }
                    guard
                        let callableID =
                            StaticSignalAnalyzerNRFEmbeddedCanvasTable
                            .callableID(at: index),
                        let captureBytes =
                            StaticSignalAnalyzerNRFEmbeddedCanvasTable
                            .captureByteCount(for: callableID),
                        let channel =
                            StaticSignalAnalyzerNRFEmbeddedCanvasTable
                            .channel(at: index)
                    else { throw .invariantViolation }
                    switch callableID {
                    case 1:
                        guard captureBytes == 0, channel == 0 else {
                            throw .invariantViolation
                        }
                        try drawGrid(context: &context, size: size)
                    case 2:
                        guard captureBytes == 32 else { throw .invariantViolation }
                        guard
                            let payload =
                                StaticSignalAnalyzerNRFEmbeddedCanvasPayload.trace(
                                    at: index, in: callableRegion
                                ), payload.modelToken == UInt64(modelGeneration) + 1,
                            payload.channelRawValue == Int64(channel)
                        else { throw .invariantViolation }
                        try drawTrace(
                            context: &context, size: size,
                            channelID: SignalChannelID(
                                rawValue: Int(payload.channelRawValue)
                            ),
                            visibleRange: Duration.milliseconds(payload.lowerMilliseconds)
                                ..< Duration.milliseconds(payload.upperMilliseconds)
                        )
                    default: throw .invariantViolation
                    }
                    return
                }
                index += 1
            }
            throw .invariantViolation
        }

        package mutating func releaseCanvas(at identity: UInt16) {
            var index: UInt16 = 0
            while index < canvasOccurrenceCount {
                if canvasIdentity(at: index) == identity {
                    _ = StaticSignalAnalyzerNRFEmbeddedCanvasPayload.release(
                        at: index, in: callableRegion
                    )
                    released |= UInt8(1) << UInt8(index)
                    return
                }
                index += 1
            }
        }

        package var allReleased: Bool {
            released == 0b1_1111
                && StaticSignalAnalyzerNRFEmbeddedCanvasPayload.isEmpty(callableRegion)
        }

        private func drawGrid(
            context: inout GraphicsContext, size: Size
        ) throws(DrawingError) {
            guard size.width > 0, size.height > 0 else { throw .invalidValue }
            try context.withPath { (context, path) throws(DrawingError) in
                for index in 0 ... 10 {
                    let x = GeometryScalar(Int64(size.width) * Int64(index) / 10)
                    try path.move(to: Point(x: x, y: 0))
                    try path.addLine(to: Point(x: x, y: size.height))
                }
                let centerY = size.height / 2
                try path.move(to: Point(x: 0, y: centerY))
                try path.addLine(to: Point(x: size.width, y: centerY))
                try context.stroke(path, with: .color(.gray), lineWidth: 1)
            }
        }

        private func drawTrace(
            context: inout GraphicsContext,
            size: Size,
            channelID: SignalChannelID,
            visibleRange: Range<Duration>
        ) throws(DrawingError) {
            guard size.width > 0, size.height >= 4,
                channelID.isStandard,
                let regions = StaticSignalAnalyzerNRFCaptureRegions(
                    storage: captureRegion
                ),
                var level = captureState.baselineLevels[channelID]
            else { throw .invalidValue }
            var index = 0
            while index < Int(captureState.count) {
                guard let transition = regions.load(from: .snapshot, at: index)?.transition
                else { throw .invariantViolation }
                if transition.channelID == channelID,
                    transition.timestamp <= visibleRange.lowerBound
                {
                    level = transition.level
                }
                index += 1
            }
            try context.withPath { (context, path) throws(DrawingError) in
                try path.move(to: Point(x: 0, y: y(for: level, height: size.height)))
                var current = level
                var ordinal = 0
                while ordinal < Int(captureState.count) {
                    guard
                        let transition = regions.load(
                            from: .snapshot, at: ordinal
                        )?.transition
                    else { throw .invariantViolation }
                    if transition.channelID == channelID,
                        transition.timestamp > visibleRange.lowerBound,
                        transition.timestamp <= visibleRange.upperBound
                    {
                        let x = x(
                            for: transition.timestamp, width: size.width,
                            visibleRange: visibleRange
                        )
                        try path.addLine(
                            to: Point(x: x, y: y(for: current, height: size.height))
                        )
                        current = transition.level
                        try path.addLine(
                            to: Point(x: x, y: y(for: current, height: size.height))
                        )
                    }
                    ordinal += 1
                }
                try path.addLine(
                    to: Point(
                        x: size.width, y: y(for: current, height: size.height)
                    )
                )
                try context.stroke(path, with: .color(.green), lineWidth: 1)
            }
        }

        private func x(
            for timestamp: Duration, width: GeometryScalar,
            visibleRange: Range<Duration>
        ) -> GeometryScalar {
            let span = milliseconds(visibleRange.upperBound - visibleRange.lowerBound)
            guard width > 0, span > 0 else { return 0 }
            let elapsed = milliseconds(timestamp - visibleRange.lowerBound)
            return GeometryScalar(min(span, max(0, elapsed)) * Int64(width) / span)
        }

        private func y(for level: DigitalLevel, height: GeometryScalar) -> GeometryScalar {
            switch level {
            case .high: max(1, height / 4)
            case .low: min(height - 1, max(2, height - height / 4))
            }
        }

        private func milliseconds(_ duration: Duration) -> Int64 {
            let parts = duration.components
            let seconds = parts.seconds.multipliedReportingOverflow(by: 1_000)
            guard !seconds.overflow else { return parts.seconds < 0 ? .min : .max }
            let fractional = parts.attoseconds / 1_000_000_000_000_000
            let result = seconds.partialValue.addingReportingOverflow(fractional)
            return result.overflow
                ? (seconds.partialValue < 0 ? .min : .max)
                : result.partialValue
        }

        private static func exactMilliseconds(_ duration: Duration) -> Int64? {
            let parts = duration.components
            let seconds = parts.seconds.multipliedReportingOverflow(by: 1_000)
            guard !seconds.overflow,
                parts.attoseconds.isMultiple(of: 1_000_000_000_000_000)
            else { return nil }
            let result = seconds.partialValue.addingReportingOverflow(
                parts.attoseconds / 1_000_000_000_000_000
            )
            return result.overflow ? nil : result.partialValue
        }
    }
#endif
