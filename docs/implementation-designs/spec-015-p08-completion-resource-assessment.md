---
spec: SPEC-015
feature: giftui-mvp-architecture
title: Implementation Design — P08 completion and resource assessment
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

# P08 completion and resource assessment

The [rebuilt counter resource result](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-firmware-final-fit-result.md) now reports actual
new-ELF resource PASS: main95,469/106,496, ISR6,672/8,192, RAM255,612/262,144.
Fresh address rebasing and corrected executable proof pass; independent
current-image review and remaining four-route/SO/P08 exit reconciliation are next.
Historical prerequisite/decision text below is retained as history.

[ADR-040](../adrs/adr-040-counter-physical-sram-budget.md) now records the
[explicit human counter resource acceptance](../iterations/iteration-003-review/p08-counter-resource-acceptance.md).
Independent corrected proof review passes; counter-only configuration and new
normal image/proof qualification are next, with P08 exit still open.

The maintainer now authorizes larger main **and total RAM within physical
262,144 bytes**. The [independent complete-bound review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-firmware-complete-bound-independent-review.md)
passes after a separate decoder correction; authority reconciliation and fresh
normal guarded-image/address-proof qualification remain required.
The [complete frozen-firmware resource proposal](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-firmware-complete-bound-result.md)
submits conservative main/ISR bounds 95,469 / 6,672 and counter-only payloads
106,496 / 8,192, projecting RAM 255,612. Narrow authority reconciliation and
the final normal guarded image must precede acceptance of the rebuilt image.
The earlier live rejection remains valid against the historical 196,608 ceiling.
Prepared-lending implementation is not selected; source repair allowances remain
closed. Historical next-step text below predates this authorized resource direction.

The [actual current firmware result](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-firmware-resource-result.md)
now closes that measurement prerequisite: full nRF 227/227 and normal pristine
image/ABI/layout/RAM/flash pass, but an actual linked cold subset 28,560 exceeds
main 27,648 before omitted costs. P08 remains open; next is a concrete compatible
internal design review, with no renewed source allowance or resource amendment.

Historical measurement prerequisite, now fulfilled: the [frozen-artifact worksheet](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-resource-worksheet.md)
identifies a material applicability gap: normal firmware recompiles all 24 owners
with differing flags and active raster/text branches. The frozen contract-object
failure does not prove final firmware fit/failure. Its concrete next step is a
narrow image-handoff registry fix, full current nRF collection and the normal
guarded image build at unchanged limits, before source optimization or a numerical
stack amendment. This refines the measurement protocol below; no scratch-link or
partial-receipt bypass is proposed.

This derived assessment selects no new source variant or resource limit. SPEC-015
remains **implementing**, its plan active and P08/R07/T8.1 open. The applicable
work is ITERATION-003 I3-04/I3-05 runtime-derived counter and four-configuration
validation, preserving ITERATION-001's reference-application/stack requirements.
Full RFC-015 delivery remains ITERATION-004 I4-07. Existing repair allowances,
including the latest correction 2/2, remain closed.

## Frozen result and remaining completion gates

At source `51cfc960` / SOURCE review `ee10d2f1`, the
[final result](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-constructor-caller-final-result.md)
and [independent exit review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-constructor-caller-final-independent-review.md)
establish three focused passes: Native Dynamic/Static total 3,472,564 assertions,
zero failures; nRF 25 checks and 160 strict layout roots. Native omits 384 checks
per profile; nRF omits 202. These are incomplete collections. There is no fresh
complete four-route matrix or linked-image qualification of this source.

Current nRF backing is 4 × 34,720 = **138,880** bytes. Metadata occupies 16,584
bytes of one donor slot. The necessary cold stack subset is **28,288 > 27,648**;
later original bank callbacks, enclosing corpus/custody/dispatch, deeper factory
callees, alignment and feasible IRQ costs remain additional. The 640-byte excess
is not the complete gap. The live 22,856 subset is not an upper bound. Neither
complete peak nor current whole-image RAM failure is proved: backing plus the
cold subset alone is 167,168, below 196,608, before other required costs.

| Gate | Required disposition before P08 exit |
| --- | --- |
| SO-01–06 / adopted IN-SO, RP-SO, HC-SO subcases | Reconcile current callers, exact physical inventory, owned compatibility and complete lifetime chain; preserve every applicable capacity, initialization-prefix, early-return, activation/candidate failure, quiescence, reuse and independent action/semantic/pixel control. Focused results qualify only their named source and cases. |
| SO-07 / four registered counter routes | Current-source macOS Dynamic/Static, Pi ARMv6 Dynamic and nRF Embedded Static boundary evidence, with positive twins and classified negative/exclusivity causes. Refresh changed dependencies and account for every omission under the existing focused-campaign rules. |
| SO-08 / R07 | Current early Pi/nRF linked artifacts, ABI, rooted allocator evidence, complete feasible construction/live/action/failure/cleanup stack and IRQ accounting, retained RAM/flash, Static zero heap and matched Dynamic allocation costs. The existing main-stack rejection must be replaced by passing evidence. |
| SO-09 | Independent P08 exit review of the applicable evidence and an exact source-specific I4-07 residual handoff. All nine SO criteria remain open as full criteria; partial P08 coverage cannot close full RFC delivery. |

The [fixed P01–P12 plan](../iterations/iteration-003-review/rfc-014-implementation-plan.md#ordered-work-packages)
keeps analyzer migration and its actual legacy factory/owned-return gaps in P09,
integrated owner/functional conformance and the full hardware-free gate in P10,
complete two-application resources/workload and authorized connected evidence in
P11, and production removal/cutover/conformance transitions in P12. The
[approved allocation](../iterations/iteration-003-review/rfc-015-delivery-allocation.md)
assigns full RFC-015 reconciliation to I4-07, coordinated with P09–P12. It permits
no deferral of an adopted counter safety or fit gate. Existing hardware and unmet
timing dispositions remain separate; cross-builds establish no connected result.

## What is required, and what is the current fixture realization?

Authority is accepted ADR-035/036/038/039 and implementing SPEC-011/013/015.
The relevant distinctions are:

| Cost or constraint | Authority and consequence |
| --- | --- |
| Actual declaration traversal, full exact owned keys, distinct semantic/Interaction banks, model tickets/pins, one physical owner/session, original typed loans, mandatory host state cases and retirement | ADR-035/036/039; SPEC-013 S13.1 and SPEC-015 S15.1. These are essential semantic/lifetime costs. Pointer erasure, a second state machine, hashes/prefixes, omitted input dependencies, or a tag replacing the mandated host payloads require upstream change. |
| Actual endpoint, application/control, scheduling, capabilities, backend payload and transport | Required by SPEC-015 construction/activation and ledger, with downstream owner contracts. Private counter placement is replaceable, but a recording-only substitute cannot qualify the supported endpoint and actual host. |
| Full recordings, retained baseline/fingerprint, foreign root/control, fault inventories, transcripts and custody | Fixture/oracle machinery, visible in `CounterScopedStorage.swift` and `CounterPipelineOwner.swift`. Independent comparisons and adversarial behavior remain required by HC-SO-002/HC-RD-003 and RP-SO-001/002. Their present wrappers, simultaneous scratch and physical placement are not mandated core layouts. Every byte still counts while linked/live; removing an observation or weakening a comparison is not a layout optimization. |
| Complete finite counter corpus on four configurations | SPEC-015 “Owners, resource ledger and migration”, HC-SO-001–003; plan P08/SO-06–08. Four routes mean four configurations, not four simultaneously live counter profiles. No clause inspected requires all independent test cases to remain simultaneously initialized. Required foreign objects, two-bank states and old owned observations must still coexist at their actual adversarial operation. |
| Four 34,720-byte backing slots | Current `counter_main.c`, `StaticCounterEmbeddedBacking.swift` and `P08EmbeddedCasePlan.ranges`, not a fixed Spec cardinality or permanent slot-size promise. The current design/package deliberately preserves all four; it cannot be silently changed under its exhausted allowance. A new reviewed internal layout may change reservation organization while preserving all capacities, addresses/lifetimes needed by each case and caller validation. |

Source-grounded co-residency: `p08RunEmbeddedCorpus` runs graph, scoped cases and
hosts sequentially through one `P08CallerCustody`. Each `run` validates disjoint
active/donor ranges, completes logical work, destroys metadata and ends descriptors
before returning ranges to idle. Ordinary selections reserve one active slot plus
one donor; unequal exchange reserves two contiguous active slots plus one donor.
Host cases rotate active slots 0/1/2/3. `p08RunMetadataTwoHosts` reconstructs the
same original owner/control sequentially, retaining owned observations across the
two hosts; it does not require two live host instances. Foreign root/control are
separate live objects inside donor metadata. This supports investigating a compact
reservation map; it does not prove that three slots, one smaller arena, or any
particular byte total preserves the full corpus.

Splitting independent cases into non-overlapping phases can fit the contract.
Dropping on-target cases, suppressing oracle fields, replacing supported-endpoint
cost with recording-only cost, or treating a test-only image as the complete host
would change the evidence obligation. Any multi-image proposal must map every
required case and still prove the actual complete composition and all co-resident
adversarial paths; this assessment does not establish such a proposal.

## Which resource decision is actually open?

**196,608 bytes is the normative 192 KiB linked-RAM ceiling** in
[SPEC-004 Performance Requirements](../specs/spec-004-capability-contribution-and-resolution.md#performance-requirements),
inherited by SPEC-015's complete ledger. It is not the nRF device's entire physical
RAM. Use final RAM-mapped PT_LOAD sizes, including reserved stacks, rather than
adding stack high-water to a linked total that already reserves that stack.

**27,648 began as `CONFIG_MAIN_STACK_SIZE` in the firmware `prj.conf`.** It is now
explicitly preserved in approved SPEC-015 HC-SO-003, SO-08 and the RFC-015 delivery
allocation. ADR-039 selects no resource exception and rejects relaxed stack limits.
Therefore a larger stack is not an authorized local configuration edit even if
the total remains below 192 KiB. Conversely, this does not establish an immutable
hardware stack limit: [ITERATION-003's validation rule](../iterations/iteration-003-dev-ux-improvement.md#required-configuration-matrix)
explicitly allows consideration of a larger stack only with a complete bound
within the total RAM budget, not a lower bound or observed high-water mark.

A concrete repartition proposal needs explicit maintainer resolution of that
preserved limit and reviewed affected Spec amendments; resolve any change to
ADR-039's excluded larger-limit alternative through its RFC/ADR gate before
relying on it. A total-RAM increase, changed ownership, reduced corpus or relaxed
lifetimes is a separate upstream decision. No such change is justified merely
by the current 640-byte rejecting subset.

## Ranked next path and smallest prerequisite evidence

1. **Complete a decision-sized resource worksheet from the frozen artifacts.**
   First extend the current object's exact section/relocation call graph through
   the omitted original loan callbacks, entry/custody frames and factory callees;
   enumerate finite indirect targets and SP realignment. Cover cold construction,
   live/current/stale action, refusal/failure and cleanup maxima separately, adding
   only source-feasible nesting. Reconcile active/donor metadata and each required
   foreign/baseline object's lifetime. This read-only work can proceed without a
   contract change. Stop with exact unresolved edges if existing objects are
   insufficient; do not fabricate a finite upper bound.
2. **Prefer a compatible fixture-layout design if that worksheet identifies a
   concrete saving on the failing path.** Map each existing case to its simultaneous
   typed regions; preserve unequal supplied extents, same-address reconstruction,
   foreign origins, first errors, complete observations and prefix unwind. Compact
   backing alone saves retained RAM, not the currently failing main stack. A new
   source candidate needs a reviewed mechanism that also addresses the measured
   constructor/destination homes or a separately approved stack repartition. Do
   not repeat helper/annotation experiments with no physical cause.
3. **If repartition is the credible remedy, prepare the exact resource proposal
   before seeking its decision.** Existing recorded artifacts lack a current
   complete linked RAM/flash/IRQ ledger; historical images cannot supply it by
   adding a backing delta. Inventory compatible current objects and build inputs.
   If necessary, propose one diagnostic-only link under an explicitly named
   scratch configuration sufficient to retain the current graph, with no source
   variant, execution, flashing, acceptance claim or guessed accepted stack size.
   Record all non-counter sections, Zephyr/main/IRQ reservations and feasible
   exception nesting, ABI and rooted allocator reachability. Any changed link
   layout/codegen must be reconciled with its own stack graph. The worksheet must
   show a conservative complete bound and exact total within 192 KiB before a
   larger-stack approval request is meaningful.

The smallest next deliverable is that worksheet plus unresolved artifact/edge
list and one evidence-backed recommendation, not a full-suite rerun or source
repair allowance. Current objects can establish more call-path evidence, but the
existing selected proof packet and stale linked images cannot establish a safe
whole-current-image upper bound. If it cannot be completed from existing
artifacts, record the precise diagnostic measurement needed. A human decision
is required only when the resulting proposal changes the bound/contract/scope;
internal investigation and compatible design do not manufacture an approval gate.

After a compatible source freeze or an approved resource amendment, qualify only
that exact realization: focused object/layout screen, necessary full boundary
coverage, both early linked artifacts and resource proof, then independent P08
exit. Preserve all current passing evidence and explicit 384/202 omissions. This
assessment ran no compiler, runtime, image build or hardware operation and creates
no new tuning allowance. FW-007 and FW-038 already preserve configuration reporting
and broader validation consolidation; neither is a P08 resource waiver.
