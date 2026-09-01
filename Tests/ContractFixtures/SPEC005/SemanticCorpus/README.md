# SPEC-005 Normalized Semantic Corpus

`cases.tsv` is an ordered, profile-neutral registry. Each non-comment row has
five tab-separated fields:

1. a unique lowercase kebab-case case identifier;
2. a lowercase domain token;
3. ordered comma-separated fixed-width decimal or `0x` hexadecimal input
   words, or `-`;
4. ordered comma-separated expected fixed-width words, or `-`; and
5. an expected evidence-class token: `host`, `cross-built`, `simulator`, or
   `connected-target`.

Domains and exact word meanings are added with the implementation task that
owns them. Drivers must reject duplicate IDs, unknown domains or evidence
classes, malformed or out-of-width words, and any profile-specific addition,
omission, reordering, or reinterpretation. Human prose, filenames,
timestamps, addresses, and concrete platform font identities do not belong in
corpus rows.

The shared logical corpus uses `host` for executable host semantics and
`cross-built` only for target-compiled inspection. `simulator` and
`connected-target` rows remain absent unless a later owning integration and
the required authorization exist; their schema presence does not claim that
evidence.

The `validation-isolated` domain contains one input raw value and the same
expected `TextResourceValidationError` raw value. The `validation-pair` domain
contains two distinct ascending raw values and expects the lower value; the
focused host fixture executes both declaration orders for every registered
pair.
