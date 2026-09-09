# SPEC-010 T7.2 Failure Policy Evidence

The focused adapter represents simultaneous local conditions as one bounded
12-bit set and selects them in SPEC-010's exact owner precedence. The exhaustive
pairwise corpus proves every individual condition and every higher/lower pair,
while the existing mutation-result and reconciliation fault corpora prove that
later cleanup failures cannot replace the first selected condition and cleanup
still completes.

The residual-input table distinguishes initial/candidate work, replacement
attachment, retired stale reports, contained phase violations, and terminal
safety-not-proven failures. It emits only a Failure Core `.failure` containing
the already-correlated fact, preserves the detection context, admits no paced
retry, fixes the sole attempt to ordinal zero of limit one, and emits no input
for the mandatory contained-phase row or before policy is permitted. Therefore
policy cannot weaken containment, narrow scope, reinterpret success, skip the
owner's prerequisite effects, or introduce an unbounded retry.
