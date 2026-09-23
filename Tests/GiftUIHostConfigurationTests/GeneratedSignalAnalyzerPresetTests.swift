import Testing

@testable import GiftUIHostConfiguration

@Test func generatedPresetsCarryOneFreshCompleteWorkload() {
    let presets = [
        GeneratedSignalAnalyzerPresets.macOSDynamic(),
        GeneratedSignalAnalyzerPresets.macOSStatic(),
        GeneratedSignalAnalyzerPresets.raspberryPiDynamic(),
        GeneratedSignalAnalyzerPresets.nrf52840Static(),
    ]
    let first = presets[0]
    for preset in presets {
        #expect(preset.identity == GeneratedSignalAnalyzerPresets.sourceIdentity)
        #expect(preset.workload.schemaVersion == 3)
        #expect(preset.workload.semanticNodeOccurrences == 48)
        #expect(preset.workload.semanticStructuralOccurrences == 126)
        #expect(preset.runtimeLimits.semantic.maximumDepth == 34)
        #expect(preset.runtimeLimits.semantic.maximumBodyEvaluations == 14)
        #expect(preset.runtimeLimits.semantic.maximumModifierApplications == 50)
        #expect(preset.runtimeLimits.maximumSemanticStructuralOccurrences == 126)
        #expect(preset.workload.renderSemanticScopeOccurrences == 98)
        #expect(preset.workload.layoutScopeOccurrences == 98)
        #expect(preset.workload.maximumRenderTraversalDepth == 13)
        #expect(preset.workload.renderTextLineCount == 128)
        #expect(preset.workload.positionedGlyphCount == 224)
        #expect(preset.workload.ordinaryRenderOperations == 145)
        #expect(preset.workload.requiredRuntimeLimits == preset.runtimeLimits)
        #expect(preset.runtimeLimits.renderWorkspace.maximumSemanticScopes == 98)
        #expect(preset.runtimeLimits.renderWorkspace.maximumLayoutScopes == 98)
        #expect(preset.runtimeLimits.renderWorkspace.maximumTraversalDepth == 13)
        #expect(preset.runtimeLimits.layout.maximumTextLines == 128)
        #expect(preset.runtimeLimits.renderWorkspace.maximumTextLines == 128)
        #expect(preset.runtimeLimits.maximumOrdinaryRenderOperations == 145)
        #expect(preset.runtimeLimits.render.maximumOperations == 150)
        #expect(preset.runtimeLimits.renderSink.maximumOperations == 150)
        #expect(preset.capabilityRequirement.operations.rawValue == 0x1F)
        #expect(preset.capabilityRequirement.extent.width == preset.raster.logicalWidth)
        #expect(preset.capabilityRequirement.extent.height == preset.raster.logicalHeight)
        #expect(preset.capabilityRequirement.operationStream == .synchronousBorrowedOneShot)
        #expect(preset.capabilityRequirement.absence == .required)
        #expect(preset.cardinality.compactFactCapacity == 32)
        #expect(preset.pacing.maximumTransitionFactsPerServiceWindow == 20)
    }
    for preset in presets.dropFirst() {
        #expect(first.workload.semanticNodeOccurrences == preset.workload.semanticNodeOccurrences)
        #expect(
            first.workload.semanticStructuralOccurrences
                == preset.workload.semanticStructuralOccurrences)
        #expect(
            first.workload.renderSemanticScopeOccurrences
                == preset.workload.renderSemanticScopeOccurrences)
        #expect(first.workload.layoutScopeOccurrences == preset.workload.layoutScopeOccurrences)
        #expect(
            first.workload.maximumRenderTraversalDepth
                == preset.workload.maximumRenderTraversalDepth)
        #expect(first.workload.renderTextLineCount == preset.workload.renderTextLineCount)
        #expect(first.workload.positionedGlyphCount == preset.workload.positionedGlyphCount)
        #expect(first.workload.ordinaryRenderOperations == preset.workload.ordinaryRenderOperations)
        #expect(
            first.workload.inputEventsPerOpportunity == preset.workload.inputEventsPerOpportunity)
        #expect(
            first.workload.semanticActionsPerOpportunity
                == preset.workload.semanticActionsPerOpportunity)
        #expect(
            first.workload.completionFactsPerOpportunity
                == preset.workload.completionFactsPerOpportunity)
    }
}

@Test func generatedDrawingAndStaticProfileBoundsAreExact() {
    let dynamic = GeneratedSignalAnalyzerPresets.macOSDynamic()
    let `static` = GeneratedSignalAnalyzerPresets.macOSStatic()
    let drawing = dynamic.workload.drawing
    #expect(drawing.canvasOccurrences == 5)
    #expect(drawing.maximumLivePathPoints == 202)
    #expect(drawing.maximumLivePathSubpaths == 12)
    #expect(drawing.submittedStrokes == 5)
    #expect(drawing.snapshottedPoints == 832)
    #expect(drawing.snapshottedSubpaths == 16)
    #expect(drawing.normalizedStrokeOperations == 5)
    #expect(drawing.staticCallableCases == nil)
    #expect(drawing.maximumStaticCaptureBytes == nil)
    #expect(`static`.workload.drawing.staticCallableCases == 2)
    #expect(`static`.workload.drawing.maximumStaticCaptureBytes == 32)
    #expect(`static`.runtimeLimits.staticCanvas?.maximumStaticCallableCases == 2)
    #expect(`static`.runtimeLimits.staticCanvas?.maximumStaticCaptureBytes == 32)
}

@Test func generatedStaticRootDescriptorMatchesThePortableHierarchy() {
    let dynamic = GeneratedSignalAnalyzerPresets.macOSDynamic()
    let macOS = GeneratedSignalAnalyzerPresets.macOSStatic()
    let embedded = GeneratedSignalAnalyzerPresets.nrf52840Static()

    #expect(dynamic.staticRoot == nil)
    #expect(GeneratedSignalAnalyzerPresets.raspberryPiDynamic().staticRoot == nil)
    #expect(macOS.staticRoot == embedded.staticRoot)
    guard let root = macOS.staticRoot else {
        Issue.record("Static preset omitted its generated root descriptor")
        return
    }
    #expect(root.structuralIdentity != 0)
    #expect(root.declarationOrdinal == 0)
    #expect(root.modelStorageSlots == 2)
    #expect(root.locationCapacity == macOS.cardinality.rootModelLocationCount)
    #expect(
        root.registrationCapacity
            == macOS.cardinality.activeRegistrationCount
    )
    #expect(
        root.replacementCapacity
            == macOS.cardinality.stagedAssociationCount
    )
}

@Test func generatedStorageAuditsAreExactAndSuccessful() {
    for preset in [
        GeneratedSignalAnalyzerPresets.macOSDynamic(),
        GeneratedSignalAnalyzerPresets.macOSStatic(),
        GeneratedSignalAnalyzerPresets.raspberryPiDynamic(),
        GeneratedSignalAnalyzerPresets.nrf52840Static(),
    ] {
        guard case .valid(let audit) = preset.validatedStorageAudit() else {
            Issue.record("generated preset failed its exact SPEC-013 storage audit")
            continue
        }
        #expect(audit.profile == preset.profile)
        #expect(audit.limits == preset.runtimeLimits)
        #expect(audit.semanticCandidateBytes == preset.expectedStorageBytes.semanticCandidateBytes)
        #expect(audit.renderWorkspaceBytes == preset.expectedStorageBytes.renderWorkspaceBytes)
        #expect(audit.drawingPlanBytes == preset.expectedStorageBytes.drawingPlanBytes)
    }
}

@Test func generatedPhysicalPresetProjectionsMatchTheContract() {
    let macDynamic = GeneratedSignalAnalyzerPresets.macOSDynamic()
    let macStatic = GeneratedSignalAnalyzerPresets.macOSStatic()
    #expect(macDynamic.kind == .macOSDynamic)
    #expect(macDynamic.profile == .dynamic)
    #expect(macStatic.kind == .macOSStatic)
    #expect(macStatic.profile == .static)
    #expect(macDynamic.raster == macStatic.raster)
    #expect(macDynamic.raster.logicalWidth == 320)
    #expect(macDynamic.raster.logicalHeight == 240)

    let pi = GeneratedSignalAnalyzerPresets.raspberryPiDynamic()
    #expect(pi.kind == .raspberryPiDynamic)
    #expect(pi.profile == .dynamic)
    #expect(pi.raster.logicalWidth == 240)
    #expect(pi.raster.logicalHeight == 240)
    #expect(pi.raster.regionHeight == 16)
    #expect(pi.raster.maximumRasterBytes == 7_680)

    let nrf = GeneratedSignalAnalyzerPresets.nrf52840Static()
    #expect(nrf.kind == .nrf52840Static)
    #expect(nrf.profile == .static)
    #expect(nrf.raster.logicalWidth == 480)
    #expect(nrf.raster.logicalHeight == 320)
    #expect(nrf.raster.regionHeight == 4)
    #expect(nrf.raster.bytesPerRow == 960)
    #expect(nrf.raster.maximumRasterBytes == 3_840)
    #expect(nrf.raster.maximumPayloadBytes == 3_840)
    #expect(nrf.raster.maximumInFlightPayloads == 1)
}
