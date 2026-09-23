---
spec: SPEC-001
feature: signal-analyzer
title: SPEC-001 Implementation Plan
status: active
owners:
  - codex
created: 2026-09-13
updated: 2026-09-22
related_design_notes:
  - ../implementation-designs/spec-001-presentation-admission-and-failure.md
  - ../implementation-designs/spec-001-four-host-application-join.md
  - ../implementation-designs/spec-001-connected-target-host-loop.md
  - ../implementation-designs/spec-001-nrf-static-semantic-records.md
  - ../implementation-designs/spec-001-nrf-static-layout-records.md
conformance_report: ../conformance/spec-001-conformance.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-001 Implementation Plan

> This ready plan derives the ordered application work and evidence strategy
> from the approved Signal Analyzer contract. It does not amend SPEC-001,
> redefine a reusable GiftUI contract, or authorize deployment, remote service
> changes, connected Pi execution, or nRF52840 flashing.

## Authority and Scope

The governing
[SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md) is
explicitly `approved`. Its application authority begins with accepted
[PROPOSAL-002](../proposals/proposal-002-signal-analyzer-reference-application.md),
is preserved by approved
[RFC-001](../rfcs/rfc-001-signal-analyzer-application-architecture.md), and is
updated by approved [RFC-008](../rfcs/rfc-008-observable-reference-state-architecture.md),
[RFC-009](../rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md), and
[RFC-011](../rfcs/rfc-011-bounded-application-actions.md). Accepted ADR-001,
ADR-003, ADR-004, ADR-011, ADR-014 through ADR-016, ADR-024 through ADR-031,
and ADR-033 govern the work. ADR-002 and ADR-013 are superseded and remain
historical evidence only.

Approved SPEC-002 through SPEC-015 own the reusable Foundation, failure,
capability, text, declarative, layout, rendering, execution, observable-state,
interaction, Drawing, profile, backend, and target-host contracts. This plan
consumes those contracts. It owns only the fixed Signal Analyzer Domain, Data,
Presentation, admission-adapter declarations, application-specific owner
adapter, concrete source behavior, portable hierarchy, host-facing analyzer
assembly inputs, and end-to-end application evidence required by SPEC-001.

The [MVP Scope](../MVP_SCOPE.md) requires one coherent, substantially shared
four-channel analyzer to exercise the complete Rank 0-2 client surface and
waveform drawing on macOS dynamic, macOS static, Raspberry Pi 1/Linux dynamic
with framebuffer/PiScreen, and nRF52840 static with TFT. This reference
application and four-stack validation requirement is the reason this work is
in the MVP now.

## Current Repository State

- `docs/features.yaml` registers `signal-analyzer` at the `specification`
  stage with approved SPEC-001 and dependencies on `observable-reference-state`
  and `canvas-drawing`. The authority gate is complete; implementation has not
  begun under the reconciled contract.
- `demo/SignalAnalyzer/` is a separate SwiftPM macOS investigation containing
  logical Domain, Data, Presentation, and App targets plus 17 baseline tests.
  It is valuable migration input, but it is not the governed implementation.
- The root package has no governed `SignalAnalyzerDomain`,
  `SignalAnalyzerData`, or `SignalAnalyzerPresentation` production/test
  targets. The implementation must add those package targets under root
  `Sources/` and `Tests/`; it must not continue evolving the standalone demo
  as though that package were the four-profile product.
- The Domain target already has the four channel values, transition/capture
  values, repository contracts, and five use cases. It still uses `@MainActor`,
  reference-only sink protocols, unbounded Foundation collections, `String`
  failure data, and unrevisioned whole-capture callbacks.
- The Data target already demonstrates stable transition insertion, 30-second
  trimming, 2,404-entry overflow, lower-bound baselines, clear/rebase behavior,
  deterministic mock patterns, and stale-generation cancellation. It still
  depends on Foundation, `ContinuousClock`, `Task`, dynamic arrays/maps,
  closure diagnostics, and wrapping generation arithmetic; it has no bounded
  publication mutation or capture-revision exhaustion path.
- Presentation is still SwiftUI/Observation-based. Its ViewModel implements
  both repository sinks and mutates immediately, starts observation from View
  construction, owns desktop-only observation behavior, uses closure Buttons,
  and renders a grid inside each channel Canvas. Those paths conform to the
  investigation and superseded ADR-002 rather than approved SPEC-001.
- The root package now contains production or focused implementation surfaces
  for the approved reusable contracts, including `GiftUI`,
  `GiftUIFailureCore`, `GiftUIExecution`, `GiftUIObservableState`,
  `GiftUIInteraction`, `GiftUIDrawing`, dynamic/static runtimes, raster and
  backend integration. SPEC-007 and SPEC-008 are implemented; SPEC-002,
  SPEC-005, SPEC-006, and SPEC-014 have completed plans but remain at their
  independent conformance/status gates; SPEC-003, SPEC-004, and SPEC-009
  through SPEC-013 have active plans; and SPEC-015 has a ready plan. These
  states make the prerequisite seam, rather than a whole-document status,
  the gate for each dependent analyzer task.
- Existing SPEC-007 through SPEC-013 fixtures already encode parts of the
  analyzer layout, render, execution, observation, action, Drawing, and profile
  workload. There is no `Tests/ContractFixtures/SPEC001/`, registered SPEC-001
  driver, governed four-profile analyzer assembly, application resource
  report, or conformance report.
- Repository-local Raspberry Pi 1 and nRF52840 workflows preserve the required
  target triples, SDKs, artifacts, and hardware safety boundaries. Hardware-free
  builds and inspection may be planned now; connected deployment or flashing
  requires a later explicit user request.

## Readiness Review

**Reviewed:** 2026-09-13

**Disposition:** Ready with explicit prerequisite gates. SPEC-001 is approved,
all 45 criteria map exactly once below, the existing code establishes a
reproducible migration baseline, and no unresolved architecture or application
contract question remains. Milestones 0 through 4 and dependency-complete
slices of Milestone 5 may begin in order. Production runtime, backend, and host
joins wait for the exact approved SPEC-009 through SPEC-015 owner seams; they
must not be replaced by analyzer-local substitutes.

`ready` means the implementation order, ownership boundaries, and evidence
requirements are executable without inventing contract intent. It does not
mean every downstream production seam or connected target is currently
available. `T0.4` records those seam-level gates, and an unavailable seam
blocks only the tasks that name it.

No `docs/features.yaml` change is required for this derived plan. When
implementation actually begins, SPEC-001 must transition from `approved` to
`implementing` and the `signal-analyzer` manifest stage must transition from
`specification` to `implementation` in the same authorized implementation
change.

If implementation cannot express the exact bounded diagnostic, mutation,
admission, static storage, model identity, action dispatch, or host-workload
contract on a supported compiler, return that contract to Specification
review. Any pressure to alter module ownership, domain separation, observable
lifecycle, failure meaning, Canvas workload, target presets, or connected-
hardware requirements returns to the governing RFC/ADR/Specification rather
than being decided in this plan or in code.

## Task Dependencies and Affected Surfaces

Milestone order is the default dependency order. Tasks may proceed in parallel
only across the fixed boundaries shown here and only after their named owner
contracts are available.

| Work | Prerequisites | Primary affected surfaces | Parallel boundary |
| --- | --- | --- | --- |
| `T0.1`-`T0.5` | Approved SPEC-001 authority | `Package.swift`, `Sources/SignalAnalyzer*/`, `Tests/SignalAnalyzer*/`, `Tests/ContractFixtures/SPEC001/`, driver registry, migration/import inventories | Fixture schemas, migration inventory, package-target reservation, and driver scaffold may proceed together |
| `T1.1`-`T1.4` | SPEC-002/003/005 declaration owners | `SignalAnalyzerDomain`, domain tests, static compile fixtures | Diagnostic and capture values may proceed separately before publication/use-case integration |
| `T2.1`-`T2.4` | Milestone 1 values | `SignalAnalyzerData`, repository/source tests, static storage fixtures | Repository and deterministic source work may proceed separately against fixed Domain contracts |
| `T3.1`-`T3.5` | Milestone 1; SPEC-003/009/010 admission and failure seams | `SignalAnalyzerPresentation`, adapter/owner fixtures | ViewModel values and adapter normalization may proceed separately before integrated fact application |
| `T4.1`-`T4.4` | Milestone 3 model/action values; implemented SPEC-006/007/008 and usable SPEC-011/012 declarations | portable GiftUI views and semantic/drawing fixtures | Hierarchy/status and waveform derivation may proceed separately after source declarations freeze |
| `T5.1`-`T5.5` | Milestones 3-4; production SPEC-009/010/011/013 seams | admission storage, model lifetime, action dispatch, cycle fixtures | Admission and model-lifetime fixtures may proceed separately; coordinator joins wait for both |
| `T6.1`-`T6.6` | Milestones 1-5; production SPEC-014/015 seams | target composition, generated manifests, four host fixtures | Each immutable preset may build independently; equivalence consumes all four reports |
| `T7.1`-`T7.4` | Complete application graph and owner adapters | failure matrix, workload/resource instrumentation | Failure and performance corpora may execute independently against one frozen graph |
| `T8.1`-`T8.3` | Corresponding cross-builds and explicit connected-hardware authorization | PiScreen and TFT execution evidence | Pi and nRF connected work is independent and remains separate from hardware-free evidence |
| `T9.1`-`T9.4` | All applicable implementation and evidence tasks | registered driver, repository gate, conformance report | Profile runs may execute independently; final disposition consumes all required evidence |

## Evidence Lanes and Artifact Ownership

- macOS dynamic and macOS static runs are target-execution evidence because
  the produced executables run on the claimed host. Their contract reports
  live below `.build/contract-reports/spec-001/`.
- Raspberry Pi and nRF52840 host-native fixtures or simulators prove only the
  portable/profile semantics they actually execute. They MUST be labeled
  `host-native-fixture` or `simulator`; neither label satisfies target
  execution, display, input, process-memory, stack-high-water, responsiveness,
  or watchdog criteria.
- Raspberry Pi and nRF52840 compiler, ABI, symbol, link-map, and static-resource
  results are `cross-build-inspection` evidence. Deployable Pi artifacts remain
  under `.build/raspberry-pi/`; nRF52840 ELF, HEX, map, Devicetree, and reports
  remain under `.build/nrf52840/`. The SPEC-001 driver records their emitted
  paths and identities rather than relocating or duplicating them.
- PiScreen and nRF52840 TFT/input runs are `connected-target-execution`
  evidence, require a separate explicit user request, and must name the exact
  inspected artifact. Only these runs may close the connected portions of
  `SA-AC-023` through `SA-AC-025`.
- Every report records repository revision, fixture/schema version, compiler,
  SDK/toolchain, target triple, optimization mode, command, artifact digest,
  evidence kind, execution environment, and whether physical display/input
  was exercised. Unknown or contradictory claim/evidence combinations fail
  closed.

## Acceptance-Criterion Matrix

The criterion text remains authoritative in SPEC-001. A `baseline` status
means the imported investigation supports part of the criterion, but the
governed implementation must still reproduce and record the required evidence.

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `SA-AC-001` — Complete feature and authority traceability | `T0.1`, `T9.4` | Governance, manifest, status, and reciprocal-link audit | baseline; revalidation pending |
| `SA-AC-002` — Logical Domain/Data/Presentation/host graph and inward dependencies | `T0.2`, `T0.5`, `T1.4`, `T6.1`, `T9.1` | Package graph, imports, interfaces, generated graph report | baseline; revalidation pending |
| `SA-AC-003` — Domain excludes UI/backend/platform/timing/hardware APIs | `T0.2`, `T0.5`, `T1.4`, `T9.1` | Source/import/symbol negative scans in every profile | baseline; revalidation pending |
| `SA-AC-004` — Presentation excludes Data/platform/timing/renderer/display/hardware APIs | `T0.2`, `T0.5`, `T4.4`, `T9.1` | Import and dependency negative fixtures | pending |
| `SA-AC-005` — Complete visible screen surface | `T4.1`-`T4.3`, `T6.2`-`T6.5`, `T6.7`, `T6.8`, `T8.1`, `T8.2` | Semantic hierarchy transcript plus rendered/connected display evidence | pending |
| `SA-AC-006` — Fixed explicit portable composition shared by four configurations | `T4.1`, `T4.4`, `T6.2`-`T6.5` | Source identity/hash, compile, and hierarchy comparison | pending |
| `SA-AC-007` — Revisioned current-value sink registration, replacement, detach, and bounded returns | `T1.3`, `T2.2`, `T3.2` | Ordered callback/outcome and lifetime transcript | pending |
| `SA-AC-008` — Synchronous application delivery and distinct GiftUI mutation without portable concurrency facilities | `T1.4`, `T2.2`, `T3.2`, `T5.3`, `T9.1` | Same-thread/distinct-executor transcript and forbidden-facility scans | pending |
| `SA-AC-009` — Complete acquisition action state table | `T2.2`, `T2.3` | State/publication/source-generation matrix | baseline; revalidation pending |
| `SA-AC-010` — Clear resets epoch/history, preserves state/levels, rebases, and publishes once | `T1.3`, `T2.1`, `T2.2`, `T3.3` | Idle/running/stopped/failed clear and mutation replay corpus | pending |
| `SA-AC-011` — 80 transitions/second for 30 seconds without loss or duplication | `T2.4`, `T7.4` | Timestamped 2,400-event sustained-workload transcript | pending |
| `SA-AC-012` — Static 2,404-entry transition storage and four baselines | `T1.2`, `T2.1`, `T6.3`, `T6.5`, `T7.4` | Static layout, high-water, boundary, map, and ELF reports | pending |
| `SA-AC-013` — Oldest-first trimming/overflow with correct lower-bound levels | `T1.2`, `T2.1` | Time/capacity boundary and reconstruction corpus | baseline; revalidation pending |
| `SA-AC-014` — Stable ordering and specified invalid/out-of-horizon behavior | `T2.1`, `T2.2` | Equal/out-of-order/invalid/horizon transcript | baseline; revalidation pending |
| `SA-AC-015` — Exact deterministic four-channel source and stale-event prevention | `T2.3` | Pattern, restart, cancellation, and teardown corpus | baseline; revalidation pending |
| `SA-AC-016` — Initial state and mutation-phase-only observable changes/reports | `T3.1`, `T3.3`, `T5.2`, `T5.3` | Initial/materialization/fact/action/change-report transcript | pending |
| `SA-AC-017` — Exact control enabled/disabled behavior | `T3.1`, `T4.2` | Four-state control matrix and semantic transcript | baseline; revalidation pending |
| `SA-AC-018` — Exact 1/2/5-second visible ranges | `T3.1`, `T4.3` | Boundary and golden range corpus | baseline; revalidation pending |
| `SA-AC-019` — Baseline-correct continuous waveform mapping | `T4.3` | Path point/subpath transcript at range/retention edges | pending |
| `SA-AC-020` — Ruler formatting and 11-plus-one grid | `T4.3` | Text bytes and normalized Drawing operation transcript | baseline; revalidation pending |
| `SA-AC-021` — Consistent latest state at 250 ms without per-event frames | `T5.3`, `T7.4` | Admission/application/publication/frame timeline and cadence report | pending |
| `SA-AC-022` — macOS dynamic and static deterministic execution | `T6.2`, `T6.3`, `T9.2` | Two host-execution reports and normalized equivalence | pending |
| `SA-AC-023` — Raspberry Pi framebuffer/PiScreen display and input | `T6.4`, `T6.7`, `T8.1` | ARMv6 cross-build plus separately labeled connected-target transcript | pending |
| `SA-AC-024` — nRF52840 static TFT display and input | `T6.5`, `T6.8`, `T8.2` | ELF inspection plus separately labeled connected-target transcript | pending |
| `SA-AC-025` — nRF binary/RAM/storage/drawing/stack fit evidence | `T6.5`, `T6.8`, `T7.4`, `T8.2` | Link map, ELF, stack/high-water, workspace, and run report | pending |
| `SA-AC-026` — Conforming source replacement changes no portable owners | `T2.3`, `T6.6` | Mock/fixture-source substitution compile and graph comparison | pending |
| `SA-AC-027` — Missing GiftUI behavior fails configuration without reduced UI | `T6.6`, `T7.1` | Each-required-facility negative and zero-publication transcript | pending |
| `SA-AC-028` — Host-owned observation and adapter sink installation | `T3.2`, `T6.1`-`T6.5`, `T6.7`, `T6.8` | Construction/start/stop/teardown owner-call ledger | pending |
| `SA-AC-029` — Exact `1/32/1` fact capacities and first-excess rejection | `T5.1`, `T6.1`, `T7.4` | 28/32/33 ordinary, snapshot 1/2, reserved 1/2 corpus | pending |
| `SA-AC-030` — Nonzero monotonic sequence and ordered at-most-once application | `T5.1`, `T5.3` | Cross-storage seal/apply/post-seal/exhaustion transcript | pending |
| `SA-AC-031` — Exact revisioned mutation replay and mismatch containment | `T1.3`, `T2.2`, `T3.3`, `T7.1` | Full replay, malformed/mismatch, unchanged-model, restart corpus | pending |
| `SA-AC-032` — One portable `@State` identity across reconstruction/profiles | `T4.1`, `T5.2`, `T6.2`, `T6.3` | Source compile plus dynamic/static identity transcript | pending |
| `SA-AC-033` — Exact replacement/removal/reinsertion lifecycle | `T5.2` | Shared dynamic/static lifecycle matrix | pending |
| `SA-AC-034` — Deterministic bounded observable failures without alias/fallback | `T5.2`, `T5.3`, `T7.1` | Capacity/identity/stale/phase/generation fault matrix | pending |
| `SA-AC-035` — Twenty reports coalesce while facts and semantic publication remain complete | `T5.1`, `T5.3`, `T7.4` | Twenty-update dirty/wake/publication high-water transcript | pending |
| `SA-AC-036` — Button callback becomes later fact; executor realizations agree | `T3.1`, `T5.3`, `T5.4` | Reentrancy poison and normalized executor-equivalence transcript | pending |
| `SA-AC-037` — Six qualified actions and total noncapturing handler | `T3.1`, `T4.2`, `T5.4`, `T9.1` | Four-profile compile, source audit, and six-case dispatch transcript | pending |
| `SA-AC-038` — Replacement cancels in-flight dispatch; failed replacement preserves old target | `T5.2`, `T5.4` | Down/admission/replacement interleaving corpus | pending |
| `SA-AC-039` — Embedded typed model/storage/facility/resource evidence | `T5.2`, `T6.5`, `T6.8`, `T7.4` | Generated source, address/layout, forbidden-symbol, timing, RAM/flash/stack reports | pending |
| `SA-AC-040` — Total normalization, mandatory effects, residual policy, and diagnostic independence | `T3.4`, `T7.1` | Exhaustive outcome/effect/policy/projection matrix | pending |
| `SA-AC-041` — Complete 96-byte UTF-8 diagnostic and BoundedText matrix | `T1.1`, `T3.4`, `T9.2` | Dynamic/static construction, borrow, projection, allocation transcript | pending |
| `SA-AC-042` — Exact wrapping CH4 vectors in every profile/host | `T2.3`, `T6.2`-`T6.5`, `T9.2` | Two golden vectors and four normalized host traces | pending |
| `SA-AC-043` — Capture revision exhaustion terminal procedure | `T1.3`, `T2.2`, `T3.4`, `T7.1`, `T7.3` | `UInt32.max - 1/max`, reserved fact, no-policy, quiesce/rebuild transcript | pending |
| `SA-AC-044` — Operational failure structurally contains only failure fact plus semantic diagnostic | `T3.1`, `T3.4`, `T5.1`, `T9.1` | Positive API/layout and negative construction/generated-storage fixtures | pending |
| `SA-AC-045` — Exact SPEC-015 workload/preset/report equality | `T4.3`, `T6.1`-`T6.5`, `T6.7`, `T6.8`, `T7.4` | Descriptor, generated manifest, limits, assembly, extent/region/bounds comparison | pending |

## Milestones and Tasks

### Milestone 0: Freeze Authority, Migration Boundaries, and Evidence Schemas

**Entry conditions:** SPEC-001 is approved; linked Proposal/RFC/ADR/Spec
statuses remain authoritative.

**Exit evidence:** The application boundary, migration dispositions, fixture
schemas, and fail-closed four-profile driver exist before governed behavior is
claimed.

- [x] `T0.1` — Create `Tests/ContractFixtures/SPEC001/` with a README, ordered
      fixture registry, criterion/evidence registry for `SA-AC-001` through
      `SA-AC-045`, task-evidence ledger, semantic/callback/cycle/host/resource
      transcript schemas, and explicit `host-native-fixture`,
      `macos-target-execution`, `cross-build-inspection`, `simulator`, and
      `connected-target-execution` evidence kinds. Encode which criterion
      classes each kind may satisfy. Reject missing, duplicate, unknown,
      contradictory, stale, or unversioned required fields.
- [x] `T0.2` — Inventory every `demo/SignalAnalyzer` source and test plus all
      existing analyzer fixtures in SPEC-007 through SPEC-015. Classify each as
      preserve-as-evidence, adapt, replace, or downstream-owned. Freeze the
      logical Domain -> none, Data -> Domain, Presentation -> Domain/GiftUI/
      GiftUIFailureCore, and host -> all selected owners dependency rules with
      import, package graph, and generated-static equivalents.
- [x] `T0.3` — Create and explicitly register a fail-closed
      `scripts/contracts/run-spec-001.sh` with a required `--profile` argument
      accepting exactly `macos-dynamic`, `macos-static`,
      `raspberry-pi-armv6`, and `nrf52840-embedded`. Preserve each exact
      standalone invocation, record immutable source/fixture/compiler/SDK/
      target/optimization identity, write only below
      `.build/contract-reports/spec-001/` for driver-owned reports, and perform
      no network access, remote deployment, service restart, hardware probe,
      or flashing. When the driver invokes a repository platform build, retain
      the emitted deployable artifacts under `.build/raspberry-pi/` or
      `.build/nrf52840/` and record their paths and digests in the report.
- [x] `T0.4` — Record the implementation prerequisites supplied by SPEC-002
      through SPEC-015 at declaration, focused-owner, profile, backend, and host
      joins. Mark an unavailable prerequisite `missing` rather than copying or
      weakening it inside the analyzer. Add a source-of-truth registry for
      reused SPEC-007-015 fixture inputs so drift fails explicitly.
- [x] `T0.5` — Add governed root-package target and test boundaries for
      `SignalAnalyzerDomain`, `SignalAnalyzerData`, and
      `SignalAnalyzerPresentation`. Place them under root `Sources/` and
      `Tests/`, encode Data -> Domain and Presentation -> Domain/`GiftUI`/
      `GiftUIFailureCore` dependencies in `Package.swift`, and add negative
      dependency fixtures. Leave concrete composition roots and reusable host
      validation in SPEC-015's `GiftUIHostConfiguration`/preset ownership;
      retain `demo/SignalAnalyzer/` unchanged as migration evidence until its
      eventual disposition is separately recorded.

### Milestone 1: Implement Bounded Domain Values and Publication Contracts

**Entry conditions:** Milestone 0 boundaries; required SPEC-002/003/005 value
owners compile for the applicable profile.

**Exit evidence:** Domain exposes the exact bounded values, revisions,
publication changes, sinks, repository contract, and use cases with no
prohibited imports or facilities.

- [x] `T1.1` — Replace string failure state with the exact 96-byte
      `SignalAnalyzerDiagnostic` and construction result. Implement exact and
      truncating UTF-8 validation at scalar boundaries, one-call byte borrowing,
      equality, static inline/caller-owned storage, and Presentation's
      byte-identical total `BoundedText` projection. Add the complete boundary,
      malformed, empty, nonempty failure, allocation, and borrow-lifetime corpus.
- [x] `T1.2` — Implement exact channels, levels, transitions, fixed standard
      ordering, `SignalChannelLevels`, and profile-equivalent `SignalCapture`
      semantics. Provide dynamic bounded storage and static storage of at least
      2,404 transitions plus four baselines; prove invariants, stable order,
      retained reconstruction, value equality, and checked indexing.
- [x] `T1.3` — Implement `SignalCaptureChange`, revisioned
      `SignalCapturePublication`, repository/admission condition values, and
      exact insert/trim/reset replay. Use nonwrapping `UInt32` revision rules,
      bounds at 2,404, revision-zero snapshot semantics, and structural
      representation of the terminal capture-revision failure.
- [x] `T1.4` — Update the two sink protocols, repository protocol, source-facing
      Domain boundary, and five use cases to their exact synchronous bounded
      behavior. Remove `@MainActor`, Foundation/UI/timing/platform requirements
      from Domain, add exact-once delegation/attach/detach tests, and enforce
      prohibited-import and linked-symbol scans for every profile.

### Milestone 2: Implement Repository, Retention, and Deterministic Source

**Entry conditions:** Milestone 1 Domain contract is fixed.

**Exit evidence:** Dynamic and bounded static Data realizations produce the
same capture/state/publication traces and deterministic source vectors.

- [x] `T2.1` — Adapt the repository around checked dynamic/static storage.
      Implement validation, epoch rebasing, stable insertion, duration,
      30-second trimming, oldest-first capacity eviction, baseline updates,
      current levels, and Clear's exact reset mutation. Exhaust empty, boundary,
      equal/out-of-order, newly inserted-and-evicted, and four-state Clear cases.
- [x] `T2.2` — Implement one replaceable sink of each kind with immediate
      revisioned current values, synchronous bounded outcome propagation, weak
      or explicit non-retaining lifetime, detach-before-return, state-table
      actions, source-contract failures, horizon diagnostics, and the complete
      `UInt32.max` terminal procedure. Prove startup failure stops partial
      source activation, publishes one nonempty bounded failed state, and
      throws the same failure or a value carrying the same diagnostic; prove no
      rollback after callback refusal and no later operation on an exhausted
      graph.
- [x] `T2.3` — Separate deterministic source state from host-provided live
      scheduling. Implement four initial lows, CH1/CH2/CH3 patterns, exact
      wrapping CH4 LCG and both golden vectors, checked nonaliasing generations,
      pause/resume conceptual time, accelerated timing, teardown, and a second
      conforming source fixture. Keep clocks/schedulers/tasks outside Domain and
      Presentation and reject generation wrap rather than aliasing.
- [x] `T2.4` — Run the repository/source oracle at the accepted aggregate rate
      for 30 conceptual seconds. Record every input, revision, mutation,
      eviction, sink outcome, state transition, and final capture; require no
      missing, duplicate, reordered, stale, or unexpected fact.

### Milestone 3: Implement Presentation State, Admission, and Failure Ownership

**Entry conditions:** Milestone 1 values; production or contract-faithful
SPEC-003/009/010 admission and mutation seams.

**Exit evidence:** Application callbacks terminate at a non-model adapter,
facts apply only in GiftUI mutation, and every failure follows the exact total
normalization/effect/policy sequence.

- [x] `T3.1` — Implement exact visible-window, view-state, six-action,
      noncapturing action-handler, Presentation-fact, operational-failure,
      observation-start, residual-context, and ViewModel declarations. Keep
      success/operational outcomes unrepresentable in
      `SignalAnalyzerOperationalFailure`; implement initial state, visible
      range, four intents, and model-owned change signaling.
- [x] `T3.2` — Implement `SignalAnalyzerPresentationAdmissionAdapter` with both
      sinks, two use cases, one fact endpoint, idempotent host-started/stopped
      observation, exact callback conversions, two-current-value start result,
      partial-start cleanup, and rejection reporting. Prove it never owns,
      borrows, registers, observes, or mutates a ViewModel.
- [x] `T3.3` — Implement package-scoped mutation-phase fact application.
      Atomically apply snapshots and exact mutations, validate base revisions,
      preserve capture on mismatch, apply state and operational failure, expose
      semantic error text, and emit synchronous owner-dirty reports only for
      changes. Prove callbacks cannot enter these operations directly.
- [x] `T3.4` — Implement the narrow analyzer owner adapter and exhaustive total
      mapping from repository, admission, and runtime conditions into exact
      SPEC-003 outcomes. Apply mandatory effects before constructing only valid
      residual inputs, enforce the selected total policy, reserve the failure
      path, implement invariant/no-policy rows, and prove optional diagnostics
      cannot alter semantic diagnostics, outcomes, effects, policy, or state.
- [x] `T3.5` — Create focused Presentation fixtures for initial state, all fact
      and action cases, thrown/published errors, observation lifetime, exact
      no-op reporting, and source substitution. Verify `startTapped` clears an
      old error before application-executor entry, converts a thrown failure to
      the same bounded diagnostic, and leaves any synchronous repository
      callback admitted for a later cycle. Preserve normalized semantic
      transcripts that can be replayed unchanged by both runtime profiles.

### Milestone 4: Port the Fixed Presentation to GiftUI and Drawing

**Entry conditions:** Milestone 3 declarations; usable approved SPEC-006,
SPEC-007, SPEC-008, SPEC-010, SPEC-011, and SPEC-012 client surfaces.

**Exit evidence:** One portable source hierarchy compiles in every profile and
produces the exact labels, controls, layout workload, and five Canvas
occurrences without platform branches or closure actions.

- [x] `T4.1` — Replace SwiftUI/Observation Presentation with one
      `@ObservableStateHost` GiftUI root containing
      `@State private var viewModel`. Declare header, status, waveform panel,
      CH1-CH4 rows, controls, and error region explicitly; use no dynamic child
      collection, view-started observation, platform branch, runtime import, or
      unsupported client feature.
- [x] `T4.2` — Implement the complete title/subtitle/status/error text and
      exact enabled/disabled table with the six qualified
      `Button(..., action: SignalAnalyzerAction.case)` values. Use only the
      approved opaque color, foreground, background, stack, spacer, padding,
      alignment, and frame surface; record the semantic/layout transcript for
      all acquisition/window/error states.
- [x] `T4.3` — Implement one grid Canvas plus one trace Canvas for each explicit
      channel. Derive ruler labels, 11 vertical/one center line, starting level
      through the lower bound, exact transition filtering and x mapping,
      vertical level changes, right-edge extension, current HIGH/LOW at capture
      duration, and exact SPEC-015 Drawing minima. Compare path/subpath/point/
      stroke transcripts at empty, trim, overflow, edge, and out-of-order cases.
- [x] `T4.4` — Compile byte-identical portable Presentation source through
      dynamic and static declarations. Audit imports, macro output, semantic
      identities, fixed channel/window occurrences, action closure absence,
      model non-retention, and absence of concrete Data, platform, timing,
      renderer, display, input-driver, and hardware dependencies.

### Milestone 5: Join Admission, Observable State, Actions, and Run Cycles

**Entry conditions:** Milestones 3-4; production SPEC-009/010/011/013 owner
seams are implemented for the dependent slice.

**Exit evidence:** Both profiles preserve exact fact order, model lifetime,
action target provenance, mutation/publication atomicity, and 250-millisecond
coalescing behavior.

- [x] `T5.1` — Configure independent snapshot capacity one, compact-fact
      capacity 32, and reserved-failure capacity one. Implement nonzero
      nonwrapping `UInt32` sequencing across physical stores, seal/apply order,
      at-most-once application, post-seal deferral, exact first-excess
      rejection, and the full 28-fact production burst without replacement or
      coalescing of facts. Separately prove the `20`, `2`, and `6` producer
      category bounds, all 32 physical compact slots, physical fact 33, and
      rejection of each category excess as an incompatible host workload
      rather than spending the four-slot margin.
      **Completed:** the host-owned fixed-storage kernel enforces exact
      `1/32/1` physical stores, `20/2/6` producer limits, one nonzero
      nonwrapping sequence across stores, ordered sealing, post-seal deferral,
      at-most-once removal, quiescence, and discard. The application-specific
      `SignalAnalyzerHost` target now owns the Dynamic production
      `SignalAnalyzerPresentationFact` classifier, producer-context gate, and
      exact application rejection mapping. The composition join applies sealed
      facts exactly once in `RuntimeCompletePipeline` mutation order and proves
      that post-seal facts wait for the next opportunity. A Static direct-
      dispatch handle now uses caller-owned fixed storage and shares the same
      classifier/sequencer core; normalized cross-store transcripts match the
      Dynamic endpoint exactly. The integrated profile comparison joins both
      endpoints to identical wake and cycle behavior.
- [x] `T5.2` — Bind the root to one observable location, active registration,
      dirty/live bit, and transient replacement record. Run identical dynamic/
      static fixtures for initializer preservation, atomic replacement,
      candidate failure, derivation failure, published removal, reinsertion,
      stale reports, duplicate ownership, incompatible association, and
      generation exhaustion; inspect static address-stable typed storage.
      **Completed:** the production profile workspace allocates its first
      target generation at raw zero without using that valid value as an
      exhaustion sentinel. An explicit optional exhausted state rejects before
      staging a location in the inline Static store. The same workspace cursor
      now reserves replacement generations for exact live keys, spends a
      discarded reservation without changing the live generation, commits a
      successful reservation atomically, and prevents a later reinsertion from
      aliasing either value in both profiles. Dynamic profile typed
      storage now consumes the first initializer, preserves it across repeated
      transient wrappers, routes assignment without directly replacing stored
      state, and rejects rebinding one wrapper. Static profile caller-owned
      inline typed storage now performs the same initializer preservation and
      assignment routing within one attempt-scoped direct binding whose wrapper
      and pointer cannot escape. Both typed stores also own exactly one separate
      candidate-model position: a second stage is rejected, commit swaps only
      after staging, and discard preserves the live model. Shared production
      conformance transcripts prove these Dynamic and Static mechanisms expose
      equal materialization, preservation, read, assignment-routing, staging,
      commit, discard, and stored-model results.
      A narrow replacement bridge now exposes supplied-generation begin,
      candidate report/return validation, commit/discard, live report,
      dirty-clear, and retirement operations while keeping SPEC-010's focused
      replacement transaction internal as required.
      A focused package registration bridge now composes the existing finite
      lifecycle into single sink issuance, attach-time report poisoning, exact
      attachment-return activation, stale-report rejection, retirement, and
      shutdown for later address-stable roots. The bridge also owns the common
      mutation-phase check and one-bit dirty/coalesced transition, avoiding a
      second Static report algorithm. The Dynamic profile now composes
      that bridge and typed storage in one stable owner: initial attachment,
      preserved rebinding, mutation-phase dirty/coalesced reports, attach-time
      cleanup, and retirement are integrated. It now also composes the focused
      replacement bridge with the candidate model slot: successful candidate
      attachment commits before former detachment, while attach-time failure
      discards only candidate state and preserves the live model and route.
      A Dynamic root adapter now joins
      that owner to the production structural workspace, so the workspace's
      nonaliasing generation zero drives attachment, candidate discard retires
      candidate-only state, and published absence retires live state. Its
      replacement join validates the focused transaction before reserving,
      supplies the workspace's exact reserved generation to candidate
      attachment, commits that reservation only with the typed registration,
      and discards a failed candidate without changing the live generation.
      Thus validation failure spends no generation, while attach-time failure
      spends the discarded candidate generation and the next successful
      replacement cannot alias it. Static
      composition now has a separate inline registration record with the same
      attachment, attach-time-report, phase, dirty/coalesced, retirement, and
      shutdown behavior; keeping it separate from typed model storage permits
      generated direct dispatch without recursive access to one movable value.
      That record now also owns the one transient replacement bridge and sink-
      issuance bit. It preflights without mutation, activates the candidate
      route before retiring the initial route, projects replacement dirtiness,
      and discards an attach-time-poisoned candidate while the inline live
      model and registration remain active.
      A normalized production conformance fixture now drives both registration
      realizations through initial dirtied/coalesced reports, successful
      generation-1 replacement, a post-commit coalesced report, and a poisoned
      generation-2 candidate. Their exact outcomes, retained model identity,
      live state, and dirty state match; the fixture also corrected Dynamic's
      active-state projection to follow its committed replacement route.
      Both profile registration owners now drop a retired replacement bridge
      only at the no-attachment reinsertion boundary. Dynamic root coverage
      proves committed replacement, published removal, fresh generation-2
      materialization with clear dirtiness, and a later generation-3
      replacement. Static record coverage proves the matching fresh initial
      route and clean dirty bit after replacement retirement.
      The checked SPEC-015 generator now projects the immutable portable
      hierarchy into one Static-root descriptor for both Static presets. Its
      nonzero `UInt32` structural identity derives from the hierarchy input;
      declaration ordinal zero, two typed model positions, and `1/1/1`
      location/registration/replacement capacities are generated values rather
      than runtime negotiation. Dynamic presets carry no Static descriptor.
      Static typed storage now provides the root's ownership-safe initial
      operation: it binds and materializes inline storage, obtains exactly one
      sink through a nonescaping factory over the separate registration
      record, attaches and validates it, ends model mutation, and only then
      evaluates the bound `State` body. Attach-time poisoning suppresses the
      body and removes the partially materialized model.
      A Static root adapter now consumes one fixed structural identity and
      declaration ordinal and joins that inline storage and registration
      record to the production Static workspace. It materializes or preserves
      the typed model, publishes or discards candidates, retires published
      absence, reinserts with a fresh generation, and coordinates atomic
      replacement with the workspace reservation. Preflight failure spends no
      generation. Generated-root-compatible `SignalAnalyzerViewModel` direct
      reporting and target dispatch now operate through the caller-owned,
      address-stable root for the complete integrated opportunity. A normalized
      production root transcript proves equal Dynamic
      and Static materialization, preservation, dirty/coalesced reporting,
      replacement, published removal, and fresh generation-2 reinsertion.
      Its paired failure transcript proves identical incompatible-association,
      duplicate-owner, registration-capacity, replacement-capacity, and
      initial/replacement-generation-exhaustion results. All four preflight
      failures leave generation 1 available, and exhaustion preserves the
      live `UInt32.max` generation and model.
      The normalized corpus also proves that discarding a later derivation
      which omits the root preserves an already committed replacement, its
      generation-1 registration, and dirty state; the next encounter preserves
      that same model in both profiles.
- [x] `T5.3` — Integrate admitted facts and semantic actions with the serialized
      mutation phase, freeze, complete-root derivation, publication, wake, and
      paced retry owners. Prove 20 change reports become one dirty transition
      and at most one wake while every fact applies, frames see one complete
      revision, and same-thread/distinct-executor callbacks never reenter the
      active mutation.
      **Completed:** the Dynamic application endpoint, fixed host sequencer,
      wake pacing, real analyzer model, Dynamic observable root, and complete
      pipeline now run one 20-fact burst. All facts apply once after the paced
      boundary, the first admission alone requests a wake, 20 model reports
      produce one clean-to-dirty transition, and derivation publishes only the
      final state in one semantic revision. Successful joint publication now
      clears the observable dirty epoch in both production profile roots;
      cross-profile evidence proves the next mutation can dirty once again.
      The production Dynamic Start dispatch now also drives equal same-thread
      and deferred application callbacks: each returns through sequenced fact
      admission while the observable model remains unchanged, and only later
      fact application installs the running state.
      A normalized Dynamic/Static integrated opportunity now applies all 20
      facts, dispatches one semantic action, produces one dirty transition,
      traverses Drawing/render/interaction, publishes one complete revision,
      and compares accepted-frame and retryable-refusal dispositions. Static
      change reporting uses the generated-root-compatible direct route; both
      profiles leave exactly one paced wake after retryable refusal.
- [x] `T5.4` — Bind the six-action handler to the current model generation at
      the runtime coordinator. Exhaust exact dispatch, no capture/retention,
      pointer-down and admitted-action replacement, removal, failed/staged
      replacement, stale action generation, disabled state, and final target
      revalidation; require at-most-once dispatch to the exact current model.
      **Completed:** both production root adapters provide one atomic
      generation-matching model borrow for final dispatch revalidation. A
      stale requested generation invokes no body; replacement invalidates the
      former generation and permits only the current generation to borrow the
      new model. Profile target-access adapters now expose that operation to
      the existing runtime dispatcher. Dynamic keeps only a weak root
      reference; Static copies one typed pointer whose lifetime remains owned
      by the generated address-stable root, so copied handles preserve storage
      identity without model retention. The application-specific Dynamic
      composition now installs the concrete `SignalAnalyzerActionHandler`,
      production dispatcher, and weak production root access. Its corpus
      dispatches all six exact actions, rejects invalid codes without model
      mutation, cancels stale action/target generations, and cancels a captured
      former action after real root replacement. Static analyzer composition
      now installs the same handler and dispatcher through a typed pointer to
      the generated-root-compatible address-stable model owner, and all six
      exact actions reach the same intents.
      A production-dispatcher transcript now proves equal initial dispatch,
      preservation of former dispatch after incompatible replacement failure,
      cancellation of a captured former generation after successful
      replacement, exact current-replacement dispatch, and cancellation after
      published removal.
      The final profile-equal interleaving corpus covers pointer-down and
      activation-admitted capture across replacement, published removal,
      replacement-staging failure, disabled state, and final revalidation.
      Replacement cancels both captured actions without invoking either model;
      failed staging preserves and dispatches only the former target.
- [x] `T5.5` — Produce one normalized integrated cycle transcript containing
      callback, admission, seal, application, change report, dirty/wake,
      semantic publication, Drawing, offer, and frame events. Compare all
      profile-independent fields across dynamic and static realizations.
      **Completed:** the checked-in accepted and retryable-refusal rows plus
      the executable normalized comparison cover every named event family and
      match all profile-independent fields.

### Milestone 6: Assemble and Validate the Four Target Hosts

**Entry conditions:** Applicable Milestones 1-5 and production SPEC-014/015
owner seams. Missing downstream owner work blocks only its dependent host
slice and remains explicit.

**Exit evidence:** Each exact SPEC-015 preset builds a single analyzer graph,
uses the shared Presentation, and emits an immutable assembly/execution report.

- [x] `T6.1` — Feed the checked-in portable hierarchy descriptor into the
      SPEC-015 generator/validator. Prove exact six actions, one model/input
      owner, `1/32/1` stores, 28-fact burst, five Canvas occurrences/strokes,
      202 live points, 12 live subpaths, 832 snapshot points, 16 snapshot
      subpaths, runtime limits, and one-owner acyclic graph before constructing
      any host. For every preset, require both the Drawing B2 structural gate
      and the independent SPEC-004 `rasterPresentation` capability gate before
      owner construction; neither may substitute for the other. Keep adapter
      installation before acquisition and observation start/stop solely in
      host lifecycle.
- [x] `T6.2` — Assemble and execute the macOS dynamic host with the deterministic
      source, dynamic runtime, complete GiftUI client surface, full-surface
      backend, input, clock/scheduler, owner adapter, and host pacing. Record
      normalized state/action/drawing/frame output and resource/cadence data.
      **Completed:** `SignalAnalyzerMacOSDynamic` links the shared portable
      Presentation and production Dynamic host owners, validates the exact
      preset, and emits the registered normalized hardware-free report. The
      focused Milestone 5 cycle and host-lifecycle suites remain the detailed
      state/action/Drawing/frame and pacing transcript; the executable report
      binds that evidence to the concrete preset and 41,376-byte profile
      storage audit.
- [x] `T6.3` — Generate, compile, and execute the macOS static host from the
      same portable Presentation and exact preset. Inspect generated model,
      action, Canvas, fact, and workspace storage; compare its normalized
      application transcript with `T6.2`.
      **Completed:** `SignalAnalyzerMacOSStatic` consumes the generated Static
      root descriptor, checks its two typed model positions and exact `1/1/1`
      observable capacities, and runs the identical semantic script through
      caller-owned fixed fact storage. Its checksum equals T6.2 while the
      report preserves the approved 36,368-byte Static profile total. Evidence
      and reproduction commands are in the shared macOS preset record.
- [x] `T6.4` — Assemble the Raspberry Pi 1 dynamic preset with exact 240 x 240
      extent and 240 x 16 RGB565 tiled region. Cross-build only for
      `armv6-unknown-linux-gnueabihf` through
      `scripts/raspberry-pi/build.sh --product`, passing the exact executable
      product delivered by SPEC-015's Raspberry Pi preset task. Require its
      ELF, ARMv6, and hard-float checks, record the emitted `ARTIFACT=` path
      and digest, inspect dependencies/resources, and keep connected PiScreen
      execution for `T8.1`.
      **Completed:** the exact product is `SignalAnalyzerRaspberryPiARMv6`.
      The repository workflow emits and inspects the ARMv6 artifact while the
      registered host-native fixture binds the equal semantic checksum to its
      exact 240 x 240 / 240 x 16 projection. Artifact identity, linked
      dependencies, profile storage, and the open connected PiScreen gate are
      recorded in the Milestone 6 ARMv6 evidence.
- [x] `T6.5` — Assemble the `nrf52840dk/nrf52840` static preset with exact
      480 x 320 extent, 480 x 4 RGB565 region, 960-byte row, and 3,840-byte
      raster/payload/in-flight bounds. Cross-build through
      `scripts/nrf52840/build.sh --application`, passing the exact application
      delivered by SPEC-015's nRF52840 preset task, with the bundled
      `armv7em-none-none-eabi` module and Zephyr Cortex-M4F hard-float flags.
      Record emitted `ELF=`, `HEX=`, `MAP=`, `DEVICETREE=`, and `REPORTS=`
      paths and digests, verify VFP ABI, storage and forbidden symbols, and
      keep flashing for `T8.2`.
      **Completed:** the exact application is `signal-analyzer-static`. Its
      final ELF retains the Swift preset entry, generated-profile storage,
      two complete 2,404-transition application stores, and one exact staging
      slot while remaining within RAM/flash budgets with both heaps disabled.
      The registered report records every emitted artifact class, ABI,
      symbols, storage, and resource totals; the equal host-native transcript
      remains explicitly separate from uncollected connected execution.
- [x] `T6.6` — Replace the mock with the conforming fixture source without
      changing Domain, use cases, adapter, ViewModel, or portable hierarchy.
      Separately fault every required GiftUI/host facility and prove validation
      fails before publishing a reduced or target-specific analyzer.
      **Completed:** the independent `SignalDataSource` fixture substitutes at
      the repository initializer and reaches the common publication contract
      without changing any portable owner. The ordered validator corpus faults
      all nine required facility stages independently, records zero side
      effects, and proves later stages are not accessed. Evidence is in
      `Tests/ContractFixtures/SPEC001/Evidence/milestone-6/source-and-facility-substitution.md`.
- [x] `T6.7` — Replace the Raspberry Pi proof-only executable path with the
      production target-host composition required by SPEC-001. Keep the
      portable Presentation unchanged; compose the accepted Dynamic runtime,
      240 x 240 / 240 x 16 RGB565 endpoint, Linux framebuffer submission,
      normalized PiScreen input, clock/scheduler, application owners, pacing,
      activation, and teardown at the executable boundary. Add hardware-free
      device-adapter fixtures for format/stride/extent validation, partial
      initialization cleanup, normalized input provenance and calibration,
      six-action routing, stale-event rejection, frame offer/drain behavior,
      and exact owner cardinality. The ARMv6 build must retain the existing
      ABI/resource checks and must not access or deploy to a remote target.
      **Completed:** the target-owned `GiftUIPlatformRaspberryPi` boundary
      now provides the exact 240 x 240 / 240 x 16 RGB565 synchronous display
      target, validated 16-bit framebuffer layout, 480 x 320 aspect-fit
      projection, calibrated touch mapping, and one-contact sequencing. Its
      fake-sink tests cover invalid format/stride/mapping, canonical byte and
      physical-bound preservation, transport refusal, letterbox rejection,
      and ordered down/move/up behavior. A Linux-only implementation now owns
      framebuffer sysfs validation, an mmap lifetime, native RGB565 writes,
      nonblocking evdev reads, and explicit device teardown. The exact product
      cross-builds as an ARM EABI5 hard-float executable and exposes a bounded
      `--inspect-piscreen` device-readiness mode. The separately authorized
      device-readiness run verified `armv6l`, deployed the exact artifact
      without a service restart, and opened an accessible 480 x 320 RGB565
      framebuffer plus `/dev/input/event0`; see the
      [platform-adapter evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/piscreen-platform-adapter.md).
      A second bounded connected adapter run synchronously accepted and
      flushed the exact fifteen 240 x 16 payloads / 115,200 RGB565 bytes and
      kept the input poll operational. The user confirmed the gradient was
      physically visible and reported the framebuffer console's blinking
      underscore overlay after process exit. Production console-mode ownership
      now retains the prior Linux console mode, enters graphics mode before
      constructing framebuffer or input devices, and restores that mode after
      host-loop teardown. Hardware-free fixtures cover partial acquisition,
      restoration failure, preexisting graphics mode, and idempotent cleanup;
      the ARMv6 product cross-build verifies the Linux ioctl binding. Physical
      permission and cursor-suppression proof remains in T8.1. The completed
      production-stage join is defined by the
      [Connected-Target Host Loop design](../implementation-designs/spec-001-connected-target-host-loop.md).
      Its first production-store slice now preserves bounded structural,
      layout, render, Canvas, action, and disabled-scope facts from one Dynamic
      semantic traversal with atomic first-excess cleanup; see the
      [Dynamic semantic-storage evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-semantic-host-storage.md).
      Exact state-bound traversal then measured 47 semantic nodes, 14 body
      evaluations, 5 modifiers, 6 actions, depth 26, 80 structural identities,
      and 5 Canvas occurrences; the diagnostic-present maximum is 48 semantic
      nodes and 81 structural identities. The maintainer reapproved SPEC-013
      and SPEC-015 schema 3 on 2026-09-20. Generated depth 26 and independent
      structural capacity now admit the exact state-bound tree, resolving that
      blocker; see the [resolution evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-semantic-preset-blocker.md).
      The next production slice joins that semantic result to the real layout
      engine and atomic Dynamic resolved-layout storage. It measures a
      diagnostic-present maximum of 53 layout scopes. The maintainer approved
      that measured capacity on 2026-09-20; the regenerated schema-3 preset now
      admits the exact production join, resolving the former capacity blocker.
      See the [layout resolution evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-layout-preset-blocker.md).
      The portable hierarchy now realizes the approved 21 foreground and 9
      rectangular-background roles plus bounded padding and a waveform frame.
      Its final checked diagnostic maximum is 48 semantic nodes, 50 modifiers,
      semantic depth 34, 126 retained expansion identities, 98 layout
      scopes, and layout depth 13; see the
      [surface measurement](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/portable-surface-measurement.md).
      The semantic store now publishes a coherent 98-scope render-only tree.
      With separately labeled measurement capacities, real render preflight
      and streaming cover every render/layout scope and produce 30 ordinary
      operations, 129 positioned glyphs, and clip depth 3. A production
      Dynamic drawing-plan workspace then derives all five Canvas strokes;
      Canvas-aware streaming completes with 35 total operations. The
      maintainer approved the measured SPEC-008/SPEC-013/SPEC-015 values on
      2026-09-20, and the regenerated exact preset now admits the complete
      production join. The projection, Canvas-integration, and capacity
      blockers are resolved; see the
      [render capacity evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-render-projection-blocker.md).
      Dynamic Canvas ownership and the diagnostic plan census are recorded in
      the [drawing-plan evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-drawing-plan-workspace.md).
      The real observable, semantic, layout, Canvas, and combined-render
      stages now live together in the production `SignalAnalyzerTargetHost`
      module. Its reusable pipeline is initialized from the exact generated
      Dynamic limits and reproduces the approved diagnostic maxima on
      consecutive cycles. Endpoint offer, interaction candidate formation,
      pacing, and lifecycle ownership are recorded by later slices below; see
      the
      [target-host pipeline evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-target-host-presentation-pipeline.md).
      The pipeline now also derives the six real action occurrences from the
      published semantic and resolved-layout candidates, stages them through
      the production Dynamic interaction state, preserves generations across
      unchanged accepted presentations, performs hit testing, and dispatches
      through the final observable target-generation guard. The subsequent
      endpoint-production stage is recorded below; see the
      [interaction join evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-target-host-interaction.md).
      Backend Integration now supplies the previously missing production
      display-owning operation-major RGB565 offer session. Focused evidence
      proves exact reservation, synchronous one-shot consumption, painter-
      ordered tile payloads, one frame finish, and pre-transfer cancellation.
      The remaining endpoint work is therefore the target-host call-site join,
      not another backend realization; see the
      [production session evidence](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-7/production-operation-major-session.md).
      The target-host pipeline now owns that call-site: it streams the retained
      semantic/layout/drawing candidate through `CanvasRenderProducer` inside
      one endpoint offer, preserves the exact producer error, and returns the
      authoritative offer for interaction resolution. Dynamic-profile proof
      observes the full 35-operation / 129-glyph / 5-stroke stream before
      committing all six actions. Concrete Pi endpoint construction and the
      executable lifecycle loop are recorded by later slices below; see the
      [interaction and endpoint-offer evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-target-host-interaction.md).
      The exact Pi endpoint factory now composes the 7,680-byte Dynamic tile
      store, reference bitmap resource, operation-major RGB565 session, and
      real `PiScreenDisplayTarget`. A hardware-free 480 x 320 framebuffer sink
      accepts the complete production candidate through that concrete stack.
      A production initial-presentation owner now binds the generated Dynamic
      limits and validated effective presentation to that stack, enables all
      six actions only after an accepted physical frame, retains ineligibility
      on transport refusal, rejects repeated initial admission, and removes
      eligibility on quiescence. It now consumes already-normalized pointer
      events with exact presentation/source/sequence/ordinal checks and routes
      down/move/up through generation-checked dispatch. Executable application
      ownership now has a bounded pointer-admission seam: the existing host
      normalization gate assigns source/sequence/ordinal/provenance and defers
      model mutation until an application-opportunity gate serializes a drain
      into the production interaction owner. Quiescence closes both admission
      and opportunity execution. Action dispatch now opens the production
      `.action` fact-producer scope, so Start/Stop/Clear repository callbacks
      remain deferred; a real deterministic-source fixture records the four
      bootstrap transitions and running-state fact without synchronous model
      mutation. The Pi presentation owner now reuses the synchronous endpoint
      for later candidates, installs each exact frame provenance, advances the
      physical presentation revision only after offer and interaction commit,
      and rejects the replaced revision as stale. A later serialized
      opportunity now seals and applies deferred repository facts in the
      observable mutation phase, rerenders changed state, and updates input
      correlation only after physical and interaction commit. The unified
      opportunity also dispatches normalized input under observable mutation,
      rerenders direct action changes immediately, and leaves repository
      callbacks produced after the seal for the next opportunity. The PiScreen
      decoder now emits canonical `PointerPhase` values, and its exact decoded
      down/move/up events feed the production coordinator in the hardware-free
      fixture without a translation seam. Linux device-file polling,
      wake/pacing, and the complete seven-step activation/eight-step teardown
      join are implemented by the production executable and lifecycle
      aggregate.
      A production fact-admission decorator now notifies the host loop only
      after bounded repository fact acceptance and stays silent on rejection.
      Its callback and queued input now feed one target-owned pacing state:
      first ingress requests a wake, later ingress coalesces, execution cannot
      begin before the generated frame boundary, and quiescence closes further
      admission. A target correlation owner now reserves every opportunity's
      cycle identity while reserving semantic, candidate-frame, and physical
      presentation identities only for changed publications; idle cycles do
      not create gaps in publication identity. The serialized coordinator now
      owns those reservations, including the changed-publication-only call
      site. The pacing owner now services that coordinator only at the
      generated frame boundary and completes pacing for success or focused
      failure. A bounded decoded-contact ingress now joins PiScreen phases to
      normalized admission and wake coalescing without synchronous model work.
      The ARMv6 executable's typed input pump maps the real nonblocking Linux
      device poll directly into that seam. A production Dynamic Pi lifecycle
      aggregate now delegates all seven activation and eight teardown steps to
      the existing host controller. A production assembly factory now derives
      every projection from the generated Pi preset and completes the checked
      nine-stage validator before any Linux device is opened. Its hardware-free
      fixture accepts the
      first physical frame before input eligibility, invokes the committed
      Start action through normalized admission, services six deferred source
      facts at the generated frame boundary, commits the replacement frame,
      and proves repeated teardown is inert. The ARMv6 executable now exposes
      an explicit production mode that validates before device construction,
      polls touch, advances source deadlines, services paced opportunities
      against `CLOCK_MONOTONIC`, and routes SIGINT/SIGTERM plus loop failures
      through controller teardown. A refusing initial-frame fixture now proves
      partial activation containment after runtime and observation setup,
      followed by complete eight-step cleanup. Linux console ownership retains
      and restores the prior mode around production device lifetime. Final
      evidence reconciliation and the connected application scenario remain
      open; see the
      [lifecycle-owner evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-pi-lifecycle-owner.md).
- [ ] `T6.8` — After the concrete nRF52840 TFT/input assembly is explicitly
      selected, replace the preset-only firmware entry with the production
      Static target-host composition. Keep the portable Presentation
      unchanged; compose the generated Static root, exact 480 x 4 RGB565
      one-slot endpoint, synchronous borrowed display submission, normalized
      input, clock/scheduler, application owners, watchdog-aware pacing,
      activation, and teardown at the firmware boundary. Add hardware-free
      HAL fixtures for initialization/cleanup, payload lifetime, six-action
      routing, stale-event rejection, display/input failure mapping, and exact
      storage/resource accounting. The checked build must preserve the VFP
      ABI, zero-heap, no-full-framebuffer, RAM/flash, and forbidden-symbol
      gates and must not flash a board.
      **In progress:** the concrete assembly is now the
      `nrf52840dk/nrf52840` plus 480 x 320 ILI9486/ADS7846 PiScreen. The first
      hardware-free slice installs application-local Devicetree bindings and
      pin/frequency selection, safe-state display and touch drivers, bounded
      480 x 4 / 3,840-byte RGB565 submission, raw touch acquisition, and
      saturating fault accounting. The exact pristine firmware build retains
      all driver entry points and passes ARMv7E-M hard-float, zero-heap,
      RAM/flash, and required-symbol gates. Static host-loop composition,
      calibrated polling-loop activation, connected stack measurement, and
      flashing remain open. A
      target-local,
      allocation-free
      touch normalizer
      now validates injected calibration, maps swapped/inverted raw axes into
      the 480 x 320 logical extent, emits ordered down/move/up phases, closes
      out-of-range contacts, and resets without an action-producing up event
      after transport failure. Its C99 fixture is part of the nRF SPEC-001
      driver. A Static application-host coordinator now passes those phases
      through the shared normalized input gate, assigns source, presentation,
      sequence, and ordinal provenance, and retains the generated six-event
      maximum in fixed inline ring storage. Its host fixture proves ordered
      drain, first-excess cancellation, reuse, stale-presentation rejection,
      and quiescent cleanup without treating that host run as embedded
      evidence. The coordinator now owns the same application-opportunity gate
      as the Dynamic host: no package API can remove queued input outside that
      serialized opportunity, and each removed event receives a total consumed,
      dispatched, or cancelled/rejected classification. The production Static
      application input owner now retains capture and provenance as fixed value
      state across serialized opportunities while borrowing the generated
      interaction state and observable root only for one synchronous drain. It
      uses the generated root descriptor's exact `UInt32` structural identity
      type and value rather than narrowing that identity at the input boundary.
      It installs each physical presentation atomically in admission and dispatch,
      brackets dispatch with observable mutation ownership, and applies actions
      only through the committed target-generation guard. Host fixtures prove a
      down/up pair split across opportunities, stale-generation cancellation,
      replacement cancellation, dirty reporting, and complete quiescence.
      A production Static nRF assembly validator now binds the generated preset
      and storage audit to the exact 480 x 320 RGB565 endpoint, one 480 x 4 /
      3,840-byte synchronous-borrow slot, fixed component graph, six-action
      domain, `1/32/1` admission cardinality, input/wake boundary, pacing, and
      residual policy before any device or application owner is constructed.
      Its host fixture proves the immutable report and remains distinct from
      Embedded Swift or connected-target evidence. A caller-owned,
      noncopyable Static application aggregate now accepts only that exact
      report and constructs the generated `UInt32` root, six-action/six-region
      interaction stores, and input owner together without activating them.
      Host checks prove another target report is rejected and the generated
      interaction limit is neither narrowed nor enlarged. The aggregate now
      lends its disjoint fields to a scoped address-stable application owner.
      That owner materializes generation-zero model storage from the generated
      root descriptor, retains the direct change-report route only for the
      aggregate's stable lifetime, dispatches normalized input through the
      committed interaction, and automatically quiesces input plus publishes
      structural root removal before the scope ends. Its host fixture proves
      one action mutation, dirty reporting, model detachment, and empty input
      cleanup. The scoped owner now accepts the one concrete acquisition
      repository and constructs the exact Start, Stop, and Clear use cases plus
      `SignalAnalyzerViewModel` itself. The bound model retains that repository
      after the caller releases its reference, and structural root removal
      releases it before the aggregate's stable-address scope ends.
      The same aggregate now owns fixed Static fact-admission storage. Model
      binding constructs the capture/state observation adapter from that exact
      repository, and an explicit later activation step starts both observations
      under the generated two-fact bootstrap producer bound. Repository
      callbacks terminate at sequenced fact admission and do not mutate the
      bound model synchronously. Scope teardown stops both observations,
      quiesces and discards admitted work, and only then detaches the root.
      A later explicit Static application opportunity now seals the admitted
      batch, applies every fact once through `SignalAnalyzerViewModel.apply`
      under observable mutation ownership, and returns the bounded fact count
      plus aggregate changed state. Repeating the opportunity without new
      admission applies zero facts.
      Static input dispatch now brackets the complete normalized drain with
      the bounded action-fact producer. Synchronous Start, Stop, and Clear
      repository callbacks therefore terminate at admission, leave the model
      unchanged during action dispatch, and apply in sequence only at the next
      fact opportunity; unavailable producer ownership rejects before removing
      queued input. After first presentation, one combined Static application
      opportunity now seals and applies the previously admitted repository
      batch before it dispatches input and returns both bounded summaries. The
      six-event Start/Stop/Clear fixture proves the action callbacks are absent
      from that opportunity and become the next opportunity's three ordered
      facts; bootstrap application remains the explicit pre-presentation step.
      The firmware's formerly stale pre-amendment profile reservation is now
      reconciled to the generated 36,368-byte Static audit. Its entry validates
      the resulting 155,600-byte named application-storage total, the build
      gate verifies the exact linked size of all three named stores, and the
      SPEC-015 report derives those sizes from the inspected ELF. The pristine
      build remains below the approved RAM/flash ceilings with both heaps off.
      A noncopyable, allocation-free region map now partitions the existing
      caller-owned 36,368-byte firmware reservation into all sixteen generated
      profile families. Host tests prove exact-capacity refusal, field-by-field
      audit equality, and that attempt reset clears 28,224 attempt-local bytes
      while complete reset also clears all 8,144 retained bytes. Caller-supplied
      storage avoids materializing this workspace as a large stack temporary.
      An exact-assembly-gated factory now joins that map, the generated root
      identity and limits, and caller-supplied generated Canvas metadata into
      the common `StaticRuntimeProfileBinding`. A host fixture proves audit
      equality plus begin/finish/quiesce lifecycle resets without presenting
      its fixture callable table as production generated-source evidence. The
      join now also requires the concrete table's dense case count and greatest
      capture record to exactly equal the generated workload's `2 / 32`
      metadata, rejecting an otherwise valid underfilled table.
      One noncopyable runtime-storage aggregate now constructs the application
      storage and profile binding from that same exact report and lends both
      through a single address-stable lifetime scope with common quiescence.
      The same aggregate now owns the shared wake/pacing controller initialized
      from the generated 250-millisecond policy and an explicit monotonic frame
      origin; its scoped lifetime quiesces with the application and profile.
      A Static application-stage service now enters only at that frame boundary
      and completes pacing after application failure as well as success; the
      host fixture proves no-work, early wait, failure completion, and a later
      reusable wake. Full presentation still follows as a separate pending join.
      The finite nRF device entry now times display transfer through a linked
      checked 64-bit monotonic-microsecond clock seam. A C99 fake-kernel
      fixture covers conversion and invalid/overflow inputs; the direct
      hardware-free build passes at 184,128 RAM and 34,496 flash bytes.
      The production metadata envelope now supplies the preset's one exact
      observable slot, six-action specialization, and dense two-case Canvas
      coverage around a caller-supplied generated callable table; host
      validation rejects incomplete table coverage before storage construction.
      The approved address-stable observable-model handle now preserves a
      generated callable's typed drawing failure while its model borrow remains
      scoped, so trace dispatch does not need to copy or retain model state.
      A checked generated table now provides the two dense Canvas cases: an
      empty grid capture and one exact 32-byte trace capture containing the
      stable model handle, channel, and millisecond range. Its direct switch
      dispatches the existing grid and trace helpers, while a manifest and
      contract checker pin all five source occurrences, field offsets, and
      capture bounds. Runtime-storage integration now consumes this production
      table instead of a test stand-in. A generated presentation-input stage
      now selects the exact normal or diagnostic semantic high-water summary,
      reserves those candidate limits once per active profile opportunity, and
      produces all five fixed Canvas captures from one synchronous stable-model
      borrow. The generated semantic writer now fills the exact 96/98-scope
      portable hierarchy, all action/Canvas associations, primitive and
      modifier payloads, and UTF-8 text ranges inside the unchanged 3,024-byte
      region. Host-oracle tests seal both complete version-2 tables and a
      96-byte diagnostic; the generated table now also stages through the
      attempt-local production region with checksum, topology, action, and
      Canvas validation. A separate version-2 publication path now retains
      exact validated candidate bytes and rejects stale/corrupt replacement
      without changing the prior revision. The full layout/render presentation
      transaction and firmware owner join remain open. A
      validated borrowed version-2 render view now matches the portable
      Dynamic projection's exact scope kinds, stable identities, and child
      links in both variants. The region owner now lends that reader only
      during validated candidate/published storage lifetimes. A companion
      version-2 layout reader now matches every portable primitive, child,
      modifier, and text scalar query in both variants. Production scoped
      lending now follows candidate/published region lifetimes; the full
      layout/render transaction remains open. A paired borrow now exposes
      both readers over one validated region lifetime. The common Static
      layout validator accepts the normal generated hierarchy. Its former
      139-scalar/glyph nRF preset rejected a permitted 96-byte diagnostic that
      requires 214 scalars/glyphs. The approved 2026-09-21 SPEC-015/SPEC-001
      amendment raises all four preset layout/render/sink ceilings to 224.
      The descriptor and four generated presets now carry that exact value;
      the common Static layout validator accepts both the normal hierarchy
      and the 214-scalar maximal diagnostic. The full layout/render transaction
      remains open. The follow-up full Dynamic Pi pipeline test measured 27
      lines for 96 printable `W` bytes and 117 lines for 96 LF bytes; the
      approved SPEC-015 line ceiling is now 128 in all four presets. No
      diagnostic truncation is permitted. The Static nRF generated candidate
      host fixture now stages and validates 96-byte `A`, `W`, and LF
      diagnostics across separate profile opportunities, preserving prior
      publication on refusal. Resolved Static layout publication remains open.
      The common Static
      profile binding now also lends each
      generated region only during its registered retained or attempt-local
      lifetime, giving those focused stages direct bounded workspace access
      without exposing or duplicating the complete profile buffer. The firmware
      now compiles the exact shared input values,
      sequence allocator, normalized gate, Static coordinator, and typed ABI
      into its Embedded Swift object. A retained C bridge forwards only phase,
      logical point, observed presentation, and physical resynchronization
      proof; Swift alone assigns source, sequence, and ordinal provenance. C
      and Swift host fixtures cover the ABI, while a pristine build retains
      every bridge symbol and passes the existing zero-heap and resource
      gates. The firmware bridge now stores that ABI in one fixed global owner,
      binds its source exactly once, and mutates it in place through
      presentation installation, admission, and quiescence rather than copying
      coordinator state out of optional global storage on every call. Host
      tests cover pre-initialization refusal, duplicate initialization,
      stable-owner mutation, pending-state retention, and quiescence; the exact
      Embedded Swift build preserves the established ABI and resource gates.
      The production application input owner now embeds this exact firmware
      storage and delegates its serialized opportunity drain to it, eliminating
      the former parallel coordinator state before the larger composition is
      linked. The shared storage is now noncopyable, and a compiler-negative
      fixture rejects explicit duplication before the exact Embedded Swift
      build proves the global form remains supported. This is still the
      firmware-owned input lifetime only; the
      generated root, interaction, rendering, and endpoint aggregate remains
      to be linked. An
      allocation-free production touch pipeline now joins the exact
      normalizer to that bridge for injected calibration and committed
      presentation revision. It suppresses contact after transport or bridge
      failure until release is physically observed, and only then supplies
      resynchronization proof for a later down. Its hardware-free fixture
      covers the complete raw-sample-to-Swift-ABI seam without claiming
      unmeasured shield calibration. A follow-up finite firmware entry now
      initializes both devices,
      transfers bounded color bars, polls touch for ten seconds, and reports
      faults plus stack high-water when deliberately flashed; its exact
      pristine build also passes. Both controllers now expose explicit
      shutdown operations; partial display initialization rolls back to safe
      GPIO state, and the finite entry performs reverse-order cleanup on every
      post-initialization failure and normal return while preserving the first
      failure. The pristine firmware retains both shutdown symbols and passes
      all existing ABI, zero-heap, no-full-framebuffer, RAM, and flash gates.
      It has not been flashed because physical
      shield provenance, continuity/orientation, and power gates are not yet
      evidenced. See the
      [TFT/input adapter evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/nrf52840-tft-input-adapter.md).
      The remaining production-stage join is defined by the
      [Connected-Target Host Loop design](../implementation-designs/spec-001-connected-target-host-loop.md).
      The exact packed workspace/result ownership for the next Static layout
      slice is drafted in the
      [nRF Static Layout Records design](../implementation-designs/spec-001-nrf-static-layout-records.md);
      its first 32-byte scope codec passes exact-region, placement, overflow,
      duplicate, and corruption tests. Fixed 16-byte line and 10-byte glyph
      codecs now pass exact-range and scratch-isolation tests. The workspace,
      derived clips/indexes, and complete layout/render join remain open. The
      common Static profile owner now lends the exact disjoint 3,136-byte
      layout and 4,704-byte render regions together only during an active
      attempt and clears both on finish. A fixed-region Static layout workspace
      now implements the common workspace protocol over those exact ranges;
      focused host tests prove scoped geometry/text storage, derived fields,
      duplicate rejection, and reset. An in-place resolved-layout sink now
      verifies workspace records, publishes only a complete result, and lends
      a checked view until the next layout acquisition; focused host tests
      cover success and refusal. An attempt-scoped three-region borrow now
      runs the generated normal and three 96-byte diagnostic hierarchies
      through the common full layout pass, including in-place publication.
      The production Static nRF layout entry now supplies the exact 480 x 320
      proposal, reference text metrics, and generated limits; the eight-case
      hierarchy fixture exercises it with the fixed workspace and sink.
      Render/Canvas consumption and firmware join remain open.
      The fixed Static render traversal workspace now uses only the 416-byte
      scratch tail of the same render region; host tests prove visit/foreground
      bounds and isolation from the published layout records. Render preflight
      and operation production remain open.
      The next fixed-region Drawing join follows the
      [nRF Static Drawing Records design](../implementation-designs/spec-001-nrf-static-drawing-records.md).
      Its first production slice implements the exact 3,280-byte live-path
      region and passes scoped builder, signed point, subpath, first-excess,
      and reset host tests. The fixed 13,536-byte Drawing-plan codec now
      round-trips the last
      Canvas, stroke, point, and subpath slots with checked occupancy and
      corruption rejection. The fixed plan owner now snapshots five strokes,
      validates contiguous ranges and subpath coverage, publishes a direct
      `DrawingPlanView`, and rejects incomplete or corrupt plans in host tests.
      A scoped Static Drawing workspace now connects `GraphicsContext`,
      `LivePathBuilder`, and `StrokeSnapshotProducer` to those two fixed
      regions; host tests invoke five contexts and reject an invalid path
      without a partial plan. An attempt-scoped five-region borrow now lends
      semantic, layout, render, path, and plan storage together. The generated
      Canvas source maps five occurrence identities from the packed semantic
      table to the callable manifest; the common `CanvasPlanProducer` derives
      all five against resolved layout for the normal and seven diagnostic
      hierarchies in host tests. The production Static Canvas pass now supplies
      the deriving context and generated Drawing limits, rejects a workspace
      with other limits, and checks complete callable release on success. The
      eight-case fixture invokes it before render preflight. Normalized
      operation comparison and firmware
      linkage remain open. The first common render preflight exposed an
      application-capacity mismatch: at 480×320, valid 96-byte `A`, `W`,
      and mixed `W`/LF diagnostics require 37, 38, and 39 combined operations.
      The approved SPEC-001/SPEC-008/SPEC-015 amendment reserves 145 ordinary
      and 150 combined operation slots from the bounded hierarchy. All eight
      generated normal and diagnostic cases now pass preflight and stream into
      a counting `DrawingOperationSink` under the approved production capacity.
      The production Static render helper now performs preflight with the
      validated physical surface and generated render/sink limits; the
      eight-case hierarchy fixture exercises this entry before each offer.
      A production handoff now builds generated interaction only after that
      preflight, streams the physical offer, and resolves action publication
      plus input eligibility from the offer disposition. The eight-case
      endpoint fixture exercises the accepted handoff through the scoped
      application owner. A mismatched physical-surface header in the same
      fixture now fails before transport, discards the action candidate, and
      leaves input ineligible before the valid retry. The firmware join
      remains open.
      A production preparation entry now keeps layout, five-Canvas derivation,
      render preflight, and the handoff callback inside one attempt-scoped
      five-region borrow. A focused host fixture rejects an unstaged semantic
      input and accepts a staged normal candidate through the physical handoff.
      Semantic publication and the paced firmware owner remain open.
      The Static nRF endpoint now owns one exact 3,840-byte raster tile and
      240-byte coverage map, with raster work limits derived from 150
      operations across the full 480 x 320 surface. A production render-offer
      helper streams the generated normal and seven diagnostic hierarchies
      through that endpoint in host fixtures with accepted synchronous RGB565
      submissions. A bounded display target now packs each touched run into
      the same raster region and synchronously lends it to a platform
      transport. The host fixture verifies the in-place compaction across
      separated source offsets and offers all eight generated cases through
      the shared one-slot target. The 240-byte coverage map now has its own
      exact-size firmware symbol and is included in the 155,840-byte named-storage
      self-check. The hardware-free nRF build passes ABI, zero-heap, symbol,
      and resource gates at 184,128 RAM bytes and 34,400 flash bytes. The live
      application host and firmware loop remain open.
      A direct Static interaction occurrence reader now maps six generated
      action scopes through resolved bounds and ancestor disable modifiers;
      the eight generated hierarchy fixtures verify identities, action codes,
      paint order, and initial enabled state. A production candidate builder
      now stages all six bounded records, assigns generations, and permits
      offer-time commit or discard. Host fixtures commit six records, then
      rebuild an unchanged candidate without consuming new generations.
      The address-stable application owner now owns its generation allocator,
      refuses candidate construction before root binding, and delegates
      offer-time commit/discard to the common transaction resolver. A host
      fixture rejects an offer before accepting a later one and verifies that
      the refused candidate never reaches committed interaction state. Offer
      resolution now installs the physical input revision in that same owner
      call only after acceptance; the fixture checks refusal leaves input
      ineligible and acceptance admits input. The owner also rejects an
      accepted offer without a ready interaction candidate, preserving input
      ineligibility. An accepted replacement now advances that same physical
      revision; the host fixture rejects an event tagged with the previous
      revision and admits a resynchronized event for the replacement. The
      physical offer and firmware loop remain open.

### Milestone 7: Exhaust Failure, Workload, and Resource Evidence

**Entry conditions:** A complete contract-faithful analyzer graph exists for
the relevant profile.

**Exit evidence:** Every failure row, accepted workload, exact preset value,
and required performance/resource measurement has a reproducible disposition.

- [x] `T7.1` — Exhaust every capacity, availability, sequence, identity,
      revision, phase, reentrancy, invariant, unknown-producer, residual-policy,
      and diagnostic-projection condition. Record normalized fields, mandatory
      effects, policy-call count/input/result, reserved-fact behavior,
      quiescence, last-complete-state preservation, and reconstruction.
      **Completed:** the 19-row normalized matrix covers every admission,
      repository, and runtime condition and the focused owner tests assert
      ordered mandatory effects, zero-or-one policy calls, policy inputs and
      results, reserved-fact handling, terminal containment, and reconstruction
      requirements. Evidence is in
      `Tests/ContractFixtures/SPEC001/Evidence/milestone-7/exhaustive-failure-matrix.md`.
- [x] `T7.2` — Run the complete diagnostic matrix in dynamic and static
      profiles with projection omitted, enabled, filtered, saturated, dropped,
      and failing. Require byte/value-identical semantic diagnostics,
      `BoundedText`, normalized outcomes, effects, policy, revisions, and
      visible error state.
      **Completed:** all six projection modes execute through both concrete
      admission profiles and preserve byte-identical semantic diagnostics,
      `BoundedText`, failure values, revision, and visible error state.
      Evidence is in
      `Tests/ContractFixtures/SPEC001/Evidence/milestone-7/diagnostic-profile-equivalence.md`.
- [x] `T7.3` — Run the capture revision boundary independently for transition
      processing and Clear. Prove success at `UInt32.max - 1`, rejection before
      mutation at `UInt32.max`, exactly one normalized reserved terminal fact,
      no ordinary failed-state callback, no residual policy, full quiescence,
      and fresh-graph-only recovery.
      **Completed:** transition processing and Clear each succeed from
      `UInt32.max - 1` to `UInt32.max`, then reject before mutation through
      one reserved terminal fact with no ordinary failure callback or policy
      call. Evidence is in
      `Tests/ContractFixtures/SPEC001/Evidence/milestone-7/revision-exhaustion.md`.
- [x] `T7.4` — Run 80 events/second for 30 seconds with four frames/second and
      the 28/32/33 admission corpus in the executable macOS profiles and in
      the shared host-native semantic fixture configured with each Pi/nRF
      preset. Cross-build-only reports must label unexecuted timing and target
      runtime claims `not-collected`, not infer them from the host fixture.
      Record
      transition/snapshot/fact/model/registration/replacement/Drawing/buffer
      high-water values; admission, mutation, report, publication, and frame
      timing; process/heap/stack/RAM/flash/map/ELF evidence as applicable; and
      exact equality with every SPEC-015 manifest, limit, extent, region,
      bound, and assembly report.
      **Completed:** all four hardware-free roots execute the same 2,400-event,
      120-frame workload and the 28/32/33 capacity corpus. The normalized
      preset comparison preserves every SPEC-015 manifest and physical/resource
      value; Pi/nRF target timing remains `not-collected`. Evidence is in
      `Tests/ContractFixtures/SPEC001/Evidence/milestone-7/sustained-workload-and-resources.md`.

### Milestone 8: Collect Separately Authorized Connected-Hardware Evidence

**Entry conditions:** The corresponding hardware-free build, ABI, resource,
and safety checks pass; the user explicitly requests the connected-target
change; the physical target is available and reports the required identity.

**Exit evidence:** Display, input, pacing, responsiveness, and resource claims
are recorded as connected-target evidence rather than inferred from build or
simulation.

- [ ] `T8.1` — After explicit authorization, require the remote Raspberry Pi to
      report `armv6l`, deploy the exact `T6.4` artifact through the repository
      workflow, run the deterministic 80-event/second scenario for at least 30
      continuous seconds on framebuffer/PiScreen, exercise all six controls,
      and record display/input correctness, no loss/duplication/stale events,
      responsiveness, process memory, four-frame/second cadence, teardown,
      commands, artifact identity, and recovery. **Blocked pending explicit
      connected-run authorization:** earlier authorized remediation
      established that the `armv6l` target exposes an accessible `fb_ili9486`
      framebuffer at `/dev/fb0` and its ADS7846 touchscreen at
      `/dev/input/event0`; a bounded adapter run transferred all fifteen 240 x
      16 payloads, but no physical touch was observed. T6.7 now supplies the
      production analyzer host loop and graphics-console lifecycle. A new
      authorized run must still exercise the six physical controls and collect
      semantic/action, pacing, process memory, cursor-suppression, and teardown
      observations. See the
      [Pi adapter evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/piscreen-platform-adapter.md).
- [ ] `T8.2` — After explicit authorization, inspect and flash the exact `T6.5`
      ELF through the repository nRF workflow, run the deterministic scenario
      for at least 30 continuous seconds on the connected TFT/input target,
      exercise all six controls, and record display/input correctness, no
      loss/duplication/stale events, responsiveness, four-frame/second cadence,
      watchdog/reset behavior, stack high-water where supported, assembled
      RAM/flash/workspaces/timing, artifact identity, and teardown. Never infer
      this evidence from an emulator or cross-build.
      **Blocked:** the selected ILI9486/ADS7846 firmware builds with a finite
      device-validation entry, but the Static analyzer host loop is not yet
      composed. Physical shield provenance, continuity/orientation, and power
      evidence is also required before flashing.
- [ ] `T8.3` — Compare connected semantic/action/drawing traces with the
      hardware-free oracle while preserving target-specific performance and
      display facts. Classify any absent hardware run as an open connected
      gate, not a failure hidden by simulator evidence.

#### Cross-Specification Connected Validation Campaign

Milestone 8 executes as two coordinated target groups followed by one shared
comparison. This ordering reuses one immutable artifact and one connected run
per target without treating evidence owned by one Specification as evidence
for a different criterion. Each group records the exact revision, artifact
hash, target identity, commands, transports, raw traces, measurements, and
teardown result needed by every consuming report.

1. **Raspberry Pi / PiScreen group:** after SPEC-003 `T5.4` and `T5.5` pass
   and SPEC-001 `T6.7` supplies the production display/input-capable artifact,
   select one Raspberry Pi 1 and obtain a separate explicit request authorizing
   deployment and connected execution. Run the repository Pi doctor, verify
   the exact `T6.4` artifact and hard-float ARMv6 attributes, require the remote
   machine to report `armv6l` before deployment, and collect one coordinated
   run for SPEC-001 `T8.1`, SPEC-003 `T6.2`, the Raspberry Pi portion of
   SPEC-011 `T9.3`, and SPEC-015's connected PiScreen gate. A service restart
   remains separately unauthorized unless the same request names it.
2. **nRF52840 TFT/input group:** after SPEC-001 `T6.8` supplies the production
   display/input-capable firmware, obtain a separate explicit request authorizing
   the connected-board change. Run the repository nRF doctor, rebuild and
   inspect the exact `T6.5` firmware, reverify ARMv7E-M and VFP hard-float
   attributes, then flash only `nrf52840dk/nrf52840` through the checked-in
   J-Link workflow. Collect one coordinated run for SPEC-001 `T8.2`, SPEC-011
   `T9.4`, and SPEC-015's connected nRF52840 TFT/input gate.
3. **Shared oracle comparison:** only after both target groups have immutable
   evidence, run SPEC-001 `T8.3` against the hardware-free semantic, action,
   and drawing oracle. Preserve target-specific timing, display, resource,
   reset, and recovery facts rather than normalizing them away.

Commit the evidence and matching task/report dispositions after each numbered
group. Do not combine an uncollected group with a completed group or mark any
Specification `implemented`; the lifecycle transition still requires explicit
human authorization after conformance review.

### Milestone 9: Integrate Repository Gates and Prepare Conformance

**Entry conditions:** All applicable implementation tasks have dispositions;
required owner contracts remain authoritative.

**Exit evidence:** Reproducible registered checks and a conformance report map
every SPEC-001 criterion without conflating implementation completion with the
human `implemented` transition.

- [x] `T9.1` — Audit Package.swift, generated sources/manifests, public/package
      interfaces, import/dependency graph, source identities, finite action
      switch, failure representation, prohibited facilities, static symbols,
      and evidence completeness. Run all positive and negative compile
      fixtures with their pinned profile compilers.
      **Completed:** the registered audit verifies the exact target/import
      graph, generated preset/storage surface, portable identities, six-case
      action handler, structural failure representation, prohibited facilities,
      and all positive/negative dependency cases. Evidence is in
      `Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md`.
- [x] `T9.2` — Run focused Domain/Data/Presentation tests, the SPEC-001 driver
      for every hardware-free profile, every applicable registered dependency
      driver from SPEC-002 through SPEC-015, and normalized cross-profile
      comparison. Preserve standalone invocations and immutable logs; a
      dependency driver may be inapplicable only through its own explicit
      profile contract, never through a SPEC-001 skip.
      **Completed:** every hardware-free SPEC-001 profile and every registered
      dependency driver runs through the explicit repository registry. The
      four latest analyzer reports compare equal across 24 semantic/workload
      fields. The host-native focused phase explicitly enables the Dynamic
      profile required by its production Canvas-callable tests; the later
      profile product build remains independently selected. Evidence is in
      `Tests/ContractFixtures/SPEC001/Evidence/milestone-9/hardware-free-driver-suite.md`.
- [x] `T9.3` — Run `scripts/format-swift.sh`, `scripts/test.sh` for the fast
      local gate and applicable explicit profiles, and governance validation.
      Record failures against their owning task/specification; do not weaken or
      silently skip another contract driver.
      **Completed:** formatting, the fast local gate, all four hardware-free
      profile lanes, all 60 registered spec/profile driver combinations, and
      governance validation pass. The one initial governance ledger mismatch
      was corrected and revalidated without weakening a driver. Evidence is in
      `Tests/ContractFixtures/SPEC001/Evidence/milestone-9/repository-gates.md`.
- [x] `T9.4` — Update every task disposition and evidence link, create
      `docs/conformance/spec-001-conformance.md` with all 45 criteria exactly
      once, link it from SPEC-001 and this plan, and request the human
      conformance review. Plan completion does not mark SPEC-001 implemented;
      that transition remains an explicit human decision after all required
      platform and connected-hardware evidence is accepted.
      **Completed:** the complete conformance report maps all 45 criteria
      exactly once: 40 pass and five retain explicit connected-hardware
      blockers. SPEC-001 remains `implementing`; T8.1-T8.3 and the human
      transition remain open.

## Design-Note Triggers

- Create `docs/implementation-designs/spec-001-bounded-capture-and-publication.md`
  before Milestone 2 if the dynamic/static storage, exact mutation replay,
  stable insertion/eviction, and nonwrapping terminal revision mechanism cannot
  be reconstructed locally from code and tests.
- Create `docs/implementation-designs/spec-001-presentation-admission-and-failure.md`
  before integrated `T3.4`/`T5.1` work if cross-storage sequencing, reserved
  failure admission, mandatory effects, quiescence, and residual policy need a
  maintained owner/data-flow account. It must not redefine SPEC-003/009/010.
  **Created:** the current note fixes the replaceable three-store sequencing,
  sealing, profile-storage, and failure-routing realization used for T5.1.
- Create `docs/implementation-designs/spec-001-deterministic-source-adapters.md`
  only if sharing the deterministic generator between desktop scheduling,
  cooperative embedded scheduling, and accelerated tests requires a
  non-obvious state machine or lifetime mechanism.
- Create `docs/implementation-designs/spec-001-four-host-application-join.md`
  before Milestone 6 only if the analyzer-specific mapping into the fixed
  SPEC-015 owner graph is not self-explanatory. Host validation and lifecycle
  semantics remain owned by SPEC-015.
  **Created:** the current note fixes the typed executable-owned model, fact,
  action, profile, and lifecycle joins while leaving reusable host validation
  and lifecycle semantics under SPEC-015.

No note may choose a new public value, capacity, dependency, capability,
failure disposition, target preset, or application behavior. Mechanical view
composition, straightforward use-case delegation, and local test helpers do
not warrant design notes.

## Integration and Validation Order

1. Freeze SPEC-001 fixture/evidence schemas and package/import boundaries;
   register the fail-closed driver before adding a conformance claim.
2. Implement and test bounded Domain values and Data behavior independently of
   GiftUI, first with host-native dynamic storage and then the identical-limit
   static fixture.
3. Implement Presentation facts, adapter, ViewModel, and failure owner through
   focused recording seams before joining a production runtime.
4. Port the fixed hierarchy and five-Canvas workload to GiftUI; compare
   semantic/layout/drawing transcripts before backend pixels.
5. Join fact admission, observable state, action dispatch, and serialized
   cycles at identical artificial capacities in dynamic and static profiles.
6. Validate the exact SPEC-015 descriptor and assemble macOS dynamic, macOS
   static, Raspberry Pi ARMv6, and nRF52840 profiles in that order.
7. Run sustained workload, failure, UTF-8, resource, import, symbol, ABI, and
   normalized equivalence checks. Hardware-free Pi/nRF builds establish only
   compile/link/inspection evidence.
8. With separate explicit authorization, collect connected PiScreen and TFT
   display/input evidence. Do not let absence of hardware evidence block safe
   local implementation progress or turn into an inferred pass.
9. Run the repository gates, create the conformance report, and request human
   review of any remaining platform exception and the eventual
   `implemented` transition.

## Risks and Upstream Blockers

### Implementation risks

- The 2,404-entry capture plus snapshot, Drawing, runtime, model, and backend
  workspaces may be a material fraction of nRF52840 RAM. Measure each owner
  separately before host integration; do not compress or reduce a required
  value silently.
- The imported array/dictionary repository may conceal copying and shifting
  costs. Preserve exact stable-order and baseline semantics while measuring a
  bounded static representation rather than adopting its mechanics by default.
- Scheduling adapters can accidentally leak tasks, clocks, actors, or platform
  types into portable modules. Keep deterministic generation state separate
  from host scheduling and enforce source/import/symbol negatives early.
- Host-native Pi/nRF semantic fixtures can be mistaken for target execution.
  Enforce the evidence-kind schema before accepting a criterion disposition,
  and leave target timing, display/input, process-memory, stack, responsiveness,
  and watchdog fields open until connected evidence exists.
- The admission, observable, action, Drawing, and host joins span several
  actively implemented Specifications. Reuse their checked fixtures and
  production seams; avoid analyzer-local parallel implementations that make a
  demo run while bypassing owner conformance.
- Connected hardware may be unavailable or differ operationally. Preserve
  exact artifact identity and evidence classification so a successful build or
  simulator run never becomes a hardware claim.

### Upstream blockers

- A missing production declaration or owner seam from SPEC-002 through
  SPEC-015 blocks only the dependent task and must be completed under that
  Specification. SPEC-001 must not duplicate it locally.
- Inability to represent the exact bounded diagnostic, capture mutation,
  failure sum, static model/action/Canvas storage, or supported-compiler source
  shape is a Specification-review blocker.
- Any need to change logical ownership, executor/mutation separation,
  observable identity, failure meaning/disposition, Canvas semantics,
  application action model, capability gates, or host topology is an
  architecture-review blocker.
- Any proposed capacity, rate, cadence, extent, region, payload, or connected-
  evidence change is a SPEC-001/SPEC-015 contract-review blocker.
- The eventual `implemented` transition is blocked until the conformance
  report disposes all 45 criteria and a human explicitly approves the
  transition. Connected-hardware criteria remain open unless accepted evidence
  or an explicit human exception exists.

## Deferred and Follow-up Work

SPEC-001 originates no deferred item. This plan schedules none. Public binding
and fine-grained property observation remain in RFC-008's linked
[FW-017](../future-work/fw-017-public-binding-abstraction.md) and
[FW-019](../future-work/fw-019-fine-grained-observable-dependency-tracking.md);
multiple/nested action domains remain in RFC-011's
[FW-021](../future-work/fw-021-scoped-action-domains.md). They are not required
for the fixed analyzer and must not expand this implementation.

If implementation discovers a valuable non-blocking optimization or future
application feature, capture it through the deferred-work lifecycle with a
concrete revisit trigger and reciprocal link. Correctness, required capacity,
and conformance gaps may not be deferred.

## Completion Record

Governed implementation began on 2026-09-13. `T0.1` established the ordered,
fail-closed fixture and evidence contract, the complete task ledger, five
versioned transcript schemas, and explicit evidence-kind-to-criterion-class
permissions. `T0.2` classified all 26 tracked investigation sources/tests and
26 existing analyzer-related SPEC-007-through-SPEC-015 fixtures, then froze
the dynamic package and generated-static dependency equivalents. `T0.3`
registered the exact four-profile, report-only driver; it records all required
identities and remains fail-closed until profile implementation commands land.
`T0.4` records each reusable contract's declaration, focused-owner, profile,
backend, and host-join readiness and pins the reused SPEC-007-through-SPEC-015
fixture inputs by digest. Checked criteria in SPEC-001 and the imported package
remain baseline evidence only until the governed implementation and required
profiles reproduce them. `T0.5` activates the three governed root-package
owners and their focused test targets with exact direct dependencies and
negative graph/import fixtures; concrete host composition remains in SPEC-015.
`T1.1` adds the inline 96-byte diagnostic, scalar-boundary exact/truncating
UTF-8 validation, one-call byte borrowing, and byte-identical `BoundedText`
projection without adding Foundation to Domain or Presentation.
`T1.2` adds the exact fixed channels and baselines plus bounded dynamic and
2,404-entry caller-owned static capture storage with shared invariant validation,
stable ordering, value equality, retained reconstruction, and checked access.
`T1.3` adds exact publication, delivery-outcome, rejection, and repository-
condition values plus fail-closed snapshot/mutation replay, insert-before-trim
ordering, bounded change validation, reset semantics, and nonwrapping revisions.
`T1.4` adds the synchronous bounded sink, repository, and source contracts plus
the five exact-once delegating use cases, with source-level enforcement against
Domain UI, platform, timing, and concurrency facilities.
`T2.1` adds checked capture retention and its repository integration, including
epoch rebasing, stable insertion, 30-second and capacity eviction, reconstructed
baselines, exact mutation replay, and state-preserving Clear behavior.
`T2.2` completes repository lifecycle and failure handling: immediate weak sink
replacement, synchronous bounded outcomes, action idempotence, startup cleanup,
source-contract and horizon paths, no-rollback refusal, and terminal revision
exhaustion with permanent object-graph quiescence.
`T2.3` adds the scheduler-independent four-channel generator, exact wrapping
CH4 vectors, host-scaled delivery seam, checked nonaliasing generations,
pause/resume continuity, teardown, and a second conforming source fixture.
`T2.4` adds the 30-second, 2,400-event workload oracle joined to four initial
lows, checking all inputs, mutations, revisions, outcomes, state transitions,
and the replayed 2,404-transition final capture without loss or duplication.
`T3.1` adds the exact Presentation values, runtime-condition catalogue,
diagnostic-preserving intents, total six-action handler, visible range, and
model-owned synchronous dirty reporting with proven no-op suppression.
`T3.2` adds the non-model admission adapter with exact callback translation,
two-current-value startup, idempotent host lifecycle, partial-start cleanup,
original-rejection preservation, and nonrecursive reserved-failure reporting.
`T3.3` adds atomic snapshot and exact-mutation application, fail-closed revision
validation, state and operational-failure semantics, derived visible ranges,
and synchronous dirty reports only for observable changes.
`T3.4` adds exhaustive repository/admission/runtime normalization, ordered
mandatory effects, nonrecursive reserved-failure handling, coordinator-owned
contained-phase retry, valid residual inputs, and the target's total policy.
`T3.5` closes the focused Presentation matrix with exact start error-clear and
executor-entry ordering, deferred synchronous callback application, observation
lifetime, no-op reporting, and source-substitution transcript equivalence.
`T4.1` adds the portable observable root and fixed explicit header, status,
waveform, four-channel, six-control, and conditional-error hierarchy without
dynamic collections, platform branches, or view-owned lifecycle work.
`T4.2` adds the exact title, subtitle, status, channel-level, action-label,
error, acquisition-control, and selected-window-control semantics with the
complete four-state by three-window normalized matrix.
`T4.3` adds three-label ruler formatting, one 12-subpath grid Canvas, four
streamed digital trace Canvases, exact lower/upper-bound transition handling,
current-level projection, and the normative `5/5/202/12/832/16` workload.
`T4.4` freezes the identical dynamic/static portable source set with an import,
macro, identity, explicit-channel, qualified-action, Canvas-occurrence, and
forbidden-mechanism audit plus successful compilation under both profile flags.

Milestone 5 is complete. `T5.1` provides the common fixed `1/32/1` sequencer
through Dynamic retained and Static caller-owned direct endpoints, including
the exact producer/physical limits, nonwrapping order, sealing, deferral, and
at-most-once application. `T5.2` completes equal typed model materialization,
registration, replacement, failure, removal, reinsertion, direct reporting,
and generation behavior. `T5.3` joins facts, semantic actions, 250-millisecond
pacing, one-bit dirtiness, freeze, derivation, publication, and retryable offer
recovery without callback reentrancy. `T5.4` installs the six-case handler in
both roots and closes pointer-down, admitted-action, replacement, removal,
failure, disabled, stale-generation, and final-revalidation cases. `T5.5`
records equal accepted and retryable integrated-cycle transcripts through the
Drawing, interaction, offer, and frame stages.

`T6.1` joins the checked-in SPEC-001 portable hierarchy descriptor to the
SPEC-015 workload generator as a required, identity-bearing input. Generation
fails unless the exact root/model, six-control/action, and five-Canvas hierarchy
matches the workload descriptor. All four generated presets then pass the
complete runtime-limit/storage audit, Drawing B2 structural gate, independent
SPEC-004 capability resolution, endpoint projection, action/model, input/wake,
policy, and one-owner acyclic graph stages before any live owner construction.
Evidence is in
`Tests/ContractFixtures/SPEC001/Evidence/milestone-6/host-structural-gates.md`.

Milestone 7 is complete. `T7.1` records the 19-row exhaustive failure matrix,
`T7.2` proves six diagnostic-projection modes cannot change Dynamic or Static
semantics, `T7.3` closes both capture-revision terminal paths, and `T7.4`
executes the equal 2,400-event/120-frame workload plus 28/32/33 capacity corpus
in all four hardware-free presets.

Milestone 9 is complete. The interface/dependency audit, all 60 registered
hardware-free spec/profile driver combinations, formatter, root tests,
governance, and 24-field analyzer comparison pass. The linked conformance
report maps all 45 criteria once: 40 pass and five remain blocked by the
separately authorized connected-hardware Milestone 8. The plan therefore
remains `active`; neither the report nor Milestone 9 marks SPEC-001
`implemented`.

The 2026-09-13 readiness revision fixed the governed root-package destination,
seam-level dependency ledger, contract-report and platform-artifact ownership,
evidence classification, startup/action/category-bound checks, dual Drawing
startup gates, connected sustained-workload evidence, and complete dependency-
driver coverage. Those readiness changes did not themselves start
implementation or supply conformance evidence; the plan is now `active` as
recorded above.

Update task dispositions with stable evidence in the same change that completes
or invalidates them. When every planned task has a disposition, set the plan to
`completed` and link the conformance report.
Plan completion alone does not establish conformance or authorize SPEC-001's
`implemented` status.
