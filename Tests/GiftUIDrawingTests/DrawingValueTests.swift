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

@Test
func drawingLimitsRejectEveryZeroFieldAndInvalidOperationRelation() {
    let valid = makeDrawingLimits()
    #expect(valid != nil)
    #expect(valid?.maximumLineWidth == 1)
    #expect(valid?.maximumCanvasOccurrences == 2)
    #expect(valid?.maximumLivePathPoints == 3)
    #expect(valid?.maximumLivePathSubpaths == 4)
    #expect(valid?.maximumPlanStrokes == 5)
    #expect(valid?.maximumPlanPoints == 6)
    #expect(valid?.maximumPlanSubpaths == 7)
    #expect(valid?.maximumNormalizedStrokeOperations == 5)

    for zeroField in 0 ..< 8 {
        #expect(makeDrawingLimits(zeroField: zeroField) == nil)
    }
    #expect(makeDrawingLimits(normalizedOperations: 4) == nil)
    #expect(makeDrawingLimits(normalizedOperations: 5) != nil)
    #expect(StaticCanvasLimits(maximumStaticCallableCases: 0, maximumStaticCaptureBytes: 1) == nil)
    #expect(StaticCanvasLimits(maximumStaticCallableCases: 1, maximumStaticCaptureBytes: 0) == nil)
    #expect(StaticCanvasLimits(maximumStaticCallableCases: 1, maximumStaticCaptureBytes: 1) != nil)
}

@Test
func dynamicAndStaticFixtureIdentityStorageAdmitEqualityAndRejectFirstExcess() {
    var dynamic = DynamicCanvasIdentityFixtureStorage(capacity: 2)
    var fixed = StaticCanvasIdentityFixtureStorage(capacity: 2)!
    for identity: UInt16 in [11, 29] {
        let dynamicAccepted = dynamic.append(identity)
        let fixedAccepted = fixed.append(identity)
        #expect(dynamicAccepted)
        #expect(fixedAccepted)
    }
    let dynamicExcess = dynamic.append(47)
    let fixedExcess = fixed.append(47)
    #expect(!dynamicExcess)
    #expect(!fixedExcess)
    #expect(dynamic.count == 2)
    #expect(fixed.count == 2)
    #expect(dynamic.identity(at: 0) == 11)
    #expect(fixed.identity(at: 1) == 29)
    #expect(dynamic.identity(at: 2) == nil)
    #expect(fixed.identity(at: 2) == nil)
    #expect(StaticCanvasIdentityFixtureStorage(capacity: 0)?.capacity == nil)
    #expect(StaticCanvasIdentityFixtureStorage(capacity: 5)?.capacity == nil)
}

private func makeDrawingLimits(
    zeroField: Int? = nil,
    normalizedOperations: UInt16 = 5
) -> DrawingLimits? {
    var values: [UInt16] = [2, 3, 4, 5, 6, 7, normalizedOperations]
    if let zeroField, zeroField > 0 {
        values[zeroField - 1] = 0
    }
    return DrawingLimits(
        maximumLineWidth: zeroField == 0 ? 0 : 1,
        maximumCanvasOccurrences: values[0],
        maximumLivePathPoints: values[1],
        maximumLivePathSubpaths: values[2],
        maximumPlanStrokes: values[3],
        maximumPlanPoints: values[4],
        maximumPlanSubpaths: values[5],
        maximumNormalizedStrokeOperations: values[6]
    )
}
