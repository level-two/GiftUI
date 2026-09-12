# SPEC-011 T6.2 Failure Precedence Evidence

`InteractionVisibleFailures` is a finite inline bit set. Selection checks the
approved order explicitly: reentrancy, phase, domain, missing target, identity,
geometry, action value, capacity, then invariant. The implementation does not
derive precedence from the error raw values.

Focused tests cover all nine individual conditions, all 36 unordered pairs at
one boundary, an empty set, and duplicate insertion. Every pair is also an
explicit canonical row in `failures.yaml`, making omitted or reordered pair
coverage visible to the fixture harness.
