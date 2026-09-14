# SPEC-013 T6.4 Handoff and Recovery Evidence

Evidence kind: host execution and inspection. No simulator, connected target,
deployment, service restart, or flashing was used.

## Result

The shared suites cover accepted, backpressured, retryable-refusal,
nonretryable-refusal, and failed endpoint outcomes. Acceptance atomically
commits all coupled routing fields. Every other result retires candidate-only
state and preserves the prior committed routing and published semantic
revision.

Retry exhaustion clears pending intent. One hundred newer backpressure reports
retain only the latest fixed-size `PresentationPendingIntent` and coalesce to
one outstanding wake. Facts arriving after the seal remain queued for a later
opportunity. Reentrant admission and offer attempts are rejected, quiescence
refuses later admission and cancels pointer sequences, and active quiescence
finishes only mandatory containment before the same finite teardown.

## Reproduction

```sh
scripts/format-swift.sh
swift test --filter failedEndpointPreservesPublicationAndDiscardsCandidateRouting
swift test --filter repeatedBackpressureRetainsOneIntentAndOneOutstandingWake
swift test --filter GiftUIExecutionTests
swift test --filter GiftUIRuntimeCoreTests
scripts/contracts/check-spec-013-handoff-recovery.rb
scripts/contracts/check-spec-013-harness.rb
```
