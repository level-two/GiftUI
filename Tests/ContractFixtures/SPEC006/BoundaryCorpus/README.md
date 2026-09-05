# SPEC-006 Boundary Corpus

`cases.tsv` records each independently exercised finite boundary. The numeric
columns describe below-limit, exact-limit, and one-over attempts; `overflow`
means the checked addition after `UInt16.max`. These are operation counts, not
allocation measurements or profile-private storage layouts.

`coincident-failures.tsv` records the competing conditions at one operation,
the first normative detecting point, its exact result, and the required
no-hook/no-publication/reuse outcome. Condition lists are ordered only for
readability; `detecting_point` is authoritative.

`framework-invariants.tsv` is restricted to test-only framework fault
injection. Its `body_evaluations` column counts actual body closure calls, so
the detectable `Never.body` row remains zero even though the attempted
recording is discarded.

`owner-mapping.tsv` records the complete SPEC-003 fact produced by the first
test-only owner that imports both contracts. The invalid-limits row is the
only row before an active cycle and therefore uses runtime scope.
