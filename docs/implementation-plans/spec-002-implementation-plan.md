---
spec: SPEC-002
feature: giftui-mvp-architecture
title: SPEC-002 Implementation Plan
status: draft
owners:
  - codex
created: 2026-08-28
updated: 2026-08-29
related_design_notes: []
conformance_report: null
related_future_work:
  - FW-005
  - FW-016
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-002 Implementation Plan

> This plan derives work from the approved Portable Foundation Specification.
> It orders implementation and evidence but does not amend the contract.

## Authority and Scope

The governing contract is approved
[SPEC-002](../specs/spec-002-portable-foundation.md). It is supported by
accepted [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md),
approved [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md),
[RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md), and
[RFC-011](../rfcs/rfc-011-bounded-application-actions.md), and accepted
[ADR-005](../adrs/adr-005-semantic-layout-render-boundary.md),
[ADR-006](../adrs/adr-006-shared-semantics-runtime-profiles.md),
[ADR-007](../adrs/adr-007-integration-ownership-and-host-composition.md),
[ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md),
[ADR-009](../adrs/adr-009-checked-integer-geometry.md), and
[ADR-033](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md).

The [MVP Scope](../MVP_SCOPE.md) requires one substantially shared Signal
Analyzer presentation across macOS dynamic, macOS static, Raspberry Pi 1/Linux
dynamic, and nRF52840 static configurations. Those stacks require identical
portable geometry and input-value meaning without importing target mechanics.

This plan implements only SPEC-002-owned values, checked operations, import
enforcement, migration, and independent evidence. Failure vocabulary remains
owned by approved [SPEC-003](../specs/spec-003-failure-outcomes-and-containment.md),
capability vocabulary by approved
[SPEC-004](../specs/spec-004-capability-contribution-and-resolution.md), and
input admission, dispatch, layout, backend, and host policy by their contracts.

Implementation begins from a clean MVP baseline rather than by incrementally
reshaping the proof-of-concept package. The immutable `PoC` Git tag at commit
`2b2837a` is the sole implementation baseline for migration evidence. No source,
test, product, target, firmware application, or compatibility shim is retained
merely because it worked in the proof of concept.

The clean-baseline cut is a repository-wide coordination operation. This plan
owns the SPEC-002 portion: disposition evidence for Foundation declarations,
replacement of the package/Foundation baseline, contract fixtures, and proof
that no legacy Foundation surface survives. Removal of code or tests governed
by another Specification requires a ready owning plan or an explicit
maintainer-approved removal disposition. Removal of legacy documents requires
the separately reviewed governance change described in Milestone 0; this plan
does not amend documentation-preservation policy.

## Current Repository State

- The immutable `PoC` tag at commit `2b2837a` contains the old root
  `Package.swift`, `Sources/`, `Tests/`, PoC firmware applications, legacy
  `docs/GiftUI_*.md` documents, and the original cross-target scripts. These
  paths are historical evidence, not the starting structure of the MVP
  implementation.
- The active tree still contains that PoC package and implementation. Its
  geometry uses mutable `Int`, trapping or throwing arithmetic, and a public
  three-case `InputEvent`; none conforms to SPEC-002 and none will be carried
  into the clean baseline.
- `demo/SignalAnalyzer/`, the governed Proposal/RFC/ADR/Specification corpus,
  current Spikes and `experiments/`, and `scripts/validate-governance.rb` were
  added after the PoC tag. They belong to MVP work and are not candidates for
  PoC removal.
- The reusable Raspberry Pi environment consists of the project-local pins,
  setup, environment, doctor, ARMv6 probe package, and generic build/artifact
  inspection mechanics. The Thermostat default product and deployment example
  are PoC coupling and must not survive the reset.
- The reusable nRF52840 environment consists of the project-local pins,
  setup, environment, doctor, generic build/ELF inspection mechanics, and the
  hardware-free `probe` application. `compile-layer.sh`, the `ili9486`,
  `kmrtm24024_spi`, and `skeleton` applications, and any source lists or checks
  tied to old GiftUI modules are PoC implementation and must not survive.
- `scripts/check-environment.sh` is mechanically reusable but still describes
  “PoC A”; it must be generalized before retention. Generic deploy/flash
  mechanics may remain only if they accept an explicit current product or
  application and contain no PoC default, path, or documentation example.
- `Tests/ContractFixtures/SPEC002/` and
  `scripts/contracts/run-spec-002.sh` do not exist. There is no exact target
  allow-list, forbidden-import/re-export inspection, layout/allocation probe,
  or baseline/candidate link-map harness.
- Project-local Raspberry Pi and nRF52840 pins and doctor/probe workflows fix
  Swift 6.3.2, ARMv6 Bookworm, and nRF Embedded Swift with Zephyr 4.3.0/SDK
  0.17.4. The local Apple compiler reports the required Swift 6.3.3 identity
  for macOS evidence.

## Clean-Baseline Disposition

The reset uses provenance and current need, not file type, to decide what
survives.

| Disposition | Active-tree material | Rule |
| --- | --- | --- |
| Preserve | `docs/MVP_SCOPE.md`, vision/principles, governed lifecycle artifacts, `docs/features.yaml`, engineering governance, `.agents/`, and repository skills | Current authority or current process infrastructure |
| Preserve | `demo/SignalAnalyzer/`, `docs/spikes/`, and `experiments/` | Post-PoC MVP application or governed evidence |
| Preserve after audit | Toolchain pins, setup/environment/common/doctor scripts, Raspberry Pi probe package, nRF52840 `probe` application, generic build and artifact/ELF inspection mechanics, and ignored `.toolchains/` state | Reusable environment capability with no old product, module, API, or application assumption |
| Rewrite | Root `Package.swift`, root `README.md`, environment summary text, build/deploy defaults, and retained script examples | The file has reusable mechanics but its active meaning is PoC-coupled |
| Remove | PoC contents of root `Sources/` and `Tests/`, Thermostat products/examples, PoC backend/runtime/platform/input/font implementations, and compatibility surfaces | Old implementation is recoverable from tag `PoC` and has no authority; newly created contract fixtures are retained |
| Remove | nRF52840 `ili9486`, `kmrtm24024_spi`, and `skeleton` applications plus `scripts/nrf52840/compile-layer.sh` | Product/application or source-list coupling rather than reusable environment |
| Remove after governance/link preparation | Legacy root `docs/GiftUI_*.md` documents and PoC-only README material | Allowed only after tagged-history policy and all active links are repaired |
| Recreate | Minimal one-package MVP manifest, `GiftUI` Foundation sources/tests, SPEC-002 contract fixtures, and contract driver | Derived only from approved Specifications and accepted ADRs |

Retention does not adopt an implementation technique. Any preserved script or
fixture that imports an old GiftUI module, names a removed product, embeds an
old source list, or asserts an obsolete contract must be rewritten or removed.

## Acceptance-Criterion Matrix

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `PF-001` | `T2.1`, `T2.4`, `T5.2` | API/visibility fixtures, geometry tests, four-profile declaration reports | pending |
| `PF-002` | `T2.2`, `T2.4`, `T4.2` | Rejection corpus and exact SPEC-003 owner-adapter mapping fixtures | pending |
| `PF-003` | `T2.3` | Complete rectangle boundary and half-open containment corpus | pending |
| `PF-004` | `T3.1`, `T3.2`, `T3.3` | Package-SPI inspection, raw-boundary fixtures, concrete-type exclusions | pending |
| `PF-005` | `T0.7`, `T1.3`, `T1.6`, `T4.1`, `T4.3` | Clean package bootstrap, skeleton-readiness transcript, exact graph/cycle check, import fixtures, compiled re-export inspection | pending |
| `PF-006` | `T5.1`, `T5.2` | Four exact driver commands and equal host/Embedded transcripts | pending |
| `PF-007` | `T5.3`, `T5.4` | Layout, allocation, section-delta, compiler, command, revision, and link-map reports | pending |
| `PF-008` | `T0.2`, `T0.5`, `T2.4`, `T3.3`, `T6.1` | Tag-derived migration ledger, clean-baseline removal record, and forbidden-shim audit | pending |
| `PF-009` | `T4.1`, `T4.2`, `T6.2` | Ownership fixtures plus reciprocal lifecycle-link audit | pending |
| `PF-010` | `T6.3` | Normative scope audit across code, fixtures, and notes | pending |

## Milestones and Tasks

### Milestone 0: Re-baseline the Repository for MVP

**Entry conditions:** SPEC-002 remains `approved`; tag `PoC` resolves to the
maintainer-confirmed final PoC commit; the tag is available in the repository's
durable remote; and the maintainer has approved the exact reset boundary.

**Exit evidence:** The PoC implementation is absent from the active tree, the
repository has a minimal buildable SPEC-002 package baseline, reusable
environment probes remain operational, and every removed Foundation item is
recoverable and dispositioned against tag `PoC`.

- [ ] `T0.1` — Verify and record the immutable PoC baseline: tag name, commit
      `2b2837a`, remote availability, tree checksum or complete tracked-path
      inventory, and retrieval commands. Fail the reset if the durable tag
      cannot reproduce `Package.swift`, `Sources/`, `Tests/`, firmware, scripts,
      and legacy documents selected for removal.
- [ ] `T0.2` — Before deletion, create the PF-008 migration ledger under
      `Tests/ContractFixtures/SPEC002/` directly from tag `PoC`. Enumerate every
      PoC `Point`, `Size`, `Rect`, `ProposedSize`, `LayoutArithmetic`,
      `InputEvent`, scalar representation, mutable field, precondition,
      throwing/trapping path, source location, consumer, and package edge.
      Record `removed`, `recreated by SPEC-002`, or `owned by SPEC-NNN`; do not
      use “unchanged” or “retained from PoC” as a disposition.
- [ ] `T0.3` — Produce an exact keep/rewrite/remove manifest for the paths in
      `Clean-Baseline Disposition`. For each retained script or fixture, prove
      that its purpose is toolchain setup, environment diagnosis, hardware-free
      probing, generic build/artifact inspection, or governance validation and
      that it does not encode an old GiftUI API, target graph, product, sample,
      or architecture.
- [ ] `T0.4` — Obtain coordinated dispositions before the cut. Every non-
      Foundation source/test/firmware path must be covered by its owning
      Specification plan or explicit maintainer-approved removal-only record.
      Amend the documentation-preservation rule and repair lifecycle links
      before removing legacy `docs/GiftUI_*.md`; SPEC-002 does not authorize
      either action by itself.
- [ ] `T0.5` — Execute one reviewable clean-baseline cut: remove the old root
      manifest, PoC source and test targets, Thermostat material, PoC
      implementation firmware, hard-coded layer compilation, and all approved
      for-removal legacy-document paths. Preserve the new SPEC-002 ledger and
      fixtures plus post-tag Signal Analyzer, lifecycle, Spike, experiment,
      governance, and environment material. Record deleted paths against tag
      `PoC`; do not copy them into an active `archive/` directory.
- [ ] `T0.6` — Sanitize retained environment infrastructure. Generalize
      `scripts/check-environment.sh`; remove the Raspberry Pi Thermostat default
      and example; retain the Raspberry Pi probe; retain only the nRF52840
      `probe` application; and prove every retained build/deploy/flash command
      requires an explicit current product/application where no MVP default
      exists. Keep downloads and generated environments under `.toolchains/`
      and generated artifacts under the existing `.build/` roots.
- [ ] `T0.7` — Recreate a minimal buildable root Swift package from SPEC-002:
      one SwiftPM distribution package, the stable `GiftUI` library
      product/target, only SPEC-002-owned Foundation source and test targets,
      and no speculative targets owned by later Specifications. Establish the
      initial exact target allow-list from this clean manifest and make newly
      introduced targets fail closed until their owning plan updates it.
- [ ] `T0.8` — Rewrite the root README for the MVP and add the minimal approved
      historical-baseline pointer required by the governance change. Run the
      governance/link validator and an active-tree audit proving that removed
      products, modules, applications, and local legacy-document paths occur
      only in the tag-derived migration ledger or approved historical pointer.

`T0.5` and `T0.7` must land together or in a branch sequence that never merges
an unbuildable active baseline. Milestone 0 does not claim any downstream
runtime, backend, platform, driver, or Signal Analyzer conformance.

### Milestone 1: Establish the Foundation Contract Harness

**Entry conditions:** SPEC-002 remains `approved`; its ADRs remain `accepted`;
and its RFCs remain `approved`.

**Exit evidence:** The clean package has a contract-fixture skeleton, exact
dependency baseline, four-profile SPEC-002 driver surface, and one stable
repository-level test entry point. A clean-checkout skeleton-readiness
transcript proves those seams work together before substantive Foundation
implementation begins.

- [ ] `T1.1` — Create the checked-in SPEC-002 fixture layout, deterministic
      report locations, positive/negative compile-fixture conventions, and
      test entry points. The tag-derived ledger from `T0.2` remains evidence;
      no PoC test file or helper is copied into the new suite.
- [ ] `T1.2` — Review the migration ledger for complete tag coverage and add
      explicit expected replacement declarations and evidence owners for each
      SPEC-002 row. Reject shims that preserve trapping-only, unbounded,
      public-input, mutable-field, or absent-provenance behavior.
- [ ] `T1.3` — Add
      `Tests/ContractFixtures/SPEC002/target-dependencies.yaml` from the clean
      `swift package dump-package` target set, including empty dependency lists,
      plus exact-set/direct-edge comparison and an independent cycle check.
      Newly added targets must fail closed until reviewed.
- [ ] `T1.4` — Create the exact four-profile command surface at
      `scripts/contracts/run-spec-002.sh`, shared report locations, deterministic
      exits, and compiler/target/SDK/flags/command/revision metadata capture.
      Missing pins or mismatched compilers must fail rather than fall back.
- [ ] `T1.5` — Create `scripts/test.sh` as the single repository-level test and
      check entry point. With no arguments it runs the fast macOS-dynamic path:
      governance validation, root package/unit tests, and every registered
      macOS-dynamic contract driver. It also accepts the explicit profiles
      `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
      `nrf52840-embedded`, plus `all-hardware-free` to run every registered
      contract driver across all four profiles. Use a checked-in ordered driver
      registry, common report roots, deterministic exit aggregation, and clear
      missing-toolchain/SDK/driver diagnostics. Register
      `scripts/contracts/run-spec-002.sh` first; every later implementation plan
      must register its driver without changing the top-level invocation.
      Preserve each contract driver's exact command, compiler checks, metadata,
      and evidence output rather than hiding or weakening them. Do not deploy,
      access a remote Raspberry Pi, run connected-board tests, or flash an nRF
      target from this runner.
- [ ] `T1.6` — Establish the explicit framework-skeleton readiness gate from a
      clean checkout. Record one reproducible transcript proving that
      `swift package dump-package` matches the initial dependency allow-list,
      `swift build --product GiftUI` succeeds, a client fixture can
      `import GiftUI`, the root unit-test target passes, positive and
      forbidden-import fixture mechanics execute, the macOS-dynamic
      `scripts/contracts/run-spec-002.sh` entry point is callable, and the
      no-argument `scripts/test.sh` fast gate passes. Audit the manifest and
      active tree to prove that no PoC compatibility surface or speculative
      target owned by a later Specification exists. Verify the retained
      Raspberry Pi and nRF setup/doctor/probe entry points structurally and
      record their pinned targets; missing ignored toolchain state does not
      block this host skeleton gate, while actual cross-profile probe and
      compiler evidence remains required by Milestone 5. Do not begin
      Milestone 2 until this gate passes.

### Milestone 2: Implement Checked Portable Geometry

**Entry conditions:** Milestone 0 produced the clean `GiftUI` target,
`T1.1`/`T1.2` fixed the contract-fixture and migration-evidence seams, and the
`T1.6` framework-skeleton readiness gate passed.

**Exit evidence:** The exact geometry contract passes the host boundary corpus,
the clean `GiftUI` target compiles, and downstream consumers remain absent or
have a named owning-plan dependency.

- [ ] `T2.1` — Implement the exact public,
      immutable `Int32` API: `GeometryScalar`, `Point`, failable `Size`,
      failable `Rect` with total exclusive edges, and failable `ProposedSize`.
      Test declarations, access, conformances, zero dimensions, and independently
      absent proposals.
- [ ] `T2.2` — Implement the exact package
      `GeometryArithmetic` optional-result API. Test ordinary values, zero,
      `Int32.min`, `Int32.max`, and every add/subtract/multiply overflow edge;
      add no trapping compatibility helper or second arithmetic seam.
- [ ] `T2.3` — Construct rectangles through checked exclusive-edge addition and
      implement `contains` from total edges without unchecked intermediates.
      Test maximum valid extents, both scalar limits, rejected edges, empty
      rectangles, exact edges, and half-open containment.
- [ ] `T2.4` — Compile the clean public declarations, package SPI, and
      Foundation tests without any PoC compatibility declaration. Downstream
      consumers are implemented later by their owning Specifications and must
      import these values directly; any consumer need that requires layout,
      render, execution, backend, or host policy is routed upstream.

`T2.1`–`T2.4` should land as one independently testable Foundation contract
change. No downstream module is recreated solely to prove source migration.

### Milestone 3: Implement Normalized Pointer Values

**Entry conditions:** Tagged PoC input producers/consumers are dispositioned in
the migration ledger and `T2.1` fixes the `Point` contract.

**Exit evidence:** The bounded package-SPI family exists and exposes no
concrete integration type or admission semantics.

- [ ] `T3.1` — Add exact package declarations for `PointerPhase`,
      `InputSourceID`, `PointerSequenceID`, `InputOrdinal`,
      `PresentationRevision`, and `NormalizedPointerEvent`. Preserve every raw
      bit pattern and require provenance without a sentinel.
- [ ] `T3.2` — Add package compile/value fixtures for every phase, min/max
      coordinates, min/max wrapper values, copying/equality, exact raw widths,
      and absence of backend/platform/OS/driver/transport/HAL/hardware fields.
      Do not test admission, ordering, cancellation, hit testing, or dispatch.
- [ ] `T3.3` — Prove that public PoC `InputEvent` is absent and that the clean
      package exports only the required package-SPI value family. Future
      simulator, Linux, Raspberry Pi, device-input, and runtime callers are
      created by their owning Specifications; they must keep physical-to-logical
      rejection local until the first owner adapter and must not reintroduce an
      absent-provenance compatibility event. Close every tagged input case in
      the migration ledger.

Milestone 3 may proceed beside Milestone 2 after `T2.1`; it does not recreate
any old input integration.

### Milestone 4: Enforce Cross-Owner Boundaries

**Entry conditions:** SPEC-003 has produced `GiftUIFailureCore` and
`GiftUIFailureExecution`, SPEC-004 has produced `GiftUICapabilities`, and
Milestones 2/3 expose final Foundation declarations.

**Exit evidence:** The final package DAG, adapters, and compile fixtures prove
reciprocal ownership without making Foundation import either owner.

- [ ] `T4.1` — Refresh the exact allow-list after owner targets exist. Add
      positive and forbidden-import fixtures for every protected owner and
      prove `GiftUIFailureCore` and `GiftUICapabilities` do not import `GiftUI`.
- [ ] `T4.2` — At each first boundary knowing both concepts, implement exact
      SPEC-003 mappings for negative dimensions, arithmetic overflow,
      unrepresentable rectangle edges, and out-of-range input conversion.
      Prove exact condition, `.foundation` origin, `.operation` scope,
      `.contained` containment, and absence of partial values.
- [ ] `T4.3` — Inspect source imports, exported declarations, compiled module
      dependencies, and product linkage to prove `GiftUI` neither imports nor
      re-exports prohibited higher/concrete modules. Cover every package target
      and require positive plus forbidden-import evidence for protected owners.

### Milestone 5: Produce Four-Profile Evidence

**Entry conditions:** Milestones 2–4 are complete; the macOS compiler matches
SPEC-002; project-local Pi/nRF doctor and hardware-free probes pass.

**Exit evidence:** All four exact commands produce reproducible reports and
link maps, clearly labeled as host or hardware-free cross-build evidence.

- [ ] `T5.1` — Complete the driver profiles: macOS dynamic/static use Apple
      Swift 6.3.3, `arm64-apple-macosx26.0`, release `-O`, and WMO; Raspberry Pi
      uses project-local Swift 6.3.2/Bookworm and
      `armv6-unknown-linux-gnueabihf`; nRF uses project-local Swift 6.3.2,
      `armv7em-none-none-eabi`, Embedded Swift, `-Osize`, WMO, Zephyr 4.3.0,
      and SDK 0.17.4. Do not substitute architectures, install globally,
      deploy, or flash.
- [ ] `T5.2` — Compile the same Foundation source and deterministic semantic
      corpus in all profiles. Compare host and Embedded transcripts for values,
      arithmetic, rejection, rectangle behavior, phases, and raw wrappers.
- [ ] `T5.3` — Report size/stride/alignment for every owned value and fail every
      normative maximum. Prove construction/arithmetic add no heap allocation,
      reflection, runtime discovery, Objective-C, `Task`, or `MainActor`.
- [ ] `T5.4` — Build matched baseline/candidate executables from one template
      and equal link inputs; candidate references every SPEC-002 value/operation.
      Preserve link maps and report candidate-minus-baseline code, read-only,
      initialized, zero-initialized, and file-size deltas plus full toolchain
      metadata. Treat deltas as descriptive, not new ceilings.

### Milestone 6: Prepare Conformance Review

**Entry conditions:** Every prior task has a disposition and reports reproduce
from a clean checkout.

**Exit evidence:** Migration, traceability, and scope audits are complete and a
SPEC-002 conformance report can be reviewed.

- [ ] `T6.1` — Re-run the migration inventory and close every ledger row with a
      code location, removal, explicit owner blocker, or approved exception.
      Prove no shim weakens checked geometry, failable construction, bounded
      fields, mandatory provenance, or package visibility.
- [ ] `T6.2` — Audit reciprocal references among SPEC-002/003/004 and between
      SPEC-002 and RFC-004/RFC-011/ADR-033; audit package edges and adapter
      locations against them. Update navigation only, never contract text.
- [ ] `T6.3` — Confirm code, fixtures, and notes define no declarative behavior,
      failure disposition/diagnostics, capability resolution, layout policy,
      input admission, backend policy, or host policy. Route new needs upstream.
- [ ] `T6.4` — Create `docs/conformance/spec-002-conformance.md`, link stable
      evidence, and hand every PF criterion to conformance review. Do not mark
      SPEC-002 implemented without complete evidence and maintainer approval.

## Design-Note Triggers

- Create a focused evidence-driver design note if compiler discovery, shared
  sources, allocation instrumentation, module inspection, or link-section
  normalization cannot be reconstructed from local scripts/fixtures.
- Create a dependency-enforcement design note if exported-declaration,
  compiled-module, and direct-edge inspection needs a maintained multi-stage
  algorithm. It must explain realization, not alter allowed edges.
- Do not create geometry/wrapper notes unless implementation exposes a genuine
  non-local mechanism; the Specification and local tests should suffice.

## Integration and Validation Order

1. Run `scripts/test.sh` with no arguments after the clean bootstrap and after
   every milestone; it is the stable fast local gate.
2. Run host Foundation unit and package-SPI compile fixtures through the
   registered SPEC-002 driver.
3. Run the clean Foundation suite and prove the PoC public surfaces are absent.
4. Integrate SPEC-003 adapters/SPEC-004 import fixtures and rerun the exact
   graph check whenever `Package.swift` changes.
5. Run macOS dynamic, then macOS static through `scripts/test.sh` profile
   selection.
6. Run Raspberry Pi ARMv6 cross-build/inspection after its doctor/probe.
7. Run nRF Embedded cross-build/inspection after its doctor/probe, including
   VFP ABI inspection where the fixture links an ELF.
8. Run `scripts/test.sh --profile all-hardware-free` and compare transcripts,
   layouts, allocations, section reports, and link maps before conformance
   review.

No task requires deployment, a remote `armv6l` host, connected Pi display/input
evidence, or nRF flashing. Those claims remain downstream conformance work.

## Risks and Upstream Blockers

### Upstream blockers

- The tagged-history preservation amendment and exact repository-wide removal
  scope require explicit maintainer approval. Legacy documents cannot be
  deleted while the current preservation rule and active lifecycle links still
  require them.
- Non-Foundation PoC code and tests cannot be removed under SPEC-002 authority
  alone. Each affected owner needs a ready plan or an explicit coordinated
  removal-only disposition before `T0.5`.
- The approved SPEC-003/004 owner targets do not yet exist. `T4.1`/`T4.2`, and
  complete PF-002/PF-005/PF-009 evidence, cannot finish until their own plans
  produce those targets. SPEC-002 must not create substitute vocabularies.
- Recreating any input producer or consumer crosses into execution,
  interaction, integration, or host ownership. If its approved contract and
  plan do not give an unambiguous seam, leave it absent rather than recreate a
  PoC adapter or add an unbounded or absent-provenance compatibility event.
- If a consumer cannot handle failable construction without choosing new
  layout, render, backend, or host policy, return to its owning Specification.

### Implementation risks

- A clean reset removes working integration coverage before its MVP
  replacements exist. Atomic package bootstrapping, tag-derived disposition,
  and per-Spec ownership prevent the temporary absence from becoming silent
  loss or accidental re-adoption.
- Retained scripts may look generic while embedding an obsolete product,
  source list, firmware application, or hardware assumption. The retention
  audit must inspect behavior and defaults, not filenames.
- Removing old tests eliminates a convenient regression net. Contract tests
  must be created from approved requirements rather than copied expectations
  before new implementation claims begin.
- A top-level runner can conceal skipped suites or weaken exact per-Spec
  commands if it relies on implicit discovery or normalizes failures. Use the
  checked-in registry, fail closed for requested profiles, and retain each
  driver's exact metadata and report output.
- Package input values must be visible to sibling targets without becoming
  Client API; compile both sides under every supported compiler.
- Source allow-lists miss re-exports; PF-005 requires compiled evidence.
- Dead stripping or unequal inputs can invalidate allocation/section evidence;
  record and equalize inputs and observably reference every candidate symbol.
- Toolchain drift must fail closed and be repaired only through tracked local
  workflows, without changing Xcode/global Swift, `/opt`, hardware, or remotes.

## Deferred and Follow-up Work

- [FW-005](../future-work/fw-005-alternative-geometry-scalars.md) remains
  outside MVP and does not relax checked `Int32` geometry.
- [FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md)
  remains outside this plan and does not change the one-package MVP contract.
- New optional discoveries must use the deferred-work track and cannot become
  implementation tasks without their normal lifecycle.

## Completion Record

No task has started. All tasks are pending, no design note or conformance
report exists, and this plan remains `draft` until the SPEC-003/004 coordination
path and task boundaries are reviewed as executable. Plan completion will not
by itself mark SPEC-002 `implemented`.
