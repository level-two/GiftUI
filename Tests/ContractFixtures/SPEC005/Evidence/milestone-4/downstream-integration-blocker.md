# SPEC-005 T4.4 Downstream Integration Disposition

T4.4 remains blocked on its incomplete downstream prerequisites as of
2026-09-06. SPEC-008 now has an active implementation plan and its production
`GiftUIRenderCore` target imports `GiftUITextResources` directly alongside
`GiftUI`. The SPEC-005 boundary registry activates and audits that exact edge;
Render Core reuses `FontInstanceID` and `GlyphID` without aliases or identity
translation.

`GiftUILayout`, `GiftUITextRasterProvider`, `GiftUIBackend`, `GiftUIPlatform`,
and `GiftUIHost` remain reserved pending consumers. `GiftUIRenderLowering` and
the production lookup adapter are also not yet present. The dependency checker
continues to fail closed if any reserved target appears without an activated
audit row. Public negative compile fixtures continue to prove there is no
externally consumable text-resource or Render Core product.

No alias, translated text-resource identity, production host adapter, layout
adapter, render adapter, raster provider, backend, platform, or host module was
created as a substitute. T4.4 remains open until the governing downstream
plans create the remaining production owners and integration seams.

## Reproduction

```text
swift package dump-package
scripts/contracts/check-spec-005-dependencies.rb < package.json
scripts/contracts/run-spec-005.sh --profile macos-dynamic
```
