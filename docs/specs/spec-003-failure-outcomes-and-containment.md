---
id: SPEC-003
feature: giftui-mvp-architecture
title: Failure Outcomes and Containment
status: draft
authors:
  - codex
created: 2026-08-22
updated: 2026-08-24
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-005
related_adrs:
  - ADR-014
  - ADR-015
  - ADR-016
related_specs:
  - SPEC-001
  - SPEC-002
  - SPEC-004
related_future_work:
  - FW-009
  - FW-012
  - FW-013
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-003: Failure Outcomes and Containment

## Summary

This Specification defines the shared, bounded meaning of GiftUI outcomes,
failure containment, affected scope, layered disposition, explicit operational
health projection, and optional diagnostics. It establishes pure fixtures for
mapping producer facts into portable outcomes and for proving that policy and
diagnostic configuration cannot weaken correctness.

This is the `FAILURE` contract in the MVP Specification Portfolio. It freezes
the common Swift vocabulary, finite representations, conservative mappings,
policy-validation seam, operational-health snapshot, diagnostic projection,
and profile budgets needed by downstream Specifications. Concrete producer
condition catalogues, execution identities, coordinator state machines, and
target product-policy tables remain owned by their respective downstream
contracts.

## Scope

This Specification covers:

- profile-neutral outcome categories for success, expected operational
  conditions, and failure;
- source-stable condition identity within one build, stable origin, affected
  scope, and conservative containment;
- the ordered responsibilities of detecting contracts, owning coordinators,
  and target-composition policy;
- explicit operational-health facts and transitions as correctness-relevant
  state distinct from diagnostic history;
- bounded, optional diagnostic projection from outcomes and health
  transitions;
- pure outcome-mapping, total-policy, containment, health, and diagnostic-
  isolation fixtures shared by dynamic and static profiles; and
- the physical dependency boundary between foundational failure facts,
  execution correlation, target policy, and optional diagnostics.

The contract applies to macOS dynamic, macOS static, Raspberry Pi/Linux
dynamic, and nRF52840 static configurations. It does not define the execution
phase machine, backend handoff protocol, capability catalogue, or a particular
platform's product policy.

### Ownership boundary

`FAILURE` exclusively owns outcome, containment, affected-scope, layered-
disposition, operational-health-projection, and diagnostic vocabulary.

- `FOUNDATION` / SPEC-002 owns portable values and import boundaries. This
  Specification references that ownership wherever downstream envelopes use
  those values and MUST NOT define competing geometry, identity-storage, or
  portability primitives. In accordance with ADR-014, `GiftUIFailureCore`
  itself uses only language-level fixed-width primitives and MUST NOT import
  the `GiftUI` module that owns Foundation values.
- `CAPABILITY` / SPEC-004 owns capability contribution, resolution, and
  immutable effective-capability semantics. This Specification MUST NOT
  redefine them. The foundational `GiftUICapabilities` module MUST NOT import
  failure. A target-host adapter outside that module may map a capability-
  domain unavailable result into this Specification's outcome vocabulary.
- Downstream execution Specifications own cycle, revision, frame, publication,
  and handoff state machines. `GiftUIFailureExecution` only correlates those
  externally owned identities with failure facts.
- Backend and host Specifications own concrete normalization tables and total
  product-policy choices for their boundaries. They MUST use, rather than
  reinterpret, this Specification's vocabulary.

## Goals

- Provide one finite, allocation-free portable meaning for equivalent
  outcomes in static and dynamic profiles.
- Make conservative containment and affected scope explicit and testable.
- Ensure every remaining product-policy choice is total, bounded, and no less
  safe than the detecting and coordinating contracts require.
- Keep operational health queryable independently of optional or lossy
  diagnostics.
- Make diagnostic enablement, filtering, saturation, omission, and sink
  failure observationally irrelevant to correctness.
- Supply a hardware-free acceptance seam usable before renderer, runtime,
  backend, or target implementations exist.

## Non-goals

- Defining portable Foundation values or changing module import boundaries
  owned by SPEC-002.
- Defining capability contribution, host resolution, effective capabilities,
  or capability absence/failure semantics owned by SPEC-004.
- Defining execution phases, publication, frame commit, refusal recovery,
  post-handoff presentation mechanics, or input gating.
- Defining one product policy, retry schedule, fatal hook, or target-specific
  policy table for all supported configurations.
- Exposing framework-internal failures as ordinary portable-view control flow.
- Promising stable numeric condition identifiers across builds or versions,
  a serialized error ABI, a global identity registry, or a telemetry schema.
- Adding finer containment classes, rollback, nested semantic execution, or
  condition-specific recovery beyond the accepted conservative MVP model.
- Creating a general `GiftUIServices` package or mandatory global diagnostic
  service.

## Dependencies

### Lifecycle authority

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
  is accepted.
- [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md) supplies the
  approved import partial order and foundational ownership constraints.
- [RFC-005](../rfcs/rfc-005-failure-diagnostics-propagation.md) is approved.
- [ADR-014](../adrs/adr-014-bounded-cross-layer-outcomes.md),
  [ADR-015](../adrs/adr-015-layered-failure-disposition.md), and
  [ADR-016](../adrs/adr-016-non-authoritative-diagnostics.md) are accepted.

### Specification and module dependencies

Wave 1 has no earlier Specification drafting prerequisite. Coordination with
SPEC-002 and SPEC-004 is nevertheless required before this draft can enter
review so the three Specifications use the declarations and owner-adapter
seams frozen below and do not claim the same contract.

The required physical dependency direction is:

```text
target host / composition policy
    |-> runtime or backend ----------> GiftUIFailureExecution
    |                                      |-> execution contract
    |                                      \-> GiftUIFailureCore
    |-> integration adapter ---------> GiftUIFailureCore
    \-> optional diagnostic adapter -> GiftUIFailureCore

driver / transport / HAL -----------> GiftUIFailureCore
```

`GiftUIFailureCore` has no dependency on `GiftUI`, execution, runtime, layout,
rendering, backend, platform, driver, OS/RTOS, HAL, capability, or diagnostic
implementations. `GiftUIFailureExecution` imports only `GiftUIFailureCore` and
the focused execution contract. The execution contract MUST NOT import
`GiftUIFailureExecution`.

## Related ADRs

- **ADR-014 — Bounded Cross-Layer Outcome Meaning** governs the three outcome
  categories, stable origin and source identity, affected scope, conservative
  containment, unknown-value mapping, and the split between
  `GiftUIFailureCore` and `GiftUIFailureExecution`.
- **ADR-015 — Layered Failure Disposition Ownership** governs the strict order
  of detecting-layer containment, coordinator-mandated effects, and only then
  total composition-owned selection among remaining safe choices.
- **ADR-016 — Non-Authoritative Diagnostic Projection** governs optional
  bounded diagnostics, explicit operational health independent of diagnostic
  history, and the prohibition on diagnostic or callback paths gaining
  semantic authority.

## Terminology

- **Outcome:** A bounded result of a fallible cross-layer operation. Its
  category is success, operational, or failure.
- **Success:** The operation fulfilled its contract.
- **Operational condition:** An expected bounded condition that requires an
  explicit local or coordinating disposition without asserting a broken
  invariant.
- **Failure:** The operation did not fulfill its contract and supplies a
  failure fact.
- **Failure fact:** The portable combination of source-stable condition
  identity, origin, affected scope, and containment.
- **Origin:** The stable producing contract or subsystem identity. Wrapping a
  fact MUST preserve its original origin.
- **Condition identity:** A source-level identity stable within the producing
  build and shared fixtures. Its numeric representation is not durable across
  builds or versions.
- **Affected scope:** The smallest scope for which the detecting contract can
  prove the reported condition applies: local operation, active cycle,
  candidate frame, owning component/integration, or assembled runtime.
- **Contained:** The detecting contract proved that partial work was rejected
  or invalidated and that normal processing remains safe outside the reported
  affected scope.
- **Safety not proven:** The detecting contract cannot prove contained
  continuation for the reported scope. Unknown or richer profile-specific
  containment maps to this value.
- **Mechanical containment:** Mandatory local rejection, invalidation,
  draining, or resource-release behavior owned by the detecting contract.
- **Coordinator disposition:** Mandatory operation, publication, or frame-
  transaction behavior owned by the coordinator after local containment.
- **Residual product choice:** A safe choice that remains after mechanical
  containment and coordinator disposition and may therefore be selected by
  target composition.
- **Total policy:** A bounded policy that maps every possible input in its
  declared domain to one explicitly allowed residual product choice.
- **Operational health:** Explicit bounded current integration or component
  state, including any required counters, that correctness may query without
  reconstructing it from diagnostics.
- **Diagnostic projection:** An optional bounded observation derived from an
  outcome or health transition. It has no control-flow or health authority.

## Public Contract

Portable views MUST NOT be required to catch or interpret framework-internal
failure facts. A host- or integration-facing API MAY expose bounded startup,
component, operation, cycle, or frame outcomes only when the caller owns a
meaningful disposition.

For the same normalized input and configured policy, static and dynamic
profiles MUST expose equivalent outcome category, condition identity, origin,
affected scope, containment, mandatory disposition, residual policy input,
and operational-health result. Diagnostic configuration MUST NOT change any
of those observations.

No public API may represent a numeric condition identity as persistent,
cross-process, cross-device, or cross-version data under this Specification.

## Module Contract

`GiftUIFailureCore` MUST own only the foundational portable vocabulary. It
MUST permit low-level producers to construct a failure fact without importing
execution, runtime, backend, capability, policy, or diagnostic code.

`GiftUIFailureExecution` MUST own only correlation between a core fact and
identities or positions supplied by the focused execution contract. The first
owner that knows both facts constructs the correlation. Low-level producers
MUST NOT manufacture execution context.

A detecting module MUST perform its contract-mandated mechanical containment
and return the original outcome. A coordinator MUST then apply every mandatory
effect belonging to its operation or transaction. Only a remaining residual
choice may be presented to target-composition policy.

Operational-health storage MUST be owned by the component or integration
whose current health it represents. Diagnostic adapters MAY observe a bounded
projection of its transitions but MUST NOT own, reconstruct, or mutate that
health.

Diagnostic adapters MUST be downstream consumers. No correctness-bearing
module may import an optional diagnostic implementation.

## Types / APIs

The declarations in this section are normative at the level of names, cases,
field meaning, raw-value width, visibility, and behavior. They are source
contracts, not a frozen serialized ABI. Implementations MAY reorder fields or
specialize generic storage when all `MemoryLayout` maxima and observable
semantics remain satisfied.

### Core identifiers and facts

`GiftUIFailureCore` MUST export the following `public`, value-semantic,
`Sendable`, and `Equatable` declarations. Raw-value wrappers MUST reject no
bit pattern; reserved or producer-unknown values are normalized by the owner
adapter before a fact reaches a coordinator.

```swift
public struct GiftUIConditionID: RawRepresentable, Sendable, Equatable {
    public let rawValue: UInt16
    public init(rawValue: UInt16)
    public static let unknownProducerCondition: Self
    public static let invalidValue: Self
    public static let arithmeticOverflow: Self
    public static let capacityExhausted: Self
    public static let invalidIdentity: Self
    public static let invalidProvenance: Self
    public static let invalidPhase: Self
    public static let reentrancyViolation: Self
    public static let requiredFacilityUnavailable: Self
    public static let nonRetryableRefusal: Self
    public static let invariantViolation: Self
}

public enum GiftUIFailureOrigin: UInt8, Sendable {
    case foundation = 0
    case capability = 1
    case semantic = 2
    case layout = 3
    case rendering = 4
    case execution = 5
    case observableState = 6
    case interaction = 7
    case backend = 8
    case presentationIntegration = 9
    case inputIntegration = 10
    case hostComposition = 11
    case displayDriver = 12
    case inputDriver = 13
    case transport = 14
}

public enum GiftUIAffectedScope: UInt8, Sendable {
    case operation = 0
    case activeCycle = 1
    case candidateFrame = 2
    case component = 3
    case runtime = 4
}

public enum GiftUIContainment: UInt8, Sendable {
    case contained = 0
    case safetyNotProven = 1
}

public struct GiftUIFailureFact: Sendable, Equatable {
    public let condition: GiftUIConditionID
    public let origin: GiftUIFailureOrigin
    public let affectedScope: GiftUIAffectedScope
    public let containment: GiftUIContainment

    public init(
        condition: GiftUIConditionID,
        origin: GiftUIFailureOrigin,
        affectedScope: GiftUIAffectedScope,
        containment: GiftUIContainment
    )
}
```

The pair `(origin, condition)` is the source-stable condition identity. A
producer contract MUST declare every condition constant in source and MUST
keep each raw value unique within its origin for the lifetime of one build and
its generated conformance fixtures. `0` is reserved for
`unknownProducerCondition`; raw values `1...10` have the shared meanings below,
and producer-specific catalogues allocate additional named conditions from
`11...65535`. Reuse across origins is allowed. No raw value is durable across
builds or versions.

The shared catalogue below fixes meanings needed by more than one MVP
producer. A producer MAY define additional origin-local constants when its
own Specification defines their mapping and fixtures.

| Raw value | Shared source name | Required meaning |
| ---: | --- | --- |
| `0` | `unknownProducerCondition` | Native or future producer condition has no approved portable mapping |
| `1` | `invalidValue` | A normalized or requested value violates the receiving contract |
| `2` | `arithmeticOverflow` | Checked integer arithmetic could not represent the result |
| `3` | `capacityExhausted` | A correctness-bearing fixed capacity cannot admit or produce more work |
| `4` | `invalidIdentity` | A bounded identity is absent, stale, aliased, or otherwise invalid |
| `5` | `invalidProvenance` | Source, sequence, revision, or frame provenance is not admissible |
| `6` | `invalidPhase` | The operation is forbidden at the current owning phase |
| `7` | `reentrancyViolation` | Reentrant work bypassed its required admission boundary |
| `8` | `requiredFacilityUnavailable` | A required configured facility cannot provide its approved semantics |
| `9` | `nonRetryableRefusal` | A synchronous owner refused before acceptance and declared no retry path |
| `10` | `invariantViolation` | A producer invariant failed without a more specific approved condition |

The SPEC-002 owner adapter MUST use these exact mappings after the Foundation
operation has returned `nil` and discarded partial output:

| Foundation rejection | Condition | Origin | Scope | Containment |
| --- | --- | --- | --- | --- |
| Negative dimension or invalid proposed dimension | `invalidValue` | `foundation` | `operation` | `contained` |
| Scalar arithmetic overflow | `arithmeticOverflow` | `foundation` | `operation` | `contained` |
| Unrepresentable rectangle exclusive edge | `arithmeticOverflow` | `foundation` | `operation` | `contained` |
| Physical-to-logical input conversion outside `GeometryScalar` | `arithmeticOverflow` | `foundation` | `operation` | `contained` |

The SPEC-004 host adapter MUST map every closed
`RasterPresentationUnavailable` case to the following producer-specific
condition identity. The names and raw values are fixed for source and shared-
fixture use within one build; they are not durable serialized identifiers.

| `RasterPresentationUnavailable` case | Capability condition name | Raw value |
| --- | --- | ---: |
| `malformedRequirement` | `rasterMalformedRequirement` | `12` |
| `duplicateContributor` | `rasterDuplicateContributor` | `13` |
| `missingContributor` | `rasterMissingContributor` | `14` |
| `malformedContribution` | `rasterMalformedContribution` | `15` |
| `insufficientCapacity` | `rasterInsufficientCapacity` | `16` |
| `operationSetMismatch` | `rasterOperationSetMismatch` | `17` |
| `operationStreamMismatch` | `rasterOperationStreamMismatch` | `18` |
| `logicalExtentOverflow` | `rasterLogicalExtentOverflow` | `19` |
| `unsupportedLogicalExtent` | `rasterUnsupportedLogicalExtent` | `20` |
| `noCommonCanonicalPixelEncoding` | `rasterNoCommonCanonicalPixelEncoding` | `21` |
| `incompatibleSubmissionLifetime` | `rasterIncompatibleSubmissionLifetime` | `22` |
| `incompatibleSubmissionHandoff` | `rasterIncompatibleSubmissionHandoff` | `23` |
| `policyHasNoConformingRealization` | `rasterPolicyHasNoConformingRealization` | `24` |
| `byteCountOverflow` | `rasterByteCountOverflow` | `25` |

Raw value `11` is intentionally unassigned. The closed four-role typed buffer
cannot produce a distinct contribution-capacity condition: every insertion
after all four roles are occupied is necessarily a duplicate role.

For a required family, the host adapter MUST enclose the mapped fact as the
`.failure` case of `GiftUIOutcome<CapabilitySnapshot>`. The fact MUST use
`.capability` origin, `.runtime` affected scope, and `.contained`
containment. The originating `RasterPresentationUnavailable` remains the
capability-domain validation result; associated field, role, and capacity
payloads MAY be projected as bounded annotations or diagnostics but MUST NOT
change the primary condition identity. `GiftUIFailureCore` does not import
`GiftUICapabilities`; the generic carrier is instantiated only by the
downstream host adapter that knows both contracts.

The shared `requiredFacilityUnavailable` condition is reserved for later
operational loss of a previously configured required facility and MUST NOT
collapse the SPEC-004 initialization-validation catalogue.

`MemoryLayout<GiftUIConditionID>.size` MUST equal 2 bytes and
`MemoryLayout<GiftUIFailureFact>.size` MUST be no greater than 8 bytes on every
MVP profile. No declaration in `GiftUIFailureCore` may contain a reference,
existential, closure, string, collection, or platform-native error.
Affected-scope raw values are tags, not an ordering: `activeCycle` and
`candidateFrame` are distinct transaction scopes and neither is implicitly
narrower than the other. Any scope change requires the explicit proof stated
under Conservative Mapping.

### Operational outcomes

Expected bounded conditions use a closed shared kind rather than a failure
containment value:

```swift
public enum GiftUIOperationalKind: UInt8, Sendable {
    case noChange = 0
    case cacheMiss = 1
    case backpressured = 2
    case superseded = 3
    case deferredToLaterAdmission = 4
    case retryableRefusal = 5
}

public struct GiftUIOperationalFact: Sendable, Equatable {
    public let kind: GiftUIOperationalKind
    public let origin: GiftUIFailureOrigin
    public let affectedScope: GiftUIAffectedScope

    public init(
        kind: GiftUIOperationalKind,
        origin: GiftUIFailureOrigin,
        affectedScope: GiftUIAffectedScope
    )
}

public enum GiftUIOutcome<Success> {
    case success(Success)
    case operational(GiftUIOperationalFact)
    case failure(GiftUIFailureFact)
}
```

`GiftUIOutcome` MUST be conditionally `Sendable` and `Equatable` when
`Success` is. It MUST add no allocation of its own. Success payload ownership
and capacity remain with the producing contract. An adapter receiving an
unknown native outcome category or an unknown operational kind MUST produce
`unknownProducerCondition` with `safetyNotProven` for the smallest scope it
can prove; it MUST NOT guess a known operational case.

`MemoryLayout<GiftUIOperationalFact>.size` MUST be no greater than 4 bytes.

### Bounded annotation and execution correlation

Core facts never acquire execution identity. A boundary that adds portable
annotation uses at most two entries:

```swift
public struct GiftUIFailureAnnotation: Sendable, Equatable {
    public let key: UInt16
    public let value: UInt32
    public init(key: UInt16, value: UInt32)
}

public struct GiftUIFailureAnnotations: Sendable, Equatable {
    public static let capacity: UInt8 = 2
    public private(set) var count: UInt8
    public init()
    public mutating func append(_ annotation: GiftUIFailureAnnotation) -> Bool
    public subscript(index: UInt8) -> GiftUIFailureAnnotation? { get }
}
```

The storage MUST be inline and allocation-free. `append` returns `false` and
leaves the existing entries and order unchanged when both slots are occupied.
Annotation exhaustion never replaces or modifies the failure fact and MAY
increment an optional diagnostic counter only after propagation continues.
Keys are producer-contract-local and are not a global or durable registry.
`MemoryLayout<GiftUIFailureAnnotations>.size` MUST be no greater than 20
bytes.

`GiftUIFailureExecution` MUST export an allocation-free generic correlation
envelope whose `Context` is supplied by the focused execution contract:

```swift
public struct GiftUICorrelatedFailure<Context> {
    public let fact: GiftUIFailureFact
    public let context: Context
    public let annotations: GiftUIFailureAnnotations
    public init(
        fact: GiftUIFailureFact,
        context: Context,
        annotations: GiftUIFailureAnnotations = .init()
    )
}
```

It is conditionally `Sendable` and `Equatable` when `Context` is. Constructing
the envelope preserves every field of `fact` unchanged. The future EXECUTION
Specification owns `Context`, cycle/revision/frame widths, and transaction
position; this Specification owns only the one-way correlation behavior.

### Residual policy seam

```swift
public enum GiftUIResidualDisposition: UInt8, Sendable {
    case continueOperation = 0
    case requestPacedRetry = 1
    case markFacilityUnavailable = 2
    case quiesceAffectedScope = 3
    case invokeFatalHook = 4
}

public struct GiftUIAllowedDispositions: OptionSet, Sendable, Equatable {
    public let rawValue: UInt8
    public init(rawValue: UInt8)
    public static let continueOperation: Self
    public static let requestPacedRetry: Self
    public static let markFacilityUnavailable: Self
    public static let quiesceAffectedScope: Self
    public static let invokeFatalHook: Self
}

public struct GiftUIResidualPolicyInput<Context> {
    public let outcome: GiftUIOutcome<Void>
    public let context: Context
    public let allowed: GiftUIAllowedDispositions
    public let attemptOrdinal: UInt8
    public let attemptLimit: UInt8
    public init?(
        outcome: GiftUIOutcome<Void>,
        context: Context,
        allowed: GiftUIAllowedDispositions,
        attemptOrdinal: UInt8,
        attemptLimit: UInt8
    )
}

public protocol GiftUIResidualFailurePolicy {
    associatedtype Context
    mutating func disposition(
        for input: GiftUIResidualPolicyInput<Context>
    ) -> GiftUIResidualDisposition
}
```

The initializer is the only public construction seam and returns `nil`, with
no partial value, unless all of the following are true:

- `outcome` is `.operational` or `.failure`, never `.success`;
- `allowed` is non-empty and contains only the five declared bits;
- `attemptLimit` is in `1...255` and `attemptOrdinal < attemptLimit`;
- `continueOperation` is absent for a safety-not-proven failure;
- a runtime-scoped safety-not-proven failure allows no value other than
  `quiesceAffectedScope` or `invokeFatalHook`; and
- `requestPacedRetry`, when present, applies only to `backpressured` or
  `retryableRefusal` and satisfies `attemptOrdinal + 1 < attemptLimit`.

Thus empty or unknown disposition bits, success outcomes, zero attempt limits,
out-of-range ordinals, exhausted retry ordinals, and semantically forbidden
choices have one deterministic disposition: construction failure. They never
reach a policy. The returned policy value MUST belong to `allowed`. Returning
an unlisted value is a runtime-scope
`invariantViolation` with `safetyNotProven`; the coordinator MUST prevent
normal continuation and MAY trap if it cannot safely propagate that fact.
The five declared option bits are `1 << disposition.rawValue`; bits 5 through
7 are reserved and make an input invalid. A policy input MUST contain a
non-success outcome. `Context` in each concrete policy MUST have a finite,
fixture-enumerable domain and MUST use value storage on a static profile.

A concrete target table and pacing interval are HOST-CONFIGURATION
responsibilities. That owner MUST treat unexpected `nil` from construction as
its own invariant violation; it MUST NOT repair or broaden invalid input before
calling policy. It also MUST derive `allowed` only after mechanical containment
and mandatory coordinator effects; the generic initializer cannot rediscover
owner-specific actions from the bit set alone.

### Operational health

```swift
public enum GiftUIOperationalHealthState: UInt8, Sendable {
    case available = 0
    case degraded = 1
    case unavailable = 2
    case quiesced = 3
}

public struct GiftUIOperationalHealth: Sendable, Equatable {
    public private(set) var state: GiftUIOperationalHealthState
    public private(set) var transitionCount: UInt32
    public private(set) var operationalCount: UInt32
    public private(set) var failureCount: UInt32
    public private(set) var countersSaturated: Bool

    public init(state: GiftUIOperationalHealthState = .available)

    public mutating func recordOperational(
        _ fact: GiftUIOperationalFact,
        resultingState: GiftUIOperationalHealthState
    )
    public mutating func recordFailure(
        _ fact: GiftUIFailureFact,
        resultingState: GiftUIOperationalHealthState
    )
}
```

Each call increments the matching outcome counter. When the current state is
not `quiesced`, it increments `transitionCount` only when `state` changes and
commits `resultingState` before returning. When the current state is
`quiesced`, the requested resulting state is ignored: the matching outcome
counter still increments, `state` remains `quiesced`, and `transitionCount`
does not increment. Counters saturate at `UInt32.max`; the first saturation sets
`countersSaturated` permanently. Counter saturation never wraps and never
prevents a permitted state update. `MemoryLayout<GiftUIOperationalHealth>.size` MUST
be no greater than 20 bytes. An owner MAY maintain additional typed counters
under its own Specification, but diagnostics cannot be their authority.

An owner contract may permit transitions among `available`, `degraded`, and
`unavailable` as its bounded recovery mechanics require. Any of those states
may enter `quiesced` after mandatory disposition or valid residual policy.
`quiesced` is terminal for the assembled runtime lifetime: restoring service
requires teardown and construction of a new runtime. A runtime-scoped failure
with `safetyNotProven` MUST result in `quiesced` before normal processing can
return. Re-recording the current state is legal, updates the matching outcome
counter, and does not increment `transitionCount`.

### Diagnostic projection

```swift
public enum GiftUIDiagnosticKind: UInt8, Sendable {
    case operationalOutcome = 0
    case failureOutcome = 1
    case healthTransition = 2
    case residualDisposition = 3
}

public enum GiftUIDiagnosticSeverity: UInt8, Sendable {
    case debug = 0
    case information = 1
    case notice = 2
    case warning = 3
    case error = 4
    case critical = 5
}

public struct GiftUIDiagnosticSelection: Sendable, Equatable {
    public let kindMask: UInt8
    public let originMask: UInt16
    public let minimumSeverity: GiftUIDiagnosticSeverity

    public init(
        kindMask: UInt8,
        originMask: UInt16,
        minimumSeverity: GiftUIDiagnosticSeverity
    )

    public func includes(
        kind: GiftUIDiagnosticKind,
        origin: GiftUIFailureOrigin,
        severity: GiftUIDiagnosticSeverity
    ) -> Bool
}

public struct GiftUIDiagnosticRecord: Sendable, Equatable {
    public let kind: GiftUIDiagnosticKind
    public let severity: GiftUIDiagnosticSeverity
    public let flags: UInt16
    public let origin: GiftUIFailureOrigin
    public let affectedScope: GiftUIAffectedScope
    public let condition: UInt16
    public let correlation0: UInt32
    public let correlation1: UInt32
    public let observation0: UInt32
    public let observation1: UInt32

    public init(
        kind: GiftUIDiagnosticKind,
        severity: GiftUIDiagnosticSeverity,
        flags: UInt16,
        origin: GiftUIFailureOrigin,
        affectedScope: GiftUIAffectedScope,
        condition: UInt16,
        correlation0: UInt32 = 0,
        correlation1: UInt32 = 0,
        observation0: UInt32 = 0,
        observation1: UInt32 = 0
    )
}

public enum GiftUIDiagnosticSinkResult: UInt8, Sendable {
    case accepted = 0
    case dropped = 1
    case saturated = 2
    case failed = 3
}

public protocol GiftUIDiagnosticSink {
    mutating func consume(
        _ record: GiftUIDiagnosticRecord
    ) -> GiftUIDiagnosticSinkResult
}
```

`flags` uses bit 0 for `contained`, bit 1 for `safetyNotProven`, bit 2 for
`countersSaturated`, and bit 3 for `contextTruncated`; all other bits are zero
in MVP. Unused condition, correlation, and observation words are zero.
Execution and owner adapters define the meaning of nonzero correlation and
observation words in source and fixtures; the record itself is not serialized
or stable across builds.

For `operationalOutcome`, `condition` is the operational-kind raw value. For
`failureOutcome`, it is the failure-condition raw value. For
`healthTransition`, it is the resulting health-state raw value and
`observation0` contains the prior state. For `residualDisposition`, it is the
selected disposition raw value. The projecting adapter assigns severity from
an immutable source-defined table; changing that table may change only which
diagnostic records are selected, never outcome, health, allowed dispositions,
or chosen policy.

`MemoryLayout<GiftUIDiagnosticRecord>.size` MUST be no greater than 24 bytes.
A selection bit `1 << kind.rawValue` or `1 << origin.rawValue` admits that
value; zero masks select nothing. Selection is a pure constant-time operation
and MUST occur before constructing a full record.
A selected sink call occurs only after the originating outcome has propagated
or the authoritative health state has committed. Sink result is recorded only
in optional saturating `UInt32` diagnostic counters and is otherwise ignored.

An optional first-party fixed diagnostic buffer MUST use drop-new saturation:
it preserves admitted record order, never overwrites an admitted record, and
increments a saturating dropped-record counter when full. The default record
capacities are 64 for macOS dynamic, 16 for macOS static, 16 for Raspberry
Pi/Linux dynamic, and 8 for nRF52840 static. A target MAY select capacity zero
to compile out record storage while retaining identical outcome and health
behavior.

All common surfaces above MUST be representable without heap allocation,
strings, exceptions, reflection, unrestricted dynamic dispatch, or a dynamic
registry. A dynamic convenience MAY adapt them at an integration boundary but
MUST preserve the portable meaning and bounds.
The policy and sink protocols MUST be consumed through generic specialization
or static composition on static profiles; existential storage is not part of
the common contract.

## Behavior

### Normal outcome propagation

1. The producer classifies the result as success, operational, or failure.
2. For a failure, the producer reports its original identity, origin, the
   smallest affected scope it can prove, and containment.
3. The detecting contract completes mandatory local containment before
   returning the outcome.
4. Each wrapper preserves the original fact and may add bounded context. It
   MUST NOT replace the original cause, narrow affected scope without proof,
   or upgrade containment.
5. The owning coordinator applies every mandatory operation or transaction
   effect.
6. If safe choices remain, target composition receives a residual policy
   input and selects one bounded allowed response.
7. Outcome and health transitions MAY independently produce diagnostic
   observations after correctness-relevant state is established.

### Conservative mapping

Containment normalization MUST be a pure total function. `contained` maps to
`contained`. `safety not proven`, an unknown representation, and every richer
profile-specific value without an explicit portable proof map to `safety not
proven`. Diagnostics, platform detail, policy, and severity MUST NOT upgrade
that result.

An affected scope MUST NOT become narrower during propagation unless the
contract performing that mapping proves the narrower containment before any
effect. Merely adding diagnostic context is not such proof.

### Layered disposition

Composition policy MUST NOT:

- weaken containment or narrow affected scope;
- override mandatory coordinator behavior;
- reinterpret failure as success;
- manufacture missing semantic support;
- silently fall back;
- retry without a finite attempt and pacing bound; or
- use diagnostic presence, severity, delivery, or loss as policy input.

If safe propagation is impossible, the detecting boundary MAY trap when its
contract requires it. A trap is mechanical enforcement of that boundary, not
a target-composition product choice.

### Operational health and diagnostics

Correctness-relevant operational health MUST be updated and queryable even
when diagnostics are disabled, filtered, saturated, dropped, or failing.
Diagnostic selection MAY occur before record construction. A selected record
MAY then be filtered, discarded, counted, buffered, streamed, symbolized, or
omitted.

Changing diagnostic configuration MUST NOT change outcome propagation,
operational health, semantic state, capability results, frame disposition,
policy inputs, or policy results. A diagnostic sink, callback, interrupt,
backend, or driver MUST NOT mutate semantic state or invoke client actions.

## State / Lifecycle

A core failure fact is immutable after construction. Correlation creates a
new envelope and does not mutate or replace the core fact.

Operational health belongs to one component or integration. A transition MUST
update the authoritative bounded health state before any optional diagnostic
projection of that transition. Diagnostic loss does not create, erase, or
reorder health transitions.

Outcome handling follows one forward-only lifecycle:

```text
detect -> mechanically contain -> preserve outcome
       -> apply mandatory coordinator disposition
       -> select any residual product choice
       -> optionally project diagnostics
```

No diagnostic path may re-enter an earlier stage. An approved asynchronous
outcome that is allowed to affect Core MUST enter through its own bounded,
sequenced admission contract; diagnostics are never that admission contract.

Initialization and teardown of diagnostic adapters MUST NOT change failure or
health behavior. After an adapter is unavailable or torn down, outcomes and
health updates continue according to the same contract and observations may
be omitted.

## Capability Requirements

This Specification declares no capability contribution, resolution rule, or
default. Those are owned by SPEC-004.

Failure disposition MAY react to operational loss only through an explicitly
owned health or target-policy seam. It MUST NOT mutate immutable effective-
capability meaning, manufacture support, or treat a missing required
capability as a diagnostic choice. Whether an operational-health transition
changes facility availability is a capability/host contract, not a decision
made here.

## Backend Requirements

A backend or integration boundary MUST normalize native errors into this
portable vocabulary before a core coordinator or composition policy consumes
them. Platform-native strings, exception types, error codes, or richer
containment details MAY remain available to optional diagnostics but MUST NOT
weaken the normalized outcome.

Pre-handoff and post-handoff ownership is supplied by downstream execution and
backend contracts. This Specification requires only that pre-handoff facts use
the typed outcome path and that post-handoff operational conditions cannot be
reclassified as an earlier refusal or reopen committed Core work.

Low-level drivers and transports MUST depend only on `GiftUIFailureCore` when
reporting portable facts. They MUST NOT import execution correlation, runtime,
composition policy, capability resolution, or diagnostics.

## Error Handling

Exhaustion of any correctness-bearing bounded store or admission surface MUST
produce its own deterministic typed outcome. It MUST NOT overwrite admitted
work, silently drop a correctness-relevant fact, reorder facts, recurse into
immediate unbounded retry, or redirect the condition through diagnostics.

Exhaustion or failure of optional diagnostic storage or delivery MUST follow
its configured bounded observation behavior and MUST NOT replace, suppress, or
modify the originating outcome or operational-health update.

Unknown containment fails closed as `safety not proven` for the reported
scope. A failure with safety not proven for runtime scope MUST prevent normal
runtime processing from continuing; target composition may quiesce or invoke
its configured fatal hook, but continuation is not allowed.

## Performance Requirements

- Static-profile construction, normalization, propagation, health update, and
  pure policy dispatch MUST perform zero heap allocations. The measurement
  excludes a caller-owned generic success payload but includes every common
  failure value and adapter named by this Specification.
- The correctness path from a normalized non-success outcome through allowed-
  disposition validation MUST execute at most 64 fixture-counted branch,
  comparison, increment, and store steps, excluding coordinator work owned by
  a downstream Specification. Containment normalization and diagnostic
  selection each MUST execute at most 8 such steps.
- Failure-free execution MUST perform only the outcome tag check and any
  correlation required at the first owning boundary. Diagnostic formatting
  and sink dispatch MUST NOT be part of that path.
- A disabled diagnostic category MUST construct zero
  `GiftUIDiagnosticRecord` values and invoke the sink zero times.
- The common outcome/policy path, compiled with optimization and diagnostics
  disabled, MUST meet these incremental maxima. Writable RAM includes one
  health value, diagnostic counters, and the default buffer when its capacity
  is nonzero; it excludes owner-specific state and the caller's success
  payload.

| Profile fixture | Writable RAM | Worst stack | Linked code | Outcome/policy latency |
| --- | ---: | ---: | ---: | ---: |
| macOS dynamic | 2,048 B | 512 B | 32 KiB | p99 <= 100 us |
| macOS static | 512 B | 384 B | 24 KiB | p99 <= 100 us |
| Raspberry Pi/Linux dynamic | 512 B | 384 B | 24 KiB | p99 <= 150 us |
| nRF52840 static | 320 B | 256 B | 16 KiB | <= 4,096 target instructions |

The reproducible macOS reference runner is an arm64 `Mac15,7` with an Apple M3
Pro (12 cores), 36 GB RAM, macOS 26.3 build 25D125, and Apple Swift 6.3.3
(`swiftlang-6.3.3.1.3`), using `swift test -c release --filter
GiftUIFailureContractTests`. Latency uses at least 10,000 iterations after
1,000 warm-up iterations with no other repository job running. Evidence MUST
record the model identifier, OS build, complete `swift --version`, command,
commit, and raw samples; results from another runner are informative only
until this reference is deliberately revised with the Specification.

Raspberry Pi latency is measured over the same corpus on a connected machine
that reports `armv6l`. nRF52840 instruction and stack evidence comes from the
optimized board-probe ELF and disassembly and requires no flash operation.
Linked-code evidence is the incremental text contribution relative to the
same empty fixture. Debug, symbolization, and dynamic-only formatting code is
reported separately and is not part of these maxima.

## Compatibility

Equivalent normalized facts MUST have the same source-level identity and
portable meaning in shared static and dynamic conformance fixtures.

Existing throwing, callback-based, or platform-native APIs MAY be adapted at
dynamic or integration boundaries. Such adapters MUST preserve origin,
identity, affected scope, containment, ordering, and disposition and MUST not
make exceptions or callbacks the common GiftUI contract.

Numeric condition representations are build-local. They MUST NOT be persisted,
transmitted, externally symbolized without the exact producing build's map, or
treated as stable across versions. This Specification defines no serialized
failure ABI or migration format.

## Testing Requirements

The independent acceptance harness MUST use pure producers, mappers,
coordinators, policy fixtures, health stores, and diagnostic sinks. It MUST
require no renderer, runtime implementation, concrete backend, platform
driver, simulator, or connected hardware.

This hardware-free harness is the Specification-approval seam. It runs on the
macOS reference runner above and includes normalized fixtures for all four
profiles, host execution of shared semantics, static allocation checks, and
cross-built nRF52840 ELF inspection. It does not claim Raspberry Pi target
latency or connected-target behavior.

Required tests are:

- exhaustive outcome-category, operational-kind, origin, affected-scope, and
  containment mapping, including every unknown or richer input
  representation;
- raw-value and `MemoryLayout` tests for every common declaration, including
  the 8-byte failure-fact, 4-byte operational-fact, 20-byte health, and
  24-byte diagnostic-record maxima;
- propagation fixtures proving identity and origin preservation, non-narrowing
  affected scope, and non-upgrading containment;
- annotation fixtures proving exact two-entry order, non-overwrite, and an
  unchanged core fact when a third append is refused;
- table-driven policy-totality tests that enumerate every declared residual
  policy input and verify exactly one allowed bounded result;
- invalid-policy-input construction tests covering success outcomes, empty
  and unknown disposition bits, zero limits, ordinals at and above the limit,
  exhausted retry ordinals, forbidden retry kinds, and forbidden
  safety-not-proven choices, each returning `nil` without policy invocation;
- fixtures proving detecting-layer, coordinator, and composition stages cannot
  perform one another's responsibilities;
- an operational-health fixture proving current state and counters remain
  accurate when every diagnostic record is dropped, counters saturate without
  wrapping, a permitted state transition still commits after saturation, and
  both record methods leave `quiesced` latched when passed every other
  `resultingState`;
- a diagnostic matrix covering disabled, source-filtered, sink-filtered,
  saturated, dropping, counting, and failing sinks and comparing all
  correctness-relevant outputs against diagnostics omitted;
- selector tests covering every diagnostic kind, origin, and severity
  threshold and proving an excluded record is never constructed;
- callback and interrupt fixtures proving diagnostic paths cannot mutate
  semantic state or invoke client actions;
- deterministic exhaustion tests for every selected correctness-bearing and
  diagnostic capacity;
- static/dynamic parity fixtures for equivalent facts and policy inputs;
- allocation instrumentation proving the static outcome and policy path makes
  zero heap allocations;
- optimized resource evidence for every profile fixture against the RAM,
  stack, code, step, latency, record, context, and buffer limits above; and
- target-graph/import tests proving the module dependency rules in this
  Specification.

Downstream execution, backend, platform, and hardware Specifications MUST add
their own transaction-position, handoff, device-health, and connected-target
tests. Those are not prerequisites for this contract's pure test seam.

### Post-approval target-integration evidence

The Raspberry Pi `armv6l` latency row and any connected-target behavior are
implementation/conformance evidence collected after Specification approval,
when the owning target integration exists. They remain required before the
relevant integration is conforming and before SPEC-003 may become
`implemented`, but they are not inputs to approval of this hardware-free
contract. The nRF52840 row is satisfied by reproducible cross-built ELF and
disassembly evidence unless a later owning Specification separately requires
connected-board execution.

## Acceptance Criteria

### Specification-approval seam

- [ ] A compile fixture imports `GiftUIFailureCore` without importing GiftUI,
  execution, runtime, backend, platform, capability, or diagnostic modules.
- [ ] Import-graph checks prove `GiftUIFailureExecution` imports only the core
  failure and focused execution contracts, the execution contract does not
  import failure execution correlation, and a driver fixture cannot import
  the correlation adapter.
- [ ] One exhaustive containment fixture maps `contained` to `contained` and
  every safety-not-proven, unknown, and richer test value to `safety not
  proven` in both runtime profiles.
- [ ] Raw-value and layout fixtures cover every declared case and prove the
  specified 2-, 4-, 8-, 20-, and 24-byte equalities or maxima on every
  available MVP compiler target.
- [ ] Propagation fixtures prove the original condition identity and origin
  are unchanged, affected scope is never narrowed without fixture-backed
  proof, and containment is never upgraded.
- [ ] Two annotations retain insertion order; a third append returns `false`,
  overwrites no entry, and leaves every correlated core-fact field unchanged.
- [ ] Every value in every declared residual-policy input domain is exercised
  exactly once by a table-driven test and produces one allowed finite result;
  every forbidden input returns `nil` without invoking policy, and no test
  exposes a mandatory local or coordinator action as a policy choice.
- [ ] The diagnostic configuration matrix produces value-equal normalized
  outcomes, health snapshots, coordinator inputs, residual policy inputs, and
  policy results for diagnostics omitted, enabled, filtered, saturated,
  dropping, and failing.
- [ ] Dropping every projected health-transition record leaves the explicit
  health query and counters equal to the diagnostics-enabled baseline; forced
  `UInt32.max` saturation wraps no counter and blocks no state transition.
- [ ] Once health reaches `quiesced`, both record methods preserve `quiesced`
  for every requested resulting state, increment only the matching
  non-saturated outcome counter, and add no transition.
- [ ] Diagnostic callback and interrupt fixtures record zero semantic
  mutations and zero client-action invocations.
- [ ] Every declared store, context, counter, and policy capacity has one
  deterministic exhaustion test, and no such test overwrites, silently drops,
  reorders, or immediately retries correctness-relevant work.
- [ ] Allocation instrumentation records zero heap allocations for static
  construction, normalization, propagation, health update/query, and residual
  policy dispatch with diagnostics disabled.
- [ ] Static and dynamic fixtures produce identical portable facts and
  dispositions for the complete shared fault corpus.
- [ ] Hardware-free release evidence satisfies the 64-step correctness-path
  bound, 8-step mapping/selection bounds, default buffer capacities, macOS
  reference-runner limits, normalized static-profile bounds, and nRF52840
  cross-built instruction/stack limits. Raspberry Pi `armv6l` latency is
  explicitly tracked as post-approval target-integration evidence.
- [ ] SPEC-002 uses the exact Foundation fact rows, and SPEC-004 uses the exact
  capability condition catalogue and `GiftUIOutcome<CapabilitySnapshot>`
  carrier defined here; both preserve reciprocal links and define no competing
  failure, health, disposition, or diagnostic vocabulary.

### Implemented-transition target evidence

The following criterion is deliberately not a Specification-approval gate. It
becomes mandatory when the Raspberry Pi integration exists and before
SPEC-003 may transition to `implemented`:

- [ ] The connected Raspberry Pi reference target reports `armv6l` and the
  release contract corpus satisfies the Raspberry Pi RAM, stack, linked-code,
  and p99 latency row under the recorded compiler, OS, command, revision, and
  raw-sample conditions.

## Implementation Notes

This section is non-authoritative. A practical drafting sequence is to freeze
the core semantic cases and fixture corpus first, then agree the Foundation
primitive representations with SPEC-002, and finally add execution correlation
and optional diagnostic adapters. Existing throwing and platform-specific
errors are migration evidence, not contract authority.

The same pure fixtures should be reusable by later execution, runtime-profile,
backend-integration, and host-configuration Specifications.

A host-only feasibility layout compiled with Apple Swift 6.3.3 on arm64 macOS
measured: `GiftUIConditionID` 2 bytes, `GiftUIFailureFact` 5 bytes,
`GiftUIOperationalFact` 3 bytes, `GiftUIFailureAnnotations` 20 bytes,
`GiftUIOperationalHealth` 17 bytes, and `GiftUIDiagnosticRecord` 24 bytes.
These measurements support the frozen maxima but are not acceptance evidence
for the macOS static, ARMv6, or Embedded Swift targets.

## Open Issues

No architectural or reciprocal-terminology issue is open. SPEC-002 now uses
the exact Foundation fact rows above, and SPEC-004 now uses the exact
capability condition catalogue and enclosing
`GiftUIOutcome<CapabilitySnapshot>` carrier. Their reciprocal metadata and
manifest registration were already present.

The future EXECUTION Specification must provide the concrete `Context` used
by `GiftUICorrelatedFailure`; the future HOST-CONFIGURATION Specification must
instantiate the total policy table, pacing, and fatal-hook choices for each
MVP composition. Those are downstream obligations, not prerequisites for
review or approval of this independent Wave 1 contract. Implementation and
conformance must later produce the required cross-target allocation,
operation-count, and optimized resource evidence. Failing a frozen bound
requires representation reduction or an explicit Specification revision; it
does not permit an implementation exception.

Any resolution that changes ownership, adds a new containment or recovery
class, makes diagnostics authoritative, or changes the accepted dependency
direction MUST return to RFC/ADR review instead of being resolved here.

## Deferred and Follow-up Work

- [FW-009](../future-work/fw-009-shared-delegated-service-foundation.md)
  preserves a possible shared delegated-service foundation. This
  Specification requires only a narrow consumer-specific diagnostic seam.
- [FW-012](../future-work/fw-012-durable-failure-identity-compatibility.md)
  preserves durable cross-build identities and versioned catalogues.
- [FW-013](../future-work/fw-013-fine-grained-failure-containment-recovery.md)
  preserves finer containment and recovery classifications.

None of these items is required for correctness or approval of the bounded MVP
contract.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [ADR-014: Bounded Cross-Layer Outcome Meaning](../adrs/adr-014-bounded-cross-layer-outcomes.md)
- [ADR-015: Layered Failure Disposition Ownership](../adrs/adr-015-layered-failure-disposition.md)
- [ADR-016: Non-Authoritative Diagnostic Projection](../adrs/adr-016-non-authoritative-diagnostics.md)
- [SPEC-001: Signal Analyzer Reference Application Contract](spec-001-signal-analyzer-reference-application.md)
- [SPEC-002: Portable Foundation](spec-002-portable-foundation.md)
- [SPEC-004: Capability Contribution and Resolution](spec-004-capability-contribution-and-resolution.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
