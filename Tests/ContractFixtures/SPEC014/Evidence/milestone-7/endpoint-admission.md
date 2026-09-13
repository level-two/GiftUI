# SPEC-014 T7.1 Endpoint Admission Evidence

Date: 2026-09-13

The concrete generic endpoint rejects startup/configuration mismatch at
construction. For each offer it checks active state, exact provenance,
immutable descriptor/limit identity, and sink idle state before reserving the
configured payload-byte and region slot exactly once. Only a successful
reservation invokes the body, exactly once.

The four non-reserved results map to backpressure, retryable refusal,
non-retryable refusal, or contract failure exactly; display failure preserves
its local `DisplayTargetError`. Focused tests record every reservation and body
count plus exact reservation arguments.

The approved API supplies `RenderPlanHeader` only inside the body. SPEC-014
and its plan now state explicitly that the reserved sink validates exact header
work on its first `begin`, before surface/display mutation. This resolves the
previously impossible pre-body wording without changing ADR-010 or SPEC-009.

Run from the repository root:

```sh
swift test --filter oneShotEndpoint
swift test --filter reservationOutcomesMap
swift test --filter invalidEnvelopeAndNonidle
swift test --filter endpointConstructionRejects
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-014-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-014-value-profiles.sh --profile nrf52840-embedded
```

All focused tests and four profile compilations pass. T7.2 supplies the exact
session cleanup and post-body mapping implementation.
