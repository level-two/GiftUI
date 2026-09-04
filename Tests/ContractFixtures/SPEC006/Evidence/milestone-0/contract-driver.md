# SPEC-006 Contract Driver

Plan task: `T0.3`

Date: 2026-09-04

The registered driver exposes exactly the four required standalone commands:

- `scripts/contracts/run-spec-006.sh --profile macos-dynamic`
- `scripts/contracts/run-spec-006.sh --profile macos-static`
- `scripts/contracts/run-spec-006.sh --profile raspberry-pi-armv6`
- `scripts/contracts/run-spec-006.sh --profile nrf52840-embedded`

Each command verifies the SPEC-006 fixture schemas, pins the compiler, target,
SDK/board where applicable, and optimization identity inherited from SPEC-002,
compiles the current portable `GiftUI` and `GiftUISemanticCore` modules, runs
the initial import fixtures, hashes checked-in inputs and emitted modules, and
records every command plus the repository revision and dirty state.

Every report contains `required-evidence.tsv`. Until later tasks provide the
ordered semantic corpus, normalized results, allocation record, owned-value
layouts, summary counters, maximum observed depth, underscored-reference
inventory, and nRF ELF inspection, those rows are `missing` and metadata fixes
`evidence_complete=false`. The harness can pass without claiming conformance,
but its checker rejects an omitted row or a completed claim while any required
row is missing.

ARMv6 and nRF commands are hardware-free cross-build/inspection seams. Driver
metadata fixes remote access, deployment, service restart, simulator
execution, connected-target execution, and flashing to `false`.
