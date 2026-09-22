import GiftUI
import GiftUIDrawing
import GiftUIRenderCore

/// One attempt-local Drawing plan over the generated 13,536-byte region.
/// The caller must keep the region alive through render preflight and streaming.
package struct StaticSignalAnalyzerNRFDrawingPlanStorage:
    DrawingPlanWorkspace, DrawingPlanMutationStorage
{
    package typealias Identity = UInt16

    package let capacity: DrawingLimits
    package private(set) var isActive = false
    package private(set) var strokeCount: UInt16 = 0
    package private(set) var pointCount: UInt16 = 0
    package private(set) var subpathCount: UInt16 = 0
    package var normalizedStrokeOperationCount: UInt16 { strokeCount }
    package var limits: DrawingLimits { capacity }

    private let region: UnsafeMutableRawBufferPointer
    private var canvasCount: UInt16 = 0
    private var currentCanvas: UInt16?
    private var currentFirstStroke: UInt16 = 0
    private var currentOrigin = Point(x: 0, y: 0)
    private var publishedSummary: DrawingPlanSummary?

    package init?(region: UnsafeMutableRawBufferPointer, capacity: DrawingLimits) {
        guard region.count == StaticSignalAnalyzerNRFDrawingPlanRecords.regionByteCount,
            capacity.maximumCanvasOccurrences == 5,
            capacity.maximumPlanStrokes == 5,
            capacity.maximumPlanPoints == 832,
            capacity.maximumPlanSubpaths == 16,
            capacity.maximumNormalizedStrokeOperations == 5
        else { return nil }
        self.region = region
        self.capacity = capacity
    }

    package var summary: DrawingPlanSummary {
        precondition(publishedSummary != nil)
        return publishedSummary!
    }

    package mutating func acquire() -> Bool {
        guard !isActive, publishedSummary == nil else { return false }
        region.initializeMemory(as: UInt8.self, repeating: 0)
        isActive = true
        return true
    }

    package mutating func beginCanvas(identity: UInt16, origin: Point) -> Bool {
        guard isActive, currentCanvas == nil, identity != 0,
            canvasCount < capacity.maximumCanvasOccurrences,
            canvasRecord(for: identity) == nil
        else { return false }
        currentCanvas = identity
        currentFirstStroke = strokeCount
        currentOrigin = origin
        return true
    }

    package mutating func endCanvas() -> Bool {
        guard isActive, let identity = currentCanvas,
            StaticSignalAnalyzerNRFDrawingPlanRecords.stageCanvas(
                StaticSignalAnalyzerNRFPlanCanvasRecord(
                    identity: identity, firstStroke: currentFirstStroke,
                    strokeCount: strokeCount - currentFirstStroke
                ), at: canvasCount, in: region
            )
        else { return false }
        canvasCount += 1
        currentCanvas = nil
        return true
    }

    package mutating func appendStroke<PathStorage>(
        header: StraightLineStrokeHeader,
        path: borrowing PathStorage
    ) -> Bool where PathStorage: LivePathStorage {
        guard isActive, let canvas = currentCanvas,
            header.surfaceOrigin == currentOrigin,
            strokeCount < capacity.maximumPlanStrokes,
            header.pointCount == path.pointCount,
            header.subpathCount == path.subpathCount,
            let nextPoints = checkedSum(pointCount, path.pointCount),
            nextPoints <= capacity.maximumPlanPoints,
            let nextSubpaths = checkedSum(subpathCount, path.subpathCount),
            nextSubpaths <= capacity.maximumPlanSubpaths
        else { return false }

        // Check all translations before writing any plan record.
        var pointIndex: UInt16 = 0
        while pointIndex < path.pointCount {
            guard let point = path.point(at: pointIndex),
                !point.x.addingReportingOverflow(currentOrigin.x).overflow,
                !point.y.addingReportingOverflow(currentOrigin.y).overflow
            else { return false }
            pointIndex += 1
        }
        var subpathIndex: UInt16 = 0
        while subpathIndex < path.subpathCount {
            guard path.subpath(at: subpathIndex) != nil else { return false }
            subpathIndex += 1
        }

        let record = StaticSignalAnalyzerNRFPlanStrokeRecord(
            canvas: canvas, firstPoint: pointCount,
            firstSubpath: subpathCount, header: header
        )
        guard
            StaticSignalAnalyzerNRFDrawingPlanRecords.stageStroke(
                record, at: strokeCount, in: region
            )
        else { return false }
        pointIndex = 0
        while pointIndex < path.pointCount {
            let point = path.point(at: pointIndex)!
            let translated = Point(
                x: point.x + currentOrigin.x,
                y: point.y + currentOrigin.y
            )
            guard
                StaticSignalAnalyzerNRFDrawingPlanRecords.stagePoint(
                    translated, at: pointCount + pointIndex, in: region
                )
            else { return false }
            pointIndex += 1
        }
        subpathIndex = 0
        while subpathIndex < path.subpathCount {
            guard
                StaticSignalAnalyzerNRFDrawingPlanRecords.stageSubpath(
                    path.subpath(at: subpathIndex)!,
                    at: subpathCount + subpathIndex, in: region
                )
            else { return false }
            subpathIndex += 1
        }
        strokeCount += 1
        pointCount = nextPoints
        subpathCount = nextSubpaths
        return true
    }

    package mutating func seal(canvasOccurrenceCount: UInt16) -> DrawingPlanResult {
        guard isActive, currentCanvas == nil,
            canvasOccurrenceCount == canvasCount,
            canvasCount == capacity.maximumCanvasOccurrences,
            strokeCount == capacity.maximumPlanStrokes,
            normalizedStrokeOperationCount == strokeCount,
            validateRecords()
        else { return .failure(.invariantViolation) }
        let summary = DrawingPlanSummary(
            canvasOccurrenceCount: canvasCount,
            strokeCount: strokeCount,
            pointCount: pointCount,
            subpathCount: subpathCount,
            normalizedStrokeOperationCount: strokeCount
        )
        publishedSummary = summary
        isActive = false
        return .success(summary)
    }

    package mutating func discard() {
        reset()
    }

    package mutating func reset() {
        region.initializeMemory(as: UInt8.self, repeating: 0)
        isActive = false
        canvasCount = 0
        currentCanvas = nil
        currentFirstStroke = 0
        currentOrigin = Point(x: 0, y: 0)
        strokeCount = 0
        pointCount = 0
        subpathCount = 0
        publishedSummary = nil
    }

    package func strokeCount(of canvas: UInt16) -> UInt16? {
        guard publishedSummary != nil else { return nil }
        return canvasRecord(for: canvas)?.strokeCount
    }

    package func strokeHeader(
        of canvas: UInt16, at index: UInt16
    ) -> StraightLineStrokeHeader? {
        strokeRecord(of: canvas, at: index)?.header
    }

    package func point(
        of canvas: UInt16, stroke index: UInt16, at pointIndex: UInt16
    ) -> Point? {
        guard let stroke = strokeRecord(of: canvas, at: index),
            pointIndex < stroke.header.pointCount,
            let ordinal = checkedSum(stroke.firstPoint, pointIndex)
        else { return nil }
        return StaticSignalAnalyzerNRFDrawingPlanRecords.point(at: ordinal, in: region)
    }

    package func subpath(
        of canvas: UInt16, stroke index: UInt16, at subpathIndex: UInt16
    ) -> SubpathRange? {
        guard let stroke = strokeRecord(of: canvas, at: index),
            subpathIndex < stroke.header.subpathCount,
            let ordinal = checkedSum(stroke.firstSubpath, subpathIndex)
        else { return nil }
        return StaticSignalAnalyzerNRFDrawingPlanRecords.subpath(at: ordinal, in: region)
    }

    private func canvasRecord(for identity: UInt16) -> StaticSignalAnalyzerNRFPlanCanvasRecord? {
        var ordinal: UInt16 = 0
        while ordinal < canvasCount {
            if let record = StaticSignalAnalyzerNRFDrawingPlanRecords.canvas(
                at: ordinal, in: region
            ), record.identity == identity {
                return record
            }
            ordinal += 1
        }
        return nil
    }

    private func strokeRecord(
        of canvas: UInt16, at index: UInt16
    ) -> StaticSignalAnalyzerNRFPlanStrokeRecord? {
        guard publishedSummary != nil,
            let record = canvasRecord(for: canvas), index < record.strokeCount,
            let ordinal = checkedSum(record.firstStroke, index)
        else { return nil }
        return StaticSignalAnalyzerNRFDrawingPlanRecords.stroke(at: ordinal, in: region)
    }

    private func validateRecords() -> Bool {
        var canvasOrdinal: UInt16 = 0
        var expectedStroke: UInt16 = 0
        var expectedPoint: UInt16 = 0
        var expectedSubpath: UInt16 = 0
        while canvasOrdinal < canvasCount {
            guard
                let canvas = StaticSignalAnalyzerNRFDrawingPlanRecords.canvas(
                    at: canvasOrdinal, in: region
                ), canvas.firstStroke == expectedStroke
            else { return false }
            var localStroke: UInt16 = 0
            while localStroke < canvas.strokeCount {
                guard
                    let record = StaticSignalAnalyzerNRFDrawingPlanRecords.stroke(
                        at: expectedStroke, in: region
                    ), record.canvas == canvas.identity,
                    record.firstPoint == expectedPoint,
                    record.firstSubpath == expectedSubpath,
                    let nextPoint = checkedSum(expectedPoint, record.header.pointCount),
                    let nextSubpath = checkedSum(
                        expectedSubpath, record.header.subpathCount
                    ), nextPoint <= pointCount, nextSubpath <= subpathCount
                else { return false }
                var pointOrdinal = expectedPoint
                while pointOrdinal < nextPoint {
                    guard
                        StaticSignalAnalyzerNRFDrawingPlanRecords.point(
                            at: pointOrdinal, in: region
                        ) != nil
                    else { return false }
                    pointOrdinal += 1
                }
                var subpathOrdinal = expectedSubpath
                var expectedLocalFirstPoint: UInt16 = 0
                while subpathOrdinal < nextSubpath {
                    guard
                        let subpath = StaticSignalAnalyzerNRFDrawingPlanRecords.subpath(
                            at: subpathOrdinal, in: region
                        ), subpath.firstPoint == expectedLocalFirstPoint,
                        let nextLocalPoint = checkedSum(
                            expectedLocalFirstPoint, subpath.pointCount
                        ), nextLocalPoint <= record.header.pointCount
                    else { return false }
                    expectedLocalFirstPoint = nextLocalPoint
                    subpathOrdinal += 1
                }
                guard expectedLocalFirstPoint == record.header.pointCount else {
                    return false
                }
                expectedPoint = nextPoint
                expectedSubpath = nextSubpath
                expectedStroke += 1
                localStroke += 1
            }
            canvasOrdinal += 1
        }
        return expectedStroke == strokeCount && expectedPoint == pointCount
            && expectedSubpath == subpathCount
    }

    private func checkedSum(_ lhs: UInt16, _ rhs: UInt16) -> UInt16? {
        let sum = lhs.addingReportingOverflow(rhs)
        return sum.overflow ? nil : sum.partialValue
    }
}
