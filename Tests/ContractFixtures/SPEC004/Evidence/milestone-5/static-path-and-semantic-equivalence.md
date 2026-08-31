# SPEC-004 Milestone 5 Static Path and Semantic Equivalence Evidence

**Task:** `T5.2`

**Recorded:** 2026-08-31

The optimized static allocation probe measures 10,000 complete capability
initialization iterations after warmup. Each iteration constructs all four
contributions, inserts them into fixed storage, resolves with caller-owned
workspace, constructs the bounded validation result and optional immutable
snapshot, stores it, and reads it. The malloc/calloc/realloc interposer reports
exactly zero allocations.

The instrumented semantic transcript records the widest success path at 44
primitive operations and an early negative path at eight, each with one
resolver invocation and one validation-result construction. Every later
negative is a prefix of, or omits work from, the widest two-candidate,
two-encoding path. Ten thousand repeated snapshot reads record zero primitive
operations and zero resolver invocations. All remain below the 96-operation
limit.

Both macOS profile drivers compare the complete 42-row semantic transcript
byte-for-byte. A dedicated fail-closed check requires the exact allocation and
operation rows and rejects instrumentation/count symbols in the production
capability image. The ARMv6 and nRF production builds likewise omit the
instrumentation condition; their execution remains hardware-free cross-build
evidence.
