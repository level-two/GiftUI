# SPEC-009 Wake Value Evidence

Plan task: `SPEC-009 T1.2`

`ExecutionWakeReasons` stores one byte and masks every initializer input with
`0x07`; its three known values are exactly `0x01`, `0x02`, and `0x04`.
The package-only requester is a non-suspending mutating notification seam with
no result. `PresentationPendingIntent` stores only semantic revision and
retryable-refusal count within its eight-byte ceiling.

A fixture-owned transition model proves backpressure starts a new revision at
zero without incrementing an unchanged revision, retryable refusal starts at
one, equality with the configured maximum is exhausted rather than retained,
and a newer revision replaces the complete intent. The model is test-only and
does not establish a scheduler, runtime owner, or production capacity.
The source audit excludes imports, dynamic storage, rendering/runtime payloads,
callables, models, target generations, and other retained work.

Reproduce from the repository root:

```text
swift test --filter WakeValueTests
scripts/contracts/check-spec-009-wake-values.rb
```
