# SPEC-010 T3.1 Candidate Lifecycle Evidence

The profile-neutral internal lifecycle validates candidate begin, per-
encounter reservation, and exactly one publish/discard finish without owning a
model or selecting profile packing. It accepts begin only during `.deriving`,
rejects nested entry, preserves a sticky first failure, and resets bounded
attempt state only after finish.

The fixture owns exactly two explicit association slots. Each encounter checks
staging, location, and registration capacity with checked `UInt16` successors
before recording its key. Focused fault cases prove the rejected association
never enters storage at each capacity boundary and a count equal to every
limit succeeds.

Discard returns `.candidateDiscarded`; unchanged publish returns `.unchanged`;
publish with additions/removals returns `.associationsCommitted`. Publish is
ordinary-failure-free after reservations; the injected impossible commit
refusal returns `.invariantViolation`. Begin/finish outside the lifecycle use
the exact contained, safety-not-proven, or reentrancy classifications, and a
completed storage value begins a clean later attempt.

The registered audit rejects dynamic collections, models, attachments, sinks,
handlers, tasks, exceptions, public/package lifecycle SPI, concrete profile
storage, and prohibited owners. Candidate association content remains
fixture-owned until SPEC-013 supplies production packing.
