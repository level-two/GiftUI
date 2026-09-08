# SPEC-009 T3.2 Input Sequence Evidence

The target gate exposes raw zero for the first down submitted to Execution and
advances only when that down is submitted. Abandoned target-local physical
input consumes no runtime-visible value. Submitted values use checked exact
successors, reserve `UInt32.max`, and then exhaust permanently.

The runtime-side state independently validates each bounded source. A down
uses ordinal zero and the exact next sequence. Move and up use the active
sequence and exact next ordinal. Gaps, duplicates, decreases, wrong sequences,
and ordinal wrap cancel without trusting the malformed value as a baseline.
Cancelled suffix phases are consumed without dispatch until a valid up or an
independently gate-proven exact successor down resynchronizes the source.
Sequence exhaustion makes only that source quiescent for the runtime lifetime.

```sh
swift test --filter InputSourceSequenceStateTests
ruby scripts/contracts/check-spec-009-input-sequences.rb
```

The focused implementation uses only fixed-width optionals and enums. It owns
no pointer queue, capture, action, model, backend, platform, or production
per-source container; SPEC-013 retains the latter storage choice.
