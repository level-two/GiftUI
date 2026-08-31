# SPEC-003 Milestone 5 Static/Dynamic Semantic Evidence

**Task:** `T5.2`

**Recorded:** 2026-08-31

The standalone SPEC-003 driver runs the same four focused XCTest targets under
the optimized macOS dynamic and static profile flags. It removes timings and
runner noise, sorts the passed test identifiers, and writes the complete
portable transcript to `semantics/complete-suite.tsv`.

The normalizer fails unless the executed suites cover facts, conservative
containment, ordered annotations, residual-policy validation and results,
operational health, diagnostic isolation, deterministic exhaustion, and both
Foundation and capability owner mappings. It also fails if a test is repeated
or no XCTest result is present. Each profile run fails when a matched
counterpart transcript differs byte-for-byte.

The matched runs executed 57 tests across the required nine categories. The
normalized dynamic and static transcripts were identical. Raw XCTest output,
normalized transcripts, full compiler commands, input hashes, and comparison
status remain in the generated profile reports under
`.build/contract-reports/spec-003/`.

This is host-executed semantic-equivalence evidence. ARMv6 and nRF evidence in
this milestone remains hardware-free cross-build evidence and does not claim
target execution.
