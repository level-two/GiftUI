# SPEC-011 T5.5 Replacement Timing Evidence

The Runtime Core dispatcher fixture uses mutable committed-record and current
target views to reproduce the publication boundaries owned by SPEC-010.

- A committed replacement after pointer down changes both action and target
  generations; the former capture invokes neither model.
- A committed replacement after admission but before same-phase dispatch is
  rejected by final target validation and invokes neither model.
- Published removal exposes no current target and invokes no retained former
  model.
- Staged and failed replacements leave the former committed record, target
  generation, and model route authoritative. A still-current capture or a new
  valid gesture therefore dispatches normally to the former model, never the
  uncommitted candidate.

SPEC-010's focused replacement and target-lifetime tests independently prove
that its atomic owner publishes exactly these live/staged/failure views.

Reproduce with:

```sh
swift test --filter RuntimeInteractionDispatcherTests
swift test --filter ObservableStateReplacementTransactionTests
swift test --filter ObservableStateTargetLifetimeTests
```
