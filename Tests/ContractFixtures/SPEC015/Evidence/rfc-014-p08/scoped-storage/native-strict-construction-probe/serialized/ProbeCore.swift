@usableFromInline package protocol ProbeResolver {
    associatedtype Identity: Equatable
    var expected: Identity { get }
    func down() -> Identity
}
@usableFromInline package protocol ProbeOwner { mutating func perform() -> UInt32 }
package struct ProbeRoot<Model> {
    @usableFromInline var slots: InlineArray<2, Model?>
    @inlinable package init() { slots = .init(repeating: nil) }
    @inlinable package mutating func install(_ model: consuming Model) { slots[0] = model }
    @inlinable package var hasModel: Bool { slots[0] != nil }
}
@inlinable package func probeDown<R: ProbeResolver>(_ resolver: R) -> Bool {
    resolver.down() == resolver.expected
}
@inlinable package func probeRun<O: ProbeOwner>(_ owner: inout O) -> UInt32 { owner.perform() }
