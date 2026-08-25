// Disposable SPIKE-004 Embedded Swift integration entry point. The scalar
// workload loop is in the freestanding C fixture to avoid measuring generic
// Swift Range machinery rather than the candidate storage boundary.

@_silgen_name("spike004_candidate_run") func candidateRun(_ seed: UInt32) -> UInt64
@_silgen_name("spike004_raster_touch") func rasterTouch(_ seed: UInt32) -> UInt32

@_cdecl("spike004_swift_run")
public func spike004Run(_ seed: UInt32) -> UInt64 {
    candidateRun(seed) ^ UInt64(rasterTouch(seed))
}
