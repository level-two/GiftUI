@testable import GiftUIFailureCore

@_silgen_name("giftui_allocation_probe_reset")
private func resetAllocationCount()

@_silgen_name("giftui_allocation_probe_read")
private func readAllocationCount() -> UInt64

private struct ProbePolicy: GiftUIResidualFailurePolicy {
    mutating func disposition(
        for input: GiftUIResidualPolicyInput<UInt8>
    ) -> GiftUIResidualDisposition {
        input.context == 0 ? .continueOperation : .markFacilityUnavailable
    }
}

@inline(never)
private func dispatch<Policy: GiftUIResidualFailurePolicy>(
    policy: inout Policy,
    input: GiftUIResidualPolicyInput<Policy.Context>
) -> GiftUIResidualDisposition {
    policy.disposition(for: input)
}

@inline(never)
private func exercise(seed: UInt8) -> (checksum: UInt32, countedSteps: UInt16) {
    var countedSteps: UInt16 = 0
    let normalized = GiftUIFailureNormalization.normalizeFailure(
        condition: GiftUIConditionID(rawValue: UInt16(seed) + 1),
        origin: .backend,
        affectedScope: .component,
        producerContainmentRawValue: GiftUIContainment.contained.rawValue
    )
    countedSteps += 5
    let propagated = GiftUIFailureNormalization.propagate(normalized)
    countedSteps += 4
    let outcome = GiftUIOutcome<Void>.failure(propagated)
    countedSteps += 1
    let input = GiftUIResidualPolicyInput(
        outcome: outcome,
        context: seed & 1,
        allowed: [.continueOperation, .markFacilityUnavailable],
        attemptOrdinal: 0,
        attemptLimit: 1
    )!
    countedSteps += 12
    var policy = ProbePolicy()
    let disposition = dispatch(policy: &policy, input: input)
    countedSteps += 2
    var health = GiftUIOperationalHealth()
    health.recordFailure(propagated, resultingState: .degraded)
    countedSteps += 8
    let checksum = UInt32(propagated.condition.rawValue)
        &+ UInt32(disposition.rawValue)
        &+ health.transitionCount
        &+ health.failureCount
        &+ UInt32(health.state.rawValue)
    countedSteps += 5
    return (checksum, countedSteps)
}

var warmup: UInt32 = 0
for index in UInt8(0) ..< 100 {
    warmup &+= exercise(seed: index).checksum
}

resetAllocationCount()
var checksum = warmup
var maximumCountedSteps: UInt16 = 0
for iteration in UInt32(0) ..< 10_000 {
    let result = exercise(seed: UInt8(truncatingIfNeeded: iteration))
    checksum &+= result.checksum
    maximumCountedSteps = max(maximumCountedSteps, result.countedSteps)
}
let allocationCount = readAllocationCount()

print("allocation_count=\(allocationCount)")
print("maximum_counted_steps=\(maximumCountedSteps)")
print("checksum=\(checksum)")

if allocationCount != 0 || maximumCountedSteps > 64 {
    fatalError("SPEC-003 correctness-path instrumentation failed")
}
