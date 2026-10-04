# Step 03 — Requirements, Selected Flows, and Tooling

Date: 2026-10-04. Source baseline:
`6cf31f266987e917458f31f05ed8c390cda9a202`; traceability inventory taken at
`1eb49235a2d358f6cc26a5968ae7db18eaf88318` (research-only changes since baseline).

## Requirement traceability and evidence limits

[Criterion inventory](evidence/03-criterion-coverage.tsv) finds 240 acceptance
criteria across all fifteen implemented Specs and no missing corresponding
conformance table entries. Reproduce from the repository root with
`python3 docs/iterations/iteration-002-review/criterion-inventory.py`.
Hashes identify the exact Spec/report texts. This is a navigation check:
recorded table labels are historical text, not fresh passed criteria.

The latest disposition and explicit approval in the
[closeout packet](../../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md)
qualify earlier table results/open gates. Read the exceptions and artifact/input
identity, not only a `pass` label or the most recent document date. In particular,
SPEC-001/011/015 implemented transitions preserve timing and connected-evidence
exceptions. The research does not reset lifecycle statuses by inference.

CBR-001 demonstrates why these reports are not proof over every admissible
storage arrangement: SPEC-011 IN-008/IN-009 historical evidence covers its corpus,
while the new independently undersized staging buffer exposes omitted preflight
and stronger-than-required failure classification. Link its reproduction and
extend the corpus when correcting it; do not rewrite historical runs as failures.

## Selected production flow and lifetime inspection

Inspected `Sources/GiftUIRuntimeCore/RuntimeCompletePipeline.swift` together with
the nRF `StaticSignalAnalyzerCommonOwner` in
`firmware/nrf52840/applications/signal-analyzer-static/src/StaticPreset.swift:2642`.
The current firmware calls the common pipeline at line 3350. Its ordered joins
are admission/seal → mutation → freeze → observable/semantic derivation → layout
→ Canvas/plan → combined render preflight → interaction candidate → semantic/
observable publication → candidate allocation → offer/production.

The source carries mutation progress separately from successful publication.
Before publication, failures retain acquired-resource cleanup obligations;
after publication, the published revision is a distinct fact even if offering
fails. The firmware joins common Layout and bounded Canvas derivation, clears a
failed semantic candidate, checks callable release, and only clears model dirty
state on publication. These are legitimate semantic distinctions; collapsing
result types or revisions by name/count alone could lose them. This inspection
does not prove every owner implementation or injected failure path.

The ordinary capture store and nRF packed history preserve stable insertion,
cutoff baselines, and bounded retained history. Their representation costs
differ. The draft five-second retention change reaches domain constants, both
store realizations, live/snapshot/publication lifetimes, profile budgets, and
contract fixtures; it is not a one-line literal replacement. It requires the
already identified ADR/Spec amendments. The existing 30-second sustained-load
workload remains distinct from retention length. No new capture inconsistency
is asserted from the inspected paths.

Packed identity scans are a profiling hypothesis (CBR-005), not a demonstrated
cause of target cadence failure. The current cleanup scope excludes automatic
performance work; the existing FW-032 now preserves this evidence and its trigger.

## Fresh structural checks and test tooling

[Check ledger](evidence/03-checks.json) retains exact commands, outputs, and exit
codes. All eight intended checks pass after the three generator commands were
correctly invoked through Ruby. Their initial direct invocations returned 126
because those generator files are not executable; this is a command invocation
mistake, not a product defect or an approval rejection.

| Fresh check group | What it establishes | What it does not establish |
| --- | --- | --- |
| SPEC-015 workload, SPEC-001 nRF font and Canvas-table `--check` | Checked-in outputs match these generator inputs | Hierarchy generation cleanliness or target behavior |
| SPEC-009 pending and render/offer mapping checks | Expected source fragments, forbidden surfaces, and test/oracle presence | Execution of every mapping/failure path |
| SPEC-013 storage boundaries, registry, migration | Required inventory/fixture/source relationships remain present | New four-profile limit behavior or measured target costs |

The Step 02 interaction suite separately executed 17 XCTest and three Swift
Testing cases. Neither that suite nor these lexical guards is a full repository
or all-profile conformance gate. Historical 72-check closeout results remain
historical. The dependency pass's fresh SPEC-002 macOS Dynamic driver is separately
identified in Step 01.

CBR-004 identifies aggregate runner report/caches shared by selection. The
historical closeout confirms real overlap; no destructive concurrent runner
experiment was performed. Per-contract PID staging/input-identity publication
(for example `scripts/contracts/run-spec-013.sh:78`) provides a pattern worth
reusing. Do not conflate immutable child evidence with an isolated parent ledger.

CBR-006 records a process/tooling inconsistency encountered during deferred
capture: the documented repository-path `source` form fails ID-only authority
graph validation. Its [failed invocation](evidence/03-governance-source-case.json)
is retained; body/References links and existing Spec source IDs preserve this
review's provenance after removing the unsupported path from metadata. No
validator or authority rule was changed during research.

## Remaining coverage

This targeted source/evidence pass is not an all-criterion conformance review.
Remaining work includes all-module producer/consumer responsibility checks,
complete input/action and failure/recovery flows, malformed/boundary cases in
each owner, all target/profile realizations, external demo/probe paths, and
measured hierarchy feasibility. See [coverage](coverage.md). Connected timing,
input, and recovery evidence remains under its existing exceptions and deferred
work; no connected execution was performed or requested here.
