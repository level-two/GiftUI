# SPEC-005 T4.4 Downstream Integration Disposition

T4.4 is blocked on its explicit downstream prerequisites as of 2026-09-01.
SPEC-007, SPEC-008, SPEC-014, and SPEC-015 are approved contracts, but none has
an active implementation plan or a production owner target in `Package.swift`.
In particular, the package graph contains no `GiftUILayout`,
`GiftUIRenderCore`, `GiftUIRenderLowering`, raster-provider, backend, platform,
or host target into which the SPEC-005 package can be integrated.

The SPEC-005 boundary registry therefore continues to list `GiftUILayout`,
`GiftUIRenderCore`, `GiftUITextRasterProvider`, `GiftUIBackend`,
`GiftUIPlatform`, and `GiftUIHost` as reserved pending consumers. Its dependency
checker fails closed if any reserved target appears without an activated audit
row. The negative compile fixtures also continue to prove that layout and
render modules are absent rather than silently substituted.

No alias, translated text-resource identity, production host adapter, layout
adapter, render adapter, raster provider, backend, platform, or host module was
created for this task. T4.4 remains open until the governing downstream plans
create those targets and authorize integration.

## Reproduction

```text
swift package dump-package
scripts/contracts/check-spec-005-dependencies.rb < package.json
scripts/contracts/run-spec-005.sh --profile macos-dynamic
```
