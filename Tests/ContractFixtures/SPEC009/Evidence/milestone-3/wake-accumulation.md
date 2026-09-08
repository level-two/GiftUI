# SPEC-009 T3.1 Wake Accumulation Evidence

The internal focused accumulator owns exactly one normalized
`ExecutionWakeReasons` set, one `wakeOutstanding` bit, and one generic
`ExecutionWakeRequester`. Empty or masked-empty requests are ignored. The
first nonempty transition requests one wake; duplicate and additional reasons
coalesce into the stored set without a second request.

Idle opportunity entry takes the complete set and clears both stored reasons
and the outstanding bit in the same synchronous operation. A reason injected
after that take during admitting, mutating, deriving, publishing, offering, or
finalizing creates a fresh empty-to-nonempty transition. A non-idle take
cannot acknowledge the request, and a redundant idle opportunity returns an
empty set without requesting work.

```sh
swift test --filter ExecutionWakeAccumulatorTests
ruby scripts/contracts/check-spec-009-wake-accumulator.rb
```

The audit keeps the mechanism internal and rejects scheduling APIs,
synchronous run control, downstream owners, dynamic containers, suspension,
and retained work payloads. The requester returns no scheduling result and
the accumulator makes no cycle-membership decision.
