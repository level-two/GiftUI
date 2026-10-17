package protocol ProbeResolver {
    associatedtype Identity: Equatable
    var expected: Identity { get }
    func down() -> Identity
}
package protocol ProbeOwner { mutating func perform() -> UInt32 }
package struct ProbeRoot<Model> {
    private var slots: InlineArray<2, Model?>
    package init() { slots = .init(repeating: nil) }
    package mutating func install(_ model: consuming Model) { slots[0] = model }
    package var hasModel: Bool { slots[0] != nil }
}
package func probeDown<R: ProbeResolver>(_ resolver: R) -> Bool {
    resolver.down() == resolver.expected
}
package func probeRun<O: ProbeOwner>(_ owner: inout O) -> UInt32 { owner.perform() }
