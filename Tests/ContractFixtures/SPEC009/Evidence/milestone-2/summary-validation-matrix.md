# SPEC-009 Summary Validation Matrix Evidence

Plan task: `SPEC-009 T2.4`

The focused suite exhaustively compares both failable value initializers with
independent finite predicates:

- 768 admission combinations span equality and one-over limits, disabled
  completion capacity, semantic-action/input count ordering, and both intent
  bits.
- 10,368 cycle-summary combinations span absent/present semantic and
  presentation revisions, all semantic/logical/intent dispositions, absent,
  matching, and mismatched pending intent, and every normalized operational
  event subset.

A separate fixture-owned history oracle accepts all thirteen rows in
SPEC-009's terminal-state matrix and rejects contradictions visible only by
comparing entry state, reserved semantic/candidate/presentation identities,
and the completed summary. It covers accepted commit, both pending refusal
forms, retry exhaustion, non-retryable refusal, post-publication failure,
both identity-exhaustion positions, both presentation-facility-loss positions,
and clean/dirty pre-publication termination.

Historical storage remains fixture-only. T2.4 introduces no coordinator or
profile representation and does not duplicate history in `RunCycleSummary`.

Reproduce from the repository root:

```text
swift test --filter SummaryValidationMatrixTests
```
