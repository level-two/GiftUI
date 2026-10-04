# Final research reconciliation

Reviewed source baseline: `6cf31f266987e917458f31f05ed8c390cda9a202`.
Branch: `review/iteration-002-codebase-audit`. Production code, build scripts and
maintained tests are unchanged. Each review step has its own commit.

## Audit outcome and limits

The bounded source review covers dependencies, owner interfaces and
representative producer/consumer joins, types/mappings, requirements, update,
action, presentation, failure and cleanup flows, profile/resource boundaries,
and test/generator/entry-point roles. The
[84-target review index](evidence/09-module-review.tsv) and
[coverage matrix](coverage.md) make its perspectives explicit. The register
contains eight findings: two reproduced correctness defects, three tooling
defects, two supported simplification opportunities and one performance
hypothesis. Fewer types, targets, mappings or guards is not itself an outcome.

The [fresh gate record](11-fresh-hardware-free-validation.md) provides current
hardware-free corpus evidence across all four profiles. The
[240 criterion notes](evidence/11-criterion-review-notes.tsv) preserve historical
dispositions and link owner review perspectives. They do not independently
revalidate every criterion. CBR-001/007 challenge specific coverage despite
historical passes and must remain visible when planning correction tests.

Physical timing, pointer/display/input/failure validation and measured candidate
replacement feasibility remain explicit gaps. Existing exceptions under FW-027,
FW-031, FW-032 and FW-033 retain their original bounds. New correctness findings
are not absorbed into those exceptions. The audit can conclude with these
documented gaps; neither implementation nor iteration closure is complete.

## Recommended selection, requiring scope approval

| Order / candidate | Bounded outcome | Routing | Required validation |
| --- | --- | --- | --- |
| 1 — CBR-007 | Callback-safe startup preserves terminal failure, stops partial source activation and avoids subsequent running publication | Maintenance within SPEC-001; Data/source lifecycle owner | Real-source max/max-minus-one startup, callback then throw, normal Start/Stop/Clear/restart, exact publication and host quiescence; compare target realizations |
| 1 — CBR-001 | Check all staged commit-storage capacities before ready-for-offer and return the specified contained capacity failure | Maintenance within SPEC-011/013; Interaction owner | Unequal capacities, first failure and exact mapping, discard/reuse and committed-state preservation, standard host and affected profile gates |
| 2 — CBR-004 | Give each aggregate invocation isolated, retained logs/ledger/cache with safe publication or serialization | Test tooling maintenance | Two overlapping same-selection invocations cannot clear or interleave evidence; failed-run preservation and child-report identity |
| 2 — CBR-006 | Accept documented valid repository sources without weakening artifact-ID authority links | Governance tooling maintenance | Existing/missing/unsafe paths, valid/unknown IDs, mixed sources and reciprocal traceability |
| 2 — CBR-008 | Report the actual Pi cross-build compiler; name the native-check compiler separately | Contract-driver metadata maintenance | Compare emitted fields with paired compiler/SDK and artifact build output when default and paired versions differ; all profile report cases |
| 3 — CBR-003 | Replace duplicate startup text rules only after shared-owner probes preserve the old invariant/codec negatives | Target-host maintenance if contract unchanged; review resource consequences | Probe-to-common-engine parity, malformed/capacity cases, current startup paths, linked flash/RAM/stack before/after; no assumed savings |
| Investigation — CBR-002 / hierarchy candidate | Compare stable-role generation, complete offline projection and bounded runtime derivation; allow retain disposition | [EXP-001](../../explorations/exp-001-nrf-hierarchy-derivation.md); Spike after questions/budgets; upstream gates for contract changes | Actual declaration and normal/diagnostic/action parity; identical pinned firmware, ABI/heap/symbol/resource checks and agreed derivation costs |
| Deferred — CBR-005 | Measure lookup contribution before considering a bounded alternative | Existing [FW-032](../../future-work/fw-032-nrf-performance-improvement.md) | Phase costs/call counts, RAM/flash/stack and identity/pixel parity in the authorized performance work |

These are recommendations, not selected commitments. The findings register
records source locations, consequences, counterevidence and confidence.
Scope approval should choose bounded outcomes and their affected profiles;
public contracts, ownership, dependencies and material resource changes follow
the applicable lifecycle gates before implementation.

## Existing cleanup candidates

- **Dependencies:** The 84-target graph is acyclic with declared source imports
  and fixture-free executable closures. No new wrong dependency was demonstrated.
  Avoid repeating completed SPEC-001 Milestone 10 cleanup or merging independent
  owner/result contracts merely to reduce target count.
- **Conditionals:** [59 Swift and five production C guard dispositions](evidence/09-source-guards.tsv)
  separate file-selection candidates from profile declarations, instrumentation,
  resource exclusions, arithmetic and board configuration. Select specific
  removals and retain exact source/symbol/pixel/resource validation.
- **Hierarchy:** Source assessment is complete; comparative feasibility and
  IT-AC-003 remain open. Agree allowed deltas and derivation budgets before a
  candidate Spike. Keep production packed storage pending evidence.
- **Five-second retention:** Amend accepted ADR-003 and affected capture/host
  contracts before implementation. Account for all simultaneously live stores,
  boundary baselines/equal-time ordering, overflow capacities, resource limits
  and every 1/2/5-second view. Preserve the 30-second sustained-load validation
  workload and the existing per-channel input limit.

## Next transition

Use these recommendations to refine and approve draft ITERATION-002, then route
selected items to the required contract changes and implementation plan. The
remaining review gaps are comparative hierarchy evidence and connected evidence,
with explicit prerequisites; another generic source sweep adds no missing
decision or hardware proof. No approval or feature status was inferred.

Final [documentation/provenance QA](evidence/12-document-validation.json)
records governance, local-link and script parsing checks, archive hash
verification and preservation of all maintained source/test/build inputs.
