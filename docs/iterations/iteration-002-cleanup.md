---
id: ITERATION-002
title: Cleanup
status: draft
revision: 5
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
| nRF hierarchy tooling and optional role-binding cleanup | [EXP-001](../explorations/exp-001-nrf-hierarchy-derivation.md), [SPIKE-009](../spikes/spike-009-nrf-hierarchy-role-bindings.md), [SPIKE-010](../spikes/spike-010-bounded-declaration-traversal.md), [SPIKE-011](../spikes/spike-011-clean-topology-generation.md), [SPIKE-012](../spikes/spike-012-connected-hierarchy-costs.md), CBR-002; signal-analyzer | Retain packed runtime hierarchy. Consider clean topology generation using explicit codec templates/binding policy: both outputs and 42 semantic transcripts match, with zero linked flash/RAM delta. Optionally select named text/modifier roles at +192 flash / zero RAM. | Tooling maintenance preserves storage/runtime owners; integrate projection freshness, template/policy ownership and generator/profile gates. Full runtime replacement is outside this proposed cleanup scope; any later selection requires design, contract review, full parity and agreed resource/time budgets. |
| Move named source-selection guards into build selection | [FW-029](../future-work/fw-029-reduce-source-conditional-compilation.md), [Step 15](iteration-002-review/15-conditional-removal-candidates.md) | Consider 15 named Embedded-only whole-file guards plus one empty compatibility file; coordinate SwiftPM exclusion, CMake and native source lists. Keep the justified residual profile/resource/arithmetic/instrumentation/board guards. | Mechanical selection may be lightweight; profile behavior, declarations, ownership or resource changes need lifecycle review. |
| Five-second Signal Analyzer buffer | [Step 14](iteration-002-review/14-five-second-retention-impact.md); signal-analyzer | Consider 404 records per store and 5s retention. Resize live/model/admission storage together; measured nRF RAM changes from 191,104 to 95,104 bytes. Preserve 1/2/5s baselines, 10 Hz per-channel input and the 30s workload. | Amend accepted ADR-003 and affected capture/host contracts before implementation; migrate retained-history oracles separately from delivered-event counts and revalidate all profiles. |
| Callback-safe startup and interaction capacity | CBR-007 / CBR-001; Signal Analyzer Data and Interaction | Preserve terminal startup state and preflight every staged commit-store capacity with the specified contained failure. | Contract-preserving maintenance under SPEC-001/011/013; real-source and unequal-capacity reproduction cases plus failure/reuse and affected profile gates. |
| Evidence tooling integrity | CBR-004 / CBR-006 / CBR-008 | Isolate overlapping runner evidence; align documented source-path validation; report actual Pi cross-build and native compilers separately. | Tooling maintenance with overlap/path/configuration-identity regressions and retained failure reports. |
| Shared-engine startup text validation | CBR-003, [Step 13](iteration-002-review/13-startup-text-probe-assessment.md) | Retire duplicate startup text algorithms using the shared Layout owner. Isolated candidate saves 1,296 flash bytes at unchanged RAM. Preserve codec checks and migrate negative/overflow coverage. | Candidate maintenance under SPEC-001/007/013; startup/reuse/text corpus and firmware ABI/resource validation before production adoption. |

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

The maintainer authorized research kickoff on 2026-10-04. The
[review record](iteration-002-review/README.md) links the baseline, coverage
matrix, findings, and step results. This scope remains draft. Completion depends
on coverage and explicit finding dispositions,
not on repeated agent passes ceasing to produce suggestions. Discovery does not
automatically select remediation or expand an approved iteration.

The [updated research reconciliation](iteration-002-review/28-host-followup-reconciliation.md)
records eight findings, all bounded review perspectives, the passing four-profile
gate and completed bounded follow-up experiments/assessments. It recommends correctness and
evidence fixes first, then measured startup/source-selection cleanups and the
5s contract amendment; retaining the packed hierarchy is the current research
disposition. Clean generation is demonstrated with exact outputs/parity and
zero size delta; named roles are an optional smaller runtime cleanup. Actual-body
snapshot traversal compiles but lacks complete replacement parity and costs
an additive 34,184 flash bytes. Static inspection records explicit barriers to
a whole-stack bound. The authorized connected supplement records Pi 0.717fps,
nRF 21.2s median publication gaps and a 19,480-byte startup sentinel extent.
Candidate staging is 55.6ms packed / 54.3ms roles; partial counting is 6.26ms
with a 17,896-byte extent. Full physical/fault/sustained-load coverage remains
incomplete and no performance fix is selected. These are refined
candidates, not selected commitments, scope approval or criterion passes.

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
- Full runtime declaration replacement is excluded from this proposed cleanup
  revision. The bounded prerequisite experiment is evidence for future design
  selection, not an additional investigation commitment for this iteration.

## Success Criteria and Validation

These are provisional outcomes to refine before scope approval.

| ID | Observable result | Required configurations | Evidence / governing contract |
| --- | --- | --- | --- |
| IT-AC-001 | Numbered iteration records are registered, discoverable, and distinguish draft scope from approved commitments. | Repository documentation | Governance validation and iteration index; already established process plus these scopes. |
| IT-AC-002 | Selected dependency cleanup has explicit ownership and no forbidden imports or dependency cycles. | Affected modules and supported target builds, to be selected | Before/after dependency inventory, owner checks, and governing ADR-007/ADR-008/SPEC-002 criteria. |
| IT-AC-003 | Hierarchy research has an explicit disposition. Any selected clean-generation cleanup emits both outputs from empty directories, checks registered projection freshness and malformed inputs, preserves full semantic transcripts, and has no runtime algorithm/storage change. Any separately selected named-role cleanup preserves parity and stays within agreed costs. | nRF Static; native comparison/rehearsal; generator gate | EXP-001 and SPIKE-009/010/011/012 record negative direct-module results, snapshot prerequisite limits, named roles, clean generation, 42 semantic comparisons and linked costs. Step 20 records static stack proof barriers. Full runtime replacement is excluded from this draft revision; Steps 22–23 add bounded connected timing/sentinel observations; whole-program bounds and full connected parity remain unproven. |
| IT-AC-004 | Selected 15-file source-selection guards and the empty compatibility shell are removed coherently; justified residual guards remain documented. | SwiftPM native selections, nRF CMake and native rehearsal | Step 15 candidate list; manifest/source consistency, compile/behavior and resource checks; preserve profile exclusions and negative configuration tests. |
| IT-AC-005 | Approved 5s/404-record retention supports all 1/2/5s windows with correct left-edge levels and snapshot/replay behavior. | All analyzer configurations | ADR-003 and affected Spec amendments; cutoff/equal-time/404/405/clear/snapshot cases; three-store size, linked nRF memory and 30s sustained acquisition/publication validation. Step 14 is prototype evidence, not a production pass. |
| IT-AC-006 | The bounded audit records its baseline, all planned review perspectives, coverage and gaps, evidence-backed findings, and reconciled dispositions. | Maintained code/build/test areas across all four supported configurations | Linked baseline, coverage matrix, and findings register following the Codebase Review Process; governing requirements and known MVP exceptions; explicit evidence limitations rather than inferred passes. |
| IT-AC-007 | Every selected remediation item traces to a finding or existing candidate, has a lifecycle route and validation plan, and closes with evidence or an explicitly approved exception. | Configurations affected by each selected change | Final selected-work list and refined criteria before scope approval; governing contract/plan links; focused checks and appropriate profile gates; resource/parity evidence where affected; deferred records for valuable unselected work. |

## Dependencies and Open Questions

- Existing architecture and Signal Analyzer features are registered as
  `implemented`; these post-MVP candidates do not reset their lifecycle stages
  or amend their authoritative artifacts.
- Which dependency issues remain after SPEC-001 Milestone 10, rather than
  repeating completed cleanup?
- The hardware-free hierarchy investigations have dispositions. Select clean
  generation and/or named roles for production work; complete runtime
  replacement would require a separate scope/design and agreed budgets.
- Step 15 specifies 15 file-selection candidates and justified residual guards. Confirm that bounded outcome when selecting scope; all-directive removal is unsupported.
- Five seconds is a proposed retention horizon, not a new workload duration:
  distinguish it from the existing 30-second sustained-acquisition validation.
  Capacity, boundary-event policy, snapshot/model stores, host budgets, and
  cross-references must be reviewed together.
- If selecting named roles, what comparison budgets/resource evidence govern
  adoption? Clean-generation evidence has zero runtime size/algorithm delta;
  retain the packed representation in either case.
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
| 2 | 2026-10-04 | Incorporate Steps 13–16: measured startup/retention/guard/role candidates, direct-module negative result and refined bounded outcomes. | Scope approval pending; maintainer authorized remaining research and per-step commits. |
| 3 | 2026-10-04 | Incorporate Steps 18–21: actual-body snapshot prerequisite, complete clean topology generation, static stack stopping boundary; retain packed runtime and exclude full replacement from the proposed cleanup commitment. | Scope approval pending; maintainer requested remaining hardware-free research and explicitly kept connected work deferred. |
| 4 | 2026-10-04 | Incorporate Steps 22–24: authorized connected baseline/candidate costs and restoration; preserve performance/full-corpus gaps and retain packed runtime. | Scope approval pending; maintainer authorized hardware measurements/experiments, not production selection. |

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

## Focused connected follow-up — revision5

The continued research request adds [Step25](iteration-002-review/25-quiescent-software-input.md)'s
production software-input subset and [Step26](iteration-002-review/26-connected-nrf-phases-and-failure.md)'s
actual-owner phase/refusal observations. nRF layout/production dominate; this
localizes future performance investigation without selecting an optimization or
runtime replacement. Programmatic Clear/diagnostic and one refusal/fresh-activation
case are scoped supplements to existing connected exceptions.

[Step27](iteration-002-review/27-pi-profiler-preparation.md)'s separate ARMv6
profiler is ready, but Pi connectivity blocks its measurement. Resume that
specific task when SSH is restored. Physical-contact provenance, complete
independent traces/pixels, other fault modes and lossless sustained admission
remain explicit follow-up gates. No generic audit pass remains necessary.

The recommended cleanup priority remains reproduced correctness and tooling
integrity, then supported startup/source-selection/generator cleanup. This
revision does not select fixes, approve scope, promise cadence remediation or
amend capture retention. `approved_revision`, approval, feature stages,
authoritative contracts and approved MVP exceptions remain unchanged.
