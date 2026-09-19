# SPEC-001 T7.2 Diagnostic Profile Equivalence

- Evidence kind: hardware-free Dynamic/Static semantic corpus
- Projection modes: omitted, enabled, filtered, saturated, dropped, failing
- Result: pass

Every mode admits the same reserved operational-failure fact through the
Dynamic retained endpoint and Static caller-owned endpoint. The executable
matrix requires byte-identical semantic diagnostics, `BoundedText`, normalized
failure values, unchanged revision, and visible error state. Projection result
differences remain observational and cannot change admission, mutation, or
failure semantics.
