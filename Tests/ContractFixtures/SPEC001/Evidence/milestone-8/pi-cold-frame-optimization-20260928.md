# Pi complete-frame optimization — 2026-09-28

The Signal Analyzer's selected Pi path still performs a complete rendering
pass. This investigation runs on `feature/pi-cold-frame-path` after the
bounded semantic and layout lookup changes. Partial presentation and
cross-frame work reuse are deferred in FW-024 and FW-025. The connected board
reported `armv6l`; all runs used a foreground executable and did not restart
a service.

## Affected-pixel run scanning

Commit `d941704e` adds a bounded run query to tile storage. The Pi storage
scans its affected flags through a borrowed buffer, while other storage types
retain the original per-pixel algorithm through a default implementation.
The emitter uses the returned maximal row run in both normal and draining
paths. Payload bytes, region boundaries, work limits, and operation-major
order are unchanged. The focused emitter suite (9 tests) and exact Pi
host-native raster gate passed. A clean ARMv6 hard-float build passed with
build ID `9049cc70e580193da3b8b22c3c5494072def52e9`.

The [baseline 60-second frame trace](pi-layout-lookup-frame-trace-20260928.log)
and both [candidate](pi-cold-run-scanner-trace-20260928.log)
[60-second runs](pi-cold-run-scanner-repeat-20260928.log) used
`GIFTUI_PI_TRACE=1` without optional inner timers. The first 15 steady frames
have identical payload, region, and byte counts in the same order across all
three runs.

| Application phase, all complete steady frames | Baseline (32) | Candidate (35) | Repeat (35) |
| --- | ---: | ---: | ---: |
| **Total frame service** | **1,837.182 ms** | **1,662.330 ms** | **1,661.297 ms** |
| Presentation derivation | 185.092 ms | 194.445 ms | 190.547 ms |
| Offer excluding framebuffer sink | 819.660 ms | **667.826 ms** | **670.936 ms** |
| Framebuffer sink | 829.641 ms | 797.127 ms | 796.843 ms |

The repeated offer reduction is consistent with fewer per-pixel flag calls.
The whole-frame improvement across separate runs is about 175 ms (9.5%);
sink differences are not assigned to the scanner. Candidate frame service
remains about 6.65 times the 250 ms target. The trace measures application
service, not physical panel completion or touch response.

## RGB565 pixel writes

Commit `432d67ca` lets a display writer accept one RGB565 pixel in a single
checked call. The Pi writer appends the two canonical bytes together; other
writers retain the prior two byte calls through a default implementation.
The focused emitter and Pi target suite (20 tests) and the exact Pi host-native
raster gate passed. A clean ARMv6 hard-float build passed with build ID
`c091b39aca3c204ecbf22b465f9e8156c7d4dacf`.

Two [60-second](pi-cold-pixel-writer-trace-20260928.log)
[connected traces](pi-cold-pixel-writer-repeat-20260928.log) completed normally.
The first 15 steady frames again have the same payload, region, and byte
counts as the scanner-only candidate in order.

| Application phase, all complete steady frames | Scanner repeat (35) | Pixel writer (36) | Pixel writer repeat (38) |
| --- | ---: | ---: | ---: |
| **Total frame service** | **1,661.297 ms** | **1,604.151 ms** | **1,559.083 ms** |
| Presentation derivation | 190.547 ms | 191.034 ms | 191.819 ms |
| Offer excluding framebuffer sink | 670.936 ms | 631.941 ms | 572.992 ms |
| Framebuffer sink | 796.843 ms | 778.571 ms | 791.529 ms |

Both candidate runs improve whole-frame service on the matched workload.
The size of the offer reduction varies across runs, so the full difference
cannot be assigned to the new writer call. The best observed 60-second mean
is still 6.24 times the 250 ms period. Physical panel completion remains
unmeasured.

## RGB565 tile pixel reads

Commit `4b9e5c6b` lets tile storage return both bytes of one RGB565 pixel in a
single checked call. The Pi storage reads both bytes with one bounds check;
other storage types retain the prior two byte reads through a default
implementation. The focused emitter suite (9 tests) and the exact Pi
host-native raster gate passed. A clean ARMv6 hard-float build passed with
build ID `36daf91d4bc42a9281452fee0d68623af3a152dd`.

Two more [60-second](pi-cold-pixel-read-trace-20260928.log)
[connected traces](pi-cold-pixel-read-repeat-20260928.log) completed normally.
Their first 15 steady frames again match all earlier runs' payload, region,
and byte counts in order.

| Application phase, all complete steady frames | Pixel writer repeat (38) | Paired read (38) | Paired read repeat (38) |
| --- | ---: | ---: | ---: |
| **Total frame service** | **1,559.083 ms** | **1,538.076 ms** | **1,537.141 ms** |
| Presentation derivation | 191.819 ms | 189.244 ms | 188.364 ms |
| Offer excluding framebuffer sink | 572.992 ms | 563.391 ms | 547.441 ms |
| Framebuffer sink | 791.529 ms | 782.341 ms | 798.468 ms |

The paired-read total was stable across its two runs. The current complete
frame averages about 1.538 seconds, roughly 300 ms (16%) below the preceding
lookup branch's 1.837-second run and about 6.15 times the 250 ms target.
These comparisons span separate runs and do not isolate the exact contribution
of each changed call. Mean application cadence is about 0.65 frames/s.

The default host test command lacks `GIFTUI_DYNAMIC_PROFILE` and produced
drawing invariant failures in dynamic presentation tests. The same previously
failing presentation test passed with that flag, and the full host suite then
passed **1,144 tests in 17 suites** using
`swift test --disable-sandbox -Xswiftc -DGIFTUI_DYNAMIC_PROFILE`.

## Initial presentation in these runs

The first `pi-present-us` entry precedes the steady-frame duration entries.
It measures presentation derivation and offer for the first frame, but does
not include process startup, framebuffer setup, physical panel completion, or
visible latency. Its workload was identical across the baseline and final
candidate runs: 311 payloads, 3,577 regions, and 218,874 payload bytes.

| Initial presentation phase | Lookup baseline | Paired read | Paired read repeat |
| --- | ---: | ---: | ---: |
| **Derivation + offer** | **1,798.604 ms** | **1,578.635 ms** | **1,589.878 ms** |
| Derivation | 258.298 ms | 258.004 ms | 260.822 ms |
| Offer excluding sink | 771.389 ms | **502.478 ms** | **485.033 ms** |
| Framebuffer sink | 768.917 ms | 818.153 ms | 844.023 ms |

The complete first presentation work is about 209–220 ms lower in these
separate runs. The sink varied in the opposite direction; this is not an
end-to-end cold-start or panel-visible latency measurement.

## Current first-frame derivation split

After restoring the verified build ID `36daf91d4bc42a9281452fee0d68623af3a152dd`, a
[20-second foreground trace](pi-cold-derive-profile-20260928.log) enabled the
existing optional `GIFTUI_PI_TRACE_DERIVE` timers. The board reported `armv6l`,
and the deployed executable's SHA-256 matched the local artifact:
`71f50e2fe4fd5faf07f2085b6b96a570485bfabe878c9fc9149e178387903954`.
The first derivation took 258.388 ms inclusive. Its subphases were semantic
expansion/publication 141.273 ms, layout 74.591 ms, drawing 2.586 ms,
render preflight 33.276 ms, and interaction 4.917 ms. The 13 subsequent
derivations averaged 76.926, 68.351, 1.979, 34.954, and 1.825 ms in the
same order. The first-frame priority within derivation is now semantic work,
not layout. These optional timers add overhead and do not measure process
startup or visible panel completion.

## Remaining complete-frame options

The current sink still consumes roughly 790 ms, and the offer outside it
roughly 547–563 ms, after these changes. The separate
`experiment/pi-frame-paths-20260928` branch measured a target-owned frame
accumulator at 1,133.990 ms mean service, a full-surface raster replay at
340.445 ms in an instrumented pass, and a separate full-surface transport
probe at 6.803 ms median. These are different experiments and must not be
added or presented as an end-to-end full-surface result. A selected Pi
full-surface realization or extra target framebuffer would change the
approved SPEC-014 BI-006 resource and tiling contract, so it requires
architecture and Specification review before production adoption. The current
complete-frame improvements do not depend on partial damage or cross-frame
reuse.
