# T6.5 Profile Equivalence

`LayoutProfileEquivalenceTests.swift` passes recording-path, dynamic-slot, and
fixed-enum identity representations through the real generic `layout` entry.
The sink normalizes identities only to canonical source tokens and compares
the complete ordered scope, text-line, and glyph transcript, every numeric
geometry field, the result summary, and the exact identity relations.

The same fixture reports 8 scopes, 2 text scalars, 1 line, 2 positioned
glyphs, and maximum observed depth 4 in every representation. The engine uses
only caller-owned workspace records and bounded depth traversal; the static
and borrow probes in milestone 7 cover allocation and lifetime independently.

Reproduce with:

```console
swift test --filter recordingDynamicAndStaticViewsProduceIdenticalLayoutTranscripts
```
