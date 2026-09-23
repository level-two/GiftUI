private struct StaticSignalAnalyzerPreset {
    let logicalWidth: UInt16 = 480
    let logicalHeight: UInt16 = 320
    let regionHeight: UInt16 = 4
    let bytesPerRow: UInt32 = 960
    let rasterBytes: UInt32 = 3_840
    let profileStorageBytes: UInt32 = 36_368
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
            && profileStorageBytes == 36_368
            && captureEntries == 2_404
            && canvasCount == 5 && livePointCount == 202 && planPointCount == 832
            && compactFactCapacity == 32 && actionCount == 6
            && modelStorageSlots == 2
            && observableLocationCapacity == 1
            && observableRegistrationCapacity == 1
            && observableReplacementCapacity == 1
    }
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

@_cdecl("giftui_signal_analyzer_compact_ring_valid")
public func giftUISignalAnalyzerCompactRingValid(
    _ profile: UnsafeMutableRawPointer?, _ bytes: UInt32
) -> UInt32 {
    guard let profile, bytes == 36_368 else { return 0 }
    let storage = UnsafeMutableRawBufferPointer(start: profile, count: Int(bytes))
    guard var admission = StaticSignalAnalyzerNRFCaptureFactAdmission(
        activeStorage: UnsafeMutableRawBufferPointer(
            rebasing: storage[31_632 ..< 33_808]
        ),
        sealedStorage: UnsafeMutableRawBufferPointer(
            rebasing: storage[33_808 ..< 35_984]
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
    return 1
}

@_cdecl("giftui_signal_analyzer_snapshot_admission_valid")
public func giftUISignalAnalyzerSnapshotAdmissionValid(
    _ profile: UnsafeMutableRawPointer?, _ profileBytes: UInt32,
    _ capture: UnsafeMutableRawPointer?, _ captureBytes: UInt32
) -> UInt32 {
    guard let profile, let capture, profileBytes == 36_368,
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
            rebasing: profileStorage[31_632 ..< 33_808]
        ),
        sealedStorage: UnsafeMutableRawBufferPointer(
            rebasing: profileStorage[33_808 ..< 35_984]
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
        profileBytes == 36_368, captureBytes == 115_392,
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
