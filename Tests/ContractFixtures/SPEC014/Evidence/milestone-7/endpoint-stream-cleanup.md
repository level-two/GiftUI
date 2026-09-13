# SPEC-014 T7.2 Endpoint Stream Cleanup Evidence

Date: 2026-09-13

The endpoint owns final offer disposition and reads only explicit session
facts: terminal stream completion, irreversible responsibility transfer, and
the producer's separately retained local error.

Before transfer, every non-complete result discards raster state and cancels
the reservation exactly once. Producer failure and capacity shortfall require
their matching retained error; endpoint refusal requires `sinkRefused`; any
mismatch and a false `.complete` become contract violations. A valid complete
stream is accepted only after the session reports its surface/display terminal
work complete.

After transfer, all five body results are accepted. A nonterminal session is
finished once without discard or cancel, and a non-complete producer error is
preserved for later correlation/quiescence. The endpoint does not retain the
body or sink borrow.

Run from the repository root:

```sh
swift test --filter OneShotRasterBackendEndpointTests
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-014-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-014-value-profiles.sh --profile nrf52840-embedded
```

The complete focused matrix and all four compilation profiles pass.
