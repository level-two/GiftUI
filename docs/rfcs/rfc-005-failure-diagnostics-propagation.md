---
id: RFC-005
feature: giftui-mvp-architecture
title: Failure and Diagnostics Propagation Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-15
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-004
  - RFC-006
  - RFC-007
related_adrs: []
related_specs: []
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# RFC-005: Failure and Diagnostics Propagation Architecture

## Summary

This RFC proposes that GiftUI separate control-flow failures from diagnostics.
A failure is a typed, bounded value that affects whether an operation, runtime
cycle, or presentation attempt can continue. A diagnostic is an observation
for humans or tooling and has no control-flow meaning. Reporting a diagnostic
may accompany a failure, but correctness never depends on a diagnostic sink
being installed or able to accept a record.

Layers report structured facts upward through explicit contracts. The runtime
cycle is the synchronous propagation and policy boundary; asynchronous backend,
display, and transport outcomes re-enter as sequenced completion inputs. The
composition root owns failure policy and decides whether to abort a semantic
transaction, drop or retry a frame, degrade an optional capability, quiesce,
report, or trap.

The common architecture requires no exceptions, heap allocation, strings,
reflection, or dynamic dispatch. Embedded Swift can use fixed-size numeric
records, value or out-parameter status transport, and statically composed
policy and sink types. Dynamic profiles may enrich the same records with
strings, stacks, tracing, and pluggable sinks without changing control-flow
semantics.

These are candidate architectural choices for review. This draft does not
approve them, define final public APIs, or authorize implementation.

## Context

[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
accepts the need to establish cross-cutting GiftUI architecture for the Signal
Analyzer and the four MVP configurations. Failure behavior is part of that
architecture because the portable presentation crosses semantic runtime,
layout, render-sink, backend, display, and transport boundaries while the
static nRF52840 configuration requires bounded, allocation-free behavior.

[RFC-002](rfc-002-giftui-mvp-layered-architecture.md) proposes the layer
boundaries and composition-root ownership used by this RFC.
[RFC-004](rfc-004-run-cycle-and-frame-transaction.md) focuses the runtime-cycle
ordering, transaction commit point, frame identity, and presentation lifecycle.
Both remain drafts and are therefore related design context rather than
authority. This RFC must be revised with either draft if review changes those
foundations; none may rely on another as an accepted decision.

GiftUI operations cross several failure domains:

```text
semantic runtime -> layout -> render sink -> backend -> display -> transport
```

Some conditions indicate violated invariants and make continued execution
unsafe. Others invalidate only the current transaction or frame. Still others
are normal operational conditions such as backpressure, temporary
disconnection, or diagnostic-capacity exhaustion.

Layer-local trap, log, retry, and ignore decisions would produce
backend-dependent behavior. Exceptions and rich strings would impose
mechanisms that Embedded Swift may not support. Diagnostics used as control
flow would make correctness depend on observability configuration. Arbitrary
upward calls from asynchronous device code would bypass the deterministic
runtime-cycle boundary. GiftUI therefore needs a small common failure
protocol, a separate diagnostic protocol, and one policy authority at stack
assembly.

The maintainer-provided failure and diagnostics architecture attached to this
RFC request is the primary design source. It is adapted here to GiftUI's
lifecycle template, accepted MVP Proposal, related draft RFCs, static-profile
constraints, and repository traceability rules.

### Terminology

- **Failure:** A structured control-flow value indicating that an operation
  could not fulfill its contract.
- **Diagnostic:** A bounded observation about behavior, performance,
  degradation, misuse, or a failure.
- **Failure category:** The required control posture: `fatal`, `recoverable`,
  or `operational`.
- **Severity:** Diagnostic importance such as `note`, `warning`, or `error`;
  it is not a control-flow category.
- **Origin:** The layer and operation that first detected a condition.
- **Context frame:** A bounded numeric annotation added while a failure crosses
  a boundary.
- **Failure policy:** Composition-root logic that maps failure facts and
  transaction position to an action.
- **Diagnostic sink:** An optional Service that consumes diagnostic records
  on a best-effort, bounded basis.
- **Propagation boundary:** Cycle finalization, where accumulated synchronous
  facts are ordered and policy actions are applied.

## Requirements

### R1 — Explicit propagation

Fallible contracts across semantic runtime, layout, render sink, backend,
display, and transport boundaries MUST return structured success,
operational, or failure outcomes. Exceptions MAY be adapted at a dynamic
platform boundary but MUST NOT be the only cross-layer failure mechanism.

### R2 — Central policy authority

Layers MUST report facts rather than select product-level disposition. The
composition root MUST own the policy that maps those facts and transaction
position to abort, frame, capability, fallback, or fatal actions.

### R3 — Failure and diagnostics separation

Diagnostic emission, filtering, formatting, loss, or sink failure MUST NOT
change semantic commit, layout, frame content, or presentation disposition.
A condition that changes control flow MUST have a structured failure or
operational representation independent of diagnostics.

### R4 — Deterministic cycle boundary

Synchronous failures MUST be observed and arbitrated at a runtime-cycle
propagation boundary. Multiple failures MUST be ordered independently of
worker or callback completion timing.

### R5 — Sequenced asynchronous re-entry

Backend, display, and transport outcomes that arrive after their originating
cycle MUST re-enter as bounded, identified, sequenced completion inputs. They
MUST NOT mutate committed semantic state or invoke application handlers from
arbitrary callback or interrupt contexts.

### R6 — Transaction preservation

A recoverable pre-commit failure MUST preserve the prior committed semantic
revision. A recoverable post-commit failure MUST NOT roll back or recompute the
committed revision and MUST affect only the frame or capability disposition.

### R7 — Bounded portable representation

The common failure, diagnostic, context, accumulator, and completion
representations MUST have explicit bounds and MUST NOT require heap
allocation, strings, reflection, exceptions, or dynamic dispatch on Embedded
Swift.

### R8 — Stable identity and context

Failure domains, codes, diagnostic events, layers, phases, and operations MUST
use stable identifiers. Propagation MUST preserve the originating domain and
code; boundary context MUST NOT erase or replace the cause.

### R9 — Total and conservative policy

Failure policy MUST define a disposition for every registered code and a
conservative fallback for unknown codes. A policy MAY classify a condition
more strictly for a product but MUST NOT downgrade an invariant-classified
fatal failure to normal continuation.

### R10 — Profile-neutral behavior

Static and dynamic profiles MUST agree on portable failure identity,
classification, deterministic ordering, transaction effect, and policy input.
Richer dynamic diagnostics MUST NOT create different release semantics.

### R11 — Bounded observability

Diagnostic capture, rate limiting, loss accounting, and formatting MUST be
bounded for every profile. A diagnostic sink MUST NOT recursively diagnose its
own failure through itself.

### R12 — Testability

Every first-party layer MUST support deterministic fault injection or
equivalent fixtures so propagation, arbitration, truncation, policy, and
cross-profile conformance can be tested without requiring the full hardware
matrix.

## Constraints

- The architecture MUST preserve the portable Signal Analyzer presentation
  across macOS dynamic, macOS static, Raspberry Pi/Linux dynamic, and
  nRF52840/Embedded Swift static configurations.
- The supported embedded path cannot require heap allocation, reflection,
  unrestricted existentials, desktop concurrency facilities, runtime backend
  discovery, or exception-based propagation.
- Static storage capacities and overflow behavior must be explicit and
  deterministic.
- The layer and capability ownership used below are candidates shared with
  RFC-002, while the runtime cycle, semantic commit point, frame identity, and
  completion admission are candidates shared with RFC-004.
- Backpressure, cache misses, no-change cycles, and other expected bounded
  states must remain distinguishable from broken contracts.
- Platform- and backend-specific detail needed for diagnosis must remain
  representable without leaking opaque platform values into core policy.
- The design does not define a universal logging framework, text format,
  telemetry vendor, crash reporter, or application-domain error system.
- Recovery from memory corruption or violated language safety is not required.

## Proposed Design

### Classification model

Category and diagnostic severity are separate axes.

**Fatal failures** mean that continued normal GiftUI execution cannot preserve
a required invariant. Examples include corrupted runtime identity, an
impossible state-machine transition, unsafe command-buffer bounds, an
uninterpretable ABI/schema mismatch, or token reuse that demonstrates runtime
corruption. After fatal policy is selected, the runtime becomes quiescent and
admits no further normal cycles.

An immediate trap before the propagation boundary is permitted only when
continuing to the boundary would itself be unsafe. An implementation SHOULD
emit a minimal last-chance numeric record first when that is safe, but MUST NOT
rely on successful emission.

**Recoverable failures** invalidate a bounded unit of work while preserving
runtime invariants. Examples include layout capacity exhaustion, an
unsupported render operation, a missing required raster resource, rejection
of one frame, display submission failure, or retry exhaustion. Recoverable
does not mean automatic retry: transaction position and composition policy
determine the action.

**Operational conditions** are expected bounded-system states requiring an
explicit disposition but not indicating a broken contract. Examples include
presentation backpressure, no semantic changes, a disconnected optional
display, a superseded frame, diagnostic ring overflow, cache eviction, or a
transient transport state with a retry contract. Their frequency or duration
MAY produce a diagnostic, but visibility alone MUST NOT promote them to
recoverable or fatal.

### Reporting and policy flow

```text
Semantic Runtime ─┐
Layout ───────────┤
Render Sink ──────┤ explicit Failure / DiagnosticRecord
Backend ──────────┤
Display ──────────┤
Transport ────────┘
          |
          v
cycle-local failure accumulator + optional diagnostic sink
          |
          v
runtime-cycle propagation boundary
          |
          v
composition-root FailurePolicy
          |
          +--> abort semantic transaction
          +--> drop/retry/supersede frame
          +--> degrade/disable capability
          +--> quiesce and fatal action
          +--> continue
```

Layers detect and describe conditions. A transport may describe a protocol
failure as transient, but it may not retry indefinitely unless composition
policy granted it a bounded autonomous-retry contract.

### Failure and result values

The minimum portable failure record is fixed-size and string-free:

```text
Failure {
  domain: FailureDomain
  code: FailureCode
  category: fatal | recoverable | operational
  phase: CyclePhase
  origin: LayerId
  operation: OperationId
  cycleId: CycleId?
  frameId: FrameId?
  token: CapabilityToken?
  detail0: UInt
  detail1: UInt
  flags: FailureFlags
}
```

`detail0` and `detail1` have code-specific meanings. Static profiles may use
reserved sentinel values or tagged fixed storage for optional identities.
Dynamic profiles may attach a localized message, source location, causal
chain, stack, or platform error sidecar. The sidecar is diagnostic only;
equality, category, ordering, recovery, canonical serialization, and policy
selection depend solely on the portable record.

Fallible contracts share this conceptual result:

```text
OperationResult<T> = success(T) | operational(OperationStatus) | failure(Failure)
```

Conforming static representations include a tagged enum returned by value, a
status plus caller-owned out-parameter, a fixed cycle-local result slot, or a
generic direct-call protocol specialized at compile time. A dynamic adapter
may catch a native exception or callback error and normalize it before it
enters GiftUI core.

The ordinary `.operational` branch is preferred for an expected condition that
one caller can disposition immediately. When an operational fact must join
cycle-wide arbitration or composition policy, it uses the same portable fields
with `category=operational`; this does not turn the condition into a broken
contract.

### Diagnostic records

```text
DiagnosticRecord {
  eventId: DiagnosticEventId
  severity: note | warning | error
  origin: LayerId
  phase: CyclePhase
  cycleId: CycleId?
  frameId: FrameId?
  detail0: UInt
  detail1: UInt
  relatedFailureDomain: FailureDomain?
  relatedFailureCode: FailureCode?
}
```

Emission is bounded and non-recursive. Formatting SHOULD occur outside
correctness-critical paths. Static builds MAY compile out selected event
classes while retaining required failure behavior. Sensitive application data
MUST be absent unless an explicit diagnostics policy permits and supplies it.

`DiagnosticSink.emit` either has no result or returns an operational
acceptance value. Sink failure is represented by a bounded counter or
last-status slot and is never reported recursively through the same sink.

### Context propagation

When a layer cannot handle a failure within its own contract, it returns the
original portable record. A boundary may add one fixed-size context frame:

```text
ContextFrame {
  layer
  operation
  detail
}
```

Static implementations keep a small fixed-depth array or only the most recent
frame; overflow sets `contextTruncated`. Dynamic implementations may retain
more context, but policy cannot depend on context unavailable in the static
profile unless a profile contract explicitly diverges. A genuinely new
failure detected while handling another enters arbitration as a separate
fact.

### Runtime-cycle propagation boundary

Synchronous failures and diagnostics are observed during their originating
cycle. A bounded cycle-local accumulator records facts. At `Finalize`, the
runtime:

1. seals the accumulator;
2. determines whether semantic commit was crossed;
3. orders recorded failures canonically;
4. asks `FailurePolicy` for the controlling failure and action;
5. applies the action allowed for the transaction position;
6. publishes `CycleOutcome`; and
7. schedules explicit follow-up work.

An operation may short-circuit its own phase when it cannot produce a valid
value. That is local control flow, not product policy; the composition-root
policy still owns cycle and frame disposition.

Multiple failures are ordered by:

1. category: fatal, recoverable, operational;
2. the canonical cycle-phase order resolved with RFC-004;
3. layer: semantic runtime, layout, render sink, backend, display, transport;
4. operation-local sequence assigned by deterministic traversal; and
5. stable numeric domain/code as a final tie breaker.

The first is the controlling failure. Other records remain secondary facts if
capacity permits. Parallel work merges into canonical rather than completion
order. Overflow sets a sticky `failuresTruncated` flag and count and MUST NOT
replace an already recorded fatal or recoverable failure.

### Asynchronous propagation

Late backend, display, and transport outcomes produce bounded completion
records identified by `FrameId` and `CapabilityToken`. A later runtime cycle
admits each completion through the ordered input boundary proposed by RFC-004.

Asynchronous code MUST NOT mutate committed semantic state, invoke application
event handlers outside admission, reopen an originating cycle, retain expired
cycle-local pointers, or call fatal policy from an arbitrary callback context
unless immediate continuation is unsafe. Interrupt code may write a fixed
single-producer record to an approved queue or sticky emergency slot;
normalization, diagnostics, and policy run at a safe propagation boundary.

### Composition-root failure policy

```text
FailurePolicy.decide(FailureContext) -> FailureAction

FailureContext {
  controllingFailure
  secondarySummary
  transactionPosition: preCommit | postCommit | noTransaction
  semanticRevision
  frameDisposition
  capabilityState
}

FailureAction =
  continue
  | abortCycle
  | dropFrame
  | retryFrame(RetryClass)
  | disableCapability(CapabilityId)
  | enterFallback(FallbackId)
  | quiesce(FatalAction)
```

Assembly owns policy because it knows the product, profile, recovery
capabilities, and diagnostic sinks. The same layout failure may trap in a
debug simulator, preserve the last frame on an embedded product, or drop a
remote-preview frame when each disposition respects classification and
transaction invariants.

Policy execution must be total. Static targets SHOULD use generic
specialization, a build-fixed function table, or a generated switch; dynamic
dispatch remains optional.

### Identifier registry

GiftUI maintains a versioned registry containing:

- stable domain, code, event, layer, phase, and operation identifiers;
- category and allowed policy actions for each failure code;
- meanings of detail fields and flags;
- symbolic names and human-readable templates for host tooling;
- schema compatibility rules; and
- deprecation and reservation policy.

Static firmware needs only numeric constants it uses. Host tooling may carry
the full registry and symbolize records using a firmware build fingerprint.
Codes are never reused with a different meaning. Unknown future codes remain
representable and use the conservative policy fallback.

### Determinism rules

1. The same declared inputs and capability outcomes produce the same portable
   records and controlling action.
2. Failure selection never depends on thread completion timing.
3. Policies do not parse strings or localized messages.
4. Queue, accumulator, context, and diagnostic overflow have bounded,
   deterministic representations.
5. Retry uses explicit attempt state and sequenced scheduler inputs.
6. Diagnostic configuration cannot change semantic or presentation outcomes.
7. Conditions reachable in supported production input have defined production
   dispositions even if debug assertions stop earlier.
8. Platform errors are normalized at their boundary; opaque native values do
   not enter core policy.

## Module Responsibilities

| Module / layer | Responsibility | Dependency impact |
| --- | --- | --- |
| Semantic runtime | Own cycle accumulator, propagation boundary, commit position, `CycleOutcome`, and completion admission | Depends only on portable failure contracts and assembled policy |
| Layout | Return complete geometry, an operational result, or a registered failure; never pass partial geometry as complete | Does not depend on backends or diagnostic sinks |
| Render sink | Produce a complete immutable frame or a registered failure; never silently truncate commands | Reports through portable failure contracts |
| Backend | Normalize command, resource, and execution outcomes; separate frame acceptance from presentation completion | May preserve native numeric detail but not leak native policy upward |
| Display | Report surface, buffer, submission, and presentation outcomes associated with frame identity | Uses completion boundary for late outcomes |
| Transport | Separate link state from frame outcome and perform only policy-delegated bounded retries | Uses sequenced completion records and stable tokens |
| Composition root | Assemble failure policy, diagnostics configuration, sinks, and profile capacities | Depends on selected product stack; portable views remain independent |
| Host tooling | Symbolize numeric records and present rich context | Consumes registry/build fingerprints; no runtime control authority |

## Public API Impact

The RFC introduces architectural concepts that later Specifications may expose
as `OperationResult`, `Failure`, `FailurePolicy`, `FailureAction`,
`DiagnosticRecord`, `DiagnosticSink`, and `CycleOutcome`. Exact Swift names,
access levels, numeric layouts, and generic forms remain Specification work.

Portable view declarations should not normally handle framework-internal
failures. Application-facing host and integration APIs may receive a cycle or
presentation outcome when the application can take a meaningful action.
Existing proof-of-concept `throw` sites may remain behind adapters during
migration, but maintained core boundaries cannot depend exclusively on them.

## Capabilities Impact

Failure policy is assembled policy, and diagnostic delivery is an injected
Service rather than an inferred platform check. A diagnostic sink is optional;
its absence has defined no-op behavior.
RFC-002 fixes the selected MVP stack as immutable after assembly; runtime
device presence and loss are operational inputs handled by this failure model
and RFC-004 rather than capability mutation.

[RFC-006](rfc-006-capability-system-architecture.md) owns the candidate
capability representation and the relationship between capability and policy.
This RFC does not add a general capability catalogue, resolution rule, or
propagation model.

## Backend Impact

Backends validate commands and resources before unsafe execution and normalize
native outcomes into registered GiftUI records. Acceptance of a frame is
distinct from asynchronous presentation completion. Backend-specific status
may be retained in a numeric detail field, but the GiftUI domain and code
control policy.

Display backpressure is operational. Loss of a required surface, invalid
buffer lifecycle, or permanent rejection is a failure. Transport disconnection
may be operational with no pending frame and recoverable for an accepted
frame. Protocol corruption or incompatible schema may disable one capability
or become runtime-fatal according to a classification and assembled policy
that review must make explicit.

## Static / Embedded Impact

| Concern | Static profile | Dynamic profile | Required common behavior |
| --- | --- | --- | --- |
| Failure representation | Fixed numeric record | Same record plus optional rich sidecar | Same domain, code, category, and policy inputs |
| Propagation | Value, out-parameter, or fixed result slot | Result, throwing adapter, callback, or task normalized at boundary | Explicit GiftUI outcome across core boundaries |
| Policy dispatch | Generic specialization, fixed function table, or generated switch | Existential, closure, registry, or injection | Composition root is policy authority |
| Diagnostics | Fixed ring, counters, UART/RTT, or disabled | Logging, tracing, crash reports, or telemetry | No control-flow dependency on sink |
| Messages | Host symbolization | Runtime formatting/localization allowed | Strings not required for identity or decisions |
| Storage | Fixed accumulator and bounded context | Configured bounded buffers; optional allocations | Deterministic selection and truncation signal |
| Async completion | Interrupt-safe queue or polling | Callback, task, or event loop | Sequenced re-entry through completion boundary |
| Fatal action | Trap, panic hook, safe state, or reset | Trap, assertion, host error, or crash reporter | No continued normal cycles after fatal policy |

Static profiles may omit descriptions but not failure identity. Interrupt paths
perform only bounded writes into approved storage. Connected-hardware work is
not authorized by this RFC; later validation must distinguish host,
cross-compile, simulator, and device evidence.

## Performance

Failure-free hot paths pay for explicit result checks and cycle-local
accounting but MUST NOT perform diagnostic formatting or unbounded work.
Diagnostic emission and policy evaluation must have profile-specific bounds.
Canonical merge cost is bounded by accumulator capacity rather than the number
of attempted operations.

The review and downstream Specification must define measurement fixtures for
runtime-cycle overhead, failure injection, accumulator saturation, diagnostic
ring saturation, completion admission, and host symbolization. Exact budgets
remain open until record layouts and first-profile capacities are selected.

## Memory / Binary Size

The portable record, context depth, failure accumulator, completion queue,
diagnostic ring, counters, and registry subset create explicit RAM, stack, and
flash costs. Static capacities must be configuration values with deterministic
overflow behavior. Firmware links only the identifiers and formatting-free
policy paths it uses; symbolic templates reside in host tooling when possible.

Dynamic sidecars and sinks may allocate, but disabling them must not remove the
portable record or alter control semantics. Exact widths, packing, capacities,
and stack-placement rules remain open and require cross-compiled size and
connected-device high-water evidence before the eventual Specification is
approved.

## Alternatives

### Exceptions throughout the core

This offers familiar Swift ergonomics on dynamic hosts and automatic stack
unwinding. It would be preferable for a desktop-only framework without static
constraints. It does not fit Embedded Swift as the common contract and does
not solve asynchronous identity or ordering.

### Layer-local recovery policy

This can keep individual components simple when their product disposition is
fixed. GiftUI layers, however, cannot know whether a display or capability is
mandatory, whether a frame may be dropped, or which fatal action a product
supports.

### One global error callback

This can centralize reporting with little type surface. Reentrancy, ordering,
callback lifetime, thread context, nested failures, and transaction position
remain ambiguous.

### One rich error object for failure and diagnostics

This can maximize desktop convenience and context. It couples correctness to
allocation, strings, and observability, and makes deterministic cross-profile
comparison and policy selection harder.

## Rejected Approaches

No approach is formally rejected while this RFC is a draft. Review is expected
to reject or revise the following candidates before approval:

- trap on every error, because expected resource and transport conditions can
  preserve invariants and the last valid state;
- log and continue on every error, because some operations cannot produce a
  valid result and some invariant violations make continuation unsafe;
- exceptions as the universal propagation mechanism, because static profiles
  cannot depend on them;
- strings as failure identity, because they are unstable, costly, and invite
  policy-by-parsing;
- layer-local product policy, because lower layers do not know product
  requirements;
- a global mutable error callback, because ordering and reentrancy are
  ambiguous; and
- diagnostics as control flow, because sink configuration must not affect
  correctness.

## Compatibility

This is additive architecture for governed GiftUI code but requires migration
of inconsistent proof-of-concept behavior. Existing throwing APIs may be
adapted at dynamic boundaries. Existing static status and error enums require
mapping to the stable registry. No public ABI stability is established for the
proof of concept, so source compatibility is desirable but subordinate to the
accepted architecture.

Serialized portable records require explicit schema-version and code-reservation
rules. Future codes must remain representable by older policy and tooling.
Changing a code's meaning is prohibited; deprecation reserves its identity.

## Testing Strategy

- Unit-test classification, policy totality, unknown-code fallback, and every
  allowed action for pre-commit, post-commit, and no-transaction positions.
- Fault-inject every first-party layer and verify domain, code, phase, origin,
  context preservation, and disposition.
- Permute worker completion order and verify identical controlling failure.
- Saturate accumulators, context storage, completion queues, and diagnostic
  sinks and verify deterministic truncation or loss metadata.
- Disable every diagnostic sink and verify identical semantic and presentation
  outcomes.
- Compare static and dynamic portable records and actions through shared
  canonical fixtures.
- Cross-compile the Embedded Swift path without exceptions, required
  existential dispatch, allocation, or string formatting in the failure path.
- Verify late completions cannot mutate semantic state or invoke handlers
  outside input admission.
- Verify fatal outcomes quiesce normal cycles and invoke exactly one configured
  fatal action.
- Verify recoverable pre-commit failures preserve the prior revision and
  post-commit failures affect only frame/capability disposition.
- Normalize representative platform-native errors and symbolize static records
  with the matching registry fingerprint.
- Keep connected-hardware fatal, reset, interrupt, and stack claims separate
  from host and cross-compilation evidence.

## Risks

- **The portable record becomes too large for static hot paths.** Select widths
  from measured first-profile needs and keep rich data in dynamic sidecars.
- **The record becomes too small to diagnose real failures.** Preserve stable
  code-specific detail fields, bounded context, truncation flags, and host
  symbolization.
- **Operational conditions are inconsistently classified.** Maintain a
  versioned registry with category and allowed actions, then test every code.
- **Policy becomes a hidden source of semantic divergence.** Restrict policy
  actions by category and transaction position and compare actions across
  profile fixtures.
- **Diagnostics consume excessive time or memory.** Bound emission, storage,
  formatting, rate limits, and loss accounting independently by profile.
- **Late callbacks violate runtime isolation.** Require tokenized completion
  queues and test that callbacks cannot reach semantic mutation directly.
- **RFC-002, RFC-004, or RFC-006 changes a shared
  layer, configuration, cycle, policy, or frame boundary.** Review these
  artifacts together and revise this draft before any reaches approval.
- **Privacy-sensitive values enter diagnostic records.** Make fields numeric
  and code-defined, require explicit privacy policy, and audit production event
  classes.

## Open Questions

These questions remain in the active RFC review scope rather than being
deferred:

1. Which exact numeric widths and packing rules should portable records use?
2. How many secondary failures and context frames must the first static
   profile retain?
3. Which failures may a product promote from recoverable or capability-fatal
   to runtime-fatal?
4. Does GiftUI need a distinct `capabilityFatal` category, or is recoverable
   plus `disableCapability` sufficient?
5. Which execution-context violations can be deterministically deferred rather
   than classified fatal?
6. Is policy frozen for the runtime lifetime or snapshotted per cycle?
7. Which last-chance diagnostic operations are safe from interrupt and
   corruption contexts?
8. How are native error domains mapped and versioned without exhausting the
   common registry?
9. Which diagnostic events and detail fields are sensitive?
10. Should production dynamic profiles retain numeric source-location IDs when
    strings are stripped?
11. What cycle-phase order and transaction positions are final after RFC-004
    review?
12. What measurable CPU, RAM, stack, and binary-size budgets apply to each MVP
    configuration?

These questions may refine representation and product defaults, but review
must ensure none leaves diagnostics authoritative for control flow or makes a
dynamic runtime mechanism mandatory in the static profile.

## Deferred and Follow-up Work

No Future Work, Exploration, or Spike is linked at draft creation. All known
uncertainty is still material to reviewing this RFC and remains in Open
Questions. If review intentionally postpones a non-blocking choice, it must be
captured as a bidirectionally linked deferred item with a concrete revisit
trigger before this RFC can be approved.

After accepted ADRs and an approved Specification authorize implementation,
expected downstream work includes the identifier registry, binary record
layout, bounded accumulator, reference policies and sinks, platform adapters,
completion admission, fault-injection fixtures, static conformance tests, and
the first embedded fatal-state/reset strategy. This list is not implementation
authorization or a milestone expansion.

## Decision Summary

If approved, this RFC is expected to yield separate proposed ADRs for:

1. explicit bounded failure values and independent best-effort diagnostics;
2. runtime-cycle arbitration and sequenced asynchronous completion admission;
3. composition-root ownership of failure and diagnostic policy;
4. deterministic failure classification, ordering, and transaction effects;
5. stable numeric identifier registry and profile-neutral portable records;
   and
6. static/dynamic conformance with optional rich dynamic sidecars.

These are candidate decision extractions, not accepted architecture.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [PROPOSAL-004: GiftUI Capability System](../proposals/proposal-004-capability-system.md)
- [RFC-002: GiftUI MVP Layered Architecture](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-006: GiftUI Capability System Architecture](rfc-006-capability-system-architecture.md)
- [RFC-007: GiftUI Delegated Services Architecture](rfc-007-delegated-services-architecture.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md)
- Maintainer-provided “Failure and Diagnostics Propagation Architecture” source
  draft supplied with this RFC request.
- `Sources/GiftUIRuntimeStatic/StaticRuntime.swift`
- `Sources/GiftUIDisplayILI9341/ILI9341Display.swift`
