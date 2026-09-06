# SPEC-008 Recording Verification Evidence

Plan task: `SPEC-008 T3.4`

The independent typed-event verifier accepts only one leading `begin`, one
trailing `finish`, complete non-empty glyph groups, glyphs inside their group,
and exact header operation/glyph totals. Negative controls cover count
disagreement, incomplete groups, out-of-group glyphs, and nested begin events.

Field assertions compare surface and damage rectangles, every header count,
clip depth, fill bounds/clip/RGB, nominal resource and instance identity,
group clip/RGB/count, glyph identity, baseline, group ends, and finish directly
as values. A source audit excludes memory bytes, pointers, hashes, reflected
names, and object identity as comparison shortcuts.

Reproduce from the repository root:

```text
swift test --filter RecordingVerification
scripts/contracts/check-spec-008-recording-verification.rb
scripts/contracts/run-spec-008.sh --profile macos-dynamic
```
