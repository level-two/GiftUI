// Matched placeholder-waveform baseline for SPIKE-004.

@_silgen_name("spike004_raster_touch") func rasterTouch(_ seed: UInt32) -> UInt32

@inline(never)
func placeholderWaveform(_ seed: UInt32) -> UInt32 {
    var digest = seed
    for index in 0..<820 {
        digest = (digest &* 16_777_619) ^ UInt32(index)
    }
    return digest
}

@_cdecl("spike004_swift_run")
public func spike004BaselineRun(_ seed: UInt32) -> UInt64 {
    UInt64(placeholderWaveform(seed) ^ rasterTouch(seed))
}
