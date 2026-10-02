# T10.2 — Failed Dynamic derivation cleanup

Evidence lane: macOS host-native production-owner tests, 2026-10-02.

The fault fixture injects the original focused error at observable begin,
semantic completion, Layout, Drawing, combined render and Interaction. The
baseline regression (`cleanup-before.log`) executed with
`swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE --filter dynamicDerivationFailurePermitsNextAttemptAndPreservesCommittedActions`
and reproduced three failures: subsequent valid derivations returned
invariantViolation after Layout, Drawing and render faults. Observable begin
acquires no candidate; semantic and Interaction paths already discard their
observable candidate. Initial test attempts without the required Dynamic flag
were configuration errors and are excluded from this reproduction.

The repair tracks acquired attempt storage and the observable candidate's
actual lifetime, then uses RuntimeCoordinatorCleanupOracle/RuntimeCleanupTracker
to release failed attempt state. Observable cleanup already performed by a
focused owner is excluded from the tracker. Drawing's own callable-release
obligation is retained. Failed publication cleanup has a single Interaction
resolution path. A failed begin now preserves its ObservableStateError.

The regression commits an initial presentation, injects each failure, checks
that the exact error survives, checks observable discard count (zero without
acquisition, exactly one otherwise), compares prior committed action records,
and verifies unchanged model state/capture revision across the failed and
subsequent valid derivations. It then commits the valid follow-up. Derivation
does not reapply admitted facts. Existing action/fact tests also cover deferred
repository callbacks and sealed application ownership.

`swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE --filter 'dynamic.*(Derivation|Pi|TargetHost)'`
passes all 18 tests (`cleanup-focused.log`), including initial endpoint refusal,
lifecycle quiescence/teardown, replacement presentation revision, normalized
input queuing and action callback deferral. `scripts/format-swift.sh` was run
before validation. The regression remains required when T10.5 replaces the
parallel runner. No connected input/display or resource conformance is claimed.
