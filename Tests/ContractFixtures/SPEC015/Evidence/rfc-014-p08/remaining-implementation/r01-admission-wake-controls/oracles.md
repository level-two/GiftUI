# Remaining P08 R01 — cases and independent expected outcomes before edits

2026-10-12, entry `5475f547195bb06aa222baf1a6827e0d88146629`.
Strong gpt-6.1-sol/high, sequential. Behavior/test edit footprint is only
CounterWakeIntegration.swift `counterWakeControls`, exercised by both actual
Static/Dynamic scoped hosts. Production admission/emission/pacing remains fixed.
SPEC-009 queued-only notification and first-fact service deadline; SPEC-015
HC-011/014/018 and HC-RD-004 govern. B03 accepted; its1/1 and historical2/2 stay
closed. This records the expected cases **before source edits**.

1. With no outstanding work: state10 and completion1 reject invalidValue;
   a pointer with a different presentation revision rejects invalidProvenance.
   Each must preserve canonical requester count/reasons/outstanding, host wake
   count, accepted-fact count/first timestamp, supplied clock, wake takes,
   finalized/applied counts and disabled-notification rejection count. Rejection
   may legitimately cancel pointer provenance state; that is not wake work.
2. At idle timeT emit semanticDirty and presentationPending: one canonical
   requester/host request, reasons6. Accept state0 atT+10, another state0 atT+20,
   completion0 atT+30, normalized pointer down/up atT+40/T+50, source0 and a
   harmless point outside the action bounds. Five accepted notifications each
   increment acceptedFactWakeRecords exactly once; all retain first-factT+10,
   canonical reasons7/outstanding and one requester/host wake. No synchronous
   finalized/applied change. A copy of the actual scheduler after each acceptance
   rejects current supplied clock−1 as timeRegression, proving the current
   clock reached pacing state while the actual instance remains untouched.
3. With this actual pending wake, state10/completion1/stale-revision pointer still
   reject without wake/time side effects. Duplicate completion0 rejects
   capacityRefused. A pointer on foreign source1 with current revision rejects
   capacityRefused (actual controller is already bound to source0), again with
   no wake/time side effect. State-capacity and production burst boundaries are
   distinct remaining work; do not claim their coverage from these cases.
4. Copied actual scheduler at first-fact deadlineT+250010 begins with reasons7;
   at deadline+1 rejects serviceDeadlineMissed. Thus later accepted clocks must
   not replace the earliest pending-fact deadline. Actual host waits atT+249999
   and services atT+250000. Summary is exactly2 pointer,2 state,1 completion,
   zero semantic action; later existing controls must still pass. Canonical
   take clears outstanding and first-fact timestamp.
5. After existing actual third-refusal terminal shutdown, state0, completion0
   and pointer submissions each return unavailable and preserve the same
   wake/time/runtime snapshot, including disabled notification count. Keep
   existing direct disabled-notification and stopped-scheduler checks.

All existing cycle-time callback, dirty recovery, backpressure, refusal and
terminal controls remain. Cases1/3/5 compare snapshots independently of return
codes. This validation is one initial existing pinned counter invocation after
these new controls, not an unchanged B03 rerun. Failure outside this footprint
stops for parent triage. No target build, next slice or new API is authorized.
