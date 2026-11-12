---
spec: SPEC-013
feature: giftui-mvp-architecture
title: Implementation Design — Qualified Static Drawing Storage
status: current
authors:
  - codex
created: 2026-11-06
updated: 2026-11-06
implementation_plan: ../implementation-plans/spec-013-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Qualified Static Drawing Storage

This note describes the internal storage realization for the finite Counter
Static Drawing workspace. The current linked pipeline requests metadata for the
generic workspace owner while qualifying a Canvas reference and dispatching to
its Drawing base. The new realization gives Counter a concrete owner and keeps
one qualification algorithm. Focused actual consumer and Native control gates pass. Complete artifact and
P08 qualification remain open.

## Governing contract

[SPEC-013](../specs/spec-013-runtime-profiles.md#compatibility) permits internal
storage changes with equivalent behavior, limits, audits and conformance
evidence. RP-TB-003/004 retain setup, refusal, cleanup and complete-path costs.
RP-RD-003 and the performance requirements retain Static zero heap and complete
linked fit. [ADR-039](../adrs/adr-039-scoped-storage-ownership.md) governs the
backing loans. [ADR-041](../adrs/adr-041-native-static-typed-model-backing.md)
continues to govern the surrounding Native typed owner. The
[SPEC-013 plan](../implementation-plans/spec-013-implementation-plan.md#milestone-4-static-generation-storage-and-coordinator)
T4.2 and T4.4–T4.6 provide the fixed-storage, capture, coordinator and compile
obligations. [RFC-014 P08](../iterations/iteration-003-review/rfc-014-implementation-plan.md)
and [SPEC-015 T8.1](../implementation-plans/spec-015-implementation-plan.md)
qualify the actual finite Counter consumers. This derived note grants no
contract or lifecycle transition.

## Storage and control flow

`StaticCounterRecordDrawingWorkspace` stores the existing
`StaticCounterDrawingWorkspace` base followed by a `SemanticRecordReference?`
qualification. The generic `StaticRecordDrawingWorkspace<Base>` remains the
compatibility realization. This follows the MP06 pattern already used by
[SemanticRecordTraversalRealization](spec-006-runtime-record-banks.md): the
concrete owner supplies fields, and the existing algorithm has one home.

The stateless `StaticRecordDrawingQualification` namespace implements acquire,
Canvas lending, discard and reset over explicit `inout` base and qualification
fields. It owns no state. Each wrapper
projects its stored fields directly. Both use the same owner/bank/revision
match for readers and forward the original ordinal to the base on a match.
Capacity, active state, summary, seal and the existing Drawing algorithm
continue to come from the base.

A successful acquire clears qualification after the base acquires. Failed
acquire preserves the previous qualification. On the first Canvas call the
wrapper records the supplied reference before invoking the base. A mismatched
owner, bank or revision throws the existing invariant error before the
callback. A base error leaves qualification in the existing state for cleanup.
Seal forwards the count. Discard and reset first act on the base, then clear
qualification. An absent or mismatched qualification gives readers the
existing absent result. The one base callback retains its original argument
order and typed failure.

## Backing and profile realization

The concrete wrapper occupies the existing typed Drawing slot. Its base still
borrows the original path and plan regions from the same caller-owned donor.
`withBase` invokes the nonescaping body with `&base`, the actual stored field,
for the lexical exclusive loan. Access uses that address directly throughout
inspection and mutation. A getter/setter temporary or copy-back would break
physical address and loan evidence. The loan ends before another field access,
reset or release. The wrapper stores scalar qualification rather than a model,
read or semantic-bank borrow. The existing initialized-prefix unwind and
backing-last retirement keep ownership of all regions.

Declare the concrete owner beside `StaticCounterDrawingWorkspace`. Use it in
the actual Counter profile storage, geometry, scoped slot/factory, storage-region
ledger and Embedded layout builder. Recompute size, stride, alignment, region placement and charged bytes
from that type. The generic compatibility callers and Dynamic Drawing owner
retain their current realizations. Revalidate any profile whose registered
route includes the changed Static fixture.

## Qualification and evidence

- Compare existing success, wrong-owner/bank/revision, acquisition refusal,
  typed Canvas failure, discard/reset and repeat-session transcripts. Verify
  exactly-once callbacks and backing-last cleanup through the actual owners. Run
  any generic/concrete comparison in a separate process from the actual cold
  entry so it cannot initialize shared provider state before measurement.
- Verify the actual base address, its two original region loans and disjoint
  typed slots in the physical ledger. The direct projection preserves storage
  identity at source. Fresh compiled address, layout and lifetime evidence
  qualifies the real consumer and its aliases.
- Bind Native and Embedded actual constructor/dispatch/cleanup paths to the
  current compiler and linked artifacts. Check whether the specific generic
  workspace metadata request disappears across the entire charged path,
  including setup and retirement. Measure cold/reuse with the existing observer
  and preserve any residual allocation paths. The Static observer supplies
  observations within its known provider coverage.
- Recompute affected linked stack, RAM, flash and ABI evidence, including
  construction temporaries, cleanup and nRF IRQ overlap. Check the current
  ARMv6 route when collecting its affected evidence. A prior size or fit does
  not transfer to the new typed slot.

The source seam is [StaticRecordDrawingWorkspace.swift](../../Sources/GiftUIRuntimeStatic/StaticRecordDrawingWorkspace.swift).
The existing [P08 receipt](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/progress.md)
records compiled evidence, rejected alternatives and remaining acceptance.

The seven-file group covers 19 matching typed references and both constructors.
The separate Native control passes 11 checks, including equal size, stride and
alignment and the direct address comparison. The actual Native and Embedded
focused gates pass. The cold observer records 159 events and 15,569 requested B
with zero reuse events. Linked origin attribution and whole charged-path
qualification remain open. Target ABI and physical fit need refreshed artifact
evidence after the type change.
