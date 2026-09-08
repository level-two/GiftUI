# SPEC-009 Cycle Finalization Evidence

`RecordingCycleFinalizer` accumulates the complete normalized operational-event
set and reconstructs the terminal summary with that set before choosing the
result. A retained failure always selects `.failure`; otherwise primary
operational precedence is exactly retryable refusal, backpressure,
supersession, later-admission deferral, and no change. An empty event set is
the sole success path.

Focused tests cover every intrinsically legal event-set combination used by
that precedence and prove that success, operational, and failure results all
carry a complete summary for a started cycle. The first failure and its
detecting context remain unchanged when later failures are observed.

Finalization is exercised from admitting, mutating, deriving, publishing, and
offering. Every path enters finalizing once, releases fixture scratch and
borrow state, clears active cycle/candidate identity through the common phase
machine, and records the resulting idle authoritative context. A second call
is rejected without repeating cleanup or finalization.

Reproduce the focused evidence with:

```sh
swift test --filter RecordingCycleFinalizerTests
scripts/contracts/check-spec-009-cycle-finalization.rb
scripts/contracts/run-spec-009.sh --profile macos-dynamic
scripts/contracts/run-spec-009.sh --profile macos-static
```
