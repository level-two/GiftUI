@_silgen_name("giftui_allocation_probe_reset")
private func resetAllocationCount()

@_silgen_name("giftui_allocation_probe_read")
private func readAllocationCount() -> UInt64

var warmup: UInt32 = 0
for seed in UInt32(0) ..< 100 {
    warmup &+= GiftUIFoundationOperationProbe.exercise(seed: seed)
}

resetAllocationCount()
var checksum = warmup
for seed in UInt32(0) ..< 10_000 {
    checksum &+= GiftUIFoundationOperationProbe.exercise(seed: seed)
}
let allocationCount = readAllocationCount()

print("allocation_count=\(allocationCount)")
print("checksum=\(checksum)")

if allocationCount != 0 {
    fatalError("SPEC-002 construction/arithmetic path allocated")
}
