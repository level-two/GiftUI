# SPEC-006 Framework Invariant Injection Evidence

Task `T4.3` is implemented by
`BoundaryCorpus/framework-invariants.tsv` and focused tests across
`SemanticDeclarationCorpusTests`, `SemanticReentrancyTests`,
`SemanticExpansionAttemptTests`, and `SemanticExpansionTraversalTests`.

The framework-only injections force an identity alias, same-workspace
reentrancy, missing and multiple visitor categories, a sink that refuses
advertised storage, and a custom-body category whose declared body is `Never`.
They return the exact `invalidIdentity`, `reentrancyViolation`, or
`invariantViolation` result, publish no partial recording, reset their
workspace, and preserve later reuse.

Semantic Core detects `Declaration.Body == Never` after the body reservation
and before invoking the body closure. The poison counter therefore remains
zero and the unavoidable trap does not run. This recoverable claim is limited
to the framework-owned traversal hook; arbitrary client traps remain outside
the contract.
