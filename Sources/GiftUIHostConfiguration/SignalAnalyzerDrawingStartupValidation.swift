import GiftUIRuntimeCore

package enum SignalAnalyzerDrawingStartupValidation {
    package static func validate(
        workload: SignalAnalyzerHostWorkload,
        limits: RuntimeProfileLimits,
        profile: RuntimeProfileKind
    ) -> HostConfigurationError? {
        let drawing = workload.drawing
        guard workload.schemaVersion == 2,
            drawing.canvasOccurrences > 0,
            drawing.maximumLivePathPoints > 0,
            drawing.maximumLivePathSubpaths > 0,
            drawing.submittedStrokes > 0,
            drawing.snapshottedPoints > 0,
            drawing.snapshottedSubpaths > 0,
            drawing.normalizedStrokeOperations > 0,
            drawing.greatestLineWidth > 0,
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

        guard drawing.canvasOccurrences <= limits.drawing.maximumCanvasOccurrences,
            drawing.maximumLivePathPoints <= limits.drawing.maximumLivePathPoints,
            drawing.maximumLivePathSubpaths <= limits.drawing.maximumLivePathSubpaths,
            drawing.submittedStrokes <= limits.drawing.maximumPlanStrokes,
            drawing.snapshottedPoints <= limits.drawing.maximumPlanPoints,
            drawing.snapshottedSubpaths <= limits.drawing.maximumPlanSubpaths,
            drawing.normalizedStrokeOperations
                <= limits.drawing.maximumNormalizedStrokeOperations,
            drawing.greatestLineWidth <= limits.drawing.maximumLineWidth,
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
