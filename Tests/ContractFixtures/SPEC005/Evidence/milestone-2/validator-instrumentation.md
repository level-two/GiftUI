# T2.5 Validator Work and Allocation Evidence

Task `T2.5` extends the optimized macOS dynamic and static allocation probe to
construct a certified maximum-size synthetic package and call the complete
validator inside every measured iteration. Both variants report exactly
`allocation_count=0` and checksum `4004008340`. The measured path also retains
the maximum 256-comparison lookup, metric and record access, payload slice,
canonical byte traversal, canonical SHA-256, and raw payload SHA-256 work.

Focused counters prove one complete validation performs every bounded table
traversal even when an earlier predicate has already failed. For the valid
single-record fixture, the payload callback is invoked exactly once and its
single byte is visited exactly once by the payload digest pass. Exact counter
totals also account for the validator's range-completeness probes and canonical
manifest pass.

A contract-local assembly adapter counts one validator call during admission.
Four simulated frames containing 64 glyph lookups each leave that count at one,
proving the validated accessor path does not revalidate per glyph or per frame.
The maximum lookup fixture independently retains exactly 256 comparisons and
the canonical traversal fixture visits all 256 mappings, metrics, and records.

`check-spec-005-validator-instrumentation.rb` fail-closes on loss of any of
these probes. ARMv6 and nRF52840 cross-build the same collection-free validator
path but make no runtime-allocation or hardware-execution claim.
