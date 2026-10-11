---
id: ADR-036
feature: external-application-integration
title: Scoped Model Access and Bounded Ownership
status: accepted
authors:
  - codex
created: 2026-10-10
updated: 2026-10-10
proposal:
  - PROPOSAL-007
related_rfcs:
  - RFC-014
related_adrs:
  - ADR-011
  - ADR-024
  - ADR-025
  - ADR-026
  - ADR-033
  - ADR-034
  - ADR-035
related_specs:
  - SPEC-002
  - SPEC-001
  - SPEC-006
  - SPEC-010
  - SPEC-011
  - SPEC-012
  - SPEC-013
  - SPEC-015
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# ADR-036: Scoped Model Access and Bounded Ownership

## Status

Accepted by Eugene on 2026-10-10: “Let's accept ADRs and commit everything.
And after that let's proceed with specs update.” The
[acceptance record](../iterations/iteration-003-review/rfc-014-adr-acceptance.md)
preserves the reviewed commits, supersession and downstream contract gate.

## Context

Accepted PROPOSAL-007's runtime scope requires actual analyzer/counter declarations
on macOS Dynamic/Static, Pi 1 ARMv6 Dynamic and nRF52840 Embedded Static. Runtime
body evaluation and deferred post-layout drawing need typed access to live backing
without copying the analyzer's complete capture into every declaration. A model
key alone cannot keep backing alive, and a scoped wrapper around a pointer does
not establish its pointee lifetime.

Approved RFC-014 selects fixed-domain compiled access, stable owned storage and
serialized mutation exclusion through graph/Layout/draw. Separate frozen model
copies are unnecessary. The maintainer selected three capture banks with bounded
replacement refusal; additional metadata does not authorize another model bank.
MVP analyzer semantics remain regression requirements, not a new MVP commitment.

## Decision Boundary

This record owns the typed model-read/write boundary and the ownership/capacity
rules that make it safe. It preserves ADR-011/024/025/026/033/034 and does not
supersede them. Runtime semantic records and Canvas representation are separate
RFC-014 decisions. Exact declarations, layouts, error mappings and source-tooling
integration belong in Specifications. External packaging remains RFC-013's scope.

## Decision

### Fixed-domain access and source transformation

Each compiled View conformance MUST have one fixed read-domain type. Its scoped
read context MUST be a concrete nonescapable generic type parameterized by that
domain; the design MUST NOT require a nonescapable associated type or a
method-generic body context.

GiftUI MUST own generic View/builder/key/read-scope and failure contracts, without
application schemas, Runtime lookup, global/task-local resolvers, reflection or an
`Any` registry. An application-generated schema surface MUST own field types,
schema-specific read requirements, scoped facades and pure computed getters. A
host/profile bridge MUST implement them against concrete storage. Authored
portable framework usage MUST import GiftUI; existing Domain imports remain
allowed. Generated presentation imports its schema surface. Authored presentation
MUST NOT import Runtime or encode target storage offsets.

Finite source transformation MUST preserve authored body/property intent and
evaluation order while producing checked reads/writes and typed failure transport.
Generated custom views and core containers MUST carry the same domain as a type
argument, not a stored read context. Their opaque body witnesses MUST constrain
that domain while allowing Swift to infer concrete Body types. Stateless primitives
MUST lift as leaves; stateless custom views MUST retain custom traversal. Never
remains the leaf Body: a universal `Body.Domain == Domain` constraint or a broad
Never default MUST NOT suppress custom body witnesses.

Before exposing a facade, the bridge MUST validate owner identity, schema,
occupied slot, allocation generation and read phase. Scalar getters may then
return owned values without another owner lookup; indexed capture access MUST
still check bounds. Nested aggregates MUST expose scoped facades, never mutable
references, raw storage descriptors, service objects or owning tickets.

The trusted bridge MUST establish backing ownership, initialization, alignment,
bounds, disjoint writes and lifetime before constructing any read view. A borrowed
pointer descriptor is insufficient. Source lowering MUST reject unsupported
escaping uses, unchecked aliases, arbitrary unchecked `inout` callbacks and
unmanaged reference writes, with no runtime fallback around this boundary.

The initial implementation MUST pin/check the tested project-local Swift 6.3.2
configuration with `LifetimeDependence`, `Lifetimes` and internal lifetime
annotations. Generated/internal access code may depend on these; authored code
MUST NOT expose the annotations. Missing required features MUST fail clearly,
without a global compiler change, a newer associated-type feature dependency or
unchecked fallback. Compiler changes that require different public semantics
MUST return for a decision.

**Current compiler configuration — approved 2026-10-12:** the
[Swift 6.4 baseline correction](../iterations/iteration-003-review/rfc-014-compiler-baseline-correction.md)
supersedes the initial version-specific 6.3.2 pin above for RFC-014 migration.
The [explicit approval](../iterations/iteration-003-review/rfc-014-spec-approval.md#swift-64-compiler-baseline-correction--2026-10-12)
preserves this decision's public semantics, lifetime guarantees, required feature
settings and prohibition on unchecked fallback. The initial pin remains recorded
as provenance; current implementation and fresh evidence use the approved 6.4
configuration. A later change of public semantics still requires a decision.

### Stable ownership, phases and State

Static MUST use stable typed storage supplied before activation. Dynamic may use
retained objects internally but MUST enforce equivalent configured bounds and
outcomes. Model schema, owner-instance identity, model allocation generation and
structural registration/target generation MUST remain distinct.

Copied model keys MUST be nonowning. A live owner MUST retain backing before key
validation; generation checks through freed storage are invalid. Owning tickets,
frame pins and registration references MUST have explicit bounded lifetimes and
release paths. Backing MUST be reclaimed only after every relevant owner/reader
ends. Detaching a registration MUST NOT invalidate independently retained models;
host caches MUST NOT hide independent ownership behind the current-root route.

Observable writes MUST use an exclusive checked mutation route. Phase, identity,
capacity and fallible preconditions MUST be validated before changing bytes.
Model data MUST be separate from registration/dirty and coordinator result
storage so synchronous reporting does not overlap a mutable model borrow. Preserve
coarse model-owned reports, proven no-op omission and admitted mutation order;
do not add property dependency tracking, Combine or Apple Observation.

Fallible compound capture writes MUST preflight before a non-failing commit.
Unaccounted full-capture rollback copies are not permitted. Later derivation or
drawing failure MUST NOT replay admitted mutations or service side effects.

Serialized mutation exclusion and backing ownership MUST cover the entire frame
model-reading interval, including Layout and post-layout drawing. No additional
snapshot bank or OS lock is required by this baseline. External facts MUST enter
through the existing admission owner rather than mutating frame-visible data.
Read scopes MUST end between parent body evaluation and child State discovery;
the frame's exclusion and ownership persist. Discovery authority may reserve
metadata, materialize an inert new model and stage registration, but MUST NOT
mutate an existing frame-visible model. Bind new State before its body; preserved
State ignores repeated initializer seeds. Ordinary replacement remains
mutation-phase only. Candidate associations follow SPEC-010 publication/discard.

End model-data reads after the last body/Canvas use or discard. Registration and
model ownership MUST persist until their own retirement points. Teardown MUST
quiesce admission/producers, drain active synchronous/IRQ handoffs, retire
registrations and invalidate generations before releasing backing last.

### Three-bank replacement and capture meaning

The analyzer MUST retain ADR-034's source/admission/model reservation:
**3 × 404 × 16 = 19,392 transition bytes**. The selected configuration has two
bounded analyzer metadata records and one model-capture entitlement. An installed
analyzer MUST reserve that entitlement even while empty. Counter scalar storage
is separate. Source/admission banks MUST NOT be loaned to model replacement;
implicit sharing, COW, a fourth bank and heap fallback are excluded.

Replacing populated installed A with inert empty B requires explicit transfer
of A's last owning ticket, no surviving independent A owner/reader, and reserved
metadata, registration and generations. Candidate attachment MUST observe B's
actual empty seed. Reservation through commit/discard MUST be guarded against
reentrant writes, frame reads and ownership changes that invalidate it.

Precommit failure MUST preserve A's data, identity, attachment and dirty state,
releasing candidate-only reservations exactly once. Success MUST activate B,
retire A's association and release the explicitly transferred final ownership,
then make the model-bank entitlement available to B. B's count/baselines define
its empty state without clearing old bytes; generations reject stale A keys.
Later derivation/drawing failure MUST preserve committed B. Required detach hooks
follow SPEC-010 invariant-failure rules, without an invented postcommit rollback.

If retained A prevents transfer, replacement MUST refuse before commit while
keeping that owner valid. A second populated candidate requires unavailable
backing and MUST refuse. An empty candidate MUST NOT bypass entitlement checks
only to fail its first normal capture update. Initial materialization may use
a candidate already owning the sole model bank when no installed analyzer needs
it. Two metadata slots MUST NOT imply two captures or guaranteed replacement.

Owned Domain `SignalCapture` values MUST preserve their independent immutable
snapshot meaning. Scoped presentation selection/read types MUST be an explicit
migration, not a silent alias substitution. An owned full-capture export requires
an accounted destination outside body/draw evaluation. ADR-034's five-second
horizon, baselines, replay/Clear and admitted workload semantics remain unchanged.

## Rationale

Fixed domains let Swift infer Body while keeping application-specific schemas
outside the generic framework. Stable backing and scoped access separate three
different responsibilities: keeping storage alive, validating identity and
excluding mutation. Serialized reads provide stable frame data without paying
for another capture version. Explicit bounded refusal preserves both existing
owners and the selected three-bank budget.

The RFC's final six-module fixture supports representative inference, escape
controls and the guarded capacity transaction. It does not prove a complete
source transformer, actual runtime ownership, target execution or zero heap.

## Consequences

### Positive

- Authored body/property intent and inferred Body remain available across profiles.
- Backing, borrowed access and registration have explicit independent lifetimes.
- Frame stability requires no copied model version; retained owners stay valid.
- Analyzer transition capacity remains the accepted three-bank reservation.

### Negative

- Source transformation, schema generation and the trusted bridge require precise
  compiler integration and exhaustive supported-source coverage.
- Two metadata slots still permit replacement refusal when backing is unavailable.
- Tickets, descriptors, registration and frame pins consume storage beyond the
  three transition banks; compiler/phase checks alone cannot prove safety or fit.
- The selected internal lifetime features constrain supported compiler versions.
- Presentation capture selection changes compiled contracts and needs migration.

### Follow-up

- Amend/review SPEC-006/010/011/012 for compiled access, State/action generations,
  checked mutation, drawing reads and typed failure routing; SPEC-001 for explicit
  presentation-capture migration; SPEC-013/015 for compiler policy, profile storage,
  owner capacities, exact transaction failures and teardown.
- Under IH-2/3/5, cover all analyzer/counter source routes, pure computed/nested
  reads, helper/short-circuit order, compiler escape/exclusivity controls, real
  pointer backing and host tickets, State discovery/ignored seeds, replacement
  success/refusal, attach/detach/report failures, stale keys/actions, generation
  exhaustion, removal/reinsertion and every release path on both profiles.
- Under IH-6, account for all descriptors, registrations, owners, alignment,
  construction/service/teardown and feasible stack/IRQ overlap. Prove linked
  Static zero heap and resource limits and measure matched Dynamic costs. Fixture
  subtotals, the provisional control allowance and absent costs are not budgets.

## Deferred and Follow-up Work

No new deferred item. These are required IH-1–6 obligations after ADR acceptance
and Spec approval, not another investigation round. RFC-014 keeps terminal
SPIKE-069–074 evidence and its limitations. General Swift frontends, arbitrary
cross-domain composition and external delivery are outside this finite scope.

## Rejected Alternatives

### Separate frozen copies or another populated-model bank

Serialized mutation exclusion makes copied frame versions unnecessary. A fourth
bank would permit more retained/populated models but adds 6,464 transition bytes
and changes the maintainer-selected ADR-034 capacity policy.

### Unbounded owners, hidden bank overlays or owner revocation

These evade finite resource limits or invalidate still-owned models. Bounded
refusal exposes the capacity limit before commit instead.

### Global resolution, unchecked callbacks or generation-only pointer safety

Global resolution violates dependency boundaries. Callback discipline and phase
bits do not prevent escaping wrappers; generations cannot resurrect freed backing.

### User-facing scoped-read APIs or reconstructed concrete Body aliases

Explicit read APIs change the selected authoring surface. Reconstructing all Body
types is unnecessary with fixed-domain inference; making custom views Never leaves
to evade inference would change traversal semantics.

## References

- [Approved RFC-014](../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md), especially Typed access and inferred Body, Mutation, State discovery and ownership, Three-bank replacement policy, Static / Embedded Impact, and Decision Summary item 2.
- [Accepted PROPOSAL-007](../proposals/proposal-007-external-application-integration.md) and [runtime scope amendment](../iterations/iteration-003-review/runtime-derivation-scope-amendment.md).
- [RFC approval provenance](../iterations/iteration-003-review/rfc-014-final-review.md).
- [Three-bank capacity contract](../iterations/iteration-003-review/rfc-014-capture-policy-choice.md) and [typed access contract](../iterations/iteration-003-review/rfc-014-typed-access-contract.md), as consolidated by the approved RFC.
- [Implementation handoff](../iterations/iteration-003-review/rfc-014-implementation-handoff.md).
- [ADR-034: Five-Second Transition Capture](adr-034-five-second-transition-capture.md).
