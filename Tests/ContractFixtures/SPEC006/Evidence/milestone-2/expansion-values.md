# SPEC-006 Expansion Values Evidence

`SemanticExpansionLimits`, `SemanticExpansionSummary`,
`SemanticExpansionError`, and `SemanticExpansionResult` now have the exact
package-visible fields, cases, raw codes, equality, and sendability required by
SPEC-006. Focused tests prove that the three required limits reject zero while
zero modifier and action limits remain valid, and that all five summary fields
are preserved.

The caller-owned workspace and sink protocols now report every finite path,
identity, and staging capacity and expose begin, stage, publish, discard, and
reset operations without importing a runtime profile or failure module. The
sole generic `expandSemanticTree` entry accepts a borrowed root, immutable
limits, and `inout` collaborators. Its same-workspace active check already
fails before touching the sink. T2.2 supplies the bounded lifecycle beneath
that entry, and T2.3 now supplies its sealed traversal visitor.

The host compiler reports limits and summary sizes within 10 bytes, the local
error at exactly 1 byte, and the result within 12 bytes. Cross-profile layout
evidence remains assigned to T6.4.
