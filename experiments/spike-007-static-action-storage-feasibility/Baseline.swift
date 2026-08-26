// Configuration-equivalent SPIKE-007 control image.

@_cdecl("spike007_swift_run")
public func spike007SwiftRun(_ seed: UInt32) -> UInt32 {
    return seed ^ 0x0070_0000
}
