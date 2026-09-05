# SPEC-006 T2.2 Bounded Attempt Lifecycle Evidence

`SemanticExpansionAttempt` is the nonallocating, fixed-width coordinator used
by the sole generic expansion entry. It snapshots every caller-owned finite
capacity before begin, rejects an already-active workspace before touching the
sink, and keeps the first detected local error stable until atomic discard.

Focused `SemanticExpansionAttemptTests` exercise independently:

- successful workspace/sink begin, staged-complete publication exactly once,
  and idle reset;
- depth-before-path-entry, identity-before-operation, declared-count-before-
  storage, and storage-before-hook refusal;
- sufficient advertised capacity followed by refusal as
  `.invariantViolation`, rather than ordinary capacity exhaustion;
- fixed-width reservation through `UInt16.max` followed by refusal before
  wrap;
- no later operation after the first error, no partial publication on begin,
  stage, or publish failure, complete discard/reset, and clean reuse of the
  same caller-owned collaborators; and
- the temporary fail-closed generic entry lifecycle pending T2.3 traversal.

The coordinator carries only value counters, capacity snapshots, and local
lifecycle state. It retains no declaration or payload, allocates no fallback,
imports no failure or runtime-profile module, and leaves canonical traversal
order to T2.3.
