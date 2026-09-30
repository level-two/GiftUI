# Pi frame performance analysis — 2026-09-27

This analysis interprets the [phase investigation](pi-performance-phase-investigation-20260927.md)
for the `feature/responsive-analyzer-layout` source at revision
`e3022ab6204249e9094285990612c51b9eeed777`. It separates measured costs,
mechanisms visible in source, and remaining hypotheses. No production code or
approved contract was changed.

## Conclusions

1. **The present workload performs substantial repeated work before the
   panel's physical completion is considered.** The verified application
   frame service averages 2.754 s. Derivation alone averages 0.659 s, already
   2.6 times the 250 ms frame period. Eliminating one output phase cannot
   achieve the required cadence.
2. **Payload formation and mapped framebuffer writes are the two largest
   measured inner loops.** In the first complete detailed profile,
   `fillWriter` averaged 0.872 s and the projected mapped-row loop averaged
   0.891 s. Raster closures averaged 0.323 s. The detailed build increased
   total frame time by 5.8%, so these are instrumented-run costs and cannot
   be substituted for uninstrumented absolute timing.
3. **Layout dominates derivation.** A separate 14-frame profile measured
   0.543 s in the `layout(...)` call out of 0.644 s derivation. Semantic
   expansion averaged 0.060 s; drawing-plan creation averaged 0.002 s;
   derivation render preflight averaged 0.036 s. Production repeats render
   preflight for another roughly 0.035–0.037 s.
4. **The render strategy amplifies per-frame work.** A complete profiled frame
   emitted about 220,273 RGB565 bytes, 1.91 times the 115,200-byte logical
   surface. About 293 tile visits each scan 3,840 pixel flags, giving at least
   1.124 million affected-pixel checks per frame, roughly 10.2 checks per
   emitted logical pixel. The Pi projection performs about 881,090 bytes of
   mapped writes, 2.87 times the 307,200-byte physical framebuffer size.
5. **The measured 0.9 s sink phase is application-side projection and mapped
   writes.** The physical SPI flush and panel-visible completion are outside
   the timer. No current evidence assigns time to the panel transfer.

## Mechanisms visible in source

`OperationMajorTileTraversal.visit` creates a fresh tile for each intersecting
operation. `RGB565TilePayloadEmitter.fillWriter` scans from cursor zero through
the tile's 240 × 16 pixel capacity, even when only a small part of that tile
was marked affected. The focused profile measured about 0.427 s in affected
scanning and 0.198 s reading tile bytes and calling the payload writer.
`fillWriter`'s remaining 0.350 s in that run is a *residual*, not a verified
single operation: per-run checks, region bookkeeping, loop overhead, and
clock-call overhead are all included. The focused build increased the
inclusive fill timer from 0.872 to 0.975 s, consistent with measurement
intrusion. The last build's extra timers yielded only initial frames, so the
residual has no steady-frame subdivision.

The stream emits a mean 334 payloads and 3,851 regions per frame. That is
about 659 payload bytes and 11.5 regions per payload, with a mean 28.6
logical pixels per region. The payload cap is 7,680 bytes and the region cap
is 320, while tile consumption submits at each visited operation tile.
The 293 tile visits and 334 submissions are consistent with tile/operation
boundaries accounting for much of the submission count; frame-wide byte
volume alone does not explain it. The target wrapper outside the framebuffer sink took
only about 6.8 ms per frame in the first detailed run.

For the verified 240 × 240 to 480 × 320 stretch, horizontal projection is
exactly 2×. `PiScreenCoordinateTransform.physicalBounds` uses floor for the
top boundary and ceiling for the bottom boundary. Each one-row logical run
therefore covers two physical rows; 160 of the 239 adjacent-row boundaries
overlap one physical row. `LinuxPiScreenFramebuffer.presentRGB565BigEndian` takes
the double-width branch and writes four destination bytes per source pixel
in each of those two rows. Thus 220,273 canonical bytes imply about 881,090
mapped destination-byte stores per frame, including overwrites. Region
transform and validation averaged only 23.7 ms; the projected row loop
averaged 891.3 ms. This loop includes row setup, source reads, byte-order
conversion, and mapped stores; the trace does not separate those operations.

Within the 15-frame phase profile, emitted byte volume had 0.14% coefficient
of variation while sink time had 8.6%. The sink's correlation with submitted
bytes and region count was near zero (`r=0.034` and `r=0.031`, respectively).
The workload range is narrow and the sample is small, so this does not
identify the source of sink variation. It does show that the observed timing
spread cannot be read directly from these count changes.

`GiftUILayout.layout` always validates, measures, places, and publishes the
semantic hierarchy. The three initial-only measurements from the extra-cut
build put validation at 131–134 ms, measurement at 221–230 ms, placement at
158–168 ms, and publication at 15–16 ms. These are consistent in scale with
the completed profile's 0.543 s layout call, but they do not establish its
steady-frame subdivision. The layout view repeatedly constructs and sorts
child or modifier lists in `DynamicSemanticHostStorage`; the dynamic layout
workspace also uses linear identity searches for measurements and placements.
`childCount` and each indexed `child` call reconstruct the child list, so a
parent's full search and sort recur while its children are walked. Modifier
count and indexed modifier access likewise rebuild a list. This repeated work
is directly visible in source and can contribute to the three layout
traversals, but its share of the 0.543 s call was not timed. The helper-level
attribution remains a hypothesis for focused work.

The second profile charged 1.101 s of the production stream to roughly 122
positioned glyph calls, 0.793 s to five fills, and 0.475 s to five strokes.
Those timers include rasterization, payload formation, and display submission
inside each operation. They identify operation ownership of time, not the
intrinsic cost of glyph drawing. The earlier stroke optimization already
removed most of the original 7.585 s offer remainder; present data should
not be interpreted as evidence that stroke rasterization still dominates.

## Practical interpretation for the next focused pass

- Keep workload counts and timer nesting paired by frame. The original
  2.754 s mean is the best verified service-time estimate; the detailed runs
  are location evidence. The focused profile's 3.106 s mean is 12.8% above
  the verified build, with much of the additional timing inside the offer.
- First isolate the large unassigned portion of payload filling with a
  lower-overhead method, and separate row setup/conversion from mapped stores
  in the framebuffer loop. Avoid per-pixel clocks.
- Obtain complete steady layout validation, measurement, placement, and
  publication timings; the extra-cut build produced no steady frames across
  three attempts.
- Measure panel-visible completion and touch-to-visible latency separately.
  The current service timer gives neither value.
- Recheck every proposed change against the accepted raster, output, memory,
  and profile contracts before treating a faster experiment as adoptable.

The Pi was restored to the last verified executable after profiling; its
independently checked SHA-256 was
`e90a1b598aeea847eb78c12c4e1cfda6a05100db770d452cda1329bc587eaba8`.
