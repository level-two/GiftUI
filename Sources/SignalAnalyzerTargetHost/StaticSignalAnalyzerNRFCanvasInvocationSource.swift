import GiftUI
import GiftUIDrawing

/// Synchronous bridge from the generated semantic table to the common Canvas
/// producer. The borrowed table and model handle must not escape the attempt.
package struct StaticSignalAnalyzerNRFCanvasInvocationSource: CanvasInvocationSource {
    package typealias Identity = UInt16

    private let semanticRegion: UnsafeMutableRawBufferPointer
    private let scopeCount: UInt16
    private let inputs: StaticSignalAnalyzerNRFGeneratedPresentationInputs
    private var callableTable = StaticSignalAnalyzerNRFCanvasCallableTable()
    private var released: UInt8 = 0

    package let canvasOccurrenceCount: UInt16 = 5

    package init?(
        semanticRegion: UnsafeMutableRawBufferPointer,
        inputs: StaticSignalAnalyzerNRFGeneratedPresentationInputs
    ) {
        guard
            let summary = StaticSignalAnalyzerNRFPackedSemanticRecords.utf8TableSummary(
                in: semanticRegion
            ),
            StaticSignalAnalyzerNRFPackedSemanticRecords.hasExactUTF8CanvasOccurrences(
                in: semanticRegion
            ),
            inputs.semantic.canvasOccurrenceCount == 5
        else { return nil }
        self.semanticRegion = semanticRegion
        scopeCount = summary.scopeCount
        self.inputs = inputs

        var index: UInt16 = 0
        while index < canvasOccurrenceCount {
            guard let input = inputs.canvasInput(at: index),
                input.occurrenceIdentity == index + 1,
                callableTable.captureByteCount(for: input.callableID)
                    == input.declaredCaptureByteCount,
                canvasIdentity(at: index) != nil
            else { return nil }
            index += 1
        }
    }

    package func canvasIdentity(at index: UInt16) -> UInt16? {
        guard index < canvasOccurrenceCount else { return nil }
        var ordinal: UInt16 = 0
        while ordinal < scopeCount {
            guard
                let record = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                    at: ordinal, in: semanticRegion
                )
            else { return nil }
            if record.kind == .canvas, record.payload0 == UInt32(index + 1) {
                return record.identity
            }
            ordinal += 1
        }
        return nil
    }

    package mutating func invokeCanvas(
        at identity: UInt16,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        var index: UInt16 = 0
        while index < canvasOccurrenceCount {
            if canvasIdentity(at: index) == identity {
                let bit = UInt8(1) << UInt8(index)
                guard released & bit == 0,
                    let input = inputs.canvasInput(at: index)
                else { throw .invariantViolation }
                try callableTable.invoke(
                    id: input.callableID,
                    captures: input.capture,
                    context: &context,
                    size: size
                )
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
                released |= UInt8(1) << UInt8(index)
                return
            }
            index += 1
        }
    }

    package var allReleased: Bool { released == 0b1_1111 }
}
