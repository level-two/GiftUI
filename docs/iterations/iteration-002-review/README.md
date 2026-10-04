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
| 10 — Hierarchy investigation | [Disposition and EXP-001](10-hierarchy-investigation-disposition.md) | Source assessment recorded; comparative feasibility remains open |
| 11 — Fresh hardware-free gate | [Validation and preserved report identities](11-fresh-hardware-free-validation.md) | 72 checks passed; 60 published report manifests verified |
| 12 — Final reconciliation | [Priorities, bounded outcomes, routing and remaining gaps](12-final-reconciliation.md) | Bounded audit concluded; implementation selection pending |

[Findings register](findings.md) records confirmed observations separately from
hypotheses and preferences. A step's completion does not imply every module or
acceptance criterion passed. See coverage for exact reviewed areas and gaps.

The bounded audit records two reproduced correctness defects, three tooling
defects, two supported simplification opportunities and one deferred performance
hypothesis. All owner groups have review dispositions and the hardware-free
gate passed across four profiles. [Final reconciliation](12-final-reconciliation.md)
prioritizes candidate fixes without selecting or authorizing implementation.
Comparative hierarchy feasibility and connected evidence remain explicit gaps.
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
