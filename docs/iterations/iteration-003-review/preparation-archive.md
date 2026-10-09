# Iteration 3 preparation archive

On 2026-10-09 Eugene authorized the archive-and-reconstruct proposal, including
replacement of published main, and requested minimal historical records only
where useful. His instruction was:

> let's move on with the proposed approach. replacing published main is ok in this case. also I think that minimal historical records are fine (in case they are sensible, if they introduce just noise then they should be avoided)

## Exact boundaries and recovery

- Archive branch and annotated tag: `archive/iteration-003-preparation-20261009`.
- Archived commit: `af5e9559ebf71446dbee4c3b1fcb2aae65a8f769`.
- Reconstructed baseline: `2d0367480b5bcf7a8c9dbf021d10e0d57dce80e2` (iteration-2 closeout).
- Published main before cleanup: `b42f213c8d6b21147bc8dfff4e3212da9539e68e`.
- Reconstruction replaces 167 preparation commits with coherent documentation
  commits. All maintained source, tests, scripts, package files, accepted ADRs,
  Specifications, architecture and conformance records match the baseline.

The tag and branch must be verified on the durable remote before replacing
published main. Local preservation is not a claim of completed remote backup.
The archive contains original successes, failures, approvals, source snapshots,
reproduction recipes and experiment budgets. Its work orders are historical,
not instructions to resume. No historical result is relabeled or approved.

Recover a file without checking out the experimental tree:

```sh
git fetch origin tag archive/iteration-003-preparation-20261009
git show refs/tags/archive/iteration-003-preparation-20261009:path/to/file
```

The exact original preparation path inventory is reproducible with:

```sh
git diff --name-status 2d0367480b5bcf7a8c9dbf021d10e0d57dce80e2 af5e9559ebf71446dbee4c3b1fcb2aae65a8f769 -- docs experiments
```

To identify which archived paths are absent from the reconstructed checkout:

```sh
git diff --name-status --diff-filter=D af5e9559ebf71446dbee4c3b1fcb2aae65a8f769 HEAD -- docs experiments
```

## Artifact disposition and ID reservation

RFC-013 remains an active draft summary with its original design history in the
archive. PROPOSAL-007 and its acceptance, iteration-3 revisions 3/4 and iteration-4
revision 1 approval provenance remain accessible from the active scopes.
Existing accepted architecture and implemented contracts remain authoritative.

SPIKE-015 through SPIKE-067 and FW-034 are preserved only in tagged history.
They are not current work orders or new delivery commitments. Their IDs remain
reserved permanently: the next Spike ID is SPIKE-068 and the next Future Work ID
is FW-036 (FW-035 remains in the active tree). RFC-013 and iteration IDs are not
reused. Earlier SPIKE-001–014 remain at the iteration-2 baseline.

The previous RFC candidate appendices, cumulative preparation checklists and raw
experiment directories are likewise archived. This one record replaces individual
placeholder files. [Reusable findings](preparation-findings.md) identify evidence
worth retrieving; [the current plan](memory-efficiency-plan.md) owns next actions.

This retirement is explicitly authorized by the instruction above and the
[documentation preservation rule](../../engineering/DOCUMENTATION_RULES.md).
It neither abandons the approved iteration commitments nor grants RFC, ADR,
Specification, implementation, resource-exception or hardware approval.

## Reconstruction validation

The cleanup passes `scripts/validate-governance.rb`, including authority-graph
and registered task-evidence checks, and `git diff --check`. Local links in
changed documents resolve. Both approved scopes retain their exact success
criteria, validation matrices and exclusions from the archived revision.
Maintained source, tests, scripts, package and accepted authority trees are
byte-identical to the iteration-2 closeout; runtime and hardware tests were not
rerun for this documentation-only reconstruction. The complete local recovery
bundle passed `git bundle verify`; remote archive verification remains a
separate prerequisite to replacing published main.
