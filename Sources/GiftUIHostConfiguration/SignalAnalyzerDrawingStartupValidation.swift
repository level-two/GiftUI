import GiftUIDrawing
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIRuntimeCore

package enum SignalAnalyzerDrawingStartupValidation {
    package static func validate(
        workload: SignalAnalyzerHostWorkload,
        limits: RuntimeProfileLimits,
        profile: RuntimeProfileKind
    ) -> HostConfigurationError? {
        let drawing = workload.drawing
        let isCounter =
            workload.semanticActionsPerOpportunity == 2
            && limits.models.maximumModelCaptureBanks == 0
        // CounterCanvas emits no stroke at zero and one two-point stroke otherwise.
        // Analyzer's five-Canvas capacity proof remains unchanged.
        guard workload.schemaVersion == 4,
            drawing.canvasOccurrences == (isCounter ? 1 : 5),
            drawing.maximumLivePathPoints == (isCounter ? 2 : 202),
            drawing.maximumLivePathSubpaths == (isCounter ? 1 : 12),
            drawing.submittedStrokes == (isCounter ? 1 : 5),
            drawing.snapshottedPoints == (isCounter ? 2 : 832),
            drawing.snapshottedSubpaths == (isCounter ? 1 : 16),
            drawing.normalizedStrokeOperations == (isCounter ? 1 : 5),
            drawing.greatestLineWidth == 1,
            workload.ordinaryRenderOperations > 0
        else { return .invalidWorkload }

        let combined = workload.ordinaryRenderOperations.addingReportingOverflow(
            drawing.normalizedStrokeOperations
        )
        guard !combined.overflow else { return .arithmeticOverflow }

        guard
            workload.renderSemanticScopeOccurrences
                == limits.renderWorkspace.maximumSemanticScopes,
            workload.layoutScopeOccurrences == limits.renderWorkspace.maximumLayoutScopes,
            workload.maximumRenderTraversalDepth
                == limits.renderWorkspace.maximumTraversalDepth,
            workload.renderTextLineCount == limits.renderWorkspace.maximumTextLines,
            workload.ordinaryRenderOperations == limits.maximumOrdinaryRenderOperations
        else { return .insufficientWorkloadCapacity }

        guard drawing.canvasOccurrences == limits.drawing.maximumCanvasOccurrences,
            drawing.maximumLivePathPoints == limits.drawing.maximumLivePathPoints,
            drawing.maximumLivePathSubpaths == limits.drawing.maximumLivePathSubpaths,
            drawing.submittedStrokes == limits.drawing.maximumPlanStrokes,
            drawing.snapshottedPoints == limits.drawing.maximumPlanPoints,
            drawing.snapshottedSubpaths == limits.drawing.maximumPlanSubpaths,
            drawing.normalizedStrokeOperations
                == limits.drawing.maximumNormalizedStrokeOperations,
            drawing.greatestLineWidth == limits.drawing.maximumLineWidth,
            combined.partialValue <= limits.render.maximumOperations,
            combined.partialValue <= limits.renderSink.maximumOperations
        else { return .insufficientWorkloadCapacity }

        switch profile {
        case .dynamic:
            guard drawing.staticCallableCases == nil,
                drawing.maximumStaticCaptureBytes == nil,
                limits.staticCanvas == nil
            else { return .invalidWorkload }
        case .static:
            guard let callableCases = drawing.staticCallableCases,
                let captureBytes = drawing.maximumStaticCaptureBytes,
                callableCases > 0,
                captureBytes > 0,
                let staticLimits = limits.staticCanvas
            else { return .invalidWorkload }
            guard callableCases == staticLimits.maximumStaticCallableCases,
                captureBytes == staticLimits.maximumStaticCaptureBytes
            else { return .insufficientWorkloadCapacity }
        }
        return nil
    }
}
