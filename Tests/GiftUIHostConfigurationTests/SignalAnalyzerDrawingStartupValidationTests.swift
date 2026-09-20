import Testing

@testable import GiftUIHostConfiguration

@Test func generatedDrawingWorkloadsPassTheIndependentStructuralGate() {
    for preset in [
        GeneratedSignalAnalyzerPresets.macOSDynamic(),
        GeneratedSignalAnalyzerPresets.macOSStatic(),
        GeneratedSignalAnalyzerPresets.raspberryPiDynamic(),
        GeneratedSignalAnalyzerPresets.nrf52840Static(),
    ] {
        #expect(
            SignalAnalyzerDrawingStartupValidation.validate(
                workload: preset.workload,
                limits: preset.runtimeLimits,
                profile: preset.profile
            ) == nil
        )
    }
}

@Test func structuralGateRejectsEveryDrawingMinimumIndependently() {
    let preset = GeneratedSignalAnalyzerPresets.macOSDynamic()
    let variants = [
        drawingWorkload(preset.workload, canvasOccurrences: 0),
        drawingWorkload(preset.workload, maximumLivePathPoints: 0),
        drawingWorkload(preset.workload, maximumLivePathSubpaths: 0),
        drawingWorkload(preset.workload, submittedStrokes: 0),
        drawingWorkload(preset.workload, snapshottedPoints: 0),
        drawingWorkload(preset.workload, snapshottedSubpaths: 0),
        drawingWorkload(preset.workload, normalizedStrokeOperations: 0),
        drawingWorkload(preset.workload, greatestLineWidth: 0),
    ]
    for workload in variants {
        #expect(
            SignalAnalyzerDrawingStartupValidation.validate(
                workload: workload,
                limits: preset.runtimeLimits,
                profile: preset.profile
            ) == .invalidWorkload
        )
    }
}

@Test func structuralGateRejectsFirstExcessAndStaticMismatch() {
    let dynamic = GeneratedSignalAnalyzerPresets.macOSDynamic()
    let excess = drawingWorkload(dynamic.workload, canvasOccurrences: 6)
    #expect(
        SignalAnalyzerDrawingStartupValidation.validate(
            workload: excess,
            limits: dynamic.runtimeLimits,
            profile: dynamic.profile
        ) == .invalidWorkload
    )

    let `static` = GeneratedSignalAnalyzerPresets.macOSStatic()
    let mismatched = drawingWorkload(
        `static`.workload,
        maximumStaticCaptureBytes: 31
    )
    #expect(
        SignalAnalyzerDrawingStartupValidation.validate(
            workload: mismatched,
            limits: `static`.runtimeLimits,
            profile: .static
        ) == .insufficientWorkloadCapacity
    )
    #expect(
        SignalAnalyzerDrawingStartupValidation.validate(
            workload: `static`.workload,
            limits: `static`.runtimeLimits,
            profile: .dynamic
        ) == .invalidWorkload
    )
}

private func drawingWorkload(
    _ source: SignalAnalyzerHostWorkload,
    canvasOccurrences: UInt16? = nil,
    maximumLivePathPoints: UInt16? = nil,
    maximumLivePathSubpaths: UInt16? = nil,
    submittedStrokes: UInt16? = nil,
    snapshottedPoints: UInt16? = nil,
    snapshottedSubpaths: UInt16? = nil,
    normalizedStrokeOperations: UInt16? = nil,
    greatestLineWidth: Int32? = nil,
    maximumStaticCaptureBytes: UInt16? = nil
) -> SignalAnalyzerHostWorkload {
    let drawing = source.drawing
    return SignalAnalyzerHostWorkload(
        schemaVersion: source.schemaVersion,
        requiredRuntimeLimits: source.requiredRuntimeLimits,
        semanticNodeOccurrences: source.semanticNodeOccurrences,
        semanticStructuralOccurrences: source.semanticStructuralOccurrences,
        renderSemanticScopeOccurrences: source.renderSemanticScopeOccurrences,
        layoutScopeOccurrences: source.layoutScopeOccurrences,
        maximumRenderTraversalDepth: source.maximumRenderTraversalDepth,
        renderTextLineCount: source.renderTextLineCount,
        positionedGlyphCount: source.positionedGlyphCount,
        ordinaryRenderOperations: source.ordinaryRenderOperations,
        inputEventsPerOpportunity: source.inputEventsPerOpportunity,
        semanticActionsPerOpportunity: source.semanticActionsPerOpportunity,
        completionFactsPerOpportunity: source.completionFactsPerOpportunity,
        drawing: SignalAnalyzerDrawingWorkload(
            canvasOccurrences: canvasOccurrences ?? drawing.canvasOccurrences,
            maximumLivePathPoints: maximumLivePathPoints ?? drawing.maximumLivePathPoints,
            maximumLivePathSubpaths: maximumLivePathSubpaths ?? drawing.maximumLivePathSubpaths,
            submittedStrokes: submittedStrokes ?? drawing.submittedStrokes,
            snapshottedPoints: snapshottedPoints ?? drawing.snapshottedPoints,
            snapshottedSubpaths: snapshottedSubpaths ?? drawing.snapshottedSubpaths,
            normalizedStrokeOperations:
                normalizedStrokeOperations ?? drawing.normalizedStrokeOperations,
            greatestLineWidth: greatestLineWidth ?? drawing.greatestLineWidth,
            staticCallableCases: drawing.staticCallableCases,
            maximumStaticCaptureBytes:
                maximumStaticCaptureBytes ?? drawing.maximumStaticCaptureBytes
        )
    )
}
