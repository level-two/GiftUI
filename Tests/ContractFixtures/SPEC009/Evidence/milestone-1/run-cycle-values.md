# SPEC-009 Run-Cycle Value Evidence

Plan task: `SPEC-009 T1.5`

`GiftUIExecution` owns the exact local execution error, semantic disposition,
presentation-intent, operational, failure, summary, and result values. The
generic focused-owner case preserves its finite `OwnerFailure` directly; the
source neither imports failure authority nor inspects, translates, maps, or
reranks that value.

Focused tests prove every closed raw value and one-byte width, masking of all
unknown operational-event bits, every generic failure case, exact equality and
sendability, the at-most-four-byte fixture-owner bound, and the 8/40/72-byte failure,
summary, and result ceilings. Legal summary examples cover success,
publication/commit, backpressure, retry exhaustion, supersession, deferral,
and no-change. Rejected examples cover each intrinsic publication,
presentation, pending-intent, event-exclusion, and event-implied state
contradiction fixed by SPEC-009. Historical transition validation remains
owned by T2.4 and is not duplicated in this value initializer.

Reproduce from the repository root:

```text
swift test --filter RunCycleValueTests
scripts/contracts/check-spec-009-run-cycle-values.rb
swift package dump-package | scripts/contracts/check-target-dependencies.rb
```
