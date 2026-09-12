# T2.5 Common Quiescence Oracle

Date: 2026-09-12

Runtime Core now provides fixed-size idle and active-cycle quiescence plans.
Both refuse admission first, cancel pointer sources, detach Observable State,
release queues and committed routing, and permit all-storage reset only after
the teardown sequence. The active plan additionally finishes mandatory active
cycle containment before detachment and release.

Every quiescence plan explicitly prohibits a new cycle, endpoint offer,
handler call, and diagnostic call. `RuntimeQuiescenceTracker` drains the finite
plan in normative order and cannot return an action twice. It stores no
callbacks or dynamic collection.

The common lifecycle moves idle coordinators to quiescent synchronously.
Active coordinators remain active only until their mandatory opportunity
release, then become quiescent and tear down once. Repeated requests do not add
work, and admission remains unavailable after quiescence or teardown.

Verification command:

```text
swift test --filter RuntimeCoordinatorQuiescenceTests
```

Result: three focused plan, prohibition, lifecycle, idempotence, and teardown
tests passed under Apple Swift 6.3.3.
