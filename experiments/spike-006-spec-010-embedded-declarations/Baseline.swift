// SPIKE-006 configuration-equivalent baseline.

@_cdecl("spike006_swift_run")
public func spike006SwiftRun(_ seed: UInt32) -> UInt32 {
    seed ^ 41
}
