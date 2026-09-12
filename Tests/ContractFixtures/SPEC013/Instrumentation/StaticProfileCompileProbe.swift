import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIRuntimeCore
import GiftUISemanticCore

#if !GIFTUI_STATIC_PROFILE_IMPLEMENTATION
    import GiftUIRuntimeStatic
#endif

private enum CompileProbeIdentity: UInt8, Equatable, Sendable {
    case root = 1
}

private struct CompileProbeCapture: Sendable {
    let color: Color
    let scalar: GeometryScalar
}

private struct CompileProbeRegions: StaticProfileStorageRegions, ~Copyable {
    var byteCounts: RuntimeStorageByteCounts {
        RuntimeStorageByteCounts(
            semanticCandidateBytes: 1,
            semanticPublishedBytes: 1,
            layoutCandidateBytes: 1,
            renderWorkspaceBytes: 1,
            canvasCallableBytes: 1,
            pathWorkspaceBytes: 1,
            drawingPlanBytes: 1,
            observableLiveBytes: 1,
            observableCandidateBytes: 1,
            interactionCandidateBytes: 1,
            interactionCommittedBytes: 1,
            admissionQueueBytes: 1,
            sealedBatchBytes: 1,
            pointerStateBytes: 1,
            coordinatorStateBytes: 1,
            failureStateBytes: 1
        )
    }

    mutating func resetAttemptRegions() {}
    mutating func resetAllRegions() {}
}

private struct CompileProbeMetadata:
    RuntimeStaticCanvasAuditMetadata, StaticCanvasCallableTable
{
    let callableCaseCount: UInt16 = 1
    let declaredEntryCount: UInt16 = 1
    let maximumDeclaredID: UInt16 = 1

    func coverageMultiplicity(for id: UInt16) -> UInt8 {
        id == 1 ? 1 : 0
    }

    func captureByteCount(for id: UInt16) -> UInt16? {
        id == 1 ? UInt16(MemoryLayout<CompileProbeCapture>.size) : nil
    }

    mutating func invoke(
        id: UInt16,
        captures: borrowing CompileProbeCapture,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        guard id == 1 else { throw .invariantViolation }
        _ = captures.color
        _ = captures.scalar
        _ = size
    }
}

@_cdecl("giftui_spec013_layout_limits")
public func spec013LayoutLimits() -> UInt32 {
    UInt32(MemoryLayout<RuntimeProfileLimits>.size)
}

@_cdecl("giftui_spec013_layout_audit")
public func spec013LayoutAudit() -> UInt32 {
    UInt32(MemoryLayout<RuntimeStorageAudit>.size)
}

@_cdecl("giftui_spec013_layout_identity")
public func spec013LayoutIdentity() -> UInt32 {
    UInt32(MemoryLayout<StaticStructuralIdentity>.size)
}

@_cdecl("giftui_spec013_layout_occurrence")
public func spec013LayoutOccurrence() -> UInt32 {
    UInt32(
        MemoryLayout<
            StaticCanvasOccurrence<CompileProbeIdentity, CompileProbeCapture>
        >.size
    )
}

public func spec013StaticProfileLayoutChecksum() -> UInt32 {
    StaticStructuralIdentity(rawValue: 1)!.rawValue
        &+ spec013LayoutLimits()
        &+ spec013LayoutAudit()
        &+ spec013LayoutIdentity()
        &+ spec013LayoutOccurrence()
}

@_cdecl("giftui_spec013_static_binding_probe")
@inline(never)
public func spec013StaticBindingProbe() -> UInt32 {
    guard let limits = compileProbeLimits(),
        var binding = StaticRuntimeProfileBinding(
            structuralIdentity: StaticStructuralIdentity(rawValue: 1)!,
            limits: limits,
            regions: CompileProbeRegions(),
            metadata: CompileProbeMetadata()
        )
    else {
        return 0
    }
    let active = ExecutionContext(
        cycle: RunCycleID(rawValue: 1),
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .admitting
    )
    guard binding.beginOpportunity(context: active) == nil,
        binding.reserve(1, for: .drawingPlanStrokes) == .accepted,
        var occurrence = binding.stageCanvas(
            identity: CompileProbeIdentity.root,
            callableID: 1,
            declaredCaptureByteCount: UInt16(MemoryLayout<CompileProbeCapture>.size),
            capture: CompileProbeCapture(color: .white, scalar: 1)
        )
    else {
        return 0
    }
    occurrence.discard()
    let idle = ExecutionContext(
        cycle: nil,
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .idle
    )
    guard binding.finishOpportunity(context: idle) == nil else { return 0 }
    binding.quiesce()
    return binding.isQuiescent ? 1 : 0
}

private func compileProbeLimits() -> RuntimeProfileLimits? {
    RuntimeProfileLimits(
        semantic: SemanticExpansionLimits(
            maximumDepth: 1,
            maximumSemanticNodes: 1,
            maximumBodyEvaluations: 1,
            maximumModifierApplications: 1,
            maximumActionOccurrences: 1
        )!,
        layout: LayoutLimits(
            maximumScopes: 1,
            maximumDepth: 1,
            maximumTextScalars: 1,
            maximumTextLines: 1,
            maximumPositionedGlyphs: 1
        )!,
        render: RenderLimits(
            maximumOperations: 2,
            maximumPositionedGlyphs: 1,
            maximumClipDepth: 1
        )!,
        renderWorkspace: RenderWorkspaceCapacity(
            maximumSemanticScopes: 1,
            maximumLayoutScopes: 1,
            maximumTraversalDepth: 1,
            maximumTextLines: 1
        )!,
        renderSink: RenderSinkCapacity(
            maximumOperations: 2,
            maximumPositionedGlyphs: 1
        ),
        maximumOrdinaryRenderOperations: 1,
        execution: ExecutionLimits(
            maximumInputEvents: 1,
            maximumStateChangeFacts: 1,
            maximumCompletionFacts: 1,
            maximumSemanticActions: 1,
            maximumActiveInputSources: 1,
            maximumCommittedActions: 1
        )!,
        observableState: ObservableStateLimits(
            maximumLocations: 1,
            maximumRegistrations: 1,
            maximumStagedAssociations: 1
        )!,
        interaction: InteractionLimits(
            maximumActions: 1,
            maximumHitRegions: 1
        )!,
        drawing: DrawingLimits(
            maximumLineWidth: 1,
            maximumCanvasOccurrences: 1,
            maximumLivePathPoints: 1,
            maximumLivePathSubpaths: 1,
            maximumPlanStrokes: 1,
            maximumPlanPoints: 1,
            maximumPlanSubpaths: 1,
            maximumNormalizedStrokeOperations: 1
        )!,
        staticCanvas: StaticCanvasLimits(
            maximumStaticCallableCases: 1,
            maximumStaticCaptureBytes: UInt16(MemoryLayout<CompileProbeCapture>.size)
        )!,
        profile: .static
    )
}
