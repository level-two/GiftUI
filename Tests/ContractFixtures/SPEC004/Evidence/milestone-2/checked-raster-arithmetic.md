# SPEC-004 T2.1 Checked Raster Arithmetic Evidence

The production `GiftUICapabilities` source contains one internal,
allocation-independent arithmetic seam. It consumes typed requirement,
realization, surface, policy, and selected-encoding values and returns either
the exact fixed geometry/usage record or the assigned bounded unavailable
reason.

The focused unit suite covers:

- RGB565 and RGBA8888;
- full-surface and deterministic tallest tiled regions;
- equal and unequal row alignments;
- the exact `480 x 4 x 2 = 3,840` nRF52840 usage;
- the maximum constructible coprime-alignment LCM and maximum unaligned row;
- the constructible shared usage overflow assigned to `.raster`; and
- exact raster, payload, and in-flight three-owner minima, including zero.

`SemanticCorpus/cases.tsv` registers 22 normalized cases. They additionally
cover each possible tiled-height minimum, width/full-height rejection, and
all nine capacity owners at equality and first excess. The
macOS driver compiles `SemanticProbe/main.swift` with the production source,
executes it, and compares its complete transcript byte-for-byte with the
checked-in corpus.

The optimized allocation probe compiles the production source with its
instrumented entry point, exercises the arithmetic seam 10,000 times, and
reports `allocation_count=0` in both macOS profiles.

Validated commands on 2026-08-30:

```text
swift test --filter GiftUICapabilitiesTests
scripts/contracts/run-spec-004.sh --profile macos-dynamic
scripts/contracts/run-spec-004.sh --profile macos-static
scripts/contracts/run-spec-004.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-004.sh --profile nrf52840-embedded
scripts/test.sh
```

All commands passed. Standalone reports are written under
`.build/contract-reports/spec-004/<profile>/`; each macOS normalized arithmetic
transcript is `semantics/arithmetic.tsv`. ARMv6 and nRF52840 results are
hardware-free cross-build evidence and do not claim connected-target
execution, deployment, or flashing.
