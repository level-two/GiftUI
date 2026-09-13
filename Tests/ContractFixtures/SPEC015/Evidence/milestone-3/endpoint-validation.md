# Endpoint validation

The stage-5 validator consumes only `HostEndpointConfiguration`, the resolved
effective presentation, and the selected text realization. Its initializer
accepts no live endpoint, owner, factory closure, or callback.

The pure gate requires exact equality for the resolved value; surface extent,
encoding, row bytes, realization, and region; writable raster bytes; payload
raster, payload, in-flight count, and in-flight byte limits; display lifetime,
handoff, count, and bytes; selected text realization; and the single shared
endpoint/display health owner.

Focused tests preserve exact success, independently mismatch every projection
family, verify the validator reports stage `.endpoint`, and apply the same
exact value comparison to a constructed endpoint projection. Both inert and
post-construction mismatch return `.invalidEndpointDescriptor`, whose approved
mapping is SPEC-014's invariant, host-composition/runtime,
safety-not-proven result.

Reproduction:

```sh
scripts/format-swift.sh
source scripts/lib/swiftpm.sh
giftui_swiftpm \
    --package-path "$PWD" \
    --scratch-path "$PWD/.build" \
    --cache-root "$PWD/.build/swiftpm-cache" \
    --disable-sandbox \
    -- test --filter GiftUIHostConfigurationTests
```
