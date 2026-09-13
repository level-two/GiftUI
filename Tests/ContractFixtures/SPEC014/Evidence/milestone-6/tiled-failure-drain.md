# SPEC-014 T6.6 Tiled Failure and Drain Evidence

Date: 2026-09-13

Before the first accepted payload, a submission failure remains reversible:
the emitter returns the exact `failureBeforeAcceptance` value, records the
sticky display failure, and leaves responsibility untransferred for endpoint
cancellation.

After a first or later accepted failure, the emitter marks responsibility and
enters validation-only draining. It simulates the same maximal-run payload
segmentation from its checked cursor, recording raster, payload, in-flight,
tile, and region bounds without borrowing another writer or performing another
submission. Later operation tiles follow the same path. Frame completion calls
the target once and reports that responsibility was transferred.

The later-failure fixture submits two physical payloads, injects failure on the
second, then drains all five logical full-row payloads across three tiles. It
records three consumer calls, five logical regions/payloads, exactly two writer
borrows/submissions, one frame-end call, and the first local display failure.
The existing Display Core responsibility suite proves the target-owned health
transition occurs exactly once and that illegal before-acceptance results after
transfer normalize to an after-acceptance invariant failure.

Run from the repository root:

```sh
swift test --filter tileEmitterPreservesPretransferFailure
swift test --filter laterAcceptedFailureStopsPhysicalWork
swift test --filter DisplayResponsibilityTests
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-014-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-014-value-profiles.sh --profile nrf52840-embedded
```

All focused tests and four profile compilations pass. Endpoint result mapping
and producer-error preservation remain assigned to Milestone 7.
