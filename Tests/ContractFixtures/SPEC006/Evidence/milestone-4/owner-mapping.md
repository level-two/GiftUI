# SPEC-006 First Owner Mapping and Diagnostic Isolation Evidence

Task `T4.4` is implemented by the test-only
`GiftUISemanticFailureAdapterFixture`, `BoundaryCorpus/owner-mapping.tsv`, and
`SemanticFailureAdapterTests`.

The adapter maps capacity, identity, and reentrancy errors to contained
semantic active-cycle facts and maps invariant violation to the same origin
and scope with `safetyNotProven`. Invalid limit construction remains local
`nil`; the owner maps it before the first cycle to `invalidValue`, semantic
origin, runtime scope, and contained disposition.

The diagnostic matrix covers disabled delivery plus accepted, saturated,
dropped, and failed sinks. A snapshot containing the local result, transcript,
summary counters, and primary fact remains exactly equal before and after each
variant. Diagnostics are therefore optional observation and cannot replace or
mutate correctness state.

The adapter target alone imports both modules. The SPEC-006 harness scans
`Sources/GiftUISemanticCore` and fails if it imports `GiftUIFailureCore`, while
the package target graph keeps Semantic Core dependent only on `GiftUI`.
