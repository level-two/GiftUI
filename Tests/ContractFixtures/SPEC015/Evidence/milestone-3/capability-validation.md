# Capability validation

The stage-4 host gate calls `RasterPresentationResolver.resolve` exactly once
from the checked validator. No other `GiftUIHostConfiguration` source invokes
the resolver, and the one-shot validation guard returns a graph-stage
invariant before a repeated validation can reach capability work. The
effective value is captured into the immutable assembly report; later report
access therefore performs no resolution.

The focused corpus inserts the exact render-producer, raster-backend,
surface/display, and host-resource-policy contributions in all 24 orders. All
orders produce the same exact report. Separate negatives preserve SPEC-004's
typed missing-render-producer result and its zero-versus-one resolver-workspace
capacity result.

The generated nRF requirement carries all five operation bits, the 480 x 320
extent, synchronous borrowed one-shot stream, RGB565 encoding, all three
accepted submission lifetimes, exact 3,840-byte raster/payload/in-flight
ceilings, and required absence. A valid Drawing gate followed by missing
capability contributions fails at `.capability`, proving the gates remain
independent and conjunctive.

Reproduction:

```sh
scripts/format-swift.sh
test "$(rg -l 'RasterPresentationResolver\.resolve' \
    Sources/GiftUIHostConfiguration -g '*.swift' | wc -l | tr -d ' ')" = 1
source scripts/lib/swiftpm.sh
giftui_swiftpm \
    --package-path "$PWD" \
    --scratch-path "$PWD/.build" \
    --cache-root "$PWD/.build/swiftpm-cache" \
    --disable-sandbox \
    -- test --filter GiftUIHostConfigurationTests
```
