# SPEC-004 Capability Boundary Evidence

Plan task: `T0.4`

Date: 2026-08-30

## Compile fixtures

The ordered fixture manifest contains 15 checked-in cases:

- one positive external-client import of `GiftUICapabilities`; and
- one negative import for each of the 14 forbidden higher or concrete modules
  in `target-boundaries.yaml`.

The manifest checker fails duplicate IDs, invalid fields, missing files,
unregistered directories, and missing diagnostics. The driver fails unexpected
negative success or a missing fixed diagnostic. The macOS dynamic/static and
nRF Embedded profiles execute the complete ordered fixture set; the ARMv6
profile cross-builds the exact dependency-free library product.

## Source, compiled, and package boundaries

The boundary checks prove:

- `GiftUICapabilities` source and emitted interface contain no forbidden
  import or `@_exported import`;
- the compiler dependency scan contains no forbidden module;
- the emitted product links no forbidden GiftUI owner or concrete module;
- emitted `GiftUI` public/package interfaces neither import, re-export, nor
  reference `GiftUICapabilities`;
- the package target/product exactly match the checked-in capability boundary;
  and
- the complete package graph remains exact and acyclic.

Synthetic dependency cases prove unknown edges and cycles fail. The checked-in
forbidden imports prove unavailable upward modules fail rather than being
silently skipped.

## Portable Signal Analyzer scan

The scanner covers all Swift files under
`demo/SignalAnalyzer/Sources/SignalAnalyzerPresentation`. It rejects direct
capability imports and platform, backend, board, driver, controller, transport,
or device identity tokens. The current four presentation files pass with zero
identity branches. A checked-in `deviceID` regression fails with the expected
concrete-identity diagnostic, proving the scan is live.

## Validation

- all four exact `run-spec-004.sh` profiles passed;
- `check-spec-004-fixture-manifest.rb` reported 15 fixtures;
- `check-spec-004-portable-source.rb` reported four clean presentation files;
- `scripts/validate-governance.rb` passed; and
- `scripts/test.sh` passed with the registered SPEC-004 macOS-dynamic driver.

All evidence is hardware-free. No remote access, deployment, service restart,
or flashing occurred.
