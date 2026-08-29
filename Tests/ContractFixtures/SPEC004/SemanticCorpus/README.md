# SPEC-004 Normalized Semantic Corpus

`cases.tsv` is an ordered profile-neutral registry. Each non-comment row has
four tab-separated fields:

1. unique lowercase kebab-case case identifier;
2. lowercase domain token;
3. ordered comma-separated fixed-width decimal or `0x` hexadecimal input
   words, or `-`; and
4. ordered comma-separated expected fixed-width words, or `-`.

Domains and word meanings are added with their implementation tasks. Drivers
must reject duplicate IDs, unknown domains, malformed/out-of-width words, and
any profile-specific addition, omission, reordering, or reinterpretation.
Human prose and concrete target/backend/device identities do not belong in
corpus rows.

Typed-resolver domains contain only values admitted by SPEC-004's failable
constructors. Raw-adapter domains stop before resolver invocation and record
their own exact validation result. The two corpora must never be merged to
claim that an unconstructible raw value reached the resolver.
