# Firmware startup aggregate and real rehearsal — 2026-10-05

The complete native Layout/Drawing/codec/startup corpus passes. The initial
production-host native rehearsal correctly rejected the stale aggregate C
startup guard, still 157,808 bytes although the three-slot capture storage
had fallen by 96,000. The aggregate guard and its exact C storage fixture now
require 61,808 bytes. This preserves startup refusal; it does not weaken a guard.
The rebuilt firmware and production-host native rehearsal pass, including
startup, workload frames, all action windows, capacity/reuse/partial-failure and
cleanup cases. Raw initial failure and successful retry logs are preserved here.

An ad hoc full `swift test` invocation omitted the canonical repository gate's
`-DGIFTUI_DYNAMIC_PROFILE`; it produced unsupported-mode Dynamic Canvas errors
and was stopped. Its log remains `.build/iteration-002-retention-root.log`, not
a passing report. The upcoming canonical aggregate gate uses the required flag.
No production change is made to accommodate an unsupported test configuration.

T12.2 fresh combined/profile/pixel checks remain pending T12.3. Existing physical
and timing limitations remain separate from these host-executed observations.
