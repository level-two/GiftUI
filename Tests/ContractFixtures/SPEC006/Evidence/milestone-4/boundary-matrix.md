# SPEC-006 Independent Boundary Matrix Evidence

Task `T4.1` is implemented by `BoundaryCorpus/cases.tsv`,
`SemanticExpansionValueTests`, `SemanticExpansionAttemptTests`, and the
zero-action/modifier cases in `SemanticDeclarationCorpusTests`.

The tests exercise below-limit, exact-limit, and one-over behavior separately
for declared depth, semantic-node, body, modifier, and action limits; workspace
path and identity capacities; and every sink storage capacity. Required zero
limits fail construction while zero modifier and action limits construct and
fail only when those operations occur. A combined exact-capacity attempt
publishes its complete nonzero-depth summary once.

Every `UInt16` counter and path depth reaches `UInt16.max` and rejects the next
checked reservation before wrap. One-over cases keep the first local error,
publish no summary, reset the workspace, and perform no retry, truncation,
overwrite, recursive fallback, or alternate hook. A rejected action fixture's
declaration-only lifetime token is released after return and no staged event
becomes current.

Allocation behavior remains measured by the dedicated Milestone 6 resource
task; this boundary fixture contains no allocating fallback path.
