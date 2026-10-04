# Step 01 — Dependencies and Ownership

Source baseline: `6cf31f266987e917458f31f05ed8c390cda9a202`.
Checks executed at the documentation-only baseline commit `9d87ae53`.
Authority: accepted ADR-005/007/008 and the owner contracts in SPEC-001/002,
003/004/005/006/007/008/011/013/015.

## Results

The fresh exact-target/edge checker passes for all 84 targets and 375 internal
edges. The source-import inventory reports no missing direct internal edge.
Existing focused dependency/source-boundary checks for SPEC-001/003/004/005/
006/007/008/011/013/015 pass. See the complete
[command/result ledger](evidence/01-checks.json), including unsuccessful attempts.

The full `run-spec-002.sh --profile macos-dynamic` contract driver also passes,
including its correctly invoked interface/dependency boundary check. Immutable
run ID: `9d87ae53252e59c937643addea0a2b05deffe298-9b9b65db77b5280e`.
Local report: `.build/contract-reports/spec-002/<run-id>/macos-dynamic/`.
This is fresh macOS contract evidence, not a new four-profile or connected gate.

An initial direct SPEC-002 boundary invocation omitted its five required input
files; that is a review invocation error, not an implementation failure.
SPEC-007's checker initially hit a compiler-cache sandbox denial and passed
on the authorized retry with cache access. Neither failed attempt is hidden or
classified as a product defect.

## Firmware composition

The [CMake owner loop](../../../firmware/nrf52840/applications/signal-analyzer-static/CMakeLists.txt)
at lines 266–360 compiles lower-owner fragments into separate Swift modules,
with separate module directories and transitive dependency visibility. Only
`SignalAnalyzerTargetHost` fragments are combined in the composition root.
The old concern that all firmware sources erase compiler-visible ownership was
already addressed in SPEC-001 Milestone 10; do not repeat that cleanup.

The selected-source inventory finds no unavailable imported owner or import
outside its manifest direct-edge set. None of the four package executables'
dependency closures reaches a regular target named `*Fixture`. See
[composition evidence](evidence/01-composition.json). This does not classify
every recording/helper implementation as test-only; names alone are insufficient.

CMake and native rehearsal derive dependency visibility from current source
imports. That alone is not an independent ownership policy. Counterevidence:
the exact package/source allow-list checks inspect maintained sources, including
embedded fragments, and the nRF driver runs three actual-invocation import
negatives through `check-spec-001-nrf-owner-isolation.py`. Therefore no new
ownership defect is asserted from automatic import collection alone.

## Scope of the conclusion

No forbidden current import, cycle, fixture-target dependency in executable
closure, or erased lower-owner compiler boundary was found in this structural
pass. This is not proof that all responsibilities and exposed values are placed
well. Inspect interfaces, representations, and producer/consumer behavior next.

The separate `demo/SignalAnalyzer` package is a SwiftUI macOS investigation,
with its own Domain/Data/Presentation implementations. It is outside the root
manifest and is not evidence that the current GiftUI reference executable uses
SwiftUI. Its README and build entry points need a documentation/tooling review
to prevent confusion between the investigation and the production GiftUI stack.

The earlier inventory counted all artifact ID mentions in acceptance sections.
It now counts only checklist criterion declarations, including SPEC-003's
two-digit IDs. This correction affects inventory evidence only.

## Remaining checks

- Re-run actual nRF compiler isolation/build evidence only when needed for a
  selected source-selection change; it was inspected but not executed here.
- Detailed responsibility review, including host concentration and internal
  value exposure, remains open even though graph guards pass.
- Classify external demo/probe entry points and their evidence roles.
