@usableFromInline package protocol ProbeResolver {
    associatedtype Identity: Equatable
    var expected: Identity { get }
    func down() -> Identity
}
@usableFromInline package protocol ProbeOwner { mutating func perform() -> UInt32 }
package struct ProbeRoot<Model> {
    @usableFromInline var first: Model?
    @usableFromInline var second: Model?
    @inlinable @inline(__always) package init() { first = nil; second = nil }
    @inlinable package mutating func install(_ model: consuming Model) { first = model }
    @inlinable package var hasModel: Bool { first != nil }
}
@inlinable package func probeDown<R: ProbeResolver>(_ resolver: R) -> Bool {
    resolver.down() == resolver.expected
}
@inlinable package func probeRun<O: ProbeOwner>(_ owner: inout O) -> UInt32 { owner.perform() }

@usableFromInline package struct ProbeScope<Model>: ~Copyable, ~Escapable {
    @usableFromInline let models: UnsafeMutableBufferPointer<Model?>
    @_lifetime(borrow models)
    @inlinable package init(models: borrowing UnsafeMutableBufferPointer<Model?>) { self.models = copy models }
    @inlinable package var hasModel: Bool { models[0] != nil }
}
@inlinable package func withProbeScope<Model, Result>(models: inout MutableSpan<Model?>,
    _ body: (borrowing ProbeScope<Model>) -> Result) -> Result {
    models.withUnsafeMutableBufferPointer { buffer in
        let scope = ProbeScope(models: buffer)
        return body(scope)
    }
}
