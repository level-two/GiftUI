# T3.2 Bounded Storage Contracts

Interaction exposes caller-owned candidate-record, committed-record, and hit-
region storage protocols. Each has an explicit `UInt16` capacity and count,
indexed borrowed reads, bounded append/reset, and no collection, allocator,
callable, handler, model, declaration, or layout borrow. Candidate records own
only finite values and an optional action generation. Profile owners provide
heap-backed bounded or generated fixed implementations later under SPEC-013.

The value-layout probe records `MemoryLayout` for the action, limits, candidate,
bound record, hit region, outcomes, and concrete profile workspaces; sizes are
evidence, not public ABI.
