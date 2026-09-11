# T7.1 Package and Authority Boundaries

The maintained audit binds `GiftUIRenderCore` to exactly `GiftUI` and
`GiftUITextResources`, and `GiftUIRenderLowering` to exactly those modules plus
`GiftUISemanticCore` and `GiftUILayout`. It checks both the governed target
ledger and every source import, and rejects runtime, execution, failure,
capability, backend, raster, concrete-resource, platform, driver, OS/RTOS, HAL,
or hardware owners.

Only Render Lowering source may import both Semantic Core and Layout. Any
backend/raster/platform/driver target is prohibited from importing semantic,
layout, or lowering authority. A unique-declaration audit fixes the owners of
the public declaration values, Render Core protocol/values, lowering entry and
limits, and both borrowed views. `GiftUI` contains neither an exported import
nor internal rendering SPI names.

Reproduce with:

```console
swift package dump-package | scripts/contracts/check-target-dependencies.rb
scripts/contracts/check-spec-008-package-boundaries.rb
```
