# Host configuration surfaces

The package declarations exactly preserve SPEC-015's host kind, validation
stage, configuration error, assembly report, validation result, lifecycle,
activation result, opportunity result, host instance, validator, residual
policy table, and residual policy surfaces.

The positive compile fixture supplies finite concrete conformers for the
three noncopyable host protocols and the residual policy specialization. The
focused Swift tests exercise every associated payload family used by
`HostConfigurationError`, generic activation payload equality, lifecycle and
stage raw values, and compile-time `Sendable` constraints. Two negative
fixtures prove the declarations are unavailable outside the package and that
`HostActivationResult` rejects a non-`Sendable` failure type.

Reproduction:

```sh
scripts/format-swift.sh
scripts/contracts/check-spec-015-host-surfaces.sh
source scripts/lib/swiftpm.sh
giftui_swiftpm \
    --package-path "$PWD" \
    --scratch-path "$PWD/.build" \
    --cache-root "$PWD/.build/swiftpm-cache" \
    --disable-sandbox \
    -- test --filter GiftUIHostConfigurationTests
```
