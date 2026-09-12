import GiftUI
import GiftUIRenderCore
import Testing

@testable import GiftUIDrawing

private func requiresCopyable<T: Copyable>(_: T.Type) {}
private func requiresSendable<T: Sendable>(_: T.Type) {}

@Test
func subpathRangeRequiresANonemptyRepresentableHalfOpenRange() {
    #expect(SubpathRange(firstPoint: 0, pointCount: 0) == nil)
    #expect(SubpathRange(firstPoint: .max, pointCount: 1) == nil)
    #expect(
        SubpathRange(firstPoint: .max - 1, pointCount: 1)
            == SubpathRange(firstPoint: .max - 1, pointCount: 1)
    )
}

@Test
func drawingValueFieldsCasesAndRawValuesAreExact() {
    let summary = DrawingPlanSummary(
        canvasOccurrenceCount: 1,
        strokeCount: 2,
        pointCount: 3,
        subpathCount: 4,
        normalizedStrokeOperationCount: 2
    )
    #expect(summary.canvasOccurrenceCount == 1)
    #expect(summary.strokeCount == 2)
    #expect(summary.pointCount == 3)
    #expect(summary.subpathCount == 4)
    #expect(summary.normalizedStrokeOperationCount == 2)
    #expect(DrawingPlanResult.success(summary) == .success(summary))

    let errors: [DrawingProductionError] = [
        .invalidValue,
        .invalidPathState,
        .arithmeticOverflow,
        .capacityExhausted,
        .invalidScope,
        .invalidPhase,
        .reentrancyViolation,
        .operationCapacityExhausted,
        .invariantViolation,
    ]
    #expect(errors.map(\.rawValue) == Array(0 ... 8))
    #expect(DrawingPlanResult.failure(.invalidScope) == .failure(.invalidScope))
}

@Test
func drawingValuesMeetCopySendAndHostLayoutContracts() {
    requiresCopyable(SubpathRange.self)
    requiresCopyable(DrawingPlanSummary.self)
    requiresCopyable(StraightLineStrokeHeader.self)
    requiresCopyable(DrawingProductionError.self)
    requiresCopyable(DrawingPlanResult.self)
    requiresSendable(SubpathRange.self)
    requiresSendable(DrawingPlanSummary.self)
    requiresSendable(StraightLineStrokeHeader.self)
    requiresSendable(DrawingProductionError.self)
    requiresSendable(DrawingPlanResult.self)

    #expect(MemoryLayout<SubpathRange>.size == 4)
    #expect(MemoryLayout<DrawingPlanSummary>.size == 10)
    #expect(MemoryLayout<StraightLineStrokeHeader>.size <= 40)
    #expect(MemoryLayout<DrawingProductionError>.size == 1)
    #expect(MemoryLayout<DrawingPlanResult>.size <= 12)
}
