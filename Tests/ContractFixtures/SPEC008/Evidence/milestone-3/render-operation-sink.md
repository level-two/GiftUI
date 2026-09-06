# SPEC-008 Render Operation Sink Evidence

Plan task: `SPEC-008 T3.2`

`Sources/GiftUIRenderCore/RenderOperationSink.swift` contains only the exact
package transport surface: one idle-capacity getter and the ordered begin,
fill, glyph-group, glyph, group-end, finish, and discard calls. It adds no
producer policy, raster acceptance, backend facts, storage, or imports.

The focused checking-sink fixture reads zero and nonzero capacity exactly once
while idle, carries empty and multiple-operation streams in order, rejects an
incomplete glyph group, and injects `false` independently at every Boolean
call. The fixture is test-only; the canonical bounded recording sink remains
assigned to T3.3.

Reproduce from the repository root:

```text
swift test --filter RenderOperationSink
scripts/contracts/check-spec-008-render-operation-sink.rb
scripts/contracts/run-spec-008.sh --profile macos-dynamic
```
