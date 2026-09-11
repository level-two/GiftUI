# T8.2-T8.4 Four-Profile Gate

All four exact commands passed from clean revision
`986a8a0c7378184213821144d07581512da12e31` with common run ID
`986a8a0c7378184213821144d07581512da12e31-59a92effaec731f5` and full input
digest `59a92effaec731f593df6bb49ac2d157e16977740752ab41cceaaae26de21140`.
The immutable local reports are under
`.build/contract-reports/spec-007/<run-id>/<profile>/`.

| Profile | Evidence classification | Primitive / modifier | Limits / summary / error / result | Workspace bytes | Layout image bytes |
| --- | --- | ---: | ---: | ---: | ---: |
| macOS dynamic | host execution and inspection | 9 / 32 | 10 / 28 / 1 / 28 | 350,488 | 77,264 |
| macOS static | host execution, SIL, and inspection | 9 / 32 | 10 / 28 / 1 / 28 | 350,488 | 77,264 |
| Raspberry Pi ARMv6 | cross-build and inspection | 9 / 32 | 10 / 28 / 1 / 28 | 350,488 | 77,200 |
| nRF52840 | Embedded Swift cross-build and ELF inspection | 9 / 32 | 10 / 28 / 1 / 28 | 350,488 | 32,736 |

Every target-derived value is within the SPEC-007 ceiling. The workspace size
and stride are equal and back the exact fixture capacities with inline finite
storage. Target IR reports zero heap-allocation calls in the static layout
entry. The macOS-static SIL audit independently rejects allocation
instructions, and the nRF symbol audit rejects Swift allocation entry points.

Every report records the exact Signal Analyzer limits
512/64/4096/512/4096 and observed high-water values: 24 scopes, depth 5,
10 text scalars, 2 lines, and 9 positioned glyphs. Depth 5 is also the maximum
simultaneous recursive layout-frame count. All profiles hash the same canonical
fixture corpus and report the same target-derived owned-value layouts. The
semantic boundary scan rejects a second node collection or retained semantic
or text-resource borrow.

The nRF object reports `Tag_CPU_arch: v7E-M` and
`Tag_ABI_VFP_args: VFP registers`. Raspberry Pi and nRF results are explicitly
cross-build/inspection evidence only. Every report records `false` for remote
access, deployment, service restart, simulator execution, connected-target
execution, and flashing.

Reproduce with:

```console
scripts/contracts/run-spec-007.sh --profile macos-dynamic
scripts/contracts/run-spec-007.sh --profile macos-static
scripts/contracts/run-spec-007.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-007.sh --profile nrf52840-embedded
```
