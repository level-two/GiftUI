# SPEC-009 Offer Normalization Evidence

`RecordingRenderProductionAdapter` converts successful production to
`complete`, capacity exhaustion to `insufficientCapacity`, sink refusal to
`endpointRefused`, invariant failure to `contractViolation`, and every other
exact render error to `producerFailed`. The separate retained-error field keeps
all seven `RenderProductionError` values intact through normalization.

The independent matrix crosses every called stream result, every optional
retained render error, and all eight legal `FrameOfferResult` values. Only the
five exact body/result pairings normalize to acceptance or their preserved
render/refusal failure. Every other pairing becomes
`frameOffer(.contractViolation)`.

The no-body matrix independently covers backpressure, retryable refusal,
endpoint-origin non-retryable refusal, invalid envelope, and contract failure.
A sink-origin refusal after body execution instead retains the distinct
`renderProducer` origin. Contradictory called/payload observations cannot be
constructed.

Reproduce the focused evidence with:

```sh
swift test --filter FrameOfferNormalizationTests
scripts/contracts/check-spec-009-offer-normalization.rb
scripts/contracts/run-spec-009.sh --profile macos-dynamic
scripts/contracts/run-spec-009.sh --profile macos-static
```
