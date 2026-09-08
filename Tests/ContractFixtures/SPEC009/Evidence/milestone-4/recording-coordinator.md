# SPEC-009 T4.1 Recording Coordinator Evidence

The canonical recording fixture implements `ExecutionOpportunityRunner` and
drives the existing phase machine and wake accumulator. Its closed event
vocabulary records the empty-to-nonempty wake transition, atomic wake take,
every execution phase, result selection, and the final idle authoritative
semantic/presentation state.

The unchanged path records idle, admitting, mutating, deriving, finalizing,
result selection, and idle return, selecting the exact `noChange` operational
result. The published fixture path additionally records publishing and
offering, then preserves the published semantic and committed presentation
revisions in the idle event. Repeated wake reasons coalesce, a reason after
idle return creates a new transition, and successive cycles reserve fresh
identities.

```sh
swift test --filter RecordingCycleCoordinatorTests
ruby scripts/contracts/check-spec-009-recording-coordinator.rb
```

The coordinator imports only `GiftUI`, stores events through a caller-owned
sink, and creates no alternate semantic, layout, render, state, Interaction,
runtime, or backend contract. Ordered effect application remains T4.2.
