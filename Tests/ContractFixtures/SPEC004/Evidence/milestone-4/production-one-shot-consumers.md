# SPEC-004 Production One-Shot Consumer Evidence

- Task: `T4.3`
- Evidence category: macOS host execution plus previously recorded Pi/nRF
  hardware-free cross-build and inspection
- Date: 2026-09-14

## Cross-owner integration

The production `GiftUIBackendIntegration` target imports the capability,
execution, raster, display, surface, text-resource, and Failure Core owners at
their downstream join. `OneShotRasterBackendEndpoint` receives the already
resolved `EffectiveRasterPresentation`; construction validates it against the
descriptor and bounded payload limits without invoking the resolver.

The one-shot endpoint reserves before invoking its body and calls that body at
most once. The full-surface and first-party RGB565 tiled paths consume the
borrowed operation stream synchronously. Borrow poisoning, workspace
poisoning, address capture, producer/operation/resource counters, and failure
drain fixtures prove that no operation, producer closure, sink borrow,
glyph/stroke view, or replay state survives the call. Persisted state is
backend-owned bounded raster, tile, payload, region, and transfer storage.

Pre-transfer faults cancel without effect. Post-transfer faults stop physical
work, drain later borrows, finish once, update operational health once, and
retain the accepted logical disposition. Construction and runtime failures
use `GiftUIFailureCore`; diagnostics cannot alter the offer or health result.

## Reproducible checks

```text
swift test --filter GiftUIBackendIntegrationTests
scripts/contracts/check-spec-014-transactions.rb
scripts/contracts/check-spec-014-resources.rb
scripts/contracts/check-spec-014-storage.rb
```

Results: all 48 backend-integration tests passed; 12 ordered transaction
oracles, 15 resource metrics, seven instrumented methods, eight bounded values,
five protocols, and three tiled sources passed their fail-closed audits.

The exact Pi `240 x 16` and nRF52840 `480 x 4` tile fixtures are included in
the passing suite. Their target resource and cross-profile evidence remains in
SPEC-014's milestone 6 and 8 records; no connected hardware was used here.
