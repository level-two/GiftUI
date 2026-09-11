---
spec: SPEC-008
feature: giftui-mvp-architecture
title: SPEC-008 Implementation Plan
status: completed
owners:
  - codex
created: 2026-09-06
updated: 2026-09-11
related_design_notes: []
conformance_report: ../conformance/spec-008-conformance.md
related_future_work:
  - FW-001
  - FW-003
  - FW-004
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-008 Implementation Plan

> This completed plan incorporates the explicitly approved 2026-09-11
> foreground-stack and arithmetic-evidence amendment. Completed task records
> remain historical implementation evidence; the amendment follow-up work
> below must land before those surfaces are treated as conforming.

## Authority and Scope

The governing [SPEC-008](../specs/spec-008-rendering.md) contract is
`implementing` after the maintainer explicitly approved its focused
foreground-stack and arithmetic-evidence correction. Its authority chain is
accepted [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md),
approved [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md),
[RFC-003](../rfcs/rfc-003-deterministic-text-rendering-architecture.md), and
[RFC-010](../rfcs/rfc-010-layout-semantic-core-adapter-boundary.md), and
accepted [ADR-005](../adrs/adr-005-semantic-layout-render-boundary.md),
[ADR-006](../adrs/adr-006-shared-semantics-runtime-profiles.md),
[ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md),
[ADR-009](../adrs/adr-009-checked-integer-geometry.md),
[ADR-010](../adrs/adr-010-synchronous-one-shot-frame-handoff.md),
[ADR-021](../adrs/adr-021-canonical-text-geometry.md),
[ADR-022](../adrs/adr-022-positioned-glyph-render-operation.md),
[ADR-023](../adrs/adr-023-exact-font-resource-identity.md), and
[ADR-032](../adrs/adr-032-semantic-core-owned-layout-input.md).

Approved [SPEC-002](../specs/spec-002-portable-foundation.md) owns checked
`Int32` geometry, compiler and SDK identities, and the four-profile evidence
conventions. Approved
[SPEC-003](../specs/spec-003-failure-outcomes-and-containment.md) owns failure
facts and containment. Approved
[SPEC-005](../specs/spec-005-text-resources.md) owns exact font/glyph identity,
validated metrics, and synchronous resource borrowing. Approved
[SPEC-006](../specs/spec-006-declarative-view-semantics.md) owns semantic
expansion, identity, modifier order, and typed payload dispatch. Approved
[SPEC-007](../specs/spec-007-layout.md) owns canonical text selection and
positioning, resolved bounds and clips, and the layout result consumed here.
This plan consumes those contracts without creating substitute owners.

Approved [SPEC-009](../specs/spec-009-execution-cycle-and-frame-handoff.md) and
[SPEC-014](../specs/spec-014-backend-integration.md) consume SPEC-008 outputs;
[SPEC-013](../specs/spec-013-runtime-profiles.md) and
[SPEC-015](../specs/spec-015-host-configuration.md) are in coordinated review
for the render-workspace limit and workload-schema additions. These contracts
consume SPEC-008 outputs
through separately governed execution, runtime, and backend boundaries. Their
integration seams are audited here only to prove that SPEC-008 remains usable;
their frame disposition, storage, rasterization, and platform behavior are not
implemented by this plan. Approved
[SPEC-011](../specs/spec-011-interaction.md) consumes
SPEC-008 paint order and visual behavior while separately owning disabled
state, hit maps, pointer capture, and action dispatch; those interaction facts
must remain parallel to, and absent from, the normalized render stream. Approved
[SPEC-012](../specs/spec-012-canvas-path-stroke-drawing.md) separately extends
the semantic and operation surfaces for Canvas/strokes and is not scheduled as
SPEC-008 work.

The [MVP Scope](../MVP_SCOPE.md) requires one substantially shared Signal
Analyzer Presentation with bounded text, opaque foreground and rectangular
background styling, deterministic positioned text, clipping, and shared
render semantics across macOS dynamic, macOS static, Raspberry Pi 1/Linux
dynamic, and nRF52840 static configurations. SPEC-008 is the backend-free
normalized-operation proof for that requirement. It does not authorize pixel
rasterization, surfaces, backend reservation or presentation, platform or
driver work, deployment, or connected-hardware changes.

## Current Repository State

- `Sources/GiftUI/GiftUI.swift` implements SPEC-002 checked geometry;
  SPEC-006 supplies the sealed traversal surface; and SPEC-008 T1.1-T1.4 now
  supply `Color`, `BoundedText`, `Text`, foreground style, and background
  declarations with typed primitive/modifier payloads.
- `Sources/GiftUISemanticCore/GiftUISemanticCore.swift` contains in-progress
  bounded semantic expansion and recording support, but not the approved
  `SemanticRenderScope`/`SemanticRenderView` or an adapter over a complete
  semantic result.
- `GiftUITextResources` and the concrete reference package provide the exact
  resource, instance, glyph, descriptor, and canonical metrics contracts that
  rendering must reuse. No parallel rendering identity is needed or allowed.
- `GiftUIRenderCore`, `GiftUILayout`, and `GiftUIRenderLowering` now exist with
  their exact production dependencies and focused test targets. The narrow
  rendering/failure owner adapter has landed with only its approved edges, so
  T0.2 is complete.
- `Tests/ContractFixtures/SPEC008/` and the registered four-profile driver now
  exist. The canonical render/analyzer cases, recording sink, complete profile
  probes, and allocation/stack/value-layout instrumentation remain pending.
- SPEC-002 through SPEC-006 provide reusable conventions for exact target
  allow lists, positive and negative compile fixtures, normalized transcripts,
  owner-adapter mappings, fail-closed fixture manifests, allocation
  interposition, cross-build resource inspection, and explicit registration
  with `scripts/test.sh`.
- SPEC-006 and SPEC-007 are `implemented`. Public rendering declarations,
  render-core values/transport, direct fixture views, the recording oracle,
  driver scaffolding, and the production semantic-result render adapter are
  available. The resolved-layout render adapter remains the next owner seam.
- Existing `RenderProducerContribution` names under SPEC-004 fixtures describe
  capability contributions, not a conforming normalized renderer. Historical
  `Color`, display-list, text-placement, and backend code is migration evidence
  only and must not be restored as a second rendering path.
- The repository may contain concurrent lifecycle work on neighboring
  Specifications. SPEC-008 implementation must preserve those changes and
  coordinate shared declaration/traversal surfaces without overwriting or
  broadening another contract.

## Readiness Review

**Reviewed:** 2026-09-11

**Disposition:** Ready with coordinated downstream gates. `T4.2` showed that
the prior workspace surface could not perform exact linear duplicate/count
validation for arbitrary `Equatable` identity with bounded zero-allocation
storage, and that two traversals could not prove complete lookup agreement
without an owner-provided immutable-result signal or a prohibited retained
transcript. The approved SPEC-008 amendment adds dense ordinal projections,
separate structural workspace capacity and visit sets, snapshot versions,
exact traversal-depth rules, preflight-only visit accounting, and bounded-work
view access. The existing follow-up tasks below cover the already completed
view, workspace, fixture, and value-layout work. Integration with SPEC-013 and
SPEC-015 waits for their focused amendments to be explicitly approved.
No `docs/features.yaml` update is required because the aggregate feature
remains in implementation while the individual Specification is approved and
its coordinated downstream consumers are in review.

If the pinned compiler cannot express the amended nonescaping generic borrows,
ordinal projections, snapshot-version guarantees, or workspace visits; if
static lowering requires heap allocation, a complete display list, or a per-
field proof transcript; or if any required value cannot meet its size ceiling,
the affected task returns to Specification or architecture review. The plan
must not add translated identity, backend text measurement, runtime-owned
lowering, profile-specialized semantics, frame history, rasterization, or
relaxed atomicity and limit behavior.

## Task Dependencies and Affected Surfaces

Milestone numbers define the default execution order. A task may start only
after every listed prerequisite is satisfied.

| Work | Prerequisites | Primary affected surfaces | Parallel boundary |
| --- | --- | --- | --- |
| `T0.1`-`T0.4` | Approved SPEC-008 authority chain | `Tests/ContractFixtures/SPEC008/`, `Package.swift`, `scripts/contracts/`, SPEC-002 graph fixtures | Fixture schemas, migration inventory, and driver scaffolding may proceed together; exact graph edits land with their first compiling targets |
| `T1.1`-`T1.5` | `T0.2` boundary audit and current SPEC-006 sealed payload/traversal surface; no new package target is needed for the `GiftUI`-owned declarations | `Sources/GiftUI/`, `Tests/GiftUITests/`, public compile fixtures, SPEC-006 semantic corpus | Color, bounded text, text primitive, and style modifiers may be implemented independently once their fixed payload roles are registered |
| `T2.1`-`T2.5` | Relevant `T1.*`; SPEC-006 complete result and SPEC-007 resolved result where named | `Sources/GiftUISemanticCore/`, `Sources/GiftUILayout/`, their unit tests, direct fixture views | Protocols and malformed direct views may precede production adapters; profile-equivalence claims wait for both prerequisite owners |
| `T3.1`-`T3.5` | `T0.2` boundary audit, `T1.1`, and existing SPEC-002/SPEC-005 values; the first compiling Render Core source lands with its T0.2 package rows | `Sources/GiftUIRenderCore/`, `Tests/GiftUIRenderCoreTests/`, recording fixtures | Operation values and sink lifecycle may proceed beside semantic/layout adapters; recording completion waits for the event schema |
| `T4.1`-`T4.5` | `T2.1`, `T3.1`-`T3.3`; direct fixture views | `Sources/GiftUIRenderLowering/`, `Tests/GiftUIRenderLoweringTests/`, owner adapter | Workspace/preflight may use direct views before production adapters; streaming follows the exact preflight traversal |
| `T5.1`-`T5.5` | `T2.*`, `T3.*`, `T4.*` as consumed by each row | lowering/core unit tests and canonical success corpus | Style, text, clip/damage, and lifecycle fixtures may be divided after canonical traversal and checked-intersection helpers are fixed |
| `T6.1`-`T6.5` | Applicable `T1`-`T5` behavior complete | complete SPEC-008 corpus, normalized profile probes, instrumentation | Focused failure and golden rows may run independently; complete cross-profile comparison waits for all corpus rows |
| `T7.1`-`T7.5` | `T1`-`T6`; production SPEC-006/SPEC-007 outputs for end-to-end rows | package graph, Signal Analyzer manifest, SPEC-009/011/012/013/014 seams | Boundary audits may precede production integration; full analyzer and shared-lowering claims wait for prerequisite owners |
| `T8.1`-`T8.5` | All applicable implementation and fixture tasks complete | formatter/gates, four profile reports, this plan, conformance report | Profile runs may execute independently after corpus freeze; comparison and conformance preparation consume all four reports |

Implementation may resume after an authorized transition of SPEC-008 to
`implementing` with this plan moved to `active`. SPEC-013/SPEC-015 integration
rows additionally require those coordinated amendments to be approved.

## Acceptance-Criterion Matrix

The criterion text remains authoritative in SPEC-008. Every criterion appears
once below and maps to implementation tasks and reproducible evidence.

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `RD-001` — Exact public text/color/style declarations and absence of clear, alpha, and portable unbounded String APIs | `T1.1`-`T1.5`, `T8.1` | Positive/negative public compile corpus and API/source audit on all compilers | pass |
| `RD-002` — Exact bounded-text admission and pre-layout invalid-declaration rejection | `T1.2`-`T1.4`, `T2.2`, `T6.2`, `T8.2` | UTF-8/integer byte goldens, invalid-marker semantic/layout probe, allocation/trap/invocation counters | pass |
| `RD-003` — Exact valid headers, fills, glyph groups, ordering, geometry, identity, indices, baselines, and RGB | `T3.1`-`T3.4`, `T5.1`-`T5.3`, `T6.1`, `T8.2` | Canonical `fixtures.yaml` transcript and field-by-field recording comparisons | pass |
| `RD-004` — Explicit root-intersection and complete-surface damage with no frame history | `T5.4`, `T6.1`, `T7.3`, `T8.2` | Damage-mode goldens, state/source audit, and repeated-attempt probes | pass |
| `RD-005` — Exact errors, mappings, precedence, structural capacity/ordinal/snapshot failures, preflight-only visit accounting, begin/discard/reset counts, and atomic current transcript | `T4.1`-`T4.5`, `T5.5`, `T6.3`, `T8.2` | Fault-injection and coincident-failure matrix with local/mapped results and sink/workspace call counts | pass |
| `RD-006` — No text reinterpretation, identity translation, retained borrow, glyph array, display-list, or per-field transcript requirement | `T2.4`, `T3.3`, `T4.4`, `T5.2`, `T6.4`, `T7.1` | Borrow/lifetime, source/import, streaming, allocation, and no-retained-list/transcript audits | pass |
| `RD-007` — Recording/dynamic/static equivalence and exact render-limit and structural-capacity behavior | `T4.2`, `T5.5`, `T6.3`-`T6.5`, `T8.2`-`T8.4` | Normalized event/result/mapping comparisons and exactly-at/one-over reports | pass |
| `RD-008` — Value layouts including structural capacity, four commands, zero static allocation, affine view-access work, and complete reproducible measurements | `T0.3`, `T3.5`, `T6.4`, `T8.1`-`T8.4` | Per-profile compiler, digest, layout, access/comparison work, allocation, high-water, timing, section, and link-map reports | pass |
| `RD-009` — Complete Signal Analyzer rendering manifest fitting all four profiles without a pixel backend | `T7.2`, `T7.4`, `T8.2` | Manifest coverage audit, declared/observed limits, and four-profile backend-free transcript | pass |
| `RD-010` — Exact import graph and one shared lowering implementation across profiles | `T0.2`, `T2.5`, `T7.1`, `T7.3`, `T8.1` | Target graph, import-negative fixtures, symbol/source ownership audit, and shared-lowering profile probe | pass |
| `RD-011` — No raster, frame disposition, capability resolution, profile selection, interaction/hit-map authority, platform, hardware, or Canvas/stroke contract in SPEC-008 implementation scope | `T0.4`, `T7.1`, `T7.3`-`T7.5`, `T8.5` | Scope/migration audit, prohibited-import scan, downstream-seam review, and conformance review disposition | pass |

## Milestones and Tasks

### Milestone 0: Freeze Scope, Module Boundaries, and Evidence Schemas

**Entry conditions:** These tasks were completed while SPEC-008 was `approved`;
any amendment follow-up requires renewed approval. PROPOSAL-003 remains
`accepted`; linked RFCs remain `approved`; linked ADRs remain `accepted`; and
SPEC-002, SPEC-003, SPEC-005, SPEC-006, and SPEC-007 remain approved authority.

**Exit evidence:** The exact target graph, fixture schema, report schema,
migration baseline, and registered fail-closed driver skeleton exist before
rendering behavior is claimed.

- [x] `T0.1` — Create `Tests/ContractFixtures/SPEC008/` with canonical
      `fixtures.yaml`, `signal-analyzer.yaml`, stable symbolic identity tokens,
      ordered recording-event/result/failure schemas, an acceptance/evidence
      registry, and README. Reject duplicate names, missing fields, unknown
      cases, and unreferenced fixture data. Distinguish host execution,
      cross-build/inspection, simulator, and connected-hardware evidence; no
      SPEC-008 task requires deployment or flashing.
- [x] `T0.2` — Add `GiftUIRenderCore`, `GiftUIRenderLowering`, their focused
      unit-test targets, and a narrowly named rendering/failure owner-adapter
      fixture to `Package.swift` only as their first compiling sources land.
      Give Render Core exactly `GiftUI` and `GiftUITextResources`; give Render
      Lowering exactly `GiftUI`, `GiftUISemanticCore`, `GiftUILayout`,
      `GiftUITextResources`, and `GiftUIRenderCore`; give the owner adapter
      only lowering and `GiftUIFailureCore`. Update SPEC-002 exact target and
      dependency fixtures atomically, including reverse and every prohibited
      runtime, execution, failure, capability, backend, raster, concrete
      resource, platform, driver, OS/RTOS, HAL, and hardware edge.
      This is an incremental boundary task: complete the graph audit and exact
      intended rows before source work, land each target row atomically with
      that target's first compiling source, and mark T0.2 complete only after
      all named targets and checks exist. It is not a prerequisite requiring
      empty placeholder targets.
- [x] `T0.3` — Create `scripts/contracts/run-spec-008.sh --profile <profile>`
      for exactly `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
      `nrf52840-embedded`; register it in
      `scripts/contracts/driver-registry.tsv`. Initially fail closed for every
      missing compiler/target/SDK/optimization identity, repository revision,
      command, fixture digest, value layout, result/transcript comparison,
      declared/observed high-water, allocation/workspace/stack measurement,
      timing sample, section delta, link map, or required ELF inspection.
- [x] `T0.4` — Inventory historical and current rendering-like surfaces,
      including `Color`, raw-string text, display lists, recording backends,
      backend text placement, host-sized counts, unchecked clip/damage
      arithmetic, retained borrows, and capability fixture names. Assign
      adopt, adapt, replace, retire, or already-absent dispositions and add
      regression scans rejecting a second style/lowering/operation path.

### Milestone 1: Implement the Portable Text, Color, and Style Surface

**Entry conditions:** Milestone 0 fixes compile-fixture and package boundaries.
SPEC-006's one sealed primitive/modifier traversal remains the only path from
public declarations into semantic expansion.

**Exit evidence:** Portable clients compile the exact API using only
`import GiftUI`; admitted text is stored inline and exact; invalid literal
declarations remain fail-closed; and style declarations preserve source order
without performing rendering.

- [x] `T1.1` — Implement three-byte `Color` with exact public initializer,
      conformances, and six named RGB values. Add compile and layout probes
      proving exact size and field values; negative fixtures prove there is no
      `clear`, alpha channel/initializer, lower-layer duplicate, or backend
      reinterpretation hook.
- [x] `T1.2` — Implement inline `BoundedText` with maximum 96 UTF-8 bytes,
      exact `StaticString` and generic byte-collection admission, trailing C
      NUL treatment, UTF-8 validation, locale-independent complete `Int32`
      formatting, and one-call nonescaping `withUTF8`. Prove the 100-byte
      ceiling and exclude reference/string/dynamic-collection storage whose
      validity contributes to the value.
- [x] `T1.3` — Implement `Text` as a primitive for admitted `BoundedText` and
      `StaticString`. Preserve a closed invalid-declaration marker for
      oversized or malformed literals without trap, repair, truncation, or
      correctness allocation, and expose no portable unbounded `String`
      initializer. Any dynamic convenience remains a separate optional module
      and is not required by this plan.
- [x] `T1.4` — Implement `foregroundStyle` and rectangular `background` as
      typed SPEC-006 modifier payloads, preserving exact color, structural
      identity, and source-call order. Extend the semantic declaration corpus
      for text and both modifiers without introducing public traversal
      witnesses or rendering work in `GiftUI`.
- [x] `T1.5` — Complete positive and negative compile fixtures for all
      declarations, named colors, empty/96/97-byte and malformed inputs,
      embedded/trailing NUL, ASCII, degree/replacement scalars, every required
      `Int32`, modifier chaining, custom views, dynamic/static compilation,
      and forbidden public conveniences. Record exact admitted bytes and
      allocation/trap/body-evaluation counters.

### Milestone 2: Expose Rendering Views from Semantic Core and Layout

**Entry conditions:** SPEC-006 supplies exact successful semantic identity and
typed scopes; SPEC-007 supplies exact successful resolved layout identity,
bounds, clips, lines, and glyphs. Direct fixture views may be created before
those production owners land, but production adapters and equivalence claims
must wait.

**Exit evidence:** Semantic Core and Layout expose the exact read-only package
views required by SPEC-008, keyed by one identity domain and borrowed without
copying a second semantic/layout result.

- [x] `T2.1` — Implement `SemanticRenderScope` and `SemanticRenderView` in
      `GiftUISemanticCore` with exact counts/lookups, child order, rendering-
      relevant payloads, and identity-preserving `layoutIdentity` selection.
      Represent structural, clip-boundary, text, foreground, and background
      meaning only; keep action/state/runtime/layout-algorithm/backend facts
      outside the view.
      **Amendment follow-up complete:** exact semantic ordinal
      bijection/inverse lookup and the semantic render snapshot version are
      verified by the amended-contract evidence.
- [x] `T2.2` — Adapt complete SPEC-006 results to the render view. Map primitive
      and layout modifiers to themselves, transparent/render-only scopes to
      their one flattened layout content scope, every SPEC-007 frame and only
      frames to `clipBoundary`, and invalid `Text` to SPEC-007's existing
      `.invalidDeclaration` path before layout publication or render
      invocation.
- [x] `T2.3` — Implement `ResolvedRenderTextLine`, `ResolvedRenderGlyph`, and
      `ResolvedRenderLayoutView` in `GiftUILayout`. Adapt complete SPEC-007
      results without translating identity or remeasuring text; expose exact
      bounds, clips, line/glyph indices, instances, glyphs, and baselines with
      the specified in-range and out-of-range behavior.
      **Amendment follow-up complete:** exact layout ordinal bijection/inverse
      lookup and the layout render snapshot version are verified by the
      amended-contract evidence.
- [x] `T2.4` — Build direct valid and malformed semantic/layout views covering
      unequal roots, independent counts, missing/duplicate identities,
      transparent/render-only mappings, invalid arity, prohibited children,
      every out-of-range index, every prohibited in-range `nil`, and all line/
      occurrence-wide glyph-index disagreements. Compare identity relations
      through symbolic fixture tokens, never raw bytes or hashes.
- [x] `T2.5` — Add import, lifetime, allocation, and materialization probes
      proving the views remain in their authoritative owners, share exact
      identity, retain no borrow, allocate zero on the static path, create no
      second complete graph/result, and expose no rendering authority to
      layout or layout authority to Render Core.

### Milestone 3: Implement Render Core Values, Transport, and Recording

**Entry conditions:** The Render Core target boundary exists; SPEC-002 geometry,
SPEC-005 identity, and SPEC-008 `Color` are available. No semantic or layout
module is imported.

**Exit evidence:** One backend-neutral package SPI carries complete normalized
fill and positioned-glyph meaning in painter order, and the canonical
recording sink enforces atomic current transcripts without pixel behavior.

- [x] `T3.1` — Implement `RenderProductionError`, `RenderSinkCapacity`, `RenderPlanHeader`,
      `PositionedGlyph`, `FillRectOperation`, and
      `PositionedGlyphOperationHeader` with exact fields, access, initializers,
      conformances, resource identities, and value-size ceilings. Add source/
      layout audits excluding references, strings, existential meaning,
      closures, dynamic collections, and duplicate identity types.
- [x] `T3.2` — Implement `RenderOperationSink` with the exact begin/fill/group/
      glyph/end/finish/discard protocol and one-read idle capacity. Define
      conformance fixtures for empty streams, multiple fills/groups, zero
      capacity, incomplete groups, and every explicit refusal point without
      turning sink capacity into frame or raster acceptance.
- [x] `T3.3` — Implement the canonical recording sink over caller-owned bounded
      storage with closed value events, staged/current transcript separation,
      exact attempted-call counters for failure tests, discard clearing only
      the attempted transcript, and no retained input/resource borrow or
      string/pointer serialization.
- [x] `T3.4` — Add field-by-field recording verification that successful
      transcripts start with one begin, end with one finish, match header
      operation/glyph counts, keep each glyph group complete and ordered, and
      preserve nominal identities and numeric values without using memory
      bytes, pointers, hashes, metatype addresses, or profile-private storage.
- [x] `T3.5` — Add macOS and cross-compiler value-layout probes for every
      SPEC-008 value, including exact sizes for `Color`, `RenderLimits`,
      `RenderSinkCapacity`, and `RenderProductionError`, plus all upper bounds.
      Record compiler/target/optimization identity with each result.
      **Amendment follow-up complete:** the exact 8-byte
      `RenderWorkspaceCapacity` and exact 1-byte `RenderWorkspaceVisit` values
      pass on all four compilers.

### Milestone 4: Implement Bounded Atomic Render Production

**Entry conditions:** Direct semantic/layout views and Render Core transport
are testable. Production adapters may follow once SPEC-006 and SPEC-007 land.

**Exit evidence:** One generic shared lowering implementation performs exact
two-pass preflight and streaming with caller-owned finite workspace,
deterministic failure precedence, and atomic sink behavior.

- [x] `T4.1` — Implement `RenderLimits`,
      `RenderProductionResult`, and `RenderProductionWorkspace` with exact
      access, cases/raw values, nonzero limit validation, capacity reporting,
      acquisition/reset semantics, and required value layouts. Provide bounded
      fixture workspaces keyed by the same semantic/layout identity.
      **Amendment follow-up complete:** `RenderWorkspaceCapacity`, separate
      structural capacity reporting, and bounded semantic/layout ordinal visit
      sets have exact first/repeated/invalid and acquire/reset behavior.
      **Amendment follow-up complete:** exact current/push/pop foreground-stack
      operations use `maximumTraversalDepth` as physical capacity and have
      covered inactive/full/empty/reset behavior.
- [x] `T4.2` — Implement canonical depth-first traversal and preflight over
      immutable borrows. Validate root mapping, exact semantic/layout counts,
      ordinal bijections and preflight-only visit sets, every lookup and
      structural invariant,
      checked intersections, exact operation/glyph totals, structural clip and
      exact semantic traversal depth including every wrapper/modifier child,
      resource compatibility, render and structural workspace capacity,
      snapshot stability, exact first-visit totals, and the one sink-capacity
      read without emitting or retaining operations.
- [x] `T4.3` — Implement the second traversal as direct ordered streaming and
      repeat every canonical lookup under the unchanged snapshot-version
      contract without clearing or calling either visit set and without
      retaining a per-field proof transcript. Call `begin`
      once only after all preflight/capacity/version checks, keep glyph groups
      whole, call `finish` once on success, and treat any version disagreement
      or post-begin refusal as invariant failure with exactly one discard.
- [x] `T4.4` — Implement the idle/acquired/preflighting/begun/streaming/
      finished-or-discarded/reset lifecycle. Check active-workspace reentry
      first before all input/sink access; call `acquire` only when inactive;
      reset exactly once after every successful acquisition on every exit;
      retain no input, operation, resource, pointer, or replay state.
      **Amendment follow-up complete:** reset also clears the foreground stack
      after every acquired exit.
- [x] `T4.5` — Implement the narrow owner adapter mapping all seven local
      errors to their exact SPEC-003 facts, origins, scopes, and containment.
      Prove lowering imports neither `GiftUIFailureCore` nor diagnostics and
      that no diagnostic path allocates as a requirement, changes the result,
      or triggers a second attempt.

### Milestone 5: Implement Style, Text, Clip, Damage, and Painter Semantics

**Entry conditions:** Milestone 4 provides canonical two-pass traversal and
atomic emission. Checked geometry and canonical resource identities remain
owned by their prerequisite modules.

**Exit evidence:** Focused goldens reproduce every valid SPEC-008 rendering
rule and every failure boundary without rasterization or frame state.

- [x] `T5.1` — Implement inherited root foreground, nested innermost
      foreground resolution, sibling isolation, and a bounded foreground stack
      in caller-owned workspace through exact current/push/pop operations,
      including root initialization, LIFO restoration, full/empty/inactive
      refusal, high-water, and reset behavior. Emit backgrounds immediately
      before their content subtree, with outer-before-inner modifier order,
      exact unclipped resolved bounds, final checked clip, and omission only for
      zero-area bounds or empty final clips.
- [x] `T5.2` — Implement source-order sibling and back-to-front ZStack painter
      traversal without sorting, coalescing, batching across intervening
      operations, resource/color reordering, or opaque-overdraw elimination.
      Stream one positioned-glyph group per non-empty line in occurrence-wide
      glyph-index order.
- [x] `T5.3` — Preserve exact SPEC-007 instances, glyphs, baselines, bounds,
      and logical clips; apply only effective foreground and surface
      intersection. Validate metrics descriptor/resource identity and every
      instance/glyph before begin; never pass raw text or remeasure, reshape,
      fallback, add advances, move baselines, substitute, or translate.
- [x] `T5.4` — Implement checked surface/root/operation intersections,
      nonzero-origin rejection, structural clip-depth accounting, empty-clip
      omission, `.rootIntersection` damage, and exact
      `.initializeCompleteSurface` damage. Keep root bounds unclamped for
      damage calculation and retain no first-frame or other frame history.
- [x] `T5.5` — Exercise exact failure precedence—reentrancy, invalid input,
      arithmetic, capacity, incompatible resource, begin refusal, invariant—
      across every simultaneously constructible pair. Audit the defensive
      checked-intersection arithmetic branches and direct error mapping without
      forging an invalid SPEC-002 rectangle. Verify before-begin failures call
      neither begin nor discard, begin refusal leaves the sink idle, every
      post-begin failure discards once, and prior current recordings remain
      atomic.

### Milestone 6: Complete the Canonical Corpus and Profile Equivalence

**Entry conditions:** Public declarations, views, core transport, lowering,
and focused semantics are independently testable. Fixture roles use stable
tokens rather than profile-private identity encodings.

**Exit evidence:** The complete corpus produces equal field-by-field success
and failure meaning across recording, fixture-dynamic, and fixture-static
paths while proving linear work, bounded storage, zero static allocation, and
nonescaping borrows.

- [x] `T6.1` — Assemble golden cases for nested foreground/background,
      siblings, ZStack order, empty/zero bounds, partial/off-surface/empty and
      unchanged nested clips, both damage modes, exact RGB, unclipped fill
      bounds, exact text identities/indices/baselines, non-empty groups, and
      empty-line omission.
- [x] `T6.2` — Complete UTF-8 and declaration integration, proving every
      admitted byte sequence and integer value, invalid literal propagation
      through semantic expansion into SPEC-007 rejection, and zero render
      invocation or layout publication after invalid declaration.
- [x] `T6.3` — Fault-inject every semantic/layout mismatch and every
      constructible producer failure; audit defensive arithmetic sites and the
      direct arithmetic-error mapping; exercise exactly-at/one-over
      operation/glyph/clip bound and semantic-scope,
      layout-scope, traversal-depth, and text-line capacity; ordinal visit-set
      failure and exact preflight-only visit counts; workspace/sink shortfall;
      incompatible resource; every sink
      refusal; snapshot changes before and after begin; nested reentry; and
      reuse. Record exact local/mapped error and begin/discard/reset/attempted-
      call counts.
- [x] `T6.4` — Instrument canonical traversal work as `O(o + g)`, static heap
      allocation as zero, render and structural workspace capacity/bytes,
      maximum call-stack high-water, lowering duration and timing method/
      samples, and incremental linked code/read-only/initialized/zero-
      initialized data. Count every view access and identity comparison across
      both traversals and prove an affine `o + g` upper bound with no result-
      sized accessor scan. Prove no complete retained display list, glyph-run
      array, or per-field preflight transcript is required.
- [x] `T6.5` — Run the entire corpus through recording, fixture-dynamic, and
      fixture-static semantic/layout/workspace storage. Compare headers,
      ordered value events, results, SPEC-003 mappings, limits, and high-water
      values field by field; audit both profile paths to the same
      `GiftUIRenderLowering.RenderProducer.produce` implementation.

### Milestone 7: Integrate the Signal Analyzer and Governed Consumer Seams

**Entry conditions:** Milestones 1-6 pass locally. Production end-to-end rows
wait for complete successful SPEC-006 and SPEC-007 results; direct recording
and boundary audits do not.

**Exit evidence:** The Signal Analyzer rendering corpus fits all exact fixture
limits without pixels, the package graph is mechanically enforced, and later
execution/runtime/backend/drawing contracts can consume or extend the seam
without acquiring SPEC-008 authority.

- [x] `T7.1` — Complete package-graph, symbol-owner, and source audits proving
      Render Core depends only on `GiftUI` and `GiftUITextResources`; Render
      Lowering alone joins semantic and layout; neither imports a runtime,
      execution, failure core, capability, backend, raster provider, concrete
      resources, platform, driver, OS/RTOS, HAL, or hardware module; backends
      cannot import semantic/layout/lowering authority; and `GiftUI` does not
      re-export internal rendering SPI.
- [x] `T7.2` — Populate `signal-analyzer.yaml` with every required label,
      bounded value, status/error text, opaque foreground, rectangular
      background, and maximum hierarchy variant. Fix the exact operation,
      glyph, clip-depth, semantic-scope, layout-scope, traversal-depth, text-
      line, workspace, and sink limits used by all four profile runs; record
      declared and observed high-water without claiming they are final
      production-host budgets.
- [x] `T7.3` — Add integration fixtures for SPEC-009's synchronous one-shot
      sink/envelope seam, SPEC-013's shared-lowering coordination seam, and
      SPEC-014's backend-side Render Core consumption boundary. Prove the
      operation borrow is consumable once and no consumer gains semantic,
      layout, style resolution, profile selection, frame disposition,
      capability, or raster authority. Do not implement those Specifications'
      owned behavior here.
- [x] `T7.4` — Audit SPEC-012 coexistence without adding Canvas/stroke cases to
      the SPEC-008 criterion set or base transcript. Preserve extension points
      required by the separately approved drawing contract, and prove ordinary
      SPEC-008 production remains identical when no Canvas declaration is
      present. Any integration implementation belongs to SPEC-012's plan.
- [x] `T7.5` — Audit SPEC-011 coexistence using a visual Button fixture whose
      label, foreground, background, and painter order lower through SPEC-008
      while disabled state, hit geometry, action identity, pointer capture, and
      dispatch remain outside semantic render views and normalized operations.
      Prove rendering neither consumes nor publishes the runtime-owned hit map;
      interaction implementation and conformance remain in SPEC-011's plan.

### Milestone 8: Run the Four-Profile Gate and Prepare Conformance Review

**Entry conditions:** Every focused test and audit is registered fail-closed;
all prerequisite-owned declarations used by the complete corpus are present.

**Exit evidence:** Each exact standalone command and the top-level gate
produce inspectable evidence for every criterion, with cross-build evidence
separated from connected-hardware claims and every plan task dispositioned.

- [x] `T8.1` — Run unit, public/negative compile, package-graph, forbidden-
      import, API/source-surface, migration, and formatter checks. Verify all
      exact/maximum value-layout requirements, including
      `RenderWorkspaceCapacity`, on each contract compiler and ensure
      SPEC-008's standalone driver remains explicitly registered with the top-
      level gate.
- [x] `T8.2` — Run the four exact commands required by SPEC-008 and capture
      complete command lines, compiler/target/SDK/optimization identities,
      repository revision/dirty state, fixture digests, layouts, declared and
      observed operation/glyph/clip and structural high-water, render and
      structural workspace capacity/bytes, maximum stack high-water,
      allocation count, timing method/samples, section deltas, link maps, and
      acceptance/evidence dispositions.
- [x] `T8.3` — For macOS dynamic/static and Raspberry Pi ARMv6, compare the
      complete normalized success/failure corpus, owner mappings, values, and
      resource identity evidence. The Raspberry Pi result is cross-build and
      inspection only; it does not claim `armv6l` execution, framebuffer
      presentation, input, or PiScreen hardware validation.
- [x] `T8.4` — For nRF52840, prove the complete contract fixture compiles and
      links with zero static heap allocation and finite workspace; inspect
      values, symbols, sections, linked code, and the ELF's Cortex-M4F
      hard-float VFP calling convention. Record cross-build/inspection only;
      do not flash or claim connected-board display/input evidence.
- [x] `T8.5` — Update this plan with every completed, changed, removed, or
      blocked task disposition and stable evidence link. Create
      `docs/conformance/spec-008-conformance.md` in `collecting` status, map
      `RD-001` through `RD-011` once, and request conformance review. Do not
      mark SPEC-008 `implemented` without a complete report and explicit human
      authorization.

## Design-Note Triggers

- After `T4.2` fixes the exact mechanism, create
  `docs/implementation-designs/spec-008-two-pass-render-production.md` only if
  the identity-indexed caller-owned workspace, preflight/stream agreement,
  acquisition rollback, and profile fixture storage would be difficult to
  reconstruct from code and tests. The note may choose replaceable bounded
  storage; it may not change traversal order, error precedence, limits, or
  atomic sink behavior.
- After `T5.1`-`T5.3`, create
  `docs/implementation-designs/spec-008-style-and-glyph-streaming.md` only if
  foreground-stack restoration, render-only identity mapping, and direct
  line-group streaming form one non-obvious mechanism worth maintaining. It
  must not introduce batching, a retained display list, text measurement, or
  another resource identity.
- The canonical recording sink does not require a design note if its staged/
  current implementation is self-explanatory. Any need for raster caches,
  surfaces, frame state, profile-specific lowering, Canvas/stroke behavior,
  or retained replay is upstream or already deferred, not a design-note
  decision.

## Integration and Validation Order

1. Establish the fixture/evidence registry and exact package edges before
   implementation can hide a dependency mistake.
2. Land `Color`, bounded text, text/style declarations, Render Core values,
   and direct recording storage in parallel where their fixed interfaces do
   not overlap. Extend SPEC-006 payload recording without performing layout or
   rendering in `GiftUI`.
3. Add direct semantic/layout fixture views, then bounded preflight and sink
   lifecycle. Integrate production adapters only after SPEC-006 and SPEC-007
   provide their complete successful results and exact shared identity.
4. Prove two-pass atomic production and failure precedence before style/text
   goldens; combine painter order, clipping, damage, and text identity into one
   canonical transcript only after focused behavior passes.
5. Run unit and contract-local recording evidence before dynamic/static
   equivalence. Run macOS dynamic first, macOS static second, then hardware-
   free ARMv6 and nRF52840 cross-build/inspection. No pixel backend or
   connected hardware is required for SPEC-008 conformance.
6. Integrate the complete Signal Analyzer manifest after its prerequisite
   semantic/layout outputs exist. Audit later execution/runtime/backend,
   interaction, and drawing seams without implementing their owned behavior or
   expanding SPEC-008's acceptance scope.
7. Register the exact standalone driver with the top-level gate and create the
   conformance report only after all criterion rows have reproducible evidence.
   Hardware-free aggregation must not imply deployment, flashing, display, or
   input validation.

## Risks and Upstream Blockers

### Implementation risks

- A recursive double traversal can increase static stack use even with zero
  heap allocation. Measure call-stack high-water and use a bounded iterative
  implementation/design note if needed without changing canonical order.
- Repeated mappings from transparent and render-only scopes can accidentally
  inflate layout counts or turn ordinals into a second identity domain. Test
  the required ordinal bijections and distinct reachable layout identities
  separately from semantic traversal count, while using exact identities for
  all correlation and equality.
- Preflight/stream comparison can accidentally retain a complete operation
  list. Rely on owner-provided snapshot stability, store only bounded ordinal,
  traversal, style, clip, and count state permitted by the workspace contract,
  and audit out a per-field transcript.
- Text-resource validation can drift into backend or layout authority. Restrict
  rendering to exact descriptor/instance/glyph compatibility checks against
  already positioned SPEC-007 output.
- Exact value ceilings, especially the glyph operation header, may be sensitive
  to compiler layout. Measure every supported compiler before relying on a
  private representation and return upstream if a required ceiling cannot be
  met.
- Concurrent SPEC-006, SPEC-007, and SPEC-010 work shares declaration and
  semantic surfaces. Preserve user changes and coordinate exact owners rather
  than adding compatibility shims or parallel payload paths.

### Upstream blockers

- `T2.2`, production portions of `T2.5`, `T6.2`, `T6.5`, and `T7.2`-`T7.3`
  wait for SPEC-006's complete semantic result, exact identity, and typed
  payload dispatch. This is not permission to create a renderer-owned semantic
  graph.
- `T2.3`, production portions of `T2.5`, `T5.3`, `T6.2`, `T6.5`, and
  `T7.2`-`T7.3` wait for SPEC-007's resolved layout result, canonical text
  geometry, and exact render view. Direct malformed views and Render Core
  tasks do not wait.
- SPEC-013 and SPEC-015 integration portions of `T7.3` and `T7.4` wait for
  explicit approval of their coordinated render-workspace and schema-2
  amendments. This does not block focused SPEC-008 amendment follow-up.
- Any compiler failure of the reviewed borrow/lifetime, ordinal-bijection, or
  snapshot contracts, need to translate identity, inability to preserve exact
  two-pass agreement and atomicity, or inability to satisfy required value-
  size/zero-allocation bounds is a Specification or architecture blocker.
- Any proposed alpha/blending, gradients, effects, images, arbitrary clips,
  backend batching that changes order, fine-grained damage, retained replay,
  rasterization, frame history/disposition, capability-selected semantics,
  profile-specific lowering, or production host-budget choice is outside
  SPEC-008. Route a required current-scope change upstream; keep optional work
  in its governed deferred or downstream track.

## Deferred and Follow-up Work

- [FW-001](../future-work/fw-001-international-and-rich-text-layout.md)
  preserves richer text and shaping. SPEC-008 implements only admitted bounded
  text lowered from canonical SPEC-007 geometry.
- [FW-003](../future-work/fw-003-advanced-font-delivery-and-glyph-rasterization.md)
  preserves advanced resource and raster delivery. No raster provider or
  ambient font behavior is scheduled here.
- [FW-004](../future-work/fw-004-retained-render-tree.md) preserves an optional
  retained producer. Direct bounded sink emission remains the MVP contract.

No new deferred item was discovered while preparing this plan. A correctness,
capacity, profile-equivalence, resource-identity, or acceptance-evidence
obligation from SPEC-008 cannot be deferred.

## Completion Record

On 2026-09-11 implementation paused at `T4.2` and SPEC-008 returned to review.
The prior contract did not bound storage for exact semantic/layout distinctness
and traversal validation, and could not prove complete agreement between two
passes without retaining all observed fields. The approved amendment adds
owner-provided dense ordinal projections, a separate four-field structural
workspace capacity with ordinal visit sets, and owner-provided immutable
snapshot versions, with exact traversal-depth, visit-lifecycle, and linear-view-
access rules. The completed `T2.1`, `T2.3`, `T3.5`, and `T4.1` records remain
valid historical evidence but require the follow-up work marked above.
`docs/features.yaml` remains unchanged because its aggregate feature is still
in implementation.

Implementation began on 2026-09-06 at the maintainer's request. SPEC-008
returned to `implementing` and this plan returned to `active` on 2026-09-11 at
the maintainer's request after approval of the amendment. Neither that history
nor the resumed implementation authorizes the eventual `implemented`
transition.

`T0.1` is complete: `Tests/ContractFixtures/SPEC008/` now contains the exact
two canonical YAML manifests, frozen fixture and Signal Analyzer fields,
stable identity/resource tokens, ordered recording events, normalized results,
local-failure precedence and mapping, and all eleven pending acceptance rows.
The focused harness rejects duplicate names, missing or unknown fields and
cases, non-reciprocal criterion references, invalid or unreferenced symbolic
data, and any non-pending initial evidence. The fixture
[README](../../Tests/ContractFixtures/SPEC008/README.md) distinguishes host,
cross-build, inspection, simulator, and separately authorized connected-
hardware evidence without claiming deployment or flashing. `T0.4` may proceed
independently; package edits in `T0.2` remain coupled to their first compiling
sources.

`T0.3` is complete: `scripts/contracts/run-spec-008.sh` is registered for
exactly the four required profiles. It records the pinned compiler, target,
SDK, optimization, repository revision, exact command transcript, and input/
fixture digest, then publishes an immutable verified report. Its prerequisite
matrix remains explicitly fail-closed for absent Render Lowering and incomplete
Render Core transport, complete value layouts, normalized result and transcript comparisons,
declared/observed high-water, allocation, workspace, stack, timing, section,
link-map, target-image/ELF inspection, and acceptance evidence. The driver
performs no remote access, deployment, restart, simulator run, connected-
target execution, or flashing.

`T0.4` is complete: the PoC/current migration inventory classifies legacy
color, raw-string text, display lists, recording backends, backend text
placement, host-sized render collections, unchecked clip/damage arithmetic,
retained text borrows, and capability fixture naming as adopt, adapt, replace,
or retire work with an exact successor owner. The registered audit pins the
PoC revision, validates every inventoried path and disposition, preserves sole
`Color`/text/style ownership in `GiftUI`, and rejects a maintained parallel
display-list, recording-backend, backend text-placement, frame-history, damage,
or capability-coupled rendering path.

On 2026-09-06 the maintainer explicitly approved the coordinated SPEC-008/
SPEC-009 correction assigning the closed `RenderProductionError` value to
Render Core while preserving all detection, precedence, cleanup, and
production behavior in Render Lowering. The module graph and every existing
error case, raw value, mapping, layout bound, and acceptance criterion remain
unchanged. T3.1 now lands the value with Render Core; T4.1 retains limits,
result, workspace, and behavior.

`T1.1` is complete: `GiftUI.Color` stores exactly three public `UInt8`
channels, provides the exact initializer and six named opaque RGB values, and
conforms to `Equatable`, `Hashable`, and `Sendable`. Focused layout/value tests
and the registered public-client fixture set prove size, stride, alignment,
field values, required conformances, and the absence of `clear`, alpha API, or
backend reinterpretation hooks. A source audit rejects a second maintained
`Color` declaration; see the
[Color evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-1/color.md).
Cross-profile compilation remains assigned to T1.5/T3.5.

`T1.2` is complete: `GiftUI.BoundedText` admits at most 96 well-formed UTF-8
bytes into platform-neutral inline fixed-width storage, excludes one trailing
C NUL from `StaticString`, formats every `Int32` directly as locale-independent
ASCII, and provides the exact one-call borrowed byte surface. Focused tests
prove the 100-byte stride ceiling, admission and malformed-sequence boundaries,
integer extremes, equality, and throwing borrow behavior. Registered positive
and negative client fixtures plus a source audit exclude a portable unbounded
`String` initializer, mutable/public storage, and reference or dynamic-array
storage; see the
[BoundedText evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-1/bounded-text.md).
Cross-profile compilation remains assigned to T1.5/T3.5.

`T1.3` is complete: `GiftUI.Text` stores a package-visible typed SPEC-006
primitive payload behind the exact two public initializers. Admitted literals
and `BoundedText` preserve identical bytes; failed literal admission stores
only the closed invalid-declaration case without trapping or exposing it to a
portable client. Focused tests prove valid byte preservation, oversized
fail-closed storage, and one primitive visit without body evaluation. Compile
fixtures and the source audit reject an unbounded `String` initializer, client
payload access, alternate ownership, or reference storage; see the
[Text evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-1/text.md).
The SPEC-007 pre-measurement rejection path remains assigned to T2.2/T6.2.
Cross-profile compilation remains assigned to T1.5/T3.5.

`T1.4` is complete: the exact `foregroundStyle` and rectangular `background`
extensions produce opaque framework wrappers carrying distinct typed SPEC-006
modifier payloads. Focused traversal tests prove exact colors and source-call
order without body evaluation. The extended semantic corpus proves inner-to-
outer chain indices, synchronous typed payload consumption, and unchanged
descendant identity when only color values change. Compile fixtures and a
source audit reject direct client payload construction, wrapper storage
access, alternate traversal, and rendering/backend work in `GiftUI`; see the
[style evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-1/style-modifiers.md).
Cross-profile and complete declaration-boundary coverage remains assigned to
T1.5.

`T3.1` is complete: the first `GiftUIRenderCore` source and target rows landed
atomically with the exact `GiftUI` plus `GiftUITextResources` dependency edge.
The target owns `RenderProductionError`, `RenderSinkCapacity`,
`RenderPlanHeader`, `PositionedGlyph`, `FillRectOperation`, and
`PositionedGlyphOperationHeader`. Focused tests prove every field, initializer,
resource identity, raw error value, exact-size requirement, and upper layout
bound. The source audit excludes dynamic/reference storage, duplicate resource
identities, and semantic, layout, lowering, failure, capability, runtime, or
backend coupling; see the
[Render Core value evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-3/render-core-values.md).
T0.2 remains active until Render Lowering and its owner-adapter rows land.
`T3.2` is complete: Render Core exposes the exact package sink transport with
one idle-capacity getter and no imports or policy. A test-only checking sink
proves empty and multiple-operation streams, zero and nonzero one-read
capacity, complete group ordering, incomplete-group refusal, and independent
refusal at every Boolean call without interpreting capacity as frame or raster
acceptance; see the
[sink evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-3/render-operation-sink.md).
T1.5 is the next declaration consolidation task; T3.3 is the next independent
Render Core task.

`T3.3` is complete: the canonical `RenderRecordingSink` converts the transport
to six closed typed value events over generic caller-owned bounded storage.
The storage boundary owns staged/current representations while the sink keeps
fixed saturating attempted-call counters. Focused refusal tests prove atomic
publication, preservation of a prior current transcript, explicit clearing of
only the staged attempt, and no retained borrow, string/pointer serialization,
dynamic storage, or upward coupling in the sink; see the
[recording evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-3/recording-sink.md).
T1.5 remains the next declaration consolidation task; T3.4 is the next Render
Core verification task.

`T3.4` is complete: an independent typed-event verifier requires one leading
begin, one trailing finish, exact header operation/glyph totals, and complete
ordered non-empty glyph groups. Tests compare every header, fill, group,
resource/instance, glyph, baseline, clip, and RGB field directly and reject
count disagreement, incomplete groups, out-of-group glyphs, and nested begin
events. The audit excludes representation bytes, pointers, hashes, reflected
names, and object identity; see the
[verification evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-3/recording-verification.md).
T1.5 remains the next declaration consolidation task; T3.5 is the next Render
Core task and requires all four compiler profiles.

`T1.5` is complete. One registered
checker now builds the portable declaration module and all 17 positive and
negative fixtures with the pinned macOS dynamic, macOS static, Raspberry Pi
ARMv6, and nRF52840 Embedded Swift configurations. The corpus includes the
complete named-color, bounded-input, integer, text, modifier, custom-view, and
forbidden-convenience surface; see the
[profile compilation evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-1/declaration-profile-compilation.md).
Its optimized dynamic and static host probes verify 14 admission cases
byte-for-byte with zero mismatches, allocations, observed traps, or body
evaluations, while package tests independently cover exact bytes and traversal
order. `T2.1` is the next independent task; production adaptation in `T2.2`
continues to wait for its SPEC-006 and SPEC-007 prerequisites.

`T2.1` is complete: `GiftUISemanticCore` now owns the exact five closed render
scope values and package-only consumer view without concrete storage or a new
identity domain. A direct fixture proves count and lookup semantics, child
order, repeated layout-identity selection for transparent render-only scopes,
and nil for unknown identities or out-of-range indices; see the
[semantic render view evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-2/semantic-render-view.md).
`T2.2` is complete now that SPEC-006 and SPEC-007 are implemented. The
semantic result storage exposes its render projection from the same published
result and exact identity domain; shared payload classification maps text,
foreground, background, fixed/flexible frame clips, and structural scopes
without rendering or layout work in Semantic Core. End-to-end expansion tests
cover transparent-root mapping, modifier arity, self-mapped layout scopes, and
invalid text preservation into SPEC-007's existing invalid-scalar rejection
path; see the
[semantic result adapter evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-2/semantic-result-render-adapter.md).

`T2.3` is complete. `GiftUILayout` now owns the exact resolved text-line,
positioned-glyph, and layout-view SPI plus a result-sink adapter that exposes a
read-only projection of the successfully published SPEC-007 result. Focused
layout tests preserve semantic identity, root and per-scope bounds/clips,
occurrence-wide glyph indices, line indices/counts, exact font/glyph IDs, and
baselines, and prove nil for unknown identities and out-of-range indices; see
the
[resolved render layout evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-2/resolved-render-layout-view.md).
T2.4 is the next dependency-complete task. T3.5 remains blocked on
lowering-owned `RenderLimits`.

`T4.1` is complete and unblocks the complete value-layout work in T3.5.
`GiftUIRenderLowering` now owns the exact nonzero `RenderLimits`, bounded
`RenderProductionResult`, and identity-keyed caller-owned workspace protocol;
the package graph records the exact five production dependencies. The missing
`RenderDamageMode` declaration required by the already-approved producer
signature was also restored to its specified Render Core owner. Focused tests
cover every zero-limit rejection, exact fields/layouts, all seven result
errors, and acquire/reset/reuse semantics; see the
[render production value evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-4/render-production-values.md).
T2.4 and T3.5 are now dependency-complete; T0.2 remains active until its owner
adapter target lands.

`T2.4` is complete. The lowering test target now owns reusable direct semantic
and resolved-layout views keyed by a closed symbolic identity enum. The valid
pair separates semantic and layout counts while preserving transparent and
render-only mappings. Malformed variants cover unequal roots, duplicates,
missing in-range scopes/mappings/bounds/clips/lines/glyphs, invalid modifier
arity, prohibited text children, unknown and out-of-range lookups, and line,
line/glyph, and occurrence-wide glyph-index disagreement. A source audit
rejects pointer, hash, memory-layout, and raw-byte identity comparisons; see
the
[direct render view evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-2/direct-render-views.md).
T2.5 and T3.5 are the next dependency-complete evidence tasks.

`T2.5` is complete. A runtime lifetime test passes semantic and resolved-layout
views carrying the only strong references to their source tokens through one
generic shared-identity borrow and proves neither source is retained. The
optimized static exposure probe reports zero heap-allocation instructions in
that borrowed accessor. A registered boundary audit verifies the exact
Semantic Core, Layout, and Render Core dependency closures, direct forwarding
of both authoritative result views without adapter-owned collection/reference
materialization, and absence of normalized rendering authority in Layout or
layout authority in Render Core; see the
[render view boundary evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-2/render-view-boundaries.md).
`T3.5` is the next dependency-complete evidence task.

`T3.5` is complete. The registered four-profile value probe compiles and
records size, stride, and alignment for all eleven bounded SPEC-008 values,
enforcing the five exact sizes and every approved upper bound from LLVM IR.
Each result records its compiler path, digest and version, target, optimization
mode, complete commands, and normalized layout table; see the
[value layout profile evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-3/value-layout-profiles.md).
The ARMv6 and nRF52840 results are cross-build evidence only. `T4.2` is the
next dependency-complete implementation task.

The 2026-09-11 amendment prerequisite step is complete. Semantic Core and
Layout expose dense forward/reverse ordinal projections and immutable render
snapshot versions; Render Lowering exposes the separate four-field structural
capacity and preflight visit result; direct, lifetime, owner, and workspace
fixtures cover their exact behavior. The value-layout probe now checks all 13
bounded values on macOS dynamic/static, Raspberry Pi ARMv6, and nRF52840, with
the two non-host profiles remaining cross-build evidence only; see the
[amended contract evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-4/amended-render-contracts.md).
This prerequisite step unblocked `T4.2`.

`T4.2` is complete. `GiftUIRenderLowering` now performs one canonical
depth-first preflight over the immutable semantic and layout borrows, validates
dense ordinal inverses through preflight-only visit sets, enforces render and
structural capacities, checks every required scope/child/layout/line/glyph and
resource relation, computes checked clips and damage, and constructs the exact
header. Focused tests prove the five-scope/two-layout valid traversal, exact
operation/glyph/clip totals, repeated layout mappings, declared and observed
capacity boundaries, invalid roots/ordinals/snapshots/resources, zero emission,
and exactly one sink-capacity read after successful validation; see the
[preflight evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-4/render-preflight.md).
This completed preflight boundary unblocked `T4.3`.

`T4.3` is complete. The second canonical traversal now repeats ordinal,
identity, scope, mapping, geometry, line, glyph, resource, count-boundary, and
damage lookups without touching either workspace visit set or retaining a
proof transcript. It streams the exact background and positioned-glyph values
directly, checks snapshots immediately before `begin` and after the last
operation, distinguishes begin refusal from every post-begin invariant, and
finishes or discards exactly once. Focused tests prove the ordered typed event
sequence, unchanged preflight visit counts, one total capacity read, begin
refusal without discard, post-begin refusal with discard, and late snapshot
change with discard; see the
[streaming evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-4/render-streaming.md).
This completed streaming boundary unblocked `T4.4`.

`T4.4` is complete. The exact generic `RenderProducer.produce` entry point now
checks active-workspace reentry before any semantic, layout, metrics, or sink
access; acquires only an inactive workspace; runs preflight then streaming; and
uses one deferred reset after every successful acquisition on all exits.
Focused tests prove successful and invalid-input resets, an untouched active
attempt on reentry, inactive acquisition refusal without reset, no input/sink
access before either early return, and workspace reuse after acquired exits;
see the
[producer lifecycle evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-4/render-producer-lifecycle.md).
`T4.5` and the final incremental slice of `T0.2` are complete. The unpublished
`GiftUIRenderFailureAdapterFixture` depends only on Render Lowering and Failure
Core and maps all seven local errors to their exact SPEC-003 facts. Focused
tests exhaust the mapping, while the source and package audits prove that
lowering imports no failure module and the pure adapter contains no diagnostic,
allocation, or second-production path; see the
[failure-adapter evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-4/render-failure-adapter.md).
`T5.1` remains open. The approved amendment now supplies exact current/push/pop
operations and binds their storage to `maximumTraversalDepth`.

`T5.2` is complete independently of the unresolved T5.1 workspace-storage
seam. A direct-view golden proves source-order structural children, both opaque
backgrounds around intervening text without elimination or reordering, and one
whole positioned-glyph group per non-empty line with occurrence-wide indices;
see the
[painter-order evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-5/painter-order.md).

`T5.3` is complete. Exact-transport goldens preserve the selected instance,
glyphs, occurrence-wide ordering, baselines, foreground, and checked line clip,
while independent resource, instance, and glyph disagreements all fail during
preflight before capacity or begin. A source audit excludes raw-text, shaping,
fallback, and advance behavior; see the
[text-lowering evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-5/text-lowering.md).

`T5.4` is complete. Focused fixtures prove exact unclamped fill bounds with a
checked partial final clip, omission for an off-surface empty final clip, and
explicit complete-surface/root-intersection/complete-surface damage across
fresh attempts without frame history; see the
[clip/damage evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-5/clip-damage.md).

Implementation review found two approval blockers. The amendment now defines
the missing foreground-stack operations and replaces impossible arithmetic
fault injection with defensive branch and direct mapping evidence while
preserving the closed error and precedence order. The maintainer explicitly
approved that amendment and resumed implementation on 2026-09-11; see the
[implementation review](../../Tests/ContractFixtures/SPEC008/Evidence/implementation-blockers.md).

The next work is the T4.1/T4.4 foreground-workspace follow-up, then T5.1 and
T5.5. Milestone 6 entry conditions remain unmet until those tasks complete.

The T4.1/T4.4 amendment follow-up is complete. The exact workspace protocol and
both maintained fixture workspaces now implement bounded current/push/pop
foreground storage, equality and refusal behavior, high-water accounting, and
acquire/reset clearing; see the
[foreground-workspace evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-4/foreground-workspace.md).
`T5.1` is complete. Streaming now initializes and verifies the root foreground
around `begin`/`finish`, uses exact caller-owned LIFO push/pop operations for
modifier scopes, and reads text paint only from `currentForeground`. A nested
foreground/background plus sibling golden proves innermost resolution, outer-
before-inner backgrounds, sibling restoration, exact high-water, and reset;
see the
[foreground-semantics evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-5/foreground-semantics.md).
`T5.5` is the next dependency-complete task.

`T5.5` is complete. A layered fault matrix proves every simultaneously
constructible precedence pair; all pre-begin failures avoid begin/discard,
begin refusal stays idle, every post-begin sink or foreground-stack refusal
discards and resets once, and recording discard preserves prior current output.
The audit covers all defensive checked-intersection branches and the direct
arithmetic fact mapping without invalid rectangle construction; see the
[failure-precedence evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-5/failure-precedence.md).
Milestone 5 is complete and `T6.1` is the next dependency-complete task.

`T6.1` is complete. Five canonical manifest rows and their executable Swift
goldens cover nested styles and sibling restoration, source-order/ZStack
painter order, exact multi-line text transport with empty-line omission,
partial unclipped backgrounds, off-surface and zero-area omission, unchanged
nested clips, exact RGB values, and both explicit damage modes. The registered
corpus audit checks every field, token, total, lifecycle, and source-test link;
see the
[canonical corpus evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-6/canonical-corpus.md).
`T6.2` is the next dependency-complete task.

`T6.2` is complete. The registered integration audit ties the complete
UTF-8/`Int32` matrix and zero-allocation declaration probe to actual invalid
literal preservation through semantic expansion, then to production layout
rejection before sink begin/publication and before the gated render call. See
the
[text declaration integration evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-6/text-declaration-integration.md).
`T6.3` is the next dependency-complete task.

`T6.3` is complete. The production entry point now runs the full direct-view
mismatch family and seven additional independent one-over capacity rows, all
with exact pre-begin lifecycle assertions. The registered audit joins these
with the existing precedence, ordinal-visit, snapshot, refusal, reentry,
reuse, arithmetic, owner-mapping, and atomic-recording evidence; see the
[complete failure corpus](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-6/failure-corpus.md).
`T6.4` is the next dependency-complete task.

`T6.4` is complete. Direct-index semantic/layout conformers count every view
access and render-identity comparison across both traversals and establish the
exact affine models through 16 occurrences and glyphs. The maintained concrete
static producer probe and whole-module Render Lowering SIL contain zero heap
allocation instructions; target IR exposes finite render/structural capacity,
workspace layout, and exact foreground-slot bytes. Timing, recursive-frame
high-water, linked-section, and link-map methods are registered for final
four-profile collection without claiming Signal Analyzer or connected-target
measurements; see the
[render resource instrumentation evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-6/render-resource-instrumentation.md).
`T6.5` is the next dependency-complete task.

`T6.5` is complete. Every canonical case runs through distinct recording,
fixture-dynamic, and fixture-static identity, visit-set, and foreground-stack
representations. Complete results, header-bearing ordered value events, real
SPEC-003 adapter mappings, both capacity families, limits, and foreground
high-water compare field for field, and a source audit proves all three paths
join one generic `GiftUIRenderLowering.RenderProducer.produce` call; see the
[profile equivalence evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-6/profile-equivalence.md).
Milestone 6 is complete and `T7.1` is the next dependency-complete task.

`T7.1` is complete. The governed graph and source-import audit enforce Render
Core's exact two dependencies, Render Lowering's exact five dependencies and
sole semantic/layout join, prohibited-owner exclusion, backend consumer
isolation, unique symbol ownership, and the absence of internal rendering SPI
re-export from `GiftUI`; see the
[package boundary evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-7/package-boundaries.md).
`T7.2` is the next dependency-complete task.

`T7.2` is complete. The governed manifest enumerates the exact title,
subtitle, ruler/channel/level/control labels, bounded ruler values, all four
status texts, a nonempty acquisition error, and every selected opaque
foreground/background role. Its maximum hierarchy accounts for 62 semantic
and 32 layout scopes, 21 text lines, 139 glyphs, 30 operations, and exact
traversal/clip/foreground high-water within common render, structural, and
sink limits; see the
[Signal Analyzer render-surface evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-7/signal-analyzer-render-surface.md).
`T7.3` is the next dependency-complete task.

`T7.3` is complete. Registered executable fixtures cover SPEC-009's
nonescaping one-shot sink/envelope and post-return poisoning, SPEC-013's three
profile paths through one shared lowering call, and SPEC-014-side ordered
Render Core consumption. The audit rejects retained operation/resource values
and semantic, layout, style, profile, disposition, capability, or raster
authority in consumers; see the
[consumer seam evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-7/consumer-seams.md).
`T7.4` is the next dependency-complete task.

`T7.4` is complete. The fail-closed coexistence audit keeps Canvas/stroke cases
out of the SPEC-008 criterion set and base transcript, preserves the generic
primitive visitor and additive Render Core seams named by approved SPEC-012,
and executes the exact ordinary transcript with no Canvas declaration. The
combined producer and its future zero-Canvas entry-point comparison remain
owned by SPEC-012 T5.3; see the
[Canvas coexistence evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-7/canvas-coexistence.md).
`T7.5` is the next dependency-complete task.

`T7.5` is complete. A visual Button projection executes the canonical
structural, red-foreground, blue-background, and two-glyph label path and
proves the fill precedes the label glyph group. Its companion ownership fixture
keeps disabled state, hit geometry, action identity, pointer capture, dispatch,
and hit-map state excluded from semantic render views and normalized operations;
see the
[Button coexistence evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-7/button-coexistence.md).
Interaction implementation and conformance remain in SPEC-011's plan. `T8.1`
is the next dependency-complete task.

`T8.1` is complete. The macOS dynamic top-level gate passed governance,
tooling, formatter lint, driver registration, all 388 Swift tests, and every
registered contract driver. Direct declaration and optimized value-layout
checks also passed for macOS static, Raspberry Pi ARMv6, and nRF52840 Embedded:
all profiles accept/reject the same 17 compile fixtures and meet all 13 layout
bounds, including exact 8-byte `RenderWorkspaceCapacity`. SPEC-008 remains
registered for all four profiles; see the
[repository and compiler-surface evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/repository-gate.md).
`T8.2` is the next dependency-complete task.

`T8.2` is complete. All four exact standalone commands passed with shared run
ID
`c98c420834f90820d655316ac470fad86d1d375b-4c33a13788ae2679` and recorded
compiler/SDK/target/optimization identity, full command and input-digest
inventories, declaration and value-layout results, exact Signal Analyzer
limits and high-water, logical and concrete finite workspace, stack high-water,
zero allocation, macOS timing samples, linked-section deltas, symbols, images,
and linker maps. ARMv6 and nRF results are explicitly cross-build/inspection
only; the nRF ELF proves the hard-float VFP ABI and no board was flashed. The
acceptance rows remain fail-closed for work assigned to T8.3 through T8.5; see
the
[four-profile evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/four-profile-evidence.md).
`T8.3` is the next dependency-complete task.

`T8.3` is complete. Reports from clean revision
`7b4eb21a68eb6240824c155f8eec0c22e1ed6aa4` share one input digest and compare
identically for the complete canonical and failure corpora, owner mappings,
ordered recording values, identity and resource evidence, 17 declaration
results, 13 value layouts, limits, workspace, stack, and high-water. Both
macOS profiles provide host execution; Raspberry Pi remains cross-build and
inspection only and makes no execution, framebuffer, input, deployment, or
hardware claim. See the
[three-profile comparison](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/three-profile-comparison.md).
`T8.4` is the next dependency-complete task.

`T8.4` is complete. The clean nRF52840 report compiles the complete declaration
and canonical corpus surface, links the concrete production entry into a
Zephyr ELF, proves all 13 target layouts, zero optimized allocation
instructions, and finite workspace, and records symbols, baseline/candidate
maps, and linked-section deltas. ELF inspection proves ARMv7E-M, VFPv4-D16,
single-precision hard-float use, and VFP-register argument passing. This is
cross-build inspection only; no connected target was used or flashed. See the
[nRF render inspection](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/nrf-render-inspection.md).
`T8.5` is the next dependency-complete task.

`T8.5` is complete. Every task and RD row now has a disposition, the plan is
`completed`, and the linked
[collecting conformance report](../conformance/spec-008-conformance.md) maps
RD-001 through RD-011 exactly once. The review records no deviation or approved
exception and keeps all hardware-free evidence distinct from connected-target
claims. It requests conformance review and explicit human authorization; it
does not change SPEC-008 from `implementing`.

Plan completion means every task has a recorded disposition; it does not mean
SPEC-008 is `implemented`. The collecting conformance report requests review
and the separate human-authorized transition.
