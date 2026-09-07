# SPEC-009 Frame Handoff Value Evidence

Plan task: `SPEC-009 T1.3`

`GiftUIExecution` owns exact frame provenance, offer/logical/stream
dispositions, offer failure, refusal origin, validated offer result, and the
generic synchronous endpoint seam. The source imports only Render Core for the
existing operation-sink owner and stores no closure, frame payload, operation,
or borrowed resource.

Focused tests prove every raw case, the exact 12-byte provenance layout, the
two-byte offer-result ceiling, and rejection unless failure is present exactly
for `.failed`. A fixture endpoint maps all five body results, calls an accepted
body exactly once, and proves backpressure calls it zero times. Because the
protocol body parameter is nonescaping and the sink is an `inout` borrow, the
compiler enforces synchronous lifetime at the declaration boundary.

Reproduce from the repository root:

```text
swift test --filter FrameHandoffValueTests
scripts/contracts/check-spec-009-frame-handoff-values.rb
swift package dump-package | scripts/contracts/check-target-dependencies.rb
```
