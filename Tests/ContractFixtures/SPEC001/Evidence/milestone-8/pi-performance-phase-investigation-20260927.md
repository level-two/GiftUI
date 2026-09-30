# Raspberry Pi frame phase investigation — 2026-09-27

This is an evidence handoff for SPEC-001 T8.1 / SA-AC-023. It identifies the
measured frame phases and the source boundaries that contain them. It does not
propose an optimization or assign a root cause.

## Provenance and method

The investigated source is revision `e3022ab6204249e9094285990612c51b9eeed777`
of `feature/responsive-analyzer-layout`. Profiling changes were made only in
an isolated source copy under `.build/raspberry-pi/investigation-src`. Each
release static ARMv6 build passed `scripts/raspberry-pi/doctor.sh` and the
build script's ELF, ARMv6, and hard-float checks. The connected target
independently reported `armv6l` and a 480 × 320, 16-bpp framebuffer with
960-byte stride. Complete profiles used bounded foreground runs with
`GIFTUI_PI_TRACE=1`; the final retry used a bounded detached run with an
on-device log. No service was restarted. The
[trace instrumentation patch](pi-performance-trace-instrumentation-20260927.patch)
contains the final superset of temporary timer changes and passes
`git apply --check` against the investigated revision. It is reproducibility
material, not a proposed implementation change.

| Run | Build ID | SHA-256 | Complete steady frames | Raw evidence |
| --- | --- | --- | ---: | --- |
| Last verified build | `603d937196660ce87964ceb088897f9c02c0a223` | `e90a1b598aeea847eb78c12c4e1cfda6a05100db770d452cda1329bc587eaba8` | 10 | [baseline trace](pi-performance-semantic-lookup-20260927.log) |
| Phase profile | `892464f3500522c370f0d01b0350219e2a27085d` | `3e85ec37b0bf867a286a0314918a253f278b5b3ef8682d4e3c9298dc410b4f2b` | 15 | [phase trace](pi-performance-phase-profile-20260927.log) |
| Focused profile | `f4d5bd9ff506a2ba84c08e6785a5c83ff73e36ab` | `e908f56108757ad75a6e23da62649d37594f20b97769f4b21e1695e91a2f609d` | 14 | [focused trace](pi-performance-focused-profile-20260927.log) |
| Extra layout/fill cuts | `74f365fcc4df05ca7cac25874ee902624f6423df` | `5c89a451d4cf56916204a90e3e0f33ad42fe8fde7adaeb4de5d120d93f094980` | 0 | [attempt](pi-performance-layout-fill-profile-20260927.log), [retry](pi-performance-layout-fill-profile-retry-20260927.log), [detached retry](pi-performance-final-retry-20260927.log) |

The initial presentation is excluded from all steady-frame tables. Each
`pi-frame-duration-us` line closes the immediately preceding group of trace
lines. `offer excluding sink` is calculated separately for each frame as
`pi-present.offer - pi-target.sink`, then averaged. The process-loop timer
starts immediately before `owner.service(at:)` and stops when that call
returns a completed opportunity. None of these clocks measures when the SPI
panel physically finishes displaying the frame.

After the measurements, the last verified executable was redeployed. An
independent target SHA-256 check returned
`e90a1b598aeea847eb78c12c4e1cfda6a05100db770d452cda1329bc587eaba8`.
No profiling executable remains installed.

## What the connected timings establish

All values below are mean milliseconds per complete steady frame. Runs are
separate bounded observations, so differences between builds include timer
overhead and run-to-run variation.

| Phase | Verified build | Phase profile | Focused profile |
| --- | ---: | ---: | ---: |
| Frame service | 2753.8 | 2913.1 | 3106.0 |
| Derivation | 658.6 | 634.4 | 644.0 |
| Offer excluding sink | 1187.8 | 1328.2 | 1486.9 |
| Framebuffer sink | 904.8 | 948.3 | 972.3 |
| Other service time | 2.6 | 2.2 | 2.8 |

The first detailed profile increased observed frame service by 159 ms (5.8%)
relative to the verified run. The focused profile was 352 ms (12.8%) above
the verified run. The extra clocks are especially frequent inside payload
filling. Consequently, the detailed values locate time within each profiled
run; they are **not** calibrated estimates of the uninstrumented absolute
cost. The phase ordering and the two large inner loops recur across both
complete profiles.

In the phase profile, the 15 steady frames submitted a mean 220,273 canonical
RGB565 bytes in 334 payloads and 3,851 regions. Tile traversal visited 293
tiles per frame. Submission bytes are repeated drawing work, not unique
surface pixels or measured SPI traffic. The logical 240 × 240 surface contains
115,200 RGB565 bytes.

### First detailed cut: where offer and sink time sits

From the 15-frame phase profile:

| Timed boundary | Mean ms | Observed range, ms | Source boundary |
| --- | ---: | ---: | --- |
| Production render preflight | 35.3 | 33.6–36.5 | `RenderProducer.produce` before streaming |
| Tile reset | 13.2 | 12.5–14.1 | `RGB565TileWorkspace.beginTile` / `DynamicSignalAnalyzerPiTileStorage.reset` |
| Pixel rasterization | 323.3 | 301.5–344.2 | `OperationMajorTileTraversal.visit` raster closure |
| Payload filling | 872.2 | 864.3–885.7 | `RGB565TilePayloadEmitter.fillWriter` |
| Target submission excluding sink | 6.8 | 6.4–7.5 | `target.submitPayload - pi-target.sink` |
| Framebuffer region projection | 23.7 | 22.6–24.6 | region transform and validation |
| Mapped framebuffer row writes | 891.3 | 742.1–998.2 | projected row loop in `LinuxPiScreenFramebuffer` |
| Other work inside sink timer | 33.2 | 31.7–34.2 | `pi-target.sink - projection - writes` |

The payload-filling and mapped-row-write timings each approach 0.9 s in this
profile; rasterization is about 0.32 s. These are non-overlapping inner
boundaries. The framebuffer sink includes projection, mapped writes, and its
residual. The `submitPayload` timer includes the sink. Tile `consume` includes
payload filling and submission. Production `stream` includes all tile work.
Those inclusive totals must not be added to their children.

### Second cut: derivation, payload filling, and operation classes

From the 14-frame focused profile:

| Derivation phase | Mean ms | Observed range, ms |
| --- | ---: | ---: |
| Semantic expansion and state binding | 59.9 | 57.5–61.9 |
| Layout call | **543.0** | 525.4–553.1 |
| Drawing-plan derivation | 2.1 | 1.7–2.5 |
| Render preflight during derivation | 35.8 | 34.2–36.5 |
| Interaction candidate setup and publication | 1.9 | 1.8–2.0 |
| Unassigned derivation residual | 1.3 | 0.2–1.6 |

The current derivation time is concentrated in the `layout(...)` call. The
older temporary profile is not used here because it preceded the latest
derivation changes.

| Payload-filling phase | Mean ms | Observed range, ms |
| --- | ---: | ---: |
| Affected-pixel scan and run formation | 427.0 | 418.7–433.6 |
| Reading tile bytes and writing payload bytes | 198.3 | 194.8–201.5 |
| Remaining work within `fillWriter` | **350.1** | 346.3–353.5 |
| `fillWriter` inclusive | 975.3 | 963.8–986.7 |

The residual is calculated per frame as `fill - scan - bytes`. It includes
capacity checks, region setup and finish calls, loop overhead, and timing
overhead; the completed profiles do not divide it further. The scan counter
counts inspected runs including runs revisited after a payload fills, so its
mean 3,961 runs exceeds the mean 3,843 emitted regions. The payload-byte
counter covers about 110,347 emitted logical pixels per steady frame.

The streamed operation-class timers are inclusive of tile traversal and
display submission. Mean times were 793 ms across 5 fill operations,
1,101 ms across about 122 positioned glyphs, and 475 ms across 5 stroke
operations. These class totals sum to 2,370 ms inside the 2,422 ms production
stream. They describe where stream time is charged, not pure fill, glyph, or
stroke rasterization cost.

### Extra cuts without steady-frame evidence

The last build attempted to split layout into validation, measurement,
placement, and publication, and payload filling into capacity and region
bookkeeping. Two bounded SSH runs each yielded only the initial frame, then
the SSH session ended with exit 255. A third, user-requested bounded attempt
saved its log on the Pi and also ended after the initial frame, with no
`pi-frame-duration-us` or `status=completed` line. The detached run showed no
remaining analyzer process when inspected; its exit disposition was not
captured. There is no steady-frame sample from this build. Its three
**initial-only** layout measurements were validation 131–134 ms,
measurement 221–230 ms, placement 158–168 ms, and publication 15–16 ms.
Initial presentation may differ from steady frames; these values are
provisional location evidence only. The initial-only payload cuts do not
establish a steady-frame subdivision of the 350 ms residual.

The Pi remained reachable and `/proc/uptime` showed a continuous boot after
the failed sessions. A reboot was initially suspected from old `dmesg`
messages, then ruled out by the uptime check. The SSH interruption itself
was not diagnosed in this investigation.

## Exact code path and boundaries

1. `DynamicSignalAnalyzerPiInitialPresentationOwner.present` calls
   `DynamicSignalAnalyzerPresentationPipeline.derive`, then `offer`. The
   current derive trace places 543 ms in `GiftUILayout.layout`.
2. `OneShotRasterBackendEndpoint.offer` reserves the frame and invokes
   `CanvasRenderProducer.produce`. `RenderProducer.produce` repeats a render
   preflight traversal before streaming operations; it took about 35–37 ms.
3. `OperationMajorRGB565RasterSession` receives fill, glyph, and stroke
   operations. `OperationMajorTileTraversal.visit` resets each tile, invokes
   the operation's raster closure, and consumes the tile. The first profile
   measured about 13 ms in reset and 323 ms in raster closures.
4. Tile consumption calls `RGB565TilePayloadEmitter.submit` and `fillWriter`.
   The focused profile places about 427 ms in affected-pixel scanning,
   198 ms in reading/writing payload bytes, and 350 ms in the remaining
   writer work under its heavier instrumentation.
5. `PiScreenDisplayTarget.submitPayload` calls
   `LinuxPiScreenFramebuffer.presentRGB565BigEndian`. The first profile
   places about 24 ms in per-region projection and 891 ms in the mapped
   framebuffer row loop. The driver may flush mapped pages to the SPI panel
   later, outside the application timer.

One separate GDB stack sample landed in tile storage reset during a stroke.
GDB inflated the sampled frame to 14.179 s, so that sample confirms only the
code path and was excluded from every table.

## Remaining measurement gaps for focused work

- Resolve the `fillWriter` residual with a lower-overhead or sampled method;
  the failed third run does not provide a steady result.
- Distinguish the mapped-row loop's row setup, pixel conversion, memory
  writes, and any driver interaction without adding enough timer calls to
  dominate the loop.
- Obtain steady-frame validation/measure/place/publish layout subdivisions.
- Measure actual panel-visible completion and touch-to-visible-response
  separately; the application timers cannot establish either latency.
- Retain build identity, exact workload counts, paired nested timers, and a
  no-debugger run when comparing later traces. Do not treat profile-to-profile
  mean differences as a controlled hardware benchmark.
