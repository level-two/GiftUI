import GiftUIFailureCore
import GiftUIFailureDiagnostics
import GiftUIFailureExecution

public nonisolated(unsafe) var giftuiSpec003Health = GiftUIOperationalHealth()
public nonisolated(unsafe) var giftuiSpec003DiagnosticBuffer = GiftUIFixedDiagnosticBuffer()
public nonisolated(unsafe) var giftuiSpec003DiagnosticCounters =
    GiftUIDiagnosticDeliveryCounters()

@_cdecl("giftui_spec003_named_storage_probe")
public func giftuiSpec003NamedStorageProbe() -> UInt32 {
    giftuiSpec003Health.failureCount
        &+ UInt32(giftuiSpec003DiagnosticBuffer.count)
        &+ giftuiSpec003DiagnosticCounters.accepted
}

private struct GiftUISpec003ResourcePolicy: GiftUIResidualFailurePolicy {
    mutating func disposition(
        for input: GiftUIResidualPolicyInput<UInt32>
    ) -> GiftUIResidualDisposition {
        input.allowed.contains(.quiesceAffectedScope)
            ? .quiesceAffectedScope
            : .invokeFatalHook
    }
}

@_cdecl("giftui_spec003_resource_entry")
@inline(never)
public func giftuiSpec003ResourceEntry(_ seed: UInt32) -> UInt32 {
    let fact = GiftUIFailureFact(
        condition: .invariantViolation,
        origin: .execution,
        affectedScope: .runtime,
        containment: .safetyNotProven
    )
    let outcome = GiftUIOutcome<Void>.failure(fact)
    var annotations = GiftUIFailureAnnotations()
    _ = annotations.append(GiftUIFailureAnnotation(key: 1, value: seed))
    _ = annotations.append(GiftUIFailureAnnotation(key: 2, value: seed &+ 1))
    let correlated = GiftUICorrelatedFailure(
        fact: fact,
        context: seed,
        annotations: annotations
    )
    var health = GiftUIOperationalHealth()
    health.recordFailure(fact, resultingState: .quiesced)
    guard let input = GiftUIResidualPolicyInput(
        outcome: outcome,
        context: seed,
        allowed: [.quiesceAffectedScope, .invokeFatalHook],
        attemptOrdinal: 0,
        attemptLimit: 1
    ) else {
        return UInt32.max
    }
    var policy = GiftUISpec003ResourcePolicy()
    let disposition = policy.disposition(for: input)
    return correlated.context
        &+ UInt32(correlated.fact.condition.rawValue)
        &+ UInt32(correlated.annotations.count)
        &+ health.failureCount
        &+ UInt32(disposition.rawValue)
}
