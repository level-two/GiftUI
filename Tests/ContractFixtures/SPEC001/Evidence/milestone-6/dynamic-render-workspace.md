# SPEC-001 T6.7 Dynamic Render Workspace

The Dynamic runtime now owns a concrete `RenderProductionWorkspace` for the
next production layout-to-render join. Construction takes the generated
`RenderLimits` and `RenderWorkspaceCapacity` without adding independent
headroom.

The workspace provides separately bounded semantic-visit and layout-visit
sets, a foreground stack bounded by maximum traversal depth, exclusive
acquisition, repeated-visit detection, invalid first-excess ordinals, and a
complete attempt reset that retains allocation capacity but no traversal or
foreground state.

The focused test covers inactive access, exact semantic/layout ordinal bounds,
repeat classification, first excess, nested acquisition, exact foreground
depth, underflow, and clean reuse after reset. The complete Dynamic runtime
suite passes with 37 tests.

Reproduction:

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

This is a production-store prerequisite, not T6.7 completion. The real render
preflight/streaming, Canvas extension, interaction, raster, endpoint, and host-
loop joins remain open.
