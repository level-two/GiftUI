package struct DrawingPlanSummary: Equatable, Sendable {
    package let canvasOccurrenceCount: UInt16
    package let strokeCount: UInt16
    package let pointCount: UInt16
    package let subpathCount: UInt16
    package let normalizedStrokeOperationCount: UInt16

    package init(
        canvasOccurrenceCount: UInt16,
        strokeCount: UInt16,
        pointCount: UInt16,
        subpathCount: UInt16,
        normalizedStrokeOperationCount: UInt16
    ) {
        self.canvasOccurrenceCount = canvasOccurrenceCount
        self.strokeCount = strokeCount
        self.pointCount = pointCount
        self.subpathCount = subpathCount
        self.normalizedStrokeOperationCount = normalizedStrokeOperationCount
    }
}

package enum DrawingProductionError: UInt8, Equatable, Sendable {
    case invalidValue = 0
    case invalidPathState = 1
    case arithmeticOverflow = 2
    case capacityExhausted = 3
    case invalidScope = 4
    case invalidPhase = 5
    case reentrancyViolation = 6
    case operationCapacityExhausted = 7
    case invariantViolation = 8
}

package enum DrawingPlanResult: Equatable, Sendable {
    case success(DrawingPlanSummary)
    case failure(DrawingProductionError)
}
