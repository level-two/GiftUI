# ITERATION-002 Codebase Review

Started 2026-10-04 under the maintainer's request to commit the workspace,
create a review branch, perform research, and commit each step's results.
Branch: `review/iteration-002-codebase-audit`.

This is a derived research record under the
[draft cleanup scope](../iteration-002-cleanup.md) and
[review process](../../engineering/CODEBASE_REVIEW.md). The scope remains
draft; research does not select or authorize implementation.

## Steps

| Step | Result | Status |
| --- | --- | --- |
| 00 — Baseline | [Baseline and limitations](00-baseline.md), [inventory evidence](evidence/inventory-summary.json), [coverage](coverage.md) | Recorded |
| 01 — Dependencies and ownership | [Graph, source checks, and firmware composition](01-dependencies.md) | Recorded; responsibility review completed in Steps 05–08 |
| 02 — Interfaces, types, and mappings | [Selected seams, reproduction, and simplification candidates](02-interfaces-and-mappings.md) | Recorded; expanded owner review completed in Steps 05–08 |
| 03 — Requirements, flows, profiles, and tooling | [Traceability, selected flows, fresh guards, and tooling findings](03-requirements-flows-and-tooling.md) | Recorded; expanded review and current gate in Steps 05–11 |
| 04 — Reconciliation | [Initial recommendations and work queue](04-reconciliation.md) | Historical initial pass; current disposition in Step 12 |
| 05 — Portable/application review | [Owner boundaries and terminal startup reproduction](05-portable-and-application.md) | Recorded |
| 06 — Semantic/layout/render/drawing | [Owner contracts, lifetimes, capacity, and rollback](06-semantic-layout-render-drawing.md) | Recorded |
| 07 — Execution/observable/runtime | [Input, replacement, failure, and quiescence flows](07-execution-observable-runtime.md) | Recorded |
| 08 — Backend/host/platform | [Responsibilities, policy, and transfer/input lifetimes](08-backend-host-platform.md) | Recorded |
| 09 — Tests/generation/entry points | [Corpus limits, updater freshness, and guard dispositions](09-tests-generation-and-entrypoints.md) | Recorded; current execution in Step 11 |
| 10 — Hierarchy investigation | [Disposition and EXP-001](10-hierarchy-investigation-disposition.md) | Initial question; bounded dispositions in Steps 16/18/19/23 |
| 11 — Fresh hardware-free gate | [Validation and preserved report identities](11-fresh-hardware-free-validation.md) | 72 checks passed; 60 published report manifests verified |
| 12 — Final reconciliation | [Priorities, bounded outcomes, routing and remaining gaps](12-final-reconciliation.md) | Bounded audit concluded; implementation selection pending |
| 13 — Startup text probe | [Measured shared-engine candidate and coverage migration](13-startup-text-probe-assessment.md) | Recorded; −1,296 flash bytes, unchanged RAM; production cleanup pending |
| 14 — Five-second retention | [Owner impact, behavioral prototype and linked costs](14-five-second-retention-impact.md) | Recorded; 96,000 bytes less RAM; contract amendments pending |
| 15 — Conditional removal | [15-file source-selection prototype and residual policy](15-conditional-removal-candidates.md) | Recorded; native/Embedded checks pass at unchanged linked size |
| 16 — Hierarchy Spike | [Direct-module failure and measured role-binding alternative](16-hierarchy-feasibility-experiment.md) | Recorded; retain packed hierarchy; smaller cleanup candidate |
| 17 — Follow-up reconciliation | [Prior candidate selection and readiness](17-followup-reconciliation.md) | Historical first follow-up round; superseded planning disposition in Step 21 |
| 18 — Declaration traversal | [Bounded actual-body snapshot prerequisite](18-bounded-declaration-traversal.md) | 42 cases/84 refusals pass; additive +34,184 flash bytes; full replacement remains unsupported |
| 19 — Clean generation | [Complete clean table emission and parity](19-clean-topology-generation.md) | Two byte-identical generations; 12 refusals; 42 semantic comparisons; zero linked size delta |
| 20 — Static stack assessment | [Addressed evidence and unresolved control-flow boundary](20-static-stack-assessment.md) | Inspection complete; indirect targets/metadata prevent a whole-stack bound; connected supplement in Steps 22–23 |
| 21 — Research closeout | [Completed queue and draft scope revision 3](21-research-closeout.md) | Hardware-free round concluded; connected supplement authorized afterward |
| 22 — Connected baseline | [Production timing, software action limits and painted startup](22-connected-baseline.md) | Pi 0.717fps; nRF 21.2s median publication gap; startup extent 19,480 bytes; full connected corpus incomplete |
| 23 — Connected candidates | [Calibrated on-board hierarchy costs](23-connected-hierarchy-candidates.md) | Packed 55.6ms, roles 54.3ms; counting 6.26ms/17,896-byte extent; replacement remains unsupported |
| 24 — Connected reconciliation | [Prior campaign disposition](24-connected-reconciliation.md) | Historical closeout; focused corpus/phase work resumed in Steps 25–28 |
| 25 — Quiescent software input | [Production service-boundary corpus](25-quiescent-software-input.md) | Start/Stop, windows, disabled Plus, movement and stale subset recorded; physical/full corpus separate |
| 26 — nRF phases/failure | [Actual-owner copied workload](26-connected-nrf-phases-and-failure.md) | Layout/production dominate; Clear/diagnostic and one pixel refusal/fresh activation recorded; no optimization selected |
| 27 — Pi phase profiler | [Verified preparation and resumption](27-pi-profiler-preparation.md) | ARMv6 build ready; connected measurement blocked by lost SSH connectivity |
| 28 — Follow-up reconciliation | [Results, restoration and remaining blockers](28-host-followup-reconciliation.md) | nRF research completed/restored; Pi profiler ready but connectivity blocks measurement; draft scope revision5 |
| 29 — Pi phase trace | [Resumed bounded measurement](29-pi-connected-phase-trace.md) | Connectivity restored; verbose phase/source/RSS trace recorded; quieter comparison pending |
| 30 — Pi accumulated counters | [Comparison and Spike closeout](30-pi-aggregate-phase-comparison.md) | Median1.381s; production/projection dominate; bounded research completed, original artifact unchanged |

[Findings register](findings.md) records confirmed observations separately from
hypotheses and preferences. A step's completion does not imply every module or
acceptance criterion passed. See coverage for exact reviewed areas and gaps.

The bounded audit records two reproduced correctness defects, three tooling
defects, two supported simplification opportunities and one deferred performance
hypothesis. All owner groups have review dispositions and the hardware-free
gate passed across four profiles. [Final reconciliation](12-final-reconciliation.md)
prioritizes candidate fixes without selecting or authorizing implementation.
Follow-up experiments in Steps 13–20 measure candidates and conclude with a
retain-packed-runtime disposition. Clean generation is demonstrated; full
runtime replacement is outside the proposed cleanup commitment. Connected work
was subsequently authorized for bounded measurements; [Step 22](22-connected-baseline.md) records fresh results and limits. [Step 30](30-pi-aggregate-phase-comparison.md) is the current
planning disposition and distinguishes remaining implementation gates from
completed investigation.
Read the register's counterevidence and validation limits before scope approval.

## Reproduce the lexical inventory

From the repository root, obtain fresh `swift package dump-package` JSON using
the repository's `scripts/lib/swiftpm.sh` helper and a project-local cache root,
then run:

```sh
python3 docs/iterations/iteration-002-review/inventory.py /path/package.json
```

The inventory uses tracked source paths and the current manifest. Its evidence
includes source/Spec hashes and the reviewed revision. Lexical counts include
generated code and inactive guards; they do not establish behavior, costs, or
conformance. Preserve a previous step's evidence before regenerating it for a
different code revision.
