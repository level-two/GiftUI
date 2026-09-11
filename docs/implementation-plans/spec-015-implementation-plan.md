---
spec: SPEC-015
feature: giftui-mvp-architecture
title: SPEC-015 Implementation Plan
status: draft
owners:
  - codex
created: 2026-09-09
updated: 2026-09-11
related_design_notes: []
conformance_report: null
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-015 Implementation Plan

> This plan is paused in `draft` while the focused 2026-09-11 schema-2
> workload amendment to SPEC-015 is in review. It does not authorize connected
> deployment, service restart, or board flashing.

## Authority and Scope

The governing [SPEC-015](../specs/spec-015-host-configuration.md) contract is in
review for the generated SPEC-008 render-workspace inputs carried through
SPEC-013. Its authority chain otherwise consists of accepted
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
  `implementation`. SPEC-015 itself is in `review`; implementation has not
  begun.
- All linked ADRs are accepted and all linked RFCs are approved. SPEC-013 and
  SPEC-015 are in coordinated review for the render-workspace workload schema;
  no new architectural choice is open.
- `Package.swift` has no `GiftUIHostConfiguration` target, host-instance
  target, runtime-profile owner, Interaction owner, Drawing owner, raster
  backend owner, concrete four-preset root, or SPEC-015 test target.
- Existing production targets implement portions of SPEC-003 through
  SPEC-010: failure, capability, semantic, text-resource, render, execution,
  and observable-state seams. Their implementation plans retain incomplete
  downstream integration work; this plan must consume those owners rather
  than duplicate them.
- SPEC-011 through SPEC-014 now have ready implementation plans but no
  production owner targets. Their declarations, lifecycle behavior, backend
  endpoint, runtime profile, and Drawing integration are hard entry conditions
  for the production assembly milestones below.
- `Tests/ContractFixtures/` and `scripts/contracts/` contain registered
  reproducible suites through SPEC-010. There is no `SPEC015` fixture tree,
  driver registration, `scripts/contracts/run-spec-015.sh`, or
  `.build/spec-015/` evidence.
- `demo/SignalAnalyzer/` is a separate SwiftUI investigation with portable
  Domain/Data/Presentation material and a legacy `DependencyContainer`. It is
  evidence and migration input only. Its SwiftUI `App`, `MainActor`, dynamic
  closures, and composition root are not the approved GiftUI host.
- Repository-local ARMv6 and nRF52840 toolchain, doctor, probe, build, and
  artifact-inspection workflows already preserve the required target pins.
  SPEC-015 may invoke hardware-free compile/link inspection but may not deploy
  or flash.

## Readiness Review

**Reviewed:** 2026-09-09

**Disposition:** Paused pending Specification reapproval. The authority chain
is otherwise complete and all eighteen acceptance criteria map exactly once,
but the plan must freeze the schema-2 render-scope, traversal-depth, text-line,
and render-workspace evidence before becoming ready. No implementation task
proceeds while the amended Specification is in review.

No `docs/features.yaml` edit is required for this derived record. After
reapproval and a ready-plan review, implementation start still requires an
authorized SPEC-015 transition to `implementing` with the corresponding
metadata and manifest consistency update.

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
| `T2.1`-`T2.4` | SPEC-001 hierarchy/workload inputs; SPEC-012/013 limit vocabularies | checked-in descriptor, generator, generated preset manifests | Generator and negative leaf corpus may proceed together against one frozen schema |
| `T3.1`-`T3.6` | Milestones 1-2; SPEC-004/005/013 projections; SPEC-014 descriptor vocabulary | pure validator, adapter fixtures, validation transcripts | Stages may have focused tests in parallel; ordered validator composition waits for every stage |
| `T4.1`-`T4.4` | Valid report; implemented focused owner factories | bootstrap, failure adapter, lifecycle instance, teardown | Failure routing and lifecycle fixtures may proceed separately after one owner-call transcript is fixed |
| `T5.1`-`T5.5` | SPEC-009/010/011 production seams; active host lifecycle | application executor join, wake/pacing, input/action, backend health | Pacing and input/action fixtures may proceed in parallel against one serialized opportunity contract |
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
| `HC-004` — Exact SPEC-013 audit and complete schema-2 runtime-limit equality | `T2.2`, `T3.1`, `T6.4` | Per-leaf equality/lowering corpus including render workspace, audit identity reports, static-table and byte-total checks | pending |
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

- [ ] `T0.1` — Create `Tests/ContractFixtures/SPEC015/` with a README,
      ordered fixture registry, criterion registry for `HC-001` through
      `HC-018`, validation-access ledger schema, owner-call transcript schema,
      normalized four-preset report schema, required-evidence registry, and
      explicit `host-execution`, `cross-build`, `simulator`, and
      `connected-target` evidence kinds. Audit metadata, manifest, portfolio,
      and reciprocal links without treating SPEC-001 as approved by inference.
- [ ] `T0.2` — Reserve the exact `GiftUIHostConfiguration` package target,
      focused tests, and narrowly named host/failure adapter fixtures in the
      package/dependency registries. Enforce its permitted focused-owner
      imports and prohibit portable Presentation, Domain, Data, focused
      owners, capabilities, backends, or drivers from importing it. Inventory
      the legacy Signal Analyzer `DependencyContainer`, SwiftUI app root,
      ambient services, direct model mutation, target branching, and dynamic
      storage; assign each preserve-as-evidence, replace-through-approved-owner,
      or remove-from-production disposition.
- [ ] `T0.3` — Create and register a fail-closed
      `scripts/contracts/run-spec-015.sh` skeleton with the exact
      `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
      `nrf52840-embedded` profiles. It must record immutable input identity,
      compiler/SDK/toolchain/optimization metadata, commands and output
      hashes; mark unimplemented rows `missing`; write only below
      `.build/spec-015/`; and contain no network, deployment, restart, probe,
      or flashing action.
- [ ] `T0.4` — Define checked-in schemas for the portable hierarchy/workload
      descriptor, generated schema-2 workload manifest, preset expectation,
      validation transcript, lifecycle transcript, normalized semantic report,
      and resource report. Every schema rejects unknown, missing, duplicate,
      reordered, or unversioned required fields and preserves exact focused
      error payloads rather than flattening them to strings.

### Milestone 1: Implement Exact Host Values and Finite Surfaces

**Entry conditions:** Milestone 0 fixes the target direction and evidence
contract. Every referenced focused type used in the SPEC-015 declarations is
available from its approved owner; absent types block only their dependent
declaration slice.

**Exit evidence:** The complete package SPI compiles with exact cases, raw
values, visibility, ownership, bounds, failable initialization, and static
layout evidence.

- [ ] `T1.1` — Implement the exact SPEC-015 host-kind, validation-stage,
      configuration-error, assembly-report, validation-result,
      lifecycle-state, activation-result, opportunity-result,
      `MVPHostInstance`, validator, residual-policy-table, and residual-policy
      declarations in `Sources/GiftUIHostConfiguration/`. Add API snapshot,
      raw-value, associated-payload, `Equatable`/`Sendable`, noncopyable
      conformance, illegal construction, and package-access tests.
- [ ] `T1.2` — Implement `HostComponentRole`, `HostComponentRoleSet`,
      `HostComponentRecord`, and the bounded graph-view seam. Prove exact bits
      `0...17`, rejection of bits `18...31`, exact raw-value ordering, no
      self/upward/unknown edges, eighteen production records, one owner per
      role, and acyclicity without allocation, reflection, untyped
      collections, service location, or ambient lookup. Prove the selected
      signal-source constructor receives its clock, scheduling, transport, or
      interrupt dependencies through source-owned concrete contracts visible
      in generated/compiler-visible construction evidence, without creating
      another component role or invoking those dependencies during validation.
- [ ] `T1.3` — Implement `HostPacingPolicy`, cardinality, Drawing workload,
      complete workload, structural, action/model, input/wake, and endpoint
      configuration values with checked initializers where specified. Test all
      zero, boundary, sum-overflow, capacity, refusal-limit, profile/kind, and
      exact Signal Analyzer constants including `20 + 2 + 6 == 28`, capacity
      `32`, four-slot margin, six action codes, and one model/input owner.
- [ ] `T1.4` — Implement a bounded one-shot validation-state guard shared by
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

- [ ] `T2.1` — Add one checked-in descriptor for the fixed Signal Analyzer
      hierarchy and application workload plus a deterministic host-only
      generator. Count every SPEC-006 semantic-node occurrence, every SPEC-008
      render semantic scope, layout scope, maximum render traversal depth,
      render text line including empty lines, glyph, ordinary operation, input,
      action, completion fact, Canvas, live Path element, snapshot element, and
      static callable/capture requirement under its owner Specification.
      Generated Swift and schema-2 manifest files must carry source identity
      and be reproducible without evaluating a client body or Canvas closure
      during validation.
- [ ] `T2.2` — Generate every complete nested `RuntimeProfileLimits` leaf and
      one exact expected SPEC-013 `RuntimeStorageAudit` for each preset. Add a
      generated per-leaf corpus proving equality succeeds and each
      independently lowered, unequal, wrong-profile, wrong-storage,
      wrong-static-table, or wrong-byte-total value fails; where a lower value
      is unconstructible, prove the owner initializer rejects it. Verify all
      four `renderWorkspace` fields equal their schema-2 source counts and the
      audited workspace capacity.
- [ ] `T2.3` — Generate and verify the exact Drawing minima: five Canvases,
      202 live points, 12 live subpaths, five strokes/normalized operations,
      832 snapshotted points, and 16 snapshotted subpaths. Compute
      `ordinaryRenderOperations + 5` with checked arithmetic and prove the
      result fits producer, runtime, Drawing, render, sink, and endpoint lower
      bounds. Dynamic static-Canvas fields are `nil`; static fields exactly
      equal generated table metadata and capture bytes.
- [ ] `T2.4` — Generate immutable projections for `macOSDynamic`,
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

- [ ] `T3.1` — Implement stages 1-3 after graph validation: exact host/profile
      match and successful SPEC-013 audit/limit equality; one already-computed
      SPEC-005 result, selected realization, identity, compatibility, and
      lifetime join; then complete workload/cardinality/capacity validation.
      Cover every SPEC-013 local error and all nine SPEC-005 validation errors
      without constructing resources or reading their borrowed views outside
      the approved lifetime.
- [ ] `T3.2` — Complete workload validation for producer, runtime, render,
      sink, observable, interaction, input, action, fact, Drawing, and static
      Canvas limits. Prove equality at every minimum, checked overflow paths,
      independent lowered leaves, exact ordinary-operation agreement, and the
      structural Drawing gate without naming Drawing capacities in SPEC-004.
- [ ] `T3.3` — Implement the capability stage using exactly four
      role-addressed contributions, a two-candidate caller-owned workspace,
      all contribution-order permutations, and one required
      `RasterPresentationRequirement` carrying all five operation bits, the
      preset's exact logical extent, synchronous borrowed one-shot mode,
      admitted encodings and lifetimes, finite byte ceilings, and `.required`
      absence. Instrument exactly one resolver invocation and no steady-state
      resolver access. Keep capability failure independent from Drawing
      structural capacity and preserve SPEC-004's producer-specific failure
      mapping.
- [ ] `T3.4` — Implement the endpoint stage against the inert SPEC-014 factory
      projection. Require exact effective-value equality, descriptor, writable
      capacity, payload, realization, lifetime/handoff, one in-flight slot,
      byte ceilings, and the single shared health owner. Cover both inert
      mismatch and post-construction mismatch using SPEC-014's exact
      safety-not-proven mapping, with no live endpoint call during validation.
- [ ] `T3.5` — Implement action/model and input/wake stages: six total action
      codes `0...5`, one immutable handler, one root location/registration/
      staging record, publishable target generation, exact fact capacities,
      one normalized source, one target-local gate, one non-reentrant wake
      requester, and distinct logical application/mutation domains. Validate
      the source spacing, maximum callbacks per action, repository/use-case
      callback bounds, executor limits, admission adapter, total handler, and
      all application-factory projections supplied to the validator. Reject
      invalid code, stale generation, incompatible callback bounds, retained
      owner references, and reentrant or malformed integration.
- [ ] `T3.6` — Implement policy-stage table completeness, allowed/selected
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

- [ ] `T4.1` — Implement the two-phase preset construction seam. Construct
      inert projections and one validator, call `validate()` exactly once, and
      expose a `.valid` instance only for `.valid(report)`. After success,
      construct live owners without changing any projection and verify the
      endpoint and every retained immutable value equal the report. Prove the
      active instance has exactly one runtime, endpoint, resource package,
      capability snapshot, root target, handler, application executor, wake
      integration, and policy table. On failure, discard all projections and
      expose no instance or borrow.
- [ ] `T4.2` — Implement the narrow host/failure adapter and exact total
      residual policy table. Preserve focused payloads and mappings, host
      error conditions, mandatory-effect ordering, all nine host contexts,
      every explicit no-policy row, ordinals/limits, allowed sets, and fixed
      selections. Ordinary startup failure invokes the complete table once
      only after validator return; defective tables quiesce mechanically and
      never decide through themselves. Diagnostics remain optional downstream
      projections and cannot change a transcript.
- [ ] `T4.3` — Implement `MVPHostInstance.activate()` and its finite inline
      preset-specific activation-failure sum. Follow the seven specified
      construction/attachment/observation/input/source/runtime steps in order,
      fault each step, perform mandatory containment, preserve the first exact
      payload, and enter `.active` or terminal `.failed`. Repeated or
      wrong-state activation calls make no owner call and map to the exact
      reentrancy/safety-not-proven route.
- [ ] `T4.4` — Implement explicit synchronous idempotent teardown in the exact
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

- [ ] `T5.1` — Join the source, repository, use cases, application executor,
      two repository sinks, the SPEC-010/ADR-027 admission adapter, root
      observable model,
      and mutation domain without direct callback-to-model mutation. Prove the
      two bootstrap current-value facts, ordered application opportunities,
      bounded later fact admission, same-thread/distinct-executor equivalence,
      and that synchronous repository callbacks stop at admission for a later
      runtime opportunity.
- [ ] `T5.2` — Implement non-reentrant wake accumulation and host scheduling.
      An empty-to-nonempty transition requests one wake and returns; serialized
      `runOpportunity()` begins at or after the 250,000-microsecond frame
      boundary and no later than the active 250,000-microsecond service-window
      deadline. Cover just-before/at/just-after boundaries, facts around the
      seal, wake coalescing, illegal lifecycle entry, and exposed report
      identity without synchronous runtime entry. Under a sustained
      80-transition-fact-per-second workload, prove admission without
      rejection, ordered facts, coalesced change reports, and derivation paced
      at four frames per second.
- [ ] `T5.3` — Integrate presentation supersession, backpressure, retryable
      refusal, non-retryable refusal, and terminal unavailability. Prove
      backpressure leaves the count unchanged, refusals retain ordinals zero
      through two, the third terminates without a fourth offer, newer
      revisions replace old pending intent in constant space, and no fact,
      action, Canvas closure, plan, operation stream, or payload is replayed.
- [ ] `T5.4` — Join normalized input and action dispatch. The target-local gate
      attaches current physical-presentation provenance and drops malformed,
      stale, unknown, unavailable, out-of-order, or excess sequences before
      runtime admission. Dispatch revalidates action/target generations and
      enabled state, borrows the exact current model, invokes one immutable
      handler in mutation phase, and retains neither handler nor model in
      action records or pointer capture. For the manifest's exact nonzero input
      and semantic-action limits, prove submission at each configured bound
      succeeds and the first excess follows SPEC-009's exact capacity refusal
      and source-sequence cancellation behavior without resizing any limit.
- [ ] `T5.5` — Integrate mutable endpoint/display health without changing the
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

- [ ] `T6.1` — Implement macOS dynamic and static composition roots using the
      same immutable logical extent, exact text package, workload, actions,
      facts, endpoint semantics, and normalized scripts. Prove only storage
      and dispatch mechanism differ, then force complete reconstruction after
      an extent change.
- [ ] `T6.2` — Implement the Raspberry Pi dynamic hardware-free composition
      root and ARMv6 compile/link fixture for
      `armv6-unknown-linux-gnueabihf`. Verify the exact 240 x 240, 240 x 16
      RGB565 projection, dynamic audit, symbols/imports, and component costs.
      Label the result cross-build evidence only; connected deployment later
      requires an explicit request and remote `armv6l` verification.
- [ ] `T6.3` — Implement the nRF52840 static hardware-free composition root and
      Embedded Swift compile/link fixture for `nrf52840dk/nrf52840` with the
      bundled `armv7em-none-none-eabi` module and Cortex-M4F hard-float flags.
      Verify the exact 480 x 320 tiled projection, 3,840-byte bounds, one slot,
      no framebuffer, and ELF VFP calling convention. Label the result
      cross-build evidence only; no board flashing is part of this task.
- [ ] `T6.4` — Compare graph, limit, audit, resource, capability, action, fact,
      input, semantic, layout, render-operation, failure, publication, and
      lifecycle transcripts across all four presets. Report zero resolver
      calls after startup and, for static presets, zero heap allocation during
      construction, steady-state opportunities, action dispatch, fact
      admission, and teardown, plus zero reflection, tasks, threads,
      exceptions, Objective-C runtime, dynamic collections, or prohibited
      linked dependencies. Record endpoint/payload, application storage,
      host-policy, staging, stack high-water, RAM, and flash costs separately
      under pinned tools, and verify the nRF52840 aggregate and incremental
      totals remain within the approved SPEC-004 and SPEC-014 budgets.

### Milestone 7: Complete the Contract Runner and Conformance Handoff

**Entry conditions:** Every focused and integrated fixture is implemented and
all four preset builds are reproducible from repository-local inputs.

**Exit evidence:** One root command reproduces all hardware-free evidence,
every acceptance criterion has a checkable disposition, and remaining
connected-hardware evidence is explicit rather than implied.

- [ ] `T7.1` — Complete the exhaustive negative corpus: graph shape/order,
      every validation stage and no-later-read proof, every runtime-limit leaf,
      Drawing/capability independence, contribution permutations, all text
      errors, endpoint mismatches, action/input/generation faults, 28/32/33
      fact boundaries, producer-category excess, configured input/action
      limit success and first-excess cancellation, every policy/no-policy row,
      every activation/teardown state, diagnostics, arithmetic, and fault
      injection. Add forbidden-import and portable-source scans.
- [ ] `T7.2` — Finish `scripts/contracts/run-spec-015.sh` so each exact profile
      runs unit, conformance, integration, compile/link, static-runtime,
      allocation, latency, and resource-accounting checks; exits nonzero on a
      missing/malformed/failing row; and writes nothing outside
      `.build/spec-015/`. Register it in the repository test gate only after
      its prerequisites are available and its output is deterministic.
- [ ] `T7.3` — Run the maintained documentation checks, Swift formatter before
      the repository test gate, focused unit suites, each SPEC-015 profile,
      `scripts/test.sh`, clean source/import/dependency scans, and deterministic
      evidence verification. Record compiler, optimization, target triple,
      fixture, repetition method, revision, dirty state, and input/output
      hashes in each immutable report.
- [ ] `T7.4` — Create `docs/conformance/spec-015-conformance.md`, map every
      `HC-001` through `HC-018` row to evidence and pass/fail/blocked status,
      link the report from this plan and SPEC-015, and classify PiScreen and
      nRF52840 TFT display/input runs as separate connected-target gates naming
      hardware, software, transport, and observed architecture. Request the
      human `implemented` transition only after all required criteria and
      connected-target obligations have conforming evidence.

## Design-Note Triggers

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
3. Generate and review the complete workload and four preset projections.
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

- SPEC-011, SPEC-012, and SPEC-014 have ready plans but no production targets;
  SPEC-013 and this Specification are in coordinated review.
  `T3.4`, `T4.*`, `T5.*`, and `T6.*` must wait for the exact owner seams they
  govern.
- SPEC-003, SPEC-004, and SPEC-008 through SPEC-010 have active plans;
  SPEC-005 and SPEC-006 have completed plans but await conformance and their
  human `implemented` transitions; SPEC-007 remains approved with a ready
  plan. SPEC-015 may test adapters against completed seams but cannot claim
  production assembly until each governing owner exposes its approved
  production contract and closes the dependencies named here.
- Approved SPEC-001 has no implementation plan. The workload descriptor and
  concrete host roots require its exact portable hierarchy, six-action domain,
  fact producers, deterministic mock trace, and application failure inputs;
  the legacy SwiftUI demo cannot substitute for them.
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
implementation evidence is invalidated or claimed. After reapproval, update
each task disposition and evidence link in place as work proceeds. Plan
completion does not mark SPEC-015 implemented; that transition requires a
complete conformance review and explicit human authorization.
