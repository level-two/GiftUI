---
spec: SPEC-006
feature: giftui-mvp-architecture
title: SPEC-006 Implementation Plan
status: active
owners:
  - codex
created: 2026-09-01
updated: 2026-09-04
related_design_notes: []
conformance_report: null
related_future_work:
  - FW-017
  - FW-020
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-006 Implementation Plan

> This ready plan derives work from the approved Declarative View Semantics
> Specification. It orders implementation and evidence but does not amend the
> declaration, expansion, identity, action, state-host, modifier, failure, or
> profile contracts owned by that Specification and its dependencies.

## Authority and Scope

The governing contract is approved
[SPEC-006](../specs/spec-006-declarative-view-semantics.md). Its authority
chain is accepted
[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md),
approved [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md),
[RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md),
[RFC-010](../rfcs/rfc-010-layout-semantic-core-adapter-boundary.md), and
[RFC-011](../rfcs/rfc-011-bounded-application-actions.md), and accepted
[ADR-005](../adrs/adr-005-semantic-layout-render-boundary.md),
[ADR-006](../adrs/adr-006-shared-semantics-runtime-profiles.md),
[ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md),
[ADR-032](../adrs/adr-032-semantic-core-owned-layout-input.md), and
[ADR-033](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md).

Approved [SPEC-002](../specs/spec-002-portable-foundation.md) owns the package
partial order, compiler identities, portable fixed-width values, and four MVP
profile evidence conventions. Approved
[SPEC-003](../specs/spec-003-failure-outcomes-and-containment.md) owns failure
facts and outcomes; `GiftUISemanticCore` returns only SPEC-006's closed local
result, and a separate owner-adapter fixture proves the required mapping.
Approved [SPEC-010](../specs/spec-010-observable-reference-state.md) exclusively
owns `_GiftUIObservableStateHost`, its lexical declaration visitor, macro, and
binding failures. This plan implements only SPEC-006's traversal position and
integrates with those declarations after they exist.

The [MVP Scope](../MVP_SCOPE.md) requires non-trivial Signal Analyzer
hierarchies, reusable custom views, fixed child composition, and modifier
chaining in one portable Presentation across macOS dynamic, macOS static,
Raspberry Pi 1/Linux dynamic, and nRF52840 static configurations. SPEC-006 is
the Rank 0 semantic foundation for that requirement. It does not authorize
layout, rendering, concrete controls or modifiers, state ownership,
activation, capabilities, backends, host policy, or connected-hardware work.

## Current Repository State

- `Sources/GiftUI/GiftUI.swift` currently contains SPEC-002 geometry and
  normalized-pointer values only. No `View`, `ViewBuilder`, fixed wrapper,
  `GiftUIAction`, semantic payload, or traversal declaration exists.
- `Package.swift` has no `GiftUISemanticCore` production target, semantic-core
  test target, or semantic/failure owner-adapter fixture. `GiftUI` is already
  the portable product and must remain a leaf rather than importing or
  re-exporting Semantic Core.
- `Tests/GiftUITests/` contains foundation tests. There is no checked-in
  `Tests/ContractFixtures/SPEC006/` corpus, canonical transcript oracle,
  compile-negative suite, allocation probe, layout probe, migration inventory,
  or four-profile report schema.
- SPEC-002 established the exact target/dependency allow-list, package-graph
  checks, clean-baseline migration ledger, compiler/SDK identities, and
  cross-profile harness. SPEC-003 through SPEC-005 established reusable
  conventions for local-error owner adapters, positive/negative compile
  fixtures, deterministic evidence roots, allocation/layout probes, and
  fail-closed fixture manifests.
- `scripts/test.sh` is the top-level gate and
  `scripts/contracts/driver-registry.tsv` explicitly registers SPEC-002
  through SPEC-005. There is no `scripts/contracts/run-spec-006.sh`.
- Historical proof-of-concept view files appear only in SPEC-002's removed-path
  inventory; they are not current source or authority. The maintained
  implementation therefore begins from the clean SPEC-002 baseline and uses
  that inventory only to prove migration closure.
- SPEC-010 is approved but its declaration protocol and macro are not present
  in the current package. Contract-local ordinary traversal can proceed, but
  the generated state-host integration milestone cannot complete until the
  SPEC-010 owner supplies those declarations and its test seam.

## Readiness Review

**Reviewed:** 2026-09-01

**Disposition:** Ready. SPEC-006 is approved, all linked Proposal/RFC/ADR gates
are authoritative, all fifteen acceptance criteria map to ordered work and
evidence, and the contract-local implementation can begin without making a
new architectural choice. No manifest update is required because
implementation records are not registered in `docs/features.yaml`.

**Second-pass review:** 2026-09-01. A clause-by-clause audit of the public,
module, API, behavior, lifecycle, capability, backend, error, performance,
compatibility, and testing sections found no missing approval gate or contract
defect. The plan now makes action raw-code/domain checks, inactive-branch
non-observation, exact empty-root depth, optional-absence recording, linear-
work instrumentation, capability-independence, dynamic-convenience exclusion,
and complete driver report fields explicit rather than leaving them implicit
in broader tasks.

The SPEC-010 state-host fixture, production runtime-profile storage, and later
layout/interaction consumption have explicit entry conditions below. Those
dependencies do not block the declaration surface, generic Semantic Core,
recording oracle, bounded failure suite, or profile-independent contract
driver. If the exact approved underscored Swift signatures fail on a pinned
compiler, or if bounded collision-free identity cannot be realized without
changing observable equality, the affected task returns to Specification or
architecture review instead of introducing a compatibility hook.

## Acceptance-Criterion Matrix

The criterion text remains authoritative in SPEC-006. Every criterion appears
once below and maps to implementation tasks and reproducible evidence.

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `DV-001` — Exact `GiftUIAction`, Rank 0 source contract, sole portable import, and unevaluated `Never` | `T1.1`, `T1.2`, `T1.4`, `T6.1` | Public-interface, action-code/domain, external-conformance, wrapper-dispatch, and four-profile compile reports | pending |
| `DV-002` — Arity zero through five, conditionals, optionals, and absence of direct six-child/dynamic-array composition | `T1.2`, `T1.3`, `T6.1` | Positive and compile-negative builder corpus | pending |
| `DV-003` — Synchronous once-only active bodies and exact depth-first, left-to-right transcript and summary | `T2.3`, `T3.1`, `T3.2`, `T6.2`, `T6.5` | Canonical nested-declaration transcripts, invocation counters, and linear-work instrumentation | pending |
| `DV-004` — Exact structural-identity equality and inequality with no collision or client-visible raw form | `T2.1`, `T2.2`, `T3.3`, `T4.3` | Identity relation corpus, alias injection, and public-surface scan | pending |
| `DV-005` — Exact modifier source/nesting order without semantic-node or layout/render meaning | `T1.4`, `T2.3`, `T3.4` | Typed modifier fixture transcripts and count/identity comparisons | pending |
| `DV-006` — Stable distinct semantic action identities with no generation, target, callable, model retention, or invocation | `T1.1`, `T1.4`, `T2.3`, `T3.5`, `T6.3` | Typed action corpus, identity relations, lifetime probes, and forbidden-symbol/surface scans | pending |
| `DV-007` — Exact-at-limit success, one-over capacity failure, atomic discard, detection order, reuse, and owner mapping | `T2.2`, `T4.1`, `T4.2`, `T4.4`, `T6.2`, `T6.5` | Independent and coincident bound corpus, work counters, and mapped-failure transcripts | pending |
| `DV-008` — Exact identity, reentrancy, invalid-limit, and invariant failures unaffected by diagnostics | `T2.2`, `T4.2`, `T4.3`, `T4.4` | Framework-only fault injection, adapter mapping, and diagnostic-isolation matrix | pending |
| `DV-009` — Equal dynamic/static canonical semantics and failure facts | `T3.2`, `T3.3`, `T3.4`, `T3.5`, `T4.4`, `T6.2` | Event-by-event normalized corpus comparison for all four profiles | pending |
| `DV-010` — Static zero allocation, bounded depth/counters/layout, and nRF hard-float ELF evidence | `T0.3`, `T2.2`, `T4.1`, `T6.2`, `T6.4`, `T6.5` | Registered four-profile driver, allocation interposer, layout report, depth/work/overflow probes, commands, and ELF attributes | pending |
| `DV-011` — Exact dependency direction and restricted underscored traversal references | `T0.2`, `T1.4`, `T4.4`, `T6.3` | Package graph, import-negative fixtures, source/reference allow-list, adapter-boundary audit | pending |
| `DV-012` — No layout, render, state ownership, interaction, capability, backend, frame, or host policy | `T0.1`, `T7.1` | Scope and public/package-surface audit | pending |
| `DV-013` — Complete proof-of-concept migration closure with no second expansion engine | `T0.4`, `T1.4`, `T6.3`, `T7.1` | Migration inventory and repository-wide forbidden-surface scan | pending |
| `DV-014` — FW-017/FW-020 remain reciprocal optional post-MVP captures | `T0.1`, `T7.2` | Governance and reciprocal-link audit | pending |
| `DV-015` — Generated SPEC-010 witness binds before body, preserves successful semantics, and publishes nothing on binding failure | `T5.1`, `T5.2`, `T5.3` | Macro expansion, lexical binding transcript, bound-copy probe, and failure atomicity report | pending |

## Milestones and Tasks

### Milestone 0: Establish the Semantic Contract Harness and Migration Baseline

**Entry conditions:** SPEC-006 remains `approved`; PROPOSAL-003 remains
`accepted`; linked RFCs remain `approved`; linked ADRs remain `accepted`; and
SPEC-002/SPEC-003 remain approved authority.

**Exit evidence:** The target boundary, fixture schema, migration inventory,
and registered fail-closed driver skeleton exist before semantic behavior is
implemented.

- [x] `T0.1` — Audit SPEC-006 status, its fifteen criteria, Proposal/RFC/ADR/
      Specification relationships, MVP traceability, non-goals, and reciprocal
      FW-017/FW-020 links. Create `Tests/ContractFixtures/SPEC006/` with an
      ordered fixture manifest, canonical transcript schema, normalized
      result schema, evidence directories, and explicit host, cross-build,
      simulator, and connected-hardware evidence labels.
- [x] `T0.2` — Add package-internal `GiftUISemanticCore` and focused unit-test
      targets. The production target depends only on `GiftUI`; `GiftUI` gains
      no dependency on Semantic Core. Add a test-only semantic/failure owner
      adapter target that imports exactly `GiftUISemanticCore` and
      `GiftUIFailureCore`. Update SPEC-002's exact target/dependency allow-list
      and graph fixtures atomically, including reverse-import negatives.
- [x] `T0.3` — Add `scripts/contracts/run-spec-006.sh --profile <profile>` for
      exactly `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
      `nrf52840-embedded`; register it explicitly in
      `scripts/contracts/driver-registry.tsv`. Initially fail closed for every
      missing corpus, report, compiler identity, target pin, optimization,
      allocation record, owned-value size/stride/alignment record, summary
      counter, maximum-observed-depth value, underscored-reference inventory,
      repository revision, complete command transcript, or ELF inspection
      rather than reporting premature conformance.
- [x] `T0.4` — Create the migration inventory from SPEC-002's historical
      removal ledger and repository-wide scans. Enumerate every former
      `_visit`, `ViewVisitor`, wrapper initializer/storage exposure, string
      structural path, client traversal witness, and dynamic/static traversal
      entry; assign each a remove, replace-through-the-sealed-surface, or
      already-absent disposition, and reject a compatibility shim or second
      expansion engine.

### Milestone 1: Implement the Portable Rank 0 Declaration Surface

**Entry conditions:** Milestone 0's target graph and compile-fixture harness
are present. No concrete layout, rendering, interaction, state, or drawing
declaration is introduced by this milestone.

**Exit evidence:** An external portable client can declare and compose custom
views with only `import GiftUI`; wrappers and framework traversal dispatch have
the exact approved source/access shape and add no client traversal burden.

- [x] `T1.1` — Implement the exact public `GiftUIAction` and `View` source
      contracts, the `Never: View` recursive-body conformance, and the ordinary
      custom-view default `_giftUITraverse` witness. Compile an external-module
      custom conformance without a handwritten witness; prove every valid
      action code is exactly its `UInt16` raw value, no public numeric domain
      identifier exists, and associated-value or non-`UInt16` action shapes
      are outside the supported contract.
- [x] `T1.2` — Implement `ViewBuilder`, `EmptyView`, `TupleView` through
      `TupleView5`, `ConditionalContent`, and `OptionalContent` with exact
      public/package access and package-private stored children/branches. Add
      zero-through-five, nested-six, conditional, optional, property/function,
      and `@ViewBuilder` compile fixtures, plus direct-six and dynamic-array
      negative fixtures.
- [x] `T1.3` — Prove builder lowering and storage boundaries independently:
      zero children become `EmptyView`, one child remains itself, inactive
      generic branches are never instantiated, evaluated, retained, address-
      compared, or recorded, `buildArray` is absent, wrapper initializers/
      storage are unavailable to ordinary clients, and wrappers require no
      allocation, reflection, existential, or runtime discovery.
- [ ] `T1.4` — Implement the exact underscored primitive, action, modifier, and
      traversal protocols plus every fixed-wrapper override. Add package
      reference allow-list checks proving only GiftUI declaration
      implementations, Semantic Core, and named fixtures use the surface;
      prove ordinary custom views use the default custom-body category and
      framework wrappers never read `Never.body`. Reject handwritten
      application overrides and any second `View` traversal requirement while
      permitting only SPEC-010's generated state-host witness.

### Milestone 2: Implement Bounded Expansion State and Atomic Traversal

**Entry conditions:** The sealed declaration-dispatch surface from Milestone 1
compiles through the host compiler and its external-conformance fixtures.

**Exit evidence:** Semantic Core can perform one generic, synchronous,
bounded attempt against caller-owned workspace and sink protocols, with exact
local values, lifecycle, detection order, and publish/discard behavior.

- [ ] `T2.1` — Implement package-visible `SemanticExpansionLimits`,
      `SemanticExpansionSummary`, `SemanticExpansionError`, and
      `SemanticExpansionResult` with exact initialization, raw values,
      `Equatable`/`Sendable` behavior, limits/summary at no more than 10 bytes,
      error at exactly 1 byte, and result at no more than 12 bytes. Introduce
      the one generic expansion entry point and package workspace/sink protocol
      operations required by SPEC-006, including complete finite-capacity
      reporting before the attempt, without importing failure or runtime
      implementations.
- [ ] `T2.2` — Implement checked fixed-width counters, active-workspace guard,
      path-depth reservation, identity validation, declared-operation
      reservation, storage reservation, and first-failure propagation in the
      exact normative order. Ensure begin, stage, publish-once, discard-all,
      idle reset, overflow-before-wrap, and clean workspace reuse are
      independently observable by fixtures.
- [ ] `T2.3` — Implement the traversal visitor over custom bodies, fixed
      children, conditionals, optionals, typed primitives, action primitives,
      and typed modifier scopes. Preserve borrowed/nonescaping lifetimes,
      depth-first left-to-right order, exactly-once active body evaluation,
      structural-only wrappers, node-before-action reservation, and modifiers
      after content in increasing scope-local chain order.
- [ ] `T2.4` — After the exact API compiles, decide whether the bounded path,
      identity, staged-record, and workspace realization is difficult to
      reconstruct from local code. If so, create
      `docs/implementation-designs/spec-006-bounded-semantic-expansion.md`
      documenting only the replaceable internal representation, ownership,
      lifecycle, failure rollback, and profile fixture seams; add it to this
      plan and SPEC-006. Any choice that changes equality, public/package
      contracts, bounds ownership, or module direction goes upstream instead.

### Milestone 3: Build the Canonical Recording Oracle

**Entry conditions:** Milestone 2 stages complete semantic attempts without
publishing partial results. Fixture roles remain symbolic bounded tokens, not
production strings or metatype-address identities.

**Exit evidence:** One checked-in oracle records and compares the complete
canonical transcript, summaries, identity relations, modifiers, and action
associations without layout, rendering, a backend, or connected hardware.

- [ ] `T3.1` — Implement the package recording sink and exact closed event
      vocabulary with canonical path components. Publish transcript events
      only on success, keep an explicitly test-only attempted-event probe for
      failure detection points, and cross-check all summary counts and maximum
      observed depth against the published events. Prove structural-entry
      events do not increment a summary counter and an `EmptyView` root
      succeeds with `maximumObservedDepth == 2`.
- [ ] `T3.2` — Build the shared declaration corpus for empty, every fixed
      arity, nested custom views, properties/functions, both conditional
      branches, optional presence/absence, nested combinations, and sibling
      insertion in another branch. Check complete depth-first left-to-right
      output and exactly-once/zero-times body access. Prove optional absence
      records only its wrapper structural entry, emits no presence child or
      counted event, and never observes the inactive conditional metatype.
- [ ] `T3.3` — Build the structural-identity relation corpus for repeated
      expansion, branch changes, optional removal/restoration, sibling index,
      endpoint role, declaration role, prefix/descendant paths, and forced
      alias detection. Compare equality relations and canonical paths, never
      profile-private identity bytes.
- [ ] `T3.4` — Add test-only typed modifier declarations for zero, one,
      repeated same-kind, mixed-kind, custom-view, fixed-group, nested, and
      sibling scopes. Prove exact source order and scope identity, unchanged
      descendant semantic identities, no sibling interleaving, preservation of
      an otherwise unknown typed payload for its owning fixture consumer, and
      no layout or rendering assertions.
- [ ] `T3.5` — Add test-only action-bearing primitives using a finite action
      enum. Prove distinct path identities, equivalent re-expansion relations,
      unchanged semantic identity when only the bounded action value changes,
      semantic-node-before-action-before-modifier ordering at one path,
      borrowed typed values, and absence of committed generations, target
      binding, callable/handler/model retention, decoding through a handler,
      or action invocation. Poison the declaration lifetime after return while
      proving the successful semantic result contains only the contractually
      staged bounded action value and runtime-owned identity needed for
      synchronous downstream consumption.

### Milestone 4: Prove Bounds, Local Failures, and Owner Mapping

**Entry conditions:** The recording oracle can distinguish attempted staging
from current published output and can reuse the same workspace after failure.

**Exit evidence:** Every independent and coincident failure has the exact
local result, detecting point, atomicity, reuse behavior, and SPEC-003 owner
mapping required by SPEC-006.

- [ ] `T4.1` — Exercise exact-at-limit success and one-over failure separately
      for path depth, semantic nodes, body evaluations, modifiers, action
      occurrences, and every caller-owned workspace/sink capacity. Include
      invalid zero depth/node/body limits, permitted zero modifier/action
      limits, `UInt16` counter overflow edges, and successful summaries that
      never report zero observed depth. Prove no truncation, overwrite, retry,
      recursive fallback, allocating fallback, or retained rejected
      declaration state.
- [ ] `T4.2` — Exercise coincident failures in the mandated order:
      reentrancy; next depth; path/identity; operation count; storage; then
      hook/body. Cover action node-before-action and increasing modifier index.
      Prove the first error is stable, later work stops, no action runs, no
      partial result publishes, and the workspace accepts a later valid
      attempt. Inject callback, invalidation, and external-input attempts during
      expansion and prove they cannot recursively expand the active root.
- [ ] `T4.3` — Add framework-only injection for identity alias,
      same-workspace reentrancy, wrong/multiple visitor category, false
      capacity reporting, and detectable `Never.body` reachability. Verify
      exact `.invalidIdentity`, `.reentrancyViolation`, or
      `.invariantViolation` outcomes and keep unavoidable client traps outside
      the recoverable fixture claim.
- [ ] `T4.4` — Implement the test-only first owner adapter and map all four
      local errors plus invalid-limits `nil` to the exact SPEC-003 facts. Run
      disabled, enabled, saturated, dropped, and failing diagnostics variants
      and prove they cannot alter the local result, transcript, counts, or
      primary mapped fact. Prove invalid limits map to `.invalidValue`,
      `.semantic`, `.runtime`, `.contained` before the first cycle, and prove
      Semantic Core still imports no failure module.

### Milestone 5: Integrate the SPEC-010 Stateful Custom-View Seam

**Entry conditions:** SPEC-010 remains approved and its owning implementation
has supplied `_GiftUIObservableStateHost`, the declaration visitor and binding
decorator, the `@ObservableStateHost` macro target, generated witness shape,
and fixture-accessible binding results. Ordinary SPEC-006 traversal is already
stable. If those declarations differ from the coordinated approved contract,
pause this milestone for Specification review.

**Exit evidence:** The exact generated witness takes the stateful traversal
path, binds one mutable transient copy before its sole body access, and leaves
no semantic publication when binding fails.

- [ ] `T5.1` — Compile an ordinary external custom view and a macro-expanded
      `@ObservableStateHost` view side by side. Prove only the generated witness
      calls `visitStatefulCustomView`, the ordinary default still calls
      `visitCustomView`, and application code hand-authors neither witness.
- [ ] `T5.2` — Extend the recording visitor through the SPEC-010 decorator.
      Prove lexical state-declaration ordinal order, binding on one mutable
      transient copy, no Semantic Core state interpretation or retention, one
      body evaluation only after complete binding, and unchanged ordinary
      counts and structural/action identity on success.
- [ ] `T5.3` — Inject every SPEC-010 binding failure relevant to this seam.
      Prove the body accessor and `evaluateCustomBody` event never occur, no
      partial semantic transcript/result publishes, the exact SPEC-010 error
      survives through the combined coordinator, and no semantic-expansion
      error is substituted.

### Milestone 6: Complete Cross-Profile, Resource, and Dependency Evidence

**Entry conditions:** Milestones 1 through 4 are complete; Milestone 5 is
complete for the stateful subset. The pinned SPEC-002 toolchains and local
cross-build probes pass. No remote deployment, service restart, or board flash
is authorized.

**Exit evidence:** All four exact standalone commands produce complete,
normalized hardware-free reports proving source compatibility, semantic
equivalence, static-path constraints, value layouts, target ABI, dependency
direction, and migration closure.

- [ ] `T6.1` — Compile the identical portable declaration corpus with only
      `import GiftUI` for macOS dynamic/static, Raspberry Pi ARMv6 dynamic, and
      nRF52840 static. Record the complete commands and repository revision;
      run public-interface and compile-negative fixtures for builder arity,
      unsupported dynamic syntax, wrapper access, and external conformance.
- [ ] `T6.2` — Run the complete normalized semantic, bounds, failure, modifier,
      action, and state-host corpus through fixture dynamic and static
      workspace/sink implementations. Compare event-by-event canonical output,
      identity relations, summaries, detecting failures, and mapped facts;
      report every counter and maximum observed depth. Repeat representative
      Rank 0 cases with varied backend/platform/capability fixture facts and
      prove those facts cannot change builder shape, branch choice, expansion,
      modifier order, identity, result, or transcript.
- [ ] `T6.3` — Enforce the exact import graph and underscored-reference
      allow-list in source and compiled interfaces. Scan for `Any`, reflection,
      runtime registries, `Task`, `MainActor`, Objective-C, callable/model
      retention, public identity bytes, string paths, second traversal engines,
      `GiftUISemanticCore` imports of dynamic/static implementations, static
      linkage of any dynamic convenience module, backend/platform/driver
      traversal references, extra public/package Semantic Core results or
      mutable semantic operations, and every migration-inventory item;
      distinguish forbidden production use from named fixture instrumentation.
      If a later separately imported dynamic convenience is present, prove it
      lowers to the same fixed declaration and canonical expansion semantics.
- [ ] `T6.4` — Instrument allocation counts and size/stride/alignment for every
      SPEC-006-owned value. Prove zero static-path heap allocations and bounded
      call depth; inspect ARMv6 and nRF artifacts, and verify the nRF52840 ELF
      uses the required Cortex-M4F hard-float calling convention. Record
      cross-build/inspection evidence only, with no connected-hardware claim.
- [ ] `T6.5` — Instrument visitor dispatches, path/identity validations,
      counter reservations, workspace/sink reservations, body evaluations,
      semantic stages, modifier stages, and action stages over geometrically
      increasing valid and first-failure corpora. Prove each unit of admitted
      work is visited a constant number of times, rejected work stops at the
      first failure, and no traversal, retry, cleanup, or retained storage adds
      work proportional to an inactive or rejected subtree.

### Milestone 7: Close Planning Tasks and Prepare Conformance

**Entry conditions:** Every earlier task has a recorded disposition and all
required reports are reproducible from checked-in drivers and fixtures.

**Exit evidence:** Contract coverage, scope, deferred-work boundaries, and
implementation-record links are complete; remaining deviations are explicit
upstream blockers rather than hidden plan edits.

- [ ] `T7.1` — Audit every normative API, behavior, lifecycle, error,
      performance, compatibility, testing, and non-goal clause against source
      and evidence. Close the migration ledger and prove no layout, rendering,
      state ownership/invalidation, activation/input, capability, backend,
      frame, host, or connected-hardware policy entered the implementation.
- [ ] `T7.2` — Recheck FW-017 and FW-020 provenance, reciprocal links,
      post-MVP classification, and revisit triggers. Confirm no implementation
      task, fixture requirement, or success claim depends on pursuing either
      item; capture any new optional discovery through the deferred-work track
      rather than expanding SPEC-006.
- [ ] `T7.3` — Update task dispositions and design-note links, create
      `docs/conformance/spec-006-conformance.md` from the conformance template
      in `collecting` status, and map all fifteen criteria to stable evidence.
      Set this plan to `completed` only after every task is complete, removed,
      changed, or blocked with a recorded reason. Do not mark SPEC-006
      `implemented` without complete conformance review and explicit maintainer
      authorization.

## Design-Note Triggers

- **Bounded semantic expansion representation:** Create the focused note in
  `T2.4` if the path/identity encoding, caller-owned staging, generic visitor,
  rollback, or workspace lifecycle would be difficult to reconstruct from
  local code. The note may explain a selected replaceable realization only
  after the exact contract compiles; it may not change structural equality,
  detection order, profile ownership, or storage bounds.
- **No separate declaration-surface note:** The public `View`, builder,
  wrapper, and traversal declarations are exact SPEC-006 contract text and
  should remain self-explanatory in source and tests.
- **No SPEC-010 mechanism note in this plan:** Macro expansion, state-slot
  discovery, binding storage, and model lifetime belong to SPEC-010. SPEC-006
  records only the integration evidence at its pre-body traversal seam.

## Integration and Validation Order

1. Run governance, package-graph, driver-registry, and migration-baseline
   checks before adding production semantics.
2. Compile the portable declaration surface and external conformance fixtures
   before Semantic Core depends on the sealed visitor categories.
3. Validate local values, bounds, lifecycle, and atomicity before using the
   recording sink as a cross-profile oracle.
4. Establish the complete canonical oracle before implementing or comparing
   dynamic/static fixture workspaces; compare semantic relations, not private
   storage bytes.
5. Validate every local failure and test-only SPEC-003 owner mapping before
   integrating diagnostics or later runtime owners.
6. Integrate the SPEC-010 generated witness only after its owning declarations
   exist; run ordinary and stateful paths together to catch witness-category
   drift.
7. Run macOS dynamic first, macOS static second, Raspberry Pi ARMv6
   cross-build/inspection third, and nRF52840 cross-build/ELF inspection last.
   The four standalone commands remain the reproducible seams even when the
   top-level runner aggregates them.
8. Treat connected Raspberry Pi or nRF52840 execution as downstream
   conformance work under the applicable host/platform plan. This plan neither
   deploys nor flashes hardware and makes no hardware-execution claim.

Tasks `T1.1` through `T1.3` may proceed in parallel only after `T0.1` through
`T0.3` fix the target and fixture interfaces. Recording-corpus tasks `T3.2`
through `T3.5` may proceed in parallel only after `T3.1` fixes the event and
path oracle. Bound/failure tasks `T4.1` through `T4.3` may proceed in parallel
after the Milestone 2 result and workspace/sink seams are fixed. Profile runs
may execute in parallel after the driver schema and complete corpus are fixed;
their normalized comparison and final evidence audit remain a join step.

## Risks and Upstream Blockers

### Implementation risks

- Swift's public protocol-witness visibility, `borrowing` parameters, generic
  result-builder lowering, and `Never` conformance may behave differently
  across the pinned host and cross-compilers. Compile the exact surface before
  building dependent code and preserve compiler transcripts.
- Collision-free bounded identity and maximum-depth enforcement must remain
  linear and allocation-free without exposing profile-private bytes. Keep the
  canonical path/equality oracle independent from the private encoding.
- A generic recursive implementation can accidentally exceed the declared
  bound on the machine stack even if its semantic counter fails correctly.
  Combine semantic depth fixtures with instrumented call-depth evidence.
- Atomic rollback and workspace reuse can be undermined by sinks that publish
  incrementally or retain borrowed payloads. Poisoned-lifetime and false-
  capacity fixtures must run before cross-profile comparisons.
- Exact `SemanticExpansionResult` layout and zero-allocation behavior can vary
  with compiler lowering. Measure every pinned compiler rather than inferring
  from the host layout.
- Package exact-set controls are shared with in-progress Specifications. Update
  them atomically and preserve unrelated target or fixture changes.

### Upstream blockers

- If any pinned compiler cannot express the exact normative public
  underscored signatures or external default witness, return the issue to
  SPEC-006 review; do not add a public compatibility protocol or hand-written
  client traversal requirement.
- If unique bounded structural/action identity requires changing the approved
  equality rules, path contributions, failure vocabulary, or profile-neutral
  transcript, pause for RFC/ADR or Specification review as applicable.
- Milestone 5 waits for the approved SPEC-010 owner to provide its protocol,
  macro-generated witness, decorator, and binding-result seam. SPEC-006 must
  not implement a parallel observable-state abstraction to bypass that
  dependency.
- Production runtime workspaces, node/action capacities, and aggregate RAM,
  stack, flash, or linked-code ceilings belong to SPEC-013 and host
  configuration. This plan uses finite conformance workspaces and reports
  measurements but must not invent production budgets.
- Exact layout-facing borrowed declarations belong to SPEC-007. Semantic Core
  may reserve its ownership boundary, but this plan must not define a parallel
  layout input or claim downstream layout integration.
- Production action generations, target binding, hit maps, and dispatch belong
  to SPEC-009/SPEC-011. Any need to add them during expansion is a contract
  conflict, not an implementation task.

## Deferred and Follow-up Work

- [FW-017](../future-work/fw-017-public-binding-abstraction.md) remains the
  optional post-MVP public two-way binding abstraction. SPEC-006 and this plan
  require no public `Binding`.
- [FW-020](../future-work/fw-020-declarative-extensibility.md) remains the
  optional post-MVP capture for unrestricted dynamic collections, keyed
  identity, public type erasure, public custom modifiers, and explicit client
  identity. Direct six-child composition and dynamic arrays remain absent from
  the maintained Rank 0 surface.
- Concrete layout, render, interaction, observable-state, and drawing
  declaration vocabularies remain scheduled only by their own approved
  Specifications and ready implementation plans.

## Completion Record

Implementation began on 2026-09-04. The plan is `active` and SPEC-006 is
`implementing`; these progress transitions do not change the approved contract
or authorize the eventual `implemented` transition.

`T0.1` is complete: the checked-in
[authority audit](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-0/authority-audit.md)
verifies the accepted/approved authority chain, all fifteen acceptance labels,
MVP traceability, downstream non-goals, and reciprocal FW-017/FW-020 links.
The [fixture contract](../../Tests/ContractFixtures/SPEC006/README.md)
establishes the ordered compile registry, canonical transcript and normalized
result schemas, deterministic generated/report roots, and precise host,
cross-build, simulator, and connected-target labels without starting semantic
implementation. `T0.2` is next.

`T0.2` is complete: the package now contains the unpublished
`GiftUISemanticCore` leaf with the sole production edge to `GiftUI`, plus the
unpublished test-only semantic/failure owner adapter importing exactly
Semantic Core and Failure Core. Focused import tests, reverse-import negative
fixtures, SPEC-002's exact target/dependency allowlist, product checks, and
cycle checks preserve the required direction; see the
[Semantic Core leaf evidence](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-0/semantic-core-leaf.md).
`T0.3` is next.

`T0.3` is complete: the explicitly registered
[four-profile contract driver](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-0/contract-driver.md)
validates the fixture schemas and pinned compiler/target/optimization identity,
compiles the current portable modules and import fixtures, hashes inputs and
images, and records the repository revision plus complete commands. Every
not-yet-produced semantic, allocation, layout, summary, depth, traversal-
reference, and nRF ELF record is present as `missing`, forcing
`evidence_complete=false` instead of premature conformance. `T0.4` is next.

`T0.4` is complete: the checked-in
[migration baseline](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-0/migration-baseline.md)
pins SPEC-002's immutable PoC revision and inventories every old traversal
surface, wrapper initializer/storage exposure, string path, client witness,
and dynamic/static traversal entry by exact path and occurrence count. Every
row is assigned remove, replace-through-the-sealed-surface, or already-absent,
and the registered check rejects the old API names, string identity, a
compatibility shim, or a second expansion engine. Milestone 0 is complete;
`T1.1` is next.

`T1.1` is complete: `GiftUI` now exposes the exact `GiftUIAction`, Rank 0
`View`, recursive `Never`, and ordinary default custom-view traversal witness.
Focused tests and the four-profile registry prove exact `UInt16` action codes,
reject wrong-width and associated-value shapes, compile an external custom
conformance without a handwritten witness, and keep `Never.body` unevaluated;
see the
[action/custom-view evidence](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-1/action-and-custom-view.md).
The remaining builder/wrapper and sealed visitor categories stay assigned to
`T1.2` through `T1.4`; `T1.2` is next.

`T1.2` is complete: the exact bounded builder overloads, structural wrappers,
package-only construction/storage, and wrapper self-dispatch now compile in
all four profiles. External fixtures cover zero through five children, a
nested six-child declaration, conditionals, optionals, builder properties and
functions, while direct six-child and loop lowering fail as required; see the
[builder/wrapper evidence](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-1/builder-and-wrappers.md).
The stronger lowering, inactive-branch, storage, and representation proofs
remain assigned to `T1.3`, which is next.

`T1.3` is complete: compile-time assignments prove exact zero/one lowering;
selected-branch tests use an inactive type whose initialization and body trap;
ordinary-client fixtures reject wrapper construction and child storage; and
optimized SIL audits find no heap allocation, existential, reflection, or
runtime-discovery operations in the declaration module. The driver now strips
package identity from `public` fixture rows, correcting the external-client
boundary for the complete T1.1–T1.3 corpus. See the
[builder lowering evidence](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-1/builder-lowering-boundaries.md).
`T1.4` is next, subject to the SPEC-010-owned state-host declarations required
by its complete normative visitor surface.
