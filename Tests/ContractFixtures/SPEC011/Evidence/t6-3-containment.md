# SPEC-011 T6.3 Containment Evidence

The focused containment fixture separates the six candidate-frame contained
errors from the three active-cycle/runtime safety-not-proven errors.

For every contained error, tests prove the complete candidate is discarded,
the committed-state token is unchanged, and a mutation makes the state dirty
with exactly one coalesced wake; without mutation, no dirty wake is introduced.

For every safety-not-proven error, tests prove candidate discard, affected-
capture cancellation, exclusion of later normal cycles, and quiescence before
fatal-hook eligibility. The allowed residual set is exactly quiescence and an
already configured post-quiescence fatal hook, with neither continuation nor
paced retry.
