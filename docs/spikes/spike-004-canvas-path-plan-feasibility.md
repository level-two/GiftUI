---
id: SPIKE-004
feature: canvas-drawing
title: Canvas Path Plan Feasibility
status: planned
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

Not run. This Spike is `planned`.

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

Planned. When completed, feed the semantic and resource matrix back into
RFC-009 Open Question 1. If no snapshot-plan candidate satisfies the gate,
RFC-009 must remain draft and reconsider its ownership/lifetime proposal; the
Spike must not silently promote direct emission or change accepted
architecture.

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
