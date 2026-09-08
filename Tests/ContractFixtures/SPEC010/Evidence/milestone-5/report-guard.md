# SPEC-010 Report Guard Evidence

`ObservableStateReportGuard` models the bounded lifecycle and mandatory effects
at the report boundary without retaining a model, sink, candidate payload, or
history. Reports during attachment, candidate state, detachment, retirement,
shutdown, or from an earlier generation in a reused slot return
`staleAttachment` and preserve current dirty, wake, and publication state.

The focused phase matrix covers every non-mutating execution phase. With proof
that no model write occurred, the guard returns `invalidPhaseContained`,
preserves the last complete publication and partial candidate, marks the live
owner dirty, and requests exactly one host-paced semantic wake. The row records
that no residual policy call is permitted.

Without that proof, the guard returns `invalidPhaseSafetyNotProven`, discards
partial candidate work, preserves the last publication and current dirtiness,
and excludes another normal cycle pending target disposition. Reports across
an active report or semantic dispatch select `reentrancyViolation` first and
perform the same safety-not-proven containment. Those rows permit only the
Specification's bounded residual policy choices.

Reproduce the focused evidence with:

```sh
swift test --filter ObservableStateReportGuardTests
scripts/contracts/check-spec-010-report-guard.rb
scripts/contracts/run-spec-010.sh --profile macos-dynamic
scripts/contracts/run-spec-010.sh --profile macos-static
```
