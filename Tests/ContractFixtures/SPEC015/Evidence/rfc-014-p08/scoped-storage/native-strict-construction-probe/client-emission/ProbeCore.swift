@usableFromInline package protocol ProbeResolver {
    associatedtype Identity: Equatable
    var expected: Identity { get }
    func down() -> Identity
}
@usableFromInline package protocol ProbeOwner { mutating func perform() -> UInt32 }
package struct ProbeRoot<Model> {
    @usableFromInline var slots: InlineArray<2, Model?>
    @_alwaysEmitIntoClient @inline(__always) package init() { slots = .init(repeating: nil) }
    @_alwaysEmitIntoClient package mutating func install(_ model: consuming Model) { slots[0] = model }
    @_alwaysEmitIntoClient package var hasModel: Bool { slots[0] != nil }
}
@_alwaysEmitIntoClient package func probeDown<R: ProbeResolver>(_ resolver: R) -> Bool {
    resolver.down() == resolver.expected
}
@_alwaysEmitIntoClient package func probeRun<O: ProbeOwner>(_ owner: inout O) -> UInt32 { owner.perform() }
