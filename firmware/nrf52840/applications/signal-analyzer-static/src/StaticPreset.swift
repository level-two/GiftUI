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

@_cdecl("giftui_signal_analyzer_static_preset")
public func giftUISignalAnalyzerStaticPreset() -> UInt32 {
    let preset = StaticSignalAnalyzerPreset()
    return preset.isValid ? 360_515_885 : 0
}
