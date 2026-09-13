# SPEC-014 T7.4 Endpoint Health and Diagnostic Isolation

Date: 2026-09-13

`OneShotRasterBackendEndpoint.health()` asks its session sink for the
authoritative target-owned value on every call. It retains no health snapshot
and does not reconstruct state from local raster or display errors. A
reference-backed test target changes health after endpoint construction and
proves that unavailable and quiesced states are immediately observable.

Display Core's responsibility tests separately prove that the first accepted
transport failure records one unavailable component fact, while an invariant
failure records one quiesced runtime fact. Both paths finish the display
session exactly once; later failures do not create a second responsibility or
health update.

Endpoint tests run the same successful offer with diagnostics omitted and
fully selected. The shared execution diagnostic-isolation suite supplies the
saturated, dropped, and failing modes. Across all modes, output, logical
result, capability values, health authority, body-call count, and input
eligibility are unchanged.

Run from the repository root:

```sh
swift test --filter endpointProjectsLiveTargetOwnedHealth
swift test --filter diagnosticSelectionCannotChangeOfferOrHealth
swift test --filter ExecutionDiagnosticIsolation
swift test --filter DisplayResponsibilityTests
```

All focused tests pass.
