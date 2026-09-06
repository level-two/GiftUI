# SPEC-008 Canonical Recording Sink Evidence

Plan task: `SPEC-008 T3.3`

`RenderRecordingSink` adapts the ordered Render Core transport into six closed
typed `RenderRecordingEvent` cases. It is generic over caller-owned
`RenderRecordingStorage`; the storage reports finite operation/glyph capacity
and owns staged/current representations, allowing later dynamic and static
fixtures without changing event meaning.

The sink holds only its storage value and fixed `UInt32` attempted-call
counters. It contains no strings, pointers, serialization, dynamic collection,
resource borrow, producer policy, or upward import. Focused tests prove atomic
publication, prior-current preservation, begin/event/publish refusal, explicit
discard of only the staged attempt, exact attempted typed events, and exact
per-call counters.

Reproduce from the repository root:

```text
swift test --filter RenderRecordingSink
scripts/contracts/check-spec-008-recording-sink.rb
scripts/contracts/run-spec-008.sh --profile macos-dynamic
```
