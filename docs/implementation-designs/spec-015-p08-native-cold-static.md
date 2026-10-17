---
spec: SPEC-015
feature: giftui-mvp-architecture
title: Implementation Design — P08 Native cold Static construction
status: draft
authors: [codex]
created: 2026-10-17
updated: 2026-10-17
implementation_plan: ../implementation-plans/spec-015-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# P08 Native cold Static construction

**Selected candidate mechanism; independent design review PASS for bounded source
execution and early actual cold screen.**
The [independent review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-native-cold-static-independent-design-review.md)
confirms the internal contract boundary and evidence limits; this note remains
derived, with no implementation/conformance claim.
The maintainer chose strict conformance after the [confirmed allocation failure](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-native-allocation-independent-review.md):
“Please proceed with strict contract, that makes sense”. This is one new bounded
candidate with at most two corrective cycles. Earlier source allowances remain
closed; diagnostic probes have spent no application candidate/corrective cycle.
This derived note changes no accepted contract and makes no completion claim.

## Purpose and governing contract

Remove cold Native Static runtime metadata/witness allocation by placing owning
storage in concrete private host types and specializing scoped operations at that
concrete boundary. Do not warm caches, move the observation window, change Native
runtime semantics, or exempt metadata. Target complete selected-profile
construction, first actions, later opportunities/failure and teardown, including
cold common Static framework paths; the11/336 subset is only a rejecting witness.

[SPEC-013 performance/S13.1–2](../specs/spec-013-runtime-profiles.md),
[SPEC-015 performance/S15.1–2](../specs/spec-015-host-configuration.md),
[ADR-036](../adrs/adr-036-scoped-model-access-and-bounded-ownership.md#fixed-domain-access-and-source-transformation)
and [ADR-039](../adrs/adr-039-scoped-storage-ownership.md) govern P08/R07/T8.1.
They require actual bounded typed storage, the existing generic read/scope and
supplied/pipeline contracts, exact observations, and complete accounting. They do
not prescribe `InlineArray` as an owning representation. Changing those normative
contracts is outside this candidate.

## Evidence and current-code boundary

[Reproducible two-module controls](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-native-strict-construction-probe.md)
show flags alone139 cold allocations; targeted serialization27; a generic named
pair25; a concrete private owner0. The concrete owner can retain a contiguous
`InlineArray`, lend its `MutableSpan`, and enter a generic noncopyable/nonescapable
scope under the actual buffer borrow with0 cold allocations. Forced client body
emission alone still allocates27. These are compiler feasibility controls, not
proof of actual root/registration/action code. The synthetic model is Copyable;
the actual CounterOwnedModel is noncopyable and its exact initialization/move/
destruction path must pass the actual screen.

`StaticObservableRootAdapter` currently owns generic model and registration
storage. `ObservableStateRootScope.records` points at an entire
`ObservableStateRootStorage<Identity>`; merely adding a concrete wrapper leaves
that generic owner construction in place. `ObservableModelScope.withRead` also
constructs generic read slots. The observed action sites cross generic resolver,
gesture and target bridges. All must be inspected in the selected actual image.

## Selected internal organization and data flow

1. Introduce a private concrete Native counter Static root backing at the fixture
   boundary. It owns `InlineArray<2,CounterOwnedModel?>` directly, plus concrete
   identity slots and a nongeneric registration/control ledger. Keep real
   contiguous initialized arrays; no tuple-layout assumption or rebinding cast.
   Preserve two models, four claims, two pins, two registrations, capture0 and
   every configured/refusal boundary. Keep the normal generic adapters as wrappers
   for their existing callers; do not replace the public read domain/context.
2. Extract only registration control independent of `Identity` from
   `ObservableStateRootStorage`. Keep identity-bearing slots separately typed.
   Make the existing generic wrapper lend those actual fields to a checked scope
   factory. The concrete host lends equivalent actual fields to the same factory.
   `ObservableStateRootScope<Model,Identity>` remains the exact scope type; its
   private representation may hold typed slot descriptors and control separately.
   Preserve every matching/generation/report/candidate/retirement check.
3. Serialize the bounded model/root/read factory and directly necessary forwarding
   bodies so the concrete caller can specialize them. Keep unsafe constructors
   inaccessible to source clients: `@usableFromInline` on a module-internal helper
   changes serialization visibility, not source access. Do not make a public or
   package-callable unchecked scope constructor, arbitrary pointer factory or
   constructible provenance token. If required visibility cannot preserve this,
   stop for design review rather than opening a capability.
4. Preserve actual model/ledger/registration/report borrows through the complete
   factory callback. Every new private descriptor constructor retains the union
   of the actual borrowed fields; borrowedRoot/borrowedScope propagate it. Keep
   the existing escaping Result constraint. A pointer descriptor alone cannot
   establish backing lifetime. Preserve MutableSpan access and read pin/exclusion
   across body/layout/drawing; read-slot construction must specialize or remain
   an observed blocker.
5. For the eleven action allocations, serialize only the measured resolver,
   gesture, target and dispatch forwarding path needed for the concrete host.
   Retain generic public APIs, typed failures, enabled-action checks and exact
   mutation/report ordering. Do not duplicate the coordinator or action algorithm.

The original fourteen loan callbacks, P08 owner/inventory, five banks, Optional
host destination, G/C/R/H constraints and all model/root/semantic/value/control/
geometry/Interaction/activation-span lifetime unions remain. The root changes
physical representation, not the logical activation/session graph. Recompute
its actual layout, padding, inventory initializer/destructor and accounting as
one coherent change. No simultaneous old/new initialized owner may cover its
bytes. Partial initialization unwinds the acquired prefix once in reverse; normal
retirement detaches reports and releases pins/claims before backing destruction.

## Candidate allowlist

Maintained changes are limited to the following mechanism and direct call sites:

- `Sources/GiftUIObservableState/ObservableModelScope.swift` and
  `ObservableStateRootScope.swift`: checked borrowed factories, private storage
  split and targeted serialization; preserve generic API/lifetime behavior.
- `Sources/GiftUIObservableState/ObservableStateRootTargetAccess.swift`;
  `Sources/GiftUIInteraction/ExecutionGestureAdapter.swift`;
  `Sources/GiftUIRuntimeCore/RuntimeRecordInteractionBridge.swift`: serialize
  only the observed action path and necessary internal helpers.
- `Sources/GiftUIRuntimeStatic/StaticObservableModelStorage.swift` and
  `StaticObservableRootAdapter.swift`: forward existing wrappers into the same
  checked bridge, without changing capacity or outcomes.
- `Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterScopedStorage.swift`,
  `CounterProfileStorage.swift`, `CounterHostProbe.swift`, `CounterSemanticProbe.swift`
  and `CounterPipelineOwner.swift`: concrete Native Static backing, exact layout/
  root call sites, targeted forwarding. A focused cold-screen driver belongs
  beside existing diagnostic tools, not in the public host API.

Before implementation, confirm exact owning files (the target bridge is located
by symbol, not assumed from this list). Additional files are allowed only for
compiler-required visibility forwarding within this same mechanism, explicitly
listed in the candidate diff. New algorithms, corpus/profile reduction, loan
substitutes, unchecked layout, disabled exclusivity, compiler-policy changes or
unrelated storage redesign return to design review; they are not corrective
cycles silently widening this candidate.

## Focused actual cold screen and validation order

First compile only changed owners and the selected Native fixture with unchanged
pinned Native flags; retain exact source/object/loaded-runtime identities. Use a
small diagnostic entry invoking the original `p08CounterHost` construction and
finite action/lifecycle scenarios **before** `p08CounterGraph` or other common
Static warmup. Repeat in fresh processes, then the identical reuse workload.
Do not accept the existing common-graph-first entry as a cold-profile proof.
Preserve all required work/check counts; derive expected counts from the exact
screen source rather than copying the combined1735019 total.

Trace/oracle output must be identified separately. A diagnostic trace-free
fixture compilation may screen the profile without Swift print prewarming, but
must be explicitly distinct from the ordinary registered image, preserve workload
semantics/counts, and cannot alone close acceptance. Also run the ordinary route
with full observer attribution. No profile metadata allocation is excluded.
Recheck public allocator/zone/temp/VM coverage and the known direct-callback blind
spot; observed zero public-route events is not by itself complete zero-heap proof.

Inspect actual disassembly and first-use groups through model/root/read and
admission/gesture/dispatch construction. Any remaining profile allocation fails
this screen, including cold common Static construction outside the11 subset.
Record its exact path before using one of the two corrective cycles. A failed
screen stops full collection/image rebuilds. The candidate is credible enough
for this bounded implementation experiment; actual bridge specialization and
complete cold zero remain its explicit feasibility questions.

Before broader testing, check copy/escape/owner-independent/Optional lifetime
negatives, overlapping mutable access/exclusivity, all fourteen loans, partial
initialization/fault unwinding, early returns, repeated sessions, root shutdown,
report detachment, stale generations and backing-last destruction. Use relevant
existing controls; no weakened diagnostics or expected-result edits.

Only after the cold/semantic/lifetime screens pass: format maintained Swift,
focused profile controls, then complete four-profile collections, image handoff,
actual-image resources/ABI/allocation and complete Native/Pi stack/physical
ledgers, caller/criterion reconciliation and independent P08 exit. Existing nRF
resource acceptance is immutable baseline evidence, not transferable proof for
changed shared source. No hardware execution is authorized here.

## Risks, rejected alternatives and open questions

Concrete storage plus serialized scoped operations has positive compiler evidence;
its actual registration/read/action graph still needs the focused screen. Private
field extraction can introduce aliasing, a missed cleanup or wrong physical charge;
the checks above are mandatory. Code growth/stack changes require fresh actual
images and bounds, with no predicted byte saving or fit claim.

Reject flags/blanket annotations as the candidate, generic named fields alone,
cache warmup, metadata exemptions, copied model banks and raw-loan substitutions.
No fundamental impossibility of strict Native Static has been established.
If the required generic scope can only be specialized by opening unchecked
construction or changing its normative type/lifetime, report that exact boundary
for upstream decision; do not weaken it. Optional performance tuning remains
separate. P08 and the remaining resource/coverage obligations remain open.
