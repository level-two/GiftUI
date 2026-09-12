import GiftUI

package struct DrawingLimits: Equatable, Sendable {
    package let maximumLineWidth: GeometryScalar
    package let maximumCanvasOccurrences: UInt16
    package let maximumLivePathPoints: UInt16
    package let maximumLivePathSubpaths: UInt16
    package let maximumPlanStrokes: UInt16
    package let maximumPlanPoints: UInt16
    package let maximumPlanSubpaths: UInt16
    package let maximumNormalizedStrokeOperations: UInt16

    package init?(
        maximumLineWidth: GeometryScalar,
        maximumCanvasOccurrences: UInt16,
        maximumLivePathPoints: UInt16,
        maximumLivePathSubpaths: UInt16,
        maximumPlanStrokes: UInt16,
        maximumPlanPoints: UInt16,
        maximumPlanSubpaths: UInt16,
        maximumNormalizedStrokeOperations: UInt16
    ) {
        guard maximumLineWidth > 0,
            maximumCanvasOccurrences > 0,
            maximumLivePathPoints > 0,
            maximumLivePathSubpaths > 0,
            maximumPlanStrokes > 0,
            maximumPlanPoints > 0,
            maximumPlanSubpaths > 0,
            maximumNormalizedStrokeOperations > 0,
            maximumNormalizedStrokeOperations >= maximumPlanStrokes
        else { return nil }

        self.maximumLineWidth = maximumLineWidth
        self.maximumCanvasOccurrences = maximumCanvasOccurrences
        self.maximumLivePathPoints = maximumLivePathPoints
        self.maximumLivePathSubpaths = maximumLivePathSubpaths
        self.maximumPlanStrokes = maximumPlanStrokes
        self.maximumPlanPoints = maximumPlanPoints
        self.maximumPlanSubpaths = maximumPlanSubpaths
        self.maximumNormalizedStrokeOperations = maximumNormalizedStrokeOperations
    }
}

package struct StaticCanvasLimits: Equatable, Sendable {
    package let maximumStaticCallableCases: UInt16
    package let maximumStaticCaptureBytes: UInt16

    package init?(
        maximumStaticCallableCases: UInt16,
        maximumStaticCaptureBytes: UInt16
    ) {
        guard maximumStaticCallableCases > 0, maximumStaticCaptureBytes > 0 else {
            return nil
        }
        self.maximumStaticCallableCases = maximumStaticCallableCases
        self.maximumStaticCaptureBytes = maximumStaticCaptureBytes
    }
}
