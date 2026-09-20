# SPEC-014 T7 Production Operation-Major Session Evidence

Date: 2026-09-20

`OperationMajorRGB565RasterSession` is the production, generic
`RasterOfferSessionSink` for the approved tiled RGB565 path. It owns one
caller-provided tile workspace, one synchronous display target, the active
reservation, stream grammar, bounded work counters, sticky raster/display
failure, and the first exact producer error. It retains no producer, borrowed
operation, glyph payload, or full framebuffer.

The focused production test constructs the session behind
`OneShotRasterBackendEndpoint`, reserves the exact descriptor and payload
limits, and streams two overlapping fills. The recorded target observes the
first fill's three row tiles before the later fill's overlapping tile, with
canonical big-endian RGB565 blue bytes in the last payload. The endpoint
accepts the frame, finishes it exactly once, returns the session to idle, and
does not cancel. A separate malformed pre-transfer stream retains the sticky
backend and producer errors, discards state, and cancels exactly once without
finishing.

Run from the repository root:

```sh
source scripts/lib/swiftpm.sh
giftui_swiftpm \
  --package-path "$PWD" \
  --cache-root "$PWD/.build/swiftpm-cache" \
  --disable-sandbox \
  -- test --filter OperationMajorRGB565RasterSessionTests
```

The two focused tests pass. This closes the reusable session-realization gap
identified while joining the SPEC-001 Raspberry Pi target host. It does not
claim a connected-target run, deployment, or flashing.
