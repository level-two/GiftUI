# Step 00 — Review Baseline

Date: 2026-10-04. Reviewed source revision:
`6cf31f266987e917458f31f05ed8c390cda9a202`.

The initial commit includes all nine pending documentation files (iteration
registration/scopes, cleanup review process, and existing Future Work context).
The branch was created after that commit. The source working tree was clean
at review kickoff. Subsequent review commits change derived documentation and
research evidence, not production implementation.

## Authority and lifecycle

The [manifest](../../features.yaml) registers Signal Analyzer, MVP architecture,
capabilities, observable state, and Canvas as `implemented`; all fifteen
Specifications are `implemented`. Their accepted ADRs and approved contracts
remain the baseline. ITERATION-002 is draft and post-MVP. Read-only research is
authorized by the maintainer's request, without resetting those feature stages.

The [Spec inventory](evidence/specifications.tsv) records current hashes,
statuses, and acceptance-criterion IDs. Start dependency/ownership review with
ADR-005/006/007/008, SPEC-002, and the downstream owner contracts. Use
SPEC-001 for application joins, SPEC-013 for profile/storage seams, SPEC-014
for backend integration, and SPEC-015 for host composition. Consult the
specific owner contract before deciding that a type or mapping is redundant.

## Inventory

Fresh manifest evaluation and a tracked-source lexical scan found:

- 84 SwiftPM targets, 375 internal direct edges, and six external product edges;
  the manifest graph is acyclic.
- 381 Swift source files under package `Sources/` targets; 59 opening `#if`
  directives, including generated code and inactive paths.
- 172 explicitly selected Swift files from 24 owners in the nRF firmware CMake
  composition, including two resource-variable selections.
- No lexically observed internal module import lacks a direct declared edge.

These observations do not prove legal ownership, semantic equivalence, or
resource viability. Files declaring no imports can still contain macro/module
dependencies; target-closure and compiler checks remain relevant.

See [modules](evidence/modules.tsv), [sources and hashes](evidence/sources.tsv),
[edges](evidence/target-dependencies.tsv), and
[nRF selection](evidence/nrf-selected-sources.tsv).

## Existing evidence and exceptions

The [MVP closeout packet](../../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md)
records 72 hardware-free checks passing, 298 XCTest tests, and 1,160 Swift
Testing cases. These are historical results for the packet's recorded artifacts,
not new execution on this branch.

The [explicit closeout authorization](../../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md)
preserves timing and connected-validation exceptions. Known target limitations:

| Area | Historical observation | Continuing boundary |
| --- | --- | --- |
| Pi cadence | 0.72335 frames/s; measured updates 1.294–1.522 s | Four-frame/s requirement remains unmet; FW-027 |
| nRF cadence | Approximately 21 s between observed presentation revisions | Sustained timing remains unmet/unproved; FW-032 |
| Connected validation | Incomplete physical interaction/fault/recovery/full-trace corpus | FW-031/FW-033; no new deployment, flashing, reset, or connected test is authorized by this research request |
| nRF resources | Flash 275,600 bytes, RAM 191,104 bytes, heap disabled; startup/idle painted stack 19,480 / 27,648 bytes | Historical artifact and scenario only; not an exhaustive worst-case bound |

## Current verification and exclusions

At kickoff, `scripts/validate-governance.rb` and `git diff --check` pass.
`swift package dump-package` succeeds with cache-access warnings; no dependency
download, compilation gate, or hardware run was performed to obtain it.

Review maintained source/build/generation/test/script areas. Exclude third-party
implementation, toolchain binaries, ignored build caches, and disposable Spike
code from maintainability scoring; inspect their integration boundaries when
relevant. Historical evidence is context, not an implementation authority.

This is a baseline record, not a new all-Spec conformance report. Full
criterion-by-criterion revalidation and measured hierarchy-replacement
feasibility remain separate work.
