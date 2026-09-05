# SPEC-006 Boundary Corpus

`cases.tsv` records each independently exercised finite boundary. The numeric
columns describe below-limit, exact-limit, and one-over attempts; `overflow`
means the checked addition after `UInt16.max`. These are operation counts, not
allocation measurements or profile-private storage layouts.
