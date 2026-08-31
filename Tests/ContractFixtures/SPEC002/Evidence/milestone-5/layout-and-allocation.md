# SPEC-002 T5.3 Layout and Allocation Evidence

**Task:** `T5.3`

**Recorded:** 2026-08-31

## Four-profile layouts

Each pinned target compiler emits optimized LLVM IR from the exact Foundation
source plus `Instrumentation/LayoutProbe.swift`. The checker requires every
measurement function to reduce to a constant `UInt32`, records all 11 owned
values, and fails every exact or maximum size requirement.

All four profiles produced the same report (SHA-256
`d6cea172ff815f658db50182c0e1efe8b9cc1adf0aad7934c01f7564b38d3211`):

| Value | Size | Stride | Alignment | Requirement |
| --- | ---: | ---: | ---: | --- |
| `GeometryScalar` | 4 | 4 | 4 | exactly 4 |
| `Point` | 8 | 8 | 4 | at most 8 |
| `Size` | 8 | 8 | 4 | at most 8 |
| `Rect` | 16 | 16 | 4 | at most 16 |
| `ProposedSize` | 13 | 16 | 4 | at most 16 |
| `PointerPhase` | 1 | 1 | 1 | reported |
| `InputSourceID` | 2 | 2 | 2 | exactly 2 |
| `PointerSequenceID` | 4 | 4 | 4 | exactly 4 |
| `InputOrdinal` | 4 | 4 | 4 | exactly 4 |
| `PresentationRevision` | 4 | 4 | 4 | exactly 4 |
| `NormalizedPointerEvent` | 28 | 28 | 4 | at most 32 |

## Allocation and forbidden-facility boundary

`Instrumentation/OperationProbe.swift` exercises valid and rejected
construction, checked add/subtract/multiply, rectangles, phases, raw wrappers,
and normalized events with a varying fixed-width seed.

Both optimized macOS profiles execute 100 warmup iterations followed by 10,000
measured iterations under a malloc/calloc/realloc interposer:

```text
allocation_count=0
checksum=300105740
```

The identical checksum prevents the measured work from being eliminated and
proves dynamic/static operation equivalence for this path. ARMv6 and nRF
compile the same Foundation and operation sources to optimized target IR. The
resource checker scans the `exercise` function rather than unrelated runtime
metadata and rejects allocator, reflection, runtime-discovery, Objective-C,
task, or actor symbols. It separately rejects those facilities in production
Foundation source. Both cross-profile checks pass.

## Reproduction

```sh
scripts/contracts/run-spec-002.sh --profile macos-dynamic
scripts/contracts/run-spec-002.sh --profile macos-static
scripts/contracts/run-spec-002.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-002.sh --profile nrf52840-embedded
```

The ARMv6 and nRF results are compiler/IR evidence only. They do not claim
connected-target execution, deployment, or flashing.
