---
id: SPIKE-004
feature: canvas-drawing
title: Canvas Path Plan Feasibility
status: completed
authors:
  - Yauheni Lychkouski
created: 2026-08-25
updated: 2026-08-25
source:
  - RFC-009
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPIKE-004: Canvas Path Plan Feasibility

> This Spike produces evidence for RFC-009. Its declarations, storage layout,
> capacities, raster shortcuts, and prototype code are disposable and do not
> establish production architecture or authorize implementation.

## Parent Gate

RFC-009 cannot advance to review until the proposed cycle-local immutable
Canvas plan is compared with direct stroke emission for the supported
Embedded Swift/nRF52840 build. The comparison must show whether the proposed
ownership and lifetime can fit the Signal Analyzer workload without a heap,
unbounded stack use, a retained full-frame display list, or an unavailable
runtime dependency.

The Spike feeds evidence only to RFC-009. It does not choose the public API,
set production capacities, approve a normalized operation encoding, select a
raster algorithm, or authorize migration of current renderer code.

## Target Questions

1. Can a caller-owned cycle-local plan represent the Signal Analyzer's grid
   and maximum five-second four-channel trace workload with finite point,
   subpath, stroke-record, and operation storage on the supported Embedded
   Swift/nRF52840 configuration?
2. What are the linked RAM, flash, maximum stack, per-point, per-subpath,
   per-stroke, and operation-count costs of:
   - copying mutable Path storage into immutable plan snapshots;
   - transferring or sealing uniquely owned arena ranges into the plan; and
   - emitting strokes directly without a plan?
3. Can the snapshot candidates preserve later-Path-mutation independence,
   multiple subpaths, painter's order, checked local-to-surface translation,
   and deterministic exhaustion without heap allocation, reflection, `Any`,
   unrestricted existentials, tasks, threads, or exceptions?
4. Can the plan validate every ordinary construction and capacity failure
   before frame offer while the direct-emission comparator satisfies the same
   no-partial-output rule without reinvoking the client closure?
5. Can a bounded RGB565 tile consumer synchronously consume the selected
   borrowed path payload without retaining Core storage after offer, and what
   backend-owned tile/span/transfer storage is required?
6. Does either candidate require a change to ADR-005's normalized render
   boundary, ADR-010's one-shot handoff, ADR-011's derivation failure rules, or
   ADR-020's composite capability meaning?

## Bounds / Stop Conditions

- Limit the client workload to the SPEC-001 time grid and four digital traces.
- Exercise the current normative five-second window and 80 aggregate
  transitions per second, including at least 400 visible transitions, 808
  trace segments, and 12 grid segments, plus explicit boundary and exhaustion
  fixtures.
- Compare exactly three producer candidates: copy-to-plan,
  unique-range-seal/transfer, and direct emission.
- Use opaque RGB paint, checked integer points, straight open subpaths,
  positive integer widths, and round caps/joins only.
- Use recording consumption plus one bounded RGB565 tile-consumer fixture. Do
  not build a general graphics API, curves, fills, text drawing, transforms,
  alpha, animation, or a production rasterizer.
- Use host semantic fixtures and hardware-free compile/link evidence for
  `nrf52840dk/nrf52840`; do not flash or operate connected hardware.
- Keep disposable code under
  `experiments/spike-004-canvas-path-plan-feasibility/`.
- Stop when every candidate has either complete reproducible measurements and
  semantic results or a named compiler, lifetime, transaction, or resource
  failure.
- Stop and report `inconclusive` if the pinned repository-managed toolchain
  cannot produce comparable baseline and candidate images. Do not install a
  global toolchain, place an SDK under `/opt`, or change Xcode/global Swift
  selection.

## Method

### 1. Common fixture vocabulary

Define a disposable checked-integer fixture vocabulary containing:

- points and subpath boundaries;
- one mutable straight-line Path construction shape;
- opaque color and a canonical round-cap/round-join style;
- a recording normalized-stroke sink with a synchronous borrowed payload;
- fixed artificial limits for negative tests; and
- stable bounded outcome identifiers for invalid state, arithmetic overflow,
  path exhaustion, plan exhaustion, and sink exhaustion.

The three candidates must consume identical generated waveform inputs and
produce comparable canonical recording rows. Prototype spelling and field
layout are not proposed production API.

### 2. Producer candidates

Implement only enough disposable code to compare:

1. **Copy-to-plan:** build one mutable Path and copy each submitted stroke into
   caller-owned immutable point/subpath and stroke-record arenas.
2. **Unique-range seal/transfer:** build directly in a uniquely owned arena
   range and seal or transfer that range into the plan at stroke submission,
   allocating a fresh range for later Path mutation.
3. **Direct emission:** invoke the same logical construction and emit borrowed
   stroke payload directly to the sink without retaining a Canvas plan.

For the direct candidate, explicitly test whether all ordinary failure can be
known before any irreversible sink effect without invoking the client fixture
twice. Record failure if it cannot satisfy that boundary; do not add a hidden
retained display list to make it pass.

### 3. Shared semantic cases

Run the same cases against every candidate:

- one horizontal and one vertical segment;
- multiple open subpaths;
- empty and one-point subpaths;
- repeated endpoints and zero-length segments;
- later mutation after an earlier stroke submission;
- multiple strokes with distinct colors/styles in painter's order;
- checked local-to-surface translation at valid and overflowing boundaries;
- exact exhaustion at point, subpath, stroke-record, and operation limits;
- failure after one successful stroke but before plan completion; and
- the complete deterministic grid and four-trace maximum-window workload.

The recording sink must prove exact point and subpath order, immutable
snapshot behavior, no partial accepted plan after failure, and no retained
borrowed address after synchronous consumption.

### 4. Embedded compile and link comparison

Build a matched placeholder-waveform baseline and each candidate with the
repository's pinned compiler, SDK, Zephyr board, Cortex-M4F hard-float flags,
optimization, and runtime support. Keep generated firmware under
`.build/nrf52840/` and stable experiment reports under the experiment
directory.

For every image, record:

- total linked flash and RAM and candidate-minus-baseline deltas;
- static Canvas-plan workspace, current Path workspace, raster/tile workspace,
  and any post-acceptance backend-owned storage separately;
- maximum stack by reproducible compiler report, instrumentation, or
  conservative complete call-graph analysis;
- per-point, per-subpath, and per-stroke byte costs including alignment;
- operation counts and complete-workload construction/lowering counts;
- allocator configuration and unresolved/linked symbol inspection;
- forbidden dependencies on reflection, `Any` storage, tasks, threads,
  exceptions, Objective-C, and unavailable runtime facilities; and
- ELF CPU/ABI and VFP calling-convention evidence required by repository
  nRF52840 rules.

If instrumentation changes the image, report resource and instrumented builds
separately rather than subtracting unlike artifacts.

### 5. Decision matrix

Produce a final matrix comparing semantic correctness, pre-offer failure,
snapshot ownership, RAM, stack, flash, operation count, allocator/runtime
closure, and compatibility with ADR-005/010/011/020. State pass, fail, or
inconclusive for every target question without selecting production code.

## Reproduction

The experiment must provide one repository-root entry point, preferably:

```text
experiments/spike-004-canvas-path-plan-feasibility/run.sh
```

It must:

1. print the source revision, pinned compiler, SDK, board, CPU/ABI,
   optimization, configured fixture bounds, and generated workload summary;
2. run all shared semantic and negative fixtures for the three candidates;
3. build matched Embedded Swift baseline and candidate images;
4. inspect allocator and forbidden runtime dependencies;
5. collect size, symbol, ABI, stack, workspace, and operation evidence; and
6. emit one stable comparison table plus pass, fail, or inconclusive for each
   target question.

The entry point must not download or globally install a toolchain, install
under `/opt`, alter Xcode/global Swift selection, flash a board, operate
connected hardware, or claim hardware validation.

## Results

Completed on 2026-08-25 with the repository-managed Swift 6.3.2 compiler,
Zephyr 4.3.0, Zephyr SDK 0.17.4, board `nrf52840dk/nrf52840`, Swift target
`armv7em-none-none-eabi`, Cortex-M4F hard-float flags, and `-Osize`. The
repository-root reproduction command is:

```text
experiments/spike-004-canvas-path-plan-feasibility/run.sh
```

The matched workload contains 400 visible transitions concentrated in one
channel to exercise the maximum current-Path bound, 808 trace segments, 12
grid segments, 836 points, 16 subpaths, and five ordered strokes/operations.
All shared semantic, boundary, and exhaustion fixtures produced their expected
outcomes for all three candidates. The complete workload produced the same
canonical recording digest for copy-to-plan, unique-range seal, and successful
direct emission.

### Linked nRF52840 Evidence

| Candidate | Linked flash | Delta | Linked RAM | Delta | `bss` |
| --- | ---: | ---: | ---: | ---: | ---: |
| Placeholder baseline | 25,912 B | 0 B | 16,636 B | 0 B | 9,665 B |
| Copy-to-plan | 26,792 B | +880 B | 30,204 B | +13,568 B | 23,143 B |
| Unique-range seal | 26,712 B | +800 B | 23,676 B | +7,040 B | 16,647 B |
| Direct emission | 26,472 B | +560 B | 23,292 B | +6,656 B | 16,201 B |

The producer workspace model accounts for 13,456 bytes for copy-to-plan,
6,960 bytes for unique-range seal, and 6,520 bytes for direct emission. Every
image also contains matched backend-owned storage: a 3,840-byte RGB565 tile,
a 960-byte span, and a 3,840-byte transfer buffer. The point, subpath, and
stroke-record costs are 8, 8, and 24 bytes respectively, including alignment.

Complete disassembly call-graph analysis gives conservative fixture stack
bounds of 36 bytes for the baseline, 104 bytes for copy-to-plan, 92 bytes for
unique-range seal, and 84 bytes for direct emission. These bounds exclude
Zephyr boot and scheduler frames and are not connected-board high-water
measurements.

Every image has a zero-sized Zephyr heap and libc arena, retains no allocator
entry point, introduces no linked reflection, Objective-C, task, exception, or
allocation dependency relative to the baseline, reports ARMv7E-M, and reports
VFP-register argument passing. No board was flashed or operated.

### Semantic and Transaction Results

- Both plan candidates preserve later-mutation independence, multiple
  subpaths, empty and one-point subpaths, repeated endpoints, zero-length
  segments, painter order, checked translation, exact workload bounds,
  deterministic exhaustion, and a single client-fixture invocation.
- Both plans validate complete producer and sink capacity before offer. The
  late sink-exhaustion fixture leaves the recording sink empty.
- Direct emission produces equivalent successful rows and has the lowest
  measured resource cost, but a sink exhaustion after one successful stroke
  leaves partial output. It therefore fails the required no-partial-output
  boundary unless it adds retained pre-recording or reinvokes the client
  closure, both excluded by this Spike.
- The bounded RGB565 consumer consumes each borrowed row synchronously and
  retains no Core storage or borrowed address after offer.

Stable generated evidence is under
`experiments/spike-004-canvas-path-plan-feasibility/evidence/`, including
`summary.md`, `semantic-results.tsv`, `operation-counts.tsv`,
`resources.tsv`, symbol comparisons, and stack analysis. Generated firmware
and detailed ELF reports remain under `.build/nrf52840/spike-004-*`.

## Limitations

- Hardware-free compile/link evidence cannot prove connected TFT timing,
  electrical behavior, display correctness, or on-device stack high-water.
- The disposable RGB565 consumer measures the selected payload and bounded
  tile interaction; it does not establish a production raster algorithm or
  pixel-conformance tolerance.
- The SPEC-001 workload and rates may change before approval. The experiment
  must record its exact input revision and must be rerun if the normative
  drawing bound changes materially.
- Prototype layouts and capacity values are evidence only and cannot be copied
  into an ADR or Specification without independent review.

## Disposition

Completed. Target Questions 1, 2, 3, 5, and 6 pass for both cycle-local plan
candidates. Target Question 4 passes for both plans and fails for direct
emission. The measured plan candidates fit the supported hardware-free
nRF52840 build with finite RAM, flash, stack, operations, and no allocator or
forbidden runtime dependency, so RFC-009's bounded-plan feasibility blocker is
resolved by evidence.

This result feeds RFC-009 only. It does not choose copy versus sealed ranges,
set production capacities, approve the RFC, establish an operation encoding or
raster algorithm, or authorize reuse of the disposable code. RFC-009 is now
`approved`, and its extracted ADR-028 through ADR-031 are accepted. Its
formerly separate implicit-Canvas-clip blocker was subsequently
resolved by maintainer direction in RFC-009; that decision does not change this
Spike's evidence-only role.

## References

- [RFC-009: Canvas, Path, and Stroke Drawing Architecture](../rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md)
- [PROPOSAL-006: Canvas, Path, and Stroke Drawing](../proposals/proposal-006-canvas-path-stroke-drawing.md)
- [SPEC-001: Signal Analyzer Reference Application Contract](../specs/spec-001-signal-analyzer-reference-application.md)
- [ADR-005: Semantic, Layout, and Render Boundary](../adrs/adr-005-semantic-layout-render-boundary.md)
- [ADR-009: Checked Integer Geometry for MVP](../adrs/adr-009-checked-integer-geometry.md)
- [ADR-010: Synchronous One-Shot Frame Handoff](../adrs/adr-010-synchronous-one-shot-frame-handoff.md)
- [ADR-011: Serialized Run Cycle and Semantic Publication](../adrs/adr-011-serialized-run-cycle-and-publication.md)
- [ADR-020: Composite Raster Presentation Capability](../adrs/adr-020-raster-presentation-capability.md)
- [GiftUI nRF52840 toolchain skill](../../skills/giftui-nrf-toolchain/SKILL.md)
