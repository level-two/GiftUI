private struct StaticSignalAnalyzerPreset {
    let logicalWidth: UInt16 = 480
    let logicalHeight: UInt16 = 320
    let regionHeight: UInt16 = 4
    let bytesPerRow: UInt32 = 960
    let rasterBytes: UInt32 = 3_840
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
        logicalWidth == 480 && logicalHeight == 320
            && regionHeight == 4 && bytesPerRow == 960
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

@_cdecl("giftui_signal_analyzer_model_location_valid")
public func giftUISignalAnalyzerModelLocationValid() -> UInt32 {
    withUnsafeMutablePointer(to: &giftUIStaticModelLocation) { location in
        guard location.pointee.structuralIdentity
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
    func check(_ variant: StaticSignalAnalyzerNRFSemanticVariant,
               revision: UInt32) -> Bool {
        guard StaticSignalAnalyzerNRFEmbeddedSemanticRegion.stage(
            variant: variant, model: model, capture: captures, in: candidate
        ) != nil,
            StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: revision, candidate: candidate, published: published
            ),
            let view = StaticSignalAnalyzerNRFEmbeddedSemanticView(
                published: published
            ),
            view.scopeCount == (variant == .normal ? 96 : 98),
            view.revision == revision,
            view.rootPrimitiveIdentity != nil,
            let title = StaticSignalAnalyzerNRFPackedSemanticRecords.scope(
                at: 6, in: published
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
    guard let view = StaticSignalAnalyzerNRFEmbeddedSemanticView(
        published: published
    ), let root = view.rootPrimitiveIdentity,
        view.layoutPrimitive(at: root) != nil,
        view.layoutChildCount(of: root) != nil,
        let modifierCount = view.layoutModifierCount(of: root),
        modifierCount == 0 || view.layoutModifier(of: root, at: 0) != nil
    else { return 0 }
    guard var workspace = StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace(
        scopes: layout, text: text
    ), workspace.acquire(), workspace.appendScope(
        identity: root, idealWidth: 480, idealHeight: 320,
        width: 480, height: 320
    ), workspace.placeScope(
        identity: root, originX: 0, originY: 0,
        width: 480, height: 320,
        clipX: 0, clipY: 0, clipWidth: 480, clipHeight: 320
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
            at: 6, in: published
        ) else { return 0 }
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
    guard var layout = StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace(
        scopes: scopes, text: workspace
    ), layout.acquire(), layout.appendScope(
        identity: title.identity,
        idealWidth: 184, idealHeight: 16,
        width: 184, height: 16
    ), layout.appendGlyph(glyph, glyphIndex: 0),
        layout.appendTextLine(line),
        layout.textLine(at: 0) == line,
        layout.glyph(at: 0) == glyph else { return 0 }
    layout.reset()
    guard let semantic = StaticSignalAnalyzerNRFEmbeddedSemanticView(
        published: published
    ), layout.acquire(), layout.appendScope(
        identity: title.identity,
        idealWidth: 0, idealHeight: 0,
        width: 0, height: 0
    ), StaticSignalAnalyzerNRFEmbeddedTextMeasure.run(
        identity: title.identity, semantic: semantic,
        proposalWidth: 480, proposalHeight: 320,
        workspace: &layout
    ), StaticSignalAnalyzerNRFEmbeddedTextPlace.run(
        identity: title.identity, semantic: semantic,
        originX: 0, originY: 0,
        inheritedClipX: 0, inheritedClipY: 0,
        inheritedClipWidth: 480, inheritedClipHeight: 320,
        workspace: &layout
    ), layout.textLineCount > 0, layout.positionedGlyphCount > 0
    else { return 0 }
    guard let resolved = layout.publish(
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
    guard let semantic = StaticSignalAnalyzerNRFEmbeddedSemanticView(
        published: published
    ), let packed = StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace(
        scopes: scopes, text: text
    ) else { return 0 }
    var workspace = StaticSignalAnalyzerNRFCommonLayoutWorkspace(packed: packed)
    guard let resolved = StaticSignalAnalyzerNRFCommonLayoutPass.run(
        semantic: semantic, workspace: &workspace
    ), resolved.isPublished,
        resolved.scopeCount == semantic.scopeCount,
        resolved.rootIdentity == semantic.rootSemanticIdentity,
        resolved.renderSnapshotVersion == semantic.revision,
        resolved.rootBounds.size.width > 0,
        resolved.rootBounds.size.height > 0,
        resolved.lineCount == 21, resolved.glyphCount == 121
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
                    guard let glyph = resolved.glyph(
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
    guard canvasCount == 5, checkedLines == 21,
        checkedGlyphs == 121
    else { return 0 }
    guard case .success(let ordinaryHeader) =
        StaticSignalAnalyzerNRFEmbeddedRenderPreflight.run(
            semantic: semantic, layout: resolved,
            textRegion: text
        ), ordinaryHeader.operationCount > 0,
        ordinaryHeader.operationCount <= 145,
        ordinaryHeader.positionedGlyphCount == 121
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
        ), var workspace = StaticSignalAnalyzerNRFDrawingWorkspace(
            pathRegion: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 14_048), count: 3_280
            ),
            planRegion: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 17_328), count: 13_536
            ), capacity: limits
        ), workspace.acquire(),
        let clip = Rect(
            origin: Point(x: 0, y: 0), size: Size(width: 480, height: 320)!
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
    guard StaticSignalAnalyzerNRFEmbeddedCanvasPayload.stageTrace(
        trace, at: 1, in: region
    ), !StaticSignalAnalyzerNRFEmbeddedCanvasPayload.stageTrace(
        trace, at: 1, in: region
    ), StaticSignalAnalyzerNRFEmbeddedCanvasPayload.trace(at: 1, in: region)?
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
    var model = StaticSignalAnalyzerNRFModelLocation()
    var interaction = StaticSignalAnalyzerNRFEmbeddedInteractionOwner()!
    var gestures = StaticSignalAnalyzerNRFEmbeddedGestureSession()
    return giftUIStaticFullCanvas(
        profile, bytes, capture, captureBytes,
        raster, rasterBytes, coverage, coverageBytes,
        write: giftUISignalAnalyzerProbeRGB565,
        validation: true, model: &model,
        interaction: &interaction, gestures: &gestures
    )
}

@_cdecl("giftui_signal_analyzer_present_initial")
public func giftUISignalAnalyzerPresentInitial(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32,
    _ raster: UnsafeMutableRawPointer?, _ rasterBytes: UInt32,
    _ coverage: UnsafeMutableRawPointer?, _ coverageBytes: UInt32,
    _ write: (@convention(c) (
        UInt16, UInt16, UInt16, UInt16, UnsafePointer<UInt8>?, Int
    ) -> Int32)?
) -> UInt32 {
    guard let write else { return 0 }
    return withUnsafeMutablePointer(to: &giftUIStaticModelLocation) { location in
        withUnsafeMutablePointer(to: &giftUIStaticRepository) { repository in
            withUnsafeMutablePointer(to: &giftUIStaticInteractionOwner) { interaction in
                withUnsafeMutablePointer(to: &giftUIStaticGestureSession) { gestures in
                guard location.pointee.activeGeneration == nil else { return 0 }
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
                let result = giftUIStaticFullCanvas(
                    profile, bytes, capture, captureBytes,
                    raster, rasterBytes, coverage, coverageBytes,
                    write: write, validation: false,
                    model: &location.pointee,
                    interaction: &interaction.pointee,
                    gestures: &gestures.pointee
                )
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

@_cdecl("giftui_signal_analyzer_retire_initial")
public func giftUISignalAnalyzerRetireInitial() {
    giftUIStaticRetire(
        model: &giftUIStaticModelLocation,
        repository: &giftUIStaticRepository,
        interaction: &giftUIStaticInteractionOwner,
        gestures: &giftUIStaticGestureSession
    )
}

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
    guard var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
        activeStorage: UnsafeMutableRawBufferPointer(
            rebasing: profileStorage[31_632 ..< 35_472]
        ), sealedStorage: UnsafeMutableRawBufferPointer(
            rebasing: profileStorage[35_472 ..< 39_312]
        )
    ), repository.startObservation(
        admission: &admission, captureStorage: captureStorage
    ) == .accepted,
        model.applyAdmittedBatch(
            from: &admission, captureStorage: captureStorage
        ) == .applied(factCount: 2),
        model.capture.revision == 0,
        model.acquisitionState == .idle
    else { return false }
    return true
}

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
}

private func giftUIStaticFullCanvas(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32,
    _ raster: UnsafeMutableRawPointer?, _ rasterBytes: UInt32,
    _ coverage: UnsafeMutableRawPointer?, _ coverageBytes: UInt32,
    write: StaticSignalAnalyzerNRFEmbeddedPixelWrite,
    validation: Bool,
    model: inout StaticSignalAnalyzerNRFModelLocation,
    interaction: inout StaticSignalAnalyzerNRFEmbeddedInteractionOwner,
    gestures: inout StaticSignalAnalyzerNRFEmbeddedGestureSession
) -> UInt32 {
    guard let profile, bytes == 39_696,
        let capture, captureBytes == 115_392,
        let raster, rasterBytes == 3_840,
        let coverage, coverageBytes == 240
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
            ), StaticSignalAnalyzerNRFEmbeddedSemanticRegion.stage(
                variant: .normal, model: model,
                capture: captures, in: candidateRegion
            ) != nil,
            StaticSignalAnalyzerNRFEmbeddedSemanticRegion.publish(
                revision: prior.revision + 1,
                candidate: candidateRegion, published: publishedRegion
            )
        else { return 0 }
    }
    guard let semantic = StaticSignalAnalyzerNRFEmbeddedSemanticView(
        published: publishedRegion
    ), let packed = StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace(
            scopes: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 6_048), count: 3_136
            ),
            text: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 9_184), count: 4_704
            )
        ), let limits = DrawingLimits(
            maximumLineWidth: 1,
            maximumCanvasOccurrences: 5,
            maximumLivePathPoints: 202,
            maximumLivePathSubpaths: 12,
            maximumPlanStrokes: 5,
            maximumPlanPoints: 832,
            maximumPlanSubpaths: 16,
            maximumNormalizedStrokeOperations: 5
        ), var drawing = StaticSignalAnalyzerNRFDrawingWorkspace(
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
    guard let resolved = StaticSignalAnalyzerNRFCommonLayoutPass.run(
        semantic: semantic, workspace: &layoutWorkspace
    ), let actions = StaticSignalAnalyzerNRFEmbeddedInteractionOccurrences(
        semantic: semantic, layout: resolved
    ), actions.count == 6,
        actions.occurrence(at: 0)?.actionCode == 0,
        actions.occurrence(at: 5)?.actionCode == 5,
        interaction.build(
            occurrences: actions,
            targetGeneration: ObservableTargetGeneration(
                rawValue: model.activeGeneration ?? 0
            )
        ), interaction.candidateIsReadyForOffer
    else { return 0 }
    var interactionCandidatePending = true
    defer {
        if interactionCandidatePending {
            interaction.resolve(
                accepted: false,
                presentationRevision: PresentationRevision(rawValue: 1)
            )
        }
    }
    guard (!validation || model.activate() != nil),
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
    let result = CanvasPlanProducer.derive(
        source: &source, layout: resolved,
        executionContext: ExecutionContext(
            cycle: RunCycleID(rawValue: 1),
            semanticRevision: SemanticRevision(rawValue: semantic.revision),
            candidateFrame: nil, phase: .deriving
        ), limits: limits, workspace: &drawing
    )
    guard case .success(let summary) = result,
        source.allReleased,
        summary.canvasOccurrenceCount == 5,
        summary.strokeCount == 5,
        summary.pointCount == 32,
        summary.subpathCount == 16,
        let gridID = source.canvasIdentity(at: 0),
        let grid = drawing.strokeHeader(of: gridID, at: 0),
        grid.color == .gray,
        grid.lineWidth == 1,
        grid.pointCount == 24,
        grid.subpathCount == 12,
        case .success(let renderHeader) =
            StaticSignalAnalyzerNRFEmbeddedRenderPreflight.runCombined(
                semantic: semantic, layout: resolved,
                textRegion: UnsafeMutableRawBufferPointer(
                    start: profile.advanced(by: 9_184), count: 4_704
                ), drawing: drawing
            ), renderHeader.operationCount <= 150,
        renderHeader.positionedGlyphCount == (validation ? 121 : 117)
    else { return 0 }
    var sink = StaticSignalAnalyzerNRFEmbeddedCountingSink()
    guard case .success(let streamedHeader) =
        StaticSignalAnalyzerNRFEmbeddedRenderPreflight.streamCombined(
            semantic: semantic, layout: resolved,
            textRegion: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 9_184), count: 4_704
            ), drawing: drawing, expectedHeader: renderHeader, sink: &sink
        ), streamedHeader == renderHeader,
        sink.isFinished, !sink.wasDiscarded,
        sink.strokeCount == 5,
        sink.glyphCount == (validation ? 121 : 117)
    else { return 0 }
    if validation {
        guard var rasterSink = StaticSignalAnalyzerNRFEmbeddedRasterSink(
            rasterRegion: UnsafeMutableRawBufferPointer(
                start: raster, count: Int(rasterBytes)
            ), coverageRegion: UnsafeMutableRawBufferPointer(
                start: coverage, count: Int(coverageBytes)
            ), write: giftUISignalAnalyzerProbeRGB565
        ), case .success(let rasterHeader) =
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
    let firstProvenance = FrameProvenance(
        cycle: RunCycleID(rawValue: 1),
        semanticRevision: SemanticRevision(rawValue: semantic.revision),
        candidateFrame: CandidateFrameID(rawValue: 1)
    )
    guard var fullEndpoint = giftUIStaticEmbeddedEndpoint(
        raster: raster, coverage: coverage,
        provenance: firstProvenance,
        write: write
    ), giftUIStaticEmbeddedOffer(
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
        presentationRevision: PresentationRevision(rawValue: 1)
    )
    interactionCandidatePending = false
    guard interaction.committedRecordCount == 6,
        interaction.committedRevision?.rawValue == 1,
        interaction.committedRecord(at: 0)?.action.code == 0,
        interaction.committedRecord(at: 5)?.action.code == 5
    else { return 0 }
    if !validation {
        guard let start = interaction.committedRecord(at: 0),
            start.isEnabled
        else { return 0 }
        let point = Point(
            x: start.hitBounds.origin.x + start.hitBounds.size.width / 2,
            y: start.hitBounds.origin.y + start.hitBounds.size.height / 2
        )
        var capture = PointerActionCapture<UInt32>()
        guard case .captured(let down) = ExecutionGestureAdapter.down(
            at: point, capture: &capture, resolver: interaction
        ), case .activationAdmitted(let up) = ExecutionGestureAdapter.up(
            at: point, capture: &capture, resolver: interaction
        ), down == up, up.identity == start.identity
        else { return 0 }
        let revision = PresentationRevision(rawValue: 1)
        gestures.installPhysicalPresentation(revision)
        var sequenceProbe = gestures
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
            sequenceProbe.handle(
                downEvent, interaction: interaction,
                modelGeneration: generation
            ) == .consumed,
            sequenceProbe.handle(
                upEvent, interaction: interaction,
                modelGeneration: generation
            ) == .admitted(actionCode: 0),
            sequenceProbe.handle(
                staleEvent, interaction: interaction,
                modelGeneration: generation
            ) == .rejected,
            gestures.hasPresentation
        else { return 0 }
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
        else { return 0 }
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
        else { return 0 }
        return 1
    }
    guard interaction.build(
        occurrences: actions,
        targetGeneration: ObservableTargetGeneration(rawValue: 0)
    ), interaction.candidateIsReadyForOffer
    else { return 0 }
    interaction.resolve(
        accepted: false,
        presentationRevision: PresentationRevision(rawValue: 2)
    )
    guard interaction.committedRecordCount == 6,
        interaction.committedRevision?.rawValue == 1
    else { return 0 }
    guard var refusingSink = StaticSignalAnalyzerNRFEmbeddedRasterSink(
        rasterRegion: UnsafeMutableRawBufferPointer(
            start: raster, count: Int(rasterBytes)
        ), coverageRegion: UnsafeMutableRawBufferPointer(
            start: coverage, count: Int(coverageBytes)
        ), write: giftUISignalAnalyzerRefuseRGB565
    ), case .failure(.invariantViolation) =
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
    drawing.reset()
    layoutWorkspace.packed.reset()
    let captureRegion = UnsafeMutableRawBufferPointer(
        start: capture, count: Int(captureBytes)
    )
    guard var regions = StaticSignalAnalyzerNRFCaptureRegions(
        storage: captureRegion
    ), let transition = StaticSignalAnalyzerNRFCaptureRecord(
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
        ), var updatedSource = StaticSignalAnalyzerNRFEmbeddedCanvasSource(
            semantic: semantic, model: model, captureRegion: captureRegion,
            callableRegion: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 13_888), count: 160
            )
        )
    else { return 0 }
    let updatedResult = CanvasPlanProducer.derive(
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
        updatedRenderHeader.positionedGlyphCount == 121
    else { return 0 }
    sink = StaticSignalAnalyzerNRFEmbeddedCountingSink()
    guard case .success(let updatedStreamedHeader) =
        StaticSignalAnalyzerNRFEmbeddedRenderPreflight.streamCombined(
            semantic: semantic, layout: updatedLayout,
            textRegion: UnsafeMutableRawBufferPointer(
                start: profile.advanced(by: 9_184), count: 4_704
            ), drawing: drawing, expectedHeader: updatedRenderHeader,
            sink: &sink
        ), updatedStreamedHeader == updatedRenderHeader,
        sink.isFinished, !sink.wasDiscarded,
        sink.strokeCount == 5,
        sink.glyphCount == 121
    else { return 0 }
    guard var updatedRasterSink = StaticSignalAnalyzerNRFEmbeddedRasterSink(
        rasterRegion: UnsafeMutableRawBufferPointer(
            start: raster, count: Int(rasterBytes)
        ), coverageRegion: UnsafeMutableRawBufferPointer(
            start: coverage, count: Int(coverageBytes)
        ), write: giftUISignalAnalyzerProbeRGB565
    ), case .success(let updatedRasterHeader) =
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
    guard fullEndpoint.replaceEnvelopeValidator(
        StaticSignalAnalyzerNRFEmbeddedProbeEnvelope(
            expected: secondProvenance
        )
    ), giftUIStaticEmbeddedOffer(
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
    guard x < 480, y < 320, width > 0, height == 1,
        UInt32(x) + UInt32(width) <= 480,
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
    guard let raster, rasterBytes == 3_840,
        let coverage, coverageBytes == 240,
        let surface = Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 480, height: 320)!
        ),
        let descriptor = RasterSurfaceDescriptor(
            bounds: surface, encoding: .rgb565BigEndian,
            bytesPerRow: 960, realization: .tiled,
            regionWidth: 480, regionHeight: 4
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
            origin: Point(x: 0, y: 0), size: Size(width: 480, height: 4)!
        ),
        let second = Rect(
            origin: Point(x: 0, y: 4), size: Size(width: 480, height: 4)!
        ),
        let third = Rect(
            origin: Point(x: 0, y: 8), size: Size(width: 480, height: 4)!
        ),
        tile.beginTile(first),
        tile.replacePixel(
            at: Point(x: 0, y: 0),
            with: CanonicalEncodedPixel(color: .white, encoding: .rgb565BigEndian)
        ),
        tile.replacePixel(
            at: Point(x: 479, y: 3),
            with: CanonicalEncodedPixel(color: .black, encoding: .rgb565BigEndian)
        ),
        tile.storage.byte(at: 0) == 0xff,
        tile.storage.byte(at: 1) == 0xff,
        tile.storage.isAffected(pixelIndex: 0),
        tile.storage.isAffected(pixelIndex: 1_919),
        !tile.storage.isAffected(pixelIndex: 1_918),
        tile.finishTile(),
        tile.beginTile(second),
        !tile.storage.isAffected(pixelIndex: 0),
        !tile.storage.isAffected(pixelIndex: 1_919),
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
        tile.storage.isAffected(pixelIndex: 483),
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
            instance: FontInstanceID(rawValue: 0), clip: third,
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
    guard let fourth = Rect(
        origin: Point(x: 0, y: 12), size: Size(width: 480, height: 4)!
    ), let small = Rect(
        origin: Point(x: 0, y: 12), size: Size(width: 2, height: 2)!
    ) else { return 0 }
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
                workspace.storage.isAffected(pixelIndex: 481),
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
    let transport = StaticSignalAnalyzerNRFILI9486Transport(
        write: giftUISignalAnalyzerProbeRGB565
    )
    guard var target = StaticSignalAnalyzerNRFDisplayTarget(
        transport: transport,
        rasterRegion: UnsafeMutableRawBufferPointer(
            start: raster, count: Int(rasterBytes)
        )
    ) else { return 0 }
    let reservation: DisplayReservationID
    switch target.reserveFrame(
        descriptor: descriptor, payloadCapacityBytes: 3_840,
        regionCapacity: 1
    ) {
    case .reserved(let value): reservation = value
    default: return 0
    }
    let written = target.withWriter(for: reservation) { writer in
        guard writer.beginRegion(
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
    let refusingTransport = StaticSignalAnalyzerNRFILI9486Transport(
        write: giftUISignalAnalyzerRefuseRGB565
    )
    guard var refusingTarget = StaticSignalAnalyzerNRFDisplayTarget(
        transport: refusingTransport,
        rasterRegion: UnsafeMutableRawBufferPointer(
            start: raster, count: Int(rasterBytes)
        )
    ) else { return 0 }
    let refusingReservation: DisplayReservationID
    switch refusingTarget.reserveFrame(
        descriptor: descriptor, payloadCapacityBytes: 3_840,
        regionCapacity: 1
    ) {
    case .reserved(let value): refusingReservation = value
    default: return 0
    }
    let refusalWritten = refusingTarget.withWriter(
        for: refusingReservation
    ) { writer in
        guard writer.beginRegion(
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
            descriptor: descriptor, payloadCapacityBytes: 3_840,
            regionCapacity: 1
        ) == .nonRetryableRefusal
    else { return 0 }
    guard let sessionTarget = StaticSignalAnalyzerNRFDisplayTarget(
        transport: StaticSignalAnalyzerNRFILI9486Transport(
            write: giftUISignalAnalyzerProbeRGB565
        ), rasterRegion: UnsafeMutableRawBufferPointer(
            start: raster, count: Int(rasterBytes)
        )
    ), let sessionStorage = StaticSignalAnalyzerNRFTileStorage(
        region: UnsafeMutableRawBufferPointer(
            start: raster, count: Int(rasterBytes)
        ), coverage: UnsafeMutableRawBufferPointer(
            start: coverage, count: Int(coverageBytes)
        )
    ), let payloadLimits = RasterPayloadLimits(
        maximumRasterBytes: 3_840, maximumPayloadBytes: 3_840,
        maximumRegionsPerPayload: 1,
        maximumRegionSubmissionsPerFrame: 23_040_000,
        maximumTileVisitsPerFrame: 12_000,
        maximumInFlightPayloads: 1,
        maximumGlyphRasterBytes: 3_840,
        maximumStrokeWorkspaceBytes: 3_840
    ), var session = OperationMajorRGB565RasterSession(
        capacity: RenderSinkCapacity(
            maximumOperations: 150, maximumPositionedGlyphs: 224
        ), descriptor: descriptor, payloadLimits: payloadLimits,
        metrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
        raster: StaticSignalAnalyzerNRFEmbeddedFontRaster(),
        realization: RasterRealizationID(rawValue: 0),
        storage: sessionStorage, target: sessionTarget
    ) else { return 0 }
    let sessionReservation: DisplayReservationID
    switch session.reserveFrame(
        descriptor: descriptor, payloadCapacityBytes: 3_840,
        regionCapacity: 1
    ) {
    case .reserved(let value): sessionReservation = value
    default: return 0
    }
    guard session.begin(
        RenderPlanHeader(
            surfaceBounds: surface, damageBounds: small,
            operationCount: 1, positionedGlyphCount: 0,
            maximumObservedClipDepth: 0
        )
    ), session.fillRect(
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
    let effective = EffectiveRasterPresentation(
        operations: [
            .opaqueRectangles, .positionedText,
            .straightLineStrokes, .clipping, .damage,
        ],
        extent: CapabilityExtent(width: 480, height: 320)!,
        regionExtent: CapabilityExtent(width: 480, height: 4)!,
        rowBytes: CapabilityByteCount(rawValue: 960),
        operationStream: .synchronousBorrowedOneShot,
        encoding: .rgb565BigEndian,
        submissionLifetime: .synchronousBorrow,
        handoff: .synchronous,
        realization: .tiled,
        requiredRasterBytes: CapabilityByteCount(rawValue: 3_840),
        requiredPayloadBytes: CapabilityByteCount(rawValue: 3_840),
        inFlightCount: 1,
        requiredInFlightBytes: CapabilityByteCount(rawValue: 3_840)
    )
    guard var endpoint = OneShotRasterBackendEndpoint(
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
    ) else { return 0 }
    let wrong = FrameProvenance(
        cycle: RunCycleID(rawValue: 2),
        semanticRevision: SemanticRevision(rawValue: 1),
        candidateFrame: CandidateFrameID(rawValue: 1)
    )
    guard endpoint.offer(provenance: wrong, body: { _ in .complete })
        == FrameOfferResult(
            disposition: .failed, failure: .invalidEnvelope
        ), endpoint.bodyCallCount == 0
    else { return 0 }
    let offer = endpoint.offer(provenance: provenance) { sink in
        guard sink.begin(
            RenderPlanHeader(
                surfaceBounds: surface, damageBounds: small,
                operationCount: 1, positionedGlyphCount: 0,
                maximumObservedClipDepth: 0
            )
        ), sink.fillRect(
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
    StaticSignalAnalyzerNRFDisplayTarget<StaticSignalAnalyzerNRFILI9486Transport>

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

private func giftUIStaticEmbeddedEndpoint(
    raster: UnsafeMutableRawPointer,
    coverage: UnsafeMutableRawPointer,
    provenance: FrameProvenance,
    write: StaticSignalAnalyzerNRFEmbeddedPixelWrite
) -> StaticSignalAnalyzerNRFEmbeddedEndpoint? {
    guard let surface = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 480, height: 320)!
    ), let descriptor = RasterSurfaceDescriptor(
        bounds: surface, encoding: .rgb565BigEndian,
        bytesPerRow: 960, realization: .tiled,
        regionWidth: 480, regionHeight: 4
    ), let storage = StaticSignalAnalyzerNRFTileStorage(
        region: UnsafeMutableRawBufferPointer(start: raster, count: 3_840),
        coverage: UnsafeMutableRawBufferPointer(start: coverage, count: 240)
    ), let target = StaticSignalAnalyzerNRFDisplayTarget(
        transport: StaticSignalAnalyzerNRFILI9486Transport(write: write),
        rasterRegion: UnsafeMutableRawBufferPointer(start: raster, count: 3_840)
    ), let limits = RasterPayloadLimits(
        maximumRasterBytes: 3_840, maximumPayloadBytes: 3_840,
        maximumRegionsPerPayload: 1,
        maximumRegionSubmissionsPerFrame: 23_040_000,
        maximumTileVisitsPerFrame: 12_000,
        maximumInFlightPayloads: 1,
        maximumGlyphRasterBytes: 3_840,
        maximumStrokeWorkspaceBytes: 3_840
    ), let session = StaticSignalAnalyzerNRFEmbeddedSession(
        capacity: RenderSinkCapacity(
            maximumOperations: 150, maximumPositionedGlyphs: 224
        ), descriptor: descriptor, payloadLimits: limits,
        metrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
        raster: StaticSignalAnalyzerNRFEmbeddedFontRaster(),
        realization: RasterRealizationID(rawValue: 0),
        storage: storage, target: target
    ) else { return nil }
    let effective = EffectiveRasterPresentation(
        operations: [
            .opaqueRectangles, .positionedText,
            .straightLineStrokes, .clipping, .damage,
        ],
        extent: CapabilityExtent(width: 480, height: 320)!,
        regionExtent: CapabilityExtent(width: 480, height: 4)!,
        rowBytes: CapabilityByteCount(rawValue: 960),
        operationStream: .synchronousBorrowedOneShot,
        encoding: .rgb565BigEndian,
        submissionLifetime: .synchronousBorrow,
        handoff: .synchronous,
        realization: .tiled,
        requiredRasterBytes: CapabilityByteCount(rawValue: 3_840),
        requiredPayloadBytes: CapabilityByteCount(rawValue: 3_840),
        inFlightCount: 1,
        requiredInFlightBytes: CapabilityByteCount(rawValue: 3_840)
    )
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
    guard source.nextScheduledDelay == .milliseconds(80),
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
    { return 1 }
    return 0
}

@_cdecl("giftui_signal_analyzer_compact_ring_valid")
public func giftUISignalAnalyzerCompactRingValid(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32
) -> UInt32 {
    guard let profile, bytes == 39_696 else { return 0 }
    let storage = UnsafeMutableRawBufferPointer(start: profile, count: Int(bytes))
    guard var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
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
    guard var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
        activeStorage: UnsafeMutableRawBufferPointer(
            rebasing: profileStorage[31_632 ..< 35_472]
        ),
        sealedStorage: UnsafeMutableRawBufferPointer(
            rebasing: profileStorage[35_472 ..< 39_312]
        )
    ), let view = StaticSignalAnalyzerNRFCaptureSnapshotView(
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
    guard var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
        activeStorage: UnsafeMutableRawBufferPointer(
            rebasing: profileStorage[31_632 ..< 35_472]
        ),
        sealedStorage: UnsafeMutableRawBufferPointer(
            rebasing: profileStorage[35_472 ..< 39_312]
        )
    ), let snapshot = StaticSignalAnalyzerNRFCaptureSnapshotView(
        storage: captureStorage, revision: 0, count: 0,
        duration: .zero, retainedLowerBound: .zero,
        baselineLevels: .allLow
    ), admission.beginProducer(.bootstrap),
        admission.admitSnapshot(snapshot) == .accepted(sequence: 1),
        admission.admitAcquisitionState(.running) == .accepted(sequence: 2)
    else { return 0 }
    admission.endProducer()
    guard admission.admitOperationalFailure(
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
    guard var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
        activeStorage: UnsafeMutableRawBufferPointer(
            rebasing: profileStorage[31_632 ..< 35_472]
        ),
        sealedStorage: UnsafeMutableRawBufferPointer(
            rebasing: profileStorage[35_472 ..< 39_312]
        )
    ) else { return 0 }
    var repository = StaticSignalAnalyzerNRFRepositoryProducer()
    return withUnsafeMutablePointer(to: &giftUIStaticModelLocation) { location in
        guard let generation = location.pointee.activate() else { return 0 }
        guard repository.startObservation(
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
            repository.nextScheduledDelay == .milliseconds(80),
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
    guard var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
        activeStorage: UnsafeMutableRawBufferPointer(
            rebasing: profileStorage[31_632 ..< 35_472]
        ),
        sealedStorage: UnsafeMutableRawBufferPointer(
            rebasing: profileStorage[35_472 ..< 39_312]
        )
    ) else { return 0 }
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
    guard let view = StaticSignalAnalyzerNRFCaptureSnapshotView(
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
            guard let view = StaticSignalAnalyzerNRFCaptureSnapshotView(
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
        guard location.pointee.applyCaptureMutation(
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
        rasterBytes == 3_840, coverageBytes == 240
    else { return 0 }
    let valid = StaticSignalAnalyzerNRFRegionMap.validate(
        profile: UnsafeMutableRawBufferPointer(start: profile, count: Int(profileBytes)),
        capture: UnsafeMutableRawBufferPointer(start: capture, count: Int(captureBytes)),
        raster: UnsafeMutableRawBufferPointer(start: raster, count: Int(rasterBytes)),
        coverage: UnsafeMutableRawBufferPointer(start: coverage, count: Int(coverageBytes))
    )
    return valid ? 1 : 0
}
