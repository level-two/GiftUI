public struct ScalarConstructor {
    public let value: Int
    @_noAllocation
    @inline(never)
    public init(_ value: Int) { self.value = value }
}
