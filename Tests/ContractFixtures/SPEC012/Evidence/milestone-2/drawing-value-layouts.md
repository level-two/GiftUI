# SPEC-012 Drawing Value Layout Evidence

Plan task: `SPEC-012 T2.3`

The optimized LLVM IR probe compiles the five drawing values independently
with the pinned macOS dynamic, macOS static, Raspberry Pi ARMv6, and nRF52840
Embedded Swift compilers. Every profile produced the same layout:

| Value | Size | Stride | Alignment | Contract |
| --- | ---: | ---: | ---: | --- |
| `SubpathRange` | 4 | 4 | 2 | exactly 4 bytes |
| `DrawingPlanSummary` | 10 | 10 | 2 | exactly 10 bytes |
| `StraightLineStrokeHeader` | 40 | 40 | 4 | at most 40 bytes |
| `DrawingProductionError` | 1 | 1 | 1 | exactly 1 byte |
| `DrawingPlanResult` | 11 | 12 | 2 | at most 12 bytes |

Focused tests cover the nonempty checked `SubpathRange`, all nine exact error
raw values, summary/result equality and cases, every stroke-header field, and
`Copyable`/`Sendable` constraints. The values contain only fixed-layout GiftUI
values and integer counts; no reference, existential, closure, collection, or
pointer contributes to their meaning.

Reproduce each profile from the repository root:

```text
scripts/contracts/check-spec-012-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-012-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-012-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-012-value-profiles.sh --profile nrf52840-embedded
```
