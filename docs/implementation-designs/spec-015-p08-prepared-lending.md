---
spec: SPEC-015
feature: giftui-mvp-architecture
title: Implementation Design — P08 prepared lending
status: draft
authors: [codex]
created: 2026-10-16
updated: 2026-10-16
implementation_plan: ../implementation-plans/spec-015-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# P08 prepared lending

**Proposal boundary: one compatible private realization; no source allowance or
fit claim.** The [independent current-image review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-firmware-independent-review.md)
at `3716ee2d` accepts the package and confirms actual firmware stack FAIL. Its
28,560-byte required subset exceeds main 27,648 before many enclosing costs.
SPEC-015 remains implementing, its plan active and P08/R07/T8.1 open. No source,
compiler, test, build, link, resource limit or hardware changes occur here.

## Measured target and governing contract

Select **prepared lending with one referenced fact value**. Move preflight's
whole-owner receiver materializations out of the activation that encloses the
host, and stop propagating the preparation's individual fields by value through
the original loan callbacks. This changes private fixture data flow, not the
required host or shared framework representation.

Actual ELF `e649c5d2…` in the [current resource packet](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/linked-firmware-current/manifest.json)
provides the concrete cause:

- `owner.withStorage`, symbol 6515 at `0x10cb8`, reserves **3,856** fixed bytes.
  It copies **1,006 owner bytes twice**, into SP-base+2,616 and SP-base+1,608,
  before `requireEmpty` and `prepareSession`. Both homes remain reserved through
  the host factory. At +0x42/+0x86 it calls actual outlined helper `0x53728`:
  `mov r0, sl; b.w memcpy`, with original owner in r1 and 1,006 in r2. These are
  physical receiver homes, not two logical physical owners.
- The source then destructures `P08SessionPreparation` into fourteen addresses,
  five complete entries and capacities. Nested callbacks propagate those values
  alongside remaining slot descriptors. The four actual byte-loan forwarders
  reserve **552/536/520/496** bytes. Their **2,104 total is observed cost**, not
  wholly removable overhead or an estimated saving.
- Current constructor 9,968, session/caller 5,960 and actual preset factory
  3,360 remain real separate costs. This proposal does not replace mandatory
  host state payloads, remove its Optional destination or promise to remove those
  frames. In particular, subtracting 2,012 from an incomplete lower bound cannot
  establish fit.

[ADR-039](../adrs/adr-039-scoped-storage-ownership.md#decision),
[SPEC-013 S13.1/2](../specs/spec-013-runtime-profiles.md#s131-physical-owner-session-and-coordinator-contract)
and [SPEC-015 S15.1/2](../specs/spec-015-host-configuration.md#s151-construction-transfers-and-retirement)
require the same actual physical owner, exclusive session, typed borrows, complete
carrier dependencies, one Interaction machine and exact cleanup/accounting.
P08/SO-04–08 permit a replaceable internal realization satisfying those duties.
The reference-application justification remains ITERATION-003 I3-04/I3-05 and
four-configuration stack validation; I4-07/P09–P12 allocation is unchanged.

## Exact source organization and control flow

The intended maintained-source change is confined to
`Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterScopedStorage.swift`:

1. Keep `P08TypedBackingOwner.withStorage` as the same exclusive mutating factory
   and owned-Result boundary. Introduce a concrete noninline **begin operation**
   taking the actual owner inout. It performs, in the existing order, idle/capacity
   validation, complete `requireEmpty`, checked serial increment, active transition
   and `prepareSession`. It returns the existing owned preparation value. Its
   receiver copies and validation scratch end before the prepared lender starts.
2. Keep one local `var prepared: P08SessionPreparation` in the thin factory;
   make that private fact type `~Copyable`. It still contains only the current
   owned addresses/entries/capacities, with no new pointer or scoped capability.
   Do not destructure it into nineteen captures. No owner field, donor object,
   physical offset, reservation, capacity or measurement-root inventory changes.
3. Within a lexical block, derive the **existing** `P08SessionLifetime` from a
   borrow of that same actual owner and its current identity/serial. Pass it,
   the selected original slot descriptors and **inout prepared** to one prepared
   Static lender (and the corresponding Dynamic lender). The explicit inout
   fact ABI avoids asking a borrowing receiver ABI to transport the fact aggregate
   by value. It is readonly by implementation; no shared/cached mutable authority
   is added. The actual owner remains exclusively accessed by the outer factory.
4. Move the current loan nest into that lender with its order unchanged:
   b0/b1/b2/b3/g0/g1/g2/g3/g4/c0/h0/r0/r1/h1 for Static; the existing nine actual
   Dynamic loans for Dynamic. The lender has **no whole-owner parameter or
   capture**, no preflight/inventory-query calls and no return of descriptors.
   It retains the original per-slot `withBorrow` calls, not raw replacement loans.
5. At the innermost loan, compare every actual address against `prepared`'s
   corresponding stored fact, retain all provenance/capacity checks, and pass
   the five original complete entries and capacities to the unchanged storage
   session constructor. Copy owned operation arguments at that final call;
   do not spread them through ancestor closure parameters. Consume the resulting
   session into the same body exactly once. Its constructor dependency on the
   actual-owner token and all original typed accesses is unchanged.
6. After the prepared lender returns, end the token/slot/fact loans before any
   owner mutation. A separate noninline **finish operation**, again on the actual
   owner inout, performs the original `requireEmpty` then idle transition. Return
   the same owned Result. No early-return, error or trap recovery is introduced.

Private lender signature shape (design, not compiled source):

```swift
fileprivate func withPreparedStaticStorage<Result>(
    slots: borrowing P08StaticSlots,
    token: borrowing P08SessionLifetime,
    prepared: inout P08SessionPreparation,
    ownerIdentity: UInt, sessionSerial: UInt64,
    transcript: UnsafeMutablePointer<P08RoleTranscript>?,
    _ body: (consuming P08StorageSession) -> Result
) -> Result
```

`P08SessionLifetime.lend`, the five access types and storage-session constructor
keep their existing lifetime annotations. The token's actual-owner borrow encloses
all fourteen typed borrows even though it is established before the first one;
no access is constructed until the complete nest is held. Slot descriptors are
the original owner's immutable values, with the same original-address checks.
The preparation is owned evidence, not another lifetime root or initialization
inventory. `Result` retains the existing owned/escapable restriction.

## Preservation and risks

Leave shared Interaction, supplied/pipeline/coordinator/host/retired types and
all required host cases unchanged. Both profiles retain their consuming moves,
full lifetime unions, semantic→geometry→Interaction reset and backing-last release.
All first errors, serial/phase checks, pair-capacity/unequal-extent cases, physical
initialization-prefix faults, two-host same-address reconstruction, complete
recordings/fingerprints, foreign origins and exact observations remain. Empty
validation still precedes session entry and follows completed logical cleanup.
Keep four slots/138,880 bytes, main 27,648, RAM 196,608, compiler and corpus fixed.

The new physical mechanism is removal of whole-owner receiver queries from the
host-enclosing lender and replacement of repeated by-value fact captures with one
inout fact value. A helper name or annotation alone is not success. The compiler
may create replacement aggregate homes, flatten captures, reject the nested inout/
scoped-token combination, or enlarge other frames. Native exclusivity may expose
a longer inout conflict. Stop for a precise source/contract diagnosis if acceptance
would require suppressions, raw lifetime erasure, dropped dependencies or changed
cleanup; no such fallback is part of this proposal. Cold begin/finish costs still
count on their own feasible paths. Actual complete fit remains unproved.

## Suggested bounded execution and validation

Request **one initial source candidate and at most one grouped correction** for
this same mechanism, after independent design review. This is a suggested new
allowance for explicit authorization, not a reset of any closed historical budget.
Freeze source/review and refresh exact existing recipe/applicability identities;
excluded-source predecessor qualifications must remain explicit.

First screen: review source invariants; run the existing three fresh focused
[collection recipes](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-constructor-caller-cycle2-source.md),
including both Native runtime/exclusivity/projection families and nRF layout.
Before any full collection, also inspect **one isolated actual-firmware-flag
counter-object diagnostic**: replay the archived real P08CounterRuntime compiler
recipe with only output-map/module/cache destinations redirected under `.build/`,
verify unchanged imported-module/source identities and preserve its exact argv.
This is an object screen, not an image or a partial-receipt image handoff.

Verify begin/finish return outside host work, the lender no longer has the two
whole-owner homes, preparation facts do not become repeated aggregate arguments,
all original callback/lifetime chains compile and actual cold/live/current/stale/
cleanup paths show no necessary rejection. Measure replacement frames and typed
callback/SP areas; shrinking one prologue is insufficient. If the same physical
rejection persists, stop without a new mechanism or full-suite/image spending.

Only after a favorable source/behavior/object screen, collect the required full
current counter boundaries and use the unchanged complete-receipt guard for the
normal pristine firmware build. Final ELF stack/IRQ, RAM/flash, ABI, rooted zero
heap and matched Dynamic costs remain required; the diagnostic cannot close them.
Every current-source omission and Pi/Native/owner conformance obligation stays
visible. Independent result/exit review follows; no hardware operation is included.

The decision at this boundary is whether to authorize that exact bounded source
candidate. A stack amendment instead needs the complete phase/IRQ and whole-RAM
proposal already identified in the assessment; this design requests none.
