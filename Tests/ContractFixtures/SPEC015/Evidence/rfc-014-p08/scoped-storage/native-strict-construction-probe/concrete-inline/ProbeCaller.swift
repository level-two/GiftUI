import ProbeCore
@_silgen_name("probe_input") func probeInput() -> UInt64
@_silgen_name("probe_touch") func probeTouch(_ pointer: UnsafeRawPointer)
struct ProbeIdentity: Equatable { let rawValue: UInt64 }
struct ProbeConcreteRoot {
    var slots: InlineArray<2, ProbeIdentity?> = .init(repeating: nil)
    mutating func install(_ model: ProbeIdentity) { slots[0] = model }
    var hasModel: Bool { slots[0] != nil }
}
struct ProbeConcreteResolver: ProbeResolver {
    let expected: ProbeIdentity
    func down() -> ProbeIdentity { .init(rawValue: probeInput()) }
}
struct ProbeGenericOwner<R: ProbeResolver>: ProbeOwner {
    let resolver: R
    mutating func perform() -> UInt32 { probeDown(resolver) ? 41 : 0 }
}
@_cdecl("giftui_rfc014_counter_entry")
func entry(_ unused: UnsafeMutableRawPointer?) -> UInt32 {
    let input = probeInput()
    var root = ProbeConcreteRoot()
    if input & 1 != 0 { root.install(.init(rawValue: input)) }
    withUnsafePointer(to: &root) { probeTouch(.init($0)) }
    var owner = ProbeGenericOwner(resolver: ProbeConcreteResolver(expected: .init(rawValue: input)))
    return probeRun(&owner) + (root.hasModel ? 1 : 0)
}
