# SPEC-006 Expansion Values Evidence

`SemanticExpansionLimits`, `SemanticExpansionSummary`,
`SemanticExpansionError`, and `SemanticExpansionResult` now have the exact
package-visible fields, cases, raw codes, equality, and sendability required by
SPEC-006. Focused tests prove that the three required limits reject zero while
zero modifier and action limits remain valid, and that all five summary fields
are preserved.

The host compiler reports limits and summary sizes within 10 bytes, the local
error at exactly 1 byte, and the result within 12 bytes. Cross-profile layout
evidence remains assigned to T6.4. T2.1 remains open until the caller-owned
workspace/sink protocols and sole generic entry point are present.
