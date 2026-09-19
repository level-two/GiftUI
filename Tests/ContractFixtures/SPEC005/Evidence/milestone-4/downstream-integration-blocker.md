# SPEC-005 T4.4 Downstream Integration Disposition

The blocker recorded here on 2026-09-06 is resolved as of 2026-09-19. The old
names were reservation labels, not required target names. Their governed
production successors now exist under SPEC-007, SPEC-008, SPEC-014, and
SPEC-015:

- `GiftUILayout` owns canonical text mapping, metrics lookup, and positioned
  nominal glyph identities;
- `GiftUIRenderLowering` validates and streams those same identities;
- `GiftUIRasterCore` consumes exact raster records and borrowed payload bytes;
- `GiftUIBackendIntegration` validates the selected realization, payload
  availability, record coverage, and bounded raster work; and
- `GiftUIHostConfiguration` validates the prior text-resource result, audits
  exactly one retained resource package, tears down rejected candidates, and
  releases platform owners before profile reset and report invalidation.

`SignalAnalyzerHost` and `SignalAnalyzerPresetHarness` are the concrete
platform-root path rather than invented `GiftUIPlatform` or `GiftUIHost`
targets. The [fresh downstream integration audit](downstream-integration-audit.md)
registers these actual owners, fails on an unlisted direct production
consumer, and retains the global no-alias/no-translation scan. T4.4 is
therefore complete; no text-resource architecture was added to close it.

## Reproduction

```text
swift package dump-package
scripts/contracts/check-spec-005-dependencies.rb < package.json
scripts/contracts/check-spec-005-downstream-integration.rb < package.json
scripts/contracts/run-spec-005.sh --profile macos-dynamic
```
