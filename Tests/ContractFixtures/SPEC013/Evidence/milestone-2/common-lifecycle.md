# T2.1 Common Coordinator Lifecycle

Date: 2026-09-12

`RuntimeCoordinatorLifecycle` supplies the common fixed-size construction and
entry-state mechanism used by both profiles. It represents every normative
state explicitly: unvalidated, validated, idle, active, quiescent, torn down,
and rejected.

The lifecycle retains the successful immutable `RuntimeStorageAudit` and the
latest complete `ExecutionContext` value. Separate admission and opportunity
entry ownership rejects reentry with `.reentrancyViolation`; unavailable or
terminal lifecycle states return `.requiredFacilityUnavailable`. Opportunity
acquisition requires an admitting context with a cycle identity, and release
requires the finalized idle context.

Quiescence is synchronous from idle and deferred during an active opportunity
until that opportunity releases its serialized entry. Teardown is permitted
once, admission and opportunities remain unavailable afterward, and no
terminal state can restart.

Verification command:

```text
swift test --filter RuntimeCoordinatorLifecycleTests
```

Result: seven focused lifecycle, construction, context-retention, entry,
reentry, quiescence, rejection, and teardown tests passed under Apple Swift
6.3.3.
