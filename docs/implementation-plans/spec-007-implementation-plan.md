---
spec: SPEC-007
feature: giftui-mvp-architecture
title: SPEC-007 Implementation Plan
status: active
owners:
  - codex
created: 2026-09-05
updated: 2026-09-11
related_design_notes:
  - ../implementation-designs/spec-007-bounded-layout-attempt.md
conformance_report: null
related_future_work:
  - FW-001
  - FW-002
  - FW-005
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-007 Implementation Plan

> This ready plan derives work from the approved Proposal-Based Layout
> Contract. It orders implementation and evidence but does not amend the
> proposal, measurement, placement, canonical text, clipping, identity,
> failure, resource, profile, or module contracts owned by that Specification
> and its authoritative dependencies.

## Authority and Scope

The governing contract is approved
[SPEC-007](../specs/spec-007-layout.md). Its authority chain is accepted
[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md),
approved [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md),
[RFC-003](../rfcs/rfc-003-deterministic-text-rendering-architecture.md), and
[RFC-010](../rfcs/rfc-010-layout-semantic-core-adapter-boundary.md), and
accepted [ADR-005](../adrs/adr-005-semantic-layout-render-boundary.md),
[ADR-006](../adrs/adr-006-shared-semantics-runtime-profiles.md),
[ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md),
[ADR-009](../adrs/adr-009-checked-integer-geometry.md),
[ADR-021](../adrs/adr-021-canonical-text-geometry.md),
[ADR-023](../adrs/adr-023-exact-font-resource-identity.md), and
[ADR-032](../adrs/adr-032-semantic-core-owned-layout-input.md).

Approved [SPEC-002](../specs/spec-002-portable-foundation.md) owns checked
`Int32` geometry, compiler and SDK identities, and the four-profile evidence
conventions. Approved
[SPEC-003](../specs/spec-003-failure-outcomes-and-containment.md) owns failure
facts and outcomes. Approved [SPEC-005](../specs/spec-005-text-resources.md)
owns the validated canonical metrics view and exact text-resource identities.
[SPEC-006](../specs/spec-006-declarative-view-semantics.md) owns expansion,
structural identity, modifier order, and the typed traversal seam. Its
primitive-with-content amendment was explicitly reapproved on 2026-09-10;
affected SPEC-007 work now waits only for the authorized implementation. This
plan consumes those contracts without duplicating their owners or changing
their acceptance criteria.

The [MVP Scope](../MVP_SCOPE.md) requires the substantially shared Signal
Analyzer Presentation to express vertical, horizontal, and overlay layout,
flexible space, explicit spacing and alignment, padding, fixed/constrained/
expanding frames, and deterministic text geometry across macOS dynamic,
macOS static, Raspberry Pi 1/Linux dynamic, and nRF52840 static
configurations. SPEC-007 is the Rank 1 layout delivery and the backend-free
geometry proof for that requirement. It does not authorize rendering, input
dispatch, state, runtime-profile production storage, backend behavior,
platform integration, deployment, or connected-hardware work.

## Current Repository State

- `Sources/GiftUI/GiftUI.swift` implements SPEC-002 geometry and checked
  arithmetic. `Sources/GiftUI/DeclarativeView.swift` contains the in-progress
  SPEC-006 declaration and traversal surface, but no layout declarations,
  layout primitive payloads, or layout modifiers exist.
- `Sources/GiftUISemanticCore/GiftUISemanticCore.swift` currently imports
  `GiftUI` only. SPEC-006's bounded expansion, identities, complete semantic
  result, and SPEC-007's borrowed `SemanticLayoutView` have not yet landed.
- `GiftUITextResources` and the concrete reference text-resource package are
  present with validated canonical metric, mapping, and glyph identity seams.
  SPEC-005's implementation plan is completed, so SPEC-007 must reuse those
  values and views rather than introduce a parallel font identity or metrics
  source.
- `Package.swift` has no `GiftUILayout` target, layout unit-test target, or
  layout/failure owner-adapter fixture. The exact required
  `GiftUILayout -> GiftUISemanticCore -> GiftUI` and
  `GiftUILayout -> GiftUITextResources -> GiftUI` edges are therefore absent.
- There is no `Tests/ContractFixtures/SPEC007/` corpus, layout recording sink,
  failure-mapping fixture, allocation/borrow/stack probe, Signal Analyzer
  approval fixture, or `scripts/contracts/run-spec-007.sh`.
  `scripts/contracts/driver-registry.tsv` consequently has no SPEC-007 row.
- SPEC-002 through SPEC-006 provide reusable conventions for target allow
  lists, positive and negative compile fixtures, canonical profile-normalized
  transcripts, owner-adapter mapping, fail-closed fixture manifests,
  allocation interposition, cross-build resource inspection, and explicit
  registration with `scripts/test.sh`.
- SPEC-006 is `approved`, including the primitive-with-content amendment. Its
  previously implemented public builder surface remains present, but stack
  declarations and semantic integration requiring the amended traversal
  operation must wait for its authorized implementation.
  Contract-local layout values, algorithms, direct recording views, and
  evidence schemas that do not consume that operation may continue.
- Existing proof-of-concept layout code is no longer maintained source. Its
  recursive algorithm is evidence only; migration must start from SPEC-002's
  clean baseline and must not restore a parallel geometry, text measurement,
  semantic graph, or runtime-owned layout path.

## Readiness Review

**Reviewed:** 2026-09-05

**Disposition:** Ready. SPEC-007 is approved, all linked Proposal/RFC/ADR
gates are authoritative, and all nine acceptance criteria map to ordered work
and reproducible evidence below. The unfinished SPEC-006 implementation is an
explicit task dependency rather than an unresolved decision: milestones that
consume its identity and semantic result wait for their owner, while layout-
local declarations, values, algorithms, text fixtures, and harness work may
proceed. No `docs/features.yaml` update is required because implementation
records are not registered there and the feature already reports the
implementation stage.

**Amendment note:** On 2026-09-10, `T1.2` exposed the missing SPEC-006
primitive-with-content operation, and the resulting amendment was explicitly
reapproved. The SPEC-007 contract remains approved; `T1.2`, `T1.5`, and
production semantic integration may resume as the amended SPEC-006 operation
is implemented with evidence.

If the pinned compiler cannot express the approved generic borrowing entry
point or exact identity-preserving sink without retention, if static layout
requires a second complete semantic graph or heap allocation, or if the
specified linear two-phase result cannot fit the approved value-size bounds,
the affected task returns to Specification or architecture review. The plan
must not add an adapter identity, fallback text metrics, backend measurement,
runtime-owned layout semantics, a compatibility shim, or relaxed capacity and
atomicity behavior.

## Task Dependencies and Affected Surfaces

Milestone numbers define the default execution order. The table below makes
the exceptions and external gates explicit; a task may start only after every
listed prerequisite is satisfied.

| Work | Prerequisites | Primary affected surfaces | Parallel boundary |
| --- | --- | --- | --- |
| `T0.1`-`T0.4` | Approved SPEC-007 authority chain | `Tests/ContractFixtures/SPEC007/`, `Package.swift`, `scripts/contracts/`, SPEC-002 graph fixtures | Fixture schemas, migration inventory, and driver scaffolding may proceed together after `T0.1`; exact-set graph edits land atomically with their first compiling targets |
| `T1.1`-`T1.4` | `T0.2`; existing SPEC-006 sealed payload/traversal declarations | `Sources/GiftUI/`, `Tests/GiftUITests/`, SPEC-007 public compile fixtures | Declaration families may proceed in parallel because SPEC-007 fixes their complete API and payload meaning |
| `T1.5`, `T2.1`-`T2.5` | Relevant `T1.*`; SPEC-006 complete-result, identity, and producer tasks where named below | `Sources/GiftUI/`, `Sources/GiftUISemanticCore/`, `Tests/GiftUISemanticCoreTests/`, SPEC-006/SPEC-007 integration fixtures | Direct malformed/recording views may proceed before production-result adaptation; production and profile-equivalence claims wait for SPEC-006 |
| `T3.1`-`T3.5` | `T0.2`, `T2.2`; exact identity type and text-metrics view available | `Sources/GiftUILayout/`, `Tests/GiftUILayoutTests/`, layout/failure owner-adapter fixture | Local values may proceed beside semantic integration; acquisition, validation, lifecycle, and mapping then execute in task order |
| `T4.1`-`T4.5` | `T3.1`-`T3.4` | `Sources/GiftUILayout/`, `Tests/GiftUILayoutTests/`, non-text golden fixtures | Stack, spacer, overlay, padding, and frame implementations may be divided only after shared checked helpers and sink lifecycle are fixed |
| `T5.1`-`T5.4` | `T3.1`-`T3.4`, `T4.1`; completed SPEC-005 production contracts | `Sources/GiftUILayout/`, `Tests/GiftUILayoutTests/`, canonical text fixtures | Text decoding/wrapping may proceed beside later non-text algorithms, but combined placement waits for the shared checked geometry path |
| `T6.1`-`T6.5` | `T2.*`, `T3.*`, `T4.*`, `T5.*` as consumed by each corpus row | SPEC-007 recording, failure, allocation, lifetime, and normalized-profile fixtures | Focused success and failure rows may run independently; the complete cross-profile comparison waits for all rows |
| `T7.1`-`T7.3` | `T1`-`T6`; SPEC-006 complete semantic result; SPEC-008 public `Text` only for the full client fixture | `Package.swift`, dependency fixtures, Signal Analyzer approval fixture, resource probes | Boundary audits may run before the full application fixture; production fixture and resource claims wait for their prerequisite owners |
| `T8.1`-`T8.5` | All applicable implementation and fixture tasks complete | repository formatter/gates, four profile reports, this plan, `docs/conformance/spec-007-conformance.md` | Profile runs may execute independently after the common corpus is frozen; comparison and conformance preparation consume all four reports |

No task changes `docs/features.yaml` or SPEC-007's lifecycle status merely by
starting. When production implementation actually begins, the separate
authorized progress update changes SPEC-007 to `implementing` and this plan to
`active` under the repository lifecycle rules.

## Acceptance-Criterion Matrix

The criterion text remains authoritative in SPEC-007. Every criterion appears
once below and maps to implementation tasks and reproducible evidence.

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `LY-001` — Exact Rank 1 declarations/constants and layout-time rejection of every preserved invalid value | `T1.1`-`T1.5`, `T4.1`, `T8.1` | Public-interface, positive/negative declaration, payload-preservation, and four-profile compile reports | pending |
| `LY-002` — Exact borrowed Semantic Core view, vocabulary, identity, flattening, ordering, text access, and index behavior | `T2.1`-`T2.5`, `T6.1`, `T8.2` | Semantic-view API audit, direct recording corpus, malformed-view corpus, borrow probe, and no-second-graph report | pending |
| `LY-003` — Exact stack, spacer, alignment, padding, frame, proposal, placement, and clipping behavior | `T4.1`-`T4.5`, `T6.2`, `T8.2` | Table-driven golden layout transcripts, including minimum/fixed 100 under parent 50 | pending |
| `LY-004` — Exact canonical text IDs, counts, bounds, baselines, advances, positions, and clips | `T5.1`-`T5.4`, `T6.3`, `T8.2` | SPEC-005-backed canonical text corpus and checked-geometry transcripts | pending |
| `LY-005` — Exact local errors/facts, acquisition and discard lifecycle, and atomic publication | `T3.1`-`T3.5`, `T6.4`, `T8.2` | Limit, malformed-input, overflow, reentry, lookup-failure, sink-refusal, and owner-mapping matrix | pending |
| `LY-006` — Equal recording/dynamic/static meaning with zero static allocation and no retained borrow | `T2.4`, `T3.4`, `T6.1`, `T6.5`, `T8.2`-`T8.4` | Canonical normalized comparisons, allocation interposer, lifetime probe, and graph/materialization audit | pending |
| `LY-007` — Exact import graph and sibling separation | `T0.2`, `T2.5`, `T7.1`, `T8.1` | Package graph, target allow-list, import-negative fixtures, and source dependency scan | pending |
| `LY-008` — Signal Analyzer approval fixture under the five exact limits and complete admitted layout surface | `T7.2`, `T7.3`, `T8.2` | Approval transcript, exact limits and high-water counts, and surface-coverage audit | pending |
| `LY-009` — Four exact driver commands and complete owned-value/resource/ELF evidence without hardware claims | `T0.3`, `T7.3`, `T8.2`-`T8.4` | Registered per-profile reports, value layouts, allocation/workspace/stack/link evidence, and nRF hard-float ELF inspection | pending |

## Milestones and Tasks

### Milestone 0: Freeze Scope, Dependency Boundaries, and Evidence Schemas

**Entry conditions:** SPEC-007 remains `approved`; PROPOSAL-003 remains
`accepted`; linked RFCs remain `approved`; linked ADRs remain `accepted`; and
SPEC-002, SPEC-003, SPEC-005, and SPEC-006 remain approved authority.

**Exit evidence:** The exact target graph, fixture inventory, report schema,
migration baseline, and registered fail-closed driver skeleton exist before
layout behavior is claimed.

- [x] `T0.1` — Create `Tests/ContractFixtures/SPEC007/` with an ordered
      fixture manifest, canonical source-token transcript schema, normalized
      result and failure schemas, acceptance/evidence registry, and README.
      Label host execution, cross-build/inspection, simulator, and connected-
      hardware evidence distinctly; no SPEC-007 task requires deployment,
      remote access, or flashing.
- [x] `T0.2` — Add `GiftUILayout`, its focused unit-test target, and a narrowly
      named layout/failure owner-adapter fixture to `Package.swift` only when
      their first compiling sources land. `GiftUILayout` depends exactly on
      `GiftUI`, `GiftUISemanticCore`, and `GiftUITextResources`; the adapter
      depends on layout and `GiftUIFailureCore`. Update SPEC-002's exact target
      allow-list and dependency fixtures atomically, including reverse,
      failure-core, capability, render, runtime, backend, platform, driver,
      OS/RTOS, HAL, and hardware import negatives, plus a portable-`GiftUI`
      non-re-export check.
- [x] `T0.3` — Create `scripts/contracts/run-spec-007.sh --profile <profile>`
      for exactly `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
      `nrf52840-embedded`; register it explicitly in
      `scripts/contracts/driver-registry.tsv`. Initially fail closed for every
      missing fixture, exact compiler/target/SDK/optimization identity,
      repository revision and dirty state, complete command, value-layout
      record, limit/high-water result, allocation count, workspace and stack
      result, linked-code delta, no-second-graph proof, or required ELF
      inspection.
- [x] `T0.4` — Inventory proof-of-concept and repository layout surfaces,
      including recursive measurement, floating or unchecked geometry,
      runtime-local layout nodes, backend measurement, font fallback,
      retained semantic/layout graphs, and old stack/frame/padding APIs.
      Assign adopt, adapt, replace, retire, or already-absent dispositions and
      add regression scans that reject a second implementation path.

### Milestone 1: Implement the Rank 1 Client Declaration Surface

**Entry conditions:** Milestone 0 fixes the package and compile-fixture
boundaries. SPEC-006's sealed primitive and modifier payload protocols remain
the only declaration-to-semantic path.

**Exit evidence:** Portable clients compile every exact layout declaration
with only `import GiftUI`, invalid values remain representable where required,
and declaration initialization performs no layout.

- [x] `T1.1` — Implement `HorizontalAlignment`, `VerticalAlignment`,
      `Alignment`, `EdgeInsets`, `EdgeSet`, and `FrameLimit` in `GiftUI` with
      the exact public access, cases, constants, raw bits, initialization,
      `Equatable`/`OptionSet`/`Sendable` conformances, and no widened API.
      Prove the reserved edge bits remain representable and `EdgeInsets`
      alone returns `nil` for any negative field.
- [x] `T1.2` — Implement `VStack`, `HStack`, `ZStack`, and `Spacer` with exact
      generic `View` conformances, defaults, builder behavior, payload
      traversal, and preserved invalid spacing/minimum values. Their bodies
      remain unevaluated primitives and initialization performs no measuring,
      semantic expansion, allocation, or capability/backend lookup.
- [x] `T1.3` — Implement the three `padding` declarations and both `frame`
      overloads as ordered SPEC-006 typed modifier wrappers. Preserve every
      negative optional dimension, negative finite `FrameLimit.points`,
      invalid min/max relation, empty/reserved edge set, all-`nil` frame, and
      source-call order for layout-time validation rather than clamping,
      normalizing, trapping, merging, or commuting modifiers.
- [x] `T1.4` — Add public compile fixtures for all constants, defaults,
      overloads, custom views, view-returning properties/functions, fixed
      builder arities, and mixed modifier chains using only `import GiftUI`.
      Add runtime declaration-preservation probes for every invalid scalar,
      relation, and reserved edge bit, plus source/API scans that reject
      layout execution or forbidden imports in `GiftUI`.
- [x] `T1.5` — Extend the SPEC-006 typed primitive/modifier transcript corpus
      with every layout payload. Prove exact payload values, outer/inner
      modifier scope identity and source order, primitive child order, and no
      new client-visible traversal witness. This integration waits only for
      the corresponding SPEC-006 traversal operations, not for a runtime or
      renderer.

### Milestone 2: Expose the Borrowed Semantic Layout View

**Entry conditions:** SPEC-006 supplies exact structural/modifier identities,
bounded complete semantic results, and the fixed typed traversal seam. Until
then, direct fixture views may define layout tests, but no production
Semantic Core adapter or profile-equivalence claim may be completed.

**Exit evidence:** Semantic Core exposes exactly one read-only, identity-
preserving, nonescaping layout-facing view over a successful result; recording,
fixture-dynamic, and fixture-static producers have equal observable meaning.

- [x] `T2.1` — Implement package `SemanticLayoutPrimitive` and
      `SemanticLayoutModifier` with exactly the closed cases and payloads from
      SPEC-007. Extend semantic expansion so layout-neutral occurrences use
      `.proxy`, approved layout-neutral modifiers alone use `.passthrough`,
      and unknown/unapproved modifiers fail instead of silently passing
      through.
- [x] `T2.2` — Implement the package `SemanticLayoutView` protocol in
      `GiftUISemanticCore` with the exact associated identity, root/scope
      counts, primitive/child/modifier/text accessors, `UInt16` indices, and
      borrowed content meaning. Do not expose actions, generations, models,
      state storage, runtime nodes, render data, backend objects, or another
      identity representation.
- [x] `T2.3` — Adapt the complete successful SPEC-006 semantic result to this
      view without copying a second complete graph. Implement transparent
      structural flattening in canonical source order; require the semantic
      root and every modifier scope to resolve to exactly one layout child;
      preserve exact modifier-scope and ordinary action-bearing occurrence
      identity; and expose text scalars without retaining the source.
- [x] `T2.4` — Build recording, fixture-dynamic, and fixture-static semantic
      views over one canonical corpus. Prove equality of occurrence kinds,
      child/modifier order, text scalars, identity relations, in-range and
      out-of-range behavior, and malformed-view injection while explicitly
      avoiding comparison of profile-private raw identity bytes.
- [x] `T2.5` — Add lifetime, allocation, and dependency probes proving the
      layout borrow cannot escape, Semantic Core imports no layout, static
      exposure allocates zero heap bytes, and no complete adapter-owned node
      array or runtime-specific input path exists. Add negative surface
      fixtures for action callables/generations, model or state storage,
      runtime nodes, render data, backend objects, platform/target identity,
      and unrestricted existentials. Inspect the embedded source and image
      closure for prohibited references.

### Milestone 3: Implement Bounded Layout Values, Workspace, and Atomic Output

**Entry conditions:** The target graph exists and direct recording views can
exercise exact identities. Production Semantic Core integration may follow
when Milestone 2's SPEC-006-owned prerequisites land.

**Exit evidence:** One generic synchronous layout entry point enforces exact
limits, workspace/sink acquisition, deterministic local errors, and atomic
publication without retaining input.

The caller-owned storage, generic entry, and atomic lifecycle use the
replaceable realization described by the
[Bounded Layout Attempt design note](../implementation-designs/spec-007-bounded-layout-attempt.md).

- [x] `T3.1` — Implement `LayoutLimits`, `LayoutSummary`, `LayoutError`, and
      `LayoutResult` with exact access, raw values, nonzero-limit initializer,
      `Equatable`/`Sendable` behavior, and the specified size ceilings. Add
      compile-time/source audits excluding references, existentials, strings,
      closures, and unbounded collections from these values.
- [x] `T3.2` — Define the package `LayoutResultSink` and one generic layout
      entry point borrowing `SemanticLayoutView` and validated
      `CanonicalTextMetricsView`, sharing the exact identity with the sink,
      and exclusively borrowing caller-owned workspace and sink. Define the
      profile-private fixture workspaces with all five preflight capacities,
      bounded identity-indexed measurement/placement storage, and explicit
      acquire/reset operations.
- [x] `T3.3` — Implement checked global scope/depth/scalar/line/glyph counters,
      equality-at-limit success, one-over pre-reservation failure, declared
      scope-count agreement, preflight agreement between all five limits and
      reported workspace capacities, semantic in-range lookup validation,
      Unicode and public-payload validation, and the exact first-failure
      detection order. Prove reservations fail before the prohibited staging
      or lookup identified by the contract.
- [x] `T3.4` — Implement the idle/acquired/measuring/begun/staging/published or
      discarded/reset lifecycle. Check reentry before all input inspection;
      exercise independently active workspace, active sink, and both-active
      reentry; call `begin` only after complete measurement/count validation;
      treat `begin == false` as capacity exhaustion without `discard`; stage
      in canonical depth-first order; call `discard` exactly once after any
      post-begin stage or publish refusal; reset only state acquired by the
      current attempt; publish once; and leave no partial current output or
      retained borrow on any failure.
- [x] `T3.5` — Implement the separate fixture owner adapter mapping each local
      error to its exact SPEC-003 fact, including foundation-origin arithmetic
      overflow and safety-not-proven invariant failures. Prove invalid limits
      map only at their first host/runtime owner and that layout itself does
      not import `GiftUIFailureCore` or diagnostics.

### Milestone 4: Implement Proposal Measurement, Placement, and Logical Clips

**Entry conditions:** Milestone 3 provides bounded per-scope storage and an
atomic recording sink. No backend, render, capability, or runtime-profile
implementation participates.

**Exit evidence:** Golden fixtures reproduce every normative non-text layout
rule with checked arithmetic, exact source ordering, bounds, clips, and hit
geometry.

- [x] `T4.1` — Implement shared checked helpers for independent proposal caps,
      ideal/resolved sizes, origins, centering division toward zero, alignment
      offsets, cursor/gap arithmetic, constraint resolution, and rectangular
      intersection including empty intersections at the greater minimum
      edges. Reject every invalid declaration before producing output.
- [x] `T4.2` — Implement `.proxy`, `VStack`, and `HStack` measurement and
      placement for zero through five children, absent/present axes, checked
      spacing totals, explicit alignment, oversized children, zero sizes, and
      main-axis proposal underflow. Measure and place each scope once.
- [x] `T4.3` — Implement direct unmodified flexible-spacer recognition,
      minimum contribution, absent-proposal behavior, equal quotient and
      source-order one-unit remainder distribution, cross-axis filling, and
      wrapped/outside-stack ordinary zero-size behavior. Never compress a
      child or assign negative space.
- [x] `T4.4` — Implement `ZStack` shared proposals, maximum ideal size,
      independent-axis alignment, source-order placement, and no added clip.
      Implement all padding forms with checked proposal subtraction floored
      at zero, checked ideal expansion, unchanged inherited clip, and
      translated child origin even when capped.
- [x] `T4.5` — Implement fixed and flexible frame algorithms independently per
      axis, including nil/min/finite max/infinity proposals and requests,
      alignment, all-nil passthrough behavior, parent caps, child overflow,
      and frame-added clip intersections. Golden-test ordered padding/frame
      chains and the exact minimum width 100 and fixed width 100 requests
      under a parent width of 50.

### Milestone 5: Implement Canonical Text Geometry

**Entry conditions:** SPEC-005's validated metrics view and concrete reference
package remain authoritative and available; Milestones 3 and 4 provide
checked storage, proposal, placement, and clipping behavior. Public `Text`
remains owned by SPEC-008 and is not invented here.

**Exit evidence:** A backend-free canonical corpus produces exact positioned
text from Semantic Core scalar access and the sole validated MVP instance.

- [ ] `T5.1` — Implement scalar decoding in source order, exact instance-zero
      lookup, CR/LF/CRLF handling, replacement mapping, glyph metric lookup,
      and invalid-scalar/post-validation invariant distinctions. Reserve the
      complete scalar, line, and positioned-glyph counts under global limits.
- [ ] `T5.2` — Implement left-to-right advance wrapping for absent, positive,
      and zero widths; keep an over-wide first glyph; preserve empty, leading,
      trailing, and consecutive-break lines; and compute checked line widths,
      text ideal/resolved size, baseline progression, and line gaps exactly.
- [ ] `T5.3` — Translate every line bound and glyph baseline to absolute root
      coordinates; stage zero-based line indices and source-order glyph
      indices excluding breaks; derive text, line, and glyph clips through the
      exact intersections; and stage all logical content even when a clip is
      empty or height-only clipping hides it.
- [ ] `T5.4` — Build SPEC-005-backed goldens for ASCII, degree sign,
      replacement glyph, CR/LF/CRLF, empty content, all wrapping modes,
      zero-width, first/later baselines, line gaps, trailing/consecutive empty
      lines, over-wide first glyphs, clipping, height caps, and every checked
      arithmetic site. Assert exact resource/instance/glyph identities,
      advances, bounds, counts, baselines, positions, and clips.

### Milestone 6: Complete the Recording Oracle and Failure Corpus

**Entry conditions:** Layout measurement, placement, text, and atomic sink
behavior are individually testable. Fixture roles use canonical symbolic
tokens, not profile-private raw identity bytes or addresses.

**Exit evidence:** One complete corpus compares successful and failed attempts
across direct recording, fixture-dynamic, and fixture-static views and proves
linear work, exact staging order, reuse, and no retained input.

- [ ] `T6.1` — Implement the recording sink's staged/current generations and
      canonical event vocabulary for begin, scope, line, glyph, publish, and
      discard. Cross-check every summary count, root bounds, observed depth,
      identity relation, exact depth-first stage order, and text-event locality
      against the published transcript.
- [ ] `T6.2` — Assemble the complete stack/spacer/alignment/padding/frame/
      proposal/clip corpus with deterministic expected tokens and numeric
      fields. Cover every table row in SPEC-007's Testing Requirements and
      derive hit geometry as bounds or checked bounds/clip intersection
      without associating actions or dispatch policy.
- [ ] `T6.3` — Add the complete canonical text corpus to the same event
      oracle, verifying that text lines precede their glyphs and that no
      raster, backend, platform, capability, or native-font fact affects any
      value.
- [ ] `T6.4` — Fault-inject every invalid declaration, arithmetic overflow,
      independent and coincident capacity edge, scope-count mismatch,
      malformed in-range access, invalid Unicode scalar, post-validation text
      lookup failure, begin/stage/publish refusal, and every independently
      active workspace/sink nested-reentry permutation. Prove exact local and
      mapped failure, detection order, whether `begin` was called, exact
      discard/reset counts, prior-current preservation, untouched active
      outer objects, and clean object reuse.
- [ ] `T6.5` — Run the whole corpus through recording, fixture-dynamic, and
      fixture-static semantic views. Compare canonical source-token
      transcripts, identity equality relations, numeric fields, summaries,
      and mapped facts event by event; instrument `O(n + g)` work, zero static
      heap allocation, bounded call depth, and nonescaping semantic/text
      borrows.

### Milestone 7: Integrate the Signal Analyzer Fixture and Boundary Audits

**Entry conditions:** Milestones 1-6 pass locally; SPEC-006 supplies its
complete successful semantic result; the fixture uses only approved public
declarations available from SPEC-006, SPEC-007, and, when required for public
text syntax, SPEC-008.

**Exit evidence:** The exact Signal Analyzer approval fixture fits its contract
limits, every module boundary is mechanically enforced, and the driver can
collect all four profiles without a backend or hardware claim.

- [ ] `T7.1` — Complete package graph and source audits proving
      `GiftUILayout -> GiftUISemanticCore -> GiftUI` and
      `GiftUILayout -> GiftUITextResources -> GiftUI`, no reverse edge,
      `GiftUIRenderCore` sibling separation, no `GiftUI` re-export of layout
      or Semantic Core, and no imports or references to runtime profiles,
      failure core from layout, capabilities, backends, platforms, drivers,
      OS/RTOS, HAL, hardware, or native font/layout APIs.
- [ ] `T7.2` — Implement the Signal Analyzer approval fixture with exactly
      `maximumScopes: 512`, `maximumDepth: 64`,
      `maximumTextScalars: 4096`, `maximumTextLines: 512`, and
      `maximumPositionedGlyphs: 4096`. Exercise vertical, horizontal, overlay,
      spacer, zero/explicit spacing, every admitted alignment, all padding,
      fixed/min/max/infinite frames, and canonical text; record exact observed
      counts and high-water values without treating these fixture limits as
      production host budgets.
- [ ] `T7.3` — Add allocation, borrow-lifetime, workspace-byte, maximum call-
      stack, semantic-view traversal work, layout work, and incremental linked-
      code probes around the approval fixture. Prove static zero allocation,
      no retained declaration/text/resource view, and no second complete
      semantic graph; keep fixture-only profile storage distinct from the
      production runtime profiles owned by SPEC-013.

### Milestone 8: Run the Four-Profile Gate and Prepare Conformance Review

**Entry conditions:** Every focused test and audit is registered fail-closed;
all prerequisite-owned declarations used by the approval corpus are present.

**Exit evidence:** Each exact standalone command and the top-level gate
produce inspectable evidence for every criterion, with cross-build facts
separated from connected-hardware claims and all plan tasks dispositioned.

- [ ] `T8.1` — Run unit, public/negative compile, package-graph, forbidden-
      import, source-surface, migration, and formatter checks. Verify the
      `GiftUI` public declaration surface on every contract compiler and the
      exact value-size ceilings for semantic payloads, limits, summary, error,
      and result.
- [ ] `T8.2` — Run the exact four commands required by SPEC-007 and capture
      repository revision/dirty state, complete commands, compiler/target/SDK/
      optimization identities, canonical corpus hashes, exact limits and
      high-water counts, value layouts, allocation count, workspace bytes,
      maximum stack high-water, linked-code delta, borrow/no-second-graph
      evidence, and all acceptance/evidence dispositions.
- [ ] `T8.3` — For macOS dynamic/static and Raspberry Pi ARMv6, compare the
      normalized success/failure corpus and owned-value/resource reports. The
      Raspberry Pi result is cross-build/inspection evidence only and does not
      claim `armv6l` execution, framebuffer presentation, input, or PiScreen
      hardware validation.
- [ ] `T8.4` — For nRF52840, prove the contract fixture compiles and links with
      zero static heap allocation and finite workspace, inspect value layouts,
      symbols, sections, linked code, and the ELF's Cortex-M4F hard-float VFP
      calling convention. Record cross-build/inspection only; do not flash or
      claim connected-board display/input evidence.
- [ ] `T8.5` — Update this plan with every completed, changed, removed, or
      blocked task disposition and stable evidence link. Create
      `docs/conformance/spec-007-conformance.md` in `collecting` status, map
      `LY-001` through `LY-009` once, and request conformance review. Do not
      mark SPEC-007 `implemented` without the required complete report and
      explicit human authorization.

## Design-Note Triggers

- After `T3.2` fixes the exact API, create
  `docs/implementation-designs/spec-007-bounded-layout-workspace.md` only if
  the identity-indexed caller-owned workspace, two-phase measurement/
  placement storage, acquisition rollback, and profile fixture variants would
  be difficult to reconstruct from code and tests. The note may select a
  replaceable bounded representation; it may not change identity equality,
  capacity ownership, the entry point, or atomic sink behavior.
- After the stack/frame algorithms compile, create
  `docs/implementation-designs/spec-007-measurement-and-placement.md` only if
  the once-per-scope two-phase realization and modifier-order data flow need
  maintained explanation. Normative proposal, sizing, placement, and clip
  behavior remains in SPEC-007.
- Canonical text line storage may be included in one of those notes only if it
  shares the same workspace mechanism. Do not create a separate text note for
  straightforward transcription of SPEC-007's wrapping algorithm. Any need
  for shaping, fallback, fractional geometry, baseline alignment, priority
  compression, or a different result contract is upstream or deferred work,
  not an implementation-note decision.

## Integration and Validation Order

1. Establish the fixture/evidence registry and exact package edges before
   production layout code can hide a dependency mistake.
2. Land the portable declaration surface and layout-local values in parallel
   with direct recording-view algorithm tests. These tasks depend only on
   approved SPEC-002, SPEC-005, and the present typed SPEC-006 declaration
   seam.
3. Integrate the production `SemanticLayoutView` only after SPEC-006 supplies
   complete bounded semantic results and exact identities. Keep direct
   recording fixtures as the independent approval seam.
4. Prove workspace and atomic sink lifecycle before layout algorithms; prove
   non-text measurement/placement before canonical text; then combine them in
   one recording oracle and exhaustive failure corpus.
5. Run unit and contract-local recording evidence before profile-equivalence
   probes. Run macOS dynamic first, macOS static second, then hardware-free
   ARMv6 and nRF52840 cross-build/inspection. No backend or connected hardware
   is needed for SPEC-007 conformance.
6. Integrate the complete Signal Analyzer approval fixture only after its
   prerequisite public/semantic declarations exist. SPEC-008 may supply public
   `Text`, but it does not change layout's independent scalar/metrics contract.
7. Register every exact standalone driver with the top-level gate and collect
   a conformance report only after all criterion rows have reproducible
   evidence. Hardware-free aggregation must not imply deployment, flashing,
   display, or input validation.

## Risks and Upstream Blockers

### Implementation risks

- Recursive measurement may increase static stack use even with zero heap
  allocation. Record maximum call-stack high-water and move replaceable
  traversal/storage details into a design note if an iterative bounded
  realization is needed without changing observable order.
- Exact identity-indexed measurement storage can accidentally copy semantic
  structure or rely on raw identity bytes. Audit stored fields and compare
  equality relations/canonical fixture tokens only.
- Text corpus size can obscure first-failure and global-limit edges. Keep
  focused scalar/line/glyph boundary fixtures alongside the combined oracle.
- Cross-module generic specialization can add linked code on nRF52840. Measure
  the exact semantic-core/layout edge and return upstream if the accepted
  direct dependency is infeasible; do not collapse module ownership.
- The repository currently contains concurrent user work for SPEC-006 and
  SPEC-010. Implementation must preserve those changes and coordinate exact
  shared traversal surfaces rather than overwriting or broadening them.

### Upstream blockers

- `T2.3`-`T2.5` and production portions of `T7.2`-`T7.3` wait for
  SPEC-006's exact complete semantic result, identities, and typed operation
  recording. This is an implementation dependency, not permission to create a
  substitute semantic graph in SPEC-007.
- Public Signal Analyzer text syntax waits for SPEC-008's approved `Text`
  declaration if the fixture is expressed through the full client surface.
  Canonical text layout and direct semantic-view fixtures do not wait for
  rendering or lowering.
- Any compiler failure of the approved nonescaping generic borrow, any need to
  translate/hash/reconstruct identity, or any inability to preserve
  first-failure atomic output is a Specification or architecture blocker.
- Any proposed baseline alignment, priority-based compression, general
  constraint solving, richer shaping, fallback, fractional scalar, backend
  feedback, capability-selected semantics, or production host-budget choice
  is outside SPEC-007. Route a required current-scope change upstream; retain
  optional work in its existing deferred track.

## Deferred and Follow-up Work

- [FW-001](../future-work/fw-001-international-and-rich-text-layout.md)
  preserves richer shaping, bidirectional/vertical text, and related text
  layout. It is not scheduled here.
- [FW-002](../future-work/fw-002-text-interaction-and-accessibility-geometry.md)
  preserves selection, editing, caret, and accessibility geometry. SPEC-007
  publishes only the logical geometry required by later approved interaction
  contracts.
- [FW-005](../future-work/fw-005-alternative-geometry-scalars.md) preserves
  fractional, floating-point, or fixed-point geometry. MVP layout continues to
  use checked `Int32` geometry.

No new deferred item was discovered while preparing this plan. A correctness,
capacity, profile-equivalence, or acceptance-evidence obligation from
SPEC-007 cannot be deferred.

## Completion Record

Implementation began on 2026-09-09 at the maintainer's request. SPEC-007 is
`implementing` and this plan is `active`; these progress transitions do not
change the approved contract or authorize the eventual `implemented`
transition.

`T0.1` is complete: `Tests/ContractFixtures/SPEC007/` now contains the ordered
canonical fixture manifest, frozen fixture fields and symbolic source-token
namespaces, the complete scope/text-line/glyph transcript vocabulary,
normalized success/failure shapes, exact local-error raw values and SPEC-003
mapping, and all nine pending acceptance rows. The focused harness rejects
schema drift, duplicate or incomplete cases, unknown events and evidence
classes, non-reciprocal criterion references, and unregistered or forbidden
identity representations. The fixture
[README](../../Tests/ContractFixtures/SPEC007/README.md) distinguishes host,
cross-build, inspection, simulator, and separately authorized connected-
hardware evidence without claiming deployment, remote access, or flashing.
`T0.3` and `T0.4` may proceed independently; package edits in `T0.2` remain
coupled to their first compiling sources.

`T0.3` is complete: `scripts/contracts/run-spec-007.sh` is registered for
exactly the four required profiles. It records the pinned compiler, target,
SDK, optimization, repository revision and dirty state, exact command
transcript, and input/fixture digest, then publishes an immutable verified
report. Its prerequisite matrix remains explicitly fail-closed for the absent
layout target and corpus, complete owned-value layouts, limits and high-water,
allocation, workspace, call-stack, linked-code delta, no-second-graph audit,
target inspection, nRF hard-float ELF evidence, and all acceptance evidence.
The driver performs no remote access, deployment, restart, simulator run,
connected-target execution, or flashing.

`T0.4` is complete: the immutable PoC inventory classifies recursive dynamic
and static measurement, host-width/trapping geometry, retained layout graphs,
backend text measurement and fallback, runtime-owned entry points, and legacy
stack declarations for replacement or retirement. It records floating
geometry, the previously absent ZStack/Spacer/padding/frame family, and a
second maintained layout path as already absent rather than fabricating
historical occurrences. The registered migration check reproduces every PoC
path/family count and rejects legacy paths, measurement outside `GiftUILayout`,
floating layout geometry, runtime/backend/platform layout graphs, and text
measurement outside the layout owner.

`T0.2` is complete: `GiftUILayout` now has exactly the approved `GiftUI`,
`GiftUISemanticCore`, and `GiftUITextResources` edges; its focused test target
and the separate `GiftUILayoutFailureAdapterFixture` with only layout/failure
knowledge compile as real owners around the first closed `LayoutError` value.
The SPEC-002 exact target allow-list is updated atomically. The boundary
registry and executable audit cover the reverse edge, Failure Core,
capability, render, runtime, backend, platform, driver, OS/RTOS, HAL, hardware,
and portable-`GiftUI` non-re-export negatives. No public product or portable
API exposes the package layout implementation.

`T1.1` is complete: `GiftUI` now exposes the exact alignment, edge-inset,
edge-set, and frame-limit value declarations. Focused public-import tests cover
every raw value and constant, nonnegative inset validation, empty and reserved
edge-bit preservation, and finite frame-limit preservation including negative
values for layout-time rejection.

`T1.2` is complete after the explicitly reapproved SPEC-006 primitive-with-
content amendment: `VStack`, `HStack`, and `ZStack` store builder-produced
content and dispatch exactly once through `visitPrimitive(content:payload:)`;
`Spacer` retains the leaf operation. Focused tests cover exact defaults,
zero-through-five builder shapes, every alignment payload, preservation of
negative spacing/minimum values, nested traversal, and zero body evaluation.

`T1.4` is complete: two external-client fixtures using only `import GiftUI`
compile every alignment, edge, inset, finite/infinite frame limit, container
default, modifier overload, custom view, view-returning property/function,
zero-through-five builder shape, and mixed modifier chain. The registered
declaration audit rejects imports, layout execution, and backend/capability/
runtime ownership in the portable layout files and proves exactly three
primitive-with-content witnesses plus the one `Spacer` leaf witness. Focused
runtime tests from `T1.1` through `T1.3` cover all preserved invalid values.

`T1.5` is complete: the canonical SPEC-006 corpus now records every SPEC-007
stack, overlay, spacer, padding, inset, fixed-frame, and flexible-frame
payload. It proves exact invalid-value preservation, primitive-before-child
traversal, nested source child order, exact semantic identities, and inner-to-
outer modifier indices without adding a client traversal witness.

`T2.1` is complete: Semantic Core owns the exact closed primitive and modifier
enums and the single canonical typed-payload mapping. Stack, overlay, spacer,
text, padding, inset, fixed-frame, and flexible-frame values are preserved
exactly; other layout-neutral primitives map to `.proxy`; current approved
style modifiers map to `.passthrough`; and an unknown modifier produces no
case so the layout producer must reject it rather than silently pass it.

`T3.5` is complete: the separate layout/failure fixture owner maps all five
closed local errors to their exact SPEC-003 facts, including Foundation-owned
arithmetic overflow and safety-not-proven invariant failure. Invalid limits
map at the pre-cycle runtime owner, while the executable import boundary proves
`GiftUILayout` itself imports neither Failure Core nor diagnostics.

`T3.2` is complete: the exact result sink, exact-identity generic layout entry,
and caller-owned workspace seam now compile together. The workspace reports
all five capacities before acquisition, provides bounded identity-indexed
measurement and placement operations plus depth storage, and resets copied
identity and derived geometry before returning. Focused poisoned-view probes
prove workspace-active and sink-active reentry occur before borrowed input
inspection. The admitted valid path remains deliberately fail-closed until
`T3.3` installs semantic validation and measurement; it neither begins nor
mutates the sink in that intermediate state.

`T1.3` is complete: all padding and frame overloads lower through the existing
typed modifier operation. Runtime transcript tests prove exact source-call
order and preservation of negative dimensions, negative finite limits,
invalid minimum/maximum relations, empty and reserved edge sets, and all-`nil`
frames without declaration-time normalization.

`T3.1` is complete: the layout package now owns the exact five nonzero limits,
summary, closed error codes, and success/failure result. Focused tests cover
each independently invalid zero limit, exact value preservation, error raw
values, and the 10-byte, 28-byte, 1-byte, and 32-byte size ceilings.

`T2.2` is complete: Semantic Core now owns the exact package-scoped borrowed
layout-view protocol with one associated identity type, `UInt16` counts and
indices, and only primitive, child, modifier, and text-scalar access. A direct
fixture proves valid and absent identity/count/index behavior. The closed
primitive and modifier enums required by the protocol are declared; their
production semantic-expansion mapping remains pending under `T2.1`.

`T2.4` is complete: recording-path, dynamic-slot, and fixed static-enum views
expose one canonical stack/modifier/action-proxy/spacer/text corpus. The tests
normalize only symbolic identity relations and compare occurrence kinds,
ordered children and modifiers, text scalars, counts, in-range and out-of-range
behavior across all three views. A dynamic malformed-view mode independently
injects a missing in-range child. The fixed view uses switch-based finite
storage and does not compare its private identity raw values with either host
fixture.

`T2.3` is complete: `SemanticLayoutResultSink` is both the real SPEC-006
expansion sink and the borrowed `SemanticLayoutView` over its one
profile-owned result storage. It forwards exact identities and accessors,
maps typed primitive and modifier payloads while they are staged, represents
an action-bearing occurrence as the same-identity layout proxy without its
callable value, rejects unknown layout modifiers, and adds no adapter-owned
node array. A focused expansion fixture proves transparent structural
flattening, source-ordered primitive children and modifiers, exact modifier
scope/action identity, and borrowed text-scalar access from the published
semantic result.

`T2.5` is complete: the optimized static exposure probe compiles a fixed
`SemanticLayoutView` through the package SPI and rejects any heap allocation
instruction in the borrowed accessor path. A runtime lifetime probe proves
the generic layout entry and its reset path retain neither the view nor its
source token. The registered boundary audit checks the exact view surface,
rejects action/generation/model/state/runtime/render/backend/platform and
unrestricted-existential exposure, rejects adapter-owned collections and
layout-side retained semantic fields, verifies Semantic Core imports only
`GiftUI`, and confirms the same one-edge package dependency closure. The
macOS-static driver executes the optimized allocation probe; every profile
executes the source/dependency audit. The nRF driver also compiles the exact
borrow surface for `armv7em-none-none-eabi`, verifies ARMv7E-M hard-float
attributes, and inspects its symbol closure for allocation calls and
prohibited layout/render/runtime/backend/platform dependencies.

`T3.3` is complete: `GiftUILayout` has one fixed-width counter set for all five
global limits. It accepts equality at each limit, rejects the next reservation
without changing the admitted count, tracks balanced active depth and its
high-water, validates the declared scope total, and retains the first failure.
The generic entry snapshots and compares all five workspace capacities before
acquisition or semantic inspection. Semantic validation rejects a declared
scope total above the call limit before reading the root, validates in-range
child/modifier/scalar access, transparent root and modifier cardinality,
closed public payload values and relations, Unicode scalars, exact canonical
instance/mapping/metric availability, and explicit line counts. Focused probes
prove scope, scalar, explicit-line, and glyph reservation failures occur before
the prohibited append, later scalar lookup, or mapping lookup. T5.1-T5.2 will
use the same global line counter when proposal-dependent wrapping is measured;
that text algorithm does not change this completed admission foundation.

`T3.4` is complete: `LayoutWorkspace` now exposes bounded ordered scope,
text-line, and positioned-glyph records, and `publishLayout` consumes only a
complete acquired workspace. It validates summary/count and terminal-index
agreement before `begin`, stages scopes in order with each text line and its
glyphs immediately after the owning scope, publishes exactly once, and always
resets the workspace acquired by the attempt. A begin refusal maps to capacity
exhaustion without discard; every scope, line, glyph, or publish refusal after
begin maps to invariant failure and discards exactly once. Focused tests prove
successful order, prior-current preservation, each refusal point, malformed
pre-begin workspace rejection, and workspace/sink/both-active reentry without
cleanup of the active outer attempt. The layout entry remains deliberately
fail-closed until T4/T5 populate real placement and text records, then calls
this completed publication coordinator rather than another sink path.

Plan completion will mean every task has a recorded disposition; it will not
mean SPEC-007 conforms or is `implemented`. The conformance report remains
`null` until `T8.5` creates it.
