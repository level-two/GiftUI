# SPEC-001 T6.7 Dynamic Live-Path Storage

The Dynamic runtime now supplies the bounded `LivePathStorage` needed by real
Signal Analyzer Canvas invocation. It reserves exactly the configured point
and subpath capacities, preserves contiguous subpath ranges, replaces a lone
current move point without spending capacity, rejects first excess through
`LivePathBuilder`, and resets without retaining logical path state.

The focused exact-bound test covers two subpaths, four points, move
replacement, first point excess, invalid ordinal lookup, complete reset, and
clean reuse. It is an independent Canvas-plan prerequisite and does not claim
that the five production canvases have been invoked yet.

Reproduce with:

```sh
scripts/format-swift.sh
source scripts/lib/swiftpm.sh
giftui_swiftpm \
    --package-path "$PWD" \
    --scratch-path "$PWD/.build" \
    --cache-root "$PWD/.build/swiftpm-cache" \
    --disable-sandbox \
    -- test --filter GiftUIRuntimeDynamicTests
```
