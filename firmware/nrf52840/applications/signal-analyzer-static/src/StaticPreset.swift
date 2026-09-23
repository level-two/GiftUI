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
        guard let generation = location.pointee.activate(),
            let handle = StaticSignalAnalyzerNRFModelHandle(
                location: location, generation: generation
            )
        else { return 0 }
        let copy = handle
        guard handle.dispatch(actionRawValue: 0) == nil,
            location.pointee.beginMutation(),
            !location.pointee.beginMutation(),
            handle.dispatch(actionRawValue: 0) == .start,
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
        guard handle.dispatch(actionRawValue: 0) == nil else { return 0 }
        return 1
    }
}

@_cdecl("giftui_signal_analyzer_static_preset")
public func giftUISignalAnalyzerStaticPreset() -> UInt32 {
    let preset = StaticSignalAnalyzerPreset()
    return preset.isValid ? 360_515_885 : 0
}

@_cdecl("giftui_signal_analyzer_capture_layout")
public func giftUISignalAnalyzerCaptureLayout() -> UInt32 {
    let recordSize = MemoryLayout<StaticSignalAnalyzerNRFCaptureRecord>.size
    let recordStride = MemoryLayout<StaticSignalAnalyzerNRFCaptureRecord>.stride
    return recordSize == 24 && recordStride == 24
        && StaticSignalAnalyzerNRFCaptureRegions.requiredByteCount == 115_392
        ? 115_392 : 0
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
