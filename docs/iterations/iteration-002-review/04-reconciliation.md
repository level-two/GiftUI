# Step 04 — Initial Findings Reconciliation

Date: 2026-10-04. Source baseline:
`6cf31f266987e917458f31f05ed8c390cda9a202`.
This reconciles the initial targeted passes. The complete audit and final
ITERATION-002 selection are still open; neither scope approval nor implementation
authorization is inferred.

## Recommended selection

| Finding | Proposed disposition | Bounded outcome | Affected configurations / validation | Route |
| --- | --- | --- | --- | --- |
| CBR-001 | Recommend correction first | Preflight every interaction staging/commit store; capacity shortage receives the contracted contained result | Shared interaction state, Static/Dynamic storage arrangements; independent undersized stores, exact capacity/first excess, error precedence, retained commit, discard/reuse; affected profile gates | Maintenance within SPEC-011/013; amend contracts only if desired behavior changes |
| CBR-004 | Recommend tooling correction | Isolate each aggregate runner invocation and retain an attributable ledger | Every test profile; same-selection overlap/interruption/failed-run fixture, exact child run IDs, latest publication, one ordinary integration gate | Tooling maintenance |
| CBR-006 | Recommend tooling alignment | Support documented deferred-source repository paths without weakening authority checks | Governance tool tests for IDs, paths, mixed sources, missing/unsafe paths, unknown IDs; governance gate | Existing Documentation Rules |
| CBR-003 | Needs focused coverage assessment | Determine whether startup validation can use common Layout and remove duplicate rules | nRF Static and host rehearsal; preserve codec/startup negatives, common text corpus, build/ABI and resource evidence | Maintenance if behavior/bounds stay fixed; upstream review otherwise |
| CBR-002 | Needs investigation; refine existing hierarchy candidate | Compare runtime derivation and generated stable-role binding; recommend an approach from evidence | nRF Static with desktop parity; scope/identity/action/text/style/failure parity, reproducible generation, flash/RAM/stack/heap and derivation cost | Exploration/Spike before promising a replacement; normal architecture/contract gates |
| CBR-005 | Deferred, FW-032 | Preserve repeated lookup hypothesis for phase profiling | Identified target firmware; per-phase measurements/call counts before choosing optimization | Existing performance follow-up; outside automatic cleanup selection |

CBR-002 and CBR-003 both concern target-host maintenance, but have distinct
consumers and validation obligations. Do not merge them into a blanket deletion
of generated or embedded code. CBR-004 and CBR-006 concern evidence tooling,
not the production architecture. CBR-001 is the only reproduced reusable-state
correctness defect in these selected source seams; standard production
reachability is not established.

The graph and firmware-boundary checks found no current forbidden dependency
or erased owner boundary. Completed Milestone 10 cleanup should not be scheduled
again. A passing graph still leaves responsibility placement and encapsulation
to inspect. No architectural defect has been established merely from target,
type, mapping, or directive counts.

## Existing candidate scope

- **Dependencies:** retain the responsibility/interface review; do not commit to
  graph changes before a concrete finding identifies the misplaced owner.
- **nRF hierarchy:** CBR-002 supplies specific manual bindings/generation coupling
  to investigate. Define the exact files and acceptable cost thresholds before
  measuring alternatives. Retaining the current packed design is a valid result.
- **Conditionals:** the baseline has 59 opening Swift `#if` directives, including
  generated and inactive paths. Classify each guard by purpose/source selection
  before selecting removal. No zero-directive target or mechanical mass removal
  is justified by this count.
- **Capture retention:** the draft five-second horizon requires accepted ADR-003
  and capture/host contract amendments. Review cutoff/baseline/equal-time ordering,
  producer limits, every simultaneously live store, overflow/resource budgets,
  and all 1/2/5-second windows. Keep the sustained-load validation duration intact.

## Next bounded review tasks

Use the [module inventory](evidence/modules.tsv) and [coverage](coverage.md) as
the work queue; inspect each owner with its immediate producers/consumers. For
each task, append source/contract evidence, update coverage, reconcile IDs, and
commit the results. Full coverage is a prerequisite for declaring the audit
complete, not for preserving these initial findings.

| Task | Boundary / governing contracts | Questions and required output |
| --- | --- | --- |
| Portable declarations and application | GiftUI, Domain/Data/Presentation; SPEC-001/002/006/010/012 | Exposure, declaration-to-semantic mapping, capture/snapshot identity and updates, authoritative versus duplicated model state; source-backed per-module dispositions |
| Semantic, text, layout, render, drawing | SPEC-005/006/007/008/012 | Borrow/resource lifetime, invalid IDs/geometry, adapter necessity, shared-algorithm parity, partial failure and cache ownership |
| Execution, observable, interaction, runtime | SPEC-009/010/011/013 | Trace complete input/action and failure/recovery flows, candidate/committed lifetimes, readiness/capacity preflight, stale identities, exact contained results in each owner |
| Capabilities, failures, backend/display/raster, platform/host | SPEC-003/004/014/015 and ADR-007/008 | Policy versus mechanics, external/internal failure propagation, producer refusal and release, profile/host coupling, raw storage exposure |
| Tests, generation, operational entry points | Owner Specs; root package, separate demo and probes | Independent oracles, exact production joins/input closure, stale source lists, reproducibility, negative/resource guards, current evidence identities |
| Hierarchy feasibility | Existing draft investigation candidate | Agree questions/thresholds, record Exploration/Spike if undertaking experiments, measure bounded alternatives and give a disposition |

Do not repeat a generic whole-repository sweep as a substitute for these tasks.
Missing full-profile/connected proof remains an evidence gap until tested under
the required authorization; it is not automatically another implementation bug.

## Verification and disposition

Fresh checks recorded so far: exact dependency/source-boundary guards,
SPEC-002 macOS Dynamic driver, 17 interaction XCTest plus three Swift Testing
cases, the unchanged-source capacity reproduction, three generator freshness
checks, and five selected structural guards. Governance and whitespace/link
checks cover these research documents. No new all-profile conformance gate,
firmware deployment, flashing, or connected campaign was performed.

Production source, package/build scripts, and maintained tests remain unchanged
from the source baseline. Future source changes should have separate commits
and evidence tied to selected findings. ITERATION-002 remains draft, and IT-AC-006
is not marked complete while planned coverage is still open.
