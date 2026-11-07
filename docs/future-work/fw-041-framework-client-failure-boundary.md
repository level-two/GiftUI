---
id: FW-041
feature: external-application-integration
title: Separate Framework and Client Failure Ownership
status: captured
authors:
  - codex
created: 2026-11-07
updated: 2026-11-07
source:
  - RFC-013
  - docs/iterations/iteration-004-backend-and-application-integration.md
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-004
---

# FW-041: Separate Framework and Client Failure Ownership

## Observation / Opportunity

Signal Analyzer currently interprets GiftUI owner failures and performs parts
of framework failure handling, while application rejection identities and
operational failures participate in GiftUI cycle and policy machinery. An
external consumer should not need to reproduce this knowledge to use GiftUI.
The opportunity is to separate failure ownership, rather than move or duplicate
the mixed `SignalAnalyzerRuntimeCondition` machinery wholesale into GiftUI.

### Current architecture and contract review

Reviewed on 2026-11-07 against checkout base `56ad8e486aeab16254b06c7467cbb8510c75664a`
and the existing working tree. This is a source/contract review, not execution
or conformance evidence. In particular, `SignalAnalyzerCycleFailureNormalizer`
and SPEC-013 already have unrelated working changes; implementation details
need refreshing against the eventual iteration-3 handoff.

| Finding | Evidence | Boundary issue / review obligation |
| --- | --- | --- |
| F-01 — Mixed producer catalogue | [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md), the `SignalAnalyzerRuntimeCondition` declaration and Error Handling tables; [enum](../../Sources/SignalAnalyzerPresentation/SignalAnalyzerRuntimeCondition.swift) | Observable-state capacity, identity, phase and invariant conditions share one application enum with capture revision and reserved failure-slot conditions. Classify each by actual owner; do not infer ownership merely from the enum or the word runtime. |
| F-02 — Framework normalization in application code | [runtime normalizer](../../Sources/SignalAnalyzerPresentation/SignalAnalyzerRuntimeFailureNormalizer.swift), [cycle normalizer](../../Sources/SignalAnalyzerTargetHost/SignalAnalyzerCycleFailureNormalizer.swift), [framework adapter fixture](../../Sources/GiftUIObservableStateFailureAdapterFixture/ObservableStateFailureAdapter.swift) | The cycle normalizer switches over semantic, layout, observable-state, interaction, drawing, execution and render errors. Framework adapter fixtures already overlap some mappings, with different context sensitivity. Reconcile semantics before consolidating; fixtures are not automatically production owners. |
| F-03 — Mixed effect and policy ownership | [effect vocabulary](../../Sources/SignalAnalyzerPresentation/SignalAnalyzerFailurePolicyValues.swift), [runtime rules](../../Sources/SignalAnalyzerPresentation/SignalAnalyzerRuntimeFailureRule.swift), [owner adapter](../../Sources/SignalAnalyzerPresentation/SignalAnalyzerOwnerFailureAdapter.swift), [dynamic effects](../../Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerApplicationFailureOwner.swift) | Stopping acquisition and marking the application failed sit beside discarding publication, pacing retries and quiescing runtime health. The dynamic sink groups several effects into graph invalidation/admission quiescence and treats others as already completed. Separate true framework containment from client effects and host product choices. |
| F-04 — Client error representation depends on framework facts | [presentation values](../../Sources/SignalAnalyzerPresentation/SignalAnalyzerPresentationValues.swift), [failure normalizer](../../Sources/SignalAnalyzerPresentation/SignalAnalyzerFailureNormalizer.swift), SPEC-001 Error Handling | `SignalAnalyzerOperationalFailure` contains `GiftUIFailureFact`; capture revision exhaustion and admission failures normalize into framework origin/scope/containment values. This coupling is in Presentation/integration, not an observed FailureCore import in SignalAnalyzerDomain. Determine a client-owned representation and translation needs without making logs authoritative. |
| F-05 — Shared cycle carries application rejection | [owner sum](../../Sources/SignalAnalyzerTargetHost/SignalAnalyzerCycleOwnerFailure.swift), [SPEC-013](../specs/spec-013-runtime-profiles.md) “Shared pipeline failure and mutation seam”, [SPEC-015](../specs/spec-015-host-configuration.md) “Compatibility” | The finite sum combines `RuntimeOwnerFailure` and application conditions. Specs explicitly preserve exact application rejection and execution context, including rejection after partial mutation. Runtime Core does not import application modules; generic transport alone is not semantic ownership. Decide whether transport remains necessary, and how partial mutation is finalized safely if it changes. |
| F-06 — Host composition and backend policy exposure | [cycle policy owner](../../Sources/SignalAnalyzerTargetHost/SignalAnalyzerCycleResidualPolicyOwner.swift), [Static routing](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFResidualRouting.swift), SPEC-015 Error Handling | Application target glue supplies framework policy/invariant hooks and routes backend health outcomes. Separate reusable framework/host mechanics from legitimate product lifecycle choices. Audit Dynamic and Static paths, including firmware composition, rather than relocating only one adapter. |

[ADR-014](../adrs/adr-014-bounded-cross-layer-outcomes.md),
[ADR-015](../adrs/adr-015-layered-failure-disposition.md) and
[ADR-016](../adrs/adr-016-non-authoritative-diagnostics.md) are accepted.
[Implemented SPEC-003](../specs/spec-003-failure-outcomes-and-containment.md)
requires explicit bounded outcomes and containment before residual policy;
ADR-015 already rejects exposing mandatory mechanics as product choices.
The [architecture summary](../architecture/module-dependencies-and-interfaces.md)
describes these separate owner errors, failure facts and composition adapters.
Approved SPEC-001 and SPEC-013 amendments and SPEC-015's current contract also
explicitly require the application integration above. These findings identify
an ownership redesign opportunity, not proof that all current code violates
its contract. Hiding errors must not erase required safety information.

## Candidate Boundary and Questions

The proposed direction for review is:

- GiftUI owns framework failure identities, normalization, containment,
  transaction finalization and runtime-health mechanics. Ordinary client code
  should not switch over internal errors or implement those mechanics.
- Client domain and presentation own acquisition, capture and other business
  failures. They express failure as ordinary application state and handle
  recovery within the client scope, without classifying a business failure as
  a GiftUI runtime fault or directly manipulating framework health.
- Target composition may still need a narrow, stable lifecycle outcome and
  explicit product choices when mounting or continued operation is impossible.
  Optional diagnostics remain observational. Neither interface should expose
  the internal failure catalogue or ask clients to repair framework invariants.
- Contract violations and unsafe partial mutations remain GiftUI containment
  responsibilities even when caused by client code. An ordinary client error
  must not poison a healthy runtime; conversely, client-local handling must not
  permit unsafe publication or continuation. Client-requested unmount/restart
  and ordinary UI updates remain legitimate effects on GiftUI.

Open decisions include whether a bounded opaque rejection carrier is still
needed, which failure notification belongs to host versus portable client,
and who owns admission exhaustion/sequence failure at each boundary. Determine
whether application-only failure can preserve a healthy mounted UI, and how to
handle the current reserved-failure path without recursive failure reporting.
No replacement API, module topology or universal error protocol is selected.

## Why Deferred

This is post-MVP integration work. ITERATION-001's State and Data Boundary and
shared reference-application requirement explain the desired separation;
ITERATION-004's real external consumer makes duplicated framework failure
handling a concrete integration concern. It is not a new iteration-3 delivery
blocker or permission to weaken current safety, resource or conformance gates.
Changing the current mappings, carrier or effects requires accepted decisions
and reviewed contracts before production implementation.

The feature manifest places `external-application-integration` at `decision`;
PROPOSAL-007 is accepted, but RFC-013 remains draft. Existing approvals for
other runtime/storage work do not approve this boundary. Use RFC-013 for this
coherent external ownership decision if PROPOSAL-007 covers the selected scope;
otherwise first obtain an amended/new Proposal. Review ADR-014/015/016 and
produce new/superseding decisions where necessary, then amend affected
SPEC-001/003/009/011/013/015 contracts and tests before implementation. Broader
owner specs are affected only where their exposed failure seams change.

## Potential Value

- External consumers could use GiftUI without copying internal error mappings,
  effect dispatch or policy boilerplate.
- Framework safety behavior could have one owner across applications/profiles.
- Client failures could be tested and rendered independently of runtime health.

## Current Non-goals

- No approved ADR, Specification, public failure API or production behavior is
  changed by this capture; no code migration or fixture deletion is authorized.
- No blanket swallowing of errors, fabricated invariant failures, weaker
  containment, unbounded retries, lost accepted facts or diagnostic control path.
- No finer recovery taxonomy (FW-013), unrelated whole-Core rewrite, new global
  error service, or automatic hardware/deployment work.

## Revisit Triggers

- I4-08 begins its boundary review before RFC-013's external package/public
  assembly decisions are finalized, coordinated with I4-01/03/06.
- A real external counter or second consumer otherwise needs analyzer failure
  normalizers, framework effect switches, or shared-package internal access.
- A proposed removal of application rejection from the shared cycle would
  affect partial-mutation containment, exact outcome preservation or finalization.

## Disposition

Captured. On 2026-11-07 Eugene requested: “Review the current architecture and
specs, identify where framework and client failure handling are mixed, and
draft a future work proposal to fix the boundary. Put it into the next iteration
scope and commit”. This authorizes capture and ITERATION-004 revision 5's
I4-08 / I4-AC-009 review, boundary proposal and migration/validation plan.
It does not approve an architectural choice or implementation. The iteration
remains approved, not active, and this item remains `captured` until explicit
promotion to an Exploration or applicable main-lifecycle artifact is recorded.

The next outcome is a reviewed disposition of F-01–06, an owner/API boundary
proposal, and a traceable contract and migration plan. Implementation follows
normal gates; unresolved containment or resource evidence stays explicit.

## References

- [RFC-013](../rfcs/rfc-013-external-application-and-backend-integration.md): draft design destination and reciprocal source link.
- [ITERATION-004](../iterations/iteration-004-backend-and-application-integration.md): scheduled review and evidence criteria.
- [PROPOSAL-007](../proposals/proposal-007-external-application-integration.md): accepted external-consumer investment.
- [ITERATION-001](../iterations/iteration-001-mvp.md): original State and Data Boundary.
- [FW-030](fw-030-application-integration-experience.md): broader integration experience.
- [FW-013](fw-013-fine-grained-failure-containment-recovery.md): distinct finer-recovery question, not a prerequisite to ownership separation.
