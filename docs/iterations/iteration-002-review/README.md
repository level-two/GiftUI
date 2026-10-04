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
| 01 — Dependencies and ownership | [Graph, source checks, and firmware composition](01-dependencies.md) | Structural pass recorded; detailed responsibility review remains |
| 02 — Interfaces, types, and mappings | [Selected seams, reproduction, and simplification candidates](02-interfaces-and-mappings.md) | Targeted pass recorded; complete module review remains |
| 03 — Requirements, flows, profiles, and tooling | [Traceability, selected flows, fresh guards, and tooling findings](03-requirements-flows-and-tooling.md) | Targeted pass recorded; full behavioral/profile review remains |
| 04 — Reconciliation | [Recommendations and remaining bounded review tasks](04-reconciliation.md) | Initial findings reconciled; full audit and final selection remain open |
| 05 — Portable/application review | [Owner boundaries and terminal startup reproduction](05-portable-and-application.md) | Recorded |
| 06 — Semantic/layout/render/drawing | [Owner contracts, lifetimes, capacity, and rollback](06-semantic-layout-render-drawing.md) | Recorded |
| 07 — Execution/observable/runtime | [Input, replacement, failure, and quiescence flows](07-execution-observable-runtime.md) | Recorded |
| 08 — Backend/host/platform | [Responsibilities, policy, and transfer/input lifetimes](08-backend-host-platform.md) | Recorded |

[Findings register](findings.md) records confirmed observations separately from
hypotheses and preferences. A step's completion does not imply every module or
acceptance criterion passed. See coverage for exact reviewed areas and gaps.

The initial passes found one reproduced interaction capacity defect, two
tooling/process defects, two supported simplification candidates, and one
deferred performance hypothesis. Read the register's counterevidence and
validation bounds before selecting fixes. The complete all-module audit is
still in progress; [Step 04](04-reconciliation.md) defines the remaining tasks.

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
