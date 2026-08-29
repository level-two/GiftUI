# Shared Semantic Corpus

`cases.tsv` is an ordered, profile-neutral registry. Each non-comment row has
four tab-separated fields:

1. a unique lowercase kebab-case case identifier;
2. a lowercase domain token naming the SPEC-003 fixture family;
3. an ordered comma-separated list of fixed-width decimal or `0x` hexadecimal
   input words, or `-` for no input words; and
4. an ordered comma-separated list of expected fixed-width words, or `-` for
   no output words.

Domain tokens and word meanings are added beside their implementation task.
Drivers must reject duplicate identifiers, unknown domains, malformed or
out-of-width words, and differences between this checked-in order and any
generated profile input. Human prose, compiler-specific values, and
target-only semantics do not belong in the rows.
