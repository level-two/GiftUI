# SPEC-003 Milestone 2 Correctness-Path Probe

Both optimized macOS profiles ran the checked-in allocation and step probe
with Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`), target
`arm64-apple-macosx26.0`, and `-O -whole-module-optimization`.

| Profile | Measured iterations | Heap allocations | Counted steps | Checksum |
| --- | ---: | ---: | ---: | ---: |
| macOS dynamic | 10,000 after 100 warm-up calls | 0 | 37 | 1,328,530 |
| macOS static | 10,000 after 100 warm-up calls | 0 | 37 | 1,328,530 |

The measured path constructs and normalizes a failure, propagates it, creates
a non-success residual-policy input, dispatches through a generic specialized
policy, records and queries operational health, and consumes a fixed-width
checksum. Diagnostics are absent. The allocation counter is reset after
warm-up and read before printing or failure reporting.

The driver records the complete commands, source hashes, generated image
hashes, ordinary Core undefined symbols, and probe undefined symbols under
`.build/contract-reports/spec-003/<profile>/`. The probe executable visibly
retains Swift printing/failure-reporting allocation symbols after the measured
boundary; the interposer observes zero calls before its counter is read.

This is host Milestone 2 evidence, not final resource conformance. Milestone 5
must repeat the measurement from pristine matched images, resolve every
compiler/runtime call in final disassembly, and produce the cross-profile
allocation, stack, code, and instruction evidence.
