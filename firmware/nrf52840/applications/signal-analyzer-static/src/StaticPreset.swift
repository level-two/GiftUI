private enum StaticSignalAnalyzerNRFEmbeddedCapabilitySelection {
    // Selected once for the immutable host lifetime, never reconstructed by an endpoint.
    static let effective: EffectiveRasterPresentation? = resolve()

    private static func resolve() -> EffectiveRasterPresentation? {
        let bytes = CapabilityByteCount(rawValue: 2_560)
        guard
            let requirement = RasterPresentationRequirement(
                operations: [
                    .opaqueRectangles, .positionedText, .straightLineStrokes, .clipping, .damage,
                ],
                extent: CapabilityExtent(width: 320, height: 240)!,
                operationStream: .synchronousBorrowedOneShot,
                acceptedEncodings: .rgb565BigEndian,
                acceptedSubmissionLifetimes: .synchronousBorrow,
                maximumRasterBytes: bytes, maximumPayloadBytes: bytes,
                maximumInFlightBytes: bytes, absence: .required
            )
        else { return nil }
        guard
            let realization = RasterRealizationContribution(
                kind: .tiled,
                operations: requirement.operations,
                operationStream: .synchronousBorrowedOneShot,
                encodings: .rgb565BigEndian,
                producedSubmissionLifetimes: .synchronousBorrow,
                maximumExtent: requirement.extent,
                maximumRegionWidth: 320,
                maximumRegionHeight: 4,
                rowByteAlignment: 2,
                maximumRasterBytes: bytes,
                maximumPayloadBytes: bytes
            ),
            let render = RenderProducerContribution(
                operations: requirement.operations,
                operationStream: .synchronousBorrowedOneShot
            ),
            let backend = RasterBackendContribution(primary: realization, alternate: nil),
            let display = SurfaceDisplayContribution(
                extent: requirement.extent,
                encodings: .rgb565BigEndian,
                acceptedSubmissionLifetimes: .synchronousBorrow,
                handoffs: .synchronous,
                maximumRegionWidth: 320,
                maximumRegionHeight: 4,
                rowByteAlignment: 2,
                maximumInFlightCount: 1,
                maximumInFlightBytes: bytes
            ),
            let policy = RasterPresentationPolicy(
                maximumRasterBytes: bytes,
                maximumPayloadBytes: bytes,
                maximumInFlightBytes: bytes,
                allowedRealizations: .tiled,
                allowedEncodings: .rgb565BigEndian,
                preferredRealization: .tiled,
                preferredEncoding: .rgb565BigEndian
            )
        else { return nil }

        var contributions = RasterPresentationContributions()
        _ = contributions.insert(.renderProducer(render))
        _ = contributions.insert(.rasterBackend(backend))
        _ = contributions.insert(.surfaceDisplay(display))
        _ = contributions.insert(.hostResourcePolicy(policy))
        var workspace = RasterPresentationResolverWorkspace()!
        guard
            case .available(let effective) = RasterPresentationResolver.resolve(
                requirement: requirement,
                contributions: contributions,
                workspace: &workspace
            )
        else { return nil }
        return effective
    }
}

private struct StaticSignalAnalyzerPreset {
    let logicalWidth: UInt16 = 320
    let logicalHeight: UInt16 = 240
    let regionHeight: UInt16 = 4
    let bytesPerRow: UInt32 = 640
    let rasterBytes: UInt32 = 2_560
    let profileStorageBytes: UInt32 = 39_696
    let captureEntries: UInt16 = 2_404
    let canvasCount: UInt16 = 5
    let livePointCount: UInt16 = 202
    let planPointCount: UInt16 = 832
    let compactFactCapacity: UInt16 = 32
    let actionCount: UInt16 = 6
    let modelStorageSlots: UInt16 = 2
    let observableLocationCapacity: UInt16 = 1
    let observableRegistrationCapacity: UInt16 = 1
    let observableReplacementCapacity: UInt16 = 1

    var isValid: Bool {
        logicalWidth == 320 && logicalHeight == 240
            && regionHeight == 4 && bytesPerRow == 640
            && rasterBytes == bytesPerRow * UInt32(regionHeight)
            && profileStorageBytes == 39_696
            && captureEntries == 2_404
            && canvasCount == 5 && livePointCount == 202 && planPointCount == 832
            && compactFactCapacity == 32 && actionCount == 6
            && modelStorageSlots == 2
            && observableLocationCapacity == 1
            && observableRegistrationCapacity == 1
            && observableReplacementCapacity == 1
    }
}

// Embedded lowering uses the exact generated variant codes without compiling
// the class-backed host Presentation input wrapper.
package enum StaticSignalAnalyzerNRFSemanticVariant: UInt8, Equatable, Sendable {
    case normal = 0
    case diagnostic = 1
}

// The firmware owns this one typed model location for its entire lifetime.
// Until the generated application adapter is linked, startup only validates
// its handle identity, generation, and six action routes.
nonisolated(unsafe) private var giftUIStaticModelLocation = StaticSignalAnalyzerNRFModelLocation()
nonisolated(unsafe) private var giftUIStaticRepository =
    StaticSignalAnalyzerNRFRepositoryProducer()
nonisolated(unsafe) private var giftUIStaticInteractionOwner =
    StaticSignalAnalyzerNRFEmbeddedInteractionOwner()!
nonisolated(unsafe) private var giftUIStaticGestureSession =
    StaticSignalAnalyzerNRFEmbeddedGestureSession()
nonisolated(unsafe) private var giftUIStaticGestureProbe =
    StaticSignalAnalyzerNRFEmbeddedGestureSession()
nonisolated(unsafe) private var giftUIStaticHasPendingFacts = false
nonisolated(unsafe) private var giftUIStaticPresentationPending = false
nonisolated(unsafe) private var giftUIStaticLastSemanticScopes: UInt32 = 0
nonisolated(unsafe) private var giftUIStaticLastLayoutScopes: UInt32 = 0
nonisolated(unsafe) private var giftUIStaticLastDrawingStrokes: UInt32 = 0
nonisolated(unsafe) private var giftUIStaticLastDrawingPoints: UInt32 = 0
nonisolated(unsafe) private var giftUIStaticLastRenderOperations: UInt32 = 0

@_cdecl("giftui_signal_analyzer_model_location_valid")
public func giftUISignalAnalyzerModelLocationValid() -> UInt32 {
    withUnsafeMutablePointer(to: &giftUIStaticModelLocation) { location in
        guard
            location.pointee.structuralIdentity
                == StaticSignalAnalyzerNRFModelDescriptor.structuralIdentity,
            location.pointee.declarationOrdinal
                == StaticSignalAnalyzerNRFModelDescriptor.declarationOrdinal,
            StaticSignalAnalyzerNRFModelDescriptor.modelStorageSlots == 2,
            StaticSignalAnalyzerNRFModelDescriptor.locationCapacity == 1,
            StaticSignalAnalyzerNRFModelDescriptor.registrationCapacity == 1,
            StaticSignalAnalyzerNRFModelDescriptor.replacementCapacity == 1
        else { return 0 }
        guard let generation = location.pointee.activate(),
            let handle = StaticSignalAnalyzerNRFModelHandle(
                location: location, generation: generation
            ),
            let registration = StaticSignalAnalyzerNRFChangeRegistration(
                location: location,
                token: StaticSignalAnalyzerNRFRegistrationToken(
                    slot: 0, generation: generation
                )
            )
        else { return 0 }
        let copy = handle
        location.pointee.clearDirtyAfterPublication()
        guard registration.reportChange() == .phaseViolation,
            !location.pointee.isDirty,
            handle.dispatch(actionRawValue: 0) == nil,
            location.pointee.beginMutation(),
            !location.pointee.beginMutation(),
            registration.reportChange() == .accepted,
            let diagnostic = giftUIStaticSampleDiagnostic(),
            location.pointee.setAcquisitionState(.failed(diagnostic)),
            location.pointee.acquisitionState == .failed(diagnostic),
            location.pointee.errorMessage == diagnostic,
            handle.dispatch(actionRawValue: 0) == .start,
            location.pointee.errorMessage == nil,
            location.pointee.acquisitionState == .failed(diagnostic),
            handle.dispatch(actionRawValue: 1) == .stop,
            handle.dispatch(actionRawValue: 2) == .clear,
            copy.dispatch(actionRawValue: 3) == .visibleWindowChanged,
            location.pointee.visibleWindowRawValue == 0,
            handle.dispatch(actionRawValue: 4) == .visibleWindowChanged,
            location.pointee.visibleWindowRawValue == 1,
            copy.dispatch(actionRawValue: 5) == .visibleWindowChanged,
            location.pointee.visibleWindowRawValue == 2,
            handle.dispatch(actionRawValue: 6) == nil,
            location.pointee.endMutation(),
            handle.dispatch(actionRawValue: 3) == nil
        else { return 0 }
        location.pointee.retire()
        guard handle.dispatch(actionRawValue: 0) == nil,
            registration.reportChange() == .staleRegistration
        else { return 0 }
        return 1
    }
}

@_cdecl("giftui_signal_analyzer_static_preset")
public func giftUISignalAnalyzerStaticPreset() -> UInt32 {
    let preset = StaticSignalAnalyzerPreset()
    return preset.isValid ? 360_515_885 : 0
}

@_cdecl("giftui_signal_analyzer_topology_valid")
public func giftUISignalAnalyzerTopologyValid(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32
) -> UInt32 {
    guard let profile, bytes == 39_696, let capture,
        captureBytes == 115_392,
        let captures = StaticSignalAnalyzerNRFCaptureRegions(
            storage: UnsafeMutableRawBufferPointer(
                start: capture, count: Int(captureBytes)
            )
        )
    else { return 0 }
    var model = StaticSignalAnalyzerNRFModelLocation()
    guard model.activate() != nil else { return 0 }
    let candidate = UnsafeMutableRawBufferPointer(start: profile, count: 3_024)
    let published = UnsafeMutableRawBufferPointer(
        start: profile.advanced(by: 3_024), count: 3_024
    )
    func check(
        _ variant: StaticSignalAnalyzerNRFSemanticVariant,
        revision: UInt32
    ) -> Bool {
        guard
            StaticSignalAnalyzerNRFEmbeddedSemanticRegion.stage(
                variant: variant, model: model, capture: captures, in: candidate
            ) != nil,
            StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: revision, candidate: candidate, published: published
            ),
            let view = StaticSignalAnalyzerNRFEmbeddedSemanticView(
                published: published
            ),
            view.scopeCount == 92,
            view.revision == revision,
            view.rootPrimitiveIdentity != nil,
            let title = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: 8, in: published
            ),
            view.textScalar(of: title.identity, at: 0) == 0x44
        else { return false }
        return true
    }
    guard check(.normal, revision: 1),
        model.beginMutation(),
        let diagnostic = giftUIStaticSampleDiagnostic(),
        model.setAcquisitionState(.failed(diagnostic)),
        model.endMutation(),
        check(.diagnostic, revision: 2)
    else { return 0 }
    model.retire()
    return 1
}

@_cdecl("giftui_signal_analyzer_layout_scope_valid")
public func giftUISignalAnalyzerLayoutScopeValid(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32
) -> UInt32 {
    guard let profile, bytes == 39_696 else { return 0 }
    let published = UnsafeMutableRawBufferPointer(
        start: profile.advanced(by: 3_024), count: 3_024
    )
    let layout = UnsafeMutableRawBufferPointer(
        start: profile.advanced(by: 6_048), count: 3_136
    )
    let text = UnsafeMutableRawBufferPointer(
        start: profile.advanced(by: 9_184), count: 4_704
    )
    guard
        let view = StaticSignalAnalyzerNRFEmbeddedSemanticView(
            published: published
        ), let root = view.rootPrimitiveIdentity,
        view.layoutPrimitive(at: root) != nil,
        view.layoutChildCount(of: root) != nil,
        let modifierCount = view.layoutModifierCount(of: root),
        modifierCount == 0 || view.layoutModifier(of: root, at: 0) != nil
    else { return 0 }
    guard
        var workspace = StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace(
            scopes: layout, text: text
        ), workspace.acquire(),
        workspace.appendScope(
            identity: root, idealWidth: 320, idealHeight: 240,
            width: 320, height: 240
        ),
        workspace.placeScope(
            identity: root, originX: 0, originY: 0,
            width: 320, height: 240,
            clipX: 0, clipY: 0, clipWidth: 320, clipHeight: 240
        ), workspace.scope(at: 0)?.identity == root,
        workspace.pushScope(root)
    else { return 0 }
    workspace.popScope()
    workspace.reset()
    return 1
}

@_cdecl("giftui_signal_analyzer_layout_text_valid")
public func giftUISignalAnalyzerLayoutTextValid(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32
) -> UInt32 {
    guard let profile, bytes == 39_696 else { return 0 }
    let published = UnsafeMutableRawBufferPointer(
        start: profile.advanced(by: 3_024), count: 3_024
    )
    guard StaticSignalAnalyzerNRFEmbeddedSemanticRegion.verifyPublished(published),
        let title = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
            at: 8, in: published
        )
    else { return 0 }
    let scopes = UnsafeMutableRawBufferPointer(
        start: profile.advanced(by: 6_048), count: 3_136
    )
    let workspace = UnsafeMutableRawBufferPointer(
        start: profile.advanced(by: 9_184), count: 4_704
    )
    let line = StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Line(
        identity: title.identity, lineIndex: 0,
        x: 0, y: 0, width: 184, height: 16,
        baselineX: 0, baselineY: 12
    )
    guard let glyphID = StaticSignalAnalyzerNRFReferenceMetrics.glyph(for: 0x44),
        let metric = StaticSignalAnalyzerNRFReferenceMetrics.metric(for: glyphID),
        metric.advanceX > 0,
        StaticSignalAnalyzerNRFReferenceMetrics.ascent == 16
    else { return 0 }
    let glyph = StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Glyph(
        identity: title.identity, lineIndex: 0, glyphID: glyphID,
        baselineX: 0, baselineY: 12
    )
    guard
        var layout = StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace(
            scopes: scopes, text: workspace
        ), layout.acquire(),
        layout.appendScope(
            identity: title.identity,
            idealWidth: 184, idealHeight: 16,
            width: 184, height: 16
        ), layout.appendGlyph(glyph, glyphIndex: 0),
        layout.appendTextLine(line),
        layout.textLine(at: 0) == line,
        layout.glyph(at: 0) == glyph
    else { return 0 }
    layout.reset()
    guard
        let semantic = StaticSignalAnalyzerNRFEmbeddedSemanticView(
            published: published
        ), layout.acquire(),
        layout.appendScope(
            identity: title.identity,
            idealWidth: 0, idealHeight: 0,
            width: 0, height: 0
        ),
        StaticSignalAnalyzerNRFEmbeddedTextMeasure.run(
            identity: title.identity, semantic: semantic,
            proposalWidth: 320, proposalHeight: 240,
            workspace: &layout
        ),
        StaticSignalAnalyzerNRFEmbeddedTextPlace.run(
            identity: title.identity, semantic: semantic,
            originX: 0, originY: 0,
            inheritedClipX: 0, inheritedClipY: 0,
            inheritedClipWidth: 320, inheritedClipHeight: 240,
            workspace: &layout
        ), layout.textLineCount > 0, layout.positionedGlyphCount > 0
    else { return 0 }
    guard
        let resolved = layout.publish(
            rootIdentity: title.identity, expectedScopeCount: 1
        ), resolved.isPublished,
        resolved.scope(at: 0)?.identity == title.identity,
        resolved.line(at: 0)?.identity == title.identity,
        resolved.glyph(at: 0)?.identity == title.identity
    else { return 0 }
    layout.reset()
    guard !resolved.isPublished else { return 0 }
    return 1
}

@_cdecl("giftui_signal_analyzer_full_layout_valid")
public func giftUISignalAnalyzerFullLayoutValid(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32
) -> UInt32 {
    guard let profile, bytes == 39_696 else { return 0 }
    let published = UnsafeMutableRawBufferPointer(
        start: profile.advanced(by: 3_024), count: 3_024
    )
    let scopes = UnsafeMutableRawBufferPointer(
        start: profile.advanced(by: 6_048), count: 3_136
    )
    let text = UnsafeMutableRawBufferPointer(
        start: profile.advanced(by: 9_184), count: 4_704
    )
    guard
        let semantic = StaticSignalAnalyzerNRFEmbeddedSemanticView(
            published: published
        ),
        let packed = StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace(
            scopes: scopes, text: text
        )
    else { return 0 }
    var workspace = StaticSignalAnalyzerNRFCommonLayoutWorkspace(packed: packed)
    guard
        let resolved = StaticSignalAnalyzerNRFCommonLayoutPass.run(
            semantic: semantic, workspace: &workspace
        ), resolved.isPublished,
        resolved.scopeCount == semantic.scopeCount,
        resolved.rootIdentity == semantic.rootSemanticIdentity,
        resolved.renderSnapshotVersion == semantic.revision,
        resolved.rootBounds.size.width > 0,
        resolved.rootBounds.size.height > 0,
        resolved.lineCount == 17, resolved.glyphCount == 86
    else { return 0 }
    var canvasCount: UInt16 = 0
    var checkedLines: UInt16 = 0
    var checkedGlyphs: UInt16 = 0
    let renderSemantic = StaticSignalAnalyzerNRFEmbeddedRenderSemanticAdapter(
        source: semantic
    )
    guard renderSemantic.rootIdentity == resolved.rootIdentity,
        renderSemantic.renderSnapshotVersion == resolved.renderSnapshotVersion,
        renderSemantic.semanticScopeCount == resolved.layoutScopeCount
    else { return 0 }
    var ordinal: UInt16 = 0
    while ordinal < semantic.scopeCount {
        guard let identity = semantic.semanticIdentity(at: ordinal),
            let record = semantic.scope(at: identity),
            renderSemantic.semanticIdentity(at: ordinal) == identity,
            renderSemantic.semanticOrdinal(of: identity) == ordinal,
            renderSemantic.scope(at: identity) != nil,
            renderSemantic.layoutIdentity(for: identity) == identity,
            renderSemantic.childCount(of: identity) != nil
        else { return 0 }
        if record.kind == .canvas {
            guard record.payload0 == UInt32(canvasCount + 1),
                let layoutOrdinal = resolved.layoutOrdinal(of: identity),
                resolved.layoutIdentity(at: layoutOrdinal) == identity,
                let bounds = resolved.bounds(of: identity),
                let clip = resolved.clip(of: identity),
                bounds.size.width > 0, bounds.size.height > 0,
                clip.size.width > 0, clip.size.height > 0
            else { return 0 }
            canvasCount += 1
        } else if record.kind == .text {
            guard let lineCount = resolved.textLineCount(of: identity) else {
                return 0
            }
            var lineIndex: UInt16 = 0
            var localGlyphIndex: UInt16 = 0
            while lineIndex < lineCount {
                guard let line = resolved.textLine(of: identity, at: lineIndex),
                    line.lineIndex == lineIndex
                else { return 0 }
                var glyphOnLine: UInt16 = 0
                while glyphOnLine < line.glyphCount {
                    guard
                        let glyph = resolved.glyph(
                            of: identity, at: localGlyphIndex
                        ), glyph.lineIndex == lineIndex,
                        glyph.glyphIndex == localGlyphIndex,
                        glyph.clip == line.clip
                    else { return 0 }
                    glyphOnLine += 1
                    localGlyphIndex += 1
                    checkedGlyphs += 1
                }
                checkedLines += 1
                lineIndex += 1
            }
            guard resolved.glyph(of: identity, at: localGlyphIndex) == nil else {
                return 0
            }
        }
        ordinal += 1
    }
    guard canvasCount == 5, checkedLines == 17,
        checkedGlyphs == 86
    else { return 0 }
    guard
        case .success(let ordinaryHeader) =
            StaticSignalAnalyzerNRFEmbeddedRenderPreflight.run(
                semantic: semantic, layout: resolved,
                textRegion: text
            ), ordinaryHeader.operationCount > 0,
        ordinaryHeader.operationCount <= 145,
        ordinaryHeader.positionedGlyphCount == 86
    else { return 0 }
    workspace.packed.reset()
    return resolved.isPublished ? 0 : 1
}

@_cdecl("giftui_signal_analyzer_drawing_storage_valid")
public func giftUISignalAnalyzerDrawingStorageValid(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32
) -> UInt32 {
    guard let profile, bytes == 39_696,
        let limits = DrawingLimits(
            maximumLineWidth: 1,
            maximumCanvasOccurrences: 5,
            maximumLivePathPoints: 202,
            maximumLivePathSubpaths: 12,
            maximumPlanStrokes: 5,
            maximumPlanPoints: 832,
            maximumPlanSubpaths: 16,
            maximumNormalizedStrokeOperations: 5
        ),
        var workspace = StaticSignalAnalyzerNRFDrawingWorkspace(
            pathRegion: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 14_048), count: 3_280
            ),
            planRegion: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 17_328), count: 13_536
            ), capacity: limits
        ), workspace.acquire(),
        let clip = Rect(
            origin: Point(x: 0, y: 0), size: Size(width: 320, height: 240)!
        )
    else { return 0 }
    var canvas: UInt16 = 1
    while canvas <= 5 {
        do {
            try workspace.withCanvasContext(
                identity: canvas, surfaceOrigin: Point(x: 0, y: 0),
                inheritedClip: clip
            ) { (context) throws(DrawingError) in
                try context.withPath { (context, path) throws(DrawingError) in
                    try path.move(to: Point(x: 0, y: 0))
                    try path.addLine(to: Point(x: 10, y: 10))
                    try context.stroke(path, with: .color(.green), lineWidth: 1)
                }
            }
        } catch { return 0 }
        canvas += 1
    }
    guard case .success(let summary) = workspace.seal(canvasOccurrenceCount: 5),
        summary.canvasOccurrenceCount == 5,
        summary.strokeCount == 5,
        summary.pointCount == 10,
        summary.subpathCount == 5,
        workspace.strokeCount(of: 1) == 1,
        workspace.point(of: 5, stroke: 0, at: 1) == Point(x: 10, y: 10)
    else { return 0 }
    workspace.reset()
    return workspace.isActive ? 0 : 1
}

@_cdecl("giftui_signal_analyzer_canvas_payload_valid")
public func giftUISignalAnalyzerCanvasPayloadValid(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32
) -> UInt32 {
    guard let profile, bytes == 39_696 else { return 0 }
    let region = UnsafeMutableRawBufferPointer(
        start: profile.advanced(by: 13_888), count: 160
    )
    region.initializeMemory(as: UInt8.self, repeating: 0)
    let trace = StaticSignalAnalyzerNRFEmbeddedCanvasPayload.TraceCapture(
        modelToken: 8, channelRawValue: 1,
        lowerMilliseconds: 0, upperMilliseconds: 2_000
    )
    guard
        StaticSignalAnalyzerNRFEmbeddedCanvasPayload.stageTrace(
            trace, at: 1, in: region
        ),
        !StaticSignalAnalyzerNRFEmbeddedCanvasPayload.stageTrace(
            trace, at: 1, in: region
        ),
        StaticSignalAnalyzerNRFEmbeddedCanvasPayload.trace(at: 1, in: region)?
            .modelToken == 8,
        region[32] == 8, region[40] == 1,
        region[48] == 0, region[56] == 0xD0, region[57] == 0x07
    else { return 0 }
    region[40] = 0
    guard StaticSignalAnalyzerNRFEmbeddedCanvasPayload.trace(at: 1, in: region) == nil
    else { return 0 }
    guard StaticSignalAnalyzerNRFEmbeddedCanvasPayload.release(at: 1, in: region),
        StaticSignalAnalyzerNRFEmbeddedCanvasPayload.isEmpty(region),
        StaticSignalAnalyzerNRFEmbeddedCanvasPayload.trace(at: 1, in: region) == nil
    else { return 0 }
    return 1
}

@_cdecl("giftui_signal_analyzer_full_canvas_valid")
public func giftUISignalAnalyzerFullCanvasValid(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32,
    _ raster: UnsafeMutableRawPointer?, _ rasterBytes: UInt32,
    _ coverage: UnsafeMutableRawPointer?, _ coverageBytes: UInt32
) -> UInt32 {
    // Borrow the static instances so the validator does not stack-allocate
    // another interaction owner alongside the render traversal.
    let result = withUnsafeMutablePointer(to: &giftUIStaticModelLocation) { model in
        withUnsafeMutablePointer(to: &giftUIStaticInteractionOwner) { interaction in
            withUnsafeMutablePointer(to: &giftUIStaticGestureSession) { gestures in
                giftUIStaticFullCanvas(
                    profile, bytes, capture, captureBytes,
                    raster, rasterBytes, coverage, coverageBytes,
                    write: giftUISignalAnalyzerProbeRGB565,
                    validation: true, frameRevision: 1, model: &model.pointee,
                    interaction: &interaction.pointee, gestures: &gestures.pointee
                )
            }
        }
    }
    giftUIStaticResetValidationState()
    return result
}

@inline(never)
private func giftUIStaticResetValidationState() {
    // Keep the large replacement value out of the validator's render frame.
    giftUIStaticModelLocation = StaticSignalAnalyzerNRFModelLocation()
    giftUIStaticInteractionOwner = StaticSignalAnalyzerNRFEmbeddedInteractionOwner()!
    giftUIStaticGestureSession = StaticSignalAnalyzerNRFEmbeddedGestureSession()
    giftUIStaticResetPresentationCounts()
}

private func giftUIStaticResetPresentationCounts() {
    giftUIStaticLastSemanticScopes = 0
    giftUIStaticLastLayoutScopes = 0
    giftUIStaticLastDrawingStrokes = 0
    giftUIStaticLastDrawingPoints = 0
    giftUIStaticLastRenderOperations = 0
}

@_cdecl("giftui_signal_analyzer_present_initial")
public func giftUISignalAnalyzerPresentInitial(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32,
    _ raster: UnsafeMutableRawPointer?, _ rasterBytes: UInt32,
    _ coverage: UnsafeMutableRawPointer?, _ coverageBytes: UInt32,
    _ write: (
        @convention(c) (
            UInt16, UInt16, UInt16, UInt16, UnsafePointer<UInt8>?, Int
        ) -> Int32
    )?
) -> UInt32 {
    guard let write else { return 0 }
    return withUnsafeMutablePointer(to: &giftUIStaticModelLocation) { location in
        withUnsafeMutablePointer(to: &giftUIStaticRepository) { repository in
            withUnsafeMutablePointer(to: &giftUIStaticInteractionOwner) { interaction in
                withUnsafeMutablePointer(to: &giftUIStaticGestureSession) { gestures in
                    guard location.pointee.activeGeneration == nil else { return 0 }
                    guard let profile, bytes == 39_696 else { return 0 }
                    UnsafeMutableRawBufferPointer(start: profile, count: Int(bytes))
                        .initializeMemory(as: UInt8.self, repeating: 0)
                    guard location.pointee.activate() != nil,
                        giftUIStaticBootstrap(
                            profile: profile, profileBytes: bytes,
                            capture: capture, captureBytes: captureBytes,
                            model: &location.pointee,
                            repository: &repository.pointee
                        )
                    else {
                        giftUIStaticRetire(
                            model: &location.pointee,
                            repository: &repository.pointee,
                            interaction: &interaction.pointee,
                            gestures: &gestures.pointee
                        )
                        return 0
                    }
                    var result = giftUIStaticCommonPresentation(
                        profile: profile, profileBytes: bytes, capture: capture,
                        captureBytes: captureBytes,
                        raster: raster, rasterBytes: rasterBytes, coverage: coverage,
                        coverageBytes: coverageBytes,
                        write: write, frameRevision: 1, initial: true, model: location,
                        repository: repository,
                        interaction: interaction, gestures: gestures)
                    if result == 1 {
                        result = giftUIStaticVerifyInitialInput(
                            model: &location.pointee,
                            interaction: &interaction.pointee,
                            gestures: &gestures.pointee,
                            frameRevision: 1
                        )
                    }
                    if result == 0 {
                        giftUIStaticRetire(
                            model: &location.pointee,
                            repository: &repository.pointee,
                            interaction: &interaction.pointee,
                            gestures: &gestures.pointee
                        )
                    }
                    return result
                }
            }
        }
    }
}

@_cdecl("giftui_signal_analyzer_present_next")
public func giftUISignalAnalyzerPresentNext(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32,
    _ raster: UnsafeMutableRawPointer?, _ rasterBytes: UInt32,
    _ coverage: UnsafeMutableRawPointer?, _ coverageBytes: UInt32,
    _ write: (
        @convention(c) (
            UInt16, UInt16, UInt16, UInt16, UnsafePointer<UInt8>?, Int
        ) -> Int32
    )?
) -> UInt32 {
    guard let write, giftUIStaticModelLocation.activeGeneration != nil,
        let previous = giftUIStaticInteractionOwner.committedRevision?.rawValue,
        previous < UInt32.max,
        giftUIStaticGestureSession.hasPresentation
    else { return 0 }
    let revision = previous + 1
    return withUnsafeMutablePointer(to: &giftUIStaticModelLocation) { model in
        withUnsafeMutablePointer(to: &giftUIStaticRepository) { repository in
            withUnsafeMutablePointer(to: &giftUIStaticInteractionOwner) { interaction in
                withUnsafeMutablePointer(to: &giftUIStaticGestureSession) { gestures in
                    let offered = giftUIStaticCommonPresentation(
                        profile: profile, profileBytes: bytes, capture: capture,
                        captureBytes: captureBytes,
                        raster: raster, rasterBytes: rasterBytes, coverage: coverage,
                        coverageBytes: coverageBytes,
                        write: write, frameRevision: revision, initial: false, model: model,
                        repository: repository,
                        interaction: interaction, gestures: gestures)
                    if offered == 2 { return 2 }
                    guard offered == 1,
                        giftUISignalAnalyzerInputInstallPresentation(revision) == 0
                    else {
                        giftUIStaticRetire(
                            model: &model.pointee,
                            repository: &repository.pointee,
                            interaction: &interaction.pointee,
                            gestures: &gestures.pointee
                        )
                        giftUISignalAnalyzerInputQuiesce()
                        return 0
                    }
                    return 1
                }
            }
        }
    }
}

@_cdecl("giftui_signal_analyzer_initial_model_active")
public func giftUISignalAnalyzerInitialModelActive() -> UInt32 {
    giftUIStaticModelLocation.activeGeneration == nil ? 0 : 1
}

@_cdecl("giftui_signal_analyzer_initial_committed_actions")
public func giftUISignalAnalyzerInitialCommittedActions() -> UInt16 {
    giftUIStaticInteractionOwner.committedRecordCount
}

@_cdecl("giftui_signal_analyzer_initial_gesture_ready")
public func giftUISignalAnalyzerInitialGestureReady() -> UInt32 {
    giftUIStaticGestureSession.hasPresentation ? 1 : 0
}

@_cdecl("giftui_signal_analyzer_needs_presentation")
public func giftUISignalAnalyzerNeedsPresentation() -> UInt32 {
    giftUIStaticModelLocation.activeGeneration != nil
        && (giftUIStaticModelLocation.isDirty || giftUIStaticHasPendingFacts
            || giftUIStaticPresentationPending
            || giftUISignalAnalyzerInputPendingCount() > 0)
        ? 1 : 0
}

@_cdecl("giftui_signal_analyzer_current_revision")
public func giftUISignalAnalyzerCurrentRevision() -> UInt32 {
    giftUIStaticInteractionOwner.committedRevision?.rawValue ?? 0
}

@_cdecl("giftui_signal_analyzer_capture_revision")
public func giftUISignalAnalyzerCaptureRevision() -> UInt32 {
    giftUIStaticModelLocation.capture.revision
}

@_cdecl("giftui_signal_analyzer_acquisition_state")
public func giftUISignalAnalyzerAcquisitionState() -> UInt32 {
    switch giftUIStaticModelLocation.acquisitionState {
    case .idle: 0
    case .running: 1
    case .stopped: 2
    case .failed: 3
    }
}

@_cdecl("giftui_signal_analyzer_visible_window")
public func giftUISignalAnalyzerVisibleWindow() -> UInt32 {
    UInt32(giftUIStaticModelLocation.visibleWindowRawValue)
}

@_cdecl("giftui_signal_analyzer_capture_count")
public func giftUISignalAnalyzerCaptureCount() -> UInt32 {
    UInt32(giftUIStaticModelLocation.capture.count)
}

@_cdecl("giftui_signal_analyzer_last_semantic_scopes")
public func giftUISignalAnalyzerLastSemanticScopes() -> UInt32 {
    giftUIStaticLastSemanticScopes
}

@_cdecl("giftui_signal_analyzer_last_layout_scopes")
public func giftUISignalAnalyzerLastLayoutScopes() -> UInt32 {
    giftUIStaticLastLayoutScopes
}

@_cdecl("giftui_signal_analyzer_last_drawing_strokes")
public func giftUISignalAnalyzerLastDrawingStrokes() -> UInt32 {
    giftUIStaticLastDrawingStrokes
}

@_cdecl("giftui_signal_analyzer_last_drawing_points")
public func giftUISignalAnalyzerLastDrawingPoints() -> UInt32 {
    giftUIStaticLastDrawingPoints
}

@_cdecl("giftui_signal_analyzer_last_render_operations")
public func giftUISignalAnalyzerLastRenderOperations() -> UInt32 {
    giftUIStaticLastRenderOperations
}

@_cdecl("giftui_signal_analyzer_next_delay_microseconds")
public func giftUISignalAnalyzerNextDelayMicroseconds() -> UInt64 {
    guard let milliseconds = giftUIStaticRepository.nextScheduledDelayMilliseconds,
        milliseconds >= 0,
        milliseconds <= Int64(UInt64.max / 1_000)
    else { return UInt64.max }
    let micros = UInt64(milliseconds) * 1_000
    return micros
}

@_cdecl("giftui_signal_analyzer_initial_start_point")
public func giftUISignalAnalyzerInitialStartPoint() -> UInt32 {
    giftUISignalAnalyzerActionPoint(0)
}

@_cdecl("giftui_signal_analyzer_action_point")
public func giftUISignalAnalyzerActionPoint(_ code: UInt16) -> UInt32 {
    guard code < 6 else { return 0 }
    var index: UInt16 = 0
    while index < 3 {
        if let record = giftUIStaticInteractionOwner.committedRecord(at: index),
            record.action.code == code, record.isEnabled
        {
            return giftUISignalAnalyzerHitPoint(code)
        }
        index += 1
    }
    return 0
}

@_cdecl("giftui_signal_analyzer_hit_point")
public func giftUISignalAnalyzerHitPoint(_ code: UInt16) -> UInt32 {
    guard code < 6 else { return 0 }
    var index: UInt16 = 0
    while index < 3 {
        if let record = giftUIStaticInteractionOwner.committedRecord(at: index),
            record.action.code == code
        {
            let x = record.hitBounds.origin.x + record.hitBounds.size.width / 2
            let y = record.hitBounds.origin.y + record.hitBounds.size.height / 2
            guard x >= 0, x < 320, y >= 0, y < 240 else { return 0 }
            return UInt32(y) << 16 | UInt32(x)
        }
        index += 1
    }
    return 0
}

@_cdecl("giftui_signal_analyzer_drain_initial_input")
public func giftUISignalAnalyzerDrainInitialInput(
    _ profile: UnsafeMutableRawPointer?, _ profileBytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32
) -> UInt32 {
    guard let profile, profileBytes == 39_696,
        let capture, captureBytes == 115_392,
        giftUIStaticGestureSession.hasPresentation,
        giftUIStaticModelLocation.activeGeneration != nil
    else { return 0 }
    let profileStorage = UnsafeMutableRawBufferPointer(
        start: profile, count: Int(profileBytes)
    )
    let captureStorage = UnsafeMutableRawBufferPointer(
        start: capture, count: Int(captureBytes)
    )
    return withUnsafeMutablePointer(to: &giftUIStaticGestureSession) { gestures in
        withUnsafeMutablePointer(to: &giftUIStaticInteractionOwner) { interaction in
            withUnsafeMutablePointer(to: &giftUIStaticModelLocation) { model in
                withUnsafeMutablePointer(to: &giftUIStaticRepository) { repository in
                    var handler = StaticSignalAnalyzerNRFEmbeddedInputHandler(
                        gestures: gestures, interaction: interaction, model: model
                    )
                    guard
                        case .completed = giftUIStaticRunInputOpportunity(
                            into: &handler
                        ),
                        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
                            resumingActiveStorage: UnsafeMutableRawBufferPointer(
                                rebasing: profileStorage[31_632 ..< 35_472]
                            ),
                            sealedStorage: UnsafeMutableRawBufferPointer(
                                rebasing: profileStorage[35_472 ..< 39_312]
                            )
                        )
                    else { return 0 }
                    var index: UInt16 = 0
                    while index < handler.actionCount {
                        guard let actionCode = handler.actionCode(at: index),
                            let generation = model.pointee.activeGeneration,
                            StaticSignalAnalyzerNRFEmbeddedActionDispatcher.dispatch(
                                actionCode: actionCode, modelGeneration: generation,
                                model: &model.pointee,
                                repository: &repository.pointee,
                                admission: &admission,
                                captureStorage: captureStorage
                            )
                        else { return 0 }
                        index += 1
                    }
                    return UInt32(handler.actionCount) + 1
                }
            }
        }
    }
}

@_cdecl("giftui_signal_analyzer_poll_scheduled_due")
public func giftUISignalAnalyzerPollScheduledDue(
    _ profile: UnsafeMutableRawPointer?, _ profileBytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32
) -> UInt32 {
    guard let profile, profileBytes == 39_696,
        let capture, captureBytes == 115_392,
        giftUIStaticModelLocation.activeGeneration != nil,
        giftUIStaticRepository.nextScheduledDelayMilliseconds != nil
    else { return 0 }
    let profileStorage = UnsafeMutableRawBufferPointer(
        start: profile, count: Int(profileBytes)
    )
    let captureStorage = UnsafeMutableRawBufferPointer(
        start: capture, count: Int(captureBytes)
    )
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            resumingActiveStorage: UnsafeMutableRawBufferPointer(
                rebasing: profileStorage[31_632 ..< 35_472]
            ),
            sealedStorage: UnsafeMutableRawBufferPointer(
                rebasing: profileStorage[35_472 ..< 39_312]
            )
        ),
        giftUIStaticRepository.pollScheduled(
            admission: &admission, captureStorage: captureStorage
        ) == .accepted
    else { return 0 }
    giftUIStaticHasPendingFacts = true
    return 1
}

@_cdecl("giftui_signal_analyzer_retire_initial")
public func giftUISignalAnalyzerRetireInitial() {
    giftUIStaticRetire(
        model: &giftUIStaticModelLocation,
        repository: &giftUIStaticRepository,
        interaction: &giftUIStaticInteractionOwner,
        gestures: &giftUIStaticGestureSession
    )
}

@inline(never)
private func giftUIStaticBootstrap(
    profile: UnsafeMutableRawPointer?, profileBytes: UInt32,
    capture: UnsafeMutableRawPointer?, captureBytes: UInt32,
    model: inout StaticSignalAnalyzerNRFModelLocation,
    repository: inout StaticSignalAnalyzerNRFRepositoryProducer
) -> Bool {
    guard let profile, profileBytes == 39_696,
        let capture, captureBytes == 115_392
    else { return false }
    let profileStorage = UnsafeMutableRawBufferPointer(
        start: profile, count: Int(profileBytes)
    )
    let captureStorage = UnsafeMutableRawBufferPointer(
        start: capture, count: Int(captureBytes)
    )
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            activeStorage: UnsafeMutableRawBufferPointer(
                rebasing: profileStorage[31_632 ..< 35_472]
            ),
            sealedStorage: UnsafeMutableRawBufferPointer(
                rebasing: profileStorage[35_472 ..< 39_312]
            )
        ),
        repository.startObservation(
            admission: &admission, captureStorage: captureStorage
        ) == .accepted
    else { return false }
    giftUIStaticHasPendingFacts = true
    return true
}

@inline(never)
private func giftUIStaticRetire(
    model: inout StaticSignalAnalyzerNRFModelLocation,
    repository: inout StaticSignalAnalyzerNRFRepositoryProducer,
    interaction: inout StaticSignalAnalyzerNRFEmbeddedInteractionOwner,
    gestures: inout StaticSignalAnalyzerNRFEmbeddedGestureSession
) {
    repository.shutdown()
    repository = StaticSignalAnalyzerNRFRepositoryProducer()
    interaction = StaticSignalAnalyzerNRFEmbeddedInteractionOwner()!
    gestures.quiesce()
    model.retire()
    giftUIStaticResetPresentationCounts()
    giftUIStaticHasPendingFacts = false
    giftUIStaticPresentationPending = false
}

@inline(never)
private func giftUIStaticVerifyInitialInput(
    model: inout StaticSignalAnalyzerNRFModelLocation,
    interaction: inout StaticSignalAnalyzerNRFEmbeddedInteractionOwner,
    gestures: inout StaticSignalAnalyzerNRFEmbeddedGestureSession,
    frameRevision: UInt32
) -> UInt32 {
    guard let start = interaction.committedRecord(at: 0),
        start.isEnabled
    else { return 0 }
    let point = Point(
        x: start.hitBounds.origin.x + start.hitBounds.size.width / 2,
        y: start.hitBounds.origin.y + start.hitBounds.size.height / 2
    )
    guard giftUIStaticVerifyRawGesture(point: point, interaction: &interaction),
        giftUIStaticVerifyGestureSequence(
            point: point, model: &model, interaction: &interaction,
            gestures: &gestures, frameRevision: frameRevision
        ),
        giftUIStaticVerifyInputDrain(
            point: point, model: &model, interaction: &interaction,
            gestures: gestures
        )
    else { return 0 }
    model.clearDirtyAfterPublication()
    return 1
}

@inline(never)
private func giftUIStaticVerifyRawGesture(
    point: Point,
    interaction: inout StaticSignalAnalyzerNRFEmbeddedInteractionOwner
) -> Bool {
    guard let start = interaction.committedRecord(at: 0) else { return false }
    var capture = PointerActionCapture<UInt32>()
    guard
        case .captured(let down) = ExecutionGestureAdapter.down(
            at: point, capture: &capture, resolver: interaction
        ),
        case .activationAdmitted(let up) = ExecutionGestureAdapter.up(
            at: point, capture: &capture, resolver: interaction
        ), down == up, up.identity == start.identity
    else { return false }
    return true
}

@inline(never)
private func giftUIStaticVerifyGestureSequence(
    point: Point,
    model: inout StaticSignalAnalyzerNRFModelLocation,
    interaction: inout StaticSignalAnalyzerNRFEmbeddedInteractionOwner,
    gestures: inout StaticSignalAnalyzerNRFEmbeddedGestureSession,
    frameRevision: UInt32
) -> Bool {
    let revision = PresentationRevision(rawValue: frameRevision)
    gestures.installPhysicalPresentation(revision)
    giftUIStaticGestureProbe.quiesce()
    giftUIStaticGestureProbe.installPhysicalPresentation(revision)
    let source = InputSourceID(rawValue: 1)
    let sequence = PointerSequenceID(rawValue: 1)
    let downEvent = NormalizedPointerEvent(
        phase: .down, position: point,
        source: source, sequence: sequence,
        ordinal: InputOrdinal(rawValue: 0),
        presentationRevision: revision
    )
    let upEvent = NormalizedPointerEvent(
        phase: .up, position: point,
        source: source, sequence: sequence,
        ordinal: InputOrdinal(rawValue: 1),
        presentationRevision: revision
    )
    let staleEvent = NormalizedPointerEvent(
        phase: .down, position: point,
        source: source, sequence: sequence,
        ordinal: InputOrdinal(rawValue: 0),
        presentationRevision: PresentationRevision(rawValue: 0)
    )
    guard let generation = model.activeGeneration,
        giftUIStaticGestureProbe.handle(
            downEvent, interaction: interaction,
            modelGeneration: generation
        ) == .consumed,
        giftUIStaticGestureProbe.handle(
            upEvent, interaction: interaction,
            modelGeneration: generation
        ) == .admitted(actionCode: 0),
        giftUIStaticGestureProbe.handle(
            staleEvent, interaction: interaction,
            modelGeneration: generation
        ) == .rejected,
        gestures.hasPresentation
    else { return false }
    return true
}

@inline(never)
private func giftUIStaticVerifyInputDrain(
    point: Point,
    model: inout StaticSignalAnalyzerNRFModelLocation,
    interaction: inout StaticSignalAnalyzerNRFEmbeddedInteractionOwner,
    gestures: StaticSignalAnalyzerNRFEmbeddedGestureSession
) -> Bool {
    var inputProbe = StaticSignalAnalyzerNRFFirmwareInputStorage(sourceRawValue: 1)
    guard inputProbe.installPhysicalPresentation(rawValue: 1),
        inputProbe.admit(
            phaseRawValue: 0, x: UInt16(point.x), y: UInt16(point.y),
            observedPresentationRevisionRawValue: 1,
            priorPhysicalSequenceIsCompleteRawValue: 0
        )?.disposition == .queued,
        inputProbe.admit(
            phaseRawValue: 2, x: UInt16(point.x), y: UInt16(point.y),
            observedPresentationRevisionRawValue: 1,
            priorPhysicalSequenceIsCompleteRawValue: 0
        )?.disposition == .queued
    else { return false }
    var drainGestures = gestures
    let drained = withUnsafeMutablePointer(to: &drainGestures) { session in
        withUnsafeMutablePointer(to: &interaction) { committed in
            withUnsafeMutablePointer(to: &model) { location in
                var handler = StaticSignalAnalyzerNRFEmbeddedInputHandler(
                    gestures: session, interaction: committed, model: location
                )
                let result = inputProbe.runOpportunity(into: &handler)
                return (result, handler.actionCount, handler.actionCode(at: 0))
            }
        }
    }
    guard case .completed(let summary) = drained.0,
        summary.eventCount == 2,
        summary.cancelledOrRejectedCount == 0,
        drained.1 == 1,
        drained.2 == 0,
        inputProbe.pendingCount == 0
    else { return false }
    return true
}

// Keep the canonical plan traversal in its own frame. Repeated validation
// passes must not reserve all of their generic traversal temporaries together.
@inline(never)
private func giftUIStaticDeriveCanvas(
    source: inout StaticSignalAnalyzerNRFEmbeddedCanvasSource,
    layout: borrowing StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView,
    executionContext: ExecutionContext, limits: DrawingLimits,
    workspace: inout StaticSignalAnalyzerNRFDrawingWorkspace
) -> DrawingPlanResult {
    CanvasPlanProducer.derive(
        source: &source, layout: layout, executionContext: executionContext,
        limits: limits, workspace: &workspace)
}

private func giftUIStaticFullCanvas(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32,
    _ raster: UnsafeMutableRawPointer?, _ rasterBytes: UInt32,
    _ coverage: UnsafeMutableRawPointer?, _ coverageBytes: UInt32,
    write: StaticSignalAnalyzerNRFEmbeddedPixelWrite,
    validation: Bool,
    frameRevision: UInt32,
    model: inout StaticSignalAnalyzerNRFModelLocation,
    interaction: inout StaticSignalAnalyzerNRFEmbeddedInteractionOwner,
    gestures: inout StaticSignalAnalyzerNRFEmbeddedGestureSession
) -> UInt32 {
    guard validation else { return 0 }
    guard let profile, bytes == 39_696,
        let capture, captureBytes == 115_392,
        let raster, rasterBytes == 2_560,
        let coverage, coverageBytes == 160
    else { return 0 }
    let candidateRegion = UnsafeMutableRawBufferPointer(
        start: profile, count: 3_024
    )
    let publishedRegion = UnsafeMutableRawBufferPointer(
        start: profile.advanced(by: 3_024), count: 3_024
    )
    if !validation {
        guard model.activeGeneration != nil,
            let prior = StaticSignalAnalyzerNRFEmbeddedSemanticView(
                published: publishedRegion
            ), prior.revision < .max,
            let captures = StaticSignalAnalyzerNRFCaptureRegions(
                storage: UnsafeMutableRawBufferPointer(
                    start: capture, count: Int(captureBytes)
                )
            ),
            StaticSignalAnalyzerNRFEmbeddedSemanticRegion.stage(
                variant: model.errorMessage == nil ? .normal : .diagnostic,
                model: model,
                capture: captures, in: candidateRegion
            ) != nil,
            StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: prior.revision + 1,
                candidate: candidateRegion, published: publishedRegion
            )
        else { return 0 }
    }
    guard
        let semantic = StaticSignalAnalyzerNRFEmbeddedSemanticView(
            published: publishedRegion
        ),
        let packed = StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace(
            scopes: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 6_048), count: 3_136
            ),
            text: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 9_184), count: 4_704
            )
        ),
        let limits = DrawingLimits(
            maximumLineWidth: 1,
            maximumCanvasOccurrences: 5,
            maximumLivePathPoints: 202,
            maximumLivePathSubpaths: 12,
            maximumPlanStrokes: 5,
            maximumPlanPoints: 832,
            maximumPlanSubpaths: 16,
            maximumNormalizedStrokeOperations: 5
        ),
        var drawing = StaticSignalAnalyzerNRFDrawingWorkspace(
            pathRegion: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 14_048), count: 3_280
            ),
            planRegion: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 17_328), count: 13_536
            ), capacity: limits
        )
    else { return 0 }
    var layoutWorkspace = StaticSignalAnalyzerNRFCommonLayoutWorkspace(packed: packed)
    defer {
        drawing.reset()
        layoutWorkspace.packed.reset()
        if validation { model.retire() }
    }
    guard
        let resolved = StaticSignalAnalyzerNRFCommonLayoutPass.run(
            semantic: semantic, workspace: &layoutWorkspace
        ),
        let actions = StaticSignalAnalyzerNRFEmbeddedInteractionOccurrences(
            semantic: semantic, layout: resolved
        ), actions.count == 3,
        actions.occurrence(at: 0)?.actionCode == (model.acquisitionState == .running ? 1 : 0),
        actions.occurrence(at: 2)?.actionCode == (model.visibleWindowRawValue == 0 ? 4 : 5),
        interaction.build(
            occurrences: actions,
            targetGeneration: ObservableTargetGeneration(
                rawValue: model.activeGeneration ?? 0
            )
        ), interaction.candidateIsReadyForOffer
    else { return 0 }
    defer {
        if interaction.candidateIsReadyForOffer {
            interaction.resolve(
                accepted: false,
                presentationRevision: PresentationRevision(rawValue: frameRevision)
            )
        }
    }
    guard !validation || model.activate() != nil,
        var source = StaticSignalAnalyzerNRFEmbeddedCanvasSource(
            semantic: semantic, model: model,
            captureRegion: UnsafeMutableRawBufferPointer(
                start: capture, count: Int(captureBytes)
            ),
            callableRegion: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 13_888), count: 160
            )
        )
    else { return 0 }
    let firstProvenance = FrameProvenance(
        cycle: RunCycleID(rawValue: frameRevision),
        semanticRevision: SemanticRevision(rawValue: semantic.revision),
        candidateFrame: CandidateFrameID(rawValue: frameRevision)
    )
    guard
        var fullEndpoint = giftUIStaticEmbeddedEndpoint(
            raster: raster, coverage: coverage, provenance: firstProvenance, write: write
        ),
        giftUIStaticValidateFirstCanvas(
            semantic: semantic, drawing: &drawing, limits: limits,
            profile: profile, capture: capture, captureBytes: captureBytes,
            raster: raster, rasterBytes: rasterBytes,
            coverage: coverage, coverageBytes: coverageBytes,
            model: &model, fullEndpoint: &fullEndpoint, resolved: resolved, source: &source,
            interaction: &interaction, gestures: &gestures, actions: actions,
            frameRevision: frameRevision, validation: validation,
            firstProvenance: firstProvenance) == 1
    else { return 0 }
    return giftUIStaticValidateUpdatedCanvas(
        semantic: semantic, drawing: &drawing, limits: limits,
        profile: profile, capture: capture, captureBytes: captureBytes,
        raster: raster, rasterBytes: rasterBytes,
        coverage: coverage, coverageBytes: coverageBytes,
        model: &model, fullEndpoint: &fullEndpoint, layoutWorkspace: &layoutWorkspace,
        resolved: resolved)
}

@inline(never)
private func giftUIStaticValidateFirstCanvas(
    semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView,
    drawing: inout StaticSignalAnalyzerNRFDrawingWorkspace,
    limits: DrawingLimits, profile: UnsafeMutableRawPointer,
    capture: UnsafeMutableRawPointer, captureBytes: UInt32,
    raster: UnsafeMutableRawPointer, rasterBytes: UInt32,
    coverage: UnsafeMutableRawPointer, coverageBytes: UInt32,
    model: inout StaticSignalAnalyzerNRFModelLocation,
    fullEndpoint: inout StaticSignalAnalyzerNRFEmbeddedEndpoint,
    resolved: StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView,
    source: inout StaticSignalAnalyzerNRFEmbeddedCanvasSource,
    interaction: inout StaticSignalAnalyzerNRFEmbeddedInteractionOwner,
    gestures: inout StaticSignalAnalyzerNRFEmbeddedGestureSession,
    actions: StaticSignalAnalyzerNRFEmbeddedInteractionOccurrences,
    frameRevision: UInt32, validation: Bool,
    firstProvenance: FrameProvenance
) -> UInt32 {
    let result = giftUIStaticDeriveCanvas(
        source: &source, layout: resolved,
        executionContext: ExecutionContext(
            cycle: RunCycleID(rawValue: frameRevision),
            semanticRevision: SemanticRevision(rawValue: semantic.revision),
            candidateFrame: nil, phase: .deriving
        ), limits: limits, workspace: &drawing
    )
    guard case .success(let summary) = result else { return 0 }
    guard source.allReleased,
        summary.canvasOccurrenceCount == 5,
        summary.strokeCount == 5,
        summary.pointCount >= 32,
        summary.pointCount <= 832,
        summary.subpathCount > 0,
        summary.subpathCount <= 16,
        frameRevision != 1
            || (summary.pointCount == 32 && summary.subpathCount == 16)
    else { return 0 }
    guard
        let gridID = source.canvasIdentity(at: 0),
        let grid = drawing.strokeHeader(of: gridID, at: 0),
        grid.color == .gray,
        grid.lineWidth == 1,
        grid.pointCount == 24,
        grid.subpathCount == 12
    else { return 0 }
    guard
        case .success(let renderHeader) =
            StaticSignalAnalyzerNRFEmbeddedRenderPreflight.runCombined(
                semantic: semantic, layout: resolved,
                textRegion: UnsafeMutableRawBufferPointer(
                    start: profile.advanced(by: 9_184), count: 4_704
                ), drawing: drawing
            ), renderHeader.operationCount <= 150,
        renderHeader.positionedGlyphCount > 0,
        renderHeader.positionedGlyphCount <= 224,
        frameRevision != 1
            || renderHeader.positionedGlyphCount == (validation ? 86 : 83)
    else { return 0 }
    var sink = StaticSignalAnalyzerNRFEmbeddedCountingSink()
    guard
        case .success(let streamedHeader) =
            StaticSignalAnalyzerNRFEmbeddedRenderPreflight.streamCombined(
                semantic: semantic, layout: resolved,
                textRegion: UnsafeMutableRawBufferPointer(
                    start: profile.advanced(by: 9_184), count: 4_704
                ), drawing: drawing, expectedHeader: renderHeader, sink: &sink
            ), streamedHeader == renderHeader,
        sink.isFinished, !sink.wasDiscarded,
        sink.strokeCount == 5,
        sink.glyphCount == renderHeader.positionedGlyphCount
    else { return 0 }
    if validation {
        guard
            var rasterSink = StaticSignalAnalyzerNRFEmbeddedRasterSink(
                rasterRegion: UnsafeMutableRawBufferPointer(
                    start: raster, count: Int(rasterBytes)
                ),
                coverageRegion: UnsafeMutableRawBufferPointer(
                    start: coverage, count: Int(coverageBytes)
                ), write: giftUISignalAnalyzerProbeRGB565
            ),
            case .success(let rasterHeader) =
                StaticSignalAnalyzerNRFEmbeddedRenderPreflight.streamCombined(
                    semantic: semantic, layout: resolved,
                    textRegion: UnsafeMutableRawBufferPointer(
                        start: profile.advanced(by: 9_184), count: 4_704
                    ), drawing: drawing, expectedHeader: renderHeader,
                    sink: &rasterSink
                ), rasterHeader == renderHeader,
            rasterSink.isFinished, rasterSink.paintedPixels > 0,
            rasterSink.tileVisits > 0, rasterSink.submittedRuns > 0,
            rasterSink.submittedBytes > 0
        else { return 0 }
    }
    guard
        giftUIStaticEmbeddedOffer(
            endpoint: &fullEndpoint,
            provenance: firstProvenance,
            semantic: semantic, layout: resolved,
            textRegion: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 9_184), count: 4_704
            ), drawing: drawing, expectedHeader: renderHeader
        ), fullEndpoint.bodyCallCount == 1
    else { return 0 }
    interaction.resolve(
        accepted: true,
        presentationRevision: PresentationRevision(rawValue: frameRevision)
    )
    guard interaction.committedRecordCount == 3,
        interaction.committedRevision?.rawValue == frameRevision,
        interaction.committedRecord(at: 0)?.action.code
            == (model.acquisitionState == .running ? 1 : 0),
        interaction.committedRecord(at: 2)?.action.code
            == (model.visibleWindowRawValue == 0 ? 4 : 5)
    else { return 0 }
    if !validation {
        giftUIStaticLastSemanticScopes = UInt32(semantic.scopeCount)
        giftUIStaticLastLayoutScopes = UInt32(resolved.scopeCount)
        giftUIStaticLastDrawingStrokes = UInt32(summary.strokeCount)
        giftUIStaticLastDrawingPoints = UInt32(summary.pointCount)
        giftUIStaticLastRenderOperations = UInt32(renderHeader.operationCount)
        gestures.installPhysicalPresentation(
            PresentationRevision(rawValue: frameRevision)
        )
        model.clearDirtyAfterPublication()
        return 1
    }
    guard
        interaction.build(
            occurrences: actions,
            targetGeneration: ObservableTargetGeneration(rawValue: 0)
        ), interaction.candidateIsReadyForOffer
    else { return 0 }
    interaction.resolve(
        accepted: false,
        presentationRevision: PresentationRevision(rawValue: 2)
    )
    guard interaction.committedRecordCount == 3,
        interaction.committedRevision?.rawValue == 1
    else { return 0 }
    guard
        var refusingSink = StaticSignalAnalyzerNRFEmbeddedRasterSink(
            rasterRegion: UnsafeMutableRawBufferPointer(
                start: raster, count: Int(rasterBytes)
            ),
            coverageRegion: UnsafeMutableRawBufferPointer(
                start: coverage, count: Int(coverageBytes)
            ), write: giftUISignalAnalyzerRefuseRGB565
        ),
        case .failure(.invariantViolation) =
            StaticSignalAnalyzerNRFEmbeddedRenderPreflight.streamCombined(
                semantic: semantic, layout: resolved,
                textRegion: UnsafeMutableRawBufferPointer(
                    start: profile.advanced(by: 9_184), count: 4_704
                ), drawing: drawing, expectedHeader: renderHeader,
                sink: &refusingSink
            ), !refusingSink.isFinished
    else { return 0 }
    var occurrence: UInt16 = 1
    while occurrence < 5 {
        guard let identity = source.canvasIdentity(at: occurrence),
            let stroke = drawing.strokeHeader(of: identity, at: 0),
            stroke.color == .green,
            stroke.pointCount == 2,
            stroke.subpathCount == 1,
            drawing.point(of: identity, stroke: 0, at: 0) != nil,
            drawing.point(of: identity, stroke: 0, at: 1) != nil
        else { return 0 }
        occurrence += 1
    }
    return 1
}

@inline(never)
private func giftUIStaticValidateUpdatedCanvas(
    semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView,
    drawing: inout StaticSignalAnalyzerNRFDrawingWorkspace,
    limits: DrawingLimits, profile: UnsafeMutableRawPointer,
    capture: UnsafeMutableRawPointer, captureBytes: UInt32,
    raster: UnsafeMutableRawPointer, rasterBytes: UInt32,
    coverage: UnsafeMutableRawPointer, coverageBytes: UInt32,
    model: inout StaticSignalAnalyzerNRFModelLocation,
    fullEndpoint: inout StaticSignalAnalyzerNRFEmbeddedEndpoint,
    layoutWorkspace: inout StaticSignalAnalyzerNRFCommonLayoutWorkspace,
    resolved: StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView
) -> UInt32 {
    drawing.reset()
    layoutWorkspace.packed.reset()
    let captureRegion = UnsafeMutableRawBufferPointer(
        start: capture, count: Int(captureBytes)
    )
    guard
        var regions = StaticSignalAnalyzerNRFCaptureRegions(
            storage: captureRegion
        ),
        let transition = StaticSignalAnalyzerNRFCaptureRecord(
            SignalTransition(
                channelID: SignalChannelID(rawValue: 1),
                timestamp: .seconds(1), level: .high
            )
        ), regions.store(transition, in: .admission, at: 0),
        let snapshot = StaticSignalAnalyzerNRFCaptureSnapshotView(
            storage: captureRegion,
            revision: 1, count: 1, duration: .seconds(1),
            retainedLowerBound: .zero, baselineLevels: .allLow
        ), model.beginMutation(),
        model.installCaptureSnapshot(snapshot, in: &regions),
        model.endMutation(),
        let updatedLayout = StaticSignalAnalyzerNRFCommonLayoutPass.run(
            semantic: semantic, workspace: &layoutWorkspace
        ),
        var updatedSource = StaticSignalAnalyzerNRFEmbeddedCanvasSource(
            semantic: semantic, model: model, captureRegion: captureRegion,
            callableRegion: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 13_888), count: 160
            )
        )
    else { return 0 }
    let updatedResult = giftUIStaticDeriveCanvas(
        source: &updatedSource, layout: updatedLayout,
        executionContext: ExecutionContext(
            cycle: RunCycleID(rawValue: 2),
            semanticRevision: SemanticRevision(rawValue: semantic.revision),
            candidateFrame: nil, phase: .deriving
        ), limits: limits, workspace: &drawing
    )
    guard case .success(let updatedSummary) = updatedResult,
        updatedSource.allReleased,
        updatedSummary.canvasOccurrenceCount == 5,
        updatedSummary.strokeCount == 5,
        updatedSummary.pointCount == 34,
        updatedSummary.subpathCount == 16,
        let traceID = updatedSource.canvasIdentity(at: 1),
        let traceBounds = updatedLayout.bounds(of: traceID),
        let trace = drawing.strokeHeader(of: traceID, at: 0),
        trace.pointCount == 4,
        let leading = drawing.point(of: traceID, stroke: 0, at: 1),
        let rising = drawing.point(of: traceID, stroke: 0, at: 2),
        leading.x == traceBounds.origin.x + traceBounds.size.width / 2,
        rising.x == leading.x,
        leading.y > rising.y,
        case .success(let updatedRenderHeader) =
            StaticSignalAnalyzerNRFEmbeddedRenderPreflight.runCombined(
                semantic: semantic, layout: updatedLayout,
                textRegion: UnsafeMutableRawBufferPointer(
                    start: profile.advanced(by: 9_184), count: 4_704
                ), drawing: drawing
            ), updatedRenderHeader.operationCount <= 150,
        updatedRenderHeader.positionedGlyphCount == 86
    else { return 0 }
    var sink = StaticSignalAnalyzerNRFEmbeddedCountingSink()
    guard
        case .success(let updatedStreamedHeader) =
            StaticSignalAnalyzerNRFEmbeddedRenderPreflight.streamCombined(
                semantic: semantic, layout: updatedLayout,
                textRegion: UnsafeMutableRawBufferPointer(
                    start: profile.advanced(by: 9_184), count: 4_704
                ), drawing: drawing, expectedHeader: updatedRenderHeader,
                sink: &sink
            ), updatedStreamedHeader == updatedRenderHeader,
        sink.isFinished, !sink.wasDiscarded,
        sink.strokeCount == 5,
        sink.glyphCount == 86
    else { return 0 }
    guard
        var updatedRasterSink = StaticSignalAnalyzerNRFEmbeddedRasterSink(
            rasterRegion: UnsafeMutableRawBufferPointer(
                start: raster, count: Int(rasterBytes)
            ),
            coverageRegion: UnsafeMutableRawBufferPointer(
                start: coverage, count: Int(coverageBytes)
            ), write: giftUISignalAnalyzerProbeRGB565
        ),
        case .success(let updatedRasterHeader) =
            StaticSignalAnalyzerNRFEmbeddedRenderPreflight.streamCombined(
                semantic: semantic, layout: updatedLayout,
                textRegion: UnsafeMutableRawBufferPointer(
                    start: profile.advanced(by: 9_184), count: 4_704
                ), drawing: drawing, expectedHeader: updatedRenderHeader,
                sink: &updatedRasterSink
            ), updatedRasterHeader == updatedRenderHeader,
        updatedRasterSink.isFinished,
        updatedRasterSink.paintedPixels > 0,
        updatedRasterSink.tileVisits > 0,
        updatedRasterSink.submittedRuns > 0,
        updatedRasterSink.submittedBytes > 0
    else { return 0 }
    let secondProvenance = FrameProvenance(
        cycle: RunCycleID(rawValue: 2),
        semanticRevision: SemanticRevision(rawValue: semantic.revision),
        candidateFrame: CandidateFrameID(rawValue: 2)
    )
    guard
        fullEndpoint.replaceEnvelopeValidator(
            StaticSignalAnalyzerNRFEmbeddedProbeEnvelope(
                expected: secondProvenance
            )
        ),
        giftUIStaticEmbeddedOffer(
            endpoint: &fullEndpoint,
            provenance: secondProvenance,
            semantic: semantic, layout: updatedLayout,
            textRegion: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 9_184), count: 4_704
            ), drawing: drawing, expectedHeader: updatedRenderHeader
        ), fullEndpoint.bodyCallCount == 2,
        fullEndpoint.reservationCallCount == 2
    else { return 0 }
    drawing.reset()
    layoutWorkspace.packed.reset()
    captureRegion.initializeMemory(as: UInt8.self, repeating: 0)
    return resolved.isPublished || drawing.isActive ? 0 : 1
}

@_cdecl("giftui_signal_analyzer_probe_rgb565")
public func giftUISignalAnalyzerProbeRGB565(
    _ x: UInt16, _ y: UInt16, _ width: UInt16, _ height: UInt16,
    _ pixels: UnsafePointer<UInt8>?, _ byteCount: Int
) -> Int32 {
    guard x < 320, y < 240, width > 0, height == 1,
        UInt32(x) + UInt32(width) <= 320,
        byteCount == Int(width) * 2, pixels != nil
    else { return -1 }
    return 0
}

@_cdecl("giftui_signal_analyzer_refuse_rgb565")
public func giftUISignalAnalyzerRefuseRGB565(
    _ x: UInt16, _ y: UInt16, _ width: UInt16, _ height: UInt16,
    _ pixels: UnsafePointer<UInt8>?, _ byteCount: Int
) -> Int32 {
    _ = x
    _ = y
    _ = width
    _ = height
    _ = pixels
    _ = byteCount
    return -1
}

@_cdecl("giftui_signal_analyzer_tile_valid")
public func giftUISignalAnalyzerTileValid(
    _ raster: UnsafeMutableRawPointer?, _ rasterBytes: UInt32,
    _ coverage: UnsafeMutableRawPointer?, _ coverageBytes: UInt32
) -> UInt32 {
    guard let raster, rasterBytes == 2_560,
        let coverage, coverageBytes == 160,
        let surface = Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 320, height: 240)!
        ),
        let descriptor = RasterSurfaceDescriptor(
            bounds: surface, encoding: .rgb565BigEndian,
            bytesPerRow: 640, realization: .tiled,
            regionWidth: 320, regionHeight: 4
        ),
        let storage = StaticSignalAnalyzerNRFTileStorage(
            region: UnsafeMutableRawBufferPointer(
                start: raster, count: Int(rasterBytes)
            ),
            coverage: UnsafeMutableRawBufferPointer(
                start: coverage, count: Int(coverageBytes)
            )
        ),
        var tile = RGB565TileWorkspace(descriptor: descriptor, storage: storage),
        let first = Rect(
            origin: Point(x: 0, y: 0), size: Size(width: 320, height: 4)!
        ),
        let second = Rect(
            origin: Point(x: 0, y: 4), size: Size(width: 320, height: 4)!
        ),
        let third = Rect(
            origin: Point(x: 0, y: 8), size: Size(width: 320, height: 4)!
        ),
        tile.beginTile(first),
        tile.replacePixel(
            at: Point(x: 0, y: 0),
            with: CanonicalEncodedPixel(color: .white, encoding: .rgb565BigEndian)
        ),
        tile.replacePixel(
            at: Point(x: 319, y: 3),
            with: CanonicalEncodedPixel(color: .black, encoding: .rgb565BigEndian)
        ),
        tile.storage.byte(at: 0) == 0xff,
        tile.storage.byte(at: 1) == 0xff,
        tile.storage.isAffected(pixelIndex: 0),
        tile.storage.isAffected(pixelIndex: 1279),
        !tile.storage.isAffected(pixelIndex: 1278),
        tile.finishTile(),
        tile.beginTile(second),
        !tile.storage.isAffected(pixelIndex: 0),
        !tile.storage.isAffected(pixelIndex: 1279),
        tile.storage.byte(at: 0) == 0,
        tile.storage.byte(at: 1) == 0
    else { return 0 }
    let fillResult = RasterFillCoverage.rasterize(
        FillRectOperation(
            bounds: Rect(
                origin: Point(x: 1, y: 4),
                size: Size(width: 3, height: 2)!
            )!,
            clip: second,
            color: .white
        ), descriptor: descriptor, damageBounds: second
    ) { point, pixel in tile.replacePixel(at: point, with: pixel) }
    guard fillResult == .completed(pixelCount: 6),
        tile.storage.isAffected(pixelIndex: 1),
        tile.storage.isAffected(pixelIndex: 323),
        !tile.storage.isAffected(pixelIndex: 0),
        tile.storage.byte(at: 2) == 0xff,
        tile.storage.byte(at: 3) == 0xff
    else { return 0 }
    let stroke = StaticSignalAnalyzerNRFTileProbeStroke(clip: second)
    let strokeResult = RasterStrokeCoverage.rasterize(
        stroke, descriptor: descriptor, damageBounds: second
    ) { point, pixel in tile.replacePixel(at: point, with: pixel) }
    guard case .completed(let strokePixels) = strokeResult,
        strokePixels > 0,
        tile.finishTile(),
        tile.beginTile(third),
        let realization = StaticSignalAnalyzerNRFEmbeddedFontRaster().realization(
            at: 0
        )
    else { return 0 }
    let glyphResult = RasterGlyphCoverage.rasterize(
        PositionedGlyph(
            glyph: GlyphID(rawValue: 1), baseline: Point(x: 10, y: 20)
        ),
        operation: PositionedGlyphOperationHeader(
            instance: StaticSignalAnalyzerNRFEmbeddedFontMetrics().instance(at: 0)!.id, clip: third,
            color: .white, glyphCount: 1
        ),
        metrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
        raster: StaticSignalAnalyzerNRFEmbeddedFontRaster(),
        realization: realization, descriptor: descriptor,
        damageBounds: third
    ) { point, pixel in tile.replacePixel(at: point, with: pixel) }
    guard case .completed(let glyphPixels, let payloadBytes) = glyphResult,
        glyphPixels > 0, payloadBytes == 24,
        tile.finishTile()
    else { return 0 }
    guard
        let fourth = Rect(
            origin: Point(x: 0, y: 12), size: Size(width: 320, height: 4)!
        ),
        let small = Rect(
            origin: Point(x: 0, y: 12), size: Size(width: 2, height: 2)!
        )
    else { return 0 }
    var consumedTiles: UInt32 = 0
    var consumedRuns: UInt32 = 0
    let traversal = OperationMajorTileTraversal.visit(
        operationClip: small, damageBounds: fourth, workspace: &tile,
        { damage, replace in
            RasterFillCoverage.rasterize(
                FillRectOperation(bounds: small, clip: small, color: .white),
                descriptor: descriptor, damageBounds: damage, replace
            ) == .completed(pixelCount: 4)
        },
        { workspace in
            guard workspace.storage.isAffected(pixelIndex: 0),
                workspace.storage.isAffected(pixelIndex: 321),
                let emitted = StaticSignalAnalyzerNRFEmbeddedTileRuns.emit(
                    workspace,
                    { x, y, pixels, bytes in
                        guard x == 0, UInt32(y) == 12 + consumedRuns,
                            pixels == 2, bytes.count == 4,
                            bytes[0] == 0xff, bytes[1] == 0xff,
                            bytes[2] == 0xff, bytes[3] == 0xff
                        else { return false }
                        consumedRuns += 1
                        return true
                    }
                ), emitted.runCount == 2, emitted.byteCount == 8
            else { return false }
            consumedTiles += 1
            return true
        }
    )
    guard traversal == .completed(tileVisits: 1), consumedTiles == 1,
        consumedRuns == 2,
        tile.activeTile == nil
    else { return 0 }
    let transport = StaticSignalAnalyzerNRFSPITFTTransport(
        write: giftUISignalAnalyzerProbeRGB565
    )
    guard
        var target = StaticSignalAnalyzerNRFDisplayTarget(
            transport: transport,
            rasterRegion: UnsafeMutableRawBufferPointer(
                start: raster, count: Int(rasterBytes)
            )
        )
    else { return 0 }
    let reservation: DisplayReservationID
    switch target.reserveFrame(
        descriptor: descriptor, payloadCapacityBytes: 2_560,
        regionCapacity: 1
    ) {
    case .reserved(let value): reservation = value
    default: return 0
    }
    let written = target.withWriter(for: reservation) { writer in
        guard
            writer.beginRegion(
                origin: Point(x: 0, y: 0), pixelCount: 2,
                encoding: .rgb565BigEndian
            ), writer.write(byte: 0xff), writer.write(byte: 0xff),
            writer.write(byte: 0), writer.write(byte: 0),
            writer.endRegion(), writer.finish()
        else { return false }
        return true
    }
    guard written == true,
        target.submitPayload(reservation) == .completed,
        target.finishFrame(reservation) == .completed
    else { return 0 }
    let refusingTransport = StaticSignalAnalyzerNRFSPITFTTransport(
        write: giftUISignalAnalyzerRefuseRGB565
    )
    guard
        var refusingTarget = StaticSignalAnalyzerNRFDisplayTarget(
            transport: refusingTransport,
            rasterRegion: UnsafeMutableRawBufferPointer(
                start: raster, count: Int(rasterBytes)
            )
        )
    else { return 0 }
    let refusingReservation: DisplayReservationID
    switch refusingTarget.reserveFrame(
        descriptor: descriptor, payloadCapacityBytes: 2_560,
        regionCapacity: 1
    ) {
    case .reserved(let value): refusingReservation = value
    default: return 0
    }
    let refusalWritten = refusingTarget.withWriter(
        for: refusingReservation
    ) { writer in
        guard
            writer.beginRegion(
                origin: Point(x: 0, y: 0), pixelCount: 1,
                encoding: .rgb565BigEndian
            ), writer.write(byte: 0xff), writer.write(byte: 0xff),
            writer.endRegion(), writer.finish()
        else { return false }
        return true
    }
    guard refusalWritten == true,
        refusingTarget.submitPayload(refusingReservation)
            == .failureAfterAcceptance(.transportUnavailable),
        refusingTarget.finishFrame(refusingReservation) == .completed,
        refusingTarget.reserveFrame(
            descriptor: descriptor, payloadCapacityBytes: 2_560,
            regionCapacity: 1
        ) == .nonRetryableRefusal
    else { return 0 }
    guard
        let sessionTarget = StaticSignalAnalyzerNRFDisplayTarget(
            transport: StaticSignalAnalyzerNRFSPITFTTransport(
                write: giftUISignalAnalyzerProbeRGB565
            ),
            rasterRegion: UnsafeMutableRawBufferPointer(
                start: raster, count: Int(rasterBytes)
            )
        ),
        let sessionStorage = StaticSignalAnalyzerNRFTileStorage(
            region: UnsafeMutableRawBufferPointer(
                start: raster, count: Int(rasterBytes)
            ),
            coverage: UnsafeMutableRawBufferPointer(
                start: coverage, count: Int(coverageBytes)
            )
        ),
        let payloadLimits = RasterPayloadLimits(
            maximumRasterBytes: 2_560, maximumPayloadBytes: 2_560,
            maximumRegionsPerPayload: 1,
            maximumRegionSubmissionsPerFrame: 11_520_000,
            maximumTileVisitsPerFrame: 12_000,
            maximumInFlightPayloads: 1,
            maximumGlyphRasterBytes: 2_560,
            maximumStrokeWorkspaceBytes: 2_560
        ),
        var session = OperationMajorRGB565RasterSession(
            capacity: RenderSinkCapacity(
                maximumOperations: 150, maximumPositionedGlyphs: 224
            ), descriptor: descriptor, payloadLimits: payloadLimits,
            metrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
            raster: StaticSignalAnalyzerNRFEmbeddedFontRaster(),
            realization: RasterRealizationID(rawValue: 0),
            storage: sessionStorage, target: sessionTarget
        )
    else { return 0 }
    let sessionReservation: DisplayReservationID
    switch session.reserveFrame(
        descriptor: descriptor, payloadCapacityBytes: 2_560,
        regionCapacity: 1
    ) {
    case .reserved(let value): sessionReservation = value
    default: return 0
    }
    guard
        session.begin(
            RenderPlanHeader(
                surfaceBounds: surface, damageBounds: small,
                operationCount: 1, positionedGlyphCount: 0,
                maximumObservedClipDepth: 0
            )
        ),
        session.fillRect(
            FillRectOperation(bounds: small, clip: small, color: .white)
        ), session.finish(), session.streamCompleted,
        session.failure == nil,
        session.isIdleForOffer
    else { return 0 }
    _ = sessionReservation
    let provenance = FrameProvenance(
        cycle: RunCycleID(rawValue: 1),
        semanticRevision: SemanticRevision(rawValue: 1),
        candidateFrame: CandidateFrameID(rawValue: 1)
    )
    guard let effective = StaticSignalAnalyzerNRFEmbeddedCapabilitySelection.effective else {
        return 0
    }
    guard
        var endpoint = OneShotRasterBackendEndpoint(
            effectivePresentation: effective,
            descriptor: descriptor,
            payloadLimits: payloadLimits,
            textMetrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
            textRaster: StaticSignalAnalyzerNRFEmbeddedFontRaster(),
            textRasterRealization: RasterRealizationID(rawValue: 0),
            envelopeValidator: StaticSignalAnalyzerNRFEmbeddedProbeEnvelope(
                expected: provenance
            ),
            sink: session,
            startupFailure: nil
        )
    else { return 0 }
    let wrong = FrameProvenance(
        cycle: RunCycleID(rawValue: 2),
        semanticRevision: SemanticRevision(rawValue: 1),
        candidateFrame: CandidateFrameID(rawValue: 1)
    )
    guard
        endpoint.offer(provenance: wrong, body: { _ in .complete })
            == FrameOfferResult(
                disposition: .failed, failure: .invalidEnvelope
            ), endpoint.bodyCallCount == 0
    else { return 0 }
    let offer = endpoint.offer(provenance: provenance) { sink in
        guard
            sink.begin(
                RenderPlanHeader(
                    surfaceBounds: surface, damageBounds: small,
                    operationCount: 1, positionedGlyphCount: 0,
                    maximumObservedClipDepth: 0
                )
            ),
            sink.fillRect(
                FillRectOperation(bounds: small, clip: small, color: .white)
            ), sink.finish()
        else { return .contractViolation }
        return .complete
    }
    guard offer == FrameOfferResult(disposition: .accepted, failure: nil),
        endpoint.bodyCallCount == 1,
        endpoint.reservationCallCount == 1,
        endpoint.sink.isIdleForOffer
    else { return 0 }
    return 1
}

private typealias StaticSignalAnalyzerNRFEmbeddedDisplay =
    StaticSignalAnalyzerNRFDisplayTarget<StaticSignalAnalyzerNRFSPITFTTransport>

private typealias StaticSignalAnalyzerNRFEmbeddedSession =
    OperationMajorRGB565RasterSession<
        StaticSignalAnalyzerNRFTileStorage,
        StaticSignalAnalyzerNRFEmbeddedDisplay,
        StaticSignalAnalyzerNRFEmbeddedFontMetrics,
        StaticSignalAnalyzerNRFEmbeddedFontRaster
    >

private typealias StaticSignalAnalyzerNRFEmbeddedEndpoint =
    OneShotRasterBackendEndpoint<
        StaticSignalAnalyzerNRFEmbeddedSession,
        StaticSignalAnalyzerNRFEmbeddedFontMetrics,
        StaticSignalAnalyzerNRFEmbeddedFontRaster,
        StaticSignalAnalyzerNRFEmbeddedProbeEnvelope
    >

@inline(never)
private func giftUIStaticEmbeddedEndpoint(
    raster: UnsafeMutableRawPointer,
    coverage: UnsafeMutableRawPointer,
    provenance: FrameProvenance,
    write: StaticSignalAnalyzerNRFEmbeddedPixelWrite
) -> StaticSignalAnalyzerNRFEmbeddedEndpoint? {
    guard
        let surface = Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 320, height: 240)!
        ),
        let descriptor = RasterSurfaceDescriptor(
            bounds: surface, encoding: .rgb565BigEndian,
            bytesPerRow: 640, realization: .tiled,
            regionWidth: 320, regionHeight: 4
        ),
        let storage = StaticSignalAnalyzerNRFTileStorage(
            region: UnsafeMutableRawBufferPointer(start: raster, count: 2_560),
            coverage: UnsafeMutableRawBufferPointer(start: coverage, count: 160)
        ),
        let target = StaticSignalAnalyzerNRFDisplayTarget(
            transport: StaticSignalAnalyzerNRFSPITFTTransport(write: write),
            rasterRegion: UnsafeMutableRawBufferPointer(start: raster, count: 2_560)
        ),
        let limits = RasterPayloadLimits(
            maximumRasterBytes: 2_560, maximumPayloadBytes: 2_560,
            maximumRegionsPerPayload: 1,
            maximumRegionSubmissionsPerFrame: 11_520_000,
            maximumTileVisitsPerFrame: 12_000,
            maximumInFlightPayloads: 1,
            maximumGlyphRasterBytes: 2_560,
            maximumStrokeWorkspaceBytes: 2_560
        ),
        let session = StaticSignalAnalyzerNRFEmbeddedSession(
            capacity: RenderSinkCapacity(
                maximumOperations: 150, maximumPositionedGlyphs: 224
            ), descriptor: descriptor, payloadLimits: limits,
            metrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
            raster: StaticSignalAnalyzerNRFEmbeddedFontRaster(),
            realization: RasterRealizationID(rawValue: 0),
            storage: storage, target: target
        )
    else { return nil }
    guard let effective = StaticSignalAnalyzerNRFEmbeddedCapabilitySelection.effective else {
        return nil
    }
    return StaticSignalAnalyzerNRFEmbeddedEndpoint(
        effectivePresentation: effective, descriptor: descriptor,
        payloadLimits: limits,
        textMetrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
        textRaster: StaticSignalAnalyzerNRFEmbeddedFontRaster(),
        textRasterRealization: RasterRealizationID(rawValue: 0),
        envelopeValidator: StaticSignalAnalyzerNRFEmbeddedProbeEnvelope(
            expected: provenance
        ), sink: session, startupFailure: nil
    )
}

@inline(never)
private func giftUIStaticEmbeddedOffer(
    endpoint: inout StaticSignalAnalyzerNRFEmbeddedEndpoint,
    provenance: FrameProvenance,
    semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView,
    layout: StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView,
    textRegion: UnsafeMutableRawBufferPointer,
    drawing: StaticSignalAnalyzerNRFDrawingWorkspace,
    expectedHeader: RenderPlanHeader
) -> Bool {
    let result = endpoint.offer(provenance: provenance) { sink in
        switch StaticSignalAnalyzerNRFEmbeddedRenderPreflight.streamCombined(
            semantic: semantic, layout: layout,
            textRegion: textRegion, drawing: drawing,
            expectedHeader: expectedHeader, sink: &sink
        ) {
        case .success(let header):
            return header == expectedHeader ? .complete : .contractViolation
        case .failure(let error):
            sink.retainProducerError(error)
            switch error {
            case .capacityExhausted: return .insufficientCapacity
            case .sinkRefused: return .endpointRefused
            default: return .producerFailed
            }
        }
    }
    return result == FrameOfferResult(disposition: .accepted, failure: nil)
        && endpoint.sink.failure == nil
        && endpoint.health().state == .available
}

private struct StaticSignalAnalyzerNRFEmbeddedProbeEnvelope:
    RasterFrameEnvelopeValidator
{
    let expected: FrameProvenance

    borrowing func accepts(_ provenance: FrameProvenance) -> Bool {
        provenance == expected
    }
}

private struct StaticSignalAnalyzerNRFTileProbeStroke: StraightLineStrokeView {
    let header: StraightLineStrokeHeader

    init(clip: Rect) {
        header = StraightLineStrokeHeader(
            color: .black, lineWidth: 1, lineCap: .butt,
            lineJoin: .miter, surfaceOrigin: Point(x: 0, y: 0),
            inheritedClip: clip, pointCount: 2, subpathCount: 1
        )
    }

    func point(at index: UInt16) -> Point? {
        switch index {
        case 0: Point(x: 1, y: 4)
        case 1: Point(x: 6, y: 4)
        default: nil
        }
    }

    func subpath(at index: UInt16) -> SubpathRange? {
        index == 0 ? SubpathRange(firstPoint: 0, pointCount: 2) : nil
    }
}

@_cdecl("giftui_signal_analyzer_source_valid")
public func giftUISignalAnalyzerSourceValid() -> UInt32 {
    var source = StaticSignalAnalyzerNRFDeterministicSource()
    guard source.start() == 1 else { return 0 }
    for channel in UInt8(1) ... 4 {
        guard let initial = source.takeInitialTransition(),
            initial.channelID.rawValue == Int(channel),
            initial.timestamp == .zero,
            initial.level == .low
        else { return 0 }
    }
    guard source.nextScheduledDelayMilliseconds == 80,
        let first = source.deliverScheduledTransition(generation: 1),
        first.channelID.rawValue == 3,
        first.timestamp == .milliseconds(80), first.level == .high
    else { return 0 }
    source.stop()
    guard source.deliverScheduledTransition(generation: 1) == nil,
        source.start() == 2,
        source.takeInitialTransition() == nil
    else { return 0 }
    source.shutdown()
    return source.start() == nil ? 1 : 0
}

@_cdecl("giftui_signal_analyzer_diagnostic_value_valid")
public func giftUISignalAnalyzerDiagnosticValueValid() -> UInt32 {
    guard SignalAnalyzerDiagnostic.maximumUTF8ByteCount == 96,
        giftUIStaticSampleDiagnostic()?.utf8ByteCount == 3
    else { return 0 }
    return 1
}

private func giftUIStaticSampleDiagnostic() -> SignalAnalyzerDiagnostic? {
    var bytes: (UInt8, UInt8, UInt8) = (0x45, 0x52, 0x52)
    return withUnsafeBytes(of: &bytes) { raw in
        let utf8 = raw.bindMemory(to: UInt8.self)
        return SignalAnalyzerDiagnostic(exactUTF8: utf8)
    }
}

@_cdecl("giftui_signal_analyzer_capture_layout")
public func giftUISignalAnalyzerCaptureLayout() -> UInt32 {
    let recordSize = MemoryLayout<StaticSignalAnalyzerNRFCaptureRecord>.size
    let recordStride = MemoryLayout<StaticSignalAnalyzerNRFCaptureRecord>.stride
    return recordSize == 16 && recordStride == 16
        && StaticSignalAnalyzerNRFCaptureRegions.requiredByteCount == 115_392
        ? 115_392 : 0
}

@_cdecl("giftui_signal_analyzer_capture_roundtrip")
public func giftUISignalAnalyzerCaptureRoundtrip() -> UInt32 {
    let transition = SignalTransition(
        channelID: SignalChannelID(rawValue: 4),
        timestamp: .milliseconds(125),
        level: .high
    )
    guard let record = StaticSignalAnalyzerNRFCaptureRecord(transition),
        record.transition == transition
    else { return 0 }
    return 1
}

@_cdecl("giftui_signal_analyzer_compact_fact_valid")
public func giftUISignalAnalyzerCompactFactValid() -> UInt32 {
    let transition = SignalTransition(
        channelID: SignalChannelID(rawValue: 4),
        timestamp: .milliseconds(125), level: .high
    )
    let change = SignalCaptureChange.insertAndTrim(
        baseRevision: 7, insertionIndex: 1,
        transition: transition, evictedPrefixCount: 0,
        duration: .seconds(2), retainedLowerBound: .zero,
        baselines: .allLow
    )
    guard MemoryLayout<StaticSignalAnalyzerNRFCompactCaptureFact>.size == 64,
        MemoryLayout<StaticSignalAnalyzerNRFCompactCaptureFact>.stride == 64,
        let fact = StaticSignalAnalyzerNRFCompactCaptureFact(
            sequence: 3, revision: 8, change: change
        ), fact.sequence == 3,
        fact.publication?.revision == 8,
        fact.publication?.change == change
    else { return 0 }
    return 1
}

@_cdecl("giftui_signal_analyzer_presentation_fact_layout_valid")
public func giftUISignalAnalyzerPresentationFactLayoutValid() -> UInt32 {
    guard MemoryLayout<StaticSignalAnalyzerNRFCompactPresentationFact>.stride <= 112,
        let diagnostic = giftUIStaticSampleDiagnostic(),
        let fact = StaticSignalAnalyzerNRFCompactPresentationFact(
            sequence: 1, payload: .acquisitionState(.failed(diagnostic))
        )
    else { return 0 }
    if case .acquisitionState(.failed(let retained)) = fact.payload,
        retained == diagnostic
    {
        return 1
    }
    return 0
}

@_cdecl("giftui_signal_analyzer_compact_ring_valid")
public func giftUISignalAnalyzerCompactRingValid(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32
) -> UInt32 {
    guard let profile, bytes == 39_696 else { return 0 }
    let storage = UnsafeMutableRawBufferPointer(start: profile, count: Int(bytes))
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            activeStorage: UnsafeMutableRawBufferPointer(
                rebasing: storage[31_632 ..< 35_472]
            ),
            sealedStorage: UnsafeMutableRawBufferPointer(
                rebasing: storage[35_472 ..< 39_312]
            )
        )
    else { return 0 }
    let change = SignalCaptureChange.reset(baseRevision: 0, baselines: .allLow)
    guard admission.beginProducer(.bootstrap),
        admission.admitCaptureMutation(revision: 1, change: change)
            == .accepted(sequence: 1)
    else { return 0 }
    admission.endProducer()
    guard admission.seal(), admission.pendingCompactCount == 0,
        admission.sealedCompactCount == 1,
        admission.takeNextSealed()?.captureMutation?.change == change,
        admission.sealedCompactCount == 0
    else { return 0 }
    guard let diagnostic = giftUIStaticSampleDiagnostic(),
        admission.admitOperationalFailure(
            conditionRawValue: 5, originRawValue: 9,
            affectedScopeRawValue: 4, containmentRawValue: 1,
            diagnostic: diagnostic
        ) == .accepted(sequence: 2),
        admission.seal(), admission.sealedOperationalFailureCount == 1,
        admission.takeNextSealed()?.operationalFailure?.diagnostic == diagnostic,
        admission.sealedOperationalFailureCount == 0
    else { return 0 }
    return 1
}

@_cdecl("giftui_signal_analyzer_snapshot_admission_valid")
public func giftUISignalAnalyzerSnapshotAdmissionValid(
    _ profile: UnsafeMutableRawPointer?, _ profileBytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32
) -> UInt32 {
    guard let profile, let capture, profileBytes == 39_696,
        captureBytes == 115_392,
        MemoryLayout<StaticSignalAnalyzerNRFSnapshotFact>.stride <= 48
    else { return 0 }
    let profileStorage = UnsafeMutableRawBufferPointer(
        start: profile, count: Int(profileBytes)
    )
    let captureStorage = UnsafeMutableRawBufferPointer(
        start: capture, count: Int(captureBytes)
    )
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            activeStorage: UnsafeMutableRawBufferPointer(
                rebasing: profileStorage[31_632 ..< 35_472]
            ),
            sealedStorage: UnsafeMutableRawBufferPointer(
                rebasing: profileStorage[35_472 ..< 39_312]
            )
        ),
        let view = StaticSignalAnalyzerNRFCaptureSnapshotView(
            storage: captureStorage, revision: 0, count: 0,
            duration: .zero, retainedLowerBound: .zero,
            baselineLevels: .allLow
        ), admission.beginProducer(.bootstrap), admission.canAdmitSnapshot,
        admission.admitSnapshot(view) == .accepted(sequence: 1)
    else { return 0 }
    admission.endProducer()
    guard admission.seal(), admission.sealedSnapshotCount == 1,
        admission.takeNextSealed()?.sequence == 1,
        admission.sealedSnapshotCount == 0
    else { return 0 }
    return 1
}

@_cdecl("giftui_signal_analyzer_capture_region_valid")
public func giftUISignalAnalyzerCaptureRegionValid(
    _ address: UnsafeMutableRawPointer?, _ bytes: UInt32
) -> UInt32 {
    guard address != nil, bytes == 115_392 else { return 0 }
    let region = UnsafeMutableRawBufferPointer(start: address, count: Int(bytes))
    guard let capture = StaticSignalAnalyzerNRFCaptureRegions(storage: region) else {
        return 0
    }
    _ = consume capture
    return 1
}

@_cdecl("giftui_signal_analyzer_capture_history_valid")
public func giftUISignalAnalyzerCaptureHistoryValid(
    _ capture: UnsafeMutableRawPointer?, _ bytes: UInt32
) -> UInt32 {
    guard let capture, bytes == 115_392,
        var regions = StaticSignalAnalyzerNRFCaptureRegions(
            storage: UnsafeMutableRawBufferPointer(start: capture, count: Int(bytes))
        )
    else { return 0 }
    var generator = DeterministicSignalGenerator(seed: 0x5EED)
    var history = StaticSignalAnalyzerNRFCaptureHistory()
    let first = generator.nextTransition()
    guard case .accepted(revision: 1, change: _) = history.receive(first, in: &regions),
        history.count == 1,
        regions.load(from: .live, at: 0)?.transition == first,
        case .accepted(revision: 2, change: _) = history.clear(in: &regions),
        history.count == 0
    else { return 0 }
    return 1
}

@_cdecl("giftui_signal_analyzer_sealed_application_valid")
public func giftUISignalAnalyzerSealedApplicationValid(
    _ profile: UnsafeMutableRawPointer?, _ profileBytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32
) -> UInt32 {
    guard let profile, let capture, profileBytes == 39_696,
        captureBytes == 115_392,
        let diagnostic = giftUIStaticSampleDiagnostic()
    else { return 0 }
    let profileStorage = UnsafeMutableRawBufferPointer(
        start: profile, count: Int(profileBytes)
    )
    let captureStorage = UnsafeMutableRawBufferPointer(
        start: capture, count: Int(captureBytes)
    )
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            activeStorage: UnsafeMutableRawBufferPointer(
                rebasing: profileStorage[31_632 ..< 35_472]
            ),
            sealedStorage: UnsafeMutableRawBufferPointer(
                rebasing: profileStorage[35_472 ..< 39_312]
            )
        ),
        let snapshot = StaticSignalAnalyzerNRFCaptureSnapshotView(
            storage: captureStorage, revision: 0, count: 0,
            duration: .zero, retainedLowerBound: .zero,
            baselineLevels: .allLow
        ), admission.beginProducer(.bootstrap),
        admission.admitSnapshot(snapshot) == .accepted(sequence: 1),
        admission.admitAcquisitionState(.running) == .accepted(sequence: 2)
    else { return 0 }
    admission.endProducer()
    guard
        admission.admitOperationalFailure(
            conditionRawValue: 5, originRawValue: 9,
            affectedScopeRawValue: 4, containmentRawValue: 1,
            diagnostic: diagnostic
        ) == .accepted(sequence: 3)
    else { return 0 }
    return withUnsafeMutablePointer(to: &giftUIStaticModelLocation) { location in
        guard location.pointee.activate() != nil,
            location.pointee.applyAdmittedBatch(
                from: &admission, captureStorage: captureStorage
            ) == .applied(factCount: 3),
            location.pointee.acquisitionState == .failed(diagnostic)
        else { return 0 }
        location.pointee.retire()
        return 1
    }
}

@_cdecl("giftui_signal_analyzer_repository_producer_valid")
public func giftUISignalAnalyzerRepositoryProducerValid(
    _ profile: UnsafeMutableRawPointer?, _ profileBytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32
) -> UInt32 {
    guard let profile, let capture, profileBytes == 39_696,
        captureBytes == 115_392
    else { return 0 }
    let profileStorage = UnsafeMutableRawBufferPointer(
        start: profile, count: Int(profileBytes)
    )
    let captureStorage = UnsafeMutableRawBufferPointer(
        start: capture, count: Int(captureBytes)
    )
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            activeStorage: UnsafeMutableRawBufferPointer(
                rebasing: profileStorage[31_632 ..< 35_472]
            ),
            sealedStorage: UnsafeMutableRawBufferPointer(
                rebasing: profileStorage[35_472 ..< 39_312]
            )
        )
    else { return 0 }
    var repository = StaticSignalAnalyzerNRFRepositoryProducer()
    return withUnsafeMutablePointer(to: &giftUIStaticModelLocation) { location in
        guard let generation = location.pointee.activate() else { return 0 }
        guard
            repository.startObservation(
                admission: &admission, captureStorage: captureStorage
            ) == .accepted,
            location.pointee.applyAdmittedBatch(
                from: &admission, captureStorage: captureStorage
            ) == .applied(factCount: 2),
            StaticSignalAnalyzerNRFEmbeddedActionDispatcher.dispatch(
                actionCode: 0, modelGeneration: generation,
                model: &location.pointee, repository: &repository,
                admission: &admission, captureStorage: captureStorage
            ),
            repository.nextScheduledDelayMilliseconds == 80,
            repository.pollScheduled(
                admission: &admission, captureStorage: captureStorage
            ) == .accepted,
            location.pointee.applyAdmittedBatch(
                from: &admission, captureStorage: captureStorage
            ) == .applied(factCount: 1),
            location.pointee.capture.revision == 5,
            location.pointee.capture.count == 5,
            location.pointee.acquisitionState == .running,
            StaticSignalAnalyzerNRFEmbeddedActionDispatcher.dispatch(
                actionCode: 1, modelGeneration: generation,
                model: &location.pointee, repository: &repository,
                admission: &admission, captureStorage: captureStorage
            ),
            StaticSignalAnalyzerNRFEmbeddedActionDispatcher.dispatch(
                actionCode: 2, modelGeneration: generation,
                model: &location.pointee, repository: &repository,
                admission: &admission, captureStorage: captureStorage
            ),
            repository.start(
                admission: &admission, captureStorage: captureStorage
            ) == .accepted,
            location.pointee.applyAdmittedBatch(
                from: &admission, captureStorage: captureStorage
            ) == .applied(factCount: 1),
            location.pointee.capture.revision == 6,
            location.pointee.capture.count == 0,
            location.pointee.acquisitionState == .running
        else { return 0 }
        repository.shutdown()
        location.pointee.retire()
        return 1
    }
}

@_cdecl("giftui_signal_analyzer_revision_failure_valid")
public func giftUISignalAnalyzerRevisionFailureValid(
    _ profile: UnsafeMutableRawPointer?, _ profileBytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32
) -> UInt32 {
    guard let profile, let capture, profileBytes == 39_696,
        captureBytes == 115_392
    else { return 0 }
    let profileStorage = UnsafeMutableRawBufferPointer(
        start: profile, count: Int(profileBytes)
    )
    let captureStorage = UnsafeMutableRawBufferPointer(
        start: capture, count: Int(captureBytes)
    )
    guard
        var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
            activeStorage: UnsafeMutableRawBufferPointer(
                rebasing: profileStorage[31_632 ..< 35_472]
            ),
            sealedStorage: UnsafeMutableRawBufferPointer(
                rebasing: profileStorage[35_472 ..< 39_312]
            )
        )
    else { return 0 }
    var repository = StaticSignalAnalyzerNRFRepositoryProducer(initialRevision: .max)
    return withUnsafeMutablePointer(to: &giftUIStaticModelLocation) { location in
        guard location.pointee.activate() != nil,
            repository.startObservation(
                admission: &admission, captureStorage: captureStorage
            ) == .accepted,
            location.pointee.applyAdmittedBatch(
                from: &admission, captureStorage: captureStorage
            ) == .applied(factCount: 2),
            repository.start(
                admission: &admission, captureStorage: captureStorage
            ) == .terminalFailureAdmitted,
            location.pointee.applyAdmittedBatch(
                from: &admission, captureStorage: captureStorage
            ) == .applied(factCount: 2),
            repository.acquisitionState == location.pointee.acquisitionState,
            location.pointee.errorMessage?.utf8ByteCount == 26
        else { return 0 }
        repository.shutdown()
        location.pointee.retire()
        return 1
    }
}

@_cdecl("giftui_signal_analyzer_snapshot_view_valid")
public func giftUISignalAnalyzerSnapshotViewValid(
    _ address: UnsafeMutableRawPointer?, _ bytes: UInt32
) -> UInt32 {
    guard address != nil, bytes == 115_392 else { return 0 }
    let storage = UnsafeMutableRawBufferPointer(start: address, count: Int(bytes))
    let transition = SignalTransition(
        channelID: SignalChannelID(rawValue: 4),
        timestamp: .milliseconds(125),
        level: .high
    )
    do {
        guard var regions = StaticSignalAnalyzerNRFCaptureRegions(storage: storage),
            let record = StaticSignalAnalyzerNRFCaptureRecord(transition),
            regions.store(record, in: .admission, at: 0)
        else { return 0 }
    }
    guard
        let view = StaticSignalAnalyzerNRFCaptureSnapshotView(
            storage: storage, revision: 1, count: 1, duration: .milliseconds(125),
            retainedLowerBound: .zero, baselineLevels: .allLow
        ), view.transition(at: 0) == transition,
        view.visibleRange(window: .seconds(1)) == (.zero ..< .seconds(1))
    else { return 0 }
    return 1
}

@_cdecl("giftui_signal_analyzer_model_capture_replay_valid")
public func giftUISignalAnalyzerModelCaptureReplayValid(
    _ address: UnsafeMutableRawPointer?, _ bytes: UInt32
) -> UInt32 {
    guard address != nil, bytes == 115_392 else { return 0 }
    let storage = UnsafeMutableRawBufferPointer(start: address, count: Int(bytes))
    return withUnsafeMutablePointer(to: &giftUIStaticModelLocation) { location in
        guard location.pointee.activate() != nil,
            location.pointee.beginMutation()
        else { return 0 }
        guard var regions = StaticSignalAnalyzerNRFCaptureRegions(storage: storage)
        else { return 0 }
        do {
            guard
                let view = StaticSignalAnalyzerNRFCaptureSnapshotView(
                    storage: storage, revision: 1, count: 1,
                    duration: .milliseconds(125), retainedLowerBound: .zero,
                    baselineLevels: .allLow
                ), location.pointee.installCaptureSnapshot(view, in: &regions)
            else { return 0 }
        }
        let transition = SignalTransition(
            channelID: SignalChannelID(rawValue: 1),
            timestamp: .milliseconds(200), level: .low
        )
        let change = SignalCaptureChange.insertAndTrim(
            baseRevision: 1, insertionIndex: 1, transition: transition,
            evictedPrefixCount: 0, duration: .milliseconds(200),
            retainedLowerBound: .zero, baselines: .allLow
        )
        guard
            location.pointee.applyCaptureMutation(
                revision: 2, change: change, in: &regions
            ) == .applied(changed: true),
            location.pointee.capture.count == 2,
            location.pointee.visibleRange == (.zero ..< .seconds(2)),
            regions.load(from: .snapshot, at: 1)?.transition == transition,
            location.pointee.endMutation()
        else { return 0 }
        location.pointee.retire()
        return 1
    }
}

@_cdecl("giftui_signal_analyzer_region_map_valid")
public func giftUISignalAnalyzerRegionMapValid(
    _ profile: UnsafeMutableRawPointer?, _ profileBytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32,
    _ raster: UnsafeMutableRawPointer?, _ rasterBytes: UInt32,
    _ coverage: UnsafeMutableRawPointer?, _ coverageBytes: UInt32
) -> UInt32 {
    guard profile != nil, capture != nil, raster != nil, coverage != nil,
        profileBytes == 39_696, captureBytes == 115_392,
        rasterBytes == 2_560, coverageBytes == 160
    else { return 0 }
    let valid = StaticSignalAnalyzerNRFRegionMap.validate(
        profile: UnsafeMutableRawBufferPointer(start: profile, count: Int(profileBytes)),
        capture: UnsafeMutableRawBufferPointer(start: capture, count: Int(captureBytes)),
        raster: UnsafeMutableRawBufferPointer(start: raster, count: Int(rasterBytes)),
        coverage: UnsafeMutableRawBufferPointer(start: coverage, count: Int(coverageBytes))
    )
    return valid ? 1 : 0
}

// Pure bounded coordinator state is copied into the generated 192-byte region.
// No pointer or region view is retained between opportunities.
private struct StaticSignalAnalyzerCommonState {
    var cycles = RunCycleIDAllocator()
    var candidates = CandidateFrameIDAllocator()
    var recovery = HostPresentationRecovery(maximumRetryableRefusals: 3)!
    var health = HostEndpointHealthController(
        initialHealth: GiftUIOperationalHealth(), inputIsEligible: false)!
    var policy = SignalAnalyzerCycleResidualPolicyOwner()
    var lastResult: RuntimeCompletePipelineResult<SignalAnalyzerCycleOwnerFailure>?
    var finalizations: UInt32 = 0
    var applicationPolicyCalls: UInt32 = 0
    var lastApplicationEffects: UInt16 = 0
    var lastApplicationDisposition: GiftUIResidualDisposition?
    var lastHealthError: HostEndpointHealthError?
    var lastCleanup: UInt16 = 0
    var isAvailable = true
    var semanticRetry = false
}

private struct StaticSignalAnalyzerHealthSnapshot: MVPHostEndpointHealthSource {
    let value: GiftUIOperationalHealth
    borrowing func health() -> GiftUIOperationalHealth { value }
}

private struct StaticSignalAnalyzerCommonOwner: RuntimeCompletePipelineOwner, ~Copyable {
    typealias OwnerFailure = SignalAnalyzerCycleOwnerFailure
    let profile: UnsafeMutableRawBufferPointer
    let capture: UnsafeMutableRawBufferPointer
    let raster: UnsafeMutableRawPointer
    let coverage: UnsafeMutableRawPointer
    let write: StaticSignalAnalyzerNRFEmbeddedPixelWrite
    let model: UnsafeMutablePointer<StaticSignalAnalyzerNRFModelLocation>
    let repository: UnsafeMutablePointer<StaticSignalAnalyzerNRFRepositoryProducer>
    let interaction: UnsafeMutablePointer<StaticSignalAnalyzerNRFEmbeddedInteractionOwner>
    let gestures: UnsafeMutablePointer<StaticSignalAnalyzerNRFEmbeddedGestureSession>
    let presentationRevision: PresentationRevision
    var state: StaticSignalAnalyzerCommonState
    var firstFailure = RuntimeFocusedFailureState<OwnerFailure>()
    var admission: StaticSignalAnalyzerNRFCaptureFactAdmission
    var layoutWorkspace: StaticSignalAnalyzerNRFCommonLayoutWorkspace
    var drawing: StaticSignalAnalyzerNRFDrawingWorkspace
    let limits: DrawingLimits
    var semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView?
    var layout: StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView?
    var header: RenderPlanHeader?
    var summary: DrawingPlanSummary?
    var cycle: RunCycleID?
    var candidate: CandidateFrameID?
    var semanticRevision: UInt32 = 0
    var changed = false
    var derivesPresentation = false
    var applicationFailure: SignalAnalyzerRuntimeCondition?
    var offer: FrameOfferResult?
    var recoveryTransition: HostPresentationRecoveryTransition?
    var healthTransition: HostEndpointHealthTransition?
    var healthError: HostEndpointHealthError?
    var healthSnapshot: GiftUIOperationalHealth?
    var priorPhysicalRevision: PresentationRevision?
    let injectedFailure: (RuntimeCompletePipelineStage, RunCycleFailure<OwnerFailure>)?
    let injectedOffer: FrameOfferDisposition?

    init?(
        profile: UnsafeMutableRawBufferPointer, capture: UnsafeMutableRawBufferPointer,
        raster: UnsafeMutableRawPointer, coverage: UnsafeMutableRawPointer,
        write: StaticSignalAnalyzerNRFEmbeddedPixelWrite,
        model: UnsafeMutablePointer<StaticSignalAnalyzerNRFModelLocation>,
        repository: UnsafeMutablePointer<StaticSignalAnalyzerNRFRepositoryProducer>,
        interaction: UnsafeMutablePointer<StaticSignalAnalyzerNRFEmbeddedInteractionOwner>,
        gestures: UnsafeMutablePointer<StaticSignalAnalyzerNRFEmbeddedGestureSession>,
        presentationRevision: PresentationRevision, initial: Bool,
        injectedFailure: (RuntimeCompletePipelineStage, RunCycleFailure<OwnerFailure>)? = nil,
        injectedOffer: FrameOfferDisposition? = nil
    ) {
        guard
            initial
                || (profile.count == 39_696
                    && profile.load(fromByteOffset: 39_408, as: UInt32.self) == 0x5255_4E31)
        else { return nil }
        guard
            StaticSignalAnalyzerNRFRegionMap.validate(
                profile: profile, capture: capture,
                raster: UnsafeMutableRawBufferPointer(start: raster, count: 2_560),
                coverage: UnsafeMutableRawBufferPointer(start: coverage, count: 160)),
            MemoryLayout<StaticSignalAnalyzerCommonState>.stride <= 184,
            MemoryLayout<RuntimeFocusedFailureState<OwnerFailure>>.stride <= 96,
            let packed = StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace(
                scopes: UnsafeMutableRawBufferPointer(rebasing: profile[6_048 ..< 9_184]),
                text: UnsafeMutableRawBufferPointer(rebasing: profile[9_184 ..< 13_888])),
            let limits = DrawingLimits(
                maximumLineWidth: 1, maximumCanvasOccurrences: 5,
                maximumLivePathPoints: 202, maximumLivePathSubpaths: 12,
                maximumPlanStrokes: 5, maximumPlanPoints: 832,
                maximumPlanSubpaths: 16, maximumNormalizedStrokeOperations: 5),
            let drawing = StaticSignalAnalyzerNRFDrawingWorkspace(
                pathRegion: UnsafeMutableRawBufferPointer(rebasing: profile[14_048 ..< 17_328]),
                planRegion: UnsafeMutableRawBufferPointer(rebasing: profile[17_328 ..< 30_864]),
                capacity: limits),
            let admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
                resumingActiveStorage: UnsafeMutableRawBufferPointer(
                    rebasing: profile[31_632 ..< 35_472]),
                sealedStorage: UnsafeMutableRawBufferPointer(rebasing: profile[35_472 ..< 39_312]))
        else { return nil }
        self.profile = profile
        self.capture = capture
        self.raster = raster
        self.coverage = coverage
        self.write = write
        self.model = model
        self.repository = repository
        self.interaction = interaction
        self.gestures = gestures
        self.presentationRevision = presentationRevision
        self.injectedFailure = injectedFailure
        self.injectedOffer = injectedOffer
        self.layoutWorkspace = StaticSignalAnalyzerNRFCommonLayoutWorkspace(packed: packed)
        self.limits = limits
        self.drawing = drawing
        self.admission = consume admission
        priorPhysicalRevision = interaction.pointee.committedRevision
        state =
            initial
            ? StaticSignalAnalyzerCommonState()
            : profile.load(fromByteOffset: 39_416, as: StaticSignalAnalyzerCommonState.self)
        state.lastCleanup = 0
        state.lastApplicationEffects = 0
        state.lastApplicationDisposition = nil
        if let published = StaticSignalAnalyzerNRFEmbeddedSemanticView(
            published: UnsafeMutableRawBufferPointer(rebasing: profile[3_024 ..< 6_048]))
        {
            semanticRevision = published.revision
        }
    }

    @inline(never)
    mutating func inject(_ stage: RuntimeCompletePipelineStage) -> RuntimePipelineStepResult<
        OwnerFailure
    >? {
        guard let injectedFailure, injectedFailure.0 == stage else { return nil }
        return failure(
            injectedFailure.1,
            phase: stage == .applyAdmittedWork || stage == .freezeObservableMutation
                ? .mutating : stage == .offerAndProduction ? .offering : .deriving)
    }

    var context: ExecutionContext {
        ExecutionContext(
            cycle: cycle,
            semanticRevision: semanticRevision == 0
                ? nil : SemanticRevision(rawValue: semanticRevision),
            candidateFrame: candidate, phase: candidate == nil ? .deriving : .offering)
    }

    @inline(never)
    mutating func failure(_ failure: RunCycleFailure<OwnerFailure>, phase: ExecutionPhase)
        -> RuntimePipelineStepResult<OwnerFailure>
    {
        if case .focusedOwner(let cause) = failure {
            if case .application(let condition) = cause { applicationFailure = condition }
            firstFailure.captureFirst(
                cause,
                context: ExecutionContext(
                    cycle: cycle,
                    semanticRevision: semanticRevision == 0
                        ? nil : SemanticRevision(rawValue: semanticRevision),
                    candidateFrame: candidate, phase: phase))
        }
        return .failure(failure)
    }

    @inline(never)
    mutating func admitAndSeal() -> RuntimePipelineStepResult<OwnerFailure> {
        guard state.isAvailable, model.pointee.activeGeneration != nil else {
            return .failure(.execution(.requiredFacilityUnavailable))
        }
        guard let reserved = state.cycles.reserve() else {
            return .failure(.execution(.identityExhausted))
        }
        cycle = reserved
        return inject(.admissionAndSeal) ?? .advanced
    }

    @inline(never)
    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult<OwnerFailure> {
        var applied = false
        switch model.pointee.applyAdmittedBatch(from: &admission, captureStorage: capture) {
        case .applied(let count): applied = count > 0
        case .failure(let cause, let progress, _):
            applicationFailure = cause
            _ = failure(.focusedOwner(.application(cause)), phase: .mutating)
            return .failure(.focusedOwner(.application(cause)), mutationApplied: progress)
        case .unavailable: return .failure(.execution(.invalidPhase), mutationApplied: false)
        }
        if gestures.pointee.hasPresentation {
            var handler = StaticSignalAnalyzerNRFEmbeddedInputHandler(
                gestures: gestures, interaction: interaction, model: model)
            guard case .completed = giftUIStaticRunInputOpportunity(into: &handler) else {
                return .failure(.execution(.invariantViolation), mutationApplied: applied)
            }
            var index: UInt16 = 0
            while index < handler.actionCount {
                guard let code = handler.actionCode(at: index),
                    let generation = model.pointee.activeGeneration
                else { return .failure(.execution(.invariantViolation), mutationApplied: applied) }
                switch StaticSignalAnalyzerNRFEmbeddedActionDispatcher.dispatchTyped(
                    actionCode: code, modelGeneration: generation, model: &model.pointee,
                    repository: &repository.pointee, admission: &admission, captureStorage: capture)
                {
                case .applied(let progress): applied = applied || progress
                case .failure(let cause, let progress):
                    applicationFailure = cause
                    _ = failure(.focusedOwner(.application(cause)), phase: .mutating)
                    return .failure(
                        .focusedOwner(.application(cause)), mutationApplied: applied || progress)
                }
                index += 1
            }
        }
        if let injected = inject(.applyAdmittedWork), case .failure(let cause) = injected {
            if case .focusedOwner(.application(let condition)) = cause {
                applicationFailure = condition
            }
            return .failure(cause, mutationApplied: applied)
        }
        return .applied(applied)
    }

    @inline(never)
    mutating func freezeObservableMutation() -> RuntimePipelineStepResult<OwnerFailure> {
        guard !model.pointee.isMutating else {
            return failure(.focusedOwner(.application(.mutationPhaseViolation)), phase: .mutating)
        }
        derivesPresentation =
            model.pointee.isDirty || state.semanticRetry || state.recovery.pendingIntent != nil
        changed = model.pointee.isDirty || state.semanticRetry
        return inject(.freezeObservableMutation) ?? .advanced
    }

    @inline(never)
    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult<
        OwnerFailure
    > {
        guard derivesPresentation else { return .advanced }
        if let injected = inject(.observableCandidateAndSemanticExpansion) { return injected }
        if changed {
            guard semanticRevision < .max else { return .failure(.execution(.identityExhausted)) }
            semanticRevision += 1
            let candidateRegion = UnsafeMutableRawBufferPointer(rebasing: profile[0 ..< 3_024])
            guard let captures = StaticSignalAnalyzerNRFCaptureRegions(storage: capture),
                StaticSignalAnalyzerNRFEmbeddedSemanticRegion.stage(
                    variant: model.pointee.errorMessage == nil ? .normal : .diagnostic,
                    model: model.pointee, capture: captures, in: candidateRegion) != nil,
                let view = StaticSignalAnalyzerNRFEmbeddedSemanticView(
                    candidate: candidateRegion,
                    revision: semanticRevision)
            else {
                candidateRegion.initializeMemory(as: UInt8.self, repeating: 0)
                return failure(
                    .focusedOwner(.runtime(.semantic(.invariantViolation))), phase: .deriving)
            }
            semantic = view
        } else {
            semantic = StaticSignalAnalyzerNRFEmbeddedSemanticView(
                published: UnsafeMutableRawBufferPointer(rebasing: profile[3_024 ..< 6_048]))
            guard semantic != nil else {
                return failure(
                    .focusedOwner(.runtime(.semantic(.invariantViolation))), phase: .deriving)
            }
        }
        return .advanced
    }

    @inline(never)
    mutating func resolveLayout() -> RuntimePipelineStepResult<OwnerFailure> {
        guard derivesPresentation else { return .advanced }
        if let injected = inject(.layout) { return injected }
        guard let semantic else { return .failure(.execution(.invariantViolation)) }
        switch StaticSignalAnalyzerNRFCommonLayoutPass.runTyped(
            semantic: semantic, workspace: &layoutWorkspace)
        {
        case .success(let value):
            layout = value
            return .advanced
        case .failure(let error):
            return failure(.focusedOwner(.runtime(.layout(error))), phase: .deriving)
        }
    }

    @inline(never)
    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult<OwnerFailure> {
        guard derivesPresentation else { return .advanced }
        if let injected = inject(.canvasInvocationAndPlan) { return injected }
        guard let semantic, let layout,
            var source = StaticSignalAnalyzerNRFEmbeddedCanvasSource(
                semantic: semantic, model: model.pointee, captureRegion: capture,
                callableRegion: UnsafeMutableRawBufferPointer(rebasing: profile[13_888 ..< 14_048]))
        else {
            return failure(.focusedOwner(.runtime(.drawing(.invariantViolation))), phase: .deriving)
        }
        switch giftUIStaticDeriveCanvas(
            source: &source, layout: layout, executionContext: context,
            limits: limits, workspace: &drawing)
        {
        case .success(let value):
            guard source.allReleased else {
                return failure(
                    .focusedOwner(.runtime(.drawing(.invariantViolation))), phase: .deriving)
            }
            summary = value
            return .advanced
        case .failure(let error):
            return failure(.focusedOwner(.runtime(.drawing(error))), phase: .deriving)
        }
    }

    @inline(never)
    mutating func preflightCombinedRender() -> RuntimePipelineStepResult<OwnerFailure> {
        guard derivesPresentation else { return .advanced }
        if let injected = inject(.combinedRenderPreflight) { return injected }
        guard let semantic, let layout else { return .failure(.execution(.invariantViolation)) }
        switch StaticSignalAnalyzerNRFEmbeddedRenderPreflight.runCombined(
            semantic: semantic,
            layout: layout,
            textRegion: UnsafeMutableRawBufferPointer(rebasing: profile[9_184 ..< 13_888]),
            drawing: drawing)
        {
        case .success(let value):
            header = value
            return .advanced
        case .failure(let error): return .failure(.renderProduction(error))
        }
    }

    @inline(never)
    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult<OwnerFailure> {
        guard derivesPresentation else { return .advanced }
        if let injected = inject(.interactionCandidate) { return injected }
        guard let semantic, let layout, let generation = model.pointee.activeGeneration,
            let occurrences = StaticSignalAnalyzerNRFEmbeddedInteractionOccurrences(
                semantic: semantic, layout: layout)
        else {
            return failure(
                .focusedOwner(.runtime(.interaction(.invalidIdentity))), phase: .deriving)
        }
        switch interaction.pointee.buildTyped(
            occurrences: occurrences,
            targetGeneration: ObservableTargetGeneration(rawValue: generation))
        {
        case .ready: return .advanced
        case .ownerFailure(let cause):
            return failure(.focusedOwner(.runtime(cause)), phase: .deriving)
        case .executionFailure(let cause):
            gestures.pointee.quiesce()
            return .failure(.execution(cause))
        }
    }

    @inline(never)
    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult<
        OwnerFailure
    > {
        guard derivesPresentation else {
            return .published(
                RuntimePipelinePublication(
                    semanticRevision: SemanticRevision(rawValue: semanticRevision), changed: false))
        }
        if let injected = inject(.semanticAndObservablePublication),
            case .failure(let cause) = injected
        {
            return .failure(cause)
        }
        if changed {
            guard
                StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                    revision: semanticRevision,
                    candidate: UnsafeMutableRawBufferPointer(rebasing: profile[0 ..< 3_024]),
                    published: UnsafeMutableRawBufferPointer(rebasing: profile[3_024 ..< 6_048]))
            else {
                _ = failure(
                    .focusedOwner(.runtime(.semantic(.invariantViolation))), phase: .deriving)
                return .failure(.focusedOwner(.runtime(.semantic(.invariantViolation))))
            }
            model.pointee.clearDirtyAfterPublication()
            state.semanticRetry = false
        }
        return .published(
            RuntimePipelinePublication(
                semanticRevision: SemanticRevision(rawValue: semanticRevision), changed: changed))
    }

    @inline(never)
    mutating func allocateCandidate() -> RuntimePipelineStepResult<OwnerFailure> {
        guard derivesPresentation else { return .advanced }
        if let injected = inject(.candidateAllocation) { return injected }
        guard let reserved = state.candidates.reserve() else {
            return .failure(.execution(.identityExhausted))
        }
        candidate = reserved
        return .advanced
    }

    @inline(never)
    mutating func offerAndProduce() -> RuntimePipelineOfferResult<OwnerFailure> {
        guard derivesPresentation else { return .noChange }
        if let injected = inject(.offerAndProduction), case .failure(let cause) = injected {
            return .failure(cause)
        }
        guard let cycle, let candidate, let semantic, let layout, let header else {
            return .failure(.execution(.invariantViolation))
        }
        if let injectedOffer {
            offer = FrameOfferResult(disposition: injectedOffer, failure: nil)
            switch injectedOffer {
            case .backpressured: return .backpressured
            case .retryableRefusal: return .retryableRefusal
            case .nonRetryableRefusal: return .nonRetryableRefusal(.endpoint)
            default: return .failure(.execution(.invariantViolation))
            }
        }
        let provenance = FrameProvenance(
            cycle: cycle, semanticRevision: SemanticRevision(rawValue: semanticRevision),
            candidateFrame: candidate)
        guard
            var endpoint = giftUIStaticEmbeddedEndpoint(
                raster: raster, coverage: coverage, provenance: provenance, write: write)
        else { return .failure(.execution(.requiredFacilityUnavailable)) }
        let result = endpoint.offer(provenance: provenance) { sink in
            switch StaticSignalAnalyzerNRFEmbeddedRenderPreflight.streamCombined(
                semantic: semantic,
                layout: layout,
                textRegion: UnsafeMutableRawBufferPointer(rebasing: profile[9_184 ..< 13_888]),
                drawing: drawing, expectedHeader: header, sink: &sink)
            {
            case .success(let value): return value == header ? .complete : .contractViolation
            case .failure(let error):
                sink.retainProducerError(error)
                switch error {
                case .capacityExhausted: return .insufficientCapacity
                case .sinkRefused: return .endpointRefused
                default: return .producerFailed
                }
            }
        }
        offer = result
        switch result.disposition {
        case .accepted:
            healthSnapshot = endpoint.health()
            switch state.health.consumeAcceptedOffer(
                from: endpoint,
                responsibilityTransferred: endpoint.sink.presentationResponsibilityAccepted,
                streamDrained: endpoint.sink.streamCompleted)
            {
            case .success(let transition): healthTransition = transition
            case .failure(let error): healthError = error
            }
            return .accepted(presentationRevision)
        case .backpressured: return .backpressured
        case .retryableRefusal: return .retryableRefusal
        case .nonRetryableRefusal:
            return .nonRetryableRefusal(
                endpoint.retainedProducerError == .sinkRefused ? .renderProducer : .endpoint)
        case .failed:
            if let error = endpoint.retainedProducerError {
                return .failure(.renderProduction(error))
            }
            return .failure(.frameOffer(result.failure ?? .contractViolation))
        }
    }

    @inline(never)
    mutating func cleanup(_ action: RuntimeCleanupAction) {
        state.lastCleanup |= 1 << action.rawValue
        guard derivesPresentation else { return }
        switch action {
        case .discardInteractionCandidate:
            if interaction.pointee.candidateIsReadyForOffer {
                interaction.pointee.resolve(
                    accepted: false, presentationRevision: presentationRevision)
            }
        case .commitInteractionCandidate:
            interaction.pointee.resolve(accepted: true, presentationRevision: presentationRevision)
            gestures.pointee.installPhysicalPresentation(presentationRevision)
            giftUIStaticLastSemanticScopes = UInt32(semantic?.scopeCount ?? 0)
            giftUIStaticLastLayoutScopes = UInt32(layout?.scopeCount ?? 0)
            giftUIStaticLastDrawingStrokes = UInt32(summary?.strokeCount ?? 0)
            giftUIStaticLastDrawingPoints = UInt32(summary?.pointCount ?? 0)
            giftUIStaticLastRenderOperations = UInt32(header?.operationCount ?? 0)
            if healthError == nil, healthTransition?.residualRouteRequest() == nil,
                let healthSnapshot
            {
                let source = StaticSignalAnalyzerHealthSnapshot(value: healthSnapshot)
                if !state.health.enableInputAfterCommittedOffer(from: source) { quiesce() }
            }
        case .resetDrawingPlan: drawing.reset()
        case .resetLayoutCandidate:
            layoutWorkspace.packed.reset()
            layout = nil
        case .discardSemanticCandidate:
            UnsafeMutableRawBufferPointer(rebasing: profile[0 ..< 3_024]).initializeMemory(
                as: UInt8.self, repeating: 0)
            semantic = nil
        case .resetAttemptStorage:
            // The enclosing region borrow ends here, including successfully published layout.
            if drawing.isActive { drawing.reset() }
            if layout != nil || layoutWorkspace.packed.isActive {
                layoutWorkspace.packed.reset()
                layout = nil
            }
        case .releaseCanvasCallable, .resetRenderWorkspace, .discardObservableCandidate:
            // Focused producer scopes already released their callables/scratch. The fixed
            // generated root registration remains live; candidate discard cannot retire it.
            break
        }
    }

    @inline(never)
    mutating func quiesce() {
        state.isAvailable = false
        state.semanticRetry = false
        admission.quiesce()
        gestures.pointee.quiesce()
        repository.pointee.shutdown()
        _ = state.health.requireFreshConstruction(for: .terminalUnavailability)
        giftUISignalAnalyzerInputQuiesce()
    }

    @inline(never)
    mutating func applyDisposition(_ disposition: RuntimePipelineDisposition) {
        if disposition.semanticDisposition == .dirty { state.semanticRetry = true }
        guard let offer else { return }
        switch offer.disposition {
        case .accepted:
            recoveryTransition = state.recovery.recordAccepted(
                revision: SemanticRevision(rawValue: semanticRevision))
        case .backpressured:
            recoveryTransition = state.recovery.recordBackpressure(
                revision: SemanticRevision(rawValue: semanticRevision))
        case .retryableRefusal:
            recoveryTransition = state.recovery.recordRetryableRefusal(
                revision: SemanticRevision(rawValue: semanticRevision))
        case .nonRetryableRefusal: recoveryTransition = state.recovery.recordNonRetryableRefusal()
        case .failed: break
        }
        if recoveryTransition?.disposition == .unavailable { quiesce() }
    }

    @inline(never)
    mutating func finalizePipeline() {
        while admission.takeNextSealed() != nil {}
        admission.endProducer()
        if let cause = applicationFailure {
            let rule = SignalAnalyzerRuntimeFailureRule.evaluate(
                cause, context: .activeDelivery,
                stableStateProven: false, existingLiveModel: true)
            var index: UInt8 = 0
            while let effect = rule.effect(at: index) {
                state.lastApplicationEffects |= 1 << effect.rawValue
                switch effect {
                case .detachObservation, .stopAcquisitionDelivery: repository.pointee.shutdown()
                case .markPresentationFailed:
                    if model.pointee.beginMutation() {
                        _ = model.pointee.setAcquisitionState(
                            .failed(SignalAnalyzerDiagnostic(exactUTF8: [])!))
                        _ = model.pointee.endMutation()
                    }
                case .preventNormalCycle, .requireFreshGraph, .quiesceAffectedScope,
                    .quiesceRuntimeHealth:
                    quiesce()
                case .discardPartialPublication, .removePartialCandidate:
                    UnsafeMutableRawBufferPointer(rebasing: profile[0 ..< 3_024])
                        .initializeMemory(as: UInt8.self, repeating: 0)
                default: break
                }
                index += 1
            }
            if let allowed = rule.allowed,
                let input = GiftUIResidualPolicyInput(
                    outcome: GiftUIOutcome<Void>.failure(
                        SignalAnalyzerRuntimeFailureNormalizer.fact(
                            for: cause, stableStateProven: false)),
                    context: SignalAnalyzerResidualPolicyContext.activeDelivery, allowed: allowed,
                    attemptOrdinal: 0, attemptLimit: 1)
            {
                var policy = SignalAnalyzerResidualFailurePolicy()
                let selected = policy.disposition(for: input)
                state.applicationPolicyCalls += 1
                state.lastApplicationDisposition = selected
                if selected == .quiesceAffectedScope { quiesce() }
            } else if rule.allowed != nil {
                quiesce()
            }
        }
        if model.pointee.isMutating { _ = model.pointee.endMutation() }
        if state.finalizations < .max { state.finalizations += 1 }
        giftUIStaticHasPendingFacts = false
    }

    @inline(never)
    mutating func finish(_ result: RuntimeCompletePipelineResult<OwnerFailure>) -> UInt32 {
        state.lastResult = result
        state.lastHealthError = healthError
        switch result {
        case .failed(let record):
            let fact = SignalAnalyzerCycleFailureNormalizer.cycleFailure(
                record.failure,
                context: firstFailure.detectingContext
                    ?? ExecutionContext(
                        cycle: cycle,
                        semanticRevision: semanticRevision == 0
                            ? nil : SemanticRevision(rawValue: semanticRevision),
                        candidateFrame: candidate,
                        phase: record.stage == .applyAdmittedWork
                            || record.stage == .freezeObservableMutation
                            ? .mutating
                            : record.stage == .offerAndProduction ? .offering : .deriving))
            if applicationFailure != nil {
                state.policy.noPolicy(.focusedOwnerFinal)
            } else if record.failure
                == .focusedOwner(.runtime(.observableState(.invalidPhaseContained)))
            {
                state.semanticRetry = true
                state.policy.noPolicy(.observableContainedPhase)
            } else if fact.containment == .safetyNotProven {
                quiesce()
                state.policy.route(
                    HostResidualRouteRequest(
                        outcome: .failure(fact), context: .safetyNotProven,
                        completedEffects: [.discardPartialWork, .preventNormalCycle],
                        attemptOrdinal: 0, attemptLimit: 1))
            } else if record.publication != nil {
                _ = state.recovery.recordNonRetryableRefusal()
                quiesce()
                state.policy.route(
                    HostResidualRouteRequest(
                        outcome: .failure(fact), context: .presentationUnavailable,
                        completedEffects: [.discardCandidate, .clearPendingIntent, .quiesceInput],
                        attemptOrdinal: 0, attemptLimit: 1))
            } else if priorPhysicalRevision == nil {
                quiesce()
                state.policy.route(
                    HostResidualRouteRequest(
                        outcome: .failure(fact), context: .activation,
                        completedEffects: [.containActivation], attemptOrdinal: 0, attemptLimit: 1))
            } else {
                state.semanticRetry = true
                state.policy.route(
                    HostResidualRouteRequest(
                        outcome: .failure(fact), context: .containedCandidateFailure,
                        completedEffects: [.discardCandidate, .preservePriorRoot],
                        attemptOrdinal: 0, attemptLimit: 1))
            }
        case .completed(let completion):
            if healthError != nil {
                quiesce()
                state.policy.route(
                    HostResidualRouteRequest(
                        outcome: .failure(
                            GiftUIFailureFact(
                                condition: .invariantViolation,
                                origin: .hostComposition, affectedScope: .runtime,
                                containment: .safetyNotProven)), context: .safetyNotProven,
                        completedEffects: [.discardPartialWork, .preventNormalCycle],
                        attemptOrdinal: 0, attemptLimit: 1))
            } else if let request = healthTransition?.residualRouteRequest() {
                quiesce()
                state.policy.route(request)
            } else if let transition = recoveryTransition,
                let policyContext = transition.policyContext
            {
                let outcome: GiftUIOutcome<Void>
                if transition.disposition == .unavailable {
                    outcome = .failure(
                        GiftUIFailureFact(
                            condition: .nonRetryableRefusal,
                            origin: .presentationIntegration, affectedScope: .component,
                            containment: .contained))
                } else {
                    outcome = .operational(
                        GiftUIOperationalFact(
                            kind: completion.operational == .backpressured
                                ? .backpressured : .retryableRefusal,
                            origin: .presentationIntegration, affectedScope: .component))
                }
                state.policy.route(
                    HostResidualRouteRequest(
                        outcome: outcome, context: policyContext,
                        completedEffects: transition.completedEffects,
                        attemptOrdinal: transition.policyAttemptOrdinal,
                        attemptLimit: transition.policyAttemptLimit))
            } else {
                state.policy.noPolicy(.success)
            }
        }
        if state.policy.preventsNormalCycle { quiesce() }
        profile.storeBytes(of: UInt32(0x5255_4E31), toByteOffset: 39_408, as: UInt32.self)
        profile.storeBytes(
            of: state, toByteOffset: 39_416, as: StaticSignalAnalyzerCommonState.self)
        profile.storeBytes(
            of: firstFailure, toByteOffset: 39_600,
            as: RuntimeFocusedFailureState<OwnerFailure>.self)
        giftUIStaticPresentationPending =
            state.isAvailable
            && (state.semanticRetry || state.recovery.pendingIntent != nil)
        guard state.isAvailable else { return 0 }
        if case .completed(let completion) = result, completion.committedPresentationRevision != nil
        {
            return 1
        }
        return 2
    }
}

private func giftUIStaticCommonPresentation(
    profile: UnsafeMutableRawPointer?, profileBytes: UInt32,
    capture: UnsafeMutableRawPointer?, captureBytes: UInt32,
    raster: UnsafeMutableRawPointer?, rasterBytes: UInt32,
    coverage: UnsafeMutableRawPointer?, coverageBytes: UInt32,
    write: StaticSignalAnalyzerNRFEmbeddedPixelWrite,
    frameRevision: UInt32, initial: Bool,
    model: UnsafeMutablePointer<StaticSignalAnalyzerNRFModelLocation>,
    repository: UnsafeMutablePointer<StaticSignalAnalyzerNRFRepositoryProducer>,
    interaction: UnsafeMutablePointer<StaticSignalAnalyzerNRFEmbeddedInteractionOwner>,
    gestures: UnsafeMutablePointer<StaticSignalAnalyzerNRFEmbeddedGestureSession>
) -> UInt32 {
    guard let profile, profileBytes == 39_696, let capture, captureBytes == 115_392,
        let raster, rasterBytes == 2_560, let coverage, coverageBytes == 160,
        var owner = StaticSignalAnalyzerCommonOwner(
            profile: UnsafeMutableRawBufferPointer(start: profile, count: Int(profileBytes)),
            capture: UnsafeMutableRawBufferPointer(start: capture, count: Int(captureBytes)),
            raster: raster, coverage: coverage, write: write, model: model, repository: repository,
            interaction: interaction, gestures: gestures,
            presentationRevision: PresentationRevision(rawValue: frameRevision), initial: initial)
    else { return 0 }
    let result = RuntimeCompletePipeline.run(owner: &owner)
    return owner.finish(result)
}

@_cdecl("giftui_signal_analyzer_source_capture_revision")
public func giftUISignalAnalyzerSourceCaptureRevision() -> UInt32 {
    giftUIStaticRepository.captureRevision
}
