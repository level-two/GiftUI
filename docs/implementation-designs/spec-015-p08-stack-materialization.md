---
spec: SPEC-015
feature: giftui-mvp-architecture
title: Implementation Design — P08 Stack Materialization
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

# Implementation Design — P08 Stack Materialization

This derived note proposes a private compiler realization, not a new resource
limit or ownership contract. It answers the maintainer's question about a roughly
30 KB stack under the [authorized diagnosis/design activity](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-resource-design-activity.md).
**Recommendation: reduce demonstrated carrier/getter materialization first.
A 30 KiB budget cannot repair the current image.** [Independent Strong design review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-resource-design-independent-review.md)
passed at `a90841e0`. The [candidate A source activity](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-stack-candidate-a-activity.md)
now freezes its [concrete realization](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-stack-candidate-a-source-freeze.md)
for independent source review before one target screen. No compiler experiment,
budget change or automatic repair variant has run/been granted.

## Authority and exact evidence

[SPEC-015 S15](../specs/spec-015-host-configuration.md#s152-additional-acceptance-criteria),
[accepted ADR-039](../adrs/adr-039-scoped-storage-ownership.md) and P08/SO-08 require
the complete supplied→pipeline→coordinator→host→retirement lifetime chain,
backing-last cleanup, zero-heap Static execution and measured feasible nested
stack under unchanged limits. The [current ownership design](spec-015-p08-scoped-storage-ownership.md)
remains the realization baseline. SPEC-011/013/015 are implementing, plans active;
ITERATION-003 I3-04/I3-05 supplies the current finite-counter need and retains the
closed MVP's analyzer/stack regression obligations. I4-07/analyzer, P09–P12,
hardware and timing are outside this diagnosis.

The [previous image packet](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-remaining-images-resource-result.md)
and [independent exit review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-remaining-independent-exit-review.md)
remain immutable. Current linked nRF ELF SHA-256 is
`66ca1113d997c6424aedb258c1477692ce4bf5b42ed77f42bb1d5cba66339da9`, source
`0d3e3c7d`, exact compiler hash `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`.
The [new artifact index](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/resource-design/README.md)
pins bounded function bodies, exact symbol/demangler attribution, copy windows,
DWARF availability and arithmetic. Only existing artifacts were inspected.

## What the current image actually requires

| Actual function | Address | Local SP subtractions | Saves | Frame lower bound |
| --- | --- | ---: | ---: | ---: |
| `counterExerciseScopedStorage` | `0x214f4` | 30,060 | 36 | 30,096 |
| `runP08ScopedBody` | `0x1eca4` | 71,772 | 36 | 71,808 |
| `P08BodyCleanup.constructOwner` | `0x1cc30` | 37,732 | 36 | 37,768 |
| `P08BodyCleanup.constructHost` | `0x1d2c0` | 42,904 | 24 | 42,928 |
| `P08BodyCleanup.run` | `0x1d45c` | 38,636 | 36 | 38,672 |
| `p08RunReuseHost` | `0x1a8fc` | 102,604 | 36 | 102,640 |
| `P08BodyCleanup.finish` | `0x1e4bc` | 31,516 | 36 | 31,552 |
| `counterWakeControls` specialization | `0x22e24` | 36,204 | 36 | 36,240 |

These are actual entry prologues, not guessed type sizes or upper bounds.
The required repeated-host path has **71,808 + 38,672 + 102,640 = 213,120 bytes**
simultaneously live, before outer caller, nested runtime, alignment or IRQ costs:

- `p08CounterHost` creates a live transcript and passes its nonnull address to
  `runP08StaticHost` twice inside the same selected owner reservation. Both calls
  use `failAfterRuntime: false`; `early` defaults to 0 and `candidateFailure` to nil.
  The second host must collide in raw namespaces/control address while rejecting
  the original producer's action/input/admission/source, so this is required coverage.
- `runP08StaticHost` forwards that same address through the nested model/root,
  semantic, Canvas and `withP08Storage` callbacks to `runP08ScopedBody`.
- The body executes supply, owner construction, join checks and host construction;
  it calls `P08BodyCleanup.run` with `BL` at `0x1f1b0`. The allocated body frame
  remains live and invokes `finish` after this call returns.
- `run` selects `if let reuse`; actual `cbz r7` at `0x1d4f6` skips the reuse branch
  only for null. `BL` at `0x1d502` calls `p08RunReuseHost`. It then reinserts the
  consumed host into the stage, so its frame also remains live. Neither edge is
  tail-call elimination. This is a feasible source workload path, not observed
  target execution (the configured stack is already insufficient).

Do not add mutually exclusive construction/retirement frames to this sum.
Separate witnessed subpaths are body→constructOwner ≥109,576,
body→constructHost ≥114,736 and body→finish ≥103,360. Wake controls have their own
large frame; no complete wake call-path total is asserted here.

## Attribution: retained backing does not eliminate carrier temporaries

The four 32,000-byte C slots correctly retain 128,000 bytes of original physical
objects in BSS. Their regions include model/root, semantic banks, geometry, five
Interaction banks and a 4,200-byte `CounterControl`; the actual target layout
report remains unchanged. Access/session/host/coordinator carriers and fixture
observations are separate values on live call frames. A final-region physical
owner does not force compiler construction/move/pattern-match temporaries into BSS.
Nothing proves that 128,000 bytes were copied onto the stack.

Concrete linked-code contributors are:

1. **Whole control materialization before a computed read.** In wake controls,
   `0x2357e` loads copy length 4,200, `0x23592` calls memcpy into a stack temporary,
   then `0x2359c` calls the exact `CounterControl.admission.getter`. This precedes
   admission-count checking. There are six explicit immediate-length 4,200-byte
   copy sites in that function. Source `admission` simply forwards to
   `runtime.admission`, with an existing `_modify` for mutation. Reading the
   original nested field/facts can avoid requesting the wrapper getter temporary.
   `counterCheckHostFrame` already takes **borrowing** control; changing its
   argument convention is not a diagnosed fix.
2. **Repeated state-union payload transfers.** Wake controls contain 138 explicit
   3,889-byte memcpy sites. At `0x2459a`/`0x245bc`, exact outlined tag helpers name
   `CounterHostState`; `0x245b6` copies 3,889 bytes and the associated outlined
   projection/destroy names the active coordinator/ticket/span tuple. The source
   consumes and reinserts this state during opportunities and other operations.
   Inlining repeated operations into the long corpus function exposes many
   carrier temporaries in one enclosing frame.
3. **Fixture cleanup-stage transfers.** `P08BodyCleanup` holds `P08BodyStage?`,
   whose cases contain a session, supplied carrier, retired carrier, owner or host.
   Methods `stage.take()` the value, consume/switch it, and reinsert the next case.
   The body holds this cleanup state through construction, execution and deferred
   finish. The linked code has explicit 4,439-byte owner transfers, 4,808-byte
   stage transfers and their tag/project helpers. Its large frames coexist;
   sequential source statements do not imply reused machine stack slots.

These byte transfers can lower lawful ownership moves or borrowed projections;
they are **not proof of semantic Copyable conformance or duplicate authority**.
The copy-site count is static code count, not simultaneously live byte count or
number of dynamic executions. No exact per-variable frame partition is claimed.
Swift commands lack debug flags; the current DWARF dump contains ANSI C99 and
assembler units, zero Swift-named DIE lines. Existing DWARF therefore cannot
locate individual Swift variables/types. The prologues and exact helper symbols
prove the materialization classes; precise liveness effects of a replacement
need one focused target compilation.

## Proposed private implementation candidate (A)

Retain every state case, lifetime annotation, consuming transition and physical
owner. Do not add an owner, heap box, global unsafe lifecycle, erased capability,
Copyable conformance or a new backing region. Keep every workload check/label.
Group the following in one reviewed candidate, without a broad optimization search:

| File | Concrete proposed change and obligation |
| --- | --- |
| `CounterScopedStorage.swift` | Place explicit non-inlining boundaries on the existing `P08BodyCleanup` stage operations and full-snapshot comparison/reuse operations; keep their caller's activation buffer, session lenders and deferred finish live. Use direct `control.pointee.runtime` field reads for existing owned observations instead of copying `CounterControl` through trivial forwarding getters. Keep all fingerprint fields, stale zero-effects, action mutation correlation, prefix cleanup and 13 labels per route. |
| `CounterHostOwner.swift` | Bound the existing state-union operations (`runOpportunity`, activation, quiescence/retirement and selected borrowing observations) with explicit non-inlining where the actual inlined union helpers occur. Preserve exact inert/active/retired cases, ticket/span ownership and all `@_lifetime(self: copy self)` rewrites. No enum-payload mutation through an invented raw projection. |
| `CounterWakeIntegration.swift` | Read the original `runtime.admission`/context/result facts directly at the existing synchronous control pointer sites, retaining the complete no-effect and pacing baseline checks. Keep actual host service calls and clock order. |
| `CounterHostProbe.swift`, `CounterHostCorpus.swift` | Apply the same direct-field observation realization at the existing join/frame checks; preserve complete owned snapshots, independent semantic/action/pixel oracles and borrowed source control. No reduction to a hash or weaker partial fingerprint. |

`@inline(never)` is already used by the production nRF validator to bound
sequential validation frames (historical commit `6d82a31d`). Its use here is a
candidate, **not a guarantee of lower peak stack**: an added callee still overlaps
its live caller. Do not mechanically annotate all code. Source review must select
the transfer/getter boundaries above and the generated target screen must measure
the resulting nesting. Native/Dynamic paths share fixture operations, so their
compiler/lifetime/runtime/exclusivity evidence must be reconsidered too.

True in-place aggregate initialization is not assumed to exist as a Swift
optimization. Current final-region `initialize(to:)` may still materialize its
argument. If that remains a measured blocker after this candidate, separately
attribute the exact initializer and propose a lawful typed construction change;
do not mutate uninitialized aggregate fields or assert copy elision.

## Why a modest increase (B) is insufficient now

27,648 is the current production `prj.conf` reservation, raised from 24,576 in
`6d82a31d` while temporary validation frames were reduced from 10,628 to 56 bytes.
The [connected record](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/nrf52840-connected-attempt.md)
also preserves a failed 27,840-byte trial and later frame-lifetime repairs. The
closed MVP startup/idle observation 19,480/27,648 was not a worst-case proof for
this new workload. Historical candidate assessment tables are not authority to
raise today's adopted baseline; SPEC-015 S15/HC-RD-003 retains unchanged bounds.

Current RAM is 159,744 against 196,608, leaving 36,864 bytes. Exact ELF symbols
reserve main object 27,712 (27,648 usable +64 guard) and ISR object 2,112
(2,048 +64). Zephyr uses 8-byte SP alignment and 64-byte kernel object/guard
alignment here; userspace is disabled, so its power-of-two **user** stack rounding
does not apply. With all other linked bytes frozen, conditional forecasts are:

| Usable main stack | Main object incl. guard | Total RAM | RAM headroom |
| --- | ---: | ---: | ---: |
| 27,648 | 27,712 | 159,744 | 36,864 |
| 30 KiB =30,720 | 30,784 | 162,816 | 33,792 |
| 32 KiB =32,768 | 32,832 | 164,864 | 31,744 |
| 64,512 (theoretical no-margin maximum) | 64,576 | 196,608 | 0 |
| 213,120 (only the proved nested lower bound) | 213,184 | 345,216 | −148,608 |

These are checked arithmetic forecasts, not new image measurements or proposed
limits. Even the standalone 102,640-byte reuse frame exceeds all currently spare
RAM that could be reassigned to stack. Decimal 30,000 bytes would not even cover
the earlier standalone 30,096-byte frame. No budget-only change within the current
application RAM ceiling can repair this source image.

After materialization is reduced, a modest increase could be technically viable
if a complete measured main path plus exception entry/alignment and separate
ISR nesting fits with explicit RAM margin. No such upper bound exists yet, so
this note proposes **no new number**. Preserve FPU/hard-float, MPU guards, ISR
reservation, 1,048,576-byte flash and zero heap. Main/IRQ hardware context,
interrupt wrappers and feasible handler callees remain unclosed; unused linked
RAM or the separate ISR buffer does not prove interrupt safety. New heap boxing
would contradict Static zero heap; Dynamic allocator headers/peak costs remain
separate obligations. Raising a required resource bound would require an explicit
reviewed Specification/baseline decision (C), not this implementation note.

## Bounded next validation package

No compile experiment is necessary to establish the diagnosis or reject 30 KiB.
The next **proposed** experiment is the grouped candidate A, independent Strong
source assessment, then one fresh target module screen before expensive tests:

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter \
  --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded \
  --host-build .build/contracts/p08-scoped-host-hzs5q7za \
  --fresh-focused --select-family so07-layout-facts
```

Use the emitted new build path, never an invented predecessor. This rebuilds
current preparation/runtime module and actual layout facts, marking 202 compiler
controls not run and aggregate coverage incomplete. Read-only ELF/object inspection
must attribute every affected function by section/symbol (ET_REL addresses need
section identity), prologues, direct/indirect edges, same-branch nested transfers,
initialization/body/finish/reuse/wake and raw SP changes. It is an **early rejection
screen**: any retained lower bound above 27,648 stops expensive follow-up; absence
of a found oversized frame is not a complete fit pass. Freeze raw commands/bytes
and compare code/helper metadata/flash as well as source, without changing flags.

The existing image handoff correctly requires a complete passing collection and
rejects fresh-focused receipts. Do not weaken it. If the target screen is promising,
run the existing complete 202-control nRF collection for the changed compiled inputs,
then the existing early image command:

```sh
scripts/nrf52840/build.sh --application signal-analyzer-static --counter-build NEW_COMPLETE_NRF_BUILD
```

The final ELF is the acceptance artifact: repeat exact layout/C/ABI/RAM/flash,
construction/body/retirement/IRQ and allocator analysis; object-only codegen can
differ. No standalone probe, diagnostic guard suppression or partial→full receipt
promotion is introduced. Review any unresolved indirect/IRQ path as unknown.

If that artifact is promising, fresh-focused native Dynamic/Static collections
should select `runtime` (all 26 reuse labels across routes),
`so06-native-exclusivity` (all five controls), `counter-host-backing`,
`counter-dynamic-host-backing`, `so06-use-after-consume`, `so06-owned-return`,
`so06-erasure-closure`, `so06-closure-erasure`, `so06-task`, `so06-async` and
`so06-static-overlap`. Every selected family includes its complete successful
twins. Pi selects those same compiler families without runtime/exclusivity and
retains ARMv6 hard-float identity; it has no target execution claim. These
are focused candidate diagnostics, not a replacement for the whole matrix.
Any change to declarations, lifetime annotations, carrier cases or constraints
widens affected coverage to the complete union/carrier/erasure families and needs
source-review disposition before execution; candidate A forbids those changes.
All four old full receipts stay valid only for their exact old compiled inputs.
Changed compiled source prevents strict predecessor reuse; focused new receipts
stay partial, with omitted coverage explicit. Any later complete P08 acceptance
still needs current required coverage, full resource proof and independent exit.

The independent design review is complete. Parent records the new bounded
source/validation activity under the current user direction before dispatch:
one grouped candidate, independent source review and one fresh nRF screen,
zero automatic repair variants. This is not a reset; previous 2/2 allowances
remain closed. Preserve the baseline and report the measured outcome before any further
candidate, resource amendment or workload decision; no optimization variants are
silently added to make the evidence pass.
