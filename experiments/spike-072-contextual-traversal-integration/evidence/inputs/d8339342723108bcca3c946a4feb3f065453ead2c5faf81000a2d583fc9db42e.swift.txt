// Integration-specific control: discovery while a parent facade remains live.
func illegalNestedDiscovery(_ storage: UnsafeMutableBufferPointer<Entry>) throws(AccessFailure) -> UInt32 {
    var session=Session(storage)
    let key=try session.bind(location:1,ordinal:0,seed:3)
    let parentRead=session.read()
    _ = try session.bind(location:2,ordinal:0,seed:4)
    return try parentRead.scalar(key,field:0)
}
