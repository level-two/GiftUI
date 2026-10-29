public final class AllocationBox {
    public let value: Int
    public init(_ value: Int) { self.value = value }
}
public struct ScalarConstructor {
    public let box: AllocationBox
    @_noAllocation
    @inline(never)
    public init(_ value: Int) { box = AllocationBox(value) }
}
