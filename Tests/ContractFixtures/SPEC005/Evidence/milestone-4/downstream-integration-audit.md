# SPEC-005 T4.4 Downstream Integration Audit

The 2026-09-19 audit replaces the obsolete placeholder-target inventory with
the production owners created by SPEC-007, SPEC-008, SPEC-014, and SPEC-015.
It does not add a text-resource abstraction or change the SPEC-005 contract.

The fail-closed audit proves:

- every production target with a direct `GiftUITextResources` edge is listed,
  and no unregistered direct consumer exists;
- the concrete Signal Analyzer host and preset roots reach the one canonical
  text-resource owner through the exact checked package graph;
- layout maps scalars and obtains glyph metrics through
  `CanonicalTextMetricsView` using the nominal `FontInstanceID` and `GlyphID`;
- render lowering validates those same nominal identities and metrics without
  translation;
- rasterization obtains the exact `GlyphRasterRecord` and consumes its payload
  synchronously through `TextRasterResourceView.withPayload`;
- backend startup validates the prior package result, exact descriptor,
  selected `RasterRealizationID`, all glyph records, payload availability, and
  bounded raster work before admitting the endpoint; and
- host validation preserves the exact text result and selected realization,
  construction audits exactly one retained resource package, rejected
  candidates tear down synchronously, and normal teardown releases platform
  owners before storage reset and report invalidation.

The existing global identity-owner scan continues to reject any parallel or
translated `FontResourceID`, `FontInstanceID`, `GlyphID`, or
`RasterRealizationID`. The exact package dependency registry remains the
authority for every target edge; this audit adds the cross-Spec consumption
and lifetime assertions that the old reserved rows could not provide.

## Reproduction

```text
source scripts/lib/swiftpm.sh
giftui_swiftpm --package-path "$PWD" --cache-root "$PWD/.build/swiftpm-cache" -- package dump-package \
  | scripts/contracts/check-spec-005-downstream-integration.rb
scripts/contracts/run-spec-005.sh --profile macos-dynamic
```
