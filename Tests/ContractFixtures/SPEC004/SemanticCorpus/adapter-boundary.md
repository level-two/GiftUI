# Raw Adapter and Typed Resolver Boundary

Raw adapters validate representation-level inputs before they can become
SPEC-004 declarations. Their fixture domain owns malformed fields, unknown or
empty option bits, invalid preferences, invalid region/alignment/count bounds,
duplicate/missing raw roles, and SPEC-002 extent conversion failures.

Typed resolver fixtures begin only after every failable constructor and the
role-addressed contribution buffer has admitted complete values. They own
compatibility, checked arithmetic, candidate normalization, stable primary-
reason precedence, optional/required absence, and immutable snapshot results.

A raw-adapter failure records zero resolver invocations and no partial typed
input. A typed incompatibility may not be short-circuited through an invented
raw failure. This separation keeps the complete constructible-pair precedence
corpus reproducible without claiming invalid bit patterns are resolver input.
