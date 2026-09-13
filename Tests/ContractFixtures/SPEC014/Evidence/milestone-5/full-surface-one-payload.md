# SPEC-014 T5.3 Full-Surface One-Payload Emission

Date: 2026-09-13

`FullSurfacePayloadEmitter` is the integration-owned join between a readable
full-surface raster and one already-reserved display session. It emits each
damaged row as one packed horizontal region, skips stride padding, finishes
one payload, submits it once, records transfer before frame end, and closes
the display and raster frame once. Empty damage emits no payload.

Focused tests prove exact capacity/region equality, the first-byte-short
writer failure, explicit caller cancellation before transfer, submit failure
before acceptance, frame-end failure after acceptance, odd stride, partial
damage, row order, and zero-payload completion.

Run from the repository root:

```sh
swift test --filter fullSurfaceEmitter
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-014-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-014-value-profiles.sh --profile nrf52840-embedded
```

No effect is produced while normalized operations are being consumed; the
emitter is called only by the successful full-surface stream-completion path.
