import GiftUI
import GiftUIRenderCore

package protocol DrawingPlanMutationStorage {
    var limits: DrawingLimits { get }
    var strokeCount: UInt16 { get }
    var pointCount: UInt16 { get }
    var subpathCount: UInt16 { get }
    var normalizedStrokeOperationCount: UInt16 { get }

    mutating func appendStroke<PathStorage>(
        header: StraightLineStrokeHeader,
        path: borrowing PathStorage
    ) -> Bool where PathStorage: LivePathStorage
}

package enum StrokeSnapshotProducer {
    package static func snapshot<PathStorage, PlanStorage>(
        path: borrowing PathStorage,
        shading: Shading,
        style: StrokeStyle,
        surfaceOrigin: Point,
        inheritedClip: Rect,
        plan: inout PlanStorage
    ) throws(DrawingError)
    where
        PathStorage: LivePathStorage,
        PlanStorage: DrawingPlanMutationStorage
    {
        guard style.lineWidth > 0 else { throw DrawingError.invalidValue }
        guard style.lineWidth <= plan.limits.maximumLineWidth else {
            throw DrawingError.capacityExhausted
        }
        try validate(path: path)
        guard plan.normalizedStrokeOperationCount == plan.strokeCount else {
            throw DrawingError.invariantViolation
        }

        let nextStrokes = try checkedIncrement(plan.strokeCount)
        let nextPoints = try checkedAdd(plan.pointCount, path.pointCount)
        let nextSubpaths = try checkedAdd(plan.subpathCount, path.subpathCount)
        let nextOperations = try checkedIncrement(plan.normalizedStrokeOperationCount)
        guard nextStrokes <= plan.limits.maximumPlanStrokes,
            nextPoints <= plan.limits.maximumPlanPoints,
            nextSubpaths <= plan.limits.maximumPlanSubpaths,
            nextOperations <= plan.limits.maximumNormalizedStrokeOperations
        else { throw DrawingError.capacityExhausted }

        let header = StraightLineStrokeHeader(
            color: shading.colorValue,
            lineWidth: style.lineWidth,
            lineCap: style.lineCap,
            lineJoin: style.lineJoin,
            surfaceOrigin: surfaceOrigin,
            inheritedClip: inheritedClip,
            pointCount: path.pointCount,
            subpathCount: path.subpathCount
        )
        guard plan.appendStroke(header: header, path: path) else {
            throw DrawingError.invariantViolation
        }
    }

    private static func validate<PathStorage>(
        path: borrowing PathStorage
    ) throws(DrawingError) where PathStorage: LivePathStorage {
        let pointCount = path.pointCount
        let subpathCount = path.subpathCount
        guard pointCount <= path.maximumPointCount,
            subpathCount <= path.maximumSubpathCount
        else { throw DrawingError.invariantViolation }
        if pointCount == 0 || subpathCount == 0 {
            guard pointCount == 0, subpathCount == 0 else {
                throw DrawingError.invariantViolation
            }
            return
        }

        var pointIndex: UInt16 = 0
        while pointIndex < pointCount {
            guard path.point(at: pointIndex) != nil else {
                throw DrawingError.invariantViolation
            }
            pointIndex += 1
        }

        var expectedFirstPoint: UInt16 = 0
        var subpathIndex: UInt16 = 0
        while subpathIndex < subpathCount {
            guard let subpath = path.subpath(at: subpathIndex),
                subpath.firstPoint == expectedFirstPoint
            else { throw DrawingError.invariantViolation }
            let end = subpath.firstPoint.addingReportingOverflow(subpath.pointCount)
            guard !end.overflow, end.partialValue <= pointCount else {
                throw DrawingError.invariantViolation
            }
            expectedFirstPoint = end.partialValue
            subpathIndex += 1
        }
        guard expectedFirstPoint == pointCount else {
            throw DrawingError.invariantViolation
        }
    }

    private static func checkedIncrement(_ value: UInt16) throws(DrawingError) -> UInt16 {
        try checkedAdd(value, 1)
    }

    private static func checkedAdd(
        _ lhs: UInt16,
        _ rhs: UInt16
    ) throws(DrawingError) -> UInt16 {
        let result = lhs.addingReportingOverflow(rhs)
        guard !result.overflow else { throw DrawingError.arithmeticOverflow }
        return result.partialValue
    }
}
