---
id: RFC-013
feature: external-application-integration
title: External Application and Backend Integration
status: draft
authors:
  - codex
created: 2026-10-05
updated: 2026-11-08
proposal:
  - PROPOSAL-007
related_rfcs:
  - RFC-014
  - RFC-002
  - RFC-008
  - RFC-009
  - RFC-011
related_adrs:
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-010
  - ADR-025
  - ADR-026
  - ADR-033
related_specs:
  - SPEC-002
  - SPEC-009
  - SPEC-010
  - SPEC-011
  - SPEC-012
  - SPEC-013
  - SPEC-014
  - SPEC-015
related_future_work:
  - FW-016
  - FW-030
  - FW-035
  - FW-038
  - FW-041
related_explorations:
  - EXP-002
related_spikes:
  - SPIKE-014
  - SPIKE-068
supersedes: []
superseded_by: []
target_milestone: ITERATION-004
---

# RFC-013: External Application and Backend Integration

**Draft; design reconsideration required.** This compact record retains the RFC
identity, investment authority and unresolved decision boundary. The original
candidate designs, alternatives and experimental reasoning remain in the
[preparation archive](../iterations/iteration-003-review/preparation-archive.md).
No candidate is accepted by this reconstruction. This is not ready for RFC
approval or implementation planning.

**Runtime design routing — 2026-10-09:** [RFC-014](rfc-014-runtime-derived-records-and-scoped-model-access.md)
owns the focused runtime record/identity and scoped model/capture recommendation
from I3-T02. This RFC retains external API, package, assembly and setup decisions.
The earlier runtime candidate below is historical evidence; RFC-014 neither
adopts it nor reopens its experiments. RFC-014 is now approved under its
[final review](../iterations/iteration-003-review/rfc-014-final-review.md); its ADR/Spec
and implementation acceptance gates still precede runtime adoption. This does
not resolve or approve the independent external package decisions in RFC-013.

## Problem and authority

[Accepted PROPOSAL-007](../proposals/proposal-007-external-application-integration.md)
defines external application and adapter consumption, focused packages, simpler
setup and compatibility outcomes. Existing accepted ADRs and implemented owner
Specifications remain authoritative. Iteration commitments do not approve
architecture or implementation.

Runtime derivation and measured memory/performance work belong to
[ITERATION-003](../iterations/iteration-003-dev-ux-improvement.md). External
package/backend/host delivery belongs to
[ITERATION-004](../iterations/iteration-004-backend-and-application-integration.md).
Runtime and external API decisions may be reviewed separately where independently
coherent. PROPOSAL-007 does not grant blanket authority for performance redesign.

## Reusable host delivery requirement — 2026-11-07

Eugene explicitly requested reusable hosts supplied as an easy-to-integrate
black box, then instructed: “Please capture this explicitly in RFC-013 and
strengthen the iteration-004 acceptance criteria, including migrating Signal
Analyzer to the reusable host. Update dependent documents and commit.”
[ITERATION-004 revision 8](../iterations/iteration-004-backend-and-application-integration.md#revision-and-approval-history)
records this approved delivery requirement under PROPOSAL-007 EI-001–005.
It does not approve this draft's eventual API or ownership realization.

Supported GiftUI hosts must encapsulate framework assembly and lifecycle
orchestration: runtime/storage setup, scheduling, input routing, rendering,
presentation and teardown. Clients supply portable views, application state,
business services/data sources, resources and explicit target/resource policy
configuration through supported inputs. Clients must not recreate framework
state machines, wire internal owners or maintain framework storage offsets and
source lists. Merely publishing assembly primitives or shortening bootstrap
syntax does not satisfy this requirement.

Black-box integration describes the normal consumer experience, not opaque
constraints or a new semantic owner. Preserve ADR-007's separate component
ownership and dependency direction. Resource limits, capabilities, startup
validation and operational diagnostics remain explicit and inspectable. A
custom display/backend adapter must use narrow supported extension contracts
through the same host path; customization must not require a second bootstrap.

Both the external counter and Signal Analyzer must use the reusable host path
on macOS Dynamic/Static, Raspberry Pi 1 ARMv6 Dynamic and nRF52840 Static.
Signal Analyzer must cease depending on bespoke framework assembly in
`SignalAnalyzerTargetHost` and firmware setup; retain only justified
application-specific capture/domain/service adapters and configuration. Inventory
each existing responsibility, record its destination, and remove superseded
production wiring after equivalent validation. Renaming the module or moving
its application-specific assembly unchanged into a public package is insufficient.
The module name itself is not a required removal target.

Under the [approved delivery transfer](../iterations/iteration-003-review/analyzer-delivery-transfer.md),
RFC-014 analyzer P09–P12 now join iteration-4 reusable-host adoption. Runtime
traversal and cutover alone do not establish that adoption. Coordinate I4-03/04 with
I4-07's ownership residuals, I4-08's failure-boundary review and I4-10's model
API migration, preserving their separate gates and avoiding duplicate work.

### Counter-first migration and P08 reuse — 2026-11-08

Eugene requested: “Please capture this counter-first migration approach in RFC-013
and the iteration-4 plan, making reuse of the P08 implementation and evidence
explicit. Update dependent documents and commit.” This establishes delivery
sequencing under I4-03/04, not approval of this draft's API or ownership design.

The P08 counter is a repository fixture with local host/pipeline assembly, not
yet an external consumer. Its concrete starting points include
[CounterHostOwner](../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterHostOwner.swift),
[CounterPipelineOwner](../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift),
profile storage and scoped-backing construction, and the existing GiftUI
[SignalAnalyzerPresetHostInstance](../../Sources/GiftUIHostConfiguration/SignalAnalyzerPresetHostInstance.swift).
Internal imports and `@testable` joins expose the current integration gap.
Use these mechanisms and their qualified evidence as the extraction baseline;
do not restart host implementation from an empty design or publish the fixture
unchanged as the supported host.

1. Use the [approved P08 freeze](../iterations/iteration-003-review/p08-freeze-and-certification-transfer.md):
   P08 stays FROZEN / UNMET. Complete bounded classification and retained shared
   validation, then obtain the iteration-3 handoff/closure decision. Pin source,
   compiler/SDK, flags, profiles, artifacts and criterion results with failures and
   limits. Full old-composition certification is not an extraction entry gate;
   shared safety defects or required unresolved safety premises still block the
   affected use. Complete transferred certification on the supported counter host
   under I4-AC-013 before its adoption and dependent analyzer adoption.
2. Inventory the counter's assembly responsibilities before extraction: classify
   each as reusable framework/host responsibility, application behavior or test
   instrumentation. Preserve separate component ownership. Views, model/state,
   actions, business services and explicit resource/target configuration stay
   consumer inputs; fault injection and probe bookkeeping stay in tests. Host
   construction, storage/lifetime coordination, scheduling, input/render joins,
   activation, refusal and teardown are candidates for the supported host path,
   subject to the approved ownership and API contracts.
3. After normal RFC/ADR/Spec and iteration entry gates, extract the qualified
   mechanisms into the supported GiftUI host. Make the counter a real external
   package using supported interfaces, with no `@testable`/privileged imports,
   internal owner wiring or handwritten framework source lists. Qualify supported
   and recording-adapter compositions across all four governed configurations.
4. Migrate Signal Analyzer through the same qualified host contracts. Coordinate
   I4-07 ownership residuals, I4-08 failure boundaries and I4-10 model authoring;
   address analyzer-specific capture/admission and workload needs through the
   normal contract gates. Complete analyzer P09–P12 on that final composition.

Reuse implementation and evidence deliberately. The migration receipt must map
old symbols/responsibilities to their destination or retirement and each relevant
P08 criterion/result to **reuse with applicability justification**, **refresh**,
or **unmet**. Consider source/dependency changes, module/access and generic
specialization boundaries, compiler/SDK/flags, concrete types, profile, backing
layout, lifetime, artifact and measurement conditions. Extracted code is not
unchanged evidence merely because its body is identical. Refresh invalidated
actual-consumer, allocation/cold, lifetime/refusal/cleanup, resource/ABI and target
checks; retain independent state/action/pixel oracles and applicable compiler
negative controls. Never replace those oracles with captured candidate output.

Counter qualification is the first adoption milestone, not proof of analyzer
scale, resource fit or cadence. Compare the extracted counter against its pinned
P08 baseline, then certify the final analyzer independently. Retire duplicated
fixture orchestration only after equivalent replacement coverage exists; keep
useful fault controls and baseline oracles. No P08 budget, safety duty or failed
check is waived, and no new P08 generalization task is introduced.

### Design questions and evidence

The review must compare supported presets/factories, explicit advanced component
assembly, and application-owned versus host-owned event-loop integration. A
primitive-only assembly surface may support advanced use but cannot be the only
normal integration path. Exact API/package names, backing ownership and lending,
service lifetimes, activation/shutdown, policy customization and diagnostic
contracts remain review blockers, not accepted choices or optional deferred work.
Map resulting decisions to ADR-007/008 and affected owner Specs, including
SPEC-003/009/013/014/015; obtain amendments where needed before implementation.

Prove adoption with external-package builds, both applications' actual host
entry points and dependency scans, a responsibility/migration inventory, and
supported/custom-adapter activation, failure and teardown tests. Count generated
inputs and hidden prerequisites in setup comparisons. Preserve independent
state/action/pixel oracles and explicit RAM/stack/heap/flash and timing evidence
across all four configurations. Encapsulation must not hide allocation, introduce
runtime discovery, merge semantic owners or silently increase resource budgets.
This requirement is current iteration work; general services and configuration
generation remain outside it under FW-009/FW-006 unless separately approved.

## Constraints to preserve

- Portable presentation imports GiftUI alone; platform and display selection
  belongs at composition boundaries.
- Both Signal Analyzer and the finite counter retain identity, state/actions,
  layout/pixels, publication, failure and teardown semantics across profiles.
- Static remains bounded and zero-heap; real target stack, backing, ABI and
  resource evidence is required. Native execution cannot establish target safety.
- Runtime graph derivation remains the approved delivery requirement. Generated
  pre-expanded topology under a different name is not an equivalent result.
- Reuse established semantic, layout, raster, endpoint and platform owners unless
  a separately reviewed change is necessary. No new module or public API is
  selected by this document.

## Evidence and alternatives

[The findings summary](../iterations/iteration-003-review/preparation-findings.md)
identifies reusable positive results, failed approaches and precise limitations.
It replaces the active chain of per-attempt reconciliation documents.

The archived design compared runtime traversal into packed records and
caller-owned typed records, explicit backing and different construction/service
lifetimes, as well as package/access and host-boundary alternatives. Preserve
those tradeoffs as evidence. Do not assume a previous candidate must be completed
because substantial experimental code already exists.

## Required decisions before review

1. A feasible complete runtime/storage/lifetime realization and explicit resource
   bounds, including unresolved callback, escape and alias behavior.
2. The smallest compatible ownership/contract changes justified by that result;
   identify affected ADRs and Specs without treating a draft as authority.
3. After iteration-3 constraints stabilize, a minimal transitive public surface,
   package partition, supported construction/activation path and build inputs.
4. Compatibility and migration behavior, error/provenance visibility, equivalent
   external setup measurements and the final configuration/evidence matrix.

Rebuild a reviewable design recommendation only around the next decision and
its measured alternatives. The [current plan](../iterations/iteration-003-review/memory-efficiency-plan.md)
sets the order. Human RFC approval, accepted ADRs, approved Spec amendments and
ready implementation plans remain prerequisites for major production adoption.

Under iteration-3 revision 5, ME-01–04 produce one bounded feasibility decision,
not an open-ended sequence of candidate repairs. Assess the complete ownership,
representation, lifetime and execution model, and distinguish structural costs
from local defects. Neither the archived candidate nor a wholesale redesign is
presumed necessary. The packet must identify the exact accepted decisions and
contracts that each recommendation preserves or would change.

A supported runtime recommendation may feed this RFC where PROPOSAL-007 covers
the decision. Independently significant performance changes require their own
applicable investment and architecture routing; do not use this RFC as blanket
authority. An incompatible or inconclusive result ends the bounded phase with
the required decision or missing evidence explicit. The plan's cumulative budget
and continuation rules apply; unresolved review questions do not automatically
authorize another experiment.

The [bounded feasibility packet](../iterations/iteration-003-review/feasibility-decision.md)
ends inconclusive. It recommends reviewing runtime-emitted bounded records and
explicit backing/lease lifetimes against the archived aggregate candidate,
without selecting either. Complete stack/callback/escape proof, supported
compositions and sustained-workload performance remain approval blockers. The
packet maps local performance remedies to their owners and distinguishes
independent redesign from this RFC's accepted investment. This RFC remains draft
and not ready for approval; no follow-up compilation is authorized by the packet.

## Deferred work

Eugene subsequently authorized one complete candidate assessment with a binary
go/no-go outcome and no automatic successor study. The
[runtime candidate appendix](../iterations/iteration-003-review/candidate-go-no-go.md)
defines representation, ownership, construction, service, teardown, proposed
resource ceilings and fixed adoption gates. It is part of this draft RFC's
runtime decision boundary, not an approved design. Its
[SPIKE-068](../spikes/spike-068-candidate-transfer-bound.md) tests a necessary
transfer-cost condition within the same single budget. Historical inconclusive
findings remain unchanged; this explicit authorization is the continuation basis.

The assessment is now terminal **NO-GO** and the RFC review verdict remains
**not ready**. SPIKE-068 demonstrates that the candidate's retained nRF
operation-major transfer strategy requires at least 508.48 ms for background
fills alone, exceeding the 250 ms budget. Complete runtime/lifetime safety and
cross-profile equivalence remain unproved. Reconsideration requires an explicit
different rendering/transfer or requirement decision; this result does not
authorize more experiments, implementation or a successor preparation phase.

Subsequently, Eugene explicitly authorized a
[32 MHz architectural reassessment](../iterations/iteration-003-review/candidate-go-no-go.md#32-mhz-architectural-reassessment)
of that candidate. Treat 32 MHz as a hypothetical bus rate, not a hardware
measurement or accepted contract amendment. The review distinguishes inevitable
architectural limits from correctable implementation behavior and missing proof.

That review is closed with **no additional unavoidable architectural contradiction
found under the assumption**. The recommendation retains current owner boundaries
and bounded/serialized/borrowed contracts. Source-deadline rebasing is a concrete
implementation blocker; raster/layout costs and resolver/stack/resource proof
remain unresolved. This supports reconsidering the 4 MHz rejection's applicability,
not approving the candidate: RFC-013 remains draft and not ready for adoption.

[FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md) and
[FW-030](../future-work/fw-030-application-integration-experience.md) feed the
accepted investment. [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md)
and [SPIKE-014](../spikes/spike-014-external-consumer-access-baseline.md) preserve
the original preparation baseline. [FW-035](../future-work/fw-035-generated-view-graph-for-interchangeable-frontends.md)
retains a future generated-frontend trigger. Full current memory/lifetime safety
cannot be deferred as an optional optimization.

[FW-038](../future-work/fw-038-scoped-contract-validation-cost.md) records the
2026-10-15 request to consolidate P08 application/build/test infrastructure during
ITERATION-004 separation. Evaluate test ownership, supported consumer reuse and
coverage-preserving driver retirement with this RFC's package/assembly decisions;
no module topology or reduction of required proof is selected by the capture.

## Deferred and Follow-up Work

[FW-041](../future-work/fw-041-framework-client-failure-boundary.md) records the
framework/client failure ownership review and candidate separation, scheduled
by ITERATION-004 revision 5 I4-08 / I4-AC-009. Resolve framework containment,
client business failures and the narrow host lifecycle boundary before dependent
public assembly decisions. Reconcile ADR-014/015/016 and the affected owner
Specifications; the capture does not amend their contracts or approve an API.
