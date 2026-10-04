---
id: ITERATION-002
title: Cleanup
status: draft
revision: 1
approved_revision: null
created: 2026-10-04
updated: 2026-10-04
features:
  - giftui-mvp-architecture
  - signal-analyzer
  - capability-system
  - observable-reference-state
  - canvas-drawing
approval: null
closure: null
---

# ITERATION-002: Cleanup

This is a working scope gathered from maintainer discussions, not a finalized
commitment. A bounded codebase audit will inform selection of fixes and the
validation matrix before scope approval. The maintainer may add, remove, or
refine candidates based on that evidence. Follow
[Numbered Iteration Scopes](../engineering/ITERATION_SCOPES.md) and the
[Codebase Review Process](../engineering/CODEBASE_REVIEW.md).

## Goal

Establish evidence of implementation consistency, justified complexity, and
clear ownership after MVP, then simplify the implementation through selected,
validated fixes. Existing candidates concern dependencies, duplicated nRF UI
structure, source conditionals, and capture retention aligned with the
analyzer's visible range. Audit findings determine the final remediation scope.

## Included Scope

The audit and findings-selection process are proposed review outcomes. All
remediation rows remain candidates; implementation details and validation
boundaries are still open. Scope membership creates no implementation authority.

| Item | Source / feature | Intended outcome | Lifecycle routing |
| --- | --- | --- | --- |
| Bounded codebase audit and findings selection | Maintainer discussion establishing the cleanup review process; all participating features | Review dependencies, module interfaces, abstractions/mappings, requirements, execution flows, profiles/resources, and tooling. Produce a baseline, coverage matrix, evidence-backed findings register, and prioritized remediation selection. | Read-only review may begin while this scope is draft. Route confirmed defects, simplifications, contract changes, architectural concerns, and uncertain hypotheses separately under the existing lifecycle. |
| Improve process: numbered iterations | [ITERATION-001](iteration-001-mvp.md); discussion “Plan MVP Cleanup Iteration” | Use consecutive scope records, beginning with MVP as ITERATION-001. The process and MVP registration are already delivered; these draft scopes continue it. Identify any remaining process gaps during review. | Documentation maintenance under the existing iteration rules. |
| Revise module dependencies | Discussion “Review module dependency direction”; giftui-mvp-architecture | Reassess dependency directions and glue modules against their actual responsibilities; select remaining cleanup after accounting for completed SPEC-001 Milestone 10 work. | Contract-preserving maintenance may use the lightweight path; ownership or dependency-graph changes require lifecycle review against ADR-007/ADR-008 and SPEC-002. |
| Investigate replacement of the nRF `.generated` hierarchy approach | Discussion “Explain Static nRF Stack Hierarchy”; signal-analyzer | Produce measured feasibility evidence and a recommendation on runtime derivation from portable view declarations. Replacement and removal of supporting infrastructure are candidates to select only if costs and parity are acceptable. | Use Exploration/Spike work where needed. Preserve Static bounded storage, zero heap allocation, and semantic parity; obtain affected contract/architecture approvals before implementing a selected replacement. |
| Remove source `#if` / `#ifdef` conditionals | [FW-029](../future-work/fw-029-reduce-source-conditional-compilation.md) | Remove avoidable conditionals and make implementation selection clearer. Determine the justified residual guards during code review. | Mechanical source selection may be lightweight; changes to profile behavior, storage, ownership, or declarations need lifecycle review. |
| Five-second Signal Analyzer buffer | Discussion “Assess 10 Hz Input Frequency Limit”; signal-analyzer | Reduce retained capture history from 30 seconds to 5 seconds, covering the largest visible window while preserving channel baselines and the existing 10 Hz per-channel input limit. | Amend accepted ADR-003 and affected capture/host contracts before implementation; resize all affected stores and remeasure resource use. |

## Audit and Scope Finalization

The sequence is: draft scope → bounded audit → findings reconciliation →
selection of fixes → explicit scope approval → required architecture/contract
gates → implementation planning and execution. Existing governing contracts
remain authoritative throughout. An investigation selected for an approved
iteration may finish with evidence and a disposition rather than a replacement.

1. Record the reviewed revision and working-tree changes, applicable accepted
   ADRs and approved/implemented Specifications, existing evidence, and known
   limitations. Carry forward MVP timing and connected-validation exceptions
   explicitly; iteration closure did not establish universal conformance.
2. Inventory maintained framework/application modules, target hosts, generators,
   SwiftPM and firmware build composition, tests, and operational scripts.
   Record reviewed areas and exclusions in a coverage matrix. Cover macOS
   Dynamic, macOS Static, Raspberry Pi ARMv6 Dynamic, and nRF52840 Static,
   distinguishing hardware-free evidence from connected execution.
3. Apply the focused passes and finding format in the
   [Codebase Review Process](../engineering/CODEBASE_REVIEW.md). Review each
   module with its producers and consumers, and trace end-to-end update,
   input/action, presentation, and failure/recovery flows. Check both contract
   conformance and whether existing design choices remain justified.
4. Reconcile overlapping findings by root cause. Prioritize correctness and
   ownership problems, then supported simplifications. Separate architectural
   concerns and hypotheses requiring evidence from implementation fixes.
   Account for completed SPEC-001 Milestone 10 cleanup before selecting work.
5. Select bounded fixes and investigations, with finding IDs, lifecycle routes,
   affected configurations, validation requirements, and measurable outcomes.
   Refine the candidate rows and criteria before requesting scope approval.
   Resolve uncertainties that invalidate a promised outcome; otherwise promise
   an investigation and disposition. Capture valuable unselected work through
   Future Work, Exploration, or Spike records with provenance and revisit triggers.
6. After scope approval and the applicable lifecycle gates, prepare implementation
   tasks under governing Specifications. Make small coherent changes, run focused
   checks, format maintained Swift before repository gates, and use affected
   profile gates at integration milestones. Remeasure constrained resources where
   affected and review resulting changes against their selected findings.

At audit kickoff, create and link the baseline, coverage matrix, and findings
register as derived review records. No audit has yet been performed by this
scope update. Completion depends on coverage and explicit finding dispositions,
not on repeated agent passes ceasing to produce suggestions. Discovery does not
automatically select remediation or expand an approved iteration.

## Exclusions

- No commitment to fix every audit finding, minimize type/target/directive
  counts, or redesign every reviewed module. Review coverage is broader than
  the eventual implementation commitment.
- Splitting packages, defining a core backend module, and redesigning consumer
  integration belong to the [Dev UX draft](iteration-003-dev-ux-improvement.md).
- No wholesale removal of generated code is implied: the nRF candidate concerns
  the precomputed analyzer hierarchy and its supporting infrastructure. Static
  Canvas specialization and unrelated generated resources need separate review
  if discovered to be affected.
- No lower signal frequency, new analyzer navigation, or new platform is proposed.
- Pi/nRF rendering optimization and outstanding connected validation are not
  automatically included; their existing deferred records remain separate.

## Success Criteria and Validation

These are provisional outcomes to refine before scope approval.

| ID | Observable result | Required configurations | Evidence / governing contract |
| --- | --- | --- | --- |
| IT-AC-001 | Numbered iteration records are registered, discoverable, and distinguish draft scope from approved commitments. | Repository documentation | Governance validation and iteration index; already established process plus these scopes. |
| IT-AC-002 | Selected dependency cleanup has explicit ownership and no forbidden imports or dependency cycles. | Affected modules and supported target builds, to be selected | Before/after dependency inventory, owner checks, and governing ADR-007/ADR-008/SPEC-002 criteria. |
| IT-AC-003 | nRF hierarchy replacement has a reproducible feasibility assessment and explicit recommendation/disposition; replacement is selected only through scope and lifecycle review. | nRF Static; desktop comparison/rehearsal | Inventory of affected generated sources/scripts/mappings; candidate parity and firmware build evidence; heap/ABI checks; measured RAM, flash, stack, and derivation cost; acceptable cost thresholds agreed before judging feasibility; remaining limitations. |
| IT-AC-004 | Reviewed avoidable conditionals are removed; remaining guards have documented reasons. | Affected Static/Dynamic and platform source selections | Before/after inventory and affected compile/behavior checks; preserve compile-time exclusions and resource bounds. |
| IT-AC-005 | Five-second retention supports all existing 1/2/5-second windows and correct levels at the left edge. | All analyzer configurations | Approved capture/host contract amendments, cutoff/baseline/ordering tests, store-capacity evidence, nRF memory measurements, and sustained acquisition validation. |
| IT-AC-006 | The bounded audit records its baseline, all planned review perspectives, coverage and gaps, evidence-backed findings, and reconciled dispositions. | Maintained code/build/test areas across all four supported configurations | Linked baseline, coverage matrix, and findings register following the Codebase Review Process; governing requirements and known MVP exceptions; explicit evidence limitations rather than inferred passes. |
| IT-AC-007 | Every selected remediation item traces to a finding or existing candidate, has a lifecycle route and validation plan, and closes with evidence or an explicitly approved exception. | Configurations affected by each selected change | Final selected-work list and refined criteria before scope approval; governing contract/plan links; focused checks and appropriate profile gates; resource/parity evidence where affected; deferred records for valuable unselected work. |

## Dependencies and Open Questions

- Existing architecture and Signal Analyzer features are registered as
  `implemented`; these post-MVP candidates do not reset their lifecycle stages
  or amend their authoritative artifacts.
- Which dependency issues remain after SPEC-001 Milestone 10, rather than
  repeating completed cleanup?
- What exact generated files, scripts, ordinal mappings, and fixtures belong
  to the hierarchy replacement? What derivation cost is acceptable?
- Which conditionals can be removed mechanically, and which require a durable
  architectural choice? Is a residual-guard list acceptable?
- Five seconds is a proposed retention horizon, not a new workload duration:
  distinguish it from the existing 30-second sustained-acquisition validation.
  Capacity, boundary-event policy, snapshot/model stores, host budgets, and
  cross-references must be reviewed together.
- What concrete cost/resource thresholds make the nRF hierarchy candidate
  acceptable? Investigation may recommend retaining the existing approach.
- Which audit findings become selected remediation, which require upstream
  decisions, and which are deferred? Settle the required validation matrix
  before approving this scope revision.

## Deferred and Follow-up Work

- [FW-029](../future-work/fw-029-reduce-source-conditional-compilation.md)
  supplies conditional-removal candidates. Scheduling this draft supplies
  context for re-evaluation; it does not promote the item or approve changes.
- [FW-028](../future-work/fw-028-embedded-owner-partitioned-output-diagnostics.md)
  remains a separate compiler/linker question; it is not the hierarchy removal.
- [FW-027](../future-work/fw-027-pi-performance-investigation-resumption.md),
  [FW-032](../future-work/fw-032-nrf-performance-improvement.md), and
  [FW-033](../future-work/fw-033-connected-validation-follow-up.md) retain
  their own revisit triggers and dispositions.

## Revision and Approval History

| Revision | Date | Change / reason | Maintainer approval |
| --- | --- | --- | --- |
| 1 | 2026-10-04 | Initial candidate scope from recent discussions and the maintainer's two-iteration outline; refined with a bounded audit, findings-selection process, and evidence-first nRF investigation. | Scope approval pending; maintainer requested these draft-document updates. |

## Closure and Follow-up

Not started. At closure, record every criterion's disposition, evidence,
approved exceptions, and remaining deferred work.

## References

- [ITERATION-001: GiftUI MVP](iteration-001-mvp.md)
- [Codebase Review Process](../engineering/CODEBASE_REVIEW.md)
- [ADR-003: Transition-Based Bounded Capture](../adrs/adr-003-transition-based-bounded-capture.md)
- [ADR-007: Integration Ownership and Host Composition](../adrs/adr-007-integration-ownership-and-host-composition.md)
- [ADR-008: Module Dependency Graph and Package Topology](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [SPEC-002](../specs/spec-002-portable-foundation.md)
- [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md)
- [SPEC-013](../specs/spec-013-runtime-profiles.md)
- [SPEC-015](../specs/spec-015-host-configuration.md)
- [SPEC-001 implementation plan](../implementation-plans/spec-001-implementation-plan.md), Milestone 10.
- Discussion provenance: “Plan MVP Cleanup Iteration” (`01a0fd70-a61c-7b43-9eb0-28ac915ee793`), “Review module dependency direction” (`01a0f92f-f02e-7a53-99d0-5f3bc8e3a546`), “Explain Static nRF Stack Hierarchy” (`01a0fb90-48f5-7d63-ad19-d7af9457368b`), “Assess Removing Project-wide ifdefs” (`01a0fcf0-fa50-75e2-835f-3105c62b284d`), and “Assess 10 Hz Input Frequency Limit” (`01a0fd19-a846-7a12-a9b6-1e50a84c13a1`).
