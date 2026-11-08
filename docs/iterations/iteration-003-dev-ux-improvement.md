---
id: ITERATION-003
title: Runtime Memory and Efficiency
status: active
revision: 8
approved_revision: 8
created: 2026-10-04
updated: 2026-11-08
features:
  - external-application-integration
  - giftui-mvp-architecture
  - signal-analyzer
related_future_work:
  - FW-027
  - FW-032
  - FW-035
  - FW-038
approval: "Revision 8: Eugene approved iteration-3 closeout with named P08 S1–S3 gaps unmet and affected iteration-4 reuse blocked on 2026-11-08; docs/iterations/iteration-003-review/p08-unmet-safety-closeout-disposition.md. Revision 7: Eugene approved freezing P08 without PASS and transferring composition-specific certification on 2026-11-08; docs/iterations/iteration-003-review/p08-freeze-and-certification-transfer.md. Revision 6: Eugene approved the analyzer-specific P09–P12 transfer on 2026-11-08; exact instruction and gates: docs/iterations/iteration-003-review/analyzer-delivery-transfer.md. Eugene requested updating governing documents to the presented bounded preparation and architectural reconsideration approach on 2026-10-09. Revision 4 sequencing and criterion transfers remain in force. Evidence: docs/iterations/iteration-003-review/efficiency-sequencing-approval.md."
closure: null
---

# ITERATION-003: Runtime Memory and Efficiency

## Approved restricted-use closeout disposition — 2026-11-08

Revision 8 applies the [S1–S3 closeout disposition](iteration-003-review/p08-unmet-safety-closeout-disposition.md).
The named gaps may remain explicitly unmet at iteration-3 closure. They block
only affected iteration-4 reuse/adoption until resolved or replaced and validated;
unrelated qualified work and normally approved resolution work may proceed.
P08 remains FROZEN / UNMET. P10 validation/criterion dispositions, independent
overall freeze acceptance, retained P11/P12/ME-09 handoff and explicit human closure
remain required. Earlier blanket S1–S3 closure/entry blockers are superseded only
by this exact disposition; other shared defects and contract gates are unchanged.

The current [closeout handoff](iteration-003-review/closeout-2026-11-08/README.md)
records retained P10/P11 evidence, the 180-row criterion dispositions, P12 no-removal,
and the remaining overall-review and human-closure gates. It does not change this
iteration's status or close P08.


## Approved P08 freeze — 2026-11-08

Revision 7 applies the [P08 freeze and certification transfer](iteration-003-review/p08-freeze-and-certification-transfer.md).
P08 is FROZEN / UNMET, not PASS. Iteration 3 retains shared safety blockers,
bounded freeze/handoff reconciliation and applicable framework/counter validation.
Composition-specific counter certification and dependent adoption move to I4-03/04/07
and I4-AC-013. Full P08 PASS is no longer an iteration-4 entry gate; reviewed
classification, human handoff/closure and normal contract gates remain required.
Earlier complete-P08/whole-counter-fit prerequisites below are superseded by this
allocation; no criterion, resource limit or safety requirement is waived.


## Approved delivery allocation — 2026-11-08

Revision 6 applies the [approved analyzer transfer](iteration-003-review/analyzer-delivery-transfer.md).
P08 and framework/counter P10–P12 remain in iteration 3. Analyzer P09 and
analyzer-specific P10–P12 move to iteration 4 with reusable-host adoption.
The transfer map preserves IT-AC-004–010 and every Spec obligation; the original
criterion wording below defines the required results across the two iterations.
Analyzer obligations are transferred and unmet, never implicitly passed.
Earlier sequencing statements are historical where superseded by this allocation.


The [mandatory memory ruleset](#mandatory-memory-ruleset) and
[mandatory batch execution workflow](#mandatory-batch-execution-workflow),
adopted on 2026-10-31, govern remaining implementation and validation. The
[delivery checkpoint](iteration-003-review/complexity-and-efficiency-checkpoint.md)
holds the current technical disposition and execution allowance. Its closed
2026-10-20 preparation steps are history, not a prerequisite to repeat.

Approved revision 5 prioritizes safe runtime graph derivation, memory efficiency
and measured frame/acquisition performance. Backend/platform extraction, focused
packages and the complete external application setup outcome now belong to
[ITERATION-004](iteration-004-backend-and-application-integration.md).
[The approval record](iteration-003-review/efficiency-sequencing-approval.md)
preserves the instruction, criterion transfers and separate lifecycle gates.
[The detailed activity plan](iteration-003-review/memory-efficiency-plan.md)
coordinates ME-01–09; it is not a ready Specification Implementation Plan.
Revision 5 makes ME-01–04 one bounded preparation phase ending in a feasibility
decision. Architectural reconsideration is part of that assessment; no
replacement architecture is selected. Revision 4's delivery outcomes, criterion
transfers, resource constraints and validation obligations remain unchanged.

The revision-5 source assessment ended inconclusive. Eugene then explicitly
authorized [one complete-candidate go/no-go assessment](iteration-003-review/candidate-go-no-go.md),
with fixed gates, one budget and no automatic successor. This is an execution
and disposition update under revision 5; delivery criteria and feature approval
gates are unchanged.

That assessment is terminal **NO-GO**: the retained nRF fill transfers alone
exceed the frame budget. No automatic preparation continuation is open, and no
delivery criterion is marked met. The packet distinguishes this demonstrated
cost failure from unproved runtime safety and records the exact decision boundary.

Eugene subsequently authorized the same packet's
[32 MHz assumption review](iteration-003-review/candidate-go-no-go.md#32-mhz-architectural-reassessment).
That closed review finds no additional unavoidable architectural contradiction
under the assumption; implementation and safety/performance obligations remain.
The historical 4 MHz rejection and unchanged iteration delivery gates still stand.

The completed [I3-T01 implementation task](iteration-003-review/memory-efficiency-plan.md#i3-t01--correct-scheduling-and-reduce-rasterlayout-costs)
groups source scheduling, Embedded raster and layout lookup corrections into
one bounded package with three subtasks and one final disposition. It decomposes
I3-05 within the existing scope; it is not another experiment or completion of
I3-04 runtime derivation. All three corrections and the 74-check hardware-free gate pass; commits,
resources and validation limits are recorded in the
[shared result](iteration-003-review/i3-t01-result.md). Connected performance
and runtime-derived graph obligations remain open.
The subsequent I3-T02 design package delivers [draft RFC-014](../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md)
and a [review/conditional migration sequence](iteration-003-review/i3-t02-design-review.md).
Its ownership, resource and supported-realization blockers remain explicit;
this updates delivery evidence, not the approved scope or architecture.
The plan's [current readiness table](iteration-003-review/memory-efficiency-plan.md#start-here)
and [implementation ownership](iteration-003-review/memory-efficiency-plan.md#implementation-plan-ownership-and-launch-details)
distinguish executable next work from unresolved runtime design, integrated
validation and closure. The [working assumptions](iteration-003-review/memory-efficiency-plan.md#working-assumptions-and-evidence-boundaries)
make the production baseline and conditional 32 MHz reasoning explicit.

The [2026-10-13 RFC-015 allocation](iteration-003-review/rfc-015-delivery-allocation.md)
schedules full scoped-storage delivery in ITERATION-004 revision 4, I4-07. P08
retains only changes necessary for its finite counter dependency path and their
complete safety/fit evidence. This narrows the downstream work package without
changing revision 5's delivery criteria, limits or required validation.

## Goal

Establish a safe, measured runtime-derived framework and finite counter across
macOS Dynamic, macOS Static, Raspberry Pi 1 Dynamic and nRF52840 Embedded Static.
Freeze P08 without PASS; complete retained framework/counter P10–P12 safety,
functional, accounting and handoff work. Transfer composition-specific counter
certification and dependent adoption to iteration 4. Remove obsolete counter/framework graph inputs
only where their adoption gates pass; preserve analyzer baseline dependencies.

Hand off the analyzer-specific migration, runtime graph removal, resource and
sustained-workload certification to iteration 4 for delivery on the reusable
GiftUI-owned host. Record exact residuals and unknowns under the approved transfer.

This is post-MVP work. ITERATION-001 closed with recorded exceptions; the
existing features remain implemented at their previously approved contracts.
Those exceptions do not satisfy this iteration's memory/performance criteria.
External application integration remains at RFC stage under accepted
PROPOSAL-007 and draft RFC-013, with external delivery scheduled in iteration 4.
Independent performance architecture needs its applicable investment and
RFC/ADR/Spec gates; iteration approval does not supply those decisions.

## Mandatory memory ruleset

**Effective 2026-10-31 for remaining I3-04/I3-05 implementation, including
P08–P12.** These rules are mandatory implementation and review checks derived
from the accepted contracts below. They do not select a new storage architecture,
change public contracts or authorize Core-wide migration. Apply them to every
changed ownership/allocation/lifetime path and its affected callers. A batch
cannot be accepted with an unresolved applicable rule violation.

| Rule | Mandatory requirement | Compliance evidence |
| --- | --- | --- |
| MR-01 — Explicit ownership | Identify the physical backing owner, all independent owning claims and the release condition. Keys, identities and borrowed descriptors are nonowning; checking a generation through freed backing is forbidden. | Owner/backing/claim/retirement mapping for the changed paths; retained-owner, stale-key and replacement/refusal controls. |
| MR-02 — Backing-dependent lifetime | Tie scoped access to the actual live backing through the approved noncopyable/nonescapable carriers and lifetime dependencies. Keep unsafe construction in the existing restricted factories; validate initialization, alignment, bounds, provenance and disjointness there. A borrowed pointer descriptor alone is insufficient. | Actual caller/factory/consumer chain; applicable positive twins and classified copy, escape and alias negatives; review every changed unsafe boundary. |
| MR-03 — Exclusive mutation | Use the checked mutation route. Preserve frame-wide mutation exclusion through the last body/Canvas read. Validate phase, identity, capacity and fallible preconditions before writes; compound commits must not replay admitted effects or acquire unaccounted rollback copies. | Mutation/read-phase and failed-preflight controls; behavior and error-order equivalence at the actual consumer. |
| MR-04 — Bounded allocation | Use the profile's approved bounded storage realization with explicit capacity refusal. Static paths must have no heap fallback throughout the required charged lifetime, including setup, first use, refusal and destruction. Native Static model construction uses caller-supplied typed backing; preserve approved Dynamic and Embedded realizations. | Current construction-through-cleanup allocation checks, first-excess/refusal controls, actual backing inventory and required cold/provider evidence. Prewarming or shifting work outside measurement cannot establish compliance. |
| MR-05 — Qualified compilation patterns | Reuse a demonstrated concrete storage/dispatch/lending pattern for equivalent sites. Treat generic instantiation, module/provider boundaries, compiler flags and profile as qualification inputs. Do not assume that a struct, nonescaping closure, `@inlinable`, forced inlining or an allocation annotation alone proves complete-path behavior. | Representative compiler/effect check through the real consumer boundary and an explicit applicability mapping to batch sites; refresh it when a relevant input changes. |
| MR-06 — Structured retirement | Track initialized storage and unwind only its successful prefix. Preserve commit/discard and replacement semantics; quiesce producers/callbacks, retire registrations and claims, destroy initialized values exactly once, then release/reuse backing last. Role swaps must not lose physical destruction ownership. | Fault-at-step, early-return, failed-activation, retained-claim and repeated-session controls plus ordered cleanup observations. |
| MR-07 — Complete physical cost | Count backing, ownership metadata, captures, copies, alignment, temporaries and simultaneous storage. Bound feasible nested main/IRQ stacks and flash/RAM against each application's accepted limits. A smaller handle, zero heap, successful link or high-water sample alone does not establish fit. | Current source-route and physical ledgers, actual linked artifacts, complete stack/ABI/resource checks; separate measured values, conservative bounds and unknowns. |
| MR-08 — Shared semantics | Preserve common algorithms, error precedence, access/report order, actions, semantic results and pixels across approved profiles. Mechanical migration must not introduce a fixture-only alternative state machine or change public ownership/behavior to satisfy a probe. | Independent old/new or reference oracles over actual consumers, including refusal and cleanup; affected cross-profile checks. |

Authority: [ADR-036](../adrs/adr-036-scoped-model-access-and-bounded-ownership.md)
(MR-01–04/06), [ADR-038](../adrs/adr-038-construction-graph-and-operational-contracts.md)
(MR-01/07), [ADR-039](../adrs/adr-039-scoped-storage-ownership.md)
(MR-02/06/08), [ADR-041](../adrs/adr-041-native-static-typed-model-backing.md)
(MR-04/05), [SPEC-013](../specs/spec-013-runtime-profiles.md)
(RP-RD, RP-SO, RP-TB) and [SPEC-015](../specs/spec-015-host-configuration.md)
(HC-RD, HC-SO, HC-TB). Exact contract declarations and acceptance criteria remain
in those documents. An apparent conflict goes to the owning contract review;
this checklist cannot override it.

### Required implementation practices and examples

Workers MUST consult the matching recipes in the
[memory migration practices](iteration-003-review/memory-migration-practices.md)
before choosing a realization. The guide mines the latest 100 commits ending
at `169174c9` and supplies before/after code, existing symbols, scoped results,
failed approaches and required checks. Use an applicable existing pattern;
record and qualify a non-equivalent case in the same batch receipt. This is not
a blanket refactor or permission to copy an unaccepted experiment.

## Mandatory batch execution workflow

Eugene explicitly requested this process update on 2026-10-31: “revisit current
iteration's governing documents and explicitly update them to improve the
process with the proposed changes and approaches”, followed by “also do not
forget about the explicit and mandatory RULESET”. This adopts the execution
policy below under approved revision 5. Delivery scope, IT-AC IDs, architecture,
Specification acceptance criteria and lifecycle status are unchanged; no scope
revision increment is needed for this work-order/evidence-strategy update.

1. **Inventory one coherent batch.** In the existing package receipt, list its
   production/fixture sites, affected consumers/profiles and governing criterion
   IDs. Group sites by ownership/allocation/lifetime mechanism. For each group,
   name the existing factory/carrier pattern and applicable MP recipe IDs,
   map MR-01–08 to evidence or a
   justified not-applicable disposition, and list genuine exceptions. Do not
   start another repository-wide inventory or create a record per helper.
2. **Qualify the pattern before multiplying it.** Reuse applicable existing
   evidence first. Where evidence is missing, run the smallest representative
   real module/consumer chain with positive and relevant negative controls,
   including construction, operation, failure and destruction. Check affected
   ARMv6/Embedded compilation and early resource feasibility when shared ownership,
   storage, dispatch or toolchain inputs change. A host-only pass is insufficient
   for those patterns. Qualification is specific to its types/boundaries/profile;
   a new mechanism or non-equivalent site returns here, not to a blind mass edit.
3. **Migrate matching sites together.** Apply the qualified pattern across the
   whole inventoried group, including callers, fixtures and cleanup. Use
   mechanical transformations where safe. Compile affected modules and run the
   focused rule/behavior checks during the batch; do not run the full matrix or
   require a separate approval/review/receipt for each annotation, helper or file.
   Complete matching edits before expanding validation. Unsafe or contract-changing
   exceptions block their dependent paths, not unrelated conforming groups.
4. **Validate the integrated batch and repair by mechanism.** Once coherent,
   exercise the actual owner-to-consumer-to-retirement chains, independent
   behavior/refusal/cleanup oracles, complete allocation entry and affected
   resource/ABI paths. Collect independent failures in one run where the runner
   can do so safely, group them by cause, and repair related sites together.
   Stop invalid dependent execution. After two unproductive corrections of the
   same mechanism, reassess it internally before another candidate; report a
   genuine contract/scope/resource/authority decision rather than requesting
   routine per-helper permission. Retain required independent package review.
5. **Run complete acceptance at the existing package/iteration boundaries.**
   Representative checks are development feedback, never replacements for
   mandated owner-specific controls. Require the reviewed P08 freeze classification before
   dependent handoff; preserve P10's `scripts/test.sh all-hardware-free`, P11's required connected/target
   evidence and P12 adoption/removal gates. Preserve positive twins, classified
   negative causes, required compiler passes, current-source coverage, strict
   cold/zero-heap proof and per-application resource limits. Format maintained
   Swift with `scripts/format-swift.sh` before the repository gate.
6. **Refresh only invalidated evidence.** For each changed input, identify the
   affected contract, transitive consumer, profile and result. Reuse a result
   only when source/dependency/compiler/flags/profile/artifact identities still
   apply under the existing verifier or reviewed applicability assessment.
   Changes to a shared lifetime pattern invalidate all dependent sites; compiler
   or configuration changes invalidate their affected profile evidence. When
   impact is uncertain, broaden validation. A focused pass is labelled focused;
   complete acceptance requires every mandatory row covered by valid evidence.

### One current record and measured feedback cost

Maintain one current package summary in the
[delivery checkpoint](iteration-003-review/complexity-and-efficiency-checkpoint.md)
and link its existing result receipt from owner plans. The receipt records the
batch inventory/rule mapping, exact commands and input/artifact identities,
what ran/reused/failed/remains open, grouped exceptions and the next concrete
step. Update it per coherent outcome; do not copy status histories into each
plan or create preparation/review/reconciliation packets per microstep.
Preserve historical failures and required raw evidence without new receipt-only
commits for routine intermediate failures. Use existing drivers and result
formats; this policy does not require a new runner, controller or evidence schema.

Record elapsed compile/check/integration/full-gate time, command counts and
avoidable repeated compilation from existing runner outputs in that same receipt.
Compare focused and full timings only for identified workloads/inputs, marking
uncontrolled observations as such. Investigate a costly repeated step before
expanding it; report actual savings or unknowns, never a promised speedup factor.
An unchanged passing package is not rerun or polished without a changed dependency,
unresolved failure or a required scheduled gate.

This policy governs prospective work within existing authorization. It creates
no per-rule/per-file run budgets or review gates, renews no consumed experiment,
and resets no current execution/accounting ceiling. Historical sessions remain
historical; use the checkpoint's latest explicit authorization and remaining
allowance. Required independent reviews and connected-action authorization remain.
The closed preparation steps 1–3 are not reopened. Full application/test/package
consolidation stays in ITERATION-004 via
[FW-038](../future-work/fw-038-scoped-contract-validation-cost.md); it is not a
prerequisite for adopting this workflow now.

## Preparation Baseline

- [ITERATION-002 closeout](iteration-002-cleanup/evidence/23-closeout/result.md)
  supplies the selected cleanup baseline; do not reopen unrelated cleanup.
- [Pi phase evidence](iteration-002-review/30-pi-aggregate-phase-comparison.md)
  and [nRF phase evidence](iteration-002-review/26-connected-nrf-phases-and-failure.md)
  identify production/projection and layout/production costs respectively.
- [Consolidated preparation findings](iteration-003-review/preparation-findings.md)
  preserve the useful runtime/copy/link evidence and unresolved safety gates.
  Original attempts and budgets remain in the
  [preparation archive](iteration-003-review/preparation-archive.md); cleanup
  neither restarts the stopped study nor approves its candidate.
- [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md),
  its [backend inventory](../explorations/exp-002/backend-foundation-inventory-2026-10-05.md)
  and [consumer baseline](../explorations/exp-002/preparation-2026-10-05/README.md)
  remain reusable integration evidence for iteration 4.

Freeze current source, recipe, workload, toolchain and artifact identities at
ME-01. Historical or experimental measurements are comparison evidence, not
claims about the final production image.

## Included Scope

| Item | Source / feature | Intended outcome | Lifecycle routing |
| --- | --- | --- | --- |
| I3-04 — Runtime view-graph derivation | Revision 3 amendment; giftui-mvp-architecture / signal-analyzer | Framework/counter runtime derivation on all four configurations; analyzer derivation and graph retirement transferred to iteration-4 I4-03/04 | RFC-013 runtime work and affected SPEC-001/006/010/012/013/015; required architecture/contract approvals before adoption |
| I3-05 — Memory and execution efficiency | FW-027 / FW-032, target phase evidence and SPIKE-067 resource findings; signal-analyzer / giftui-mvp-architecture | Account for live data and phase cost, establish safe storage/stack bounds, implement measured framework/counter improvements; analyzer loaded frame/acquisition requirements transfer unchanged to I4-AC-012 | ME-01–09; route compatible internal changes through existing contracts and independently significant changes through appropriate Proposal/RFC/ADR/Spec gates |
| Internal host and backend corrections needed by I3-04/05 | Existing runtime, raster, endpoint and platform compositions | Fix measured lifetime, scheduling, layout, raster or projection costs without requiring package extraction first | Preserve existing authority boundaries; identify and approve any necessary contract change |
| Backend preparation and handoff | EXP-002 / PROPOSAL-007 | Inventory ownership/access and recording controls alongside profiling; hand off stable cost/lifetime constraints | Analysis may proceed alongside iteration 3; public API stabilization and extraction are iteration-4 delivery |

## Transferred Commitments

These IDs are preserved for traceability and are **transferred, not met**.
Revision 3's exact baseline is preserved in commit `86caf53c`.

| Previous item / criterion | Revision 4 disposition | Destination |
| --- | --- | --- |
| I3-01 / IT-AC-001 focused packages | Transfer complete external package delivery | I4-01 / I4-AC-001 |
| I3-02 / IT-AC-002 reusable backend foundation | Transfer external foundation/platform extraction and adapter delivery | I4-02 / I4-AC-002 |
| I3-03 / IT-AC-003 simpler application setup | Transfer complete public host/build/setup outcome; retain only internal corrections necessary for I3-04/05 here | I4-03 / I4-AC-003 |
| IT-AC-005 author documentation | Retain changed-behavior/evidence/disposition documentation here; transfer external quick start, adapter, API compatibility and package migration guides | I4-AC-005 |
| IT-AC-004 / IT-AC-006 | Remain iteration-3 criteria; revalidate during iteration-4 extraction | I4-AC-004 is a separate downstream obligation |

## Application and Responsibility Boundaries

Use Signal Analyzer and the same finite counter/status application: one
observable root, finite typed actions, changing text, disabled Button and a tiny
Canvas stroke variant. Preserve portable presentation importing GiftUI alone.
For iteration-3 evidence, the counter may use an isolated repository test
composition; this explicitly relaxes the external-package eligibility of the
previous baseline. It does not fulfill the transferred IT-AC-001 requirement.
Iteration 4 must establish real external consumption without privileged access.

Runtime-derived graphs remain required for both applications. Fixed bounded
storage, resource generation and finite callable/model bindings are permitted
where their reviewed meaning does not encode a hidden pre-expanded graph.

Applications retain behavior, models, actions, workload and explicit policy.
The existing host owns activation/service/retirement and scheduling/failure
joins; semantic/layout/render, raster/session and display/transport owners
retain their accepted responsibilities until separately approved changes.
Use supported and recording compositions as controls. No universal backend
base or additional core module is selected by this scope.

## Delivery Order and Gates

1. ME-01–04 form one preparation phase with one cumulative budget and one
   feasibility decision packet. Freeze the baseline; assess complete ownership,
   representations, lifetimes and execution stages against memory/performance
   requirements; measure only decision-relevant gaps; compare bounded remedies.
   Classify structural costs separately from local implementation defects.
2. ME-05: obtain required architecture/contract approvals, explicit resource
   budgets and ready implementation plans. Do not select algorithms in code.
3. ME-06 and ME-07: implement the authorized runtime/storage and performance
   changes in attributable steps; coordinate changes sharing an owner.
4. ME-08: validate exact framework/counter artifacts and applicable target evidence;
   transfer analyzer integrated/connected workload measurements to iteration 4.
   Publish retained conformance evidence and exact transferred gaps.
5. ME-09: provide the backend handoff and request human iteration disposition.

The [detailed plan](iteration-003-review/memory-efficiency-plan.md) defines
the fixed questions, numeric budget declaration, measurement controls and
terminal outcomes. Preparation ends with a supported recommendation for the
normal approval gates, an identified incompatibility requiring an upstream
decision, or an inconclusive result naming the missing evidence. None closes
the iteration or satisfies unproved acceptance criteria.

New findings must fit the remaining budget, become an explicit blocker, or be
captured as deferred work when unnecessary for current correctness. They must
not automatically add work packages, alternatives or another preparation cycle.
Any extension after a terminal outcome requires an explicit maintainer decision
on the bounded continuation. Preserve SPIKE-067's exhausted allowance; this
amendment does not resume it. A recorded reassessment and explicit continuation
authorization are required before further experiments on that stopped question.

## Exclusions

- Backend/package extraction, external public API stabilization and full external
  setup delivery; these are iteration-4 commitments. Minimal enabling corrections
  require a named dependency and their normal contract review.
- General configuration generation, arbitrary Swift lowering, a universal backend
  base, new physical backends, GPU/non-raster platforms or independent releases.
- Generated expanded graphs under a different file/table/build-product name;
  FW-035 preserves its separately triggered future question.
- General simulator/front-end IR/ABI work, non-Swift core rewrite and unrelated
  connected-conformance gaps under FW-031/FW-033.
- Automatic remote deployment/service changes or flashing; required connected
  operations still need explicit authorization.
- Lowering workloads, increasing resource ceilings or carrying an old MVP
  exception forward to conceal a new unmet criterion.

## Success Criteria and Validation

The maintainer's 2026-10-15 [focused testing policy](iteration-003-review/rfc-014-implementation-plan.md#focused-testing-campaigns--maintainer-instruction-2026-10-15)
uses existing sequential drivers and shorter campaigns only with demonstrated
change coverage and valid retained evidence. Required full gates remain intact;
parallel workers are excluded. This execution guidance leaves revision 5's
scope, criteria and bounded activity allowances unchanged.

Transferred IT-AC-001–003 retain their disposition above. IT-AC-004–010 below
retain their complete acceptance wording. Their retained shared/framework/counter portions are iteration-3 exits; counter
composition certification follows the P08 freeze allocation and analyzer portions
remain mandatory iteration-4 exits under the
[transfer map](iteration-003-review/analyzer-delivery-transfer.md#acceptance-transfer-map).

| ID | Observable result | Required configurations | Evidence / governing contract |
| --- | --- | --- | --- |
| IT-AC-004 | Both applications preserve observable semantics, identity/state/action lifetime, pixels, failure/provenance, owner direction and resource guarantees through the changes | All four configurations | Changed owner conformance, cross-profile/state/pixel/action oracles, capacity and failure controls; affected SPEC-001/002/006–015 |
| IT-AC-005 | Changed behavior and validation limits are documented; every current and transferred criterion has a separate evidenced disposition | All work packages | Exact source/toolchain/artifact identities, contract conformance, migration notes for removed graph inputs, transfer map and human closure; external author guides move to I4-AC-005 |
| IT-AC-006 | Analyzer and finite counter derive the expanded/unwrapped graph at runtime; production uses no generated graph file, pre-expanded topology table or equivalent artifact | All four configurations; isolated counter composition permitted as described above | Clean production input inventory, portable view-change/state/action/layout/pixel comparisons, retired analyzer graph outputs/dependencies; affected SPEC-001/006/010/012/013/015 and IT-AC-004 |
| IT-AC-007 | Retained/intermediate data and major frame phases have accountable cost; dominant hypotheses are confirmed or rejected | Both profiles and actual targets | Reconciled live-memory ledger, emitted copy/stack evidence, traversal/lookup/pixel counts, paired phase measurements and ranked decision packet |
| IT-AC-008 | Adopted runtime-derived analyzer and counter have safe bounded storage/lifetimes on actual compositions | All four configurations, exact Embedded image | Complete feasible-path stack/backing/platform bounds within reviewed per-application limits; ELF/load/ABI/heap evidence, capacity/failure/lifetime oracles and supplementary connected stack observations |
| IT-AC-009 | Analyzer meets existing sustained acquisition and presentation requirements with selected improvements | All four analyzer configurations, connected Pi and nRF supported artifacts for target claims | SPEC-001 workload: at least 30 continuous seconds at 80 events/s with four-FPS target cadence, no loss/reordering/duplicates/stale facts or capacity rejection, required latency/coalescing and frame/state checks |
| IT-AC-010 | Backend extraction can proceed from measured behavior and storage/transfer constraints | Cross-platform handoff | ME-09 stable-owner/API constraints, budgets, exact artifacts/oracles and residual-obligation inventory; downstream contract approvals remain required before migration |

### Required configuration matrix

| Configuration | Required evidence |
| --- | --- |
| macOS Dynamic | Both applications' runtime derivation and semantic/action/pixel/failure behavior; allocation/live-memory and phase comparison; analyzer sustained workload |
| macOS Static | Same behavior from actual bounded storage; capacity/lifetime controls, cross-profile comparison and analyzer sustained workload |
| Raspberry Pi 1 ARMv6 Dynamic | Exact supported framebuffer/PiScreen artifact and recording control; ARMv6 ABI/build evidence; connected analyzer cadence, RSS, event age and sustained workload |
| nRF52840 Embedded Static | Exact supported TFT firmware and recording control; VFP ABI, zero heap, flash/RAM and complete stack/lifetime proof; connected analyzer cadence, transfer/event counts and supplementary high-water observations |

Use repository target skills, `.toolchains/`, `.build/raspberry-pi/` and
`.build/nrf52840/`. Native rehearsal and cross-linking do not establish target
execution. If required target access is unavailable, record the gate as unmet.
Use existing per-application budgets; establish missing counter limits before
implementation. A larger stack requires a complete bound within the total RAM
budget, not merely a lower-bound witness or observed high-water mark.

Apply the mandatory batch workflow: qualify representative patterns early,
compile/check focused affected paths during migration, validate coherent batches,
and run the final combined hardware-free and required connected matrix on adopted
production artifacts. Format maintained Swift before the repository test gate. Four-FPS and lossless acquisition are
existing requirements; a percentage speedup alone does not satisfy IT-AC-009.

## Dependencies and Open Questions

- Identify exact dominant costs and credible remedies before selecting major
  changes; no representation, reuse policy or scheduling architecture is approved.
- Assess whether architectural changes are necessary, rather than assuming
  either local optimization or a wholesale rewrite. Map each recommended change
  to existing accepted authority or the precise Proposal/RFC/ADR/Spec gate needed.
- Resolve complete stack/callback/IRQ/alias/escape and supported-composition
  obligations; zero heap and a successful link alone cannot demonstrate fit.
- Preserve runtime derivation while fixing resource cost. Isolate any required
  runtime decisions from external API/package decisions where independently
  reviewable; RFC-013 remains draft and may span both iterations.
- If feasibility cannot meet IT-AC-008/009, record an evidence-backed upstream
  decision or request an explicit scope amendment/exception. Leave unmet gates
  visible until then. PROPOSAL-007 is not blanket performance redesign authority.

## Deferred and Follow-up Work

The 2026-10-31 [contract cleanup allocation](iteration-004-backend-and-application-integration.md#contract-cleanup-after-iteration-003)
places CC-01–04 in FW-037/FW-038 and iteration 4 after the iteration-3 delivery/
closure decision. It adds no post-P08 cleanup gate or P08–P12 subtask. Only a
bounded simplification necessary for a current delivery blocker belongs in its
existing task; preserve the current rules, acceptance and delivery sequence.

- FW-027 and FW-032 are selected for this iteration's resumption. Their historical
  exceptions and evidence remain; no algorithm or connected action is implied.
- FW-024/025/026 remain candidate partial-frame/reuse/projection directions;
  evaluate only when the measurements justify them and obtain required contracts.
- FW-031/FW-033 retain unrelated connected follow-up. Changed-path evidence
  required by this iteration or a governing contract remains current work.
- FW-035 retains generated-graph/interchangeable-frontend questions outside scope.
- FW-016/FW-030 and EXP-002 feed accepted PROPOSAL-007 and iteration-4 delivery.

- [FW-038](../future-work/fw-038-scoped-contract-validation-cost.md) feeds
  iteration-4 consolidation; the mandatory batch workflow applies immediately
  within the current iteration using existing runners and unchanged coverage.

## Revision and Approval History

| Revision | Date | Change / reason | Maintainer approval |
| --- | --- | --- | --- |
| 8 | 2026-11-08 | Permit closeout with S1–S3 unmet and affected reuse blocked; retain remaining gates | [Explicit restricted-use disposition](iteration-003-review/p08-unmet-safety-closeout-disposition.md) |
| 7 | 2026-11-08 | Freeze P08 UNMET; transfer counter composition certification and dependent adoption; preserve shared safety blockers and revise entry gates | [Explicit approval and allocation](iteration-003-review/p08-freeze-and-certification-transfer.md) |
| 6 | 2026-11-08 | Transfer analyzer P09–P12 to iteration 4; retain P08/framework/counter validation and revise entry gates without waiving acceptance | [Explicit approval and transfer map](iteration-003-review/analyzer-delivery-transfer.md) |
| 1 | 2026-10-04 | Initial Dev UX candidates | Discussion only; preserved in commit `232f0041` |
| 2 | 2026-10-05 | Focused packages, reusable backend and simpler setup with shared consumer/matrix | [Scope review and approval](iteration-003-review/scope-review-and-approval.md) |
| 3 | 2026-10-06 | Add I3-04 / IT-AC-006 runtime graph derivation | [Runtime amendment](iteration-003-review/runtime-derivation-scope-amendment.md); complete prior scope preserved in `86caf53c` |
| 4 | 2026-10-09 | Prioritize runtime memory/efficiency, add IT-AC-007–010, transfer package/backend/external-host delivery to iteration 4 and narrow iteration-3 counter eligibility | [Explicit sequencing approval](iteration-003-review/efficiency-sequencing-approval.md) |
| 5 | 2026-10-09 | Make ME-01–04 one bounded architecture/feasibility assessment with a shared budget, fixed questions, terminal decisions and no automatic scope growth; preserve all delivery criteria | [Bounded preparation authorization](iteration-003-review/efficiency-sequencing-approval.md#bounded-preparation-amendment--2026-10-09) |

## Closure and Follow-up

This iteration is active with closure open. The first bounded ME-01–04 phase
ended with an [inconclusive feasibility decision](iteration-003-review/feasibility-decision.md):
the baseline is frozen, source/historical memory and performance evidence is
recorded, and complete runtime-derived safety/performance remains unproved.
This is a preparation disposition, not iteration closure or runtime-candidate
adoption readiness. The later 4 MHz assessment and conditional 32 MHz review
are also closed, with their distinct results preserved. I3-T01 is now the
planned correction task; ME-05–09 remain partly or wholly open as shown in the
plan's current readiness table. No automatic experimental continuation follows.
At closure, report IT-AC-001–003 as transferred, IT-AC-005's split explicitly,
and IT-AC-004–010 as met, unmet or individually excepted with evidence. Obtain
human closure; feature architecture, contract and implemented transitions remain
separate. Iteration-4 production entry requires the retained framework/counter gates and
human handoff/closure and reviewed freeze classification, or an applicable
exception for retained failures; full P08 PASS is not required.
Transferred analyzer memory/performance, derivation and compatibility results are
iteration-4 delivery obligations, not entry gates. Report these as transferred,
unmet at iteration-3 closure; this is not full product or Spec conformance.

## References

- [Detailed activity plan](iteration-003-review/memory-efficiency-plan.md)
- [Approval and lifecycle review](iteration-003-review/efficiency-sequencing-approval.md)
- [ITERATION-004](iteration-004-backend-and-application-integration.md)
- [PROPOSAL-007](../proposals/proposal-007-external-application-integration.md),
  [RFC-013](../rfcs/rfc-013-external-application-and-backend-integration.md)
- [Preparation findings](iteration-003-review/preparation-findings.md)
- [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md),
  [SPEC-013](../specs/spec-013-runtime-profiles.md)
- [Numbered iteration rules](../engineering/ITERATION_SCOPES.md)
