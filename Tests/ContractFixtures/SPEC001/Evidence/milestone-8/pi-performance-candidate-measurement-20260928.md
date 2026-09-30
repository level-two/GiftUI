# Pi frame performance candidate measurement — 2026-09-28

This connected measurement covers revision `b3449ca4` of
`feature/pi-frame-performance`, including the three candidate changes recorded
in [the candidate record](pi-frame-performance-candidate-20260927.md). The
[raw trace](pi-performance-candidate-connected-20260928.log) retains every
per-frame timer and workload count.

## Run identity and method

- The project-local Swift 6.3.2 ARMv6 toolchain doctor passed. The release
  cross-build passed the repository's ELF, ARMv6, and hard-float checks;
  executable build ID: `5135704b50e6a0b8acfa10a54e2514affa43b797`.
- The deployment script checked that the target reported `armv6l` and
  installed the executable without restarting a service. Independent local
  and target SHA-256 checks both returned
  `e5025d55551f58daaca2cd6bbff96d0be86ac79734ae29a1a2515721217040ae`.
  The target framebuffer reported 480 × 320 pixels, 16 bits per pixel,
  and 960 bytes per row.
- The target ran `GIFTUI_PI_TRACE=1` with the deployed
  `--run-signal-analyzer` executable under a 60-second TERM timeout. The
  foreground command exited 0 and reported `status=completed`. One initial
  presentation was excluded; 25 complete steady frames were analyzed. No
  touch input was supplied.
- Each `pi-frame-duration-us` closes the preceding `pi-present-us` and
  `pi-target-us` pair. The non-overlapping offer remainder is calculated per
  frame as `offer - sink`; other service time is `frame - derive - offer`.
  The timer covers the application's frame service, not completion of the
  physical SPI panel update.

## Current steady-frame timing

Times below are milliseconds, from all 25 completed steady frames.

| Non-overlapping phase | Mean | Median | Observed range | Share of frame mean |
| --- | ---: | ---: | ---: | ---: |
| **Total frame service** | **2,322.267** | **2,311.684** | **2,209.501–2,487.783** | **100%** |
| Presentation derivation | 651.328 | 646.374 | 636.122–737.316 | 28.0% |
| Offer excluding framebuffer sink | 828.172 | 829.737 | 782.601–886.238 | 35.7% |
| Framebuffer sink | 840.534 | 842.093 | 758.728–918.866 | 36.2% |
| Other frame-service time | 2.233 | 1.890 | 1.754–5.020 | 0.1% |

The mean frame-service cadence is **0.431 frames/s**, or 9.29 times the
required 250 ms frame period. The offer timer is inclusive of the sink; its
mean is 1,668.706 ms and must not be added to the sink again.

The 25 frames submitted a mean 220,536 RGB565 payload bytes (range
219,770–221,102), 337.72 payloads (326–346), and 3,913.36 regions
(3,720–4,070) per frame. These are submitted application bytes, not unique
surface pixels or measured SPI traffic.

## Matched-workload comparison with the last verified build

The first ten steady candidate frames have exactly the same payload,
region, and byte counts as the ten steady frames in the
[last verified trace](pi-performance-semantic-lookup-20260927.log), in the
same order. Their respective means are 331.3 payloads, 3,808 regions, and
220,098.2 bytes. This subset avoids comparing the older ten frames with
later candidate frames whose workload counts have grown. The runs remain
separate hardware observations, not a controlled benchmark.

| Non-overlapping phase | Prior ten-frame mean, ms | Candidate first-ten mean, ms | Change, ms |
| --- | ---: | ---: | ---: |
| **Total frame service** | **2,753.772** | **2,295.028** | **−458.744 (−16.7%)** |
| Presentation derivation | 658.605 | 644.017 | −14.588 |
| Offer excluding sink | 1,187.811 | 808.771 | −379.040 |
| Framebuffer sink | 904.795 | 839.711 | −65.084 |
| Other service time | 2.560 | 2.528 | −0.032 |

The candidate's measured reduction is concentrated in the offer outside the
sink. The sink is also lower, while derivation is close to the prior run.
These timer boundaries cannot assign the changes individually to the tile
scan, framebuffer row copy, or per-run offset commits. They also do not split
the current offer into rasterization and payload formation, or the current
sink into projection and mapped writes. The older detailed profile measured
those internals on a different build and must not be reused as current
component timings.

## Focused current-source profiles

Two temporary releases used the same candidate source plus timer code in an
ignored `.build/raspberry-pi/profile-candidate-src` copy. The separate
profiling executable did not replace the stock candidate executable on the
Pi. Both the [light timer patch](pi-performance-candidate-light-instrumentation-20260928.patch)
and [detailed timer patch](pi-performance-candidate-detailed-instrumentation-20260928.patch)
apply cleanly to revision `b3449ca4`. The detailed variant adds clocks
inside each emitted run. Both instrumented builds passed the ARMv6
hard-float binary check, were independently hash-checked on the target, and
ended with `status=completed`. Their first ten steady frames have exactly the
same payload, region, and byte counts as the stock first ten.

| Run | Build ID | SHA-256 | Steady frames | First-ten mean frame, ms | Increase versus stock first ten |
| --- | --- | --- | ---: | ---: | ---: |
| [Light profile](pi-performance-candidate-light-profile-20260928.log) | `b3adb6d4724bfeee1dca86519e6f208e171b56f5` | `b08138b4a153ed35ef5d78d3a0ae232e4752129608a8f1e33e0a294e563c56e0` | 23 | 2,459.044 | 7.15% |
| [Detailed profile](pi-performance-candidate-focused-20260928.log) | `16c7d2223260fc5ed845d30821f53bda3344c38d` | `4305eb69ccc12d8fe95f0acb5091fe6d44e742b49c3b3f244461c4829992d384` | 22 | 2,585.965 | 12.68% |

The following timings locate work **within each instrumented run**. They are
not calibrated stock-build costs. Means and ranges are milliseconds per
complete steady frame; inclusive parents are not added to their children.

| Timed boundary | Light profile, 23 frames | Detailed profile, 22 frames |
| --- | ---: | ---: |
| Total frame service | 2,494.536 (2,321.664–2,606.999) | 2,634.172 (2,517.026–2,733.747) |
| Derivation | 654.366 (629.242–664.593) | 663.673 (644.303–676.021) |
| Offer excluding sink | 992.689 (943.971–1,039.543) | 1,109.086 (1,053.824–1,143.742) |
| Framebuffer sink | 845.227 (725.665–956.997) | 858.906 (741.130–924.965) |
| Production render preflight | 37.537 (35.548–39.752) | 38.121 (35.521–39.977) |
| Tile reset | 12.653 (11.816–14.095) | 12.665 (11.909–14.851) |
| Pixel raster closures | 381.451 (342.953–425.012) | 360.057 (314.785–389.962) |
| Payload filling | 473.606 (463.579–478.846) | 611.006 (599.423–625.285) |
| Target submission, **including sink** | 851.963 (732.193–963.916) | 865.123 (747.506–931.048) |

The light profile's `layout(...)` call averaged 547.916 ms. Within it,
validation averaged 127.299 ms, measurement 235.676 ms, placement
167.708 ms, and publication 15.872 ms. Semantic expansion averaged
63.142 ms; drawing-plan creation 2.310 ms; derivation render preflight
37.661 ms. The production stream performs its own preflight, shown above.
These layout subdivisions were collected on complete steady frames, unlike
the initial-only values in the prior investigation.

The detailed profile subdivided its 611.006 ms payload-filling timer into
affected-pixel scanning and run formation 283.001 ms, tile-byte reads and
payload writes 221.910 ms, capacity checks 12.738 ms, region opening
16.093 ms, region closing 12.014 ms, and a 65.250 ms residual. Each run
invoked clocks around these small blocks. The detailed build's extra clocks
coincide with a 137.400 ms higher inclusive fill timer than the light
profile; these subdivisions cannot be treated as
uninstrumented durations. The light profile's tile consumption averaged
1,332.586 ms, comprising 473.606 ms payload filling, 851.963 ms target
submission including sink, and 7.017 ms residual.

Neither profile subdivided the **current** 840.534 ms stock sink into region
projection, first-row conversion, row copying, and mapped stores. The
previous sink subdivision predates the row-copy candidate. A later focused
run would be needed before assigning current time to those inner operations.

These runs did not measure panel-visible completion, touch-to-visible latency,
or physical control response.
