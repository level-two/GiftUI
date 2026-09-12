# SPEC-012 Drawing Plan Workspace Evidence

Plan task: `SPEC-012 T3.2`

`GiftUIDrawing` owns the exact `DrawingPlanView`, `DrawingPlanWorkspace`, and
`CanvasInvocationSource` package contracts. The nonfailing package
initializers for `DrawingPlanSummary` and `StraightLineStrokeHeader` preserve
every supplied field without attempting to validate or normalize producer
input.

The focused finite workspace fixture covers idle acquisition, active reentry
refusal, sealed publication, discard, reset, and reacquisition. Its published
view reports complete attempt totals, zero strokes for an admitted empty
Canvas, nil for non-Canvas identities, and nil at every count boundary. Eight
malformed candidates prove invariant rejection for duplicate and missing
Canvas identities, inconsistent summary and normalized-operation totals,
missing in-range point/subpath data, and subpaths outside their stroke's point
range. No failed or discarded candidate becomes accessible.

Reproduce from the repository root:

```text
swift test --filter DrawingPlanWorkspaceTests
scripts/contracts/check-spec-012-module-contract.rb
scripts/contracts/check-spec-012-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-012-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-012-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-012-value-profiles.sh --profile nrf52840-embedded
```

The four profile checks inspect the emitted package interfaces for the exact
constructors while retaining the established fixed-width value layouts.
Path mutation and snapshot population remain assigned to T3.3 and T3.4; this
task establishes their bounded publication contract and validation fixture.
