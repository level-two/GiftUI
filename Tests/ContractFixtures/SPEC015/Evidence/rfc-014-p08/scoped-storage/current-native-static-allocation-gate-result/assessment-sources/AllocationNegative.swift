public final class AllocationBox { let value: Int; init(_ value: Int) { self.value = value } }
@_noAllocation
@inline(never)
public func allocationNegative(_ input: Int) -> AllocationBox { AllocationBox(input) }
