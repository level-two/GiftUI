# SPEC-009 Recording Endpoint Evidence

`RecordingSynchronousFrameEndpoint` implements the package one-shot endpoint
over a finite `RecordingFrameSink`. It validates the envelope and downstream
slot availability before reserving capacity or calling the body. The body sees
that reservation, executes once, and must complete the exact begin/operation/
positioned-glyph/finish vocabulary within the advertised limits.

The endpoint copies the sink's first exact local `RenderProductionError`, then
poisons the borrowed sink and releases the attempt reservation before selecting
the result. Calls through the former borrow fail after every return. Invalid
vocabulary cannot become accepted even if the body claims completion.

Acceptance retains only endpoint-owned provenance and derived operation/glyph
counts while occupying the reserved downstream slot. Backpressure, invalid
envelope, render failure, insufficient capacity, producer refusal, and contract
violation retain no candidate data and leave no attempt reservation.

Reproduce the focused evidence with:

```sh
swift test --filter RecordingFrameEndpointTests
scripts/contracts/check-spec-009-recording-endpoint.rb
scripts/contracts/run-spec-009.sh --profile macos-dynamic
scripts/contracts/run-spec-009.sh --profile macos-static
```
