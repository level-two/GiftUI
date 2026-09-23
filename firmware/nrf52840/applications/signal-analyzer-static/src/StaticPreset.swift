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
        resolved.rootIdentity == semantic.rootPrimitiveIdentity,
        resolved.renderSnapshotVersion == semantic.revision,
        resolved.rootBounds.size.width > 0,
        resolved.rootBounds.size.height > 0,
        resolved.lineCount == 21, resolved.glyphCount == 121
    else { return 0 }
    var canvasCount: UInt16 = 0
    var checkedLines: UInt16 = 0
    var checkedGlyphs: UInt16 = 0
    var ordinal: UInt16 = 0
    while ordinal < semantic.scopeCount {
        guard let identity = semantic.semanticIdentity(at: ordinal),
            let record = semantic.scope(at: identity)
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
        guard location.pointee.activate() != nil,
            repository.startObservation(
                admission: &admission, captureStorage: captureStorage
            ) == .accepted,
            location.pointee.applyAdmittedBatch(
                from: &admission, captureStorage: captureStorage
            ) == .applied(factCount: 2),
            repository.start(
                admission: &admission, captureStorage: captureStorage
            ) == .accepted,
            location.pointee.applyAdmittedBatch(
                from: &admission, captureStorage: captureStorage
            ) == .applied(factCount: 5),
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
            repository.stop(admission: &admission) == .accepted,
            location.pointee.applyAdmittedBatch(
                from: &admission, captureStorage: captureStorage
            ) == .applied(factCount: 1),
            repository.clear(
                admission: &admission, captureStorage: captureStorage
            ) == .accepted,
            location.pointee.applyAdmittedBatch(
                from: &admission, captureStorage: captureStorage
            ) == .applied(factCount: 1),
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
