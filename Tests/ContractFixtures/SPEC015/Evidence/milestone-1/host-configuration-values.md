# Host configuration values

The exact T1.3 value family is implemented in
`Sources/GiftUIHostConfiguration/HostConfigurationValues.swift`. The focused
corpus rejects each independently zero pacing field, rejects overflow in both
checked addition positions, and accepts the nonzero lower boundary and the
largest representable fact sum with a refusal limit of 255.

All four generated presets preserve the required kind/profile mapping,
cardinalities, Drawing and workload values, and pacing policy. Their checked
production fact sum is `20 + 2 + 6 == 28`, their compact capacity is 32, and
the remaining margin is exactly four. Separate value tests preserve the
structural audit, six-code action range, one handler/model/input/wake owner,
distinct domains, non-reentrant wake flag, and every inert nRF52840 endpoint
projection field.

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
