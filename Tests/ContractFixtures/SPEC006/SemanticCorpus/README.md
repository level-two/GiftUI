# SPEC-006 Semantic Corpus Schemas

All registries are ordered, profile-neutral TSV files. Comment lines begin
with `#`. Drivers must reject duplicate IDs, unknown tokens, malformed rows,
missing referenced rows, and profile-specific additions, omissions,
reordering, or reinterpretation.

## Input cases

`cases.tsv` has five fields:

1. unique lowercase kebab-case case identifier;
2. a closed declaration-shape token introduced by the task that owns it;
3. ordered comma-separated symbolic fixture inputs, or `-`;
4. expected result case: `success` or one of `capacity-exhausted`,
   `invalid-identity`, `reentrancy-violation`, `invariant-violation`, or
   `invalid-limits`;
5. evidence class: `host`, `cross-built`, `simulator`, or `connected-target`.

## Canonical transcript

`canonical-transcript.tsv` has six fields:

1. case identifier from `cases.tsv`;
2. zero-based decimal event index;
3. canonical path;
4. event kind;
5. symbolic role;
6. zero-based modifier chain index, or `-`.

Paths are slash-separated sequences using only `root`, `custom-body`,
`fixed-child(0...4)`, `conditional-branch(0|1)`, `optional-presence`, and
`declaration-role(<symbolic-role>)`. Event kinds are exactly
`enter-structural-occurrence`, `evaluate-custom-body`,
`stage-semantic-occurrence`, `apply-modifier`, and `associate-action`.
Fixture roles are bounded symbolic tokens declared by the owning corpus row.
They are comparison vocabulary only: production identity may not use these
strings, metatype addresses, hashes, object identity, or exposed raw bytes.

`apply-modifier` alone requires the chain-index field. All other event kinds
use `-`. A failed attempt publishes no transcript rows; detecting-point
instrumentation belongs to a separately labeled attempted-event report.

## Normalized results

`normalized-results.tsv` has ten fields:

1. case identifier from `cases.tsv`;
2. result token from the closed result set above;
3. semantic-node count, or `-` on failure;
4. body-evaluation count, or `-` on failure;
5. modifier-application count, or `-` on failure;
6. action-occurrence count, or `-` on failure;
7. maximum observed depth, or `-` on failure;
8. transcript row count, which must be `0` on failure;
9. symbolic identity-relation set identifier, or `-`;
10. evidence class using the same token as the input row.

Successful counts and greatest path depth must equal the canonical transcript.
Structural-entry events do not add a summary counter. Normalized results never
contain profile-private identity bytes, addresses, timing noise, paths to
generated files, or connected-hardware claims inferred from a cross-build.
