---
spec: SPEC-015
feature: giftui-mvp-architecture
title: SPEC-015 Implementation Plan
status: active
owners:
  - codex
created: 2026-09-09
updated: 2026-09-19
related_design_notes:
  - ../implementation-designs/spec-015-generated-workload-and-presets.md
  - ../implementation-designs/spec-015-wake-and-pacing.md
conformance_report: null
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-015 Implementation Plan

> This active plan derives work from the approved MVP Target-Host Configuration
> Contract, including its explicitly reapproved schema-2 workload amendment.
> It orders reusable host assembly and evidence but does not amend SPEC-015,
> absorb behavior owned by another Specification, or authorize connected
> deployment, service restart, or board flashing.

## Authority and Scope

The governing [SPEC-015](../specs/spec-015-host-configuration.md) contract is
approved, including the generated SPEC-008 render-workspace inputs carried
through approved SPEC-013. Its authority chain consists of accepted
[PROPOSAL-002](../proposals/proposal-002-signal-analyzer-reference-application.md)
through [PROPOSAL-006](../proposals/proposal-006-canvas-path-stroke-drawing.md),
approved [RFC-001](../rfcs/rfc-001-signal-analyzer-application-architecture.md),
[RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md),
[RFC-003](../rfcs/rfc-003-deterministic-text-rendering-architecture.md),
[RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md),
[RFC-005](../rfcs/rfc-005-failure-diagnostics-propagation.md),
[RFC-006](../rfcs/rfc-006-capability-system-architecture.md),
[RFC-008](../rfcs/rfc-008-observable-reference-state-architecture.md),
[RFC-009](../rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md), and
[RFC-011](../rfcs/rfc-011-bounded-application-actions.md), plus every accepted
ADR listed by SPEC-015. The complete ADR list remains authoritative and is not
duplicated here as a substitute for the Specification metadata.

The [MVP Scope](../MVP_SCOPE.md) requires one substantially shared Signal
Analyzer Presentation to run through macOS dynamic, macOS static, Raspberry
Pi 1/Linux dynamic with framebuffer and PiScreen, and nRF52840 static with a
TFT display. SPEC-015 is the stack-validation join that proves the approved
runtime, capability, text-resource, backend, input, action, observable,
application, pacing, and failure contracts form one coherent executable host.

This plan owns only the reusable `GiftUIHostConfiguration` package SPI, pure
validation, bounded assembly reports, cross-owner adapters explicitly assigned
to the host, four immutable preset fixtures, and the SPEC-015 conformance
driver. It does not implement focused semantics owned by SPEC-003 through
SPEC-014 or portable application behavior owned by approved SPEC-001. Concrete
target roots consume those owners only after their own implementation gates
are satisfied.

## Current Repository State

- `docs/features.yaml` registers SPEC-015 under the
  `giftui-mvp-architecture` feature, whose lifecycle stage is
  `implementation`. SPEC-015 itself is `approved`; implementation has not
  begun.
- All linked ADRs are accepted and all linked RFCs are approved. SPEC-013 and
  SPEC-015 were explicitly reapproved together for the render-workspace
  workload schema; no new architectural choice is open.
- `Package.swift` has no `GiftUIHostConfiguration` target, concrete four-preset
  composition roots, or SPEC-015 test target. It now contains the focused
  Interaction, Drawing, Runtime Core/Dynamic/Static, surface, raster, display,
  and backend-integration owners that the host must consume rather than
  duplicate.
- SPEC-007 and SPEC-008 are implemented. SPEC-005, SPEC-006, and SPEC-014 have
  completed implementation plans; SPEC-014 also has a complete conformance
  report and reusable production endpoint seams. SPEC-003, SPEC-004, and
  SPEC-009 through SPEC-013 remain in active implementation with the
  downstream integration work recorded by their own plans.
- SPEC-011 through SPEC-013 already expose substantial production declarations
  and owner seams, but their remaining profile, application, host, platform,
  resource, and conformance tasks are prerequisites only for the dependent
  SPEC-015 slices named below. SPEC-015 must not replace an unfinished owner
  with a host-local implementation.
- `Tests/ContractFixtures/` and `scripts/contracts/` contain registered
  reproducible suites through SPEC-014, including the complete SPEC-014
  four-profile hardware-free evidence. There is no `SPEC015` fixture tree,
  driver registration, `scripts/contracts/run-spec-015.sh`, or
  `.build/spec-015/` evidence.
- The 2026-09-13 top-level `scripts/test.sh` readiness run is not green:
  SPEC-002 and SPEC-006 through SPEC-008 report stale source or downstream-
  consumer inventories, governance tooling rejects SPEC-013's mutable report
  publication path, and SPEC-011/SPEC-013 remain intentionally fail-closed on
  pending profile/conformance prerequisites. These are explicit `T7.3`
  prerequisites, not permission for SPEC-015 to weaken another owner's gate.
- `demo/SignalAnalyzer/` is a separate SwiftUI investigation with portable
  Domain/Data/Presentation material and a legacy `DependencyContainer`. It is
  evidence and migration input only. Its SwiftUI `App`, `MainActor`, dynamic
  closures, and composition root are not the approved GiftUI host.
- Repository-local ARMv6 and nRF52840 toolchain, doctor, probe, build, and
  artifact-inspection workflows already preserve the required target pins.
  SPEC-015 may invoke hardware-free compile/link inspection but may not deploy
  or flash.

## Readiness Review

**Reviewed:** 2026-09-13

**Disposition:** Ready with explicit prerequisite gates. The authority chain
is complete, SPEC-013 and SPEC-015 were explicitly reapproved on 2026-09-12,
and all eighteen acceptance criteria map exactly once. Every task is now
traceable to at least one criterion, including the schema-2 descriptor and
evidence schemas. Milestone 0 and dependency-complete slices of Milestones 1
through 3 can begin in order. Owner construction and four-host integration
wait for the exact prerequisite seams named by each task; those gates require
no architectural or contractual choice by the implementer.

No `docs/features.yaml` edit is required for this derived `draft` to `ready`
transition. When implementation actually starts, SPEC-015 must move from
`approved` to `implementing` with its metadata and manifest kept consistent.

If implementation cannot express the exact noncopyable validator/instance
surfaces, bounded caller-owned storage, nine-stage purity, static no-allocation
behavior, or finite activation-failure sums on the pinned compilers, return
the affected contract to Specification review. Any pressure to change module
ownership, dependency direction, capability vocabulary, endpoint semantics,
action/model identity, failure precedence, pacing bounds, or preset values
returns to the governing ADR or Specification rather than being decided in
code or an Implementation Design Note.

## Task Dependencies and Affected Surfaces

Milestone order is the default dependency order. A task may start only after
all named prerequisites exist and its owner contract remains authoritative.

| Work | Prerequisites | Primary affected surfaces | Parallel boundary |
| --- | --- | --- | --- |
| `T0.1`-`T0.4` | Reapproved SPEC-015 authority chain | `Tests/ContractFixtures/SPEC015/`, driver registry, exact package/source scans | Evidence schema, migration inventory, and driver skeleton may proceed together after names are fixed |
| `T1.1`-`T1.4` | Milestone 0 boundaries; focused value types available | `Sources/GiftUIHostConfiguration/`, focused unit tests, package graph | Value families may be implemented separately; validator orchestration waits for all exact declarations |
| `T2.1`-`T2.4` | SPEC-001 hierarchy/workload inputs; SPEC-006/008 counting rules; SPEC-012/013 limit vocabularies | checked-in descriptor, generator, generated preset manifests | Generator and negative leaf corpus may proceed together against one frozen schema |
| `T3.1`-`T3.6` | Milestones 1-2; SPEC-004/005/013 projections; SPEC-014 descriptor vocabulary | pure validator, adapter fixtures, validation transcripts | Stages may have focused tests in parallel; ordered validator composition waits for every stage |
| `T4.1`-`T4.4` | Valid report; implemented focused owner factories | bootstrap, failure adapter, lifecycle instance, teardown | Failure routing and lifecycle fixtures may proceed separately after one owner-call transcript is fixed |
| `T5.1`-`T5.5` | SPEC-001 and SPEC-009/010/011 application/runtime seams; SPEC-003/014 failure and health seams; active host lifecycle | application executor join, wake/pacing, input/action, backend health | Pacing and input/action fixtures may proceed in parallel against one serialized opportunity contract |
| `T6.1`-`T6.4` | Implemented SPEC-001 and SPEC-003 through SPEC-014 owner seams | four concrete target roots, profile workspaces, ELF/map/resource evidence | Each preset may build independently; normalized equivalence consumes all four immutable reports |
| `T7.1`-`T7.4` | Complete focused and integrated corpus | `run-spec-015.sh`, repository test gate, conformance report | Static scans may run early; conformance disposition waits for every criterion and required integration |

## Acceptance-Criterion Matrix

The criterion text in SPEC-015 remains authoritative. Each criterion appears
exactly once here with its implementation work and expected evidence.

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `HC-001` — Complete authority, metadata, manifest, portfolio, and upstream linkage without implied SPEC-001 approval | `T0.1`, `T7.4` | Governance and reciprocal-link audit | pending |
| `HC-002` — Pure ordered validation, first failure, no side effects or partial assembly, and valid-only instance exposure | `T1.4`, `T3.6`, `T4.1`, `T7.1` | Access-order probes, owner-call ledger, repeat-call corpus, construction transcript | pending |
| `HC-003` — Exact acyclic one-owner graph, portable import boundary, and no ambient/platform stack | `T0.2`, `T1.2`, `T7.1` | Exact graph corpus, source/import/link scans, negative compile fixtures | pending |
| `HC-004` — Exact SPEC-013 audit and complete schema-2 runtime-limit equality | `T0.4`, `T2.1`, `T2.2`, `T3.1`, `T3.2`, `T6.4` | Fresh four-manifest generation, schema-version rejection, per-leaf equality/lowering corpus including all render-workspace source/limit pairs, audit identity reports, static-table and byte-total checks | pending |
| `HC-005` — Exact five-Canvas minima and equal bounded render structural/ordinary operation counts | `T2.1`, `T2.3`, `T3.2`, `T6.4` | Generated workload manifests, checked arithmetic and capacity reports | pending |
| `HC-006` — Independent conjunctive Drawing and capability gates | `T3.2`, `T3.3`, `T7.1` | Two independent negatives, combined success, capability-vocabulary audit | pending |
| `HC-007` — Four contributions, five operation bits, required absence, one resolver call, exact endpoint equality | `T3.3`, `T6.4` | Permutation corpus, resolver instrumentation, effective-value transcripts | pending |
| `HC-008` — Exact immutable compatible text package and nine exact validation mappings | `T3.1`, `T4.2`, `T7.1` | Resource identity/lifetime probes and nine-row failure matrix | pending |
| `HC-009` — Exact action/model/fact/input cardinalities and fail-closed generation behavior without retention | `T1.3`, `T3.5`, `T5.4` | Action decode, replacement race, stale generation, borrow/non-retention transcripts | pending |
| `HC-010` — Equivalent bounded same-thread and distinct-executor fact admission without reentrant mutation | `T5.1`, `T6.4` | Ordered admission, callback, mutation, and normalized-equivalence transcripts | pending |
| `HC-011` — Non-reentrant wake, exact pacing and burst limits, bounded refusal termination, and no replay | `T1.3`, `T5.2`, `T5.3`, `T7.1` | Deadline-boundary, 28/32/33-fact, category-excess, refusal, supersession, and replay corpus | pending |
| `HC-012` — Total post-effect policy routing, exact no-policy rows, defective-table safety, and diagnostic independence | `T3.6`, `T4.2`, `T5.5`, `T7.1` | Complete routing/allowed-selection matrix, mandatory-effect ledger, diagnostic fault corpus | pending |
| `HC-013` — Equal macOS fixtures and exact Pi/nRF tiled endpoint joins | `T2.4`, `T3.4`, `T6.1`-`T6.3` | Four preset reports and exact extent/row/region/payload assertions | pending |
| `HC-014` — Complete activation/teardown state coverage, stale-work prevention, identity retirement, and fresh reconstruction | `T4.3`, `T4.4`, `T5.5` | State-transition, fault-at-step, callback cancellation, identity and reconstruction corpus | pending |
| `HC-015` — Static zero-prohibited-runtime/allocation and exact resource costs under pinned toolchains | `T6.2`-`T6.4`, `T7.2` | ELF, symbols, imports, allocation, RAM/stack/flash and component cost reports | pending |
| `HC-016` — Root runner executes all hardware-free fixtures and confines evidence | `T0.3`, `T7.2`, `T7.3` | Driver registry, output-boundary negatives, four immutable reports | pending |
| `HC-017` — Connected-target evidence remains separate and is never inferred from simulation/build | `T0.3`, `T6.2`, `T6.3`, `T7.4` | Evidence-kind labels and conformance disposition audit | pending |
| `HC-018` — Finite instance lifecycle, illegal-state rejection, exact local payloads, and validated report access | `T1.1`, `T4.3`, `T4.4`, `T5.2` | API/raw-value audit and complete lifecycle call matrix | pending |

## Milestones and Tasks

### Milestone 0: Freeze Authority, Boundaries, and Evidence Schemas

**Entry conditions:** SPEC-015 and coordinated SPEC-013 are reapproved; their
linked Proposals, RFCs, ADRs, and Specifications retain their authoritative
statuses.

**Exit evidence:** The exact work boundary, migration disposition, fixture
schema, and fail-closed driver contract exist before host implementation.

- [x] `T0.1` — Create `Tests/ContractFixtures/SPEC015/` with a README,
      ordered fixture registry, criterion registry for `HC-001` through
      `HC-018`, validation-access ledger schema, owner-call transcript schema,
      normalized four-preset report schema, required-evidence registry, and
      explicit `host-execution`, `cross-build`, `simulator`, and
      `connected-target` evidence kinds. Audit metadata, manifest, portfolio,
      and reciprocal links without treating SPEC-001 as approved by inference.
- [x] `T0.2` — Reserve the exact `GiftUIHostConfiguration` package target,
      focused tests, and narrowly named host/failure adapter fixtures in the
      package/dependency registries. Enforce its permitted focused-owner
      imports and prohibit portable Presentation, Domain, Data, focused
      owners, capabilities, backends, or drivers from importing it. Inventory
      the legacy Signal Analyzer `DependencyContainer`, SwiftUI app root,
      ambient services, direct model mutation, target branching, and dynamic
      storage; assign each preserve-as-evidence, replace-through-approved-owner,
      or remove-from-production disposition.
- [x] `T0.3` — Create and register a fail-closed
      `scripts/contracts/run-spec-015.sh` skeleton with the exact
      `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
      `nrf52840-embedded` profiles. It must record immutable input identity,
      compiler/SDK/toolchain/optimization metadata, commands and output
      hashes; mark unimplemented rows `missing`; write only below
      `.build/spec-015/`; and contain no network, deployment, restart, probe,
      or flashing action.
- [x] `T0.4` — Define checked-in schemas for the portable hierarchy/workload
      descriptor, generated schema-2 workload manifest, preset expectation,
      validation transcript, lifecycle transcript, normalized semantic report,
      and resource report. Every schema rejects unknown, missing, duplicate,
      reordered, stale, or unversioned required fields; the workload schema
      names all four render-workspace source counts and their exact
      `RuntimeProfileLimits.renderWorkspace` destinations; and evidence
      preserves exact focused error payloads rather than flattening them to
      strings.

### Milestone 1: Implement Exact Host Values and Finite Surfaces

**Entry conditions:** Milestone 0 fixes the target direction and evidence
contract. Every referenced focused type used in the SPEC-015 declarations is
available from its approved owner; absent types block only their dependent
declaration slice.

**Exit evidence:** The complete package SPI compiles with exact cases, raw
values, visibility, ownership, bounds, failable initialization, and static
layout evidence.

- [x] `T1.1` — Implement the exact SPEC-015 host-kind, validation-stage,
      configuration-error, assembly-report, validation-result,
      lifecycle-state, activation-result, opportunity-result,
      `MVPHostInstance`, validator, residual-policy-table, and residual-policy
      declarations in `Sources/GiftUIHostConfiguration/`. Add API snapshot,
      raw-value, associated-payload, `Equatable`/`Sendable`, noncopyable
      conformance, illegal construction, and package-access tests.
- [x] `T1.2` — Implement `HostComponentRole`, `HostComponentRoleSet`,
      `HostComponentRecord`, and the bounded graph-view seam. Prove exact bits
      `0...17`, rejection of bits `18...31`, exact raw-value ordering, no
      self/upward/unknown edges, eighteen production records, one owner per
      role, and acyclicity without allocation, reflection, untyped
      collections, service location, or ambient lookup. Prove the selected
      signal-source constructor receives its clock, scheduling, transport, or
      interrupt dependencies through source-owned concrete contracts visible
      in generated/compiler-visible construction evidence, without creating
      another component role or invoking those dependencies during validation.
- [x] `T1.3` — Implement `HostPacingPolicy`, cardinality, Drawing workload,
      complete workload, structural, action/model, input/wake, and endpoint
      configuration values with checked initializers where specified. Test all
      zero, boundary, sum-overflow, capacity, refusal-limit, profile/kind, and
      exact Signal Analyzer constants including `20 + 2 + 6 == 28`, capacity
      `32`, four-slot margin, six action codes, and one model/input owner.
- [x] `T1.4` — Implement a bounded one-shot validation-state guard shared by
      concrete validators. The first call may enter stages `0...8`; a second
      call returns graph-stage `.invariantViolation` without touching another
      projection. Instrument accessor and side-effect probes so the later
      ordered validator can prove that no client body, closure, owner, policy,
      diagnostic, scheduler, clock, input, endpoint, or external behavior ran.

### Milestone 2: Generate the Complete Workload and Four Preset Projections

**Entry conditions:** Milestone 1 value surfaces exist. Approved SPEC-001 and
SPEC-012/013 provide the exact hierarchy, application counts, Drawing rules,
and complete runtime-limit vocabulary; their implementation code is not used
as authority.

**Exit evidence:** One reviewable descriptor deterministically produces four
complete manifests and immutable preset projections with no runtime discovery
or defaulted limit leaf.

- [x] `T2.1` — Add one checked-in descriptor for the fixed Signal Analyzer
      hierarchy and application workload plus a deterministic host-only
      generator. Count every SPEC-006 semantic-node occurrence, every SPEC-008
      render semantic scope, layout scope, maximum render traversal depth,
      render text line including empty lines, glyph, ordinary operation, input,
      action, completion fact, Canvas, live Path element, snapshot element, and
      static callable/capture requirement under its owner Specification.
      Emit all four schema-2 manifests and their generated Swift preset values
      with source identity and content hashes. A freshness check must fail on
      schema 1, a changed descriptor, stale or manually edited output, or any
      non-deterministic regeneration. Generation and validation must not
      evaluate a client body or Canvas closure.
- [x] `T2.2` — Generate every complete nested `RuntimeProfileLimits` leaf and
      one exact expected SPEC-013 `RuntimeStorageAudit` for each preset. Add a
      generated per-leaf corpus proving equality succeeds and each
      independently lowered, unequal, wrong-profile, wrong-storage,
      wrong-static-table, or wrong-byte-total value fails; where a lower value
      is unconstructible, prove the owner initializer rejects it. Verify the
      four schema-2 source/limit pairs independently:
      `renderSemanticScopeOccurrences`/`maximumSemanticScopes`,
      `layoutScopeOccurrences`/`maximumLayoutScopes`,
      `maximumRenderTraversalDepth`/`maximumTraversalDepth`, and
      `renderTextLineCount`/`maximumTextLines`, plus the audited workspace
      capacity. Include wrapper/modifier depth and empty-line fixtures so the
      generated values exercise the approved SPEC-008 counting rules.
- [x] `T2.3` — Generate and verify the exact Drawing minima: five Canvases,
      202 live points, 12 live subpaths, five strokes/normalized operations,
      832 snapshotted points, and 16 snapshotted subpaths. Compute
      `ordinaryRenderOperations + 5` with checked arithmetic and prove the
      result fits producer, runtime, Drawing, render, sink, and endpoint lower
      bounds. Dynamic static-Canvas fields are `nil`; static fields exactly
      equal generated table metadata and capture bytes.
- [x] `T2.4` — Generate immutable projections for `macOSDynamic`,
      `macOSStatic`, `raspberryPiDynamic`, and `nrf52840Static`. The macOS pair
      shares logical extent, resources, workload counts, and effective
      semantics. Pi encodes 240 x 240 with a 240 x 16 RGB565 region. nRF52840
      encodes 480 x 320 with a 480 x 4 region, 960-byte rows, and exact
      3,840-byte raster, payload, and in-flight limits with one slot and no
      full framebuffer.

### Milestone 3: Implement Pure Nine-Stage Validation

**Entry conditions:** Milestones 1-2 pass. Required focused validation values
from SPEC-004, SPEC-005, SPEC-013, and SPEC-014 are implemented and stable.

**Exit evidence:** A validator processes the nine stages in exact order,
returns the first exact failure, reads no later projection, invokes no live
behavior, and emits one immutable report only after complete success.

- [x] `T3.1` — Implement stages 1-3 after graph validation: exact host/profile
      match and successful SPEC-013 audit/limit equality; one already-computed
      SPEC-005 result, selected realization, identity, compatibility, and
      lifetime join; then complete workload/cardinality/capacity validation.
      Cover every SPEC-013 local error and all nine SPEC-005 validation errors
      without constructing resources or reading their borrowed views outside
      the approved lifetime.
- [x] `T3.2` — Complete workload validation for producer, runtime, render,
      sink, observable, interaction, input, action, fact, Drawing, and static
      Canvas limits. Reject every schema version other than 2 before consuming
      a limit, require exact equality for each schema-2 source/limit pair, and
      prove equality at every remaining minimum, checked overflow paths,
      independent lowered leaves, exact ordinary-operation agreement, and the
      structural Drawing gate without naming Drawing capacities in SPEC-004.
- [x] `T3.3` — Implement the capability stage using exactly four
      role-addressed contributions, a two-candidate caller-owned workspace,
      all contribution-order permutations, and one required
      `RasterPresentationRequirement` carrying all five operation bits, the
      preset's exact logical extent, synchronous borrowed one-shot mode,
      admitted encodings and lifetimes, finite byte ceilings, and `.required`
      absence. Instrument exactly one resolver invocation and no steady-state
      resolver access. Keep capability failure independent from Drawing
      structural capacity and preserve SPEC-004's producer-specific failure
      mapping.
- [x] `T3.4` — Implement the endpoint stage against the inert SPEC-014 factory
      projection. Require exact effective-value equality, descriptor, writable
      capacity, payload, realization, lifetime/handoff, one in-flight slot,
      byte ceilings, and the single shared health owner. Cover both inert
      mismatch and post-construction mismatch using SPEC-014's exact
      safety-not-proven mapping, with no live endpoint call during validation.
- [x] `T3.5` — Implement action/model and input/wake stages: six total action
      codes `0...5`, one immutable handler, one root location/registration/
      staging record, publishable target generation, exact fact capacities,
      one normalized source, one target-local gate, one non-reentrant wake
      requester, and distinct logical application/mutation domains. Validate
      the source spacing, maximum callbacks per action, repository/use-case
      callback bounds, executor limits, admission adapter, total handler, and
      all application-factory projections supplied to the validator. Reject
      invalid code, stale generation, incompatible callback bounds, retained
      owner references, and reentrant or malformed integration.
      **Complete:** the pure configuration projection validates the exact
      action range, handler/model cardinality, source spacing, callback bounds,
      executor/fact bounds, admission count, total-handler/publishable-
      generation declarations, non-retention/non-reentrancy declarations,
      normalized-input gate, wake count, and distinct domains. Focused
      production-dispatch fixtures cover stale generation/replacement races,
      invalid action decoding, and poisoned-lifetime model non-retention.
- [x] `T3.6` — Implement policy-stage table completeness, allowed/selected
      pair validation, fatal-hook availability, diagnostic independence, and
      final `HostAssemblyReport` construction. Compose all nine stages with an
      accessor ledger proving fixed order, immediate stop, no later read,
      single-use validation, no partial report/borrow, no policy decision, and
      no live owner construction on failure.

### Milestone 4: Construct, Activate, Fail, and Tear Down One Host

**Entry conditions:** Milestone 3 yields a valid immutable report. The exact
focused owner factories required by SPEC-003 through SPEC-014 are implemented;
their absence blocks the corresponding integration task and does not permit a
substitute owner in this target.

**Exit evidence:** A concrete fixture preset exposes no instance on invalid
configuration, activates in exact order, preserves finite local failures, and
tears down idempotently from every instance state.

- [x] `T4.1` — Implement the two-phase preset construction seam. Construct
      inert projections and one validator, call `validate()` exactly once, and
      expose a `.valid` instance only for `.valid(report)`. After success,
      construct live owners without changing any projection and verify the
      endpoint and every retained immutable value equal the report. Prove the
      active instance has exactly one runtime, endpoint, resource package,
      capability snapshot, root target, handler, application executor, wake
      integration, and policy table. On failure, discard all projections and
      expose no instance or borrow.
- [x] `T4.2` — Implement the narrow host/failure adapter and exact total
      residual policy table. Preserve focused payloads and mappings, host
      error conditions, mandatory-effect ordering, all nine host contexts,
      every explicit no-policy row, ordinals/limits, allowed sets, and fixed
      selections. Ordinary startup failure invokes the complete table once
      only after validator return; defective tables quiesce mechanically and
      never decide through themselves. Diagnostics remain optional downstream
      projections and cannot change a transcript.
- [x] `T4.3` — Implement `MVPHostInstance.activate()` and its finite inline
      preset-specific activation-failure sum. Follow the seven specified
      construction/attachment/observation/input/source/runtime steps in order,
      fault each step, perform mandatory containment, preserve the first exact
      payload, and enter `.active` or terminal `.failed`. Repeated or
      wrong-state activation calls make no owner call and map to the exact
      reentrancy/safety-not-proven route.
- [x] `T4.4` — Implement explicit synchronous idempotent teardown in the exact
      eight-step order from `.valid`, `.activating`, `.active`, `.failed`,
      `.quiescing`, and `.quiescent`. Reject new delivery/input, stop and
      detach observations, cancel callbacks/sequences, finalize/quiesce,
      retire registrations and identities, release endpoint/resource/platform
      owners, reset profile storage last, and prevent stale callbacks, report
      reuse, or reactivation.

### Milestone 5: Integrate Serialized Application, Runtime, Input, and Recovery

**Entry conditions:** Milestone 4 supplies an active fixture host. SPEC-009,
SPEC-010, SPEC-011, and SPEC-001 expose their implemented coordinator,
observable target, action-domain, admission, and application-executor seams.

**Exit evidence:** Same-thread and distinct-executor fixtures produce equal
ordered transcripts with bounded facts, non-reentrant wake and mutation,
finite refusal recovery, and exact operational-failure routing.

- [x] `T5.1` — Join the source, repository, use cases, application executor,
      two repository sinks, the SPEC-010/ADR-027 admission adapter, root
      observable model,
      and mutation domain without direct callback-to-model mutation. Prove the
      two bootstrap current-value facts, ordered application opportunities,
      bounded later fact admission, same-thread/distinct-executor equivalence,
      and that synchronous repository callbacks stop at admission for a later
      runtime opportunity.
      The bounded production application-opportunity gate rejects reentrant
      and unavailable entry. The focused deterministic source/repository/
      use-case fixture proves equivalent same-thread and explicitly queued
      distinct-executor delivery for bootstrap, an action-induced callback
      burst, and a later scheduled source transition. Every synchronous
      callback stops at bounded admission, leaves the root model unchanged,
      and applies only from the sealed mutation phase. Concrete four-preset
      ownership remains the Milestone 6 root work.
- [x] `T5.2` — Implement non-reentrant wake accumulation and host scheduling.
      An empty-to-nonempty transition requests one wake and returns; serialized
      `runOpportunity()` begins at or after the 250,000-microsecond frame
      boundary and no later than the active 250,000-microsecond service-window
      deadline. Cover just-before/at/just-after boundaries, facts around the
      seal, wake coalescing, illegal lifecycle entry, and exposed report
      identity without synchronous runtime entry. Under a sustained
      80-transition-fact-per-second workload, prove admission without
      rejection, ordered facts, coalesced change reports, and derivation paced
      at four frames per second.
- [x] `T5.3` — Integrate presentation supersession, backpressure, retryable
      refusal, non-retryable refusal, and terminal unavailability. Prove
      backpressure leaves the count unchanged, refusals retain ordinals zero
      through two, the third terminates without a fourth offer, newer
      revisions replace old pending intent in constant space, and no fact,
      action, Canvas closure, plan, operation stream, or payload is replayed.
- [x] `T5.4` — Join normalized input and action dispatch. The target-local gate
      attaches current physical-presentation provenance and drops malformed,
      stale, unknown, unavailable, out-of-order, or excess sequences before
      runtime admission. Dispatch revalidates action/target generations and
      enabled state, borrows the exact current model, invokes one immutable
      handler in mutation phase, and retains neither handler nor model in
      action records or pointer capture. For the manifest's exact nonzero input
      and semantic-action limits, prove submission at each configured bound
      succeeds and the first excess follows SPEC-009's exact capacity refusal
      and source-sequence cancellation behavior without resizing any limit.
- [x] `T5.5` — Integrate mutable endpoint/display health without changing the
      immutable capability snapshot. After responsibility transfer, drain the
      one-shot stream and update the single health owner before routing
      `backendOperationalFailure`; quiesce presentation-coupled input. Prove
      terminal unavailability, identity exhaustion, graph/resource/extent/
      policy change, or immutable configuration change requires complete fresh
      construction rather than reactivation.

### Milestone 6: Realize and Compare the Four MVP Presets

**Entry conditions:** Milestones 0-5 pass. SPEC-001 and SPEC-003 through
SPEC-014 have implemented owner seams and ready plans. Concrete target roots
remain outside portable Presentation and import inward only.

**Exit evidence:** All four hardware-free preset reports build with pinned
toolchains and normalize to equal semantics while preserving exact permitted
profile/backend differences and resource accounting.

- [x] `T6.1` — Implement macOS dynamic and static composition roots using the
      same immutable logical extent, exact text package, workload, actions,
      facts, endpoint semantics, and normalized scripts. Prove only storage
      and dispatch mechanism differ, then force complete reconstruction after
      an extent change.
      **Completed:** the two executable products consume the same generated
      workload and portable `SignalAnalyzerView`, validate the fixed 18-role
      graph and exact profile audit, resolve the four capability contributions
      once, and execute the same 20-fact production-admission script. Their
      normalized checksum and logical/endpoint semantics match; only the
      approved profile-storage totals differ. Neither root exposes mutable
      extent, so changing it requires fresh preset validation and construction.
      Reproduction and exact values are recorded in
      `Tests/ContractFixtures/SPEC015/Evidence/milestone-6/macos-presets.md`.
- [x] `T6.2` — Implement the Raspberry Pi dynamic hardware-free composition
      root and ARMv6 compile/link fixture for
      `armv6-unknown-linux-gnueabihf`. Verify the exact 240 x 240, 240 x 16
      RGB565 projection, dynamic audit, symbols/imports, and component costs.
      Label the result cross-build evidence only; connected deployment later
      requires an explicit request and remote `armv6l` verification.
      **Completed:** `SignalAnalyzerRaspberryPiARMv6` links the shared portable
      Presentation, production Dynamic admission owner, generated Pi preset,
      and fixed graph/capability validation into one executable. The pinned
      workflow verifies its 32-bit ARMv6 hard-float ELF, dependencies, digest,
      artifact size, exact tiled projection, and component/profile storage.
      The matching semantic fixture is host-native and the report labels all
      connected execution `not-collected`; no deployment occurred. Evidence is
      in `Tests/ContractFixtures/SPEC015/Evidence/milestone-6/raspberry-pi-armv6.md`.
- [x] `T6.3` — Implement the nRF52840 static hardware-free composition root and
      Embedded Swift compile/link fixture for `nrf52840dk/nrf52840` with the
      bundled `armv7em-none-none-eabi` module and Cortex-M4F hard-float flags.
      Verify the exact 480 x 320 tiled projection, 3,840-byte bounds, one slot,
      no framebuffer, and ELF VFP calling convention. Label the result
      cross-build evidence only; no board flashing is part of this task.
      **Completed:** `signal-analyzer-static` provides the Embedded Swift
      preset entry and named caller-owned profile, application capture/snapshot,
      and one-slot raster staging stores. The pinned build emits all required
      artifacts, verifies ARMv7E-M/VFP ABI, zero heap configuration and
      allocator entry points, exact projection/storage, and aggregate RAM,
      flash, and entry-stack costs. The host-native Static oracle supplies the
      normalized semantic result without converting it into target execution.
      Evidence is in
      `Tests/ContractFixtures/SPEC015/Evidence/milestone-6/nrf52840-static.md`.
- [x] `T6.4` — Compare graph, limit, audit, resource, capability, action, fact,
      input, semantic, render semantic-scope, layout-scope, traversal-depth,
      text-line, glyph, ordinary/drawing-operation, failure, publication, and
      lifecycle transcripts across all four presets. Report zero resolver
      calls after startup and, for static presets, zero heap allocation during
      construction, steady-state opportunities, action dispatch, fact
      admission, and teardown, plus zero reflection, tasks, threads,
      exceptions, Objective-C runtime, dynamic collections, or prohibited
      linked dependencies. Record endpoint/payload, application storage,
      host-policy, staging, stack high-water, RAM, and flash costs separately
      under pinned tools, and verify the nRF52840 aggregate and incremental
      totals remain within the approved SPEC-004 and SPEC-014 budgets.
      **Completed:** `run-spec-015-milestone-6.sh` rebuilds all four roots and
      applies one fail-closed comparison to their immutable reports. Semantic,
      structural, workload, resolver, and storage fields agree where required;
      physical projection, ABI, profile storage, staging, RAM, flash, and
      connected-evidence classifications remain separate. Static allocation
      and prohibited-runtime claims compose the accepted owner evidence and
      final nRF symbol/configuration inspection. Evidence is in
      `Tests/ContractFixtures/SPEC015/Evidence/milestone-6/four-preset-comparison.md`.

### Milestone 7: Complete the Contract Runner and Conformance Handoff

**Entry conditions:** Every focused and integrated fixture is implemented and
all four preset builds are reproducible from repository-local inputs.

**Exit evidence:** One root command reproduces all hardware-free evidence,
every acceptance criterion has a checkable disposition, and remaining
connected-hardware evidence is explicit rather than implied.

- [x] `T7.1` — Complete the exhaustive negative corpus: graph shape/order,
      every validation stage and no-later-read proof, every runtime-limit leaf,
      schema-1 and malformed/stale schema-2 manifests, all four independent
      render-workspace source/limit mismatches, wrapper/modifier traversal
      depth and empty text lines, Drawing/capability independence,
      contribution permutations, all text errors, endpoint mismatches,
      action/input/generation faults, 28/32/33 fact boundaries,
      producer-category excess, configured input/action limit success and
      first-excess cancellation, every policy/no-policy row, every
      construction/activation/teardown state, diagnostics, arithmetic, and
      fault injection. Add forbidden-import and portable-source scans.
      The registered audit now requires every focused negative family and the
      host-import, protected-owner, ambient-lookup, and portable-source scans;
      the focused suite exercises all 140 host-configuration cases.
- [x] `T7.2` — Finish `scripts/contracts/run-spec-015.sh` so each exact profile
      runs unit, conformance, integration, compile/link, static-runtime,
      allocation, latency, resource-accounting, and generated-manifest
      freshness checks; exits nonzero on a missing, stale, malformed, or
      failing row; and writes nothing outside `.build/spec-015/`. Register it
      in the repository test gate only after its prerequisites are available
      and its output is deterministic.
- [x] `T7.3` — Run the maintained documentation checks, Swift formatter before
      the repository test gate, focused unit suites, each SPEC-015 profile,
      `scripts/test.sh`, clean source/import/dependency scans, and deterministic
      evidence verification. Record compiler, optimization, target triple,
      fixture, repetition method, revision, dirty state, and input/output
      hashes in each immutable report.
- [x] `T7.4` — Create `docs/conformance/spec-015-conformance.md`, map every
      `HC-001` through `HC-018` row to evidence and pass/fail/blocked status,
      link the report from this plan and SPEC-015, and classify PiScreen and
      nRF52840 TFT display/input runs as separate connected-target gates naming
      hardware, software, transport, and observed architecture. Request the
      human `implemented` transition only after all required criteria and
      connected-target obligations have conforming evidence.

## Design-Note Triggers

- Create a focused design note before `T2.1` if the descriptor-to-manifest
  generator needs non-obvious ownership, traversal, or source-to-limit mapping
  beyond the checked-in schema and generator code, especially for the four
  schema-2 render-workspace fields. The note may explain generation mechanics
  but cannot choose counts or counting rules.
- Create a focused design note before `T3.6` if the nine-stage validator needs
  a maintained explanation of accessor sequencing, single-use state,
  noncopyable borrows, or fail-closed report construction beyond direct code.
- Create a focused design note before `T4.2` if mandatory-effect evidence,
  exact focused-payload preservation, policy ordinals, and defective-table
  bypass require one cross-owner routing model to remain reviewable.
- Create a focused design note before `T4.3`/`T4.4` if concrete owner storage
  and partial-activation teardown need a nontrivial typestate or tagged-union
  realization, especially for static no-allocation presets.
- Create a focused design note before `T5.2` if the shared frame-boundary and
  fact-service deadline require non-obvious checked-time arithmetic or a
  bounded wake state machine.
- Create a focused design note before `T6.3` if generated static wiring,
  capture-table placement, or resource accounting cannot be explained by the
  generated manifest and link report alone.

Design Notes may explain replaceable internal mechanisms only. They may not
choose different preset values, lifecycle transitions, owners, policy rows,
or recovery behavior.

## Integration and Validation Order

1. Establish governance, package, source, fixture, and output boundaries.
2. Land exact host value declarations and bounded primitive validation.
3. Generate and review the complete schema-2 workload and four preset
   projections; reject stale output and prove each descriptor source maps to
   its owning limit before validator integration.
4. Implement and exhaustively test the pure nine-stage validator.
5. Join failure policy, construct one fixture host, and prove activation and
   teardown before running steady-state opportunities.
6. Integrate fact admission, wake/pacing, refusals, input/action dispatch, and
   backend operational health against implemented focused owners.
7. Realize macOS dynamic/static, Raspberry Pi ARMv6, and nRF52840 static roots
   independently; then normalize and compare their reports.
8. Run the complete hardware-free contract driver and repository gate.
9. Perform separately authorized connected PiScreen and nRF52840 TFT checks;
   do not infer them from compilation, simulation, or host fixtures.
10. Produce the conformance report and request the human lifecycle transition.

Unit and pure validation tests run before integration. macOS dynamic is the
behavioral reference, macOS static proves early static constraints, Raspberry
Pi proves ARMv6/Linux compile/link and later PiScreen operation, and nRF52840
proves Embedded Swift/resource constraints and later connected TFT/input
operation. A later profile cannot repair a failed earlier contract row, and a
cross-build cannot satisfy a connected-hardware row.

## Risks and Upstream Blockers

### Upstream blockers

- SPEC-011 through SPEC-013 have active plans and production owner slices, but
  retain incomplete profile, application, host, platform, resource, or
  conformance tasks. `T4.*`, `T5.*`, and `T6.*` wait only for the exact
  unfinished seams they consume. SPEC-013's production-owner integration is
  itself waiting for SPEC-010 equal-profile work and SPEC-015 assembly inputs;
  implement the shared boundary once through the owning tasks rather than
  creating reciprocal duplicate adapters.
- SPEC-003, SPEC-004, SPEC-009, and SPEC-010 retain active-plan work.
  SPEC-005 and SPEC-006 have completed plans but await conformance and their
  human `implemented` transitions; SPEC-007 and SPEC-008 are implemented.
  SPEC-014 has a completed plan and complete conformance report, so its
  reusable endpoint seams are available, while its human Specification status
  transition remains separate. SPEC-015 may test adapters against available
  seams but cannot claim production assembly until every consumed owner closes
  the prerequisite named by the dependent task.
- The current repository gate also requires owner-side maintenance of the
  SPEC-002/006/007/008 source and downstream-consumer inventories and
  SPEC-013's immutable report publication path. Those existing failures block
  `T7.3`; they do not block the ordered host-only work in Milestones 0-3 and
  must be fixed under their governing plans rather than hidden in SPEC-015.
- Approved SPEC-001 now has a ready
  [implementation plan](spec-001-implementation-plan.md). The workload
  descriptor and concrete host roots still wait for that plan's implemented
  portable hierarchy, six-action domain, fact producers, deterministic mock
  trace, and application failure inputs; the legacy SwiftUI demo cannot
  substitute for them.
- If any linked owner exposes declarations inconsistent with the exact
  SPEC-015 package SPI, stop the affected task and route the discrepancy to
  the owning Specification. Do not add a compatibility wrapper that changes
  ownership or semantics merely to make the plan compile.

### Implementation risks

- The cross-owner validator can accidentally construct or touch live owners;
  accessor ledgers and inert factories are required from the first slice.
- Generated workload counts can drift from the portable hierarchy; input
  identity, deterministic regeneration, and exact checked-in comparisons make
  drift fail closed.
- Static host storage may tempt dynamic erasure or hidden allocation; package
  boundaries, SIL/symbol/link checks, allocation instrumentation, and matched
  static fixtures must accompany each static slice.
- Deadline arithmetic and refusal state can conflate fact service with frame
  offers; boundary-time tests and separate counters prevent that collapse.
- Failure adapters can flatten focused errors or invoke policy before mandatory
  effects; exact payload tests and a state/effect ledger are mandatory.
- Platform roots can grow into vertical stacks; source/import/dependency scans
  must keep semantic, capability, runtime, backend, and hardware ownership in
  their approved modules.
- Resource evidence can double-count or hide bytes between owners. Every
  report must list profile, host, application, capability, backend, staging,
  stack, RAM, and flash costs separately before aggregation.

## Deferred and Follow-up Work

SPEC-015 creates no new deferred item. Existing contextual items remain
outside this plan and are not authorized implementation work:

- [FW-006](../future-work/fw-006-generated-target-configuration.md) preserves
  optional generalized target-configuration generation. SPEC-015 uses only
  the bounded checked-in generator needed for its four approved presets.
- [FW-009](../future-work/fw-009-shared-delegated-service-foundation.md)
  preserves a shared delegated-service foundation until multiple approved
  consumers justify it.
- [FW-018](../future-work/fw-018-live-surface-reconfiguration.md) preserves
  live surface reconfiguration. SPEC-015 requires teardown and fresh host
  construction after an extent change.

If implementation reveals a useful non-blocking optimization or question,
capture it through the deferred-work track and cross-link it before excluding
it from this plan. Architectural or contractual blockers stay upstream and
must not be deferred merely to continue implementation.

## Completion Record

This plan returned to `draft` on 2026-09-11 for the coordinated SPEC-008/
SPEC-013 render-workspace contract and schema-2 workload inputs. No task is
complete, no design note or conformance report exists, and no SPEC-015
implementation evidence is invalidated or claimed. The maintainer explicitly
reapproved SPEC-013 and SPEC-015 on 2026-09-12. The 2026-09-13 readiness pass
mapped the previously untraced evidence-schema task, made schema-2 generation,
freshness, rejection, and source-to-limit evidence explicit, refreshed the
implemented-owner inventory and gates, and restored this plan to `ready`.
Update each task disposition and evidence link in place as work proceeds. Plan
completion does not mark SPEC-015 implemented; that transition requires a
complete conformance review and explicit human authorization.

Milestone 2 generated one checked descriptor, four schema-2 manifests, a
complete 164-row per-preset limit-leaf corpus, and immutable Swift projections
with one embedded descriptor identity. The generated values pass SPEC-013's
complete storage audit in both profiles, preserve the exact Drawing minima and
combined render bound, omit static Canvas metadata from Dynamic presets, and
encode the approved macOS, Pi, and nRF raster projections. Freshness and focused
evidence are recorded in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-2/generated-workload-and-presets.md`.

T1.1 completed the remaining compile-surface evidence for the exact host
result and protocol declarations. Focused tests preserve associated payloads,
raw values, equality, and `Sendable` constraints; a package compile fixture
proves noncopyable instance/validator conformance and residual-policy
specialization; and negative fixtures reject external access and a
non-`Sendable` activation failure. Evidence and reproduction commands are in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-1/host-configuration-surfaces.md`.

T1.3 completed the immutable host value family. Focused tests reject every
zero pacing field and both checked-sum overflow positions, accept the exact
lower and representable upper boundaries, and prove every generated preset's
kind/profile, 20/2/6 fact split, 28-of-32 capacity with four-slot margin,
six-action and single-owner cardinalities, structural audit, input/wake
configuration, and inert endpoint projection. Reproduction evidence is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-1/host-configuration-values.md`.

T3.1 made the concrete validator consume the exact typed SPEC-013 validation
result before accepting its retained audit. It preserves all seven runtime
profile errors at `.runtimeProfile`, compares the returned audit with the
immutable structural projection, consumes the already-computed SPEC-005
result without constructing or borrowing a resource owner, and preserves all
nine text errors at `.textResources`. The exact success fixture proceeds into
the existing workload stage and produces a complete immutable report.
Reproduction evidence is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-3/profile-and-text-validation.md`.

T3.2 added one pure complete workload gate before capability resolution. It
rejects schema versions other than 2 and zero source counts, requires the
complete generated `RuntimeProfileLimits` value plus every semantic, layout,
render-workspace, text, glyph, ordinary-operation, input, action, completion,
observable, interaction, fact-storage, Drawing, and static-Canvas source/limit
relation, and preserves the exact 250-millisecond, 20/2/6, 28-of-32 pacing
contract. All four presets pass; independent source-count, cardinality,
pacing, fact-storage, and Drawing negatives fail with their exact host error.
Evidence is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-3/complete-workload-validation.md`.

T3.3 integrated the approved SPEC-004 resolver as the sole capability-stage
call. The fixture corpus inserts the four role-addressed contributions in all
24 orders, requires a two-candidate caller-owned workspace, carries all five
operation bits and the exact extent, lifetime, encoding, byte, and required-
absence inputs, preserves focused missing-role/workspace failures, and proves
that valid Drawing capacity does not repair a failed capability gate. The
validator's one-shot guard prevents a second resolver entry, and a source
audit confirms no other host source invokes the resolver. Evidence is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-3/capability-validation.md`.

T3.4 added a pure inert endpoint validator for every SPEC-014 construction
relation: effective value, surface extent/region/row/encoding/realization,
raster and payload limits, writable bytes, submission lifetime and handoff,
in-flight count and bytes, selected text realization, and one shared health
owner. The checked validator accepts no live endpoint or callback, so failure
precedes owner construction. The same helper rejects an already-constructed
projection unequal to the validated value with
`.invalidEndpointDescriptor`, preserving SPEC-014's safety-not-proven mapping
for the later bootstrap adapter. Evidence is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-3/endpoint-validation.md`.

The first T3.5 slice extracted pure action/model and input/wake projection
validation. Exact success and every independently malformed field now report
at `.actionAndModel` or `.inputAndWake`, with root-target defects preserved as
`.invalidModelTarget`. T3.5 remains open for concrete stale-generation,
callback-bound, admission, and non-retention evidence joined with T5.4.
Current evidence is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-3/application-projection-validation.md`.

The first T3.6 slice now requires exact equality with all nine approved policy
rows rather than merely accepting any selected member of a nonempty set. It
rejects each independently wrong allowed set or selection, proves the policy
stage is last across the available combined-failure corpus, and checks every
immutable `HostAssemblyReport` field. T3.6 remains open for the complete
poison-accessor and no-side-effect ledger. Current evidence is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-3/policy-and-report-validation.md`.

`T4.2` is complete. The host failure boundary preserves the focused
SPEC-013, SPEC-005, and SPEC-004 mappings and now routes all nine operational
contexts only after their exact mandatory-effect sets. Missing effects,
malformed policy inputs, defective tables, and out-of-table policy selections
bypass the policy and fail closed through the independently configured fatal
hook. All explicit no-policy reasons invoke no policy, and a failed optional
diagnostic projection leaves the authoritative failure and disposition
unchanged. Evidence is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-4/host-failure-adapter.md`.

`T5.3` is complete. `HostPresentationRecovery` retains only the bounded
SPEC-009 presentation intent, keeps backpressure refusal-neutral, emits retry
ordinals zero and one, and makes the third retryable refusal terminal without
a fourth offer. A newer semantic revision replaces the former intent and
resets its count in constant space; acceptance clears only its matching intent,
while non-retryable refusal immediately clears intent and quiesces input. The
state contains no fact, action, Canvas closure, plan, operation stream, or
payload that could be replayed. Evidence is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-5/presentation-recovery.md`.

`T5.5` is complete. `HostEndpointHealthController` observes the live
endpoint-owned health value without duplicating its mutable authority. It
exposes a backend operational failure only after responsibility transfer,
one-shot drain, and health update, then quiesces presentation-coupled input.
Missing transfer/drain evidence and counter regression fail closed. Terminal
unavailability, identity exhaustion, and every immutable graph/resource/
extent/policy/configuration change require fresh host construction through a
terminal controller with no reactivation path. Evidence is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-5/endpoint-health-and-reconstruction.md`.

`T5.2` is complete. `HostScheduledOpportunityController` binds the validated
assembly report to the fixed-size wake/pacing state and enters
`MVPHostInstance.runOpportunity()` only through a serialized scheduled service
call. Wake recording returns before runtime entry; lifecycle/report mismatch,
early timing, and quiescence invoke no runtime owner. The sustained fixture
preserves all 80 ordered facts and change reports while coalescing them into
four wakes and four derivations at exact 250,000-microsecond boundaries.
Evidence is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-5/scheduled-opportunity.md`.

`T5.4` is complete. `HostNormalizedInputGate` implements the one-source
target-local presentation gate, consumes sequence identity only for submitted
downs, enforces ordinal zero and checked successors, and cancels stale,
unknown, unavailable, malformed, out-of-order, exhausted, and runtime-refused
sequences without retargeting. Focused tests prove the configured bound and
first-excess capacity cancellation, while the existing production dispatcher
fixtures prove all six actions, final generation/enabled-state checks, exact
current-model borrowing, replacement cancellation, and non-retention. Evidence
is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-5/normalized-input-and-action.md`.

`T7.1` is complete. The negative-corpus audit binds every required family to
its maintained focused suite and retains the existing forbidden-import and
portable-source scans. The 2026-09-19 reproduction passed the audit and all
140 host-configuration tests without simulator or connected-target activity.
Evidence is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-7/exhaustive-negative-corpus.md`.

`T7.2` is complete. Every exact driver mode now runs the common schema,
negative, source-boundary, generation-freshness, validation-purity,
compile-surface, and focused test gates before its profile-specific build and
inspection. Immutable reports retain the full command log and keep connected
operations false. Evidence is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-7/four-profile-driver.md`.

`T7.3` is complete. The maintained formatter, governance/documentation checks,
focused suites, all four SPEC-015 modes, source/import/dependency scans, and
the complete hardware-free repository matrix pass deterministically. Evidence
is in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-7/repository-gates.md`.
T7.4 is next.

`T7.4` is complete. The linked
[conformance report](../conformance/spec-015-conformance.md) maps all eighteen
criteria to passing hardware-free evidence and records no divergence or
exception. The connected PiScreen and nRF TFT/input rows remain explicitly
open, so the plan stays active and SPEC-015 remains `implementing`; no
`implemented` transition is requested yet.
