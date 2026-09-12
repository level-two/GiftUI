---
spec: SPEC-014
feature: giftui-mvp-architecture
title: SPEC-014 Implementation Plan
status: active
owners:
  - codex
created: 2026-09-09
updated: 2026-09-12
related_design_notes: []
conformance_report: null
related_future_work:
  - FW-010
  - FW-014
related_explorations: []
related_spikes:
  - SPIKE-001
  - SPIKE-002
  - SPIKE-004
supersedes: null
superseded_by: null
---

# SPEC-014 Implementation Plan

> This ready plan derives work from the approved Raster Backend and Display
> Integration Contract. It orders implementation and evidence but does not
> amend its raster, surface, display, capability, handoff, failure, resource,
> profile, platform, or hardware contracts.

## Authority and Scope

The governing [SPEC-014](../specs/spec-014-backend-integration.md) is approved
and authoritative. Its lifecycle chain is accepted
[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md),
[PROPOSAL-004](../proposals/proposal-004-capability-system.md), and
[PROPOSAL-006](../proposals/proposal-006-canvas-path-stroke-drawing.md);
approved [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md),
[RFC-003](../rfcs/rfc-003-deterministic-text-rendering-architecture.md),
[RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md),
[RFC-005](../rfcs/rfc-005-failure-diagnostics-propagation.md),
[RFC-006](../rfcs/rfc-006-capability-system-architecture.md), and
[RFC-009](../rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md); and
accepted [ADR-005](../adrs/adr-005-semantic-layout-render-boundary.md) through
[ADR-010](../adrs/adr-010-synchronous-one-shot-frame-handoff.md),
[ADR-014](../adrs/adr-014-bounded-cross-layer-outcomes.md) through
[ADR-023](../adrs/adr-023-exact-font-resource-identity.md),
[ADR-030](../adrs/adr-030-canonical-normalized-straight-line-stroke-operation.md),
and [ADR-031](../adrs/adr-031-bounded-canvas-failure-and-startup-gate-integration.md).

Approved SPEC-002, SPEC-003, SPEC-004, SPEC-005, SPEC-008, SPEC-009, and
SPEC-012 own the exact portable geometry, failure values, capability result,
text-resource borrow, normalized operations, one-shot endpoint, and canonical
stroke contracts consumed here. This plan does not duplicate those owners.
SPEC-013 and SPEC-015 are downstream coordination contracts: profile storage,
target assembly, production capacities, platform selection, and connected
hardware remain outside this plan.

The [MVP Scope](../MVP_SCOPE.md) requires the same portable Signal Analyzer to
render opaque backgrounds, exact positioned labels, and grid/trace strokes on
macOS dynamic, macOS static, Raspberry Pi 1/Linux with PiScreen, and nRF52840
with a TFT. Those configurations require materially different full-surface and
bounded RGB565 tiled realizations. SPEC-014 is therefore the MVP
stack-validation seam proving that one normalized operation stream produces
equivalent pixels while platform and hardware mechanics remain below portable
Presentation.

## Current Repository State

- `Package.swift` contains the implemented portable, capability, text-resource,
  render-core, execution, and failure targets, but none of the approved
  `GiftUISurfaceCore`, `GiftUIRasterCore`, `GiftUIDisplayCore`, or
  `GiftUIBackendIntegration` targets or their focused test targets.
- `GiftUICapabilities` already provides the SPEC-004 operation, encoding,
  realization, submission-lifetime/handoff, contribution, resolver, and
  `EffectiveRasterPresentation` values required by construction validation.
  Its implementation plan remains active, so production adapter integration
  must consume the landed exact declarations and must not call the resolver.
- `GiftUITextResources` provides the exact resource identities,
  `TextRasterResourceView`, glyph records, payload borrow, and validator.
  SPEC-005's contract-local plan is completed; downstream backend integration
  and final cross-owner evidence remain intentionally outside that plan.
- `GiftUIRenderCore` currently provides fill and positioned-glyph operation
  values and `RenderOperationSink`. The SPEC-008 plan remains active.
  SPEC-012's focused completion-seam amendment is approved, but it has no
  production drawing implementation yet, so `DrawingOperationSink` and the
  borrowed canonical stroke view are explicit prerequisites for Canvas-capable
  backend compilation and stroke evidence.
- `GiftUIExecution` provides the exact SPEC-009 provenance, stream-result,
  offer-result, and `SynchronousFrameEndpoint` declarations. Its focused
  one-shot and failure machinery is implemented, while production backend and
  profile integrations remain open in that active plan.
- `GiftUIFailureCore`, `GiftUIFailureExecution`, and bounded diagnostic support
  exist. SPEC-014 still needs a backend-owner adapter that preserves each local
  error and applies the exact SPEC-003 mapping without moving execution
  correlation into display/transport owners.
- No `Tests/ContractFixtures/SPEC014/`, SPEC-014 fixture files, focused unit
  targets, dependency fixtures, resource probes, cross-profile comparator, or
  `scripts/contracts/run-spec-014.sh` exists. The top-level gate uses the
  explicit `scripts/contracts/driver-registry.tsv`; it never discovers drivers
  implicitly.
- SPEC-002 removed proof-of-concept raster, framebuffer, Linux, and embedded
  implementation paths from maintained source. Historical
  `RGB565TileRenderer.renderTiles` and platform adapters are migration evidence
  only; the closure-per-tile replay shape cannot be restored or wrapped as a
  conforming implementation.
- No source or generated implementation artifact is created by this planning
  change.

## Readiness Review

**Reviewed:** 2026-09-09

**Disposition:** Ready. SPEC-014 is approved, every governing Proposal, RFC,
and ADR is authoritative, all fifteen acceptance criteria map exactly once to
ordered work and reproducible evidence below, and the Specification reports no
open architectural or contractual issue. Contract-local fixture schemas,
target boundaries, value families, encoding, display grammar, recording
oracles, and failure matrices can begin in their named order. Compilation or
integration that names unfinished upstream production types waits for the
corresponding SPEC-008, SPEC-009, or SPEC-012 task rather than creating a
parallel declaration.

No `docs/features.yaml` update is required. Implementation records are not
registered in the feature manifest, and `giftui-mvp-architecture` already
reports the implementation stage. SPEC-014 remains `approved` and this plan
remains `ready` until implementation actually begins; that later progress
change moves the Specification to `implementing` and this plan to `active`.

If the supported compilers cannot express the approved borrowing protocols,
value ceilings, operation-major tiled lifetime, exact zero-heap static path,
or full failure/drain grammar, the affected work returns to Specification or
architecture review. Implementation must not add producer replay, retained
Core operations, a complete-frame display list, asynchronous Core completion,
mid-frame backpressure, target-identity capability logic, text substitution,
or platform-owned semantic behavior.

## Task Dependencies and Affected Surfaces

Milestone numbers define the default order. A task may start only after every
listed prerequisite is satisfied.

| Work | Prerequisites | Primary affected surfaces | Parallel boundary |
| --- | --- | --- | --- |
| `T0.1`-`T0.4` | Approved SPEC-014 authority chain | `Tests/ContractFixtures/SPEC014/`, `scripts/contracts/`, `Package.swift`, dependency registries | Fixture schemas, migration inventory, and fail-closed driver scaffolding may proceed together; target rows land with their first compiling source |
| `T1.1`-`T1.6` | `T0.2`; landed SPEC-002/003/004/005/008/009 declarations named by each task | four new Core/integration targets and focused test targets | Surface, raster-limit/error, and display value families may proceed independently after ownership and imports freeze; endpoint protocols wait for SPEC-012's drawing sink |
| `T2.1`-`T2.5` | Relevant `T1.*`; exact SPEC-004 effective values and SPEC-005 resource views | contributor adapters, integration construction, capability fixtures | Contribution construction, equality matrices, and checked-work arithmetic may be tested separately before combined endpoint construction |
| `T3.1`-`T3.5` | Display declarations from `T1.4`; descriptor and limits from `T1.1`/`T1.3` | display recording target, writer, transaction tests | Identity allocation and writer grammar may proceed in parallel against one frozen reservation state model |
| `T4.1`-`T4.6` | Surface/raster contracts; normalized fill/text operations; SPEC-012 for `T4.4` | raster core, recording surface, golden fixtures | Encoding, fill, and glyph work may proceed independently; stroke work starts only after the canonical borrowed stroke view exists; final golden comparison consumes all paths |
| `T5.1`-`T5.4` | `T3.*`, `T4.*`; complete full-surface bounds | RGBA8888 buffer, RGB565 framebuffer adapter, display recording target | The two encodings may be realized separately after shared raster semantics freeze |
| `T6.1`-`T6.6` | `T3.*`, `T4.*`; synchronous borrowed/copy display slot; SPEC-012 stroke view | operation-major tiled backend and Pi/nRF fixture targets | Tile traversal and payload segmentation may be developed separately only after their shared ordering and ownership invariant is fixed |
| `T7.1`-`T7.5` | `T2.*`-`T6.*`; SPEC-009 endpoint seam; SPEC-003 failure/health values | backend endpoint, failure adapter, diagnostics and transaction corpus | Offer normalization and local failure mapping may proceed in parallel; responsibility-transfer/drain evidence waits for both |
| `T8.1`-`T8.6` | Complete focused implementation and canonical corpus; upstream production seams named by each integration | contract driver, comparator, instrumentation, profile builds, conformance preparation | Four profile runs may execute independently after the corpus freezes; semantic comparison and conformance preparation consume all reports |

## Acceptance-Criterion Matrix

The criterion text remains authoritative in SPEC-014. Every criterion appears
exactly once below.

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `BI-001` — Separate surface, raster, display, backend-integration, runtime, and host ownership with every prohibited edge rejected | `T0.2`, `T1.6`, `T8.1` | SwiftPM graph audit, compiled-import scan, positive and negative dependency fixtures | pending |
| `BI-002` — Four exact SPEC-004 configurations and pre-offer rejection of every one-field construction mismatch without target probing | `T2.1`, `T2.2`, `T2.5`, `T7.1` | Complete contribution/effective-value matrix, constructor call-count transcript | pending |
| `BI-003` — Exact nRF52840 480 x 320, 480 x 4, 960-byte-row, 3,840-byte single-slot tiled configuration with no framebuffer | `T2.5`, `T6.5`, `T8.2`, `T8.5` | Normalized fixture, storage report, link/map and forbidden-buffer scan | pending |
| `BI-004` — Checked header bounds and one complete reservation before body, with one finish or cancel | `T2.3`, `T3.1`, `T3.5`, `T7.1`, `T7.2` | Header/reservation/call-order transcript for every terminal path | pending |
| `BI-005` — Complete payload grammar, exact slot reuse, and rejection of every invalid writer/reservation operation | `T3.1`-`T3.5`, `T7.5` | Exhaustive `transactions.yaml` state-transition corpus | pending |
| `BI-006` — Single producer and borrowed-operation calls in both tiled fixtures with bounded storage and no replay, display list, framebuffer, or retained address | `T0.4`, `T6.1`-`T6.5`, `T8.2` | Call-count, borrow-poison, address, storage high-water, and forbidden-symbol reports | pending |
| `BI-007` — Identical affected pixels and exact bytes through recording, RGBA8888, framebuffer RGB565, Pi tiled, and nRF tiled paths | `T4.1`, `T4.6`, `T5.4`, `T6.5`, `T8.3` | Zero-difference normalized image and canonical-byte comparison | pending |
| `BI-008` — Exact SPEC-005 glyph resources are neither reshaped, remeasured, substituted, repositioned, nor retained | `T2.4`, `T4.3`, `T6.3`, `T8.2` | Resource-identity transcript, payload-borrow count, poisoning and address scan | pending |
| `BI-009` — Every SPEC-012 stroke vector has exact full-surface and tiled coverage and encoding | `T4.4`, `T5.4`, `T6.3`, `T8.3` | Imported canonical stroke corpus with zero pixel/byte tolerance | pending |
| `BI-010` — Exact pre-body reservation and body-result mappings, call counts, retained local error, cleanup, and logical disposition | `T7.1`-`T7.3`, `T7.5` | Complete reservation/body/result cross-product transcript | pending |
| `BI-011` — Abortability before transfer and accepted drain plus one health update after transfer, without capability mutation | `T3.4`, `T6.6`, `T7.2`-`T7.4` | First/later payload fault injection, health count, immutable-value snapshot | pending |
| `BI-012` — Equality success and deterministic first excess for every limit in exact detection order | `T1.3`, `T2.2`-`T2.4`, `T3.1`, `T3.2`, `T4.5`, `T7.3`, `T7.5` | Exact-limit/first-excess and simultaneous-failure precedence matrix | pending |
| `BI-013` — Normative value layouts, zero-heap static RGB565 construction/frame, and no forbidden runtime facility | `T1.6`, `T8.2`, `T8.4`, `T8.5` | 32/64-bit layout, allocation, stack, sections, and linked-symbol reports | pending |
| `BI-014` — No operation, resource, Path/stroke, closure, sink, or Core address survives accepted, refused, or failed offer | `T4.3`, `T4.4`, `T6.4`, `T7.2`, `T8.2` | Borrow poisoning and post-offer address scans for every disposition | pending |
| `BI-015` — One registered reproducible four-profile driver with complete fixture, dependency, resource, and timing evidence confined to `.build/spec-014/` | `T0.1`, `T0.3`, `T8.1`-`T8.6` | Standalone driver reports, registry/top-level gate result, output-path audit | pending |

## Milestones and Tasks

### Milestone 0: Freeze Authority, Ownership, Fixtures, and Migration Boundaries

**Entry conditions:** SPEC-014 remains approved and its complete authority
chain remains current.

**Exit evidence:** The target graph intent, canonical fixture schema, migration
inventory, acceptance registry, and registered fail-closed driver exist before
production behavior is claimed.

- [x] `T0.1` — Create `Tests/ContractFixtures/SPEC014/` with README, fixture
      manifest, shared-field schema, acceptance/evidence registry, and exactly
      `raster.yaml`, `transactions.yaml`, `capabilities.yaml`, `failures.yaml`,
      and `resources.yaml`. Require stable fixture IDs and explicit values for
      descriptor, effective capability, header, operations/resources, injected
      events, ordered regions, encoded image, offer/body results, health, and
      every high-water counter; require explicit `none` for inapplicable
      fields and reject missing, duplicate, unknown, or unreferenced data.
- [x] `T0.2` — Freeze and enforce the approved target graph for
      `GiftUISurfaceCore`, `GiftUIRasterCore`, `GiftUIDisplayCore`, and
      `GiftUIBackendIntegration`, their focused tests, and the narrow
      backend-failure adapter fixture. Update `Package.swift`, SPEC-002 target
      inventories, dependency registries, compiled-import checks, and positive
      and negative fixtures atomically with each target's first compiling
      source. Enforce every allowed and prohibited import from SPEC-014; do not
      create placeholders, umbrella exports, compatibility shims, or a second
      owner for existing types.
- [ ] `T0.3` — Create and explicitly register
      `scripts/contracts/run-spec-014.sh --profile <profile>` for exactly
      `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
      `nrf52840-embedded`. Use the repository's immutable driver/report helpers,
      pinned compiler/SDK identities, and `.build/spec-014/` scratch/evidence
      root. Until each assertion exists, emit a failing `missing` or `blocked`
      row; never silently skip a fixture, profile, toolchain, measurement,
      dependency edge, or expected report.
- [ ] `T0.4` — Inventory every historical/current renderer, surface,
      framebuffer, tile, display target, text raster, region/payload writer,
      capability adapter, and platform/device integration reference. Assign
      adopt-through-owner, replace, retire, downstream-owned, evidence-only,
      or already-absent disposition. Add regression scans that reject the
      legacy closure-per-tile replay API, complete display lists/framebuffers
      on the nRF path, target identity checks, and parallel raster semantics.

### Milestone 1: Implement the Exact Surface, Raster, Display, and Endpoint SPI

**Entry conditions:** Milestone 0 fixes target ownership. Each declaration may
land only when all types from its approved upstream owner exist.

**Exit evidence:** The four targets compile with the exact package declarations,
raw values, failable initializers, protocol constraints, access, `Sendable`
conformance, and value layouts from SPEC-014.

- [ ] `T1.1` — In `GiftUISurfaceCore`, implement
      `CanonicalEncodedPixel` and `RasterSurfaceDescriptor` with exact stored
      fields, origin/extent/region/stride validation, checked packed-row and
      region byte products, realization rules, equality, and encoding-specific
      unused-byte zeroing. Add below/equal/above and overflow tests.
- [ ] `T1.2` — Implement `RasterSurface` and a recording conformer that proves
      one begin, bounded in-damage encoded replacement, one finish or discard,
      sticky responsibility transfer, safe draining, and complete reset. Keep
      rasterization and display submission out of this owner.
- [ ] `T1.3` — In `GiftUIRasterCore`, implement `RasterPayloadLimits`,
      `RasterBackendError`, and checked limit helpers. Require all positive
      fields, validate payload-by-in-flight multiplication, preserve equality
      success and first-excess failure, and keep region/counter/driver storage
      separate from capability raster/payload bytes.
- [ ] `T1.4` — In `GiftUIDisplayCore`, implement `DisplayReservationID`,
      reservation/transfer results, `DisplayTargetError`,
      `DisplayPayloadWriter`, and `DisplayTarget` exactly. Prove raw values,
      generic writer association, nonescaping exclusive writer borrow,
      immutable target lifetime/handoff maxima, and authoritative health.
- [ ] `T1.5` — After SPEC-012 supplies `DrawingOperationSink`, implement
      `RasterFrameSink` and `RasterBackendEndpoint` with their exact inherited
      constraints and borrowed immutable properties. Verify Canvas-capable
      sinks accept the canonical stroke operation without importing
      `GiftUIDrawing`, and ordinary render owners gain no raster dependency.
- [ ] `T1.6` — Add compile-surface, negative-import, memory-layout, reference/
      existential/closure/pointer-field, and `Sendable` probes for every
      normative value and protocol boundary on supported 32-bit and 64-bit
      compilers. Enforce the 8/32/40/4/1-byte ceilings and exact dependency
      closure before stateful implementations proceed.

### Milestone 2: Reconcile Contributions, Effective Configuration, and Startup Bounds

**Entry conditions:** Exact value/protocol surfaces compile; SPEC-004 effective
values and SPEC-005 resource views are available.

**Exit evidence:** All four MVP configurations construct from owner facts, and
every mismatch, incompatible resource, missing operation, overflow, or
insufficient bound fails in exact order before an offer or target probe.

- [ ] `T2.1` — Implement the raster-backend and surface/display contributor
      adapters using only the exact SPEC-004 vocabulary and failable
      constructors. Report only locally owned facts; prohibit resolver calls,
      end-to-end Booleans, concrete target probing, health-derived facts, and
      target identity. Test every positive and negative contribution field.
- [ ] `T2.2` — Implement integration construction checks in the normative
      detection order: descriptor construction, exact effective-value equality,
      resource compatibility, operation coverage, raster/payload/in-flight
      stores, glyph/stroke workspace, and per-frame ceilings. Exercise one-field
      mismatch for every effective field and prove no clamp, recomputation,
      target call, or capability mutation.
- [ ] `T2.3` — Implement checked construction-time and per-header calculations
      for damaged rows/pixels, ceiling tile rows, operation-by-tile visits, and
      conservative region/payload submissions. Prove zero damage, equality,
      first excess, every multiplication/addition overflow, and exact
      contract-violation mapping for a header that contradicts construction.
- [ ] `T2.4` — Validate the immutable text descriptor, realization ID, raster
      view availability, greatest selected glyph record, and payload/workspace
      bounds before first offer. Preserve exact SPEC-005 identity; test missing,
      mismatched, malformed, unavailable, and post-startup impossible cases
      without fallback or substitution.
- [ ] `T2.5` — Populate `capabilities.yaml` with macOS dynamic/static
      full-surface, Raspberry Pi 240 x 240 with 240 x 16 RGB565 regions, and
      nRF52840 480 x 320 with 480 x 4 RGB565 regions. Assert the nRF 960-byte
      row and exact 3,840-byte raster/payload/in-flight single-slot values and
      reject a full framebuffer. Use one checked-in immutable host input for
      the paired macOS fixture extent, without selecting a production window
      size in this plan. Compare macOS effective/logical results while keeping
      runtime profile identity outside capability data.

### Milestone 3: Implement Reservation, Writer, Payload, and Frame Grammar

**Entry conditions:** Display SPI, descriptors, and payload limits compile.

**Exit evidence:** A recording display target exhaustively enforces the one-
session reusable-slot grammar, ownership transition, completion, cancellation,
identity lifetime, and target-local health.

- [ ] `T3.1` — Implement checked monotonic reservation identity allocation
      starting at zero with no reuse or wrap, one active frame session, exact
      reservation arguments, idle/inactive/stale detection, and one terminal
      `finishFrame` or `cancelFrame`. Cover exhaustion before mutation.
- [ ] `T3.2` — Implement the bounded writer state machine: one nonempty
      horizontal in-bounds/in-damage region, exact encoding, no row crossing or
      nesting, exact left-to-right byte count, packed regions, deterministic
      zero initialization, finish/discard, and per-payload byte/region counters.
      Fault every underflow, overflow, empty finish, double transition, stale
      writer, wrong encoding, and reentrancy case.
- [ ] `T3.3` — Implement exactly one submission for each successful writer
      finish, slot reuse only after completed synchronous submission, and the
      selected borrow/copy/transfer/queued ownership behavior. Permit tiled
      multi-payload reuse only for synchronous handoff with synchronous borrow
      or copy; restrict queued/ownership-transfer to zero-or-one-payload
      full-surface sessions.
- [ ] `T3.4` — Implement responsibility transfer at the first completed or
      after-acceptance submission/effect, exact before/after-acceptance result
      legality, draining state, and one target-owned health transition per
      frame. Prove a pre-transfer writer/submission failure is fully reversible
      and a post-transfer failure cannot cancel or reopen disposition.
- [ ] `T3.5` — Cover zero-, one-, and multi-payload sessions, zero-damage frame
      completion, failed writer-body discard, failed pre-transfer submission,
      cancellation, frame-end failure, teardown of display-owned in-flight
      data, and exact counter reset. Freeze the complete `transactions.yaml`
      oracle before raster backends depend on it.

### Milestone 4: Implement Canonical Encoding and Shared Raster Semantics

**Entry conditions:** Surface and display recording oracles pass. Fill and
positioned-glyph operations exist; stroke tasks consume SPEC-012's approved
borrowed stroke view and completion-seam contract.

**Exit evidence:** One backend-neutral raster core produces exact affected
pixels, byte encodings, ordering, clipping, resource use, and bounded counters
for every operation independently of full-surface or tiled storage.

- [ ] `T4.1` — Implement exact RGBA8888 and big-endian RGB565 encoding with
      widened checked arithmetic, alpha 255, unused bytes zero, and no gamma,
      premultiplication, dithering, color-space conversion, or native-format
      substitution. Cover channel values 0, 1, 127, 128, 254, and 255.
- [ ] `T4.2` — Implement half-open surface/damage/resolved-clip intersection,
      checked negative/out-of-range geometry rejection, empty intersections,
      opaque replacement painter order, and fill coverage. Keep Canvas bounds
      out of clipping and row padding out of logical comparison.
- [ ] `T4.3` — Rasterize positioned glyphs only through the exact immutable
      SPEC-005 realization. Resolve the exact record and call `withPayload` at
      most once per glyph, consume the borrow before return, preserve baseline
      and clip, and reject missing payload/lookup as the exact post-startup
      invariant without reshaping, measuring, substitution, or repositioning.
- [ ] `T4.4` — Implement every SPEC-012 canonical straight-line stroke vector,
      including subpaths, duplicate points, zero length, odd/even width,
      butt/round caps, miter/round joins and limit, origin, inherited clip, and
      binary pixel-center coverage. Consume the complete borrowed view within
      the operation call and preserve identical grouping and endpoint meaning.
- [ ] `T4.5` — Track raster bytes, tile visits, region submissions, payloads,
      glyph bytes, stroke workspace, and every algorithm work bound with
      checked equality/first-excess behavior and sticky first local failure.
      Continue validation-only draining after accepted responsibility.
- [ ] `T4.6` — Build the canonical recording endpoint/surface and populate
      `raster.yaml` from exact fills, glyphs, all SPEC-012 strokes, clipping,
      damage, odd strides, partial edges, empty intersections, negative
      geometry, painter overwrites, and overflow cases. Freeze zero-tolerance
      logical pixel masks and both canonical byte encodings.

### Milestone 5: Implement Full-Surface RGBA8888 and RGB565 Realizations

**Entry conditions:** Shared raster semantics and display grammar pass. Exact
full-surface capacities and maximum damaged-row region count are admitted.

**Exit evidence:** Recording, RGBA8888 buffer, and RGB565 framebuffer adapters
produce the same logical affected image and exact selected bytes through the
one-payload full-surface rule.

- [ ] `T5.1` — Implement a bounded full-surface RGBA8888 buffer conforming to
      `RasterSurface`, including exact stride/padding, begin/replace/finish/
      discard grammar, complete-damage validation, and one retained encoded
      surface owned below Core.
- [ ] `T5.2` — Implement the hardware-free full-surface/framebuffer RGB565
      adapter with the same surface contract and explicit mapped-surface plus
      workspace accounting. It must not open a device, deploy, or claim a
      connected framebuffer/PiScreen result.
- [ ] `T5.3` — Emit affected full-width rows only after complete stream
      success, in exactly one payload, with no effect during operation
      consumption. Cover zero damage, odd stride, row padding, maximum damaged
      rows, payload/region equality and first excess, cancellation, and faults
      on submission/frame completion.
- [ ] `T5.4` — Run every frozen raster case through recording, RGBA8888, and
      RGB565 full-surface paths. Compare affected logical pixels, ordering,
      exact bytes, counters, operation/resource calls, and pre/post-transfer
      behavior with zero tolerance.

### Milestone 6: Implement Operation-Major Bounded RGB565 Tiled Realization

**Entry conditions:** Shared raster semantics and synchronous reusable display
slot pass. The canonical borrowed stroke operation is implemented.

**Exit evidence:** Pi and nRF targets rasterize every operation across its
intersecting full-width row tiles before returning from that borrowed call,
with one producer invocation, bounded owned payloads, and no retained Core
address or complete frame buffer/list.

- [ ] `T6.1` — Implement one caller-owned full-width row-tile workspace and
      operation-major traversal. For each operation, visit every intersecting
      tile in order and complete all owned derivation/submission before the
      borrowed call returns; never invoke the producer per tile or revisit a
      prior operation.
- [ ] `T6.2` — Implement ordered left-to-right horizontal run formation,
      longest-convenient coalescing, deterministic payload zeroing, and flush
      before the next run would exceed byte or region capacity. Bound payloads,
      region records, tile visits, region submissions, and in-flight bytes
      independently.
- [ ] `T6.3` — Exercise fills, exact glyph payloads, and all canonical strokes
      across tile/region boundaries, partial final tiles, empty intersections,
      clips, damage, and later-operation overwrites. Prove logical output and
      byte encoding match the full-surface oracle regardless of segmentation.
- [ ] `T6.4` — Add producer/operation/resource call counts, borrow poisoning,
      workspace poisoning, and post-call/post-offer address capture. Reject
      retained operations, glyph/stroke views, producer closure or sink borrow,
      replay, dynamic display lists, and hidden full-frame storage.
- [ ] `T6.5` — Run the exact Raspberry Pi 240 x 16 and nRF52840 480 x 4 region
      configurations at equal and worst-case limits. Record tile/payload/region
      high-water and prove one in-flight slot, 3,840-byte nRF storage, no full
      framebuffer, and exact equality with recording/full-surface output.
- [ ] `T6.6` — Inject failure before the first submitted payload and on the
      first and later payloads. Before transfer, discard/cancel with no effect;
      after transfer, stop physical work, keep validating/draining every later
      borrow, call `finishFrame` once, update health once, and preserve accepted
      logical disposition.

### Milestone 7: Join the One-Shot Endpoint, Failure Mapping, and Health Boundary

**Entry conditions:** Startup validation, raster realizations, display grammar,
and exact SPEC-009 endpoint values pass independently.

**Exit evidence:** The production integration reserves before body, consumes
once, maps every result exactly, transfers responsibility irreversibly, and
preserves failure/health/diagnostic ownership.

- [ ] `T7.1` — Implement endpoint `offer`: validate provenance/envelope,
      immutable effective configuration, exact header work, idle state, and
      resource compatibility; reserve one complete session before body; map
      backpressure/refusals/failures exactly; and call the body at most once.
      Record target/body call counts for every pre-body exit.
- [ ] `T7.2` — Implement exact stream completion and cleanup. On complete,
      accept after the sink has performed one surface and target finish. Before
      transfer, map each non-complete body result through SPEC-009 and perform
      one discard/cancel. After transfer, accept every body result, preserve
      producer failure, quiesce when required, drain safely, and retain only
      backend/display-owned bytes and operational state.
- [ ] `T7.3` — Implement a narrow backend-owner failure adapter that preserves
      the sticky `RasterBackendError` or `DisplayTargetError` and maps every
      construction, reservation, geometry/resource, writer, raster, display,
      reentrancy, and invariant condition to the exact SPEC-003 condition,
      origin, scope, and containment in the stated detection order. Low-level
      display/transport modules must not import execution correlation.
- [ ] `T7.4` — Project authoritative target health through the endpoint without
      caching or reconstructing it. Record exactly one unavailable component
      fact for the first post-acceptance transport failure or one quiesced
      runtime fact for an invariant failure. Run diagnostics omitted, selected,
      saturated, dropped, and failing and prove no change to output, result,
      capability, health authority, or input-eligibility facts.
- [ ] `T7.5` — Complete `transactions.yaml` and `failures.yaml` with every
      reservation outcome, body result, legal/illegal transfer result, writer
      misuse, simultaneous detection point, local error, offer disposition,
      cleanup action, responsibility state, health transition, drain count,
      and diagnostic mode. Validate exact first-failure precedence and reject
      impossible operational results after successful construction.

### Milestone 8: Freeze Evidence, Run Four Profiles, and Prepare Conformance

**Entry conditions:** All focused unit/oracle suites pass and the canonical
corpus is immutable. Production integrations start only after their governing
plans supply the named seam. No deployment, remote access, or flashing is
authorized.

**Exit evidence:** The exact standalone SPEC-014 driver passes every source,
semantic, failure, dependency, resource, and hardware-free cross-build check;
all criteria are ready for evidence-based conformance review.

- [ ] `T8.1` — Finalize the canonical loader, fixture/acceptance manifests,
      dependency checks, and driver. Register every case exactly once, reject
      omitted shared fields and profile-private expectations, verify all
      generated output remains under `.build/spec-014/`, and compare normalized
      reports by fixture ID rather than address or implementation identity.
- [ ] `T8.2` — Add resource instrumentation for surface/tile/glyph/stroke/
      region/payload/in-flight/display storage, tile/region/payload counts,
      stack high-water, heap calls, frame raster/submit timing, value layouts,
      linked symbols, and text/rodata/data/BSS deltas. Record exact header,
      damage, resources, region geometry, compiler, optimization, warm-up, and
      sample method. Static construction plus worst-case frame must allocate
      zero heap bytes.
- [ ] `T8.3` — Run macOS dynamic and static against the same canonical corpus,
      integrating SPEC-008/SPEC-009/SPEC-012 production operations only through
      their exact owner seams. Compare logical pixels, bytes, region order,
      results, health, counters, and failures field by field. No static-private
      semantics or dynamic-only fallback is allowed.
- [ ] `T8.4` — Preflight with `scripts/raspberry-pi/doctor.sh --probe` under the
      repository Pi toolchain skill, then compile/link the complete SPEC-014
      corpus for `armv6-unknown-linux-gnueabihf`. Record compiler/SDK identity,
      ARMv6 target, layouts, allocations, resources, timings where executable,
      and link map. Do not deploy or claim `armv6l`/PiScreen evidence.
- [ ] `T8.5` — Preflight with `scripts/nrf52840/doctor.sh --probe` under the
      repository nRF toolchain skill, then compile/link the exact 480 x 4
      static tiled fixture for `nrf52840dk/nrf52840` using
      `armv7em-none-none-eabi` and Zephyr's Cortex-M4F hard-float flags. Verify
      VFP ELF attributes, zero allocator calls, no forbidden facility or full
      framebuffer/list, exact sections and storage high-water. Never flash or
      claim connected TFT evidence.
- [ ] `T8.6` — Run `scripts/format-swift.sh`, focused unit/contract tests, the
      exact standalone four-profile SPEC-014 driver, cross-profile comparator,
      driver-registry check, dependency checks, and repository test gate.
      Create `docs/conformance/spec-014-conformance.md`, link it from SPEC-014
      and this plan, and populate every `BI-001` through `BI-015` row with
      stable evidence or an explicit deviation/exception request. Do not mark
      SPEC-014 `implemented` without human authorization or describe connected
      framebuffer, PiScreen, or TFT validation that was not actually run.

## Design-Note Triggers

- Create `docs/implementation-designs/spec-014-display-session-grammar.md`
  only if the reusable-slot writer, reservation identity, responsibility
  transfer, draining, and finish/cancel state machine cannot be reconstructed
  reliably from local code and tests. It may explain storage and transition
  guards but cannot change any legal transition or lifetime.
- Create `docs/implementation-designs/spec-014-operation-major-tiled-raster.md`
  when production work selects the internal tile workspace, run coalescing,
  stroke traversal, and payload-flush mechanics. Document how the selected
  mechanism preserves the complete operation borrow, painter order, checked
  ceilings, and zero-heap path; do not freeze a replayable or tile-major
  alternative.
- Create `docs/implementation-designs/spec-014-endpoint-responsibility-drain.md`
  only if endpoint/surface/display ownership after the first effect and
  failure-driven validation-only draining are distributed across enough
  components to obscure review. The note cannot introduce rollback, late
  refusal, Core completion, or a new recovery policy.
- Concrete framebuffer mapping, SPI/DMA, GPIO, device initialization, and
  host configuration belong to their platform/transport or SPEC-015 design
  records, not to a reusable SPEC-014 note.

## Integration and Validation Order

1. Freeze ownership, fixture schemas, migration dispositions, acceptance rows,
   and a fail-closed registered driver before implementation can hide missing
   evidence.
2. Land exact surface/raster/display values and protocols with layout/import
   probes. Then prove contribution/effective-value reconciliation and startup
   work bounds without opening a target or invoking an offer.
3. Complete the recording display transaction oracle before writing a raster
   backend. Complete shared encoding, clipping, fill, and text raster semantics
   before splitting into full-surface and tiled storage realizations.
4. Add canonical stroke rasterization only through SPEC-012's exact borrowed
   operation. Compare each realization to the same recording/golden oracle;
   never copy the operation into a retained list merely to unblock tiling.
5. Prove full-surface one-payload behavior, then operation-major multi-payload
   behavior. Fault before and after responsibility transfer before joining the
   production one-shot endpoint and failure adapter.
6. Run focused tests and the complete macOS dynamic/static corpus first.
   Preflight the repository-local Pi and nRF toolchains, then run hardware-free
   ARMv6 and Embedded Swift compile/link/resource inspection. Those checks do
   not deploy, flash, access a remote target, or prove connected hardware.
7. Collect final resource/timing evidence only after the canonical corpus and
   instrumentation boundaries freeze. Register the exact standalone driver
   and normalized comparator with the top-level gate before conformance review.

## Risks and Upstream Blockers

### Implementation risks

- Operation-major tiling combines synchronous borrowed operations with
  reusable payload flushing. An accidental helper that retains an operation,
  glyph/stroke view, sink, or closure violates the central lifetime contract;
  poisoning and address capture must be present from the first tiled slice.
- Conservative region and tile-visit ceilings can be much larger than actual
  emission. Checked construction and exact-header admission must share one
  auditable arithmetic implementation; an implementation-specific smaller
  proof becomes normative for that implementation and requires its own tests.
- Glyph bitmap and canonical stroke coverage can diverge at clips, tile edges,
  odd widths, and painter overwrites. The same frozen logical mask must drive
  recording, full-surface, and both tiled paths before encoding comparison.
- Post-transfer failure has deliberately asymmetric behavior: physical work
  may stop while stream grammar and borrows continue to be validated. Mixing
  raster state, offer disposition, and health can cause late refusal or double
  health recording; keep those axes explicit and fault every transition.
- Static zero-heap evidence can be invalidated by generic existential boxing,
  convenience collections, closure capture, test-only paths, or instrumentation
  itself. Measure the actual construction and worst-case frame path and inspect
  the final link closure, not only source spelling.
- Four new targets and focused tests add module metadata and specialization
  cost. Preserve the accepted graph first, then measure and reduce internal
  representation if needed; do not collapse owners to save module count.

### Upstream blockers

- `T1.5`, `T4.4`, `T6.3`, `T6.4`, and stroke portions of cross-profile
  evidence require SPEC-012's production `DrawingOperationSink` and borrowed
  canonical stroke declarations. If their approved source shape cannot be
  implemented, return the problem to SPEC-012 review rather than inventing a
  backend-private stroke contract.
- Production endpoint integration requires the exact landed SPEC-008 render
  operations and SPEC-009 one-shot endpoint surface. Recording fixtures may
  model those approved seams, but they cannot become duplicate production
  owners or support a conformance claim while the real owners are absent.
- Final dynamic/static runtime integration belongs to SPEC-013, and production
  target capacities, component construction, input coordination, and platform
  selection belong to SPEC-015. Their absence blocks only those integration
  claims; it does not authorize SPEC-014 to absorb profile or host behavior.
- Any need for mid-frame backpressure, replayable operations, retained Core
  resources, queued/ownership-transfer tiled reuse, platform identity in
  capability resolution, backend text layout, or post-handoff rollback is an
  architectural conflict. Pause the affected task and return through RFC/ADR
  work rather than changing this plan or implementation.
- A compiler inability to meet the exact value ceilings, nonescaping borrow,
  zero-allocation, or VFP ABI requirements is a contract or toolchain blocker.
  Record the exact compiler/profile evidence and route it upstream; do not
  weaken the assertion or substitute an unsupported target.

## Deferred and Follow-up Work

- [FW-010](../future-work/fw-010-backend-transport-submission-retry.md)
  preserves optional bounded transport recovery after accepted handoff. It is
  not scheduled here; SPEC-014 permits health and abandonment/repair only
  within its approved reusable boundary.
- [FW-014](../future-work/fw-014-replayable-operation-delivery.md) preserves a
  possible replayable operation lifetime after a measured future trigger. It
  is not an implementation escape hatch for the MVP tiled realization.
- [SPIKE-001](../spikes/spike-001-tiled-one-shot-capability-fixtures.md),
  [SPIKE-002](../spikes/spike-002-nrf52840-capability-path-resource-evidence.md),
  and [SPIKE-004](../spikes/spike-004-canvas-path-plan-feasibility.md) remain
  feasibility evidence only. Production code, capacities, storage layouts,
  and conformance claims must be implemented and proven under this plan.

No new deferred artifact was discovered while drafting this plan. The current
MVP scope and both existing deferred boundaries remain unchanged.

## Completion Record

Implementation began on 2026-09-12. `T0.1` froze the five-corpus fixture
schema, shared-field vocabulary, acceptance/evidence registry, and fail-closed
schema validator. `T0.2` froze the four production owners, five focused test/
adapter owners, every exact direct edge, prohibited dependency classes, and
reserved-to-active activation rule. Package and SPEC-002 exact-set rows remain
required atomically when each owner receives its first substantive source;
empty placeholder targets are rejected. Every `BI-001` through `BI-015`
evidence row remains pending.
Record completed, changed, removed, and blocked task dispositions as work
proceeds; do not silently rewrite task history.

Plan completion requires every task to have an explicit disposition and a
linked `docs/conformance/spec-014-conformance.md`. A complete plan and report
do not mark SPEC-014 implemented; that lifecycle transition requires complete
conformance evidence and explicit human authorization.
