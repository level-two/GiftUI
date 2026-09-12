# T3.3 Dynamic Storage Lifetime

Date: 2026-09-12

Dynamic storage now admits only one active attempt. Reentrant acquisition is
rejected, and attempt reset clears only Semantic/Layout/render/Canvas/Path/
drawing/Observable-candidate/Interaction-candidate use. Published, live,
queued, committed, operational, and pending-presentation state survive that
boundary. An explicit reset followed by attempt completion still resets the
attempt exactly once.

All-storage reset is effective only before use or after teardown. Idle
quiescence tears down synchronously; active quiescence first refuses later
reservation/acquisition and waits for mandatory attempt completion before the
same all-storage teardown. Repeated quiescence is idempotent. Pending refusal
intent is one optional `PresentationPendingIntent`, never a payload or retry
history.

`DynamicStorageReleaseCounters` and the opt-in
`DynamicStorageDeinitializationCounter` are profile-local observation seams.
Their overflow or absence cannot change storage, cleanup, or return values.

Verification command:

```text
swift test --filter GiftUIRuntimeDynamicTests
```

Result: ten focused Dynamic tests passed under Apple Swift 6.3.3, including
four lifetime tests for reentry, candidate/committed separation, pending-intent
retention, active teardown, reset boundaries, and deinitialization.
