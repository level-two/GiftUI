---
id: ITERATION-002
title: Cleanup
status: approved
revision: 7
approved_revision: 7
created: 2026-10-04
updated: 2026-10-04
features:
  - giftui-mvp-architecture
  - signal-analyzer
  - capability-system
  - observable-reference-state
  - canvas-drawing
approval: "Eugene approved revision 7 on 2026-10-04: let's approve the scope of iteration 2, commit everything and proceed with the implementation plan derivation. Evidence: docs/iterations/iteration-002-review/32-scope-approval.md."
closure: null
---

# ITERATION-002: Cleanup

Eugene explicitly approved revision 7 on 2026-10-04 after the completed codebase
review and bounded hardware experiments. This is the delivery commitment under
[Numbered Iteration Scopes](../engineering/ITERATION_SCOPES.md).
[Approval provenance](iteration-002-review/32-scope-approval.md) preserves the
maintainer instruction. Scope approval does not approve an ADR or Specification
amendment.

## Goal

Make the existing Signal Analyzer and GiftUI implementation safer to maintain:
correct two reproduced lifecycle/capacity defects, make validation evidence
reliable, and remove demonstrated duplication and build/generation fragility.
Pursue the five-second capture-retention amendment as a separately gated memory
reduction. Preserve the portable presentation, existing module owners and
supported profiles.

This is post-MVP maintenance of the reference application and stack validated by
[ITERATION-001](iteration-001-mvp.md). All five participating features are
currently `implemented`; their lifecycle stages and approved MVP exceptions
remain unchanged by this scope. Capability, observable-state and Canvas behavior
participate in regression validation without introducing new feature work.

## Preparation Baseline

The [review record](iteration-002-review/README.md) covers Steps 00–30:
owner/dependency review, requirement and flow comparison, a four-profile
hardware-free gate, bounded cleanup prototypes and connected Pi/nRF measurements.
The [findings register](iteration-002-review/findings.md) contains eight findings.
No additional generic audit pass is a prerequisite to scope approval.

- Maintained source baseline: `6cf31f266987e917458f31f05ed8c390cda9a202`.
- [Step 11](iteration-002-review/11-fresh-hardware-free-validation.md): 72 checks
  passed across four profiles. This is historical baseline evidence, not a pass
  for the forthcoming changes.
- [Step 30](iteration-002-review/30-pi-aggregate-phase-comparison.md): bounded
  research is complete. Pi median pipeline is 1.381s in the quieter profiler;
  nRF publication remains about 21s. Performance and full connected conformance
  gaps remain open.
- Packed nRF runtime hierarchy is retained. Clean generation is supported;
  complete runtime declaration replacement is unsupported by the experiments.

## Included Scope

These are the approved selections for revision 7. Each local item ID remains
stable when implementation tasks are derived. None is implemented by research.

| Item / priority                                      | Source / feature                                                                                                                                                                                                              | Intended outcome                                                                                                                                                                                      | Lifecycle routing                                                                                                                                                                                                                          |
| ---------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| I2-01 / P1 — Callback-safe source startup            | [CBR-007](iteration-002-review/findings.md#cbr-007--terminal-callback-during-source-startup-is-overwritten); signal-analyzer                                                                                                  | Preserve a terminal failure raised during synchronous source startup, stop any partial source activation and avoid a subsequent running publication.                                                  | Lightweight correction within SPEC-001, including SA-AC-043; compare the corresponding target realizations.                                                                                                                                |
| I2-02 / P1 — Complete interaction capacity preflight | [CBR-001](iteration-002-review/findings.md#cbr-001--missing-staged-committed-action-capacity-preflight); giftui-mvp-architecture                                                                                              | Check every staged commit-store capacity before ready-for-offer; return the specified contained capacity failure and preserve committed state.                                                        | Lightweight correction within SPEC-011/013; no change to error precedence or commit/rollback contracts.                                                                                                                                    |
| I2-03 / P2 — Isolated test-run evidence              | [CBR-004](iteration-002-review/findings.md#cbr-004--test-runner-reports-are-shared-across-invocations); repository tooling                                                                                                    | Same-selection runs cannot erase/interleave reports or active scratch/cache state. Preserve each invocation and its child report identities, including failed/interrupted runs.                       | Tooling maintenance; isolated invocations or safe serialization, with a documented publication/retention policy.                                                                                                                           |
| I2-04 / P2 — Documented deferred-source paths        | [CBR-006](iteration-002-review/findings.md#cbr-006--deferred-source-paths-conflict-with-the-validator); repository tooling                                                                                                    | Accept valid repository source paths as documented while retaining strict artifact-ID authority relationships.                                                                                        | Governance-tooling maintenance within Documentation Rules; repository paths do not become authority nodes.                                                                                                                                 |
| I2-05 / P2 — Actual compiler identity in reports     | [CBR-008](iteration-002-review/findings.md#cbr-008--pi-compiler-metadata-describes-the-wrong-compiler); repository tooling                                                                                                    | Record the actual Pi cross-build compiler and paired SDK; distinguish the native-check compiler. Preserve accurate identities across other profiles.                                                  | Contract-driver metadata maintenance; historical reports remain immutable.                                                                                                                                                                 |
| I2-06 / P3 — Shared-owner startup text checks        | [CBR-003](iteration-002-review/findings.md#cbr-003--duplicate-text-layout-rules-remain-in-startup-validation), [Step 13](iteration-002-review/13-startup-text-probe-assessment.md); signal-analyzer / giftui-mvp-architecture | Retire duplicate startup text-measure/place algorithms after migrating their useful probes and negatives to the common Layout owner.                                                                  | Contract-preserving maintenance under SPEC-001/007/013. Changed startup semantics or resource bounds require upstream review.                                                                                                              |
| I2-07 / P3 — Explicit Embedded source selection      | [FW-029](../future-work/fw-029-reduce-source-conditional-compilation.md), [Step 15](iteration-002-review/15-conditional-removal-candidates.md); giftui-mvp-architecture                                                       | Remove exactly the 15 named whole-file Embedded guards and the empty font-raster compatibility shell. Coordinate SwiftPM, CMake and direct/native source selection; retain justified residual guards. | Mechanical maintenance within SPEC-013 and ADR-008. No new module boundary, profile semantics or runtime branch selection.                                                                                                                 |
| I2-08 / P3 — Clean topology generation               | [CBR-002](iteration-002-review/findings.md#cbr-002--hierarchy-dependent-model-projection-has-manual-ordinal-maps), [SPIKE-011](../spikes/spike-011-clean-topology-generation.md); signal-analyzer                             | Generate both current outputs from empty directories using fresh registered projections, explicit codec templates and binding policy. Remove dependence on previous generated output.                 | Tooling maintenance preserving runtime storage, algorithms and owners under SPEC-001/013. Retain specialized model policy; named runtime role bindings are not selected.                                                                   |
| I2-09 / P4 — Five-second capture retention           | [Step 14](iteration-002-review/14-five-second-retention-impact.md); signal-analyzer / giftui-mvp-architecture                                                                                                                 | Prepare/review the 5s/404-record retention amendment; after its approvals, resize live, model and admission stores together and validate equivalent visible behavior.                                 | Full upstream gate: reviewed RFC amendment, successor accepted decision for ADR-003, and approved affected SPEC-001/SPEC-015 amendments. Check SPEC-013 and derived plans/designs for affected resource assumptions before implementation. |

The dependency audit established an acyclic graph and no new wrong dependency.
Dependency/ownership integrity is an invariant for these selected changes,
verified under IT-AC-002; it does not create an open-ended module redesign task.
I2-08 improves generation reproducibility but does not claim to eliminate every
manual ordinal/model mapping in CBR-002. Record that residual explicitly.

## Delivery Order

These milestones express scope priority and dependencies, not a ready
Specification implementation plan.

1. **Correctness:** I2-01 and I2-02, with reproductions and focused lifecycle,
   capacity, failure and reuse checks.
2. **Evidence integrity:** I2-03 through I2-05. Establish runner isolation before
   overlapping aggregate validation; ensure subsequent integration reports carry
   accurate identities. Contract drafting for I2-09 may proceed independently.
3. **Supported simplifications:** I2-06 through I2-08 as separate reviewable
   changes with coverage/source/generation and paired resource checks.
4. **Retention:** I2-09 implementation only after its upstream approvals and
   ready plan. If approval is declined, record the criterion as unmet unless the
   maintainer explicitly amends this scope or approves an exception.
5. **Integration and closeout:** Run the final affected profile gates, publish
   fresh evidence, reconcile all selected findings and request iteration closure.

Commit each completed coherent step with its documentation and validation
results, as requested by the maintainer. A discovered architecture or contract
conflict pauses only the affected item and is routed upstream; independent
selected maintenance may continue within its authority.

## Exclusions

- Full runtime hierarchy replacement, removal of packed storage, stack reservation
  reduction, or a claim of a proven whole-program stack bound.
- Optional named role bindings from SPIKE-009/012. Revisit under
  [EXP-001](../explorations/exp-001-nrf-hierarchy-derivation.md) when a hierarchy
  change needs coordinated ordinal updates; current timing evidence does not
  establish an optimization selection.
- Pi/nRF performance remediation, identity lookup optimization (CBR-005), partial
  frames, cross-frame caches, endpoint bypass or new buffering policy. Preserve
  [FW-027](../future-work/fw-027-pi-performance-investigation-resumption.md) and
  [FW-032](../future-work/fw-032-nrf-performance-improvement.md).
- A campaign to close all outstanding physical-input, independent-pixel/trace,
  fault, overlap or sustained wall-time conformance gaps. Preserve
  [FW-031](../future-work/fw-031-macos-connected-pointer-validation-resumption.md)
  and [FW-033](../future-work/fw-033-connected-validation-follow-up.md).
  Focused connected regressions for changed owners remain included below.
- Package splitting, a new core-backend module and consumer-integration redesign:
  [ITERATION-003 draft](iteration-003-dev-ux-improvement.md), FW-016/FW-030.
- Universal guard removal, unrelated Canvas/resource generation changes,
  lower signal frequency, new navigation, new platform, or minimizing type/module
  counts without a demonstrated maintenance or correctness benefit.
- Reopening the completed generic audit or requiring every finding to be fully
  resolved to claim this bounded cleanup complete.

## Success Criteria and Validation

Existing IT-AC-001–007 IDs are retained and refined; IT-AC-008–013 cover each
selected correction explicitly. The table defines approved iteration exit evidence, not
new architecture or a substitute for governing acceptance criteria.

| ID | Observable result | Required configurations | Evidence / governing contract |
| --- | --- | --- | --- |
| IT-AC-001 | Numbered scopes remain registered and distinguish drafts from approved commitments. | Repository documentation | Iteration index and governance validation; existing process baseline, revised scope metadata and approval provenance. |
| IT-AC-002 | Selected changes preserve approved module ownership, declared imports, an acyclic graph and fixture-free executable closures. | All four supported configurations | Before/after dependency/source inventories and existing dependency gates under ADR-007/008 and SPEC-002; no new backend/platform leakage into portable presentation. |
| IT-AC-003 | I2-08 emits both complete topology outputs from empty directories, is deterministic/idempotent and checks registered projection freshness. Packed runtime representation and specialized binding policy remain. | nRF Static; native semantic comparison; generator gate | Two clean runs, exact output comparison, malformed/stale input refusal without partial publication, all 42 research semantic cases migrated into maintained validation, paired zero flash/RAM delta for the generator-only change; SPEC-001/013. Partial CBR-002 disposition identifies residual mappings and deferred roles. |
| IT-AC-004 | I2-07 removes exactly the 15 Step 15 outer guards and empty shell with coherent source lists; justified residual guards remain. | Both macOS profiles, Pi ARMv6 Dynamic, nRF Static and direct/native rehearsal | Manifest/source-list consistency and wrong-selection checks, affected builds/native behavior, paired unchanged nRF linked size for this mechanical change; SPEC-013. |
| IT-AC-005 | Following upstream approval, I2-09 retains 5s/404 records per store with correct levels/replay for every 1/2/5s view; all three physical stores change together. | All four analyzer configurations | Accepted successor decision and approved Spec amendments; cutoff/equal-time/404/405/clear/snapshot/eviction/reuse cases; unchanged 30s, 80-event/s delivered-event oracle with retained-history expectations revised separately; full-history left-edge oracle and presentation parity. Matched nRF store accounting demonstrates 96,000 fewer capture-storage RAM bytes; linked total and ABI/heap/stack gates pass. Connected workload limitations remain explicit. |
| IT-AC-006 | Completed research baseline, coverage, evidence and limitations remain discoverable without another generic pass. | Maintained code/build/test areas across all four configurations | Steps 00–30, coverage matrix, findings register and immutable archives under the Codebase Review Process. Connected observations remain distinct from complete conformance. |
| IT-AC-007 | All nine selected items trace to authority and fresh evidence; each criterion closes as met, unmet or a specifically approved exception. | Configurations affected by each selected change | Derived ordered tasks and validation mapping after scope/contract gates; final reconciliation, per-step commits, current report/artifact identities and deferred records. Human closure required; existing MVP exceptions are not expanded by inference. |
| IT-AC-008 | I2-01 preserves terminal failure during callback-capable startup and stops partial activation without duplicate ordinary running/failure publication. | macOS Dynamic/Static and Pi Data realization; nRF corresponding lifecycle regression | Real deterministic source at max/max-minus-one, callback then throw, successful Start/Stop/restart/Clear, terminal replay/rejection and host quiescence under SPEC-001/SA-AC-043. Do not presume the original host probe reproduced an nRF defect. |
| IT-AC-009 | I2-02 preflights candidate, staged committed, retained committed and hit capacities before publication; failure is contained and previous committed state survives. | Native Static/Dynamic interaction compositions; affected Pi/nRF gates | Independently undersized stores, exact bound/first excess, specified result/error precedence, no partial table/hit publication, discard/reuse and infallible ready-state commit; SPEC-011/013. |
| IT-AC-010 | I2-03 prevents same-selection invocation interference and retains failed/interrupted run evidence with exact child identities. | Repository runner | Cheap overlap/failure/interruption fixture proves isolated paths or safe serialization, cache/scratch protection and publication behavior; an ordinary affected gate exercises the real runner. Retention cleanup cannot erase an active run. |
| IT-AC-011 | I2-04 accepts documented source IDs/paths without weakening authority edges or path safety. | Governance tooling | Valid ID/path/mixed sources, unknown ID, missing file, escaping/unsafe path and reciprocal-link fixtures; graph retains artifact authority semantics; Documentation Rules. |
| IT-AC-012 | I2-05 reports actual artifact compiler/SDK separately from native checks. | All profile report variants, including Pi ARMv6 | Fixtures with different default/paired compiler versions; compare fresh metadata with actual build/toolchain identity and artifact/report links. Historical evidence is unchanged. |
| IT-AC-013 | I2-06 removes the two startup-only text algorithms while preserving useful startup/codec checks through common Layout. | nRF Static, native firmware rehearsal and shared Layout tests | Step 13 coverage migration: title/empty/CR/LF/wrapping/clipping/first-excess, invalid region/index/capacity, publish/readback/reset invalidation, failure cleanup and repeated startup. Paired flash does not grow and RAM does not grow; firmware ABI/heap gates and focused connected startup regression; SPEC-001/007/013. |

### Integration evidence boundaries

- Run focused regressions per coherent change; format maintained Swift with
  `scripts/format-swift.sh` before repository gates. Run the repository's full
  four-profile hardware-free gate on the final combined implementation; preserve
  immutable invocation/child reports rather than relabeling the research gate.
- Use supported ARMv6 Pi and Cortex-M4F hard-float nRF toolchains/build routes.
  For nRF changes report matched toolchain/configuration, linked flash/RAM,
  capture-region symbols, disabled heaps and unchanged stack reservations.
  Stay within the governing application RAM limit and other approved bounds.
  Experimental savings are comparison evidence, not an assumed combined result.
- For changed nRF startup/build/retention paths, collect a focused connected
  startup and Start/Stop/1/2/5s-window regression with identified artifact,
  fault/cleanup observations and capture/baseline evidence. For changed Pi
  acquisition/retention paths, collect a bounded production-loop regression with
  actual source/delivery observations and teardown. Neither substitutes for
  independent full pixel/physical-input validation.
- Keep the 30s/80-event-per-second workload and four-fps requirements intact.
  Separate deterministic/virtual-time delivery and history checks from connected
  wall-time performance. Unmet timing/lossless wall-time gates remain recorded
  under the existing approved exceptions and linked follow-up; a changed path's
  failure is not automatically covered by those exceptions.

## Dependencies and Open Questions

The remediation selection is approved; no further generic research is required
before plan derivation. The remaining gates are explicit:

1. Human approval of **ITERATION-002 revision 7** is recorded on 2026-10-04.
   It authorizes this delivery commitment and the requested plan derivation;
   architecture and contract amendments retain their separate gates.
2. Existing accepted ADRs and implemented Specifications govern I2-01–08;
   lightweight maintenance applies only while their contracts/owners/bounds hold.
   Any material divergence must receive lifecycle triage before affected code.
3. I2-09 depends on approved retention architecture and contracts. The 5s horizon
   is a product/architecture change from ADR-003's 30s history. Prepare the smallest
   coherent RFC amendment and successor ADR, then affected Specifications and a
   ready implementation plan. Do not edit accepted history into a new decision.
4. After scope approval, derive task ordering and evidence mappings under the
   governing Specs. This scope's milestones are not a replacement plan.
5. If hardware is unavailable at validation time, leave the focused connected
   criteria unmet and report the blocker; obtain an explicit scoped exception or
   amendment before closure instead of asserting hardware-free equivalence.

## Deferred and Follow-up Work

| Item | Current boundary / revisit trigger |
| --- | --- |
| [FW-029](../future-work/fw-029-reduce-source-conditional-compilation.md) | I2-07 selects only the named mechanical subset in this approved scope. Revisit remaining directives when new source-selection work touches them or a directive leaks platform/profile selection upward. |
| [EXP-001](../explorations/exp-001-nrf-hierarchy-derivation.md), [SPIKE-009](../spikes/spike-009-nrf-hierarchy-role-bindings.md), [SPIKE-010](../spikes/spike-010-bounded-declaration-traversal.md), [SPIKE-011](../spikes/spike-011-clean-topology-generation.md), [SPIKE-012](../spikes/spike-012-connected-hierarchy-costs.md) | I2-08 uses clean-generation evidence only. Revisit named roles on a coordinated hierarchy update; full replacement needs separately selected design, complete parity and agreed resource/time budgets. |
| [FW-027](../future-work/fw-027-pi-performance-investigation-resumption.md), [FW-032](../future-work/fw-032-nrf-performance-improvement.md) | Phase boundaries are measured; lookup contribution remains unisolated. Revisit in an explicitly selected performance iteration or a release-blocking responsiveness issue. |
| [FW-031](../future-work/fw-031-macos-connected-pointer-validation-resumption.md), [FW-033](../future-work/fw-033-connected-validation-follow-up.md) | Revisit for a selected connected-validation campaign or performance changes ready for sustained regression. Focused changed-path checks above do not close the full corpus. |
| [FW-028](../future-work/fw-028-embedded-owner-partitioned-output-diagnostics.md) | Separate compiler/linker diagnostics question; revisit when owner-partitioned output work is selected. |

No deferred artifact is promoted and no feature stage changes through scope approval.

## Revision and Approval History

| Revision | Date | Change / reason | Maintainer approval |
| --- | --- | --- | --- |
| 1 | 2026-10-04 | Initial discussion candidates and bounded audit/finding-selection process. | Pending; draft-document updates requested. |
| 2 | 2026-10-04 | Steps 13–16: measured startup/retention/guard/role candidates. | Pending; remaining research and per-step commits authorized. |
| 3 | 2026-10-04 | Steps 18–21: snapshot prerequisite, clean generation and static stack assessment; retain packed runtime. | Pending; hardware-free research authorized, connected work deferred at that point. |
| 4 | 2026-10-04 | Steps 22–24: connected baseline/candidate costs and restoration. | Pending; hardware measurements/experiments authorized. |
| 5 | 2026-10-04 | Steps 25–28: software-input subset, nRF phases/refusal, Pi preparation and reconciliation. | Pending; remaining research authorized; Pi connectivity blocked then. |
| 6 | 2026-10-04 | Steps 29–30: Pi resumption/comparison and SPIKE-013 closeout. | Pending; Pi measurements authorized after connectivity restoration. |
| 7 | 2026-10-04 | Replace the candidate collection with nine recommended delivery items, explicit priorities/gates, per-item exit evidence and deferrals. | Approved by Eugene on 2026-10-04: “let's approve the scope of iteration 2, commit everything and proceed with the implementation plan derivation. When finished - commit results as well”. [Provenance](iteration-002-review/32-scope-approval.md). Earlier preparation instruction and draft are preserved in commit `a6158904`. |

## Closure and Follow-up

Implementation has not started. At closure, record every criterion's
disposition and immutable evidence, finding outcomes (including partial CBR-002
remediation), unresolved contract/hardware gates, explicit exception provenance
and deferred revisit triggers. Record the maintainer's closure decision in
`closure`; preserve prior research and conformance history.

## References

- [ITERATION-001: GiftUI MVP](iteration-001-mvp.md)
- [Codebase Review Process](../engineering/CODEBASE_REVIEW.md)
- [ADR-003: Transition-Based Bounded Capture](../adrs/adr-003-transition-based-bounded-capture.md)
- [ADR-007: Integration Ownership and Host Composition](../adrs/adr-007-integration-ownership-and-host-composition.md)
- [ADR-008: Module Dependency Graph and Package Topology](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [SPEC-002](../specs/spec-002-portable-foundation.md)
- [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md)
- [SPEC-007](../specs/spec-007-layout.md)
- [SPEC-011](../specs/spec-011-interaction.md)
- [SPEC-013](../specs/spec-013-runtime-profiles.md)
- [SPEC-015](../specs/spec-015-host-configuration.md)
- [SPEC-001 implementation plan](../implementation-plans/spec-001-implementation-plan.md), Milestone 10.
- Discussion provenance: “Plan MVP Cleanup Iteration” (`01a0fd70-a61c-7b43-9eb0-28ac915ee793`), “Review module dependency direction” (`01a0f92f-f02e-7a53-99d0-5f3bc8e3a546`), “Explain Static nRF Stack Hierarchy” (`01a0fb90-48f5-7d63-ad19-d7af9457368b`), “Assess Removing Project-wide ifdefs” (`01a0fcf0-fa50-75e2-835f-3105c62b284d`), and “Assess 10 Hz Input Frequency Limit” (`01a0fd19-a846-7a12-a9b6-1e50a84c13a1`).
