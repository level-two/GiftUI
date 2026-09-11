# T7.3 Governed Consumer Seams

Three registered executable fixtures cover the downstream boundaries without
implementing downstream policy. SPEC-009's recording endpoint receives one
nonescaping sink body, calls it once, then poisons the sink borrow; accepted
storage contains only provenance and operation/glyph counts. SPEC-013's three
profile representations join the same generic Render Producer call. The
SPEC-014-side fixture consumes ordered Render Core values without importing
semantic, layout, lowering, execution, capability, or raster authority.

The audit rejects retained fill, glyph-group, glyph, and font-resource fields
in the endpoint. No fixture gains style resolution, profile selection, frame
disposition, capability negotiation, or rasterization authority.

Reproduce with:

```console
scripts/contracts/check-spec-008-consumer-seams.rb
swift test --filter endpointReservesBeforeConsumptionAndRetainsOnlyAcceptedDerivedFrame
swift test --filter canonicalCorpusMatchesAcrossRecordingDynamicAndStaticRenderProfiles
swift test --filter sinkCarriesEmptyAndMultipleOperationStreamsInExactOrder
```
