# SO-04→06 repeated full-host design handoff — 2026-10-14

**Derived design prepared; independent design review next; source allowance zero.**
Input source remains `369906abf54f6341b0f0287e09d3dfeec28ab005`; corrective
[independent review](so04-06-corrective-independent-review.md) is recorded in
`5ba87bd0`. Findings 1–4 remain source-corrected/unexecuted; finding 5 remains
open. This is a docs-only Sol 6.1 High implementation-designer pass without
subagents. The selected direction and exact authority analysis are in the
[physical design addendum](../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md#repeated-full-hosts--derived-addendum-2026-10-14).

## Authority and precise claim

Accepted ADR-039 and approved S11/S13/S15 remain governing. SPEC-013 S13.1
permits physical inventory reuse after every old user/callback ends; SPEC-015
terminal lifecycle requires fresh complete logical hosts. SPEC-009:339–352
allocates raw zero first in each assembled runtime namespace;
SPEC-009:1144–1165 does the same for per-source submitted sequences and requires
reassembly on exhaustion. SPEC-010:619–626 makes registration generation
unique for that assembled runtime lifetime, starting at zero. The existing
noncopyable model-owner namespace survives reassembly. No universal continuing
cursor or old-root/model reactivation is implied.

Select a fixture-private check of **original producer origin**, derived from
the existing physical owner's identity/checked serial. Keep all raw focused
types, allocator starts/exhaustion, semantic paths, target generations and
bridge semantics exact. Closed host callers receive owned observations, not
an exported old pipeline/root/target dispatch capability. Old captures/input
retained for adversarial testing keep their original delivery provenance.

This does not promise rejection of a naked old value deliberately relabeled
as fresh work through a newly minted producer: numerically identical values
in different runtime-local namespaces cannot be distinguished by the focused
raw representation. The raw bridge remains a one-runtime caller boundary.
The design review must verify that every actual finite ingress retains its
original provenance or ends before reconstruction. A missing route is a source
design blocker, not a reason to weaken tests. If an approved clause requires
cross-runtime rejection at the naked raw API, cite it and stop upstream:
either clarify the permitted caller boundary through Spec review, or review
an explicit namespace/API change through RFC/ADR/Spec. Neither option is chosen
or authorized by this handoff.

## Exact proposed source whitelist

All paths below are relative to the repository root. No other source is proposed.

| Source | Required seam; why the previous two files alone do not suffice |
| --- | --- |
| `Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterScopedStorage.swift` | Separate once-per-physical reservation/inventory from once-per-host outer construction; reconstruct fresh adapters/control only after old destruction, propagate existing owner/serial facts to trusted selected setup, install cleanup, and add actual two-host reuse/collision/stale-producer/current-producer corpus. Keep original physical addresses and final destruction. |
| `Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift` | Add the private selected-origin state and narrow setup/check/retirement operations to `CounterControl`, which is declared here. Record immutable origin with any intentionally retained test capture; no new transaction state, raw dispatch API or focused generation change. This same-address guard cannot live only in the physical owner's file because actual admission reads this control in another file. |
| `Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterAdmission.swift` | Snapshot producer origin and an owned rejection context at adapter creation; check before current controller access in every submit. Existing `.unavailable` outcome uses the snapshot on mismatch, emits no wake and performs no current cancellation. Preserve ordinary owned probe behavior explicitly; an old selected adapter may never fall back when current origin is absent. This is the actual copyable raw-pointer adapter, so a test-only wrapper in CounterScopedStorage is insufficient. |
| `Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterApplication.swift` | Snapshot selected origin at actual application/producer construction and reject stale source/repository delivery before reading current control or minting a current borrowing admission adapter. Preserve existing source stop, observation detach and nonescaping callback drain. Without this seam a retained old application value could manufacture fresh ingress from the reused pointer. |
| `scripts/contracts/check-spec-015-counter.py` | Register the finite corpus labels/route applicability and exact unchanged driver invocation; preserve all existing compiler labels, positive/negative order, five Native exclusivity controls and independent semantic/action/pixel oracles. This pass edits source registration only; it never runs the driver. |

No `Sources/` API, root adapter/scope, coordinator, graph, firmware/C constant,
toolchain, build/route recipe or resource limit change is proposed. In particular,
the historical three-file terminal-owner restart patch is not selected. Any
unavoidable additional seam stops this pass and is independently documented;
it does not auto-expand the whitelist.

## Ordered implementation and freeze proposal

This is **proposed only**, subject first to independent Strong design review
and then explicit maintainer authorization of this exact source boundary.

1. Read the frozen source and design review. Inventory all CounterAdmission
   constructors/submits, application callbacks, normalized-input paths and
   capture creation/dispatch sites. Record source dispositions for each; no
   producer can replace its original origin from a pointer alone. Explain
   every ordinary owned compatibility path separately.
2. Add narrow private control-origin state, adapter/application snapshots and
   zero-effect rejection. Session origin comes from the actual common-token
   construction, with checked existing serial; no public constructor, global
   stamp namespace or capability getter. Retire selected ingress before old
   logical destruction and clear it after callback drain. Add all retained
   facts/temporaries to the symbolic ledger.
3. Refactor only the closed selected outer helpers: initialize physical G/C/R/H
   once, then construct/validate/run/consume-retire/destroy logical host 1;
   verify empty/idle/address inventory; construct complete logical host 2 on
   the same reservations with newly issued model/semantic owners. Never overwrite
   a live root/control, reactivate a retired instance or reset the physical serial.
4. Add the corpus below to both actual preset chains. Preserve every earlier
   early-return/activation/candidate/refusal/commit case. Tests deliberately
   observe raw collisions; they cannot pass by changing paths, generations,
   source IDs, model-owner comparisons or avoiding the same control address.
5. Update exact source-only label/route ledger and receipt, perform only
   whitespace/governance/Markdown-link and source-inventory checks, freeze and
   commit. Then conduct an independent Sol 6.1 High Strong **SOURCE** review.
   A failure stops; further source repairs are zero until separately authorized.

Allowance shape: **one source-only pass over these five files, one freeze/commit,
independent Strong SOURCE review, zero automatic follow-up repairs**. Compiler,
formatter, build, harness/executable, IR/debugger, linked-image, target and
hardware allowances are zero. Later execution needs its own exact reviewed
proposal and authorization; source-review success does not grant it.

## Exact planned evidence labels

Prefix is `so06-reuse-{route}-`; route order is `static`, then `dynamic`.
Static applies to macOS Static and nRF Embedded; Dynamic to macOS Dynamic and
Pi Dynamic. Do not present Embedded registration as execution. These are
**planned labels**, not current source registrations or invocation receipts.

| Suffix | Exact planned oracle |
| --- | --- |
| `inventory-two-hosts` | Two actual complete activated preset hosts, one physical initialization; original G/C/R/H IDs/addresses/extents unchanged, all roles empty/original between hosts, final original reverse destruction once. |
| `control-same-address` | Old control destroyed only after old scoped users/callbacks end; fresh control at identical address, empty admissions, initial input/wake/scheduler before activation and fresh active binding afterward. |
| `terminal-old-host` | Old host activation/opportunity rejects in terminal state before scoped consumption; existing carrier escape negatives prevent cross-session use. |
| `raw-namespace-collision` | Same semantic action/target paths and intentionally repeated raw action/target/presentation/initial source-sequence values observed from actual two runtimes; distinct newly issued model/semantic owners are recorded, never used as the rejection oracle. |
| `action-stale` / `action-current` | Original-origin actual captured action rejected before dispatch; current-origin twin enters the unchanged bridge with actual identity/action-generation/enabled/target checks and expected semantic/pixel result. |
| `input-stale` / `input-current` | Original actual source/revision/sequence/ordinal event through its retained old adapter rejects; fresh twin follows gate/admission/seal/gesture algorithm. Stale rejection has no effect on new pointer/capture state. |
| `admission-stale` / `admission-current` | Actual copied old CounterAdmission against same current pointee refuses all three submission categories before synchronization; current twin uses the actual controller and wake path. |
| `source-stale` / `source-current` | Actual retained old application/source/repository delivery cannot mint current admission; fresh application starts once and delivers through existing callback, observations and wake controls. |
| `cleanup-backing-last` | Stop/detach/cancel/quiesce/retire/release/reset/invalidate precede old destruction and second acquisition; complete users end before final physical release. |

Thirteen runtime corpus labels per route, 26 logical labels total; no new
compiler label is proposed. Existing scoped compiler totals remain 384 per
non-Embedded profile / 202 Embedded, with five separate Native exclusivity
labels. Source registration can report a named label only if its actual
matching oracle exists. A stale/current pair fingerprints queues, pointer
state, wake deadline/counts, context, model and dispatch count before/after;
stale is zero effects, current proves the check is not blanket unavailability.
Within-runtime stale-generation/cancellation tests remain independent.

## Status, resource duties and checks

Physical reconstruction temporaries, origin/control/admission/application
facts and retained stale observations join the existing symbolic 26-family
ledger; native/Embedded padding and Dynamic allocation peaks remain separately
measured duties. The historic 58,648-byte frame versus 27,648 limit remains
a failed historical measurement. No resource pass or numerical replacement is
claimed.

The previously authorized correction remains **1/1 consumed**, zero automatic
repairs. Initial freezes (`fd879ad0`, `825603a2`, `0bb4d9ca`), corrective source
`369906ab`, every immutable receipt/counter and cumulative stop guard remain.
No new source authorization exists. IN/RP/HC-SO-001–003, fit/P08/R07/T8.1,
HC-RD-003, SO-07–09, I4-07/P09–P12 remain open. Specs remain implementing;
plans active. ITERATION-003 I3-04/05 and closed ITERATION-001 regression duties
remain the necessity; full RFC-015 delivery remains ITERATION-004 I4-07.
Finding 5 is required current correctness, so it cannot be deferred to FW-037
or an Exploration. No new out-of-scope idea is introduced.

This handoff's permitted checks and docs commit are reported with the current
navigation receipt; they provide documentation consistency only. Independent
design review still must validate every ingress disposition, the five-file
minimum and the exact claim boundary before any source allowance is requested.
