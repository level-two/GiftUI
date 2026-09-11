# T7.3 Layout Resource Probes

The maintained static probe now invokes the real `GiftUILayout.layout` entry
with a fixed semantic view, fixed text metrics view, finite caller-owned
workspace, and transactional sink. Optimized SIL rejects `alloc_ref`,
`alloc_box`, and `swift_allocObject` in both the borrowed-view entry and the
layout attempt. The probe exposes its exact workspace size and stride through
`MemoryLayout` for per-compiler evidence collection.

The nRF52840 probe compiles the real layout module and entry for
`armv7em-none-none-eabi`, verifies the Cortex-M4F VFP calling convention, and
rejects allocation and prohibited dependency symbols. The semantic boundary
audit rejects retained semantic/text fields, adapter-owned node collections,
and a second complete semantic graph. Runtime lifetime tests poison their
source token after the synchronous call and prove it is released on success
and reset paths.

The Signal Analyzer fixture reports the bounded traversal high-water directly:
24 scopes, 10 scalars, 2 lines, 9 glyphs, and depth 5 under the exact
512/64/4096/512/4096 limits. The four-profile report records workspace bytes,
object/section sizes, and the incremental layout code image separately from
these logical high-water counts.

Reproduce with:

```console
scripts/contracts/check-spec-007-static-exposure.sh
scripts/contracts/check-spec-007-embedded-semantic.sh
swift test --filter signalAnalyzerApprovalFixture
```
