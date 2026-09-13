# SPEC-012 Milestone 7 — Startup and Failure Integration

SPEC-015's generated schema-2 presets now provide the exact B2 Drawing facts,
complete runtime limits, combined render capacity, static callable metadata,
and independent raster capability requirement consumed by startup validation.

`SignalAnalyzerDrawingStartupValidation` checks every nonzero workload fact,
the four render-workspace source/limit relations, Drawing/workspace bounds,
checked `ordinary + stroke` capacity, and exact Dynamic/Static callable and
capture rules before capability resolution. The generated preset tests cover
all four successful profiles plus each zero fact, first Canvas excess, static
capture mismatch, and profile mismatch. Capability requirements carry all five
operation bits and no Drawing storage capacity.

`GiftUIDrawingFailureAdapterFixture` now maps all nine
`DrawingProductionError` cases plus offer-time idle refusal and combined-stream
invariant failures to their exact SPEC-003 facts. Derivation and offer-time
failures remain distinct.

Reproduction:

```sh
ruby scripts/contracts/check-spec-015-generated-workload.rb
swift test --filter GiftUIHostConfigurationTests
swift test --filter DrawingFailureAdapterTests
```

T7.4 cycle disposition remains assigned to the common SPEC-013 pipeline slice.
