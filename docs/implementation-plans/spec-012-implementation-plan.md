---
spec: SPEC-012
feature: canvas-drawing
title: SPEC-012 Implementation Plan
status: active
owners:
  - codex
created: 2026-09-09
updated: 2026-09-13
related_design_notes:
  - ../implementation-designs/spec-012-scoped-path-and-plan-storage.md
  - ../implementation-designs/spec-012-static-canvas-lowering.md
  - ../implementation-designs/spec-012-combined-render-traversal.md
conformance_report: null
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-004
  - SPIKE-007
  - SPIKE-008
supersedes: null
superseded_by: null
---

# SPEC-012 Implementation Plan

> This active plan incorporates the explicitly approved 2026-09-12
> render-extension completion-seam amendment. Completed task records remain
> historical implementation evidence, and T5.2-T5.5 may now resume through the
> amended package SPI. The plan orders implementation and evidence but does not amend
> the drawing invocation, scoped ownership, normalized stroke, failure,
> capacity, raster, profile, backend, or host contracts owned by that
> Specification and its authoritative dependencies.

## Authority and Scope

The governing [SPEC-012](../specs/spec-012-canvas-path-stroke-drawing.md) is
`implementing`, including the explicitly approved focused completion-seam
correction. Its authority chain remains accepted
[PROPOSAL-006](../proposals/proposal-006-canvas-path-stroke-drawing.md),
approved
[RFC-009](../rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md), and
accepted
[ADR-028](../adrs/adr-028-post-layout-canvas-derivation-and-cycle-local-plan.md),
[ADR-029](../adrs/adr-029-scoped-transient-path-snapshot-semantics.md),
[ADR-030](../adrs/adr-030-canonical-normalized-straight-line-stroke-operation.md),
and
[ADR-031](../adrs/adr-031-bounded-canvas-failure-and-startup-gate-integration.md).

Approved SPEC-002 owns checked geometry and four-profile evidence; SPEC-003
owns cross-layer failure outcomes; SPEC-004 owns the existing
`rasterPresentation` capability; SPEC-006 owns semantic identity and typed
primitive traversal; SPEC-007 owns Canvas layout bounds; SPEC-008 owns the
ordinary render traversal, color, clipping, and stream transaction; and
SPEC-009 owns phase, publication, one-shot offer, refusal, and dirty
rederivation. Approved SPEC-001 and SPEC-015 own the Signal Analyzer workload
and host configuration, SPEC-013 owns dynamic/static profile storage and
generation, and SPEC-014 owns concrete backend and raster integration. This
plan consumes those contracts without duplicating their owners.

The [MVP Scope](../MVP_SCOPE.md) requires the substantially shared Signal
Analyzer presentation to draw its time grid and four data-driven digital
traces on macOS dynamic, macOS static, Raspberry Pi 1/Linux dynamic, and
nRF52840 static configurations. SPEC-012 supplies the minimal portable
straight-line Canvas surface and the bounded normalized drawing path required
for that validation. It does not authorize richer drawing, retained plans,
animation, deployment, remote service changes, or connected-board flashing.

## Current Repository State

- `GiftUI` already owns SPEC-002 geometry plus the in-progress SPEC-006 and
  SPEC-008 public surfaces. It has no `Canvas`, `GraphicsContext`, `Path`,
  `Shading`, `StrokeStyle`, `LineCap`, `LineJoin`, or `DrawingError` declarations.
- `GiftUISemanticCore` has the generic primitive staging seam and an
  in-progress `SemanticRenderView`, but no typed Canvas payload retention,
  Canvas invocation view, or `.canvas` rendering scope. SPEC-007's
  `SemanticLayoutPrimitive.canvas` and resolved layout owner do not yet exist.
- `GiftUIRenderCore` contains the ordinary SPEC-008 render value and sink
  surface. It has no `StraightLineStrokeHeader`, `StraightLineStrokeView`, or
  `DrawingOperationSink` contract. `GiftUIRenderLowering`, `GiftUILayout`, and
  `GiftUIDrawing` targets are absent from `Package.swift`.
- `GiftUIExecution` contains the focused SPEC-009 phase, candidate, offer,
  refusal, dirty-recovery, and finalization machinery. The production runtime
  coordinator that sequences semantic, layout, drawing, publication, and
  combined offer remains owned by SPEC-013.
- SPEC-007, SPEC-008, SPEC-013, SPEC-014, and SPEC-015 are approved; none of
  SPEC-013 through SPEC-015 has started production implementation. SPEC-007
  and SPEC-008 have ready plans. SPEC-009 is implementing; SPEC-008 has its
  client declarations and part of Render Core, while its resolved-layout and
  lowering work remains open. The
  runtime-profile, backend-integration, and host-configuration production
  targets remain absent.
- There is no `Tests/ContractFixtures/SPEC012/`, focused drawing unit-test
  target, drawing failure-adapter fixture, generated static Canvas fixture,
  canonical stroke raster corpus, `scripts/contracts/run-spec-012.sh`, or
  SPEC-012 driver-registry row.
- SPIKE-004 supplies feasibility evidence for bounded plan construction,
  SPIKE-007 supplies negative direct-closure and positive generated-callable
  evidence, and SPIKE-008 supplies corrected typed-throws/two-`inout`
  declaration evidence. Their experiment code is not production authority and
  is not migrated wholesale.
- Existing contract drivers and fixture trees provide reusable conventions for
  fail-closed manifests, exact profile commands, positive and negative compile
  witnesses, normalized transcripts, allocation and symbol inspection,
  cross-build resource evidence, and explicit `scripts/test.sh` registration.

## Readiness Review

**Reviewed:** 2026-09-12

**Disposition:** Ready. T5.2 exposed a contractual completion gap in the
otherwise reusable SPEC-008 producer extension; the focused SPEC-012 amendment
now defines that missing package SPI without changing accepted architecture.
The maintainer explicitly approved the amendment on 2026-09-12 and resumed the
plan, so T5.2-T5.5 may proceed.

No `docs/features.yaml` change is required because `canvas-drawing` remains in
the implementation stage based on completed work under the previously approved
contract. The amendment does not register a new feature or change MVP scope.

If the supported compilers cannot express the approved scoped noncopyable or
typed-throws surface, if exact identity cannot cross the semantic/layout/drawing
seams without translation or retention, if the combined producer cannot reuse
SPEC-008's traversal, or if the required value/resource bounds cannot be met,
the affected work returns to Specification or architecture review. The plan
must not add a fallback closure, second semantic/render traversal, relaxed
stroke meaning, target branch, silent omission, or new capability field.

## Task Dependencies and Affected Surfaces

Milestone numbers define the default execution order. A task may start only
after every listed prerequisite is satisfied.

| Work | Prerequisites | Primary affected surfaces | Parallel boundary |
| --- | --- | --- | --- |
| `T0.1`-`T0.4` | Approved SPEC-012 authority chain | `Tests/ContractFixtures/SPEC012/`, `Package.swift`, `scripts/contracts/`, graph and migration fixtures | Evidence schemas, migration inventory, and driver scaffolding may proceed together; exact target-graph edits land with their first compiling sources |
| `T1.1`-`T1.5` | `T0.2`; existing SPEC-002/006/008 public owners | `Sources/GiftUI/`, `Tests/GiftUITests/`, compile fixtures | Declaration families and negative ownership witnesses may proceed in parallel after the shared scoped-storage seam is fixed |
| `T2.1`-`T2.5` | `T0.2`; relevant `T1.*`; SPEC-006 exact identity/payload seam for production adaptation | `Sources/GiftUISemanticCore/`, `Sources/GiftUIRenderCore/`, focused tests | Render-Core values and direct semantic fixtures may proceed before production semantic-result adaptation |
| `T3.1`-`T3.6` | `T1.*`, `T2.2`-`T2.3`; SPEC-002 checked geometry | `Sources/GiftUIDrawing/`, drawing unit tests, recording plan fixtures | Limit/value construction may proceed beside private workspace storage; mutation, snapshot, and lifecycle tasks then follow shared invariants |
| `T4.1`-`T4.5` | `T2.1`, `T3.*`; SPEC-007 resolved layout and SPEC-009 execution context for production integration | `GiftUISemanticCore`, `GiftUILayout`, `GiftUIDrawing`, `GiftUIExecution`, cycle fixtures | Direct source/layout/execution fixtures may establish local behavior; production identity-preserving integration waits for SPEC-007 and the owning runtime coordinator |
| `T5.1`-`T5.5` | `T2.*`, successful drawing plans from `T3`-`T4`; SPEC-008 lowering workspace and traversal; approved focused completion-seam amendment | `GiftUIDrawing`, `GiftUIRenderCore`, rendering fixtures | Completed T5.1 preflight evidence remains historical; T5.2 first migrates that summary check into the approved completion seam, then production and transcript/failure/boundary audits proceed |
| `T6.1`-`T6.5` | `T1.*`, `T3.*`; SPEC-013/015 generated storage and host assembly where named | static generator fixtures, profile storage, host configuration | Generator grammar and negative cases may proceed locally; production captures, numeric limits, and host lifetime proofs wait for SPEC-013 and SPEC-015 |
| `T7.1`-`T7.4` | `T3`-`T6`; SPEC-004 resolver and SPEC-015 B2/host gates | structural/capability fixtures, owner adapter, runtime-cycle integration | Artificial equality/first-excess matrices may run before production host values; Signal Analyzer capacity proof waits for SPEC-001/015 assembly |
| `T8.1`-`T8.4` | `T5`; SPEC-014 backend consumers and raster workspaces | shared raster vectors, RGBA8888/RGB565 consumers, backend integration fixtures | Golden-mask generation and recording semantics may be frozen independently; concrete full-surface/tiled evidence waits for SPEC-014 |
| `T9.1`-`T9.6` | All applicable implementation and corpus tasks | resource probes, four profile reports, repository gates, conformance report | Profile runs may execute independently after the corpus freezes; equality comparison and conformance preparation consume all four reports |

## Acceptance-Criterion Matrix

The criterion text remains authoritative in SPEC-012. Every criterion appears
once below and maps to implementation tasks and reproducible evidence.

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `DR-001` — Exact public declarations and typed-throws scoped source compile; illegal context/Path use fails | `T1.1`-`T1.5`, `T6.2`, `T9.1` | Public-interface audit plus four-profile positive and negative compile transcripts | pending |
| `DR-002` — Canvas is one identity-preserving `Body == Never` semantic/layout/render leaf with no unrelated output | `T1.1`, `T2.1`, `T2.4`, `T4.1`, `T4.2`, `T9.2` | Semantic, layout, and render event transcript with zero-child/zero-unrelated-event assertions | pending |
| `DR-003` — Each occurrence invokes once after layout in `.deriving`, releases before publication, and re-expands after refusal | `T4.1`-`T4.5`, `T7.4`, `T9.2` | Cycle timeline, invocation/release counts, revision tokens, throwing cleanup, and refusal-recovery transcript | pending |
| `DR-004` — Stroke snapshots are immutable and preserve every explicit subpath | `T3.3`-`T3.6`, `T9.2` | Stroke-mutate-stroke, multiple-subpath, zero-length, atomic-capacity, and snapshot-isolation fixtures | pending |
| `DR-005` — Combined sink receives exact header, operations, styles, geometry, clips, no-ops, order, begin, and finish | `T2.2`, `T5.1`-`T5.5`, `T9.2` | Cross-profile canonical combined recording transcript and header comparison | pending |
| `DR-006` — RGBA8888 and tiled RGB565 match every normative mask and byte vector exactly | `T8.1`-`T8.4`, `T9.2`, `T9.4` | Shared vector corpus, zero-difference mask/byte reports, and full-surface/tiled equality report | pending |
| `DR-007` — Every validation/capacity edge follows exact precedence, SPEC-003 mapping, and lifecycle disposition | `T3.2`-`T3.6`, `T5.2`-`T5.5`, `T7.3`-`T7.4`, `T9.2` | Ordered injected-failure matrix, mapping transcript, discard/dirty/refusal/invariant effect counts | pending |
| `DR-008` — B2 and semantic capability startup gates pass/fail independently without drawing capacity in capability state | `T6.4`, `T7.1`, `T7.2`, `T9.2` | Equality/first-excess workload matrix, capability matrix, snapshot-field audit, and Signal Analyzer host proof | pending |
| `DR-009` — No sink borrow, plan, or closure outlives its required scope | `T3.5`, `T4.3`-`T4.5`, `T5.4`, `T9.3` | Poison-borrow probes and accepted/refused/failed lifecycle storage audits | pending |
| `DR-010` — Static generation uses complete nonzero IDs and bounded inline captures, rejecting unsupported/over-limit cases | `T6.1`-`T6.5`, `T9.1`, `T9.4` | Generated-source manifest, switch-coverage audit, repeated-occurrence records, compile-failure corpus, and no-fallback scan | pending |
| `DR-011` — Static typed errors and cleanup use zero heap and exclude forbidden runtime/symbol dependencies | `T1.5`, `T6.2`-`T6.5`, `T9.3`, `T9.4` | Throwing cleanup transcripts, allocation interposer, linked-symbol/section reports, and nRF ELF inspection | pending |
| `DR-012` — Normative value ceilings and separate capture/path/plan/render/raster/derived/stack/RAM/flash/timing costs are evidenced | `T2.3`, `T3.1`, `T9.3`-`T9.5` | Per-compiler layout reports and separately itemized resource/high-water/link/timing evidence | pending |
| `DR-013` — Module ownership/import graph and portable target independence remain exact | `T0.2`, `T2.5`, `T5.5`, `T9.1`, `T9.5` | Target dependency allow-list, import-negative fixtures, symbol-owner audit, and portable-source scan | pending |

## Milestones and Tasks

### Milestone 0: Freeze Authority, Boundaries, and Evidence Schemas

**Entry conditions:** These tasks were completed under the previously approved
SPEC-012 contract. PROPOSAL-006 remains `accepted`; RFC-009 remains `approved`;
ADR-028 through ADR-031 remain `accepted`; and the related Specifications
retain their current authority. The completion-seam amendment was explicitly
approved on 2026-09-12.

**Exit evidence:** The exact module graph, canonical corpus schemas, migration
baseline, and registered fail-closed four-profile driver exist before any
drawing conformance is claimed.

- [x] `T0.1` — Create `Tests/ContractFixtures/SPEC012/` with an ordered fixture
      manifest, declaration and negative-compile registries, normalized semantic/
      layout/cycle/plan/render/raster result schemas, failure-precedence table,
      acceptance/evidence registry, symbolic identity tokens, and README.
      Distinguish host execution, cross-build/inspection, simulator, and
      connected-hardware evidence; no task in this plan deploys or flashes.
- [x] `T0.2` — Add `GiftUIDrawing`, its focused unit-test target, and a narrowly
      named drawing/failure owner-adapter fixture only with their first compiling
      sources. Add the approved `GiftUIDrawing` dependency edges and
      `GiftUIRenderCore` drawing contracts without importing profiles, failure
      owners, capabilities, backends, rasterizers, platforms, drivers, OS/RTOS,
      HAL, or hardware targets. Update exact target allow-list fixtures.
- [x] `T0.3` — Create and explicitly register
      `scripts/contracts/run-spec-012.sh --profile <profile>` for
      `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
      `nrf52840-embedded`. Record pinned compiler/SDK/target/optimization,
      revision, input digests, commands, evidence identity, and all thirteen
      fail-closed criterion rows. Keep standalone invocations exact and make
      the top-level runner perform no remote access, deployment, or flashing.
- [x] `T0.4` — Inventory every PoC and experiment Canvas/path/stroke, display-
      list, direct-emission, raster, and static-callable surface. Classify each
      as evidence, adapt, replace, retire, or downstream-owned, pin provenance,
      and reject parallel maintained drawing paths or wholesale Spike adoption.

### Milestone 1: Implement the Public Scoped Drawing Surface

**Entry conditions:** `T0.2`; maintained SPEC-002 geometry, SPEC-006 primitive
payload, and SPEC-008 `Color` declarations remain available.

**Exit evidence:** The exact public source contract compiles where supported,
all forbidden ownership/escape examples fail, and Canvas traversal stages one
typed primitive without evaluating `body` or invoking drawing.

- [x] `T1.1` — Implement exact `Canvas` declaration, initializer, `Body == Never`,
      invariant `body`, primitive marker, and one-call traversal override in
      `GiftUI`. Preserve the exact draw callable for semantic staging without a
      public/package lookup and without invocation during expansion.
- [x] `T1.2` — Implement noncopyable, non-publicly-constructible
      `GraphicsContext` and `Path` with the exact two-`inout`, nonescaping,
      typed-throws `withPath`, `move`, `addLine`, and both `stroke` declarations.
- [x] `T1.3` — Implement exact `Shading`, `StrokeStyle`, `LineCap`, `LineJoin`,
      and `DrawingError` declarations. Preserve opaque RGB exactly, mark
      nonpositive style widths invalid for the next stroke, and make the width
      overload precisely `.butt` plus `.miter`.
- [x] `T1.4` — Add positive compile witnesses for defaults, both stroke overloads,
      explicit typed trailing closures, stroke-mutate-stroke reuse, multiple
      subpaths, and concrete `DrawingError` throws. Add negative witnesses for
      initializers, copy/consume/escape, asynchronous escape, missing typed
      throws where required, unsupported errors, and captured outer-context
      overlapping access.
- [x] `T1.5` — Run the public witnesses across all four profile compilers and
      compare the maintained surface with SPIKE-008 only as evidence. Audit
      emitted interfaces/SIL/symbols for accidental `any Error`, retained
      closure, allocator, reflection, concurrency, exception-runtime, or
      Objective-C dependencies.

### Milestone 2: Extend Semantic, Layout, and Render-Core Vocabulary

**Entry conditions:** Relevant Milestone 1 declarations exist; SPEC-006's
generic primitive and exact identity seams remain authoritative.

**Exit evidence:** Canvas payloads and identities reach the drawing attempt,
the additive layout/render cases preserve all existing raw values and behavior,
and backends can consume borrowed stroke views without importing drawing.

- [x] `T2.1` — Extend the semantic result with a Canvas invocation view that
      exposes staged callables only to the drawing-attempt input, indexed by the
      exact SPEC-006 identity. Prove one event, zero children, no body evaluation,
      stable occurrence order, exact lookup bounds, and no public/package
      callable lookup outside this seam.
- [x] `T2.2` — Add exactly `.canvas` to SPEC-007's
      `SemanticLayoutPrimitive` and SPEC-008's `SemanticRenderScope`, preserving
      every existing case, raw value, traversal order, identity relation, and
      non-Canvas result. Add `StraightLineStrokeHeader`,
      `StraightLineStrokeView`, and extending `DrawingOperationSink` to
      `GiftUIRenderCore`.
- [x] `T2.3` — Implement and measure `SubpathRange`, `DrawingPlanSummary`,
      `StraightLineStrokeHeader`, `DrawingProductionError`, and
      `DrawingPlanResult` with exact validation, cases/raw values, index meaning,
      copyability, sendability, and value-size ceilings on every supported
      compiler.
- [x] `T2.4` — Build direct recording semantic/layout/render views for Canvas
      leaf identity, proposal behavior, frame expansion, exact resolved bounds,
      inherited clip, painter position, empty Canvas, and the absence of child,
      hit, text, glyph, clip-source, or ordinary-paint events.
- [x] `T2.5` — Add import, symbol-owner, interface, borrow-lifetime, and source
      audits proving the declared module contract, backend independence from
      `GiftUIDrawing`, and absence of a second identity, semantic graph, or
      Canvas-specific visitor category.

### Milestone 3: Implement Bounded Path Construction and Immutable Plans

**Entry conditions:** Milestones 1-2 supply the exact public and package
contracts; SPEC-002 checked geometry remains the sole arithmetic authority.

**Exit evidence:** Caller-owned bounded storage implements atomic scoped Path
mutation and immutable ordered snapshots with exact counts, lookup behavior,
cleanup, and first-failure semantics.

- [x] `T3.1` — Implement validated `DrawingLimits` and `StaticCanvasLimits`
      with positive fields, `maximumNormalizedStrokeOperations >=
      maximumPlanStrokes`, exact equality admission, and nil for every invalid
      construction. Establish focused finite dynamic/static fixture storage.
- [x] `T3.2` — Implement `DrawingPlanView`, `DrawingPlanWorkspace`, and
      `CanvasInvocationSource` with exact acquisition, active/inaccessible/
      successful/discarded/reset states, total summary accounting, zero-stroke
      Canvas lookup, nil out-of-range behavior, and invariant detection for
      duplicate/missing/inconsistent data.
- [x] `T3.3` — Implement one live scoped Path per context: current-point and
      subpath state, consecutive-move replacement, post-segment move reservation,
      line-without-move rejection, zero-length preservation, atomic equal-limit/
      first-excess mutation, nested-path rejection, and normal/throwing reset.
      Prove live-Path totals survive successful stroke snapshots and reset only
      when the enclosing `withPath` exits.
- [x] `T3.4` — Implement style/path validation and atomic whole-snapshot
      reservation before copy or unique transfer. Preserve complete ordered
      points and explicit subpath ranges, append one no-op record for paths with
      no nonzero segment, and ensure later mutation cannot alter prior strokes.
      Reject nonpositive width as `.invalidValue` and positive width above
      `maximumLineWidth` as `.capacityExhausted` before any snapshot mutation.
- [x] `T3.5` — Implement exact callable, context, live Path, immutable plan, and
      borrowed stroke-view lifetimes. Add poisoned-storage and address-capture
      tests covering normal, throwing, failed, accepted, refused, discarded, and
      reset exits without retaining a borrow or eligible callable.
- [x] `T3.6` — Fault every local state and reservation edge in normative order,
      prove no partial mutation/snapshot/plan exposure, and instrument linear
      construction/snapshot work plus separate live-Path and plan high-water.

### Milestone 4: Derive the Cycle-Local Plan After Layout

**Entry conditions:** Milestone 3; exact SPEC-006 semantic Canvas identities,
SPEC-007 resolved layout view, and SPEC-009 execution context are available for
the integration path.

**Exit evidence:** `CanvasPlanProducer.derive` invokes each occurrence once in
resolved painter order and either exposes one complete translated plan or
performs exact whole-attempt cleanup and dirty recovery.

- [x] `T4.1` — Implement Canvas measurement and placement integration: present
      proposal axes become ideal dimensions, absent axes become zero, ordinary
      cap/frame behavior resolves bounds, and Canvas adds no clip. Correlate the
      same exact identity across semantic occurrence, layout result, and render
      scope.
- [x] `T4.2` — Implement `CanvasPlanProducer.derive` validation for idle
      workspace, `.deriving` phase, active cycle, allowed semantic/candidate
      revisions, exact occurrence totals, unique identity coverage, complete
      resolved layout, painter order, and exact invocation size. Guard every
      detectable attempt by Canvas code to mutate GiftUI-observed state,
      dispatch an action, submit a fact, request a wake, query capability or
      backend identity, or start/reenter a cycle; prove exact `.invalidPhase`
      versus `.reentrancyViolation` results and no later client invocation.
- [x] `T4.3` — Invoke every callable at most once, release it exactly once after
      normal or throwing return, and remove all publication-eligible callable/
      capture storage after the last occurrence. Exercise zero-Canvas and
      zero-stroke Canvas attempts.
- [x] `T4.4` — Checked-add each Canvas surface origin to every local point,
      preserve the origin as metadata without double translation, carry only
      the inherited clip, validate normalized stroke totals, and expose a plan
      only after every occurrence succeeds.
- [x] `T4.5` — Integrate drawing failure with SPEC-009 pre-publication effects:
      discard/reset once, preserve admitted mutations, publish no semantic or
      candidate revision, mark semantics dirty, and coalesce one wake. Prove
      refusal recovery retains only presentation intent and obtains new Canvas
      callables by root re-expansion and layout, not replay.

### Milestone 5: Implement Combined Render Preflight and Streaming

**Entry conditions:** A successful immutable drawing plan exists; SPEC-008's
semantic/layout/text views, render limits, traversal workspace, and ordinary
producer semantics are implemented.

**Exit evidence:** One reused traversal preflights and streams exact ordinary
and stroke operations in painter order with atomic headers, capacity checks,
and synchronous borrowed consumption.

- [x] `T5.1` — Implement `CanvasRenderProducer.preflight` by extending the
      existing SPEC-008 traversal with `.canvas`. Validate the immutable plan,
      translated geometry, exact header totals, combined checked operation
      count, configured sink lower bound, and all consistency invariants without
      observing an endpoint sink or retaining a borrow. Acquire and reset the
      caller-owned render workspace entirely within the call and expose no
      partial header on failure.
- [x] `T5.2` — Implement `CanvasRenderProducer.produce` as the same traversal inside one
      offer. First move T5.1's external successful-preflight summary comparison
      into the new preflight-extension completion requirement and make the
      ordinary empty extension complete successfully. Require exact
      expected-header and actual-capacity checks, then use
      the post-traversal preflight completion call to require complete
      plan-summary equality before `begin`. Emit each snapshot as one borrowed
      `straightLineStroke` event at its painter position and use streaming
      completion to require the same summary equality before `finish`.
- [x] `T5.3` — Extend the canonical recording transcript and verification with
      exact color, width, cap, join, origin, clip, points, subpaths, no-op strokes,
      header totals, mixed fill/glyph/stroke ordering, and one begin/finish pair.
      Prove zero-Canvas ordinary transcripts equal SPEC-008 exactly.
- [x] `T5.4` — Exercise idle refusal, actual-capacity disagreement, post-begin
      stroke refusal, header drift, plan corruption, and accepted completion.
      Apply `.sinkRefused` only where specified, otherwise
      `.invariantViolation`, and call discard exactly once where required.
- [x] `T5.5` — Audit that combined production reuses rather than forks
      SPEC-008 fill/glyph/style/clip/damage/text-resource logic, retains no
      complete operation list or borrowed payload, is the sole production entry
      point for Canvas-admitting configurations, and keeps every backend free of
      `GiftUIDrawing` imports.

### Milestone 6: Implement Static Canvas Generation and Profile Storage

**Entry conditions:** Exact public callable and plan interfaces are stable;
SPIKE-007/008 remain evidence only. Production integration additionally waits
for SPEC-013 and SPEC-015 owners.

**Exit evidence:** Static Canvas expressions lower to complete nonzero IDs and
bounded inline capture records, while dynamic and static fixture profiles
produce identical drawing meaning and cleanup without static heap allocation.

- [x] `T6.1` — Define the source-generation input and checked manifest for each
      syntactic Canvas expression, stable nonzero `UInt16` callable IDs,
      occurrence-to-expression mapping, exact captured fields, and complete
      generated switch coverage. Repeated runtime occurrences reuse the ID but
      own distinct capture records.
- [x] `T6.2` — Implement generated `StaticCanvasCallableTable` conformance and
      capture union dispatch with exact two-`inout`, `Size`, typed
      `throws(DrawingError)`, order, and normal/throwing destruction semantics;
      union size is the greatest case rather than the sum.
- [x] `T6.3` — Reject zero/excess IDs, incomplete or duplicate coverage,
      unsupported capture types, over-limit captures, dynamic collections,
      existentials, heap-owned/weak/unowned boxes, and ordinary class references
      at build time. Prove generation has no retained-closure fallback.
- [x] `T6.4` — Implement independent static-limit and production host-handle
      validation. Admit an observable model location only through its approved
      address-stable static handle with no retain/release and an explicit host
      lifetime proof.
- [x] `T6.5` — Implement the bounded profile-owned dynamic closure wrapper and
      compare fixture dynamic and static semantic, invocation, plan, failure,
      cleanup, and combined-render transcripts. Prove the wrapper is released
      immediately after invocation and no later than cycle finalization.
      Instrument static heap, forbidden `Any`, reflection, concurrency,
      exception/runtime symbols, hidden complete-frame buffers, capture bytes,
      linked RAM/flash, and ABI attributes; do not infer production costs from
      Spike evidence.

### Milestone 7: Integrate Startup Gates, Failures, and Cycle Disposition

**Entry conditions:** Milestones 3-6 supply complete focused behavior;
SPEC-004 and SPEC-015 supply production capability and host validation seams.

**Exit evidence:** Structural B2 and semantic capability gates are independent,
the exact Signal Analyzer workload is admitted, and every local error maps to
the exact SPEC-003 fact and SPEC-009 lifecycle effect.

- [x] `T7.1` — Implement B2 comparison for every declared Canvas workload fact,
      workspace capacity, combined ordinary-plus-stroke operation bound,
      configured sink lower bound, and static callable/capture bound. Test
      missing, zero, overflow, below, equal, and first-excess facts independently,
      and prove startup validation invokes no client body or Canvas callable.
- [x] `T7.2` — Integrate the separate SPEC-004 `rasterPresentation` gate for
      canonical straight-line operation coverage and required extent, clip,
      encoding, derived payload, in-flight storage, lifetime, and host policy.
      Prove neither gate repairs the other and no drawing capacity field enters
      the closed capability snapshot.
- [x] `T7.3` — Implement the narrow drawing owner adapter and exact precedence/
      mapping table for every `DrawingError`, `DrawingProductionError`, idle sink
      refusal, and invariant. Preserve origin, scope, containment, first visible
      failure, and the rule that no later check invokes client code.
- [x] `T7.4` — Integrate focused drawing results with publication, candidate
      allocation, one-shot offer, refusal, dirty rederivation, and finalization.
      Verify pre-publication versus post-publication dispositions and that no
      accepted, refused, or failed attempt retains plan/callable state.

### Milestone 8: Prove Canonical Raster Meaning Through Backend Integration

**Entry conditions:** Milestone 5 freezes normalized strokes and combined
ordering; SPEC-014 supplies the concrete full-surface RGBA8888 and bounded tiled
RGB565 consumers and their workspace contracts.

**Exit evidence:** Both consumers produce identical canonical binary coverage
and exact encoding for the complete normative vector corpus without changing
portable or normalized stroke meaning.

- [x] `T8.1` — Freeze shared normalized stroke and golden-mask vectors for all
      required horizontal, vertical, diagonal, single-point, repeated-point,
      zero-length, acute/obtuse/right-angle, same-direction, reversal,
      miter-limit fallback, odd/even width, butt/round cap, miter/round join,
      negative/outside-Canvas, every clip edge, empty clip, overlap/painter-order,
      and RGB boundary values `0`, `1`, `127`, `128`, `254`, and `255`. Record
      zero pixel/channel tolerance.
- [x] `T8.2` — Build an independent exact-rational or sufficiently widened-
      integer oracle for closed segment regions, butt/round caps, round/miter/
      bevel joins, ten-times-half-width miter limit, zero-tangent rules, pixel-
      center inclusion, inherited half-open clipping, and exact replacement.
- [x] `T8.3` — Run the complete corpus through SPEC-014's RGBA8888 full-surface
      and RGB565 bounded tiled consumers. Compare masks and exact RGBA/RGB565
      bytes, including round-to-nearest conversion and big-endian RGB565 order.
- [x] `T8.4` — Inject admitted-bound arithmetic extremes, raster workspace
      equality/first-excess, and borrowed-consumption poison cases. Classify an
      admitted-style or representability failure as invariant/configuration
      failure; permit no saturation, tolerance, native-style fallback, or hidden
      complete-frame buffer.

### Milestone 9: Complete Cross-Profile Evidence and Prepare Conformance

**Entry conditions:** All applicable implementation, integration, corpus, and
host tasks are complete; no required criterion remains delegated without
stable evidence.

**Exit evidence:** All four exact profile commands, repository gates, normalized
comparisons, resource reports, and a complete criterion disposition are ready
for independent conformance review.

- [ ] `T9.1` — Run unit, public/negative compile, package graph, import, symbol,
      portable-source, generated-source, and interface audits. Prove every
      normative declaration, additive vocabulary case, module owner, and
      forbidden dependency rule.
- [ ] `T9.2` — Run the complete semantic/layout/invocation/path/plan/cycle/
      combined-render/startup/failure corpus for every applicable profile and
      compare normalized results, identities, counts, order, and first failure.
- [ ] `T9.3` — Measure closure/capture, construction, snapshot, lowering,
      operation, raster, point/stroke, plan, derived storage, peak simultaneous
      workspace, stack, heap, and timing separately. Report generated capture
      storage, live Path storage, sealed plan storage, combined render workspace,
      backend raster workspace, and post-acceptance derived storage as distinct
      values rather than only a sum. Verify all normative value ceilings on each
      pinned compiler and each configured workspace byte bound.
- [ ] `T9.4` — Inspect ARMv6 and nRF target images/ELFs for ABI, hard-float where
      required, allocation, forbidden runtime/symbol dependencies, RAM, flash,
      sections, and linked-size deltas. Keep hardware-free evidence distinct
      from connected-target claims.
- [ ] `T9.5` — Run `scripts/format-swift.sh`, the focused SPEC-012 driver, each
      exact profile command, the fast repository gate, and the all-hardware-free
      gate. Preserve immutable report identity and register every driver
      explicitly.
- [ ] `T9.6` — Update task dispositions and create
      `docs/conformance/spec-012-conformance.md` from the canonical template,
      mapping every DR criterion to stable evidence and recording deviations,
      exceptions, platform limits, and absent connected-hardware evidence.
      Request independent conformance review; do not mark SPEC-012 implemented.

## Design-Note Triggers

- Create `docs/implementation-designs/spec-012-scoped-path-plan-storage.md` if
  the production noncopyable Path, snapshot transfer, plan packing, or
  acquire/discard/reset realization is not locally reconstructable. The note
  may explain replaceable storage and poison-test seams but cannot change
  scoped ownership, atomic reservation, snapshot, lifetime, or capacity rules.
- Create `docs/implementation-designs/spec-012-static-canvas-lowering.md` when
  production source generation begins. Record syntactic ID assignment, capture
  union layout, supported-capture validation, dispatch, destruction, and audit
  seams without widening the approved capture set or making generator output
  authoritative beyond the Specification.
- Create a focused combined-traversal note only if extending SPEC-008 without
  forking its implementation requires non-obvious workspace or iterator state.
  A note cannot authorize a retained operation list or a second traversal
  meaning.
- Rasterizer internals belong to SPEC-014 design notes. This plan records
  SPEC-012's observable vectors and integration evidence but does not select a
  backend algorithm, tile shape, or derived-storage layout.

## Integration and Validation Order

1. Freeze the fail-closed corpus, target graph, migration inventory, and
   registered driver before recording implementation claims.
2. Land public declarations and Render-Core borrowed values, then prove source
   ownership and compiler behavior independently of production profiles.
3. Implement scoped Path, immutable plan, and direct recording fixtures before
   connecting semantic identities, resolved layout, or runtime phases.
4. Integrate post-layout derivation only after SPEC-007 supplies exact bounds;
   integrate combined rendering only after SPEC-008 supplies its complete
   ordinary traversal and workspace.
5. Add static generation and host validation through SPEC-013/015 seams, then
   connect exact failure/disposition behavior to SPEC-003/009.
6. Freeze normalized stroke vectors before running them through SPEC-014's two
   raster consumers; compare logical masks before encoded bytes.
7. Run focused host tests first, then macOS static, Raspberry Pi ARMv6, and
   hardware-free nRF52840 compile/link/inspection. Run cross-profile comparison
   and conformance preparation only after all required reports exist.

The hardware-free nRF gate proves compilation, linking, ABI, symbols, and
resource properties only. Connected Raspberry Pi display evidence or nRF board
operation belongs to separately authorized downstream conformance work and is
not implied by this plan.

## Risks and Upstream Blockers

### Implementation risks

- Swift ownership or exclusivity can regress around the approved two-`inout`
  `withPath` shape. Keep the SPIKE-008 negative corpus as a compiler sentinel
  and route any required source-contract change upstream.
- Atomic snapshot reservation across points, subpaths, and records can leave
  partial mutable state on late failure. Test storage before/after every
  equality and first-excess site and keep reset/discard idempotence explicit.
- Extending SPEC-008's traversal can accidentally produce header drift or
  duplicate ordinary semantics. Compare zero-Canvas output byte-for-byte and
  make preflight/produce share replaceable mechanics while retaining their
  distinct calls.
- Exact cap/join coverage at large checked coordinates is arithmetic-heavy.
  The backend must use sufficient widened or exact arithmetic and report
  invariant/configuration failure rather than saturating or changing style.
- Generated generic callables, capture unions, plan storage, and raster helpers
  may inflate nRF stack or flash even at zero heap. Measure each contribution
  separately before selecting replaceable representations.
- Concurrent SPEC-007/008/009 work shares package and semantic/render seams.
  Preserve user changes and coordinate exact owners rather than adding
  compatibility layers or parallel paths.

### Upstream blockers

- Production semantic-to-layout Canvas integration waits for SPEC-006's
  complete Canvas-capable semantic result and SPEC-007's exact identity-
  preserving resolved bounds. Direct Canvas declarations, Render-Core values,
  workspace logic, and fixture views do not wait.
- SPEC-008's complete `GiftUIRenderLowering`, traversal workspace,
  text/layout view, and atomic producer are present. T5 must implement the
  amended extension overloads in that owner and may not create a substitute.
- T5.2 exposed that the previously approved extended `RenderProducer.produce`
  has no completion operation between its preflight traversal and
  `sink.begin`. The proposed focused SPEC-012 amendment adds exact completion
  results to both extension protocols, requires preflight completion before
  `begin` and streaming completion before `finish`, and prohibits either
  completion from traversing or owning producer state. The focused
  [pre-begin summary review](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-5/combined-render-prebegin-summary-blocker.md)
  records the defect and required correction. The maintainer explicitly
  approved the amendment on 2026-09-12, so T5.2-T5.5 may resume.
- Production dynamic/static callable storage and source-generation integration
  wait for SPEC-013. Production workload limits, observable static handles,
  startup B2 assembly, and host lifetime proofs wait for SPEC-015.
- Full-surface RGBA8888 and tiled RGB565 implementation evidence waits for
  SPEC-014. SPEC-012 may freeze vectors and an independent oracle but must not
  move raster ownership into `GiftUIDrawing` or a portable module.
- Complete Signal Analyzer workload evidence consumes exact SPEC-001/015
  counts and host configuration. SPIKE-004's 820-segment fixture is independent
  feasibility evidence and cannot substitute for production capacity.
- Any inability to preserve one invocation, pre-publication completion,
  exact identity, no retained borrow, one operation per stroke, inherited-only
  clipping, canonical raster meaning, conjunctive startup gates, or zero static
  heap is an upstream Specification/architecture blocker, not a plan tradeoff.

## Deferred and Follow-up Work

SPIKE-004, SPIKE-007, and SPIKE-008 remain linked evidence only. They do not
authorize a production storage layout, generated representation, capacity, or
cost claim.

Fills, curves, closed paths, images, Canvas text, transforms, client clips,
alpha, gradients, effects, animation, retained/replayable paths or plans,
asynchronous drawing, floating-point geometry, and richer capability fields
remain outside the accepted MVP scope. No new deferred item was discovered
while preparing this plan. A required correctness, capacity, profile,
backend, or acceptance-evidence obligation from SPEC-012 cannot be deferred.

## Completion Record

Plan audited and marked ready on 2026-09-09 after the approved authority chain,
current repository seams, thirteen acceptance criteria, exact normative
subcontracts, downstream ownership, and four-profile evidence strategy were
reviewed. The audit made invocation guards, live-Path accounting, preflight
cleanup, sole-producer ownership, profile closure storage, forbidden-runtime
checks, raster vectors, and separate resource evidence explicit. No
implementation task was completed by creating this plan.

Update task checkboxes and dispositions only with stable code, test, and report
evidence. Plan completion will mean every task has a recorded disposition; it
will not mean SPEC-012 conforms or is `implemented`. The conformance report
remains `null` until `T9.6` creates it.

`T0.1` is complete. The
[SPEC-012 contract fixture registry](../../Tests/ContractFixtures/SPEC012/README.md)
now freezes the ordered drawing and raster manifests, positive and negative
declaration witnesses, normalized cross-layer fields, symbolic identity
tokens, failure precedence, all thirteen fail-closed evidence rows, and the
distinction between host, cross-build, inspection, simulator, and separately
authorized connected-hardware evidence. The manifests intentionally contain
no behavioral cases yet, and no acceptance criterion is marked passing by
this schema-only task. `T0.2` is the next dependency-complete task.

`T0.2` is complete. `GiftUIDrawing`, its focused test target, and the narrow
`GiftUIDrawingFailureAdapterFixture` now exist with the exact approved direct
dependency edges. `GiftUIRenderCore` owns the first compiling borrowed stroke
view and extending sink contracts, while the SPEC-002 target allow-list and
SPEC-007/008 boundary checks admit only the approved drawing producer join.
The full 388-test host suite and focused graph/coexistence checks pass. The
public style enum and Render-Core declarations are prerequisites only; their
behavioral and profile evidence remains assigned to T1.3 and T2.2-T2.3, so no
DR row advances. `T0.3` is the next dependency-complete task.

`T0.3` is complete. The executable
[`run-spec-012.sh`](../../scripts/contracts/run-spec-012.sh) is explicitly
registered for all four profiles and records the pinned compiler, SDK/target,
optimization, repository revision, complete input digest inventory, exact
commands, safety claims, and report identity. Its schema checker rejects drift
in the manifests, declaration registries, normalized fields, failure order,
module boundary rows, or criterion set. A macOS dynamic rehearsal published
an immutable report with all thirteen DR rows `missing`, as required before
their owning tasks land; the driver performs no remote access, deployment,
restart, simulation, connected-target execution, or flashing. `T0.4` is the
next dependency-complete task.

`T0.4` is complete. The checked
[migration inventory](../../Tests/ContractFixtures/SPEC012/migration-inventory.tsv)
classifies 48 PoC, SPIKE-004/007/008, current maintained, and downstream-owned
drawing surfaces as evidence, extend, maintain, replace, retire, reject, or
downstream-owned. Its registered audit verifies every historical PoC path
against the immutable `PoC` tag, every tracked evidence path against the tree,
the absence of then-premature SPEC-013/014 targets, rejection of retained
`DisplayList`/`RGB565RetainedRenderer` paths, and absence of wholesale Spike
source adoption. The updated macOS dynamic report passes while all DR rows
remain fail-closed. Milestone 0 is complete; `T1.1` is the next
dependency-complete task.

The migration inventory was revisited after SPEC-013 landed. Its dynamic and
static profile-storage rows now identify the maintained concrete callable and
occurrence owners; the still-unlanded SPEC-014 backend directories remain
fail-closed downstream rows. This traceability update changes no SPEC-012
contract or acceptance status.

`T1.5` is complete. The registered declaration checker now passes all seven
positive and nine negative witnesses with the pinned optimized compilers for
macOS dynamic, macOS static, Raspberry Pi ARMv6, and nRF52840 Embedded Swift.
It records emitted interfaces, client SIL, undefined symbols, exact commands,
and configuration-equivalent baselines. Interfaces preserve concrete typed
throws, noncopyability, construction visibility, and the exact public types;
dynamic profiles retain the private Canvas closure while static profiles store
no closure pending generated T6/SPEC-013 lowering. Baseline-differenced audits
reject drawing-introduced `any Error`, allocator, reflection, task,
Objective-C, and exception-runtime artifacts without mistaking Embedded
Swift's own linked support definitions for drawing dependencies. The driver
now records this evidence per profile, and all compile-registry rows are
`complete`; DR rows remain fail-closed because their later semantic,
lifecycle, and production obligations are not yet satisfied. Milestone 1 is
complete; T2.1 is the next dependency-complete task.

`T2.1` is complete. `Canvas` now owns the exact non-returning package invocation
bridge, while a focused dynamic profile semantic-result adapter copies each
concrete payload under its existing SPEC-006 identity and alone calls that
bridge through `CanvasInvocationSource`. Tests prove deferred invocation,
exact-size forwarding, release invalidation, stable occurrence order, bounded
lookup, zero children, no root-body evaluation, and atomic discard on staging
refusal. Source and package-interface audits reject any additional bridge
client or closure-returning lookup, and all four profile compilers accept the
bridge while preserving profile-specific closure storage. The
[callable staging evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-2/canvas-invocation-adapter.md)
records the commands and observations. T3.2 is the next dependency-complete
task.

`T2.2` is complete. The existing closed semantic layout and render scope
vocabularies now add only `.canvas`; generic payload mapping recognizes the
public Canvas type while unknown and every pre-existing payload retain their
prior mappings. Exhaustive layout and ordinary-render consumers treat Canvas
as the specified zero-child, no-ordinary-paint leaf without changing other
traversal order or identity behavior. `GiftUIRenderCore` retains the focused
borrowed `StraightLineStrokeHeader`, `StraightLineStrokeView`, and extending
`DrawingOperationSink` declarations established at T0.2, so backends can
consume the normalized contract without importing `GiftUIDrawing`.

`T2.3` is complete. `DrawingPlanSummary`, the exact nine-case/raw-value
`DrawingProductionError`, and `DrawingPlanResult` now join the T2.2 Render-Core
values. Focused tests cover fields, equality, cases, half-open subpath
validation, copyability, and sendability. Optimized compiler-derived IR across
macOS dynamic/static, Raspberry Pi ARMv6, and nRF52840 Embedded Swift reports
the same layouts: 4-byte `SubpathRange`, 10-byte `DrawingPlanSummary`, 40-byte
`StraightLineStrokeHeader`, 1-byte error, and 11-byte result with 12-byte
stride. The registered
[layout evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-2/drawing-value-layouts.md)
records the commands and bounds.

`T2.4` is complete for the direct, non-callable integration that was permitted
before the T2.1 Specification correction. Focused semantic expansion records
one Canvas leaf at one identity without body evaluation or drawing invocation.
Layout fixtures prove
present-proposal/absent-axis sizing, ordinary fixed-frame expansion, exact
bounds, inherited clips, and no text/glyph output. A direct render fixture
places Canvas between a background fill and text glyph group yet emits no
ordinary operation or child of its own. The
[direct-view evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-2/direct-canvas-views.md)
records the covered observations and explicitly excludes the callable staging
seam now assigned to unblocked T2.1.

`T2.5` is complete. The registered module-contract audit checks SPEC-002's
exact target graph against source imports, sole declaration ownership,
Render-Core/backend independence from `GiftUIDrawing`, the absence of a
Canvas-specific visitor or second identity/semantic graph, and the exact
borrowed stroke operation in emitted package interfaces. All four profile
compilers pass the interface audit through the value-profile checker. The
[module evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-2/module-contract-audit.md)
records the audited seams. Milestone 2's independent work is complete; T2.1
is now unblocked and is the next production callable-integration task.

`T3.1` is complete. Both exact limit types reject every zero/nonpositive field,
`DrawingLimits` rejects normalized-operation capacity below plan-stroke
capacity while admitting equality, and focused dynamic plus inline static
fixture storage proves exact-capacity success and first-excess refusal without
mutation. All four optimized compilers report a 20-byte `DrawingLimits` and
exactly 4-byte `StaticCanvasLimits`. The
[limit evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-3/drawing-limits-and-fixture-storage.md)
records the boundary and profile results.

`T3.2` is complete. `GiftUIDrawing` now owns the exact `DrawingPlanView` and
`DrawingPlanWorkspace` contracts alongside the T2.1 `CanvasInvocationSource`.
The approved package initializers for `DrawingPlanSummary` and
`StraightLineStrokeHeader` copy every field without normalization. A focused
finite workspace fixture proves idle/active/sealed/discarded/reset lifecycle,
acquisition refusal without mutation, total summary accounting, zero-stroke
Canvas lookup, all half-open lookup bounds, post-discard inaccessibility, and
fail-closed duplicate, missing, header/range, and summary inconsistencies. The
[workspace evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-3/drawing-plan-workspace.md)
records the contract and package-interface checks. T3.3 is the next
dependency-complete task.

`T1.1` is complete. `GiftUI.Canvas` now has the exact typed-throws initializer,
private retained draw callable, `Body == Never` invariant body, primitive
marker conformance, and one-call traversal override. The focused declaration
test proves traversal records exactly one primitive while evaluating no body
and invoking no drawing. The linked draft scoped-storage design records the
replaceable ownership and lifecycle direction needed by T1.2 and T3 without
widening the approved API. Minimal exact `GraphicsContext` and `DrawingError`
type declarations exist only because the Canvas signature requires them;
their operations and behavioral obligations remain incomplete under T1.2 and
T1.3. The 388-test host suite, exact GiftUI source inventory, migration audit,
and macOS dynamic SPEC-012 driver pass; all DR rows remain fail-closed. `T1.2`
is the next dependency-complete task.

`T1.2` is complete. `GraphicsContext` and `Path` are noncopyable and have no
public initializer; their exact two-`inout`, nonescaping, typed-throws
`withPath`, `move`, `addLine`, and two borrowed-Path `stroke` declarations now
forward into caller-owned storage through a package-only, noncapturing,
C-compatible primitive-status operation table. Normal and throwing bodies
invalidate and end the Path scope exactly once, with the body error retaining
precedence over cleanup failure. Focused tests exercise operation forwarding,
typed results, and both cleanup paths. The first candidate used throwing
`@convention(thin)` references, but the pinned host compiler rejected those as
an unimplemented nontrivial thin reference; the linked draft design records
the supported replacement and leaves four-profile symbol/resource proof to
T1.5. `Shading` and `StrokeStyle` declarations were required to compile the
exact stroke signatures, but their T1.3 behavior and evidence remain
unclaimed. `T1.3` is the next dependency-complete task.

`T1.3` is complete. `Shading.color` stores the exact opaque RGB value;
`StrokeStyle` preserves its exact fields and `.butt`/`.miter` defaults; the
cap and join enums retain their required `UInt8` cases; and `DrawingError`
contains the exact eight equatable, sendable cases. The line-width stroke
overload delegates through `StrokeStyle(lineWidth:)`, while the style overload
rejects zero and negative widths as `.invalidValue` before the caller-owned
storage operation can observe a snapshot request. Focused tests cover RGB,
defaults, explicit invalid markers, enum raw values, error shape, overload
equivalence, and nonpositive-width suppression. Cross-profile interface and
resource proof remains assigned to T1.5; T1.4 is the next dependency-complete
task.

`T3.3` is complete. A profile-neutral `LivePathBuilder` now applies the exact
current-point and explicit-subpath state machine over caller-owned bounded
storage. Dynamic and fixed-capacity fixtures produce identical transcripts for
consecutive-move replacement, post-segment subpath creation, preserved
zero-length segments, equal-limit success, and reset. Focused failure tests
prove line-without-move and independent point/subpath first-excess rejection
leave storage unchanged. The public scoped facade additionally proves nested
`withPath` rejection and live-total reset on normal and throwing exits, while
an earlier snapshot remains unchanged across later mutation. The
[path construction evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-3/live-path-construction.md)
records the covered states. T3.4 is the next dependency-complete task.

`T3.4` is complete. `StrokeSnapshotProducer` validates width and complete
gap-free Path structure, computes every stroke/point/subpath/normalized-
operation reservation with checked `UInt16` arithmetic, compares all limits,
and only then makes one atomic storage append. Focused fixtures prove exact
style/header preservation, empty and one-point canonical no-op records,
multiple subpaths, painter order, equal-limit success, nonpositive and
over-limit width precedence, whole-reservation failure without mutation, and
immutable earlier snapshots after later Path mutation. The
[snapshot evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-3/stroke-snapshots.md)
records the behavior and profile compilation. T3.5 is the next
dependency-complete task.

`T3.5` is complete. Reset now poisons the live Path builder before storage can
be reused, and the existing noncopyable/nonescaping declaration corpus rejects
Path construction, copy, consume, synchronous escape, asynchronous escape,
and overlapping outer-context access. Focused lifecycle probes cover normal
and throwing Canvas returns followed by release, active Path normal/throwing
exit, successful plan publication followed by discard/reset, failed snapshot
reservation without retention, and accepted/refused borrowed stroke calls that
retain only copied derived values. The
[lifetime evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-3/drawing-lifetimes.md)
records the poison and ownership checks. T3.6 is the next dependency-complete
task.

`T3.6` is complete. The combined T3 fault corpus now covers inactive and
reentrant scope, missing current point, malformed current ranges, all four
post-validation storage refusals, live arithmetic and independent-capacity
edges, invalid/over-limit style, malformed snapshot input, inconsistent
normalized state, checked plan arithmetic, each whole-plan capacity, and final
append refusal. Every failure preserves the former logical storage and the
precedence probe confirms invalid width prevents later Path or plan access.
Instrumented 1/2/4/8-point snapshots perform exactly two point lookups per
point and two subpath lookups for the one admitted subpath, while reporting
live and immutable-plan high-water separately. The
[fault/work evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-3/drawing-faults-and-work.md)
records the matrix. Milestone 3 is complete; T4.1 is next.

`T4.1` is complete. The production layout engine's additive `.canvas` branch
uses the existing semantic identity without creating a child or Canvas-only
identity relation. The established direct-view corpus proves present proposal
axes, zero absent axes, ordinary cap and fixed-frame expansion, exact resolved
bounds and inherited clip, and no text/glyph/clip-source output. T2.1 now
supplies the same identity-keyed staged payload through the drawing-attempt
seam, while the semantic render projection maps `.canvas` back to that exact
layout identity. The
[integration evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-4/canvas-layout-integration.md)
records the correlated path. T4.2 is next.

`T4.2` was blocked by the original workspace signature. The approved
2026-09-12 amendment adds `DrawingPlanConstructionWorkspace`, whose scoped
context body and sealing operation expose exactly the missing mutation path
without revealing concrete storage or changing profile ownership. The focused
[workspace integration review](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-4/canvas-plan-producer-workspace-seam-blocker.md)
records the former defect and its resolution. T4.2-T4.5 remain unchecked
implementation work and may now resume through the amended public seam.

`T5.1` was independently blocked by the absence of a reusable lowering hook.
The approved 2026-09-12 amendment adds paired preflight/streaming extension
visitors and extended `RenderProducer` overloads. They reuse the existing
ordinary traversal, workspace, capacity checks, snapshots, and single sink
transaction while exposing the Canvas position exactly once per traversal.
The focused
[render extension review](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-5/combined-render-extension-seam-blocker.md)
records the former defect and its resolution. T5.1-T5.5 could then resume
through the amended SPI.

`T1.4` is complete. Seven maintained positive fixtures compile Canvas/style
defaults, both stroke overloads, explicit typed trailing closures,
stroke-mutate-stroke Path reuse, multiple subpaths, and concrete
`DrawingError` propagation. Nine maintained negative fixtures reject public
context/Path construction, explicit Path copying, borrowed consumption,
Path return and asynchronous escape, missing or wrong typed errors, and
captured outer-context access. Each rejection has a required diagnostic
fragment. The reproducible macOS checker builds the maintained module and
verifies all sixteen cases under optimized whole-module settings; ownership
and exclusivity cases that require body visibility deliberately use the same
whole-module mode as SPIKE-008, while the remaining cases compile against the
emitted module. Registry status stays `pending` until T1.5 records all four
profile compilers and emitted-artifact audits. `T1.5` is the next
dependency-complete task.

`T6.1` is complete. The ordered
[static Canvas input](../../Tests/ContractFixtures/SPEC012/static-canvas-input.yaml)
and [checked manifest](../../Tests/ContractFixtures/SPEC012/static-canvas-manifest.yaml)
freeze dense nonzero callable IDs, exact capture fields and layouts, complete
switch coverage, and distinct capture ownership for repeated occurrences. The
[design note](../implementation-designs/spec-012-static-canvas-lowering.md)
records the replaceable lowering and lifecycle realization, while the
[manifest evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-6/static-canvas-generator-manifest.md)
keeps generated Swift, production limits, and runtime storage explicitly
pending. T6.2 is the next dependency-complete static-generation task.

`T6.2` was blocked because the pinned Apple Swift 6.3.3 compiler rejects the
original `associatedtype CaptureStorage: ~Copyable` requirement. The approved
2026-09-12 amendment uses an implicitly `Copyable` associated type and
normatively prohibits dispatch-time copying or retention while preserving
fixed inline storage and immediate logical invalidation. The
[callable-table review](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-6/static-canvas-callable-table-specification-blocker.md)
records the former compiler defect and its resolution. T6.2-T6.3 may now
resume; production portions of T6.4-T6.5 retain their SPEC-015/SPEC-013 gates.

`T4.2` is complete through the amended construction-workspace seam.
`CanvasPlanProducer` validates workspace/phase/cycle/candidate state, bounded
occurrence count, dense unique identity coverage, complete layout lookup, and
strict painter order before invoking client code. It passes exact size,
surface origin, and inherited clip to the scoped workspace and preserves the
first `.invalidPhase` or `.reentrancyViolation` client guard failure without
invoking a later occurrence. The
[producer validation evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-4/canvas-plan-producer-validation.md)
records the full focused matrix. T4.3 is next.

`T4.3` is complete. Normal, first-failure, and later-failure fixtures prove
each callable is invoked at most once and released exactly once; failure
releases the uninvoked suffix without calling it, leaving no staged callable
eligible for publication. Empty attempts seal without entering a context, and
one zero-stroke Canvas contributes exactly one occurrence with zero remaining
plan totals. The
[callable lifetime evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-4/canvas-callable-lifetime.md)
records release counts and cleanup. T4.4 is next.

`T4.4` is complete. The construction workspace binds the scoped Path and
snapshot engines to the exact Canvas origin and inherited clip, validates
every checked coordinate addition before commit, stores translated points,
retains origin only as metadata, and seals only when normalized-operation and
stroke totals agree. Focused fixtures distinguish one translation from zero or
two and prove overflow discards the whole plan without exposure. The
[translation evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-4/canvas-plan-translation.md)
records exact values and totals. T4.5 is next.

`T4.5` is complete at the focused owner seam. A drawing failure now composes
with SPEC-009 recovery while preserving admitted-effect count and the prior
semantic revision, publishing no candidate/frame, marking semantics dirty,
and requesting one later wake. Retryable refusal finalizes the former plan,
retains only bounded presentation intent, and rederives through a fresh source
and workspace under a new cycle. The
[cycle recovery evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-4/drawing-cycle-recovery.md)
records both paths. Production coordinator integration remains T7.4 through
SPEC-013. Milestone 4 is complete; T5.1 is next.

`T5.1` is complete. `GiftUIRenderLowering` now routes both ordinary-only and
extended preflight through one traversal and invokes the extension once per
semantic scope after the local operation and before children. The extended
entry point owns acquire/reset and checked combined/configured-capacity
validation without a sink. `CanvasRenderProducer.preflight` validates every
Canvas identity, header, origin, inherited clip, point and gap-free subpath
range, exact out-of-range behavior, aggregate summary, and normalized stroke
count through that visitor. Focused fixtures cover the exact combined header,
reentry/reset lifecycle, capacity equality/first-excess, and fourteen plan
disagreements. The
[combined preflight evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-5/combined-render-preflight.md)
and [combined traversal design](../implementation-designs/spec-012-combined-render-traversal.md)
record the reusable mechanism. T5.2 is next.

`T5.2` exposed a contract defect at the amended render-extension boundary. The
preflight visitor can accumulate complete Canvas plan totals, but the extended
`RenderProducer.produce` begins and streams the sink before returning control
to `CanvasRenderProducer`; neither extension protocol exposes a post-traversal,
pre-`begin` completion result. Per-scope preorder visits cannot detect a
missing final Canvas or final point/subpath summary disagreement, and the
combined render header contains only operation and glyph counts. An independent
Canvas semantic recursion, an early extra preflight, or an unapproved protocol
requirement would violate the approved contract. The
[pre-begin summary blocker](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-5/combined-render-prebegin-summary-blocker.md)
preserves the exact proof. The proposed focused amendment now adds one exact
completion result to each extension protocol, with preflight completion before
`begin` and streaming completion before `finish`. The maintainer explicitly
approved the correction on 2026-09-12; T5.2-T5.5 may resume, and completed T6.2
evidence remains valid.

`T5.2` is complete under the approved completion-seam amendment.
`RenderProducer` now provides the additive combined production overload using
its existing preflight and streaming traversals, one workspace lifecycle, and
one sink transaction. It validates the exact header and actual capacity before
preflight completion and `begin`, tracks equal extension-operation totals, and
requires streaming completion before `finish`. The ordinary entry point uses
empty successful extensions and remains source- and transcript-compatible.
`CanvasRenderProducer.produce` validates the immutable plan in both passes and
streams each snapshot as one synchronous borrowed stroke. Focused tests prove
the exact combined transaction and pre-`begin` final-summary rejection. The
[combined production evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-5/combined-render-production.md)
records the boundary. T5.3 is next.

`T5.3` is complete. The canonical combined fixture and typed recording test
now cover exact fill, nonempty and no-op stroke, and positioned-glyph painter
order; both admitted stroke styles, RGB values, origin, inherited clip,
translated points, and explicit subpaths; one begin/finish transaction; and
exact header and sink-call totals. A second case proves a zero-Canvas drawing
plan produces the same result and transcript as ordinary SPEC-008 rendering.
The fail-closed fixture harness validates both cases and keeps raster vectors
empty until their owning milestone. The
[combined transcript evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-5/combined-render-transcript.md)
records the corpus. T5.4 is next.

`T5.4` is complete. Focused offer-time fault injection now distinguishes the
sole `.sinkRefused` row (idle `begin` refusal) from exact
`.invariantViolation` results for actual-capacity disagreement, expected-header
drift, post-begin stroke refusal, and streaming-completion plan corruption.
Pre-begin failures make no lifecycle call, idle refusal makes no discard, and
each post-begin failure discards exactly once before the workspace resets. The
accepted control still finishes without discard. The
[combined offer-failure evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-5/combined-render-offer-failures.md)
records the matrix. T5.5 is next.

`T5.5` is complete. The registered module-contract audit now proves the Canvas
producer performs no independent semantic recursion, delegates once to the
shared SPEC-008 traversal, owns no fill/glyph lowering or retained operation
list, and is the sole production stroke-emission entry point. Existing import
and graph checks keep Render Core and backend/raster/platform/driver targets
free of `GiftUIDrawing`, while the zero-Canvas execution fixture proves exact
ordinary transcript equivalence. The
[combined boundary evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-5/combined-render-boundaries.md)
records the audit. Milestone 5 is complete; the next dependency-complete work
must be selected from the remaining SPEC-013/SPEC-015-gated profile, startup,
integration, raster, and conformance tasks.

`T6.2` is complete for the checked static fixture. `GiftUIDrawing` owns the
exact amended `StaticCanvasCallableTable` protocol, and the manifest-generated
fixture supplies three dense direct-dispatch cases plus 8-byte, 12-byte, and
zero-byte capture records in one 12-byte greatest-case storage value. Dispatch
borrows that storage, copies only scalar field values needed by the nonescaping
Path body, preserves the exact two-`inout`/`Size`/typed-throws call shape, and
has no retained-closure fallback. Four ordered occurrences prove distinct
values for the repeated trace case. Normal and throwing owner paths invalidate
their sole logical capture record exactly once, and later invocation fails.
The
[static callable evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-6/static-canvas-callable-table.md)
records the source audit, layouts, dispatch transcript, and cleanup. T6.3 is
the next dependency-complete task; production profile integration remains
assigned to SPEC-013 and T6.5.

`T6.3` is complete at the checked generator boundary. The static manifest gate
now runs fourteen exact negative candidates and rejects zero, `UInt16`-excess,
and configured-limit-excess callable IDs; incomplete and duplicate switch
coverage; unsupported and over-limit capture layouts; dynamic collections;
existentials; heap-owned, weak, and unowned boxes; ordinary class references;
and captured closures. The generated-source audit additionally requires the
borrowed capture signature and rejects a complete-storage copy, `@escaping`
storage, capture arrays, and any retained closure fallback. The
[generation rejection evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-6/static-canvas-generation-rejections.md)
records every first diagnostic. Focused host tests and the full 431-test suite
remain green. T6.4-T6.5 production work retains its SPEC-015/SPEC-013 gates.

`T8.3` and `T8.4` are complete through SPEC-014's production consumers. All
17 independently frozen SPEC-012 vectors pass through both full-surface
RGBA8888/RGB565 storage and the bounded operation-major tiled RGB565 path with
zero mask or byte differences. The joined suites also prove exact RGB565
rounding and byte order, partial final tiles, exact workspace equality and
first-excess rejection, admitted arithmetic failure without saturation,
single borrowed-operation consumption, workspace/payload poisoning, and no
retained Core address or hidden complete-frame tiled storage. The
[consumer-join evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-8/full-surface-tiled-consumers.md)
records the owner tests and reproduction commands. Milestone 8 is complete;
no connected display or hardware claim is made.

`T7.1`-`T7.3` are complete through SPEC-015's generated workload and host
validation join. The host checks every nonzero B2 Drawing fact, exact
render-workspace source relation, combined ordinary/stroke capacity, and
Dynamic/Static callable metadata before the separately generated SPEC-004
capability requirement is resolved. The requirement carries all five operation
bits and no Drawing storage field. The narrow Drawing adapter maps all local
derivation errors plus idle refusal and combined-stream invariant outcomes to
their exact SPEC-003 facts. Focused zero, first-excess, profile, capability-
shape, and mapping tests are recorded in
`Tests/ContractFixtures/SPEC012/Evidence/milestone-7/startup-and-failure-integration.md`.
`T7.4` is complete through SPEC-013's shared production pipeline. A focused
Drawing failure remains exact through `RuntimeOwnerFailure`, stops before
publication, marks applied mutation dirty, releases/reset all acquired attempt
state, schedules semantic rederivation, and finalizes once. Accepted routing,
backpressure, and postpublication nonretryable refusal prove the complementary
commit/discard, pending/unavailable intent, published-revision preservation,
and no-retained-plan/callable cleanup paths. Evidence is in
`Tests/ContractFixtures/SPEC013/Evidence/milestone-5/complete-production-pipeline.md`.
