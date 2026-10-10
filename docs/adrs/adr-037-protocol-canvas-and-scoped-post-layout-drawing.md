---
id: ADR-037
feature: external-application-integration
title: Protocol Canvas and Scoped Post-Layout Drawing
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
  - ADR-010
  - ADR-011
  - ADR-028
  - ADR-029
  - ADR-030
  - ADR-031
  - ADR-035
  - ADR-036
related_specs:
  - SPEC-001
  - SPEC-006
  - SPEC-012
  - SPEC-013
  - SPEC-015
related_future_work: []
related_explorations: []
related_spikes: []
supersedes:
  - ADR-028
superseded_by: []
target_milestone: ITERATION-003
---

# ADR-037: Protocol Canvas and Scoped Post-Layout Drawing

## Status

Accepted by Eugene on 2026-10-10: “Let's accept ADRs and commit everything.
And after that let's proceed with specs update.” The
[acceptance record](../iterations/iteration-003-review/rfc-014-adr-acceptance.md)
preserves the reviewed commits, supersession and downstream contract gate.

## Context

The analyzer needs deferred drawing after Layout supplies local dimensions, with
stable model reads and bounded ownership. ADR-028 describes a retained client
drawing closure. Approved RFC-014 selects an owned protocol Canvas value with
scoped invocation so the deferred payload has explicit identity and lifetime
without retaining a read facade or copying a complete capture.

This follows accepted PROPOSAL-007's runtime scope under ITERATION-003 on macOS
Dynamic/Static, Pi 1 ARMv6 Dynamic and nRF52840 Embedded Static. The existing MVP
Canvas behavior is the regression contract. The choice changes representation,
not resolved drawing order, path/stroke semantics or backend responsibility.

## Decision Boundary

This record owns protocol Canvas representation and its scoped post-layout
invocation and plan lifetime. It supersedes ADR-028: the retained-closure
requirement is replaced with a protocol value while its timing, context, order and plan-lifetime requirements
are restated below. ADR-028 remains available as the historical predecessor.

ADR-029 transient Path snapshots, ADR-030 normalized strokes and ADR-031 failure
and startup-gate ownership remain unchanged. Fixed-domain access and safe backing
ownership follow the separate accepted ADR-036; semantic records follow accepted
ADR-035. Exact method spellings, payload layouts and failure codes belong in
Specifications. Their acceptance establishes architecture; affected Specification
amendments need approval before production migration.

## Decision

Canvas MUST refine View with `Body == Never` and remain a laid-out semantic leaf.
Concrete authored Canvas types MUST supply a synchronous drawing method accepting
checked local bounds and a scoped backend-independent GraphicsContext, without
authoring body or traversal. The compiled draw witness MUST additionally receive
its fixed domain's scoped read context. This leaf rule MUST NOT turn custom
non-Canvas views into Never leaves or replace their inferred bodies.

GiftUI MUST stage an owned Canvas value containing the exact selected model
identity and bounded scalar/selection payloads. It MUST NOT retain a read facade
or copy a full 404-record capture into that declaration. Each invocation MUST bind
a fresh scoped read to the selected owner/model/allocation generation, not resolve
through the host's current-root route. Backing ownership and mutation exclusion
MUST cover every model-reading phase under the selected scoped-access contract;
no additional historical snapshot bank is required.

Invocation MUST occur after Layout for the owning cycle-stable revision,
synchronously, without suspension, and at most once per Canvas occurrence per
derivation attempt. Occurrences MUST run in deterministic resolved painter order.
Drawing MUST NOT execute during ordinary body evaluation, Layout or backend frame
consumption. Local dimensions MUST be checked and nonnegative; translation and
clipping retain their existing framework ownership.

The drawing method MUST NOT mutate observed state, suspend, dispatch actions or
initiate a reentrant cycle. Its GraphicsContext, read facades and every borrowed
workspace view MUST NOT escape. Synchronous scoped path-building closures may
remain: the replaced representation is the retained escaping Canvas closure.

Drawing MUST produce a complete bounded immutable Canvas geometry plan before
frame offer, preserving the occurrence's position in painter order. Backends
MUST NOT resolve models or execute client drawing code. The owned plan MUST live
only from complete derivation through that attempt's synchronous one-shot offer
and MUST be discarded after either accepted or refused handoff. It MUST NOT be a
retained display list or replay payload.

Every staged Canvas value MUST be released on success or discard, no later than
finalization of its owning cycle. This includes caller cleanup when a producer
rejects before acquiring workspace or payload ownership. Staged values MUST NOT
remain in published semantic state, pending presentation intent or frame payloads,
or pass below the render-producer boundary. Model-data reads MUST end after their
last body/Canvas use or discard; registration/model ownership needed for other
purposes remains until its own retirement. Owned geometry may outlive the reads
through the governed synchronous offer.

Backend refusal MUST retain only pending presentation intent. Retry derives from
current model state rather than retaining model-reading declarations, replaying
admitted mutations or reusing the discarded geometry plan. A later failure MUST
NOT roll back already admitted model replacement or other mutations.

Owned Domain `SignalCapture` values MUST retain independent immutable snapshot
meaning. Presentation selection/read values MUST use a distinct explicit type
migration. Exporting a full owned capture requires an accounted destination
outside body/draw evaluation; scalar counter values do not need an analyzer bank.

## Rationale

An owned Canvas value retains bounded drawing inputs until resolved dimensions
exist, while a fresh scoped read gives each invocation access to the intended
model. This avoids treating an escaping wrapper as proof of backing lifetime and
fits the selected compiled View domain. A complete geometry plan still separates
client execution from backend consumption and preserves the existing one-shot
offer boundary. Serialized mutation exclusion gives stable reads without requiring
separate frozen model copies.

The RFC's representative protocol/inference/escape evidence supports this design.
It does not establish full source lowering, actual runtime-profile integration,
complete target image costs or production conformance.

## Consequences

### Positive

- Deferred drawing has an explicit bounded value and a scoped read lifetime.
- Canvas receives resolved local dimensions and preserves deterministic order.
- Backends consume owned geometry without application callbacks or model access.
- Existing Path/stroke semantics and one-shot plan disposal remain intact.

### Negative

- Canvas authoring and compiled witnesses require a deliberate source/API migration.
- Staged values, model ownership and geometry have different cleanup points that
  must be verified on early failures as well as successful drawing.
- A complete bounded geometry plan still costs memory; protocol representation
  does not itself prove zero heap, smaller stack or final target feasibility.
- Drawing remains synchronous and cannot retain context, mutate state or replay.

### Follow-up

- Amend/review SPEC-012 for the protocol, invocation, storage,
  cleanup and failure contracts; align SPEC-006 compiled traversal, SPEC-001
  presentation-capture migration and SPEC-013/015 profile storage/lifetimes.
- Under IH-2/3/4/5, cover both applications and all four configurations: inferred
  custom bodies, zero/multiple Canvas occurrences, exact model selection, checked
  dimensions, painter order, escaping contexts, early producer rejection, later
  postcommit failures, refused offers, release/teardown and pixel equivalence.
- Under IH-6, measure actual staged values, complete plan/workspace storage,
  owner/registration overlap, linked allocation reachability and complete stack
  bounds. Preserve Static zero heap and all applicable image/workload limits.

## Deferred and Follow-up Work

No new deferred item. Required migration and conformance stay in the RFC-014
IH-1–6 handoff after ADR acceptance and Spec approval. Retained rendering,
asynchronous drawing and general Swift frontend work remain outside this scope.
Terminal investigations are evidence, not authority for production adoption or
a further experiment round.

## Rejected Alternatives

### Keep a retained escaping Canvas closure

The approved design selects an owned protocol value with a separately scoped draw
witness to make deferred inputs and their read lifetime explicit. Synchronous
scoped `withPath` closures do not carry the same retained-payload obligation.

### Draw during body evaluation, Layout or backend consumption

Body evaluation lacks resolved size. Layout does not own client drawing. Backend
execution couples client failure to irreversible consumption instead of completing
and validating geometry before offer.

### Store full owned captures or retain a replayable plan

Full captures retain valid value semantics at explicit export boundaries but add
unnecessary copies to presentation declarations. Replayable geometry adds retained
identity, ownership and replay semantics excluded by the one-shot lifecycle.

## References

- [Approved RFC-014](../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md), especially Protocol Canvas and capture values, Publication and retirement, Compatibility, and Decision Summary item 3.
- [Accepted PROPOSAL-007](../proposals/proposal-007-external-application-integration.md) and [runtime scope amendment](../iterations/iteration-003-review/runtime-derivation-scope-amendment.md).
- [RFC approval provenance](../iterations/iteration-003-review/rfc-014-final-review.md).
- [ADR-028: Post-Layout Canvas Derivation and Cycle-Local Plan](adr-028-post-layout-canvas-derivation-and-cycle-local-plan.md), superseded predecessor.
- [Accepted ADR-036: Scoped Model Access and Bounded Ownership](adr-036-scoped-model-access-and-bounded-ownership.md).
- [Implementation handoff](../iterations/iteration-003-review/rfc-014-implementation-handoff.md).
