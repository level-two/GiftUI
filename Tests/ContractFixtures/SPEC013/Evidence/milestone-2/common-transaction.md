# T2.2 Common Coordinator Transaction Oracle

Date: 2026-09-12

The Runtime Core test target composes `RuntimeCoordinatorLifecycle` with the
existing SPEC-009 recording seams, as explicitly permitted until production
focused owners land. It does not copy admission, identity, frame-offer,
commit, or pending-intent algorithms into Runtime Core.

The accepted path proves:

- one serialized lifecycle opportunity and exact phase/context retention;
- one at-most-once mutation batch, including state, completion, and action;
- ordered semantic, candidate-frame, and presentation identity reservation;
- one endpoint offer and one body invocation;
- accepted-only candidate routing commit under the reserved presentation
  revision; and
- finalization back to idle with no second offer or mutation replay.

The refusal path fills the finite endpoint first, observes backpressure without
another body call, aborts candidate routing without altering committed state,
retains only the latest constant-space `PresentationPendingIntent`, coalesces
its wake, supersedes an older revision, and converges at the finite retry
limit.

Verification command:

```text
swift test --filter RuntimeCoordinatorTransactionTests
```

Result: two composed transaction tests passed under Apple Swift 6.3.3.
