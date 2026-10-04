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
| 01 — Dependencies and ownership | Package/actual-import and firmware composition review | Not reviewed |
| 02 — Interfaces, types, and mappings | Producer/consumer review of selected seams | Not reviewed |
| 03 — Requirements, flows, profiles, and tooling | Targeted contract/evidence and implementation checks | Not reviewed |
| 04 — Reconciliation | Findings, recommended selection, and remaining review work | Not reviewed |

[Findings register](findings.md) records confirmed observations separately from
hypotheses and preferences. A step's completion does not imply every module or
acceptance criterion passed. See coverage for exact reviewed areas and gaps.

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
