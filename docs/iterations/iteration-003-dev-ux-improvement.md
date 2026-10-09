---
id: ITERATION-003
title: Runtime Memory and Efficiency
status: active
revision: 5
approved_revision: 5
created: 2026-10-04
updated: 2026-10-09
features:
  - external-application-integration
  - giftui-mvp-architecture
  - signal-analyzer
related_future_work:
  - FW-027
  - FW-032
  - FW-035
approval: "Eugene requested updating governing documents to the presented bounded preparation and architectural reconsideration approach on 2026-10-09. Revision 4 sequencing and criterion transfers remain in force. Evidence: docs/iterations/iteration-003-review/efficiency-sequencing-approval.md."
closure: null
---

# ITERATION-003: Runtime Memory and Efficiency

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

## Goal

Establish a safe, measured runtime-derived Signal Analyzer and finite counter
across macOS Dynamic, macOS Static, Raspberry Pi 1 Dynamic and nRF52840 Embedded
Static. Account for intermediate representations, copies, repeated traversal
and simultaneous storage; remove demonstrated avoidable costs. Validate the
analyzer's existing sustained acquisition and presentation requirements before
stabilizing external backend and host APIs.

Remove generated expanded/unwrapped view-graph files and their production
build dependencies. Derive both applications' graphs from portable declarations
at runtime while preserving bounded zero-heap Static execution, identity,
state/action semantics, pixels and failure/publication behavior.

This is post-MVP work. ITERATION-001 closed with recorded exceptions; the
existing features remain implemented at their previously approved contracts.
Those exceptions do not satisfy this iteration's memory/performance criteria.
External application integration remains at RFC stage under accepted
PROPOSAL-007 and draft RFC-013, with external delivery scheduled in iteration 4.
Independent performance architecture needs its applicable investment and
RFC/ADR/Spec gates; iteration approval does not supply those decisions.

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
| I3-04 — Runtime view-graph derivation | Revision 3 amendment; giftui-mvp-architecture / signal-analyzer | Both applications derive their complete graph at runtime on all four configurations; retire production analyzer graph generation with equivalent coverage | RFC-013 runtime work and affected SPEC-001/006/010/012/013/015; required architecture/contract approvals before adoption |
| I3-05 — Memory and execution efficiency | FW-027 / FW-032, target phase evidence and SPIKE-067 resource findings; signal-analyzer / giftui-mvp-architecture | Account for live data and phase cost, establish safe storage/stack bounds, implement measured improvements and satisfy existing loaded frame/acquisition requirements | ME-01–09; route compatible internal changes through existing contracts and independently significant changes through appropriate Proposal/RFC/ADR/Spec gates |
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
4. ME-08: validate exact integrated artifacts, including required connected
   sustained-workload measurements; publish conformance evidence and gaps.
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

Transferred IT-AC-001–003 retain their disposition above. IT-AC-004–010 below
are current exit obligations, not replacement Specification acceptance criteria.

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

Run focused checks per change, format maintained Swift before the repository
test gate, then run the final combined hardware-free and required connected
matrix on adopted production artifacts. Four-FPS and lossless acquisition are
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

- FW-027 and FW-032 are selected for this iteration's resumption. Their historical
  exceptions and evidence remain; no algorithm or connected action is implied.
- FW-024/025/026 remain candidate partial-frame/reuse/projection directions;
  evaluate only when the measurements justify them and obtain required contracts.
- FW-031/FW-033 retain unrelated connected follow-up. Changed-path evidence
  required by this iteration or a governing contract remains current work.
- FW-035 retains generated-graph/interchangeable-frontend questions outside scope.
- FW-016/FW-030 and EXP-002 feed accepted PROPOSAL-007 and iteration-4 delivery.

## Revision and Approval History

| Revision | Date | Change / reason | Maintainer approval |
| --- | --- | --- | --- |
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
separate. Iteration-4 production extraction depends on the memory/performance,
runtime-derivation and compatibility gates or a specifically accepted exception.

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
