// Control image: identical Swift entry and read-shaped work, but no capability
// vocabulary, contribution, resolver, validation, or snapshot implementation.

@_cdecl("spike002_swift_run")
public func spike002BaselineRun(_ seed: UInt32) -> UInt64 {
    var control = seed &* 1_664_525 &+ 1_013_904_223
    control ^= control >> 13
    let readShapedValue = control &+ 0x0020_01E0
    return (UInt64(control) << 32) | UInt64(readShapedValue)
}
