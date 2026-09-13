---
spec: SPEC-001
feature: signal-analyzer
title: SPEC-001 Implementation Plan
status: active
owners:
  - codex
created: 2026-09-13
updated: 2026-09-13
related_design_notes: []
conformance_report: null
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
| `SA-AC-005` — Complete visible screen surface | `T4.1`-`T4.3`, `T6.2`-`T6.5`, `T8.1`, `T8.2` | Semantic hierarchy transcript plus rendered/connected display evidence | pending |
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
| `SA-AC-023` — Raspberry Pi framebuffer/PiScreen display and input | `T6.4`, `T8.1` | ARMv6 cross-build plus separately labeled connected-target transcript | pending |
| `SA-AC-024` — nRF52840 static TFT display and input | `T6.5`, `T8.2` | ELF inspection plus separately labeled connected-target transcript | pending |
| `SA-AC-025` — nRF binary/RAM/storage/drawing/stack fit evidence | `T6.5`, `T7.4`, `T8.2` | Link map, ELF, stack/high-water, workspace, and run report | pending |
| `SA-AC-026` — Conforming source replacement changes no portable owners | `T2.3`, `T6.6` | Mock/fixture-source substitution compile and graph comparison | pending |
| `SA-AC-027` — Missing GiftUI behavior fails configuration without reduced UI | `T6.6`, `T7.1` | Each-required-facility negative and zero-publication transcript | pending |
| `SA-AC-028` — Host-owned observation and adapter sink installation | `T3.2`, `T6.1`-`T6.5` | Construction/start/stop/teardown owner-call ledger | pending |
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
| `SA-AC-039` — Embedded typed model/storage/facility/resource evidence | `T5.2`, `T6.5`, `T7.4` | Generated source, address/layout, forbidden-symbol, timing, RAM/flash/stack reports | pending |
| `SA-AC-040` — Total normalization, mandatory effects, residual policy, and diagnostic independence | `T3.4`, `T7.1` | Exhaustive outcome/effect/policy/projection matrix | pending |
| `SA-AC-041` — Complete 96-byte UTF-8 diagnostic and BoundedText matrix | `T1.1`, `T3.4`, `T9.2` | Dynamic/static construction, borrow, projection, allocation transcript | pending |
| `SA-AC-042` — Exact wrapping CH4 vectors in every profile/host | `T2.3`, `T6.2`-`T6.5`, `T9.2` | Two golden vectors and four normalized host traces | pending |
| `SA-AC-043` — Capture revision exhaustion terminal procedure | `T1.3`, `T2.2`, `T3.4`, `T7.1` | `UInt32.max - 1/max`, reserved fact, no-policy, quiesce/rebuild transcript | pending |
| `SA-AC-044` — Operational failure structurally contains only failure fact plus semantic diagnostic | `T3.1`, `T3.4`, `T5.1`, `T9.1` | Positive API/layout and negative construction/generated-storage fixtures | pending |
| `SA-AC-045` — Exact SPEC-015 workload/preset/report equality | `T4.3`, `T6.1`-`T6.5`, `T7.4` | Descriptor, generated manifest, limits, assembly, extent/region/bounds comparison | pending |

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

- [ ] `T2.1` — Adapt the repository around checked dynamic/static storage.
      Implement validation, epoch rebasing, stable insertion, duration,
      30-second trimming, oldest-first capacity eviction, baseline updates,
      current levels, and Clear's exact reset mutation. Exhaust empty, boundary,
      equal/out-of-order, newly inserted-and-evicted, and four-state Clear cases.
- [ ] `T2.2` — Implement one replaceable sink of each kind with immediate
      revisioned current values, synchronous bounded outcome propagation, weak
      or explicit non-retaining lifetime, detach-before-return, state-table
      actions, source-contract failures, horizon diagnostics, and the complete
      `UInt32.max` terminal procedure. Prove startup failure stops partial
      source activation, publishes one nonempty bounded failed state, and
      throws the same failure or a value carrying the same diagnostic; prove no
      rollback after callback refusal and no later operation on an exhausted
      graph.
- [ ] `T2.3` — Separate deterministic source state from host-provided live
      scheduling. Implement four initial lows, CH1/CH2/CH3 patterns, exact
      wrapping CH4 LCG and both golden vectors, checked nonaliasing generations,
      pause/resume conceptual time, accelerated timing, teardown, and a second
      conforming source fixture. Keep clocks/schedulers/tasks outside Domain and
      Presentation and reject generation wrap rather than aliasing.
- [ ] `T2.4` — Run the repository/source oracle at the accepted aggregate rate
      for 30 conceptual seconds. Record every input, revision, mutation,
      eviction, sink outcome, state transition, and final capture; require no
      missing, duplicate, reordered, stale, or unexpected fact.

### Milestone 3: Implement Presentation State, Admission, and Failure Ownership

**Entry conditions:** Milestone 1 values; production or contract-faithful
SPEC-003/009/010 admission and mutation seams.

**Exit evidence:** Application callbacks terminate at a non-model adapter,
facts apply only in GiftUI mutation, and every failure follows the exact total
normalization/effect/policy sequence.

- [ ] `T3.1` — Implement exact visible-window, view-state, six-action,
      noncapturing action-handler, Presentation-fact, operational-failure,
      observation-start, residual-context, and ViewModel declarations. Keep
      success/operational outcomes unrepresentable in
      `SignalAnalyzerOperationalFailure`; implement initial state, visible
      range, four intents, and model-owned change signaling.
- [ ] `T3.2` — Implement `SignalAnalyzerPresentationAdmissionAdapter` with both
      sinks, two use cases, one fact endpoint, idempotent host-started/stopped
      observation, exact callback conversions, two-current-value start result,
      partial-start cleanup, and rejection reporting. Prove it never owns,
      borrows, registers, observes, or mutates a ViewModel.
- [ ] `T3.3` — Implement package-scoped mutation-phase fact application.
      Atomically apply snapshots and exact mutations, validate base revisions,
      preserve capture on mismatch, apply state and operational failure, expose
      semantic error text, and emit synchronous owner-dirty reports only for
      changes. Prove callbacks cannot enter these operations directly.
- [ ] `T3.4` — Implement the narrow analyzer owner adapter and exhaustive total
      mapping from repository, admission, and runtime conditions into exact
      SPEC-003 outcomes. Apply mandatory effects before constructing only valid
      residual inputs, enforce the selected total policy, reserve the failure
      path, implement invariant/no-policy rows, and prove optional diagnostics
      cannot alter semantic diagnostics, outcomes, effects, policy, or state.
- [ ] `T3.5` — Create focused Presentation fixtures for initial state, all fact
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

- [ ] `T4.1` — Replace SwiftUI/Observation Presentation with one
      `@ObservableStateHost` GiftUI root containing
      `@State private var viewModel`. Declare header, status, waveform panel,
      CH1-CH4 rows, controls, and error region explicitly; use no dynamic child
      collection, view-started observation, platform branch, runtime import, or
      unsupported client feature.
- [ ] `T4.2` — Implement the complete title/subtitle/status/error text and
      exact enabled/disabled table with the six qualified
      `Button(..., action: SignalAnalyzerAction.case)` values. Use only the
      approved opaque color, foreground, background, stack, spacer, padding,
      alignment, and frame surface; record the semantic/layout transcript for
      all acquisition/window/error states.
- [ ] `T4.3` — Implement one grid Canvas plus one trace Canvas for each explicit
      channel. Derive ruler labels, 11 vertical/one center line, starting level
      through the lower bound, exact transition filtering and x mapping,
      vertical level changes, right-edge extension, current HIGH/LOW at capture
      duration, and exact SPEC-015 Drawing minima. Compare path/subpath/point/
      stroke transcripts at empty, trim, overflow, edge, and out-of-order cases.
- [ ] `T4.4` — Compile byte-identical portable Presentation source through
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

- [ ] `T5.1` — Configure independent snapshot capacity one, compact-fact
      capacity 32, and reserved-failure capacity one. Implement nonzero
      nonwrapping `UInt32` sequencing across physical stores, seal/apply order,
      at-most-once application, post-seal deferral, exact first-excess
      rejection, and the full 28-fact production burst without replacement or
      coalescing of facts. Separately prove the `20`, `2`, and `6` producer
      category bounds, all 32 physical compact slots, physical fact 33, and
      rejection of each category excess as an incompatible host workload
      rather than spending the four-slot margin.
- [ ] `T5.2` — Bind the root to one observable location, active registration,
      dirty/live bit, and transient replacement record. Run identical dynamic/
      static fixtures for initializer preservation, atomic replacement,
      candidate failure, derivation failure, published removal, reinsertion,
      stale reports, duplicate ownership, incompatible association, and
      generation exhaustion; inspect static address-stable typed storage.
- [ ] `T5.3` — Integrate admitted facts and semantic actions with the serialized
      mutation phase, freeze, complete-root derivation, publication, wake, and
      paced retry owners. Prove 20 change reports become one dirty transition
      and at most one wake while every fact applies, frames see one complete
      revision, and same-thread/distinct-executor callbacks never reenter the
      active mutation.
- [ ] `T5.4` — Bind the six-action handler to the current model generation at
      the runtime coordinator. Exhaust exact dispatch, no capture/retention,
      pointer-down and admitted-action replacement, removal, failed/staged
      replacement, stale action generation, disabled state, and final target
      revalidation; require at-most-once dispatch to the exact current model.
- [ ] `T5.5` — Produce one normalized integrated cycle transcript containing
      callback, admission, seal, application, change report, dirty/wake,
      semantic publication, Drawing, offer, and frame events. Compare all
      profile-independent fields across dynamic and static realizations.

### Milestone 6: Assemble and Validate the Four Target Hosts

**Entry conditions:** Applicable Milestones 1-5 and production SPEC-014/015
owner seams. Missing downstream owner work blocks only its dependent host
slice and remains explicit.

**Exit evidence:** Each exact SPEC-015 preset builds a single analyzer graph,
uses the shared Presentation, and emits an immutable assembly/execution report.

- [ ] `T6.1` — Feed the checked-in portable hierarchy descriptor into the
      SPEC-015 generator/validator. Prove exact six actions, one model/input
      owner, `1/32/1` stores, 28-fact burst, five Canvas occurrences/strokes,
      202 live points, 12 live subpaths, 832 snapshot points, 16 snapshot
      subpaths, runtime limits, and one-owner acyclic graph before constructing
      any host. For every preset, require both the Drawing B2 structural gate
      and the independent SPEC-004 `rasterPresentation` capability gate before
      owner construction; neither may substitute for the other. Keep adapter
      installation before acquisition and observation start/stop solely in
      host lifecycle.
- [ ] `T6.2` — Assemble and execute the macOS dynamic host with the deterministic
      source, dynamic runtime, complete GiftUI client surface, full-surface
      backend, input, clock/scheduler, owner adapter, and host pacing. Record
      normalized state/action/drawing/frame output and resource/cadence data.
- [ ] `T6.3` — Generate, compile, and execute the macOS static host from the
      same portable Presentation and exact preset. Inspect generated model,
      action, Canvas, fact, and workspace storage; compare its normalized
      application transcript with `T6.2`.
- [ ] `T6.4` — Assemble the Raspberry Pi 1 dynamic preset with exact 240 x 240
      extent and 240 x 16 RGB565 tiled region. Cross-build only for
      `armv6-unknown-linux-gnueabihf` through
      `scripts/raspberry-pi/build.sh --product`, passing the exact executable
      product delivered by SPEC-015's Raspberry Pi preset task. Require its
      ELF, ARMv6, and hard-float checks, record the emitted `ARTIFACT=` path
      and digest, inspect dependencies/resources, and keep connected PiScreen
      execution for `T8.1`.
- [ ] `T6.5` — Assemble the `nrf52840dk/nrf52840` static preset with exact
      480 x 320 extent, 480 x 4 RGB565 region, 960-byte row, and 3,840-byte
      raster/payload/in-flight bounds. Cross-build through
      `scripts/nrf52840/build.sh --application`, passing the exact application
      delivered by SPEC-015's nRF52840 preset task, with the bundled
      `armv7em-none-none-eabi` module and Zephyr Cortex-M4F hard-float flags.
      Record emitted `ELF=`, `HEX=`, `MAP=`, `DEVICETREE=`, and `REPORTS=`
      paths and digests, verify VFP ABI, storage and forbidden symbols, and
      keep flashing for `T8.2`.
- [ ] `T6.6` — Replace the mock with the conforming fixture source without
      changing Domain, use cases, adapter, ViewModel, or portable hierarchy.
      Separately fault every required GiftUI/host facility and prove validation
      fails before publishing a reduced or target-specific analyzer.

### Milestone 7: Exhaust Failure, Workload, and Resource Evidence

**Entry conditions:** A complete contract-faithful analyzer graph exists for
the relevant profile.

**Exit evidence:** Every failure row, accepted workload, exact preset value,
and required performance/resource measurement has a reproducible disposition.

- [ ] `T7.1` — Exhaust every capacity, availability, sequence, identity,
      revision, phase, reentrancy, invariant, unknown-producer, residual-policy,
      and diagnostic-projection condition. Record normalized fields, mandatory
      effects, policy-call count/input/result, reserved-fact behavior,
      quiescence, last-complete-state preservation, and reconstruction.
- [ ] `T7.2` — Run the complete diagnostic matrix in dynamic and static
      profiles with projection omitted, enabled, filtered, saturated, dropped,
      and failing. Require byte/value-identical semantic diagnostics,
      `BoundedText`, normalized outcomes, effects, policy, revisions, and
      visible error state.
- [ ] `T7.3` — Run the capture revision boundary independently for transition
      processing and Clear. Prove success at `UInt32.max - 1`, rejection before
      mutation at `UInt32.max`, exactly one normalized reserved terminal fact,
      no ordinary failed-state callback, no residual policy, full quiescence,
      and fresh-graph-only recovery.
- [ ] `T7.4` — Run 80 events/second for 30 seconds with four frames/second and
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
      commands, artifact identity, and recovery.
- [ ] `T8.2` — After explicit authorization, inspect and flash the exact `T6.5`
      ELF through the repository nRF workflow, run the deterministic scenario
      for at least 30 continuous seconds on the connected TFT/input target,
      exercise all six controls, and record display/input correctness, no
      loss/duplication/stale events, responsiveness, four-frame/second cadence,
      watchdog/reset behavior, stack high-water where supported, assembled
      RAM/flash/workspaces/timing, artifact identity, and teardown. Never infer
      this evidence from an emulator or cross-build.
- [ ] `T8.3` — Compare connected semantic/action/drawing traces with the
      hardware-free oracle while preserving target-specific performance and
      display facts. Classify any absent hardware run as an open connected
      gate, not a failure hidden by simulator evidence.

### Milestone 9: Integrate Repository Gates and Prepare Conformance

**Entry conditions:** All applicable implementation tasks have dispositions;
required owner contracts remain authoritative.

**Exit evidence:** Reproducible registered checks and a conformance report map
every SPEC-001 criterion without conflating implementation completion with the
human `implemented` transition.

- [ ] `T9.1` — Audit Package.swift, generated sources/manifests, public/package
      interfaces, import/dependency graph, source identities, finite action
      switch, failure representation, prohibited facilities, static symbols,
      and evidence completeness. Run all positive and negative compile
      fixtures with their pinned profile compilers.
- [ ] `T9.2` — Run focused Domain/Data/Presentation tests, the SPEC-001 driver
      for every hardware-free profile, every applicable registered dependency
      driver from SPEC-002 through SPEC-015, and normalized cross-profile
      comparison. Preserve standalone invocations and immutable logs; a
      dependency driver may be inapplicable only through its own explicit
      profile contract, never through a SPEC-001 skip.
- [ ] `T9.3` — Run `scripts/format-swift.sh`, `scripts/test.sh` for the fast
      local gate and applicable explicit profiles, and governance validation.
      Record failures against their owning task/specification; do not weaken or
      silently skip another contract driver.
- [ ] `T9.4` — Update every task disposition and evidence link, create
      `docs/conformance/spec-001-conformance.md` with all 45 criteria exactly
      once, link it from SPEC-001 and this plan, and request the human
      conformance review. Plan completion does not mark SPEC-001 implemented;
      that transition remains an explicit human decision after all required
      platform and connected-hardware evidence is accepted.

## Design-Note Triggers

- Create `docs/implementation-designs/spec-001-bounded-capture-and-publication.md`
  before Milestone 2 if the dynamic/static storage, exact mutation replay,
  stable insertion/eviction, and nonwrapping terminal revision mechanism cannot
  be reconstructed locally from code and tests.
- Create `docs/implementation-designs/spec-001-presentation-admission-and-failure.md`
  before integrated `T3.4`/`T5.1` work if cross-storage sequencing, reserved
  failure admission, mandatory effects, quiescence, and residual policy need a
  maintained owner/data-flow account. It must not redefine SPEC-003/009/010.
- Create `docs/implementation-designs/spec-001-deterministic-source-adapters.md`
  only if sharing the deterministic generator between desktop scheduling,
  cooperative embedded scheduling, and accelerated tests requires a
  non-obvious state machine or lifetime mechanism.
- Create `docs/implementation-designs/spec-001-four-host-application-join.md`
  before Milestone 6 only if the analyzer-specific mapping into the fixed
  SPEC-015 owner graph is not self-explanatory. Host validation and lifecycle
  semantics remain owned by SPEC-015.

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
