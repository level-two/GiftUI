# SPEC-001 T7.1 Exhaustive Failure Matrix

- Evidence kind: hardware-free semantic corpus
- Profiles: macOS Dynamic and Static share the normalized application owner
- Rows: 19 ordered admission, repository, and runtime failure conditions
- Result: pass

`exhaustive-failure-cases.tsv` records each capacity, availability, sequence,
identity, revision, phase, reentrancy, invariant, residual-policy, reserved-fact,
and terminal condition. Focused Swift tests execute the authoritative owner and
assert mandatory-effect order, zero-or-one policy calls, policy context and
result, last-complete-state preservation, quiescence, and fresh-graph recovery.
The checked matrix keeps diagnostic projection observational; T7.2 exercises
its profile variants independently.
