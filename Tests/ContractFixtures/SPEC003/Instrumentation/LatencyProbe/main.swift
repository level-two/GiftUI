@testable import GiftUIFailureCore

private struct ProbePolicy: GiftUIResidualFailurePolicy {
    mutating func disposition(
        for input: GiftUIResidualPolicyInput<UInt8>
    ) -> GiftUIResidualDisposition {
        input.context == 0 ? .continueOperation : .markFacilityUnavailable
    }
}

@inline(never)
private func exercise(seed: UInt8) -> UInt32 {
    let normalized = GiftUIFailureNormalization.normalizeFailure(
        condition: GiftUIConditionID(rawValue: UInt16(seed) + 1),
        origin: .backend,
        affectedScope: .component,
        producerContainmentRawValue: GiftUIContainment.contained.rawValue
    )
    let propagated = GiftUIFailureNormalization.propagate(normalized)
    let outcome = GiftUIOutcome<Void>.failure(propagated)
    let input = GiftUIResidualPolicyInput(
        outcome: outcome,
        context: seed & 1,
        allowed: [.continueOperation, .markFacilityUnavailable],
        attemptOrdinal: 0,
        attemptLimit: 1
    )!
    var policy = ProbePolicy()
    let disposition = policy.disposition(for: input)
    var health = GiftUIOperationalHealth()
    health.recordFailure(propagated, resultingState: .degraded)
    let selection = GiftUIDiagnosticSelection(
        kindMask: 1 << GiftUIDiagnosticKind.failureOutcome.rawValue,
        originMask: 1 << GiftUIFailureOrigin.backend.rawValue,
        minimumSeverity: .warning
    )
    let selected = selection.includes(
        kind: .failureOutcome,
        origin: .backend,
        severity: seed & 1 == 0 ? .warning : .error
    )
    return UInt32(propagated.condition.rawValue)
        &+ UInt32(disposition.rawValue)
        &+ health.transitionCount
        &+ health.failureCount
        &+ UInt32(health.state.rawValue)
        &+ (selected ? 1 : 0)
}

private func nanoseconds(_ duration: Duration) -> UInt64 {
    let parts = duration.components
    let seconds = UInt64(parts.seconds)
    let fractional = UInt64(parts.attoseconds / 1_000_000_000)
    return seconds &* 1_000_000_000 &+ fractional
}

let clock = ContinuousClock()
var checksum: UInt32 = 0
for iteration in UInt32(0) ..< 1_000 {
    checksum &+= exercise(seed: UInt8(truncatingIfNeeded: iteration))
}

var samples = [UInt64]()
samples.reserveCapacity(10_000)
for iteration in UInt32(0) ..< 10_000 {
    let start = clock.now
    checksum &+= exercise(seed: UInt8(truncatingIfNeeded: iteration))
    samples.append(nanoseconds(start.duration(to: clock.now)))
}

let sorted = samples.sorted()
let percentileIndex = (sorted.count * 99 + 99) / 100 - 1
let p99 = sorted[percentileIndex]
#if GIFTUI_RASPBERRY_PI_PROFILE
    let p99LimitNanoseconds: UInt64 = 150_000
#else
    let p99LimitNanoseconds: UInt64 = 100_000
#endif
print("warmup_iterations=1000")
print("measured_iterations=10000")
print("p99_nanoseconds=\(p99)")
print("p99_limit_nanoseconds=\(p99LimitNanoseconds)")
print("checksum=\(checksum)")
for (index, sample) in samples.enumerated() {
    print("sample_nanoseconds[\(index)]=\(sample)")
}

if p99 > p99LimitNanoseconds {
    fatalError("SPEC-003 p99 latency exceeds the profile limit")
}
