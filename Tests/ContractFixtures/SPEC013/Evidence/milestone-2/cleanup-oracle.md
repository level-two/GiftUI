# T2.3 Stage and Cleanup Oracle

Date: 2026-09-12

Runtime Core now represents the seven normative detecting/terminal stages and
their cleanup rows as fixed-size `UInt8` enums and a bounded `UInt16` option
set. `RuntimeCleanupTracker` intersects the row with obligations that actually
began, returns actions in one deterministic ownership order, clears each action
as it is taken, and cannot return it twice. The production path contains no
array, cleanup closure, or dynamic history.

The table distinguishes prepublication candidate discard from
postpublication semantic preservation. Offer failure discards Interaction and
resets render/plan/attempt storage without rolling back published Semantic or
Observable state. Acceptance commits Interaction before attempt reset.

`RuntimeMutationApplicationState` is separate from cleanup obligations and
allows its applied transition once. No cleanup row can replay or roll back a
model mutation. Every failure row prohibits later fallible work.

Verification command:

```text
swift test --filter RuntimeCoordinatorCleanupTests
```

Result: four table-driven tests passed, covering every row, exact ordering,
partial acquisition, exactly-once draining, mutation replay prevention, and
publication boundaries.
