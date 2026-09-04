# T5.5 Resource-Only Timing Evidence

T5.5 completed on 2026-09-04 with the Apple Swift 6.3.3 compiler and macOS
26.5 SDK used by the SPEC-005 macOS dynamic and static profiles.

The optimized host-executed probe measures only scalar mapping, metric lookup,
raster-record lookup, and synchronous bitmap payload borrowing through the
adopted reference package. It does not validate the package in the measured
loop and performs no layout, rasterization, cache access, or transfer.

The representative workload is 103 admitted ASCII scalars, matching the fixed
title, subtitle, Ready status, four channel names, four level labels, controls,
and visible-window labels. The maximum workload is the approved SPEC-007
Signal Analyzer fixture ceiling of 4,096 positioned glyphs; every lookup uses
U+00B0, the last mapping record, to exercise maximum admitted linear mapping
work. Each result is the greatest per-workload average from nine optimized
batches after warmup.

| Profile | Representative worst | Maximum worst | Interval |
| --- | ---: | ---: | ---: |
| macOS dynamic | 52,857 ns | 2,442,299 ns | 250,000,000 ns |
| macOS static | 53,480 ns | 2,456,250 ns | 250,000,000 ns |

Both workloads fit the presentation interval independently, leaving more than
247 milliseconds for work owned by later contracts. This evidence makes no
claim about SPEC-007 layout time or SPEC-014 raster, cache, and transfer time,
and it is not connected-target or concurrent-capture evidence.

Reproduce the checked output through either macOS profile of
`scripts/contracts/run-spec-005.sh`; the immutable report contains
`semantics/resource-timing.txt` and the compiled probe identity.

