---
spec: SPEC-015
feature: giftui-mvp-architecture
title: Implementation Design — P08 Typed Stage Realization
status: draft
authors:
  - codex
created: 2026-10-15
updated: 2026-10-15
implementation_plan: ../implementation-plans/spec-015-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — P08 Typed Stage Realization

Current realization update: [cycle 1's measured 75,224-byte rejection](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-stage-realization-cycle1-screen-result.md)
and independent approach PASS `18dfac6d` lead to the [final cycle-2 source freeze](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-stage-realization-cycle2-source-freeze.md).
It fuses the initial nested phases into lexical typed construction, lends the host
to operations inout and bounds owned observations/action leaves. The original
design sections below explain the initial candidate; this linked freeze records
the precise current update. Required contracts and limits stay unchanged; 2/2 is
consumed, independent source review and actual compiler/resource results pending.

This derived note selects one private realization under [SPEC-015 S15](../specs/spec-015-host-configuration.md#s152-additional-acceptance-criteria),
[accepted ADR-039](../adrs/adr-039-scoped-storage-ownership.md) and plan T8.1/P08.
It does not amend their ownership, workload or resource contract. The
[new activity](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-stage-realization-activity.md)
authorizes a grouped initial candidate and at most two cause-grouped corrective
cycles after design review. Prior allowances remain closed. Independent design
review passed at `d7df2c80`; the [initial source freeze](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-stage-realization-source-freeze.md)
implements the selected private realization and awaits independent source review.
No compiler run, measured saving or fit claim accompanies this note.

[Independent Strong design review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-stage-realization-independent-design-review.md)
passes this internal realization at `8bc9c9a4`. Initial source implementation is
ready under the activity; no source/compiler/fit result is implied.

## Evidence and the replaceable mechanism

The [candidate A result](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-stack-candidate-a-screen-result.md)
pins object `025dc84f58f2c26cb9188132475995405bae8cbb3e7b6b174eb87b8190868b03`
and exact ET_REL sections/relocations. Its source is the corrected candidate A
at `9cac6bfa`, independently accepted before the one screen. Remaining frame
lower bounds are body 9,176, private stage `run` 38,672, reuse 66,616,
`constructOwner` 37,768, `constructHost` 42,928, `finish` 31,376 and corpus root
30,096 bytes. The source-required nonnull transcript branch and actual non-tail
calls prove body→run→reuse ≥114,464 bytes; mutually exclusive construction and
cleanup branches are not added to that total. The [previous design](spec-015-p08-stack-materialization.md)
and its completed candidate remain historical evidence.

`CounterHostState` is **required** by SPEC-015 S15.2: inert(supplied, span),
active(coordinator, optional model ticket, span), retired(retired storage, span),
with the stated lifetime union on every rewrite. It remains unchanged, including
its activation/opportunity/quiescence behavior. `P08BodyStage` and
`P08BodyCleanup` in `CounterScopedStorage.swift` are a **private fixture** envelope,
not those contract state cases. They repeatedly take a maximum-size Optional,
switch its carrier, and reinsert it to support several early exits. Replacing
that envelope does not remove a required carrier, enum case or lifecycle step.

The observed frames, source take/reinsert sites and unchanged 3,889-byte copy
sites justify targeting this envelope and the reuse function. They do not prove
that every byte is redundant or that typed helpers will be optimized as intended.
The compiler may still materialize required state or consumed arguments; the
first target screen must charge it and reject oversized paths.

## Typed phases and cleanup

Keep the implementation in the existing fixture. Replace only `P08BodyStage` /
`P08BodyCleanup` with concrete fileprivate Static and, under the existing
non-Embedded guard, Dynamic phase functions. Each consumes the existing exact
session/supplied/owner/host type; no new generic owner abstraction or capability
getter is introduced. Each returns only an owned report containing `checks: Int`,
`constructed: Bool`, `activationAttempted: Bool`. This report contains no pointer,
scope, closure, workspaces or origin authority.

`runP08ScopedBody` remains inside `withP08Storage`. It retains the original
model/root lenders and `InlineArray<1, UInt8>` activation backing across the
entire typed call chain. It installs the producer origin once before any early
exit. It lends model/root projections using the existing lawful `borrowedScope`
and `borrowedRoot`, and transfers the same borrowed semantic/value projections
already supplied by its enclosing callbacks. No helper returns a scoped carrier
to a longer scope. Supplied/owner/host construction keeps every existing
consuming parameter and lifetime union; helper inputs must remain scoped rather
than acquiring an unchecked lifetime annotation. Failure to express this with
ordinary supported ownership rules is an implementation failure, not permission
to erase dependencies.

| Phase | Existing transfer / operation | Early cleanup, before returning owned report |
| --- | --- | --- |
| Session | Consume into the actual Static/Dynamic supplied initializer | `early == 1`: mutable session `reset()`, checks 1, unconstructed |
| Supplied | Consume into the exact concrete owner with original activation span, assembly and `failAfterRuntime` | `early == 2`: consume `retireInertStorage()`, then `resetAfterQuiescence()`, checks 1, unconstructed |
| Owner | Same full local/foreign join snapshots and rejected-binding checks, then consume into the existing platform preset factory | `early == 3`: execute the existing eight owner teardown hooks in order, checks 1, constructed but not activation-attempted |
| Host | Keep one mutable host, execute the original reuse / early-5 / candidate-failure / ordinary lifecycle branch | `early == 4`: checks 1 without activation; all host returns run the same teardown and `teardownStep == 8` assertion |

An owner-only cleanup helper invokes, in order: refuse application delivery/input;
stop sources/detach observations; cancel pointers/callbacks; quiesce/finalize;
retire observable registration/routing; release platform owners; reset profile
storage; invalidate report/runtime use. It receives an inout concrete owner and
does not store or return it. Host-phase `defer` is lawful because that host is
never consumed again: its subsequent operations only mutate it in place. Do not
capture a session/supplied/owner in a defer and then consume that captured value.
Branch cleanup precedes transfer or return; the nonthrowing phase functions have
no recoverable error path that skips cleanup.

After the phase returns and its host defer has completed, the root applies all
existing `finish` postconditions to the original control, conditional on the two
owned flags: input ineligible; attempted activation means unavailable; otherwise
no wake/scheduler/constructions/teardowns and not unavailable; balanced observations;
no frame/seal/pending state/pointers/capture/source; no root or committed records.
Then retire the producer origin exactly once and return the unchanged check
count. No direct early return bypasses this common completion. Preserve reset
order semantic→geometry→Interaction and all backing-last outer callbacks by
calling the existing retirement/reset operations rather than reconstructing them.

Static and Dynamic use the same phase order and postconditions with their exact
existing types and platform factory selection. The original joins count enters
the ordinary lifecycle branch at the same point; early returns keep their
existing count of 1. Reuse already tears down its host; the host-phase defer
retains the second teardown, preserving the existing idempotency coverage.

## Reuse observations without a single large operation body

Keep `p08RunReuseHost` as the ordering function with its existing closed generic
constraints. Extract sequential operations into noninlined typed helpers with
those same constraints, never a new escapable wrapper. Preserve these boundaries:
activation/initial frame; stale origins; current pointer; current action;
current admission; current source; terminal host. The main admission is created
at its original point, before stale operations; the same instance feeds current
pointer/admission operations and is retained for the first host's transcript.
Keep original action capture and presentation revision observations in order.

The stale-origin phase creates **one** complete `P08ReuseFingerprint` and one
model-value observation before the first stale operation. Borrow that same
fingerprint through action prepare/delivery, input, admission and source helper
calls. Each existing comparison remains after its corresponding operation; never
refresh the baseline between groups, replace it with a hash, remove a field or
accept only a final aggregate comparison. Helpers return check counts only.
The existing noninlined full-fingerprint comparison remains.

Preserve original raw-identity collisions, actual retained old producer handles,
two real hosts at one inventory/control address, fresh runtime identities and
persistent model namespaces. Preserve both stale action operations, all stale
counters and current positive twins: down cycle has zero semantic actions;
up has exactly one, matching the same capture through sealed dispatch in the
mutating context with exactly one model/bridge effect. Keep all 13 labels per
route, actual cycles/frame checks, terminal nonreactivation, transcript lifetime,
end-retained-observations call, destruction inventory and backing-last order.

## Corpus root and physical accounting

Keep the original root loops, namespace owners, issuance order, static/dynamic
IDs, catch behavior, selected slots, every fault/prefix/capacity/surplus case and
check count. Move only each large loop **body** into a concrete noninlined case
helper. Embedded helpers cover exchange/surplus, invalid extent and acquisition
fault (the latter serves both whole-object and every byte-prefix fault). They
accept already-issued owned identities, the same selected backing and small case
arguments; they construct and destroy the original outer/owner/transcript inside
that call and return `Int`. Native reservation bodies may be factored the same
way where they currently materialize owners in the root. Do not split required
coverage into another executable or reset namespaces between cases.

No slot, physical ID, bank/geometry object, Optional padding wrapper, layout
traversal, allocator, C reservation or audit extent changes. Four 32,000-byte
slots retain their full 128,000-byte charge; target facts remain cursor 31,993 /
alignment 8 only if the fresh extraction confirms them. New report/helper frames,
consumed argument/result storage, original full snapshots, metadata, alignment,
destructors and compiler writes all count. Noninline boundaries are selective at
these concrete phase/case/observation operations, not mechanical annotations of
unchanged functions. They prevent one operation body from absorbing all cases;
they do **not** guarantee smaller frames, elision or tail calls. Add actual live
caller frames, including any consumed-value homes that survive the call, to the
callee frame. No budget-only remedy is selected: the previous 114,464-byte path
also exceeds the old image's zero-margin 64,512-byte main-stack room.

## Bounded source package and validation

The candidate changes one Swift file,
`Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterScopedStorage.swift`.
Candidate A's direct runtime-field observations and selective state-operation
boundaries in the other four Swift files remain unchanged. Supporting edits are
the counter driver's exact applicability pin, a new immutable qualification and
freeze/manifest, this note and the activity's counts. No public API, accepted
ADR/Spec clause, flag, compiler or workload changes. Removing or changing the
required `CounterHostState` representation is outside this candidate.

Before source review, pin every changed file, exact source diff and label
inventory. Recompute the seven component-receipt qualifications against their
actual compiler argv, source exclusions, receipts/artifacts and metadata hashes;
keep their old qualifications immutable. Only metadata-only excluded changes
qualify. No changed compiled counter input or old runtime log is reusable. Run
the proportionate compiler-free collection/identity tests and normal formatting
requirements; ContractFixtures are excluded by the existing formatter. Design
review precedes implementation; independent source review precedes this one
initial target screen:

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter \
  --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded \
  --host-build .build/contracts/p08-scoped-host-hzs5q7za \
  --fresh-focused --select-family so07-layout-facts
```

Use the emitted receipt/object paths, actual section identities and relocations.
Inspect the entry, phase/case constructors, cleanup, reuse groups and required
live caller chains immediately. A reachable frame/path lower bound over 27,648
rejects fit before expensive validation. Such a screen is partial: 202 compiler
controls are not run and no complete image/stack proof follows from module or
layout success. An unsupported compile/lifetime realization is also a failure,
to be diagnosed and grouped within the new activity's finite correction budget.

If promising, collect current native Static/Dynamic runtime, all 26 reuse labels,
five native exclusivity controls and complete affected host-backing,
use-after-consume, owned-return, carrier/union, erasure/closure, Task/async and
overlap families with positive twins. Exercise both Static and Dynamic phases;
ARMv6 and Embedded need their current compiler cases because this file is compiled
there too. Focused receipts remain partial. The image handoff still requires a
complete successful current collection: obtain all 202 Embedded controls before
the registered image, then verify actual linked feasible construction/body/helper/
retirement paths, caller/IRQ costs, ABI, allocator reachability, full RAM/flash
and map charges. No accepting a partial receipt as that prerequisite.

Open implementation questions are compiler-supported consumption/lifetime
realization and measured total stack, not ownership authority. If required host
state materialization still prevents fit, report exact new evidence and a
separate decision; do not silently alter the required enum. P08/R07/T8.1/
HC-RD-003 stay open pending full current acceptance and independent exit review.
I4-07/analyzer, P09–P12, hardware and timing remain separate.
