# Step 09 — Tests, generation, conditionals, and entry points

Reviewed 2026-10-04 against the unchanged production source baseline. The
[target review index](evidence/09-module-review.tsv) assigns all 84 root targets
to owner-boundary reviews or the test/fixture perspective. This is an explicit
coverage index, not a claim that every line or branch was manually verified.

## Tests and reference independence

The owner suites cover success, refusal, malformed identity, resource/capacity
failure, publication, discard, and reuse. Contract fixtures additionally cover
negative declarations/imports, exact source closure, ELF/ABI, forbidden symbols,
and resource bounds. Driver registries and criterion tables establish which
corpus is intended to provide evidence; lexical checks of test names alone do
not establish that those tests ran. Step 11 records the fresh aggregate gate.

`Tests/GiftUIRuntimeConformanceTests/ProfileDifferentialTests.swift` uses a
scripted pipeline owner returning stage outcomes and tiny fixture regions.
It tests shared control-flow, disposition, cleanup, and profile binding parity;
it does not independently validate every semantic/layout/raster algorithm.
`SignalAnalyzerDynamicSemanticJoinTests.swift` and
`StaticSignalAnalyzerNRFPresentationInputsTests.swift` exercise concrete joins,
compare common metrics and generated topology, and emit reference transcripts.
The contract driver's separately implemented comparisons and reviewed pixel
references supply additional evidence, with their documented authority bounds.
The CBR-001 asymmetric storage and CBR-007 synchronous-startup cases were absent
from existing tests. Passing that corpus cannot override their reproductions.

Failure-adapter fixture targets provide small owner-result mapping oracles.
Step 01 verified that no executable dependency closure includes these fixtures;
their number alone does not justify merging them into production owners.

## Generator and conditional evidence

The actual hierarchy updater was run twice in an isolated copy of its script,
fixture projections, and two generated outputs. Both outputs match the repository
and are idempotent: [hashed results](evidence/09-hierarchy-generator.json),
[reproduction](check-hierarchy-generator.py). Existing outputs are inputs to
this updater. It therefore establishes current freshness, not clean generation
from portable views, semantic completeness, or replacement feasibility.

[Guard dispositions](evidence/09-source-guards.tsv) classify all 59 opening
Swift guards in `Sources/` and five opening C guards in the production nRF
application's `src/`. Counts exclude C header include guards, test stub guards,
and other fixture applications. Diagnostics capacities, payload exclusions,
Static/Dynamic Canvas declarations, and Embedded arithmetic have contract or
resource purposes. File-level OS/Embedded guards are candidates for explicit
source selection; native rehearsal, cross-target closure, and negative-symbol
checks must be preserved. Instrumentation can be isolated only with equivalent
counter behavior and no production overhead. This is a justified residual list,
not authorization to remove any guard or evidence that file splitting is cheaper.

## Other maintained entry points

The separate `demo/SignalAnalyzer` package has seven targets and is a native
SwiftUI comparison application. It uses MainActor isolation and a timed mock
Task; the root portable/Embedded implementation has different runtime constraints.
Its current 17 XCTest cases passed using the repository SwiftPM helper and an
isolated scratch/cache root; zero Swift Testing cases were registered. Full
console evidence is retained with Step 11. This does not validate root GiftUI.

The macOS root executables invoke the preset hardware-free harness, the nRF
host oracle emits host evidence, and the Pi executable owns Linux device work
with a native rehearsal path. Their roles must remain explicit when comparing
build success with a physical UI run. The Pi toolchain probe establishes the
cross-compiler/ABI environment. The nRF `probe` and contract fixture applications
establish their named compile/link/resource facts, not connected application
behavior. The production firmware closure was reviewed separately in Steps 01–08.

Operational setup/doctor/build scripts retain paired pins and project-local
artifacts. Deploy and flash remain separate explicit actions. The aggregate
hardware-free gate does not authorize or perform either action. CBR-004's shared
aggregate report paths remain a tooling correction candidate; run one aggregate
invocation and preserve its ledger and raw logs before another invocation.

## Disposition

The test/generation/entry-point source review is complete at the stated
perspective. CBR-002 gains current freshness counterevidence; CBR-004 and CBR-006
remain confirmed tooling defects. No additional defect follows merely from test
quantity, source guards, fixture targets, or shared production comparisons.
Fresh gate outcomes and connected limitations are recorded separately.
