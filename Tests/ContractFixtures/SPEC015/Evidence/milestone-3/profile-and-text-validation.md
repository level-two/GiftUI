# Profile and text validation

The checked host validator consumes one typed `RuntimeProfileValidationResult`
at stage 1. Each of SPEC-013's seven local errors is retained unchanged inside
`HostConfigurationError.invalidRuntimeProfile`; success requires the returned
audit to equal the immutable structural audit, profile, and complete runtime
limits.

At stage 2 the validator consumes one already-computed
`TextResourceValidationResult`. All nine SPEC-005 errors remain typed inside
`HostConfigurationError.invalidTextResources`. Validation does not construct
a package, metrics view, raster view, or live owner; selected-realization and
endpoint equality remain in the inert endpoint projection validated by the
ordered endpoint stage.

The exact nRF52840 fixture passes graph, profile, text, workload, capability,
endpoint, action/model, input/wake, and policy validation and yields a report
with the retained audit and 28-fact service-window bound.

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
