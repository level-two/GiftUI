# Iteration 3 bounded feasibility decision

Status: active preparation. Governing scope: [ITERATION-003 revision 5](../iteration-003-dev-ux-improvement.md).
Coordination: [ME-01–09 activity plan](memory-efficiency-plan.md).
This is one derived evidence/decision packet, not architecture or an implementation contract.

## Launch and limits

Eugene requested committing the governing changes, creating a separate branch,
then proceeding with preparation and committing each step on 2026-10-09.
Governing changes: `5591932983499d4414e5e9c5b2da6fce36f23839` on `main`.
Preparation branch: `iteration-003-bounded-preparation`.
Preparation started at **2026-10-09 14:52:08 UTC**.

- Active elapsed-time ceiling: **60 minutes**, including analysis and build/run
  time; waiting for human/device access is separately reported.
- Experimental invocation ceiling: **8** underlying build/run invocations total.
- Correction ceiling: **2** experimental repair attempts total.
- These are executor-selected ceilings, not an extension of SPIKE-067's stopped
  744/768 invocations and 30/30 corrections. No compilation on that same question
  is authorized by this launch. Review of existing evidence is permitted.
- Source/evidence reads, identity hashing, toolchain version/availability checks,
  documentation validation and commits are not experiments; their time still counts.
- Stop at the earliest ceiling or a decision supported by the evidence. Publish
  one terminal disposition; do not automatically create follow-up experiments.

The selected cost boundaries are (1) runtime graph/storage construction and
service lifetimes, (2) layout and frame production, including Pi projection and
nRF raster/transfer, and (3) source-service delay caused by synchronous frames.
Compare at most two remedies per boundary. Other findings must fit this budget,
become explicit blockers, or be captured through the deferred track if optional.

## ME-01 — Baseline and gaps

Completed baseline inventory. [Machine-readable identities](feasibility-evidence/baseline.json)
freeze Git objects, installed compiler/destination hashes and historical report
identities. All ten maintained/authority roots checked match iteration-2 closeout
`2d036748`: Sources, Tests, firmware, scripts, ThirdParty, package files, ADRs,
Specs and architecture. The working copies match those objects.

| Baseline | Evidence / current gap |
| --- | --- |
| Native compiler | Swift 6.3.3, macOS SDK 26.5; keep distinct from paired cross compilers. |
| Pi compiler/SDK | Project-local Swift 6.3.2, ARMv6 hard-float destination; [doctor passes](feasibility-evidence/pi-doctor.log), no probe/build. |
| nRF compiler/SDK | Project-local Swift 6.3.2, Zephyr 4.3.0 at the pinned revision, SDK 0.17.4; [doctor passes](feasibility-evidence/nrf-doctor.log), no probe/build. Python 3.14.6 differs from lock baseline 3.12.13 but passes the supported range; J-Link 9.66 differs from tested 8.96, no device operation. |
| Production images | All four paths recorded by the final integration reports are absent locally. Historical hashes are frozen, not reverified against current binaries or devices. |
| Production resources | Final nRF report records 95,104 linked RAM bytes and 274,144 flash bytes, zero heap and 27,648-byte main stack reservation. This is the five-second-retention image, not the earlier 191,104-byte RAM image. |
| Workload | SPEC-001: 30 continuous seconds, 80 events/s, four-FPS cadence, loss/order/latency/state/pixel requirements. Retention is five seconds / 404 records per nRF store, not the older 30-second storage configuration. |
| Applications/profiles | Analyzer and finite counter; macOS Dynamic/Static, Pi 1 Dynamic and nRF Embedded Static. Counter may use repository composition; it still lacks a reviewed numeric application budget and complete supported-image proof. |
| Architecture/contract authority | Accepted ADRs and implemented owner Specs remain binding. Runtime work affects SPEC-001/006/010/012/013/015, with layout/render/backend costs additionally governed by SPEC-007/008/011/014. PROPOSAL-007 is accepted; RFC-013 remains draft. |
| Experimental evidence | Retrieve only packet 65 and its directly relevant memory/lifetime predecessors from archive `af5e9559`. No resumed compilation, prior result relabeling or assumed supported-composition success. |

The available evidence permits source-level accounting and architectural triage.
It cannot establish fresh target timings, complete stack safety, or final
runtime-derived production feasibility. Missing binaries alone do not justify
rebuilding an exhausted candidate. Timing and ownership evidence will be assessed
next to determine the smallest useful upstream decision.

## ME-02 — Memory and lifetime assessment

The [source arithmetic and identities](feasibility-evidence/source-analysis.json)
reconcile the current generated nRF production reservation, not a runtime-derived
candidate. [The region map](../../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFProfileRegions.swift)
and [firmware storage](../../../firmware/nrf52840/applications/signal-analyzer-static/src/storage.c)
give the following non-overlapping reserved regions:

| Region | Bytes | Lifetime / constraint |
| --- | ---: | --- |
| Semantic candidate + published | 6,048 | Two 3,024-byte regions; publication/failure behavior prevents assuming they may alias. |
| Layout + render/text | 7,840 | 3,136 + 4,704; text lines/glyphs and scratch live inside these regions, not extra buffers. Layout results remain inputs to Canvas/render. |
| Canvas callables + live Path + drawing plan | 16,976 | 160 + 3,280 + 13,536; path mutation and accumulated stroke snapshots can overlap. Plan stays live through render; callable release alone does not release the plan. |
| Observable live/candidate + interaction candidate/committed | 768 | Declared 128 + 128 + 256 + 256 profile regions; actual firmware also has typed global model/interaction owners. Do not confuse a region reservation with a complete model-memory measurement. |
| Active + sealed admission | 7,680 | Two 3,840-byte regions; distinct producer/sealed lifetimes. |
| Pointer/coordinator/failure | 384 | 96 + 192 + 96; coordinator state is stored between opportunities. |
| **Profile subtotal** | **39,696** | All sixteen subregions are contiguous and non-overlapping. |
| Three capture stores | 19,392 | 3 × 404 × 16; live, snapshot/model and admitted storage. Five-second retention is already applied. |
| Raster/payload/in-flight slot + coverage | 2,720 | 2,560 + 160; the tile, payload and in-flight slot are the same backing, counted once. |
| **Four outer buffers** | **61,808** | Retained C storage. |
| Configured main/ISR/workqueue/idle stacks | 31,040 | 27,648 + 2,048 + 1,024 + 320; reservation, not proved maximum use. |
| Linked remainder | 2,256 | Difference to the recorded 95,104-byte image; includes other linked storage/alignment/guards. No current ELF/map exists to attribute every byte. |

The current resource ceiling is 196,608 bytes. The arithmetic difference of
101,504 bytes is **not a safe additional stack/storage allowance**: the complete
runtime-derived construction, live backing and feasible-path stack must fit
together under reviewed application bounds. Increasing a reservation without
that proof would not answer IT-AC-008.

The actual Embedded service implementation in
[StaticPreset.swift](../../../firmware/nrf52840/applications/signal-analyzer-static/src/StaticPreset.swift)
constructs `StaticSignalAnalyzerCommonOwner` over borrowed regions, keeps semantic,
layout and drawing views through `offerAndProduce`, and persists bounded
coordinator state. The separate native `withOwners` composition is not substituted
as evidence for this firmware path. Construction temporaries, reachable recursive
Layout/Render calls, callback targets and IRQ overlap still need emitted-image
analysis; source declarations alone cannot bound them.

The archived runtime-derived candidate has a different footprint:

- [Packet 61](https://github.com/level-two/GiftUI/blob/af5e9559ebf71446dbee4c3b1fcb2aae65a8f769/experiments/spike-067-integrated-runtime-host/stack-closure-results-0061.md)
  records 73,728 frame-backing bytes + 65,536 model/capture-backing bytes +
  27,712 main-stack allocation including guard + 2,112 IRQ-stack allocation
  including guard + 896 other/alignment bytes = 169,984-byte RAM envelope.
  A twelve-frame successful-path witness needs 30,304 bytes against a 27,648-byte
  main reservation: that exact candidate is unsafe.
- [Packet 64](https://github.com/level-two/GiftUI/blob/af5e9559ebf71446dbee4c3b1fcb2aae65a8f769/experiments/spike-067-integrated-runtime-host/copy-realization-results-0064.md)
  keeps that RAM envelope, removes the specific 20,096-byte getter and reports a
  6,960-byte local helper frame. The old witness cannot be applied to the changed
  image; neither can the difference between local frames be claimed as whole-stack
  savings. Its complete upper bound remains unknown.
- [Packet 65](https://github.com/level-two/GiftUI/blob/af5e9559ebf71446dbee4c3b1fcb2aae65a8f769/experiments/spike-067-integrated-runtime-host/armv6-results-0065.md)
  retains 73 unresolved register-transfer sites, 58 table sites and eight recursive
  components, plus State/capture alias/escape and callback/IRQ obligations. It
  establishes a recording ARMv6 link, not supported target execution.

These are separate images/compositions, not a paired production memory comparison.
The current Dynamic pipeline retains semantic, layout, drawing, render and
interaction workspaces, including heap-backed collections; source inspection
identifies owners but not allocation/RSS peaks or copy-on-write behavior. Actual
Dynamic and macOS Static/counter live-memory totals remain unmeasured here.

**Memory conclusion:** fixed production reservations are accountable at region
level; safe complete runtime-derived memory/lifetimes across both applications
and all four profiles are not established. The open issues are ownership/copy
realization and whole-path safety, not simply the size of the capture buffer.

## ME-03 — Performance assessment

| Priority / boundary | Evidence | What it establishes / what remains unknown |
| --- | --- | --- |
| 1. nRF production and layout | [Connected phase study](../iteration-002-review/26-connected-nrf-phases-and-failure.md): normal total 20.65–21.22s; production 16.46–17.01s, including SPI 1.108–1.113s; layout 3.59–3.71s. | Both CPU-side phases require attention. Optimizing only wire transfer or only layout cannot explain a route to 250ms. This is an instrumented earlier image with sparse source delivery, not the final five-second image under 80 events/s. |
| 2. Pi production/projection | [Accumulated phase study](../iteration-002-review/30-pi-aggregate-phase-comparison.md): median total 1.381s, production 1.219s, nested projection 0.699s; semantic 74.3ms, layout 53.3ms, preflight 25.9ms. | Production/projection dominate that run. The medians are not additive and subtraction does not isolate raster cost. Repeated exact pixel/transfer counts and paired uninstrumented controls remain missing. |
| 3. Source-service coupling | Both source loops execute synchronous frame service before returning to source delivery; deadlines are rebased on sampled current time. | Faster rendering alone does not prove lossless scheduling. Deadline policy, bounded catch-up/admission and maximum service delay need review together. |

The [final Pi production-loop summary](../iteration-002-cleanup/evidence/22-pi-connected/summary.json)
does use the current recorded image: 31 frames at 1,322,263–1,509,253 microseconds,
mean 1,393,700 microseconds, peak RSS 9,808 KiB. That confirms the persistent
four-FPS gap, but is not a sustained 80-event/s test. Its separate accelerated
recording rehearsal delivers 2,400 scheduled transitions over 201,770ms of logical
source time; neither the delivered count nor 120 recording frames proves the
required wall-time workload. The default deterministic source's pattern is not
itself an 80-event/s stress generator.

### Source-confirmed mechanisms, not measured attribution

- [RasterStrokeCoverage](../../../Sources/GiftUIRasterCore/RasterStrokeCoverage.swift)
  enables the unit-width orthogonal fast path only for Dynamic/non-Embedded.
  Embedded visits the clipped pixel rectangle and calls segment/subpath coverage
  logic per tested pixel; it also omits the non-Embedded potential-range skip.
  The existing fast path allocates a Boolean row array, so removing the profile
  guard is not a valid zero-heap remedy. A bounded realization needs its own
  pixel-equivalence and work/resource evidence. Source inspection establishes
  the work pattern, not what fraction of 16–17s it consumes.
- [EmbeddedLayoutWorkspace](../../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace.swift)
  scans scopes by identity, and scans prior glyphs for each glyph insertion.
  [CommonLayoutWorkspace](../../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCommonLayoutWorkspace.swift)
  routes measurement/placement through those scans on the selected firmware
  path. At declared capacities, insertion duplicate checks alone entail 4,753
  prior-scope comparisons for 98 scopes and 24,976 prior-glyph comparisons for
  224 glyphs. These are source-derived capacity examples, not observed frame
  counts or proof that lookup dominates layout.
- [PiScreen projection](../../../Sources/GiftUIPlatformRaspberryPi/PiScreenFramebufferProjection.swift)
  scales/reorders each submitted RGB565 region into mapped physical rows. It
  already has a doubled-width path and repeated-row copying. Another generic
  memcpy suggestion therefore does not establish an improvement; payload count,
  repeated coverage and mapped-write time must discriminate the alternatives.
- [Pi source loop](../../../Sources/SignalAnalyzerRaspberryPiARMv6/LinuxSignalAnalyzerPiProcessLoop.swift)
  delivers at most one scheduled source transition per outer iteration and
  computes the next deadline from `now`. [nRF source service](../../../firmware/nrf52840/applications/signal-analyzer-static/src/production_host.c)
  has a bounded due loop but resets a positive next delay from the same sampled
  `now`; it does not reconstruct all elapsed deadlines after a long frame.
  A catch-up change must preserve timestamp/order/generation and the 32 compact
  fact slots; adding a thread is not implied or authorized.

**Performance conclusion:** sufficient evidence exists to rank the target cost
boundaries and reject single-cause explanations. It does not establish a measured
speedup for a remedy, full cold/unchanged/small-change/waveform operation counts,
or sustained performance of either complete runtime-derived application. Native
Dynamic/Static allocations/timings and three controlled connected runs per
accepted target candidate remain open; historical observations are not promoted
to those evidence classes.

## ME-04 — Alternatives and terminal decision

Pending. No architecture is selected and no implementation is authorized.

## Usage and validation

ME-01 checkpoint, 14:53:56 UTC: 1m48s active elapsed; 0/8 experimental invocations,
0/2 experimental corrections; no waiting. Both non-probe doctors pass. No hardware
operation, production change, new conformance claim or study restart.

ME-02 checkpoint, 14:57:26 UTC: 5m18s active elapsed; 0/8 experimental invocations,
0/2 experimental corrections; no waiting. Region arithmetic reconciles to the
historical linked total with the residual explicitly unattributed. This does
not satisfy the complete stack/lifetime or all-profile measurement criteria.

ME-03 checkpoint, 14:58:55 UTC: 6m47s active elapsed; 0/8 experimental invocations,
0/2 experimental corrections; no waiting. Ranked historical timings and current
source mechanisms are recorded without fresh timing or conformance claims.
