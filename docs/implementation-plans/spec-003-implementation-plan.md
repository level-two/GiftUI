---
spec: SPEC-003
feature: giftui-mvp-architecture
title: SPEC-003 Implementation Plan
status: active
owners:
  - codex
created: 2026-08-29
updated: 2026-08-29
related_design_notes: []
conformance_report: null
related_future_work:
  - FW-009
  - FW-012
  - FW-013
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-003 Implementation Plan

> This active plan derives work from the approved Failure Outcomes and Containment
> Specification. It orders implementation and evidence but does not amend the
> contract or authorize work owned by another Specification.

## Authority and Scope

The governing contract is approved
[SPEC-003](../specs/spec-003-failure-outcomes-and-containment.md). Its authority
chain is accepted
[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md),
approved [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md) and
[RFC-005](../rfcs/rfc-005-failure-diagnostics-propagation.md), and accepted
[ADR-014](../adrs/adr-014-bounded-cross-layer-outcomes.md),
[ADR-015](../adrs/adr-015-layered-failure-disposition.md), and
[ADR-016](../adrs/adr-016-non-authoritative-diagnostics.md).

The [MVP Scope](../MVP_SCOPE.md) requires one substantially shared Signal
Analyzer presentation across macOS dynamic, macOS static, Raspberry Pi 1/Linux
dynamic, and nRF52840 static configurations. Those stacks require equivalent,
bounded failure meaning without exceptions, heap-backed error objects,
platform-native error types, or correctness dependence on diagnostics.
SPEC-003 is therefore MVP infrastructure rather than post-MVP observability
work.

This is the next governing implementation plan after the current SPEC-002
Foundation iteration. It is not another SPEC-002 milestone: SPEC-002 owns
portable values and checked operations, while SPEC-003 exclusively owns the
failure, containment, residual-disposition, operational-health, and diagnostic
vocabulary. It is also not a new Specification: the complete approved contract
and its independent hardware-free acceptance seam already exist.

The first implementation slice creates `GiftUIFailureCore`, its pure fixtures,
and the registered contract driver. This slice can proceed while SPEC-002
remains `implementing` and will unblock the failure-owned portion of SPEC-002
Milestone 4. Later correlation and owner-adapter tasks retain explicit
dependencies on SPEC-009, SPEC-004, and SPEC-015 rather than creating substitute
execution, capability, or host contracts here.

## Current Repository State

- The clean MVP package currently exposes only the `GiftUI` product/target and
  `GiftUITests`. It contains the implemented SPEC-002 geometry, checked
  arithmetic, and package-scoped normalized pointer values.
- No `GiftUIFailureCore`, `GiftUIFailureExecution`, optional diagnostic-adapter
  target, failure unit-test target, SPEC-003 fixture tree, or SPEC-003 contract
  driver exists.
- SPEC-002 established a fail-closed target dependency allow-list, positive and
  negative compile-fixture conventions, deterministic report roots, and the
  checked-in `scripts/contracts/driver-registry.tsv`. Any SPEC-003 target must
  update those graph expectations in the same coordinated change.
- `scripts/test.sh` is the single top-level fast and cross-profile gate.
  `scripts/contracts/run-spec-003.sh` must be registered explicitly without
  weakening its standalone four-command surface or changing hardware-free
  aggregation into deployment or flashing.
- The project-local Raspberry Pi workflow pins Swift 6.3.2 and
  `armv6-unknown-linux-gnueabihf`; the project-local nRF workflow pins Swift
  6.3.2, Zephyr 4.3.0, SDK 0.17.4, board `nrf52840dk/nrf52840`, and Swift module
  target `armv7em-none-none-eabi`. Their doctor/probe workflows exist, but no
  SPEC-003 cross-build, resource image, or VFP evidence exists.
- The local macOS contract convention already checks the required Apple Swift
  6.3.3 compiler identity and supports distinct dynamic/static fixture flags.
  SPEC-003 still needs its exact optimized baseline/candidate images, latency
  corpus, allocation instrumentation, operation-count accounting, section
  reports, disassembly, and resolved call graph.
- SPEC-009 is approved but has no execution-contract target; therefore
  `GiftUIFailureExecution` cannot yet be created conformingly. SPEC-004 and
  SPEC-015 are also approved but unimplemented, so their production owner
  adapters remain integration dependencies rather than work to absorb into
  `GiftUIFailureCore`.
- No SPEC-003 implementation design note or conformance report exists.

## Acceptance-Criterion Matrix

The labels below are plan-local navigation labels. The criterion text remains
the authority in SPEC-003.

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `FAIL-AC-01` — Core imports no higher module | `T0.2`, `T0.4`, `T1.4` | Positive Core import fixture plus compiled dependency inspection | pending |
| `FAIL-AC-02` — Execution correlation and driver import graph | `T0.4`, `T4.3`, `T4.5` | Exact target graph, positive/negative compile fixtures, compiled import inspection | pending |
| `FAIL-AC-03` — Exhaustive conservative containment mapping | `T1.3`, `T5.2` | Shared dynamic/static unknown-and-richer-value corpus | pending |
| `FAIL-AC-04` — Raw values and 2/4/8/20/24-byte layout bounds | `T1.1`, `T1.2`, `T3.1`, `T5.3` | Host unit fixtures and four-profile layout reports | pending |
| `FAIL-AC-05` — Identity/origin preservation and no unsafe narrowing or upgrade | `T1.3`, `T4.3` | Propagation and correlation fixtures | pending |
| `FAIL-AC-06` — Two ordered annotations and refused third append | `T1.2`, `T4.3` | Annotation boundary corpus and unchanged-fact assertions | pending |
| `FAIL-AC-07` — Total residual-policy domain and forbidden-input rejection | `T2.1`, `T2.2`, `T5.2` | Exhaustive finite-domain policy fixture with invocation counters | pending |
| `FAIL-AC-08` — Invalid host policy use quiesces exactly and prevents later cycles | `T2.3`, `T4.4` | Pure owner-adapter fixture followed by SPEC-015 integration evidence | pending |
| `FAIL-AC-09` — Diagnostic configurations preserve correctness outputs | `T3.2`, `T3.3`, `T5.2` | Value-equality diagnostic matrix | pending |
| `FAIL-AC-10` — Dropped health records do not affect state/counters; saturation is safe | `T2.4`, `T3.3` | Health/saturation fixture with all records dropped | pending |
| `FAIL-AC-11` — Quiesced health is terminal | `T2.4` | Exhaustive resulting-state and counter fixture | pending |
| `FAIL-AC-12` — Diagnostic callbacks/interrupts cannot mutate semantics or invoke actions | `T3.4` | Reentrancy/isolation fixture with zero-mutation counters | pending |
| `FAIL-AC-13` — Every bounded capacity exhausts deterministically | `T1.2`, `T2.1`, `T3.2`, `T3.3` | Annotation, policy, counter, context, and diagnostic-store exhaustion corpus | pending |
| `FAIL-AC-14` — Static correctness path allocates zero heap storage | `T1.4`, `T2.5`, `T5.3` | Instrumented static candidate and allocation report | pending |
| `FAIL-AC-15` — Static/dynamic portable facts and dispositions are identical | `T5.1`, `T5.2` | Matched semantic transcripts | pending |
| `FAIL-AC-16` — Four exact optimized commands and two pristine builds | `T0.3`, `T5.1`, `T5.4` | Driver metadata, commands, hashes, and repeatability reports | pending |
| `FAIL-AC-17` — Hardware-free step, selection, buffer, RAM, stack, and code bounds | `T0.3`, `T3.3`, `T5.3`, `T5.4` | Count reports, section accounting, disassembly, call graph, and limit checks | pending |
| `FAIL-AC-18` — Exact reciprocal SPEC-002 and SPEC-004 mappings | `T4.1`, `T4.2`, `T6.1` | Cross-owner fixtures and reciprocal-link/import audit | pending |
| `FAIL-AC-19` — Connected Raspberry Pi `armv6l` resource and latency row | `T6.2` | Recorded connected-target command, identity, raw samples, and resource report | pending |

## Milestones and Tasks

### Milestone 0: Establish the Failure Contract Harness and Core Leaf

**Entry conditions:** SPEC-003 remains `approved`; RFC-002/RFC-005 remain
`approved`; ADR-014 through ADR-016 remain `accepted`; and the SPEC-002 clean
package plus fail-closed contract registry remain available.

**Exit evidence:** The package contains an empty but importable failure-core
leaf, the target graph has been updated deliberately, the standalone
four-profile SPEC-003 driver is registered, and its fixture/report conventions
are reproducible before semantic implementation starts.

- [x] `T0.1` — Create `Tests/ContractFixtures/SPEC003/` with an ordered fixture
      manifest, positive/negative single-entry-point compile conventions,
      shared semantic-corpus format, baseline/candidate resource-harness
      layout, deterministic generated/report paths, and a README that
      distinguishes hardware-free, cross-built, and connected-target claims.
- [x] `T0.2` — Add the `GiftUIFailureCore` library product/target and focused
      unit-test target without importing `GiftUI` or any execution, runtime,
      backend, platform, capability, host, driver, HAL, or diagnostic
      implementation. Update the SPEC-002 exact target allow-list and graph
      fixtures atomically so the new leaf is reviewed rather than bypassing the
      fail-closed package gate.
- [x] `T0.3` — Create the exact
      `scripts/contracts/run-spec-003.sh --profile <profile>` surface for
      `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
      `nrf52840-embedded`. Fail closed on every compiler, target, SDK, board,
      optimization, pin, or source-list mismatch; record revision and dirty
      state, compiler path/hash/version, complete commands, inputs/hashes,
      image hashes, and deterministic exits. Register it in the checked-in
      driver registry so the top-level runner preserves the standalone
      invocation and performs no remote access, deployment, or flashing.
- [x] `T0.4` — Add positive Core-only imports, forbidden higher imports,
      prohibited re-export checks, exact target/direct-edge comparison, cycle
      detection, and compiled-module/product-link inspection. Reserve the
      approved future `GiftUIFailureExecution` edge without adding that target
      until SPEC-009 supplies its focused execution contract.
- [x] `T0.5` — Record a clean-checkout harness-readiness transcript proving the
      package graph, Core import, negative fixtures, root tests, standalone
      macOS-dynamic driver, and no-argument top-level gate all execute before
      Milestone 1.

### Milestone 1: Implement Core Facts, Outcomes, and Correlation-Neutral Context

**Entry conditions:** Milestone 0 passes and `GiftUIFailureCore` remains a
dependency leaf.

**Exit evidence:** Every SPEC-003 foundational value exists with its exact
visibility, raw values, finite representation, conditional conformance, and
conservative propagation semantics; no execution identity or product policy
has entered the core fact.

- [x] `T1.1` — Implement the exact public, value-semantic, `Sendable`, and
      `Equatable` core declarations: `GiftUIConditionID`, shared condition
      constants, `GiftUIFailureOrigin`, `GiftUIAffectedScope`,
      `GiftUIContainment`, and `GiftUIFailureFact`. Test every raw value,
      unrestricted wrapper bit pattern, `(origin, condition)` identity, and
      the exact/maximal layouts.
- [x] `T1.2` — Implement `GiftUIOperationalKind`,
      `GiftUIOperationalFact`, conditionally `Sendable`/`Equatable`
      `GiftUIOutcome<Success>`, `GiftUIFailureAnnotation`, and the inline
      two-entry `GiftUIFailureAnnotations`. Prove that the generic carrier adds
      no allocation and that annotation refusal preserves order, storage, and
      every core-fact field.
- [x] `T1.3` — Implement pure conservative normalization and propagation test
      seams. Exhaustively map contained, safety-not-proven, unknown, and richer
      fixture values; prove origin/condition preservation, no scope narrowing
      without fixture-backed proof, and no containment upgrade.
- [x] `T1.4` — Add source/interface/binary audits excluding strings,
      collections, closures, existentials, platform-native errors, reflection,
      exceptions, dynamic registries, and upward imports from the common
      values. Retain a generic success payload as caller-owned and outside the
      common allocation budget.

### Milestone 2: Implement Residual Policy Validation and Operational Health

**Entry conditions:** Milestone 1 fixes the complete non-success vocabulary.

**Exit evidence:** Every residual-policy input is validated before policy
invocation, every policy result is bounded, and operational health remains a
finite correctness-bearing snapshot independent of diagnostics.

- [x] `T2.1` — Implement the exact disposition enum, option bits,
      `GiftUIResidualPolicyInput<Context>` initializer, and residual policy
      protocol. Reject success, empty/unknown bits, zero limits, invalid or
      exhausted ordinals, forbidden retry kinds, and forbidden
      safety-not-proven choices with no partial input and no policy call.
- [x] `T2.2` — Build a fixture-finite context and table-driven exhaustive
      policy corpus. Enumerate every declared input exactly once, require one
      listed result, and prove no mechanical containment or mandatory
      coordinator action is exposed as residual choice.
- [x] `T2.3` — Add a pure owner-adapter fixture for unexpected input `nil` and
      unlisted policy return. It must construct exactly the host-composition
      runtime-scoped safety-not-proven invariant fact, stop policy invocation,
      quiesce health before any optional fatal-hook observation, and reject all
      later normal-cycle attempts. This fixture proves the approved seam; the
      production host realization remains SPEC-015 work.
- [ ] `T2.4` — Implement `GiftUIOperationalHealth` with saturating counters,
      transition-before-return behavior, unchanged-state counting, terminal
      quiescence, and state updates that remain permitted after saturation.
      Exhaust every requested resulting state through both record methods.
- [ ] `T2.5` — Instrument construction, normalization, propagation, health
      update/query, and generic residual-policy dispatch with diagnostics
      disabled. Record zero heap allocation and the fixture-counted correctness
      path without hiding compiler/runtime calls.

### Milestone 3: Implement Optional Non-Authoritative Diagnostics

**Entry conditions:** Outcomes, health, and policy results have
correctness-bearing tests that run with no diagnostic implementation linked.

**Exit evidence:** Diagnostic selection, projection, delivery, omission, and
bounded storage are downstream observations; every configuration yields
identical correctness outputs.

- [ ] `T3.1` — Implement the exact diagnostic kind, severity, selection,
      record, sink-result, and sink declarations with specified masks, flags,
      zero defaults, projection fields, and 24-byte record maximum. Prove
      constant-time selection before full record construction.
- [ ] `T3.2` — Add the optional first-party fixed diagnostic buffer in a
      downstream adapter target that imports `GiftUIFailureCore` and is never
      imported by a correctness-bearing target. Implement capacity zero and
      profile defaults 64/16/16/8, admitted-order preservation, drop-new
      saturation, and saturating dropped-record count.
- [ ] `T3.3` — Build the complete omitted, enabled, source-filtered,
      sink-filtered, saturated, dropping, counting, and failing matrix. Compare
      normalized outcomes, health snapshots, coordinator inputs, residual
      inputs, and policy results for value equality; prove excluded records are
      never constructed and sink results affect only optional counters.
- [ ] `T3.4` — Add callback and interrupt fixtures whose diagnostic sinks
      attempt semantic mutation and client-action invocation through only the
      allowed test seams. Prove zero mutation/invocation and no re-entry into an
      earlier outcome stage.

### Milestone 4: Integrate the Approved Cross-Owner Boundaries

**Entry conditions:** Milestones 1-3 pass independently. Each production
adapter below starts only after its owning approved Specification has created
the corresponding target and stable declarations.

**Exit evidence:** Foundation, capability, execution, and host owners use the
SPEC-003 vocabulary through one-way adapters; no vocabulary or state machine is
duplicated to remove a dependency blocker.

- [ ] `T4.1` — Coordinate with the active SPEC-002 plan at the first boundary
      that knows both Foundation rejection and failure facts. Verify the exact
      four Foundation mappings, discarded partial output, and the absence of a
      `GiftUI` import from `GiftUIFailureCore`; do not move Foundation
      arithmetic into the failure target.
- [ ] `T4.2` — After SPEC-004 produces `GiftUICapabilities`, add or verify the
      downstream host adapter for every frozen `RasterPresentationUnavailable`
      condition raw value and the
      `GiftUIOutcome<CapabilitySnapshot>.failure` envelope. The capability leaf
      must not import failure, and raw value 11 remains unassigned.
- [ ] `T4.3` — After SPEC-009 produces the focused execution-contract target,
      add `GiftUIFailureExecution` importing only that target and
      `GiftUIFailureCore`. Implement the generic
      `GiftUICorrelatedFailure<Context>`, preserve every fact field, and prove
      that low-level/driver fixtures cannot import correlation and the
      execution contract does not import it.
- [ ] `T4.4` — After SPEC-015 supplies the production host policy and runtime
      gate, integrate the invariant mapping and terminal quiescence sequence
      proven by `T2.3`. A configured fatal hook may observe only after
      quiescence and cannot replace it.
- [ ] `T4.5` — Refresh the exact package allow-list, positive/negative imports,
      compiled module dependencies, and product linkage after every owner
      target lands. Fail any upward edge, re-export, monolithic target, or
      optional diagnostic dependency on a correctness path.

### Milestone 5: Produce Hardware-Free Four-Profile and Resource Evidence

**Entry conditions:** Milestones 1-3 are complete; every available Milestone 4
target has an exact graph disposition; the macOS compiler matches SPEC-003;
and the project-local Pi/nRF doctor and hardware-free probes pass.

**Exit evidence:** All four exact commands produce repeatable semantic,
allocation, operation-count, layout, section, code, and stack reports clearly
labeled as host or hardware-free cross-build evidence.

- [ ] `T5.1` — Compile the same deterministic failure corpus with the exact
      profile compilers and optimization modes: Apple Swift 6.3.3 `-O` WMO for
      both macOS fixtures, Swift 6.3.2 ARMv6 `-O` WMO, and Swift 6.3.2 nRF
      Embedded Swift `-Osize` WMO with Cortex-M4F hard-float flags. Verify the
      nRF candidate ELF VFP calling convention. Do not substitute ARMv7/AArch64,
      install globally, access a remote, deploy, or flash.
- [ ] `T5.2` — Compare complete static/dynamic transcripts for facts,
      containment, annotations, policy validation/results, health, diagnostic
      isolation, exhaustion, and owner-fixture mappings. Fail any portable
      semantic difference.
- [ ] `T5.3` — Report size/stride/alignment for every declaration, allocation
      counts, fixture-counted correctness and selection steps, default buffer
      capacity, and named production health/counter/buffer symbols. Enforce all
      exact layout and RAM limits.
- [ ] `T5.4` — Build two pristine matched baseline/candidate image pairs per
      profile from one revision and equal runtime/test support. Record complete
      source hashes, compiler/linker commands, final hashes, normalized
      section totals, signed writable/code deltas, link maps, disassembly, and
      a symbol-resolved conservative call graph. Fail recursion, unresolved
      indirect calls, missing runtime bodies, dynamic unbounded stack, unequal
      shared-library sets, or non-repeatable evidence.
- [ ] `T5.5` — On the exact macOS reference runner, execute at least 1,000
      warm-up and 10,000 measured iterations with no other repository job;
      preserve raw samples and enforce the p99 latency row. Treat results from
      another Mac as informative only.

### Milestone 6: Complete Target Evidence and Prepare Conformance Review

**Entry conditions:** Hardware-free evidence passes and the Raspberry Pi
integration needed to run the release corpus exists under its owning approved
plans.

**Exit evidence:** Every acceptance criterion has reproducible evidence or an
explicit upstream blocker, the connected Pi row is recorded separately, and a
SPEC-003 conformance report is ready for independent review.

- [ ] `T6.1` — Audit reciprocal links and exact shared declarations among
      SPEC-002/003/004 plus execution/host integrations; audit package edges,
      adapter ownership, diagnostic direction, and all deferred-work
      boundaries. Update navigation only, never contract meaning.
- [ ] `T6.2` — On an explicitly selected connected Raspberry Pi reference
      target, require `armv6l` before executing the release corpus. Record the
      pinned compiler, OS, command, revision, raw latency samples, RAM, stack,
      and linked-code evidence and enforce p99 <= 150 us. This task performs no
      deployment or service restart unless separately requested and
      authorized.
- [ ] `T6.3` — Create `docs/conformance/spec-003-conformance.md`, link stable
      evidence, distinguish host/cross-build/connected-target claims, and hand
      every `FAIL-AC` row to conformance review. Do not mark SPEC-003
      `implemented` without complete evidence and explicit maintainer
      authorization.

## Design-Note Triggers

- Create `docs/implementation-designs/spec-003-resource-evidence-driver.md` if
  the matched-image section accounting, shared-runtime proof, final-image call
  graph, indirect-target resolution, or stack-bound algorithm cannot be
  reconstructed directly from the driver and fixture README.
- Create `docs/implementation-designs/spec-003-bounded-diagnostic-buffer.md` if
  inline storage, capacity-zero compilation, profile specialization, or
  drop-new accounting requires non-local ownership/lifetime machinery.
- Create a focused correlation note only if the SPEC-009 context integration
  requires a non-obvious generic/lifetime realization. The note cannot move
  execution identity into the core fact.
- Do not create notes for the finite enums, wrappers, facts, policy validation,
  or health counters unless implementation exposes a genuinely non-local
  mechanism; the approved Specification and local tests should suffice.

## Integration and Validation Order

1. Run `scripts/test.sh` with no arguments after every package, fixture, or
   registry change.
2. Establish the Core leaf and its import graph before adding declarations.
3. Implement and exhaustively test facts/outcomes/annotations, then policy and
   health, with diagnostics absent.
4. Add the optional diagnostic consumer and compare every correctness output
   against the no-diagnostics baseline.
5. Coordinate the SPEC-002 Foundation adapter first because it unblocks the
   active Foundation plan; integrate capability, execution correlation, and
   production host policy only when their owner targets exist.
6. Run macOS dynamic and static semantic/resource fixtures, then Raspberry Pi
   ARMv6 and nRF hardware-free cross-build/inspection. Keep the exact
   standalone driver commands visible through the top-level aggregate.
7. Run `scripts/test.sh --profile all-hardware-free`, reproduce pristine image
   pairs, and complete the macOS reference latency run before conformance
   collection.
8. Run the connected Raspberry Pi corpus only after its integration exists,
   the user has requested the connected-target change, and the machine reports
   `armv6l`. No SPEC-003 task requires nRF flashing.

## Risks and Upstream Blockers

### Upstream blockers

- `GiftUIFailureExecution` is blocked until SPEC-009 creates the focused
  execution-contract target. Creating an execution identity or placeholder
  target under SPEC-003 would violate ownership.
- The reciprocal capability catalogue evidence is blocked until the SPEC-004
  plan creates `GiftUICapabilities` and its downstream host adapter seam.
- Production invariant-policy integration and prevention of later normal
  cycles are blocked until SPEC-015 creates the host configuration/runtime
  gate. The pure SPEC-003 fixture remains independently implementable.
- The connected Raspberry Pi criterion is blocked until the owning backend and
  host integration plans provide a runnable release corpus. A cross-build or
  simulator cannot satisfy it.
- If the frozen layout, RAM, stack, code, step, or latency limits cannot be met,
  reduce the representation within the approved contract or return the
  affected requirement to Specification review; the plan cannot grant an
  exception.

### Implementation risks

- Adding failure targets can invalidate SPEC-002's exact target graph. Update
  the manifest, allow-list, driver fixtures, and compiled dependency evidence
  atomically rather than weakening fail-closed checking.
- Conditional generic conformances and enum payload layout may differ across
  the three target architectures. Enforce the frozen maxima on each actual
  compiler target before downstream modules depend on an accidental host
  layout.
- Exhaustive policy tests can accidentally omit invalid bit patterns or retry
  boundaries. Generate the finite corpus from the declared widths/rules and
  assert one visit per input row.
- Diagnostics can gain authority through shared mutable storage or callback
  convenience. Keep correctness fixtures runnable with the diagnostic adapter
  unlinked and compare authoritative outputs by value.
- Baseline/candidate images, dead stripping, shared runtime differences, or
  unresolved calls can make resource deltas look smaller than the production
  path. Equalize inputs, observably consume outputs, preserve link/disassembly
  evidence, and fail unresolved bounds.
- Toolchain drift must fail closed and be repaired only through project-local
  setup/doctor/probe workflows. Do not alter Xcode/global Swift, install the Pi
  SDK under `/opt`, substitute target architectures, deploy, or flash.

## Deferred and Follow-up Work

- [FW-009](../future-work/fw-009-shared-delegated-service-foundation.md)
  remains deferred unless two approved consumers demonstrate materially shared
  environmental semantics, a dependency cycle, cross-profile wiring failure,
  or measured cost that justifies a common foundation.
- [FW-012](../future-work/fw-012-durable-failure-identity-compatibility.md)
  remains outside MVP. Do not persist or transmit build-local condition IDs;
  revisit only for an accepted cross-build consumer, protocol, or tooling need.
- [FW-013](../future-work/fw-013-fine-grained-failure-containment-recovery.md)
  remains outside MVP. Do not add finer scopes or recovery classes unless an
  accepted availability requirement and bounded cross-profile evidence trigger
  renewed lifecycle work.
- None of these items relaxes a correctness, resource, or conformance task in
  this plan.

## Completion Record

Draft created on 2026-08-29 and accepted by the maintainer as `ready` on
2026-08-29. Implementation began on 2026-08-29, transitioning SPEC-003 to
`implementing` and this plan to `active`. `T0.1` is complete: the checked-in
[SPEC-003 fixture contract](../../Tests/ContractFixtures/SPEC003/README.md)
defines the ordered compile-fixture registry, shared semantic-corpus schema,
matched resource-harness inputs, deterministic generated/report roots, and
the boundary between hardware-free, cross-built, and connected-target claims.
That fixture contract prepares the failure-core leaf needed by the
failure-owned portion of active SPEC-002 Milestone 4 without waiting for later
execution, capability, host, or connected-target integrations.

`T0.2` is complete: the package exposes an empty, importable
`GiftUIFailureCore` library leaf and a focused import test target. The
SPEC-002 exact target graph now admits those two targets with only the test-to-
leaf edge; the failure core itself has no dependency. `T0.3` is next.

`T0.3` is complete: the fail-closed standalone SPEC-003 driver exposes all
four exact profile commands and is registered with the repository aggregate.
Each run records the revision and dirty state, compiler identity and hash,
complete commands, checked-in input hashes, produced module or library image
hashes, pinned profile identity, optimization mode, and deterministic exit.
ARMv6 and nRF paths remain hardware-free and perform no remote access,
deployment, service restart, or flashing. `T0.4` is next.

`T0.4` is complete: ordered compile fixtures prove the Core-only import and
reject GiftUI, execution-correlation, and diagnostic imports. The boundary
audit rejects source or compiled-interface re-exports/upward imports and
forbidden product linkage. Exact package targets, direct edges, products, and
acyclicity are checked against the fail-closed graph; synthetic unknown-edge
and cycle regressions prove the checker fails. The future
`GiftUIFailureExecution` edge is recorded as reserved and remains absent until
SPEC-009 creates its focused execution contract. `T0.5` is next.

`T0.5` is complete at clean revision `63fc738e949293874838c3c63acd0371a7002d28`.
The checked-in [Milestone 0 readiness transcript](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-0/harness-readiness.md)
records the exact package graph, Core boundary, positive and negative imports,
17 passing root tests, standalone macOS-dynamic driver, and no-argument
top-level gate. Milestone 0 is complete; `T1.1` is the next dependency-complete
task.

`T1.1` is complete: `GiftUIFailureCore` now exports the exact condition-ID
wrapper and shared constants, origin/scope/containment tags, and immutable
failure fact. Focused tests exhaust every `UInt16` condition bit pattern,
verify every frozen raw value and unique shared identity, preserve every fact
field and `(origin, condition)` identity, enforce `Sendable`/value semantics,
and check the exact or maximal layouts. `T1.2` is next.

`T1.2` is complete: the Core leaf now owns the exact operational kind/fact,
conditionally `Sendable`/`Equatable` three-category outcome, annotation value,
and inline two-entry annotation store. Focused tests cover every tag, all
outcome categories, conditional value semantics, ordered insertion and reads,
out-of-range reads, and byte-for-byte unchanged storage after a refused third
append while enforcing the 4-byte operational-fact and 20-byte annotation-
store maxima. `T1.3` is next.

`T1.3` is complete: an internal pure fixture seam normalizes the complete
`UInt8` producer-containment domain, maps only raw `contained` to portable
`contained`, and maps safety-not-proven, unknown, and richer values
conservatively. Exhaustive tests preserve condition/origin/scope during
normalization, preserve every fact field during ordinary propagation, permit
scope replacement only through the explicitly proof-labeled seam, and never
upgrade safety-not-proven containment. `T1.4` is next.

`T1.4` is complete: every optimized macOS profile now audits Core source,
the emitted public interface, linked products, and undefined binary symbols.
The audit rejects strings, collections, closure storage, existentials,
platform-native errors, reflection, exceptions, dynamic registries, upward
imports/re-exports, and instance-allocation entry points. It separately
requires `GiftUIOutcome<Success>` to retain its caller-owned generic success
payload; generic metadata/retain support is not misreported as per-outcome
allocation. Milestone 1 is complete and `T2.1` is next.

`T2.1` is complete: Core exports the exact residual disposition, option set,
failable policy input, and generic policy protocol. Exhaustive tests reject
success, empty/unknown bits, zero limits, every ordinal at or beyond its
limit, exhausted or forbidden retry, continued safety-not-proven failures,
and non-terminal choices for runtime-scoped safety-not-proven failures. Valid
inputs preserve every field, and option bits match disposition raw values.
`T2.2` is next.

`T2.2` is complete: the checked-in shared semantic corpus defines five finite
policy contexts and covers every residual disposition exactly once. The
table-driven test proves every context appears once, every input constructs,
each selected result belongs to its allowed set, invocation count equals row
count, and the Swift fixture matches the checked-in corpus byte-for-byte. The
fixture contains only post-containment residual choices; no local rejection,
drain, frame abort, dirty-state, publication, or other mandatory coordinator
action is represented as policy. `T2.3` is next.

`T2.3` is complete: the pure owner-adapter fixture covers both an unexpected
failable-input `nil` and a policy return outside `allowed`. Each path produces
exactly the host-composition/runtime/safety-not-proven invariant fact,
quiesces before propagation and optional fatal-hook observation, invokes no
policy for `nil`, invokes policy exactly once for the unlisted result, never
reinvokes policy for the invariant, and rejects every later normal-cycle
attempt. The checked-in corpus records both paths. Production host integration
remains SPEC-015 work. `T2.4` is next.
