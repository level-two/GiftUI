# SPEC-009 Frame Commit Evidence

`RecordingFrameCommitTransaction` stages one candidate with its reserved
presentation revision, logical-frame token, hit-geometry token, action-table
token, and routing token. Only normalized acceptance after complete consumption
and reservation replaces the complete committed state, making the five coupled
values observable atomically.

Backpressure, retryable refusal, render failure, frame-offer failure, and both
non-retryable refusal origins abort the candidate and clear all staged values.
Every row preserves the prior committed presentation/routing state and the
newer already-published semantic revision.

Incomplete acceptance is a contract failure and cannot publish any coupled
field. An irreversible output observation is legal only with complete
acceptance, which finishes in accepted endpoint health; every contradictory
non-accepted result is contained as a contract failure with unavailable health.

Reproduce the focused evidence with:

```sh
swift test --filter RecordingFrameCommitTransactionTests
scripts/contracts/check-spec-009-frame-commit.rb
scripts/contracts/run-spec-009.sh --profile macos-dynamic
scripts/contracts/run-spec-009.sh --profile macos-static
```
