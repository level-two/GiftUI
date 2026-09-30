# Raspberry Pi Frame-Cost Reduction, 2026-09-27

SPEC-001 T8.1 remains open. This is connected performance evidence for the
approved 240 x 240 logical analyzer stretched to the 480 x 320 PiScreen.
The target independently reported `armv6l` before each deployment. Both
executables passed the repository ARMv6 hard-float check and were installed
through `scripts/raspberry-pi/deploy.sh` without a service restart.

The baseline build added trace-only display-target counters to the previous
full-screen renderer. Its ARMv6 build ID was
`6df1597803a39cf1bbd34ce11daffc9f432ac37a`. In a bounded 45-second
foreground run, the [baseline trace](pi-performance-baseline-20260927.log)
recorded completed frame durations of 8.119-10.829 seconds. The target
copied about 219-220 KiB through 311-332 payloads and 3,577-3,815 small
regions per frame. That copy took 0.815-0.910 seconds; semantic/layout/drawing
derivation took 1.347-1.449 seconds; the remaining offer work was the largest
cost and grew with the waveform.

The optimized build uses conservative segment bounds, limits the candidate
pixel ranges for orthogonal multisegment strokes, and rasterizes one-pixel
orthogonal strokes directly. Its framebuffer copy prevalidates each row and
duplicates pixels directly for the Pi's exact 2x horizontal projection. The
independent SPEC-012 stroke masks, Pi host-native exact-pixel gate, Pi target
tests, and ARMv6 build passed. The deployed ELF build ID was
`a0416e38ff6a8e4263425a891c7118e1293122c2` and the stripped artifact's
SHA-256 was
`b031569b3e63dd43c2c3508b523a3fab8e8489cd77fca821d6f1ac54e364f2ea`.

In the same bounded foreground scenario, the
[optimized trace](pi-performance-optimized-20260927.log) recorded 12
completed frame durations of 3.363-3.551 seconds. Presentation derivation
remained 1.342-1.418 seconds; offer took 1.873-2.202 seconds, including
0.697-0.973 seconds in the framebuffer sink. The
[active raw framebuffer](pi-performance-optimized-frame-20260927.rgb565le.gz)
expands to 307,200 RGB565 little-endian bytes. Its
[viewable conversion](pi-performance-optimized-frame-20260927.png) shows the
full-width analyzer with title, gridded traces, labels, and controls during
the optimized run.

The reduction is material but still misses the required 250 ms frame
interval by more than an order of magnitude. No touch responsiveness,
event-loss, or sustained conforming 30-second scenario was established by
these timing runs. Further T8.1 performance work is required.

## Single Layout Validation

The Dynamic pipeline had a separate semantic layout-validation pass before
calling `layout`, which validates the same declaration itself. Removing that
redundant pass preserved the Dynamic pipeline tests (24 tests under
`-DGIFTUI_DYNAMIC_PROFILE`) and passed the ARMv6 hard-float build. The
deployed build ID was `bd3067b767e583cca1613dabdcac8916484eedf8`.
The [connected trace](pi-performance-single-validation-20260927.log) from a
bounded 25-second run records seven completed frame durations of
3.203-3.373 seconds. Derivation fell to 1.133-1.166 seconds. The 250 ms
cadence and connected touch gates remain open.

## Semantic Lookup Without Retained Caches

The Dynamic semantic store formerly rebuilt the full primitive/action list
and searched every possible intermediate identity on each child and modifier
lookup. The revised lookup selects direct children by path depth and compares
modifier ownership with the nearest layout ancestor. It retains no lookup
cache between frames. Dynamic storage and pipeline tests, the exact Pi
host-native raster gate, and the ARMv6 hard-float build passed. The deployed
build ID was `603d937196660ce87964ceb088897f9c02c0a223`; its stripped SHA-256
was `e90a1b598aeea847eb78c12c4e1cfda6a05100db770d452cda1329bc587eaba8`.

The [30-second connected trace](pi-performance-semantic-lookup-20260927.log)
records ten completed frame durations of 2.694-2.812 seconds and `exit=0`.
Derivation on those frames took 0.649-0.670 seconds. This improves the
previous 3.203-3.373-second result without changing the reviewed pixels.
The required 250 ms cadence and physical interaction gate remain open.

A prior retained-array cache trial passed host tests but the
[independent Pi run](pi-performance-retained-cache-rejected-20260927.log)
segfaulted after its first frame (`exit=139`). That code was discarded, and
the last verified binary was redeployed and completed a recovery run before
the nonretained lookup was tested. The retained cache is not part of the
current implementation.

## Rejected Framebuffer Row Buffer

A Linux-only trial assembled each projected region into a reusable physical
row and copied that row to the mapped framebuffer. The ARMv6 hard-float build
and [30-second connected run](pi-performance-row-scratch-20260927.log)
completed (`exit=0`), but ten measured frames took 2.716-2.875 seconds.
The framebuffer sink still took 0.872-1.025 seconds per frame, and the
result was no faster than the verified semantic-lookup build. The trial was
discarded and build ID `603d937196660ce87964ceb088897f9c02c0a223`
was rebuilt and redeployed after the target again reported `armv6l`.

The connected traces show that each frame still submits roughly 219-220 KiB
through more than 300 payloads and 3,500-3,900 regions. The 250 ms cadence
is a current T8.1 blocker. Any proposal to change the presentation strategy
must retain the approved raster, payload, memory, and output contracts and
must be validated against the exact Pi pixels and connected frame timing.
