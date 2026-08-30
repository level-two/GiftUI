---
spec: SPEC-004
feature: capability-system
title: SPEC-004 Implementation Plan
status: active
owners:
  - codex
created: 2026-08-29
updated: 2026-08-30
related_design_notes:
  - ../implementation-designs/spec-004-raster-arithmetic.md
conformance_report: null
related_future_work:
  - FW-006
  - FW-007
  - FW-008
  - FW-014
  - FW-015
  - FW-018
related_explorations: []
related_spikes:
  - SPIKE-001
  - SPIKE-002
supersedes: null
superseded_by: null
---

# SPEC-004 Implementation Plan

> This ready plan derives work from the approved Capability Contribution and
> Resolution Specification. It orders implementation and evidence but does not
> amend that contract or authorize work owned by another Specification.

## Authority and Scope

The governing contract is approved
[SPEC-004](../specs/spec-004-capability-contribution-and-resolution.md). Its
authority chain is accepted
[PROPOSAL-004](../proposals/proposal-004-capability-system.md), approved
[RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md) and
[RFC-006](../rfcs/rfc-006-capability-system-architecture.md), and accepted
[ADR-010](../adrs/adr-010-synchronous-one-shot-frame-handoff.md) and
[ADR-017](../adrs/adr-017-capability-and-operational-state-planes.md) through
[ADR-020](../adrs/adr-020-raster-presentation-capability.md). RFC-002 and
RFC-005 remain governing integration context for the module graph, startup
gates, and failure boundary.

The [MVP Scope](../MVP_SCOPE.md) requires one substantially shared Signal
Analyzer presentation across macOS dynamic, macOS static, Raspberry Pi
1/Linux dynamic with PiScreen, and nRF52840 static with TFT. Those stacks use
materially different full-surface and bounded tiled presentation paths, so the
host must prove the complete `rasterPresentation` semantic promise without
portable target/backend/device checks. SPEC-004 is therefore required MVP
stack-validation work, not a post-MVP general capability framework.

This is the active implementation plan for the next dependency-complete Wave 1
work. SPEC-003 has completed its independent Core, policy, health, diagnostic,
and Foundation-adapter tasks; its `T4.2` capability/failure adapter is now a
separately ready parallel-safe slice. SPEC-004 has completed its contract
harness and closed, bounded capability vocabulary. Its corrected arithmetic
contract has been explicitly reapproved, so the selected critical-path next
iteration remains inside SPEC-004 and begins Milestone 2 with checked
byte-bound and region arithmetic rather than opening a plan for another
Specification.
Production failure mapping, operation-stream integration, backend behavior,
and startup composition retain dependencies on SPEC-003, SPEC-009, SPEC-014,
and SPEC-015.

## Current Repository State

- The package exposes `GiftUI`, `GiftUIFailureCore`, the optional downstream
  `GiftUIFailureDiagnostics`, and the dependency-free `GiftUICapabilities`
  product/target with focused tests. The exact-set graph also includes the
  test-only Foundation/failure and Foundation/capability owner-adapter
  boundaries. All existing nodes and edges remain subject to the checked
  source, compiled-import, product-link, cycle, and non-re-export controls.
- `GiftUI` contains SPEC-002 checked geometry, arithmetic, and normalized
  pointer values. No capability declaration may be added there or re-exported
  from it. The approved SPEC-002 extent-to-capability adapter belongs at the
  first downstream boundary that imports both vocabularies.
- The registered four-profile SPEC-004 contract driver, ordered compile
  fixtures, normalized-corpus boundary, matched resource-harness roots,
  authority audit, and Milestone 0 readiness evidence exist. The driver builds
  the same production source in all four hardware-free profiles and the
  boundary suite rejects prohibited imports, graph changes, re-export, and
  portable target identity. No resolver semantic corpus, matched resource
  image, or conformance report exists yet.
- Milestone 1 supplies the complete approved value vocabulary, four
  role-addressed inline contribution slots, the reusable two-candidate
  workspace, failable validation seams, and bounded layout/allocation audits.
  `RasterPresentationResolver.resolve` is not implemented; the existing
  workspace normalization helpers are internal storage seams, not resolution
  behavior.
- SPEC-002 established fail-closed target dependency checks, positive and
  negative compile-fixture conventions, deterministic contract reports, and
  `scripts/contracts/driver-registry.tsv`. The capability target and driver
  must update those exact-set controls atomically rather than weakening them.
- `scripts/test.sh` is the single top-level fast and cross-profile gate. The
  SPEC-004 driver must preserve independent commands for `macos-dynamic`,
  `macos-static`, `raspberry-pi-armv6`, and `nrf52840-embedded` and must not
  perform remote access, deployment, or flashing.
- The project-local Raspberry Pi and nRF52840 setup, doctor, probe, build, and
  artifact-inspection workflows already preserve the required target pins.
  SPIKE-001 and SPIKE-002 contain useful feasibility fixtures and measurement
  shapes, but their types, layouts, and code are non-authoritative and cannot
  be promoted directly into production.
- SPEC-003 is implementing and has completed its independent Milestones 0-3
  plus the Foundation owner-adapter task. Its `T4.2` capability outcome adapter
  now has the stable SPEC-004 declarations it needs and may proceed separately
  without blocking or being absorbed into this iteration. SPEC-009, SPEC-014,
  and SPEC-015 are approved but unimplemented, so first-party one-shot tiled
  integration, operational fault injection, and the conjunctive startup gate
  remain downstream integration tasks.

## T2.1 Implementation Iteration — Completed

**Iteration disposition:** Completed after the maintainer explicitly
reapproved the corrected Specification. The linked
[checked raster-arithmetic design note](../implementation-designs/spec-004-raster-arithmetic.md)
proves why the fixed input widths make shared LCM/row overflow and a
payload-only usage overflow unconstructible. SPEC-004 now preserves those
widths, requires maximum-bound representability proofs, assigns the one
constructible shared-usage overflow to `.raster`, and forbids manufactured
wider fixtures.

**Completed objective:** Complete `T2.1`, the checked byte-bound and region
arithmetic slice of SPEC-004 Milestone 2. Add the pure internal arithmetic
and candidate-evaluation seam needed to derive exact row, region, raster,
payload, and in-flight usage or the corrected Specification-assigned
overflow/capacity reason. This remains the smallest implementation slice after
Milestone 1 and gives `T2.2` through `T2.5` a tested numeric foundation without
prematurely claiming a complete public resolver.

**Included task:** `T2.1` only.

**Satisfied upstream gate:** The maintainer explicitly reapproved the
consistent 2026-08-30 corrections to SPEC-004's `Byte-bound and region
arithmetic`, `Error Handling`, `Testing Requirements`, and `CR-010A`. The
correction preserves the approved fixed public widths and checked operations
while requiring overflow fixtures only for sites reachable from constructible
typed inputs.

**Explicitly excluded:** the separately ready SPEC-003 `T4.2`
capability/failure adapter, which may proceed in parallel under its own plan;
operation/lifetime/handoff compatibility and policy
selection (`T2.2`); complete resolver orchestration, role permutations,
snapshot construction, and absence behavior (`T2.3`); simultaneous-condition
precedence (`T2.4`); operation-count instrumentation (`T2.5`); normalized
four-host fixtures and one-shot lease evidence (Milestone 3); production
SPEC-002/SPEC-003 adapters and SPEC-009/SPEC-014/SPEC-015 integration; matched
resource images; conformance review; connected-target execution, deployment,
service restart, and flashing.

**Entry conditions:**

- SPEC-004 remains `implementing`, this plan remains `active`, and the
  Proposal/RFC/ADR authority chain remains accepted or approved.
- The SPEC-004 arithmetic conflict has been resolved in the normative contract
  and the corrected Specification has received explicit maintainer approval.
- Milestones 0 and 1 remain complete, including the registered fail-closed
  driver, exact import boundary, complete closed vocabulary, fixed
  contribution/workspace storage, malformed adapter boundary, and bounded
  value audits.
- The active package graph, including SPEC-003 diagnostic and
  Foundation-adapter work, is treated as the baseline; the iteration must not
  discard or weaken those edges or their exact-set checks.
- No arithmetic helper may widen the public contract, import another owner,
  allocate, trap on caller-derived values, or choose among unresolved
  operation, encoding, lifetime, handoff, realization, or policy alternatives.

**Ordered work and evidence:**

1. In `Sources/GiftUICapabilities/`, define a replaceable internal arithmetic
   result/seam that consumes already validated typed values and uses checked
   `UInt32` operations only. It returns either a complete fixed geometry/usage
   value or one exact unavailable reason, retains no input, and exposes no
   partial result. Keep the public declarations exactly as approved and keep
   `GiftUICapabilities` a dependency-free leaf.
2. Compute the effective row alignment as checked LCM; then compute checked
   unaligned and aligned row bytes. Prove the `UInt16.max` alignment product,
   `UInt16.max * 4` RGBA row, and maximum aligned-row boundaries remain within
   `UInt32`; include unequal and coprime alignments. No operation may wrap,
   saturate, substitute zero, or trap, and no wider private value may be
   presented as resolver input.
3. Apply exact region selection: full logical width; full logical height for
   `.fullSurface`; and the tallest admissible complete-row height for `.tiled`
   from logical, candidate, and surface limits. Cover each limit as the selected
   minimum plus width/full-height rejection and exact-limit controls. Do not
   search a smaller tile to evade a byte ceiling.
4. Check `rowBytes * regionHeight` exactly once. On overflow return
   `.byteCountOverflow(domain: .raster)`; on success copy the same value to
   raster, payload, and one in-flight payload. Prove no `.payload` or
   `.inFlight` arithmetic overflow can be emitted and do not manufacture
   different operands.
5. Compute each available ceiling as the exact minimum of its three approved
   owners: requirement/candidate/policy for raster and payload, and
   requirement/surface/policy for in-flight. For all nine owner positions,
   cover equality success and first-excess failure with exact
   required/available payloads, preserving raster → payload → in-flight
   precedence.
6. In `Tests/GiftUICapabilitiesTests/` and the checked-in SPEC-004 semantic
   corpus, add focused table-driven cases for RGB565 and RGBA8888, equal and
   unequal alignments, full-surface and tiled regions, zero and limiting
   ceilings, the maximum typed representability proofs, the constructible
   shared-usage overflow, all nine capacity-minimum owners, and the exact nRF
   calculation: 960 row bytes and 3,840 raster, payload, and in-flight bytes
   for `480 x 4 x 2`. Case IDs and expected normalized results must be stable
   and fail closed when unknown or omitted.
7. Extend the existing allocation probe to execute the complete new arithmetic
   seam repeatedly and fail on any allocation, without claiming the full
   resolver allocation or operation-count criteria assigned to `T2.5`/`T5.2`.
   Re-run source/interface/binary boundary audits so no collection, closure,
   diagnostic, platform identity, or upward import enters the capability leaf.
8. Record deterministic Milestone 2 arithmetic evidence. Run focused tests and
   both macOS profile semantics, then run the exact standalone SPEC-004 driver
   for `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
   `nrf52840-embedded`, followed by the no-argument top-level gate. Pi and nRF
   results remain hardware-free cross-build/inspection evidence; retain linked
   resource, full-corpus, and connected-target claims for later milestones.

**Iteration exit:** `T2.1` is complete only when every corrected arithmetic,
overflow-domain, region-selection, and minimum-ceiling case has reproducible
passing evidence; the dependency/import and allocation boundaries still pass;
and the checked-in report makes no claim that the complete resolver or
Milestone 2 is finished. `T2.2` is then the next plan task. The existing
checked raster-arithmetic design note is `current`; update it in the same
change if implementation makes its described data flow, bounds, or test seams
stale.

## Acceptance-Criterion Matrix

The criterion text remains authoritative in SPEC-004. Each row below maps one
criterion to implementation work and checkable evidence.

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `CR-001` — Approval, manifest, authority, and reciprocal relationships | `T0.1`, `T6.1` | Governance and reciprocal-link audit | pending |
| `CR-002` — Foundational import boundary and identity-free portable presentation | `T0.2`, `T0.4`, `T6.1` | Exact target graph, compile fixtures, compiled imports, portable-source scan | pending |
| `CR-003` — Exactly one fixture-justified `rasterPresentation` family | `T1.1`, `T3.1` | Public-surface audit and fixture-to-field coverage report | pending |
| `CR-004` — Exact declarations, validation, capacities, and size ceilings | `T1.1`, `T1.2`, `T1.3`, `T5.3` | API/raw-value tests, invalid corpus, layout reports | pending |
| `CR-005` — All 24 role permutations are order-independent | `T2.3`, `T3.1` | Complete permutation transcripts for positive and representative negative fixtures | pending |
| `CR-006` — Missing, duplicate, malformed, absence, and workspace exhaustion behavior | `T1.3`, `T2.3`, `T3.3` | Typed-buffer and adapter-boundary negative corpus | pending |
| `CR-007` — Exact simultaneous-incompatibility precedence | `T2.4` | Generated constructible-pair matrix with candidate/order permutations | pending |
| `CR-008` — Encoding and submission-lifetime failures remain distinct | `T2.2`, `T3.2` | Independent negative/control fixture pairs | pending |
| `CR-009` — Complete lifetime/handoff matrix and no retained operation stream | `T2.2`, `T3.2`, `T4.3` | Closed compatibility matrix and one-shot lease fixtures | pending |
| `CR-010` — Four normalized host results and exact Pi/nRF outcomes | `T3.1`, `T5.1` | Cross-profile semantic transcripts and exact target builds | pending |
| `CR-010A` — Complete formula, capacity, malformed-bound, and overflow coverage | `T2.1`, `T2.4`, `T3.1` | Table-driven arithmetic and exact 3,840-byte nRF result corpus | pending |
| `CR-011` — Zero static-path heap allocation | `T1.4`, `T5.2` | Allocation-instrumented host fixture and allocator-free linked target | pending |
| `CR-012` — Zero steady-state resolution and at most 96 initialization operations | `T2.5`, `T5.2` | Invocation and primitive-operation reports for every path | pending |
| `CR-013` — nRF resource, layout, repeatability, and toolchain evidence | `T5.3`, `T5.4` | Matched ELF/map/disassembly reports and two pristine rebuilds | pending |
| `CR-014` — First-party tiled paths consume the borrowed stream exactly once | `T3.2`, `T4.3` | Pure lease fixture followed by SPEC-014 integration evidence | pending |
| `CR-015` — Runtime faults leave the snapshot unchanged and use SPEC-003 seams | `T4.2`, `T4.3` | Cross-owner fault-injection and snapshot-equality transcripts | pending |
| `CR-016` — B2 structural and capability gates fail independently and start conjunctively | `T4.4`, `T6.1` | Independent-negative and combined-startup fixtures | pending |

## Milestones and Tasks

### Milestone 0: Establish the Capability Contract Harness and Leaf

**Entry conditions:** SPEC-004 remains `implementing`; RFC-004/RFC-006 remain
`approved`; ADR-010 and ADR-017 through ADR-020 remain `accepted`; the active
SPEC-002/003 package graph is available without weakening its checks.

**Exit evidence:** An empty `GiftUICapabilities` leaf is importable, its exact
dependency boundary is enforced, and a registered four-profile SPEC-004 driver
has reproducible fixture and report conventions before semantic code lands.

- [x] `T0.1` — Verify the complete authority chain, manifest entry, reciprocal
      SPEC-002/003 relationships, and all 17 acceptance-criterion labels
      (`CR-001` through `CR-016`, including `CR-010A`). Create
      `Tests/ContractFixtures/SPEC004/` with an ordered fixture manifest,
      normalized semantic-corpus schema, adapter-versus-typed-input boundary,
      matched resource-harness layout, deterministic generated/report roots,
      and explicit host/cross-build/connected-target evidence labels.
- [x] `T0.2` — Add the `GiftUICapabilities` library product/target and focused
      unit-test target. It must import no `GiftUI`, semantic, layout, render,
      execution, failure, runtime, backend, platform, driver, OS/RTOS, HAL, or
      concrete integration module. Update SPEC-002's exact target allow-list
      and graph fixtures atomically while preserving the in-progress
      `GiftUIFailureCore` leaf and every existing edge.
- [x] `T0.3` — Create
      `scripts/contracts/run-spec-004.sh --profile <profile>` for the exact four
      supported profile names. Fail closed on compiler, target, SDK, board,
      optimization, pin, source-list, and evidence mismatches; record revision
      and dirty state, tool hashes/versions, full commands, inputs/hashes,
      outputs/hashes, and deterministic exits. Register the standalone driver
      in `scripts/contracts/driver-registry.tsv` without adding remote access,
      deployment, or flashing to `scripts/test.sh`.
- [x] `T0.4` — Add positive capability-only imports; forbidden upward imports;
      `GiftUI` non-re-export tests; exact source and compiled dependency
      inspection; target-cycle detection; and a portable Signal Analyzer
      source scan for platform, backend, board, driver, controller, transport,
      or device identity branches.
- [x] `T0.5` — Record a clean-checkout harness-readiness transcript covering
      governance, exact package graph, Core import, negative fixtures, root
      tests, the standalone macOS-dynamic driver, and the no-argument top-level
      gate before Milestone 1.

### Milestone 1: Implement the Closed Capability Vocabulary

**Entry conditions:** Milestone 0 passes and `GiftUICapabilities` remains a
foundational dependency leaf.

**Exit evidence:** Every approved common value, requirement, contribution,
workspace, resolution, snapshot, and unavailable declaration has its exact
visibility, finite cases, raw widths, failable construction behavior, and
bounded representation without importing another owner.

- [x] `T1.1` — Implement the exact common values, option sets, raw enums,
      `RasterPresentationRequirement`, four contributor records, policy,
      effective result, resolution, snapshot, malformed/capacity vocabulary,
      and `RasterPresentationUnavailable`. Test declared bits and raw values,
      public labels/types, `Equatable`/`Sendable` conformance, zero-valid byte
      ceilings, nonzero structural bounds, and the rule that the public
      catalogue contains exactly `rasterPresentation`.
- [x] `T1.2` — Implement the role-addressed four-slot
      `RasterPresentationContributions`, duplicate mask, insertion result, and
      two-candidate `RasterPresentationResolverWorkspace`. Prove first-value
      preservation, duplicate-slot equality rules, deterministic lowest-role
      duplicate/missing selection, fifth-insert duplicate behavior, workspace
      capacities `0...2`, rejection above two, reuse after return, and no
      order-bearing storage semantics.
- [x] `T1.3` — Implement failable initializers and adapter-facing validation
      seams for every malformed field, unknown/empty option-set case, invalid
      preference, region/alignment/count bound, and alternate-realization rule.
      Keep raw SPEC-002 extent conversion and role/field precedence in a
      downstream fixture adapter so unconstructible values are never claimed
      as resolver inputs.
- [x] `T1.4` — Add source/interface/binary audits excluding strings,
      collections, closures, existentials, reflection, exceptions, registries,
      platform identities, and heap-backed provenance from the capability
      path. Instrument construction and fixed storage early so a layout or
      allocation breach is found before resolver consumers depend on it.

### Milestone 2: Implement Deterministic Bounded Resolution

**Entry conditions:** Milestone 1 fixes the complete valid input domain and
unavailable vocabulary.

**Current gate:** The maintainer explicitly reapproved the SPEC-004 correction
that resolves the unreachable-overflow conflict recorded in the checked
raster-arithmetic design note. `T2.1` is complete. `T2.2` exposed that the
single-case operation-stream enum made its required mismatch path
unconstructible; the Specification adds a validation-only negative fact, and
the maintainer explicitly reapproved that correction. `T2.2` may proceed.
Tasks `T2.2` through `T2.5` must use the checked numeric foundation without
reinterpreting its reasons.

**Exit evidence:** The pure resolver produces one immutable effective result
or exact stable reason, independent of role/candidate order, with checked
arithmetic, complete compatibility rules, bounded work, no partial snapshot,
and no runtime side effect.

- [x] `T2.1` — Implement checked effective-alignment LCM, unaligned/aligned row
      arithmetic, full-surface/tiled region selection, raster/payload/in-flight
      usage, minimum available ceilings, and deterministic overflow-domain
      assignment. Cover both encodings, unequal alignments, zero ceilings,
      full and tiled regions, maximum typed non-overflowing LCM/row boundaries,
      the constructible shared-usage overflow assigned to `.raster`, the proof
      excluding payload-only/in-flight arithmetic overflow, equality and first
      excess for every owner of all three capacity minima, exact
      `480 x 4 x 2 = 3,840` nRF usage, allocation-free helper execution, and
      compilation through all four hardware-free profile commands.
- [x] `T2.2` — Implement operation/one-shot compatibility, canonical-encoding
      intersection, the complete submission lifetime/handoff matrix,
      realization/encoding allow rules, and deterministic preference order.
      Add the reapproved validation-only incompatible operation-stream case
      with raw value `2`; admit it only in producer and
      realization contributions, reject it as `.operationStreamMismatch`, and
      prove it can never appear in an available effective result.
      Prove that policy selects only complete conforming paths and that
      encoding, lifetime, handoff, and policy exclusion retain distinct
      reasons.
- [x] `T2.3` — Implement role validation, normalization of at most two
      candidates into caller-owned workspace, candidate evaluation, result
      construction, optional-absence snapshot behavior, and required-absence
      failure. Run all 24 role permutations for every positive and
      representative negative fixture and compare results by value and stable
      transcript.
- [x] `T2.4` — Build the table-driven primary-reason corpus for every
      constructible pair of typed incompatibilities in the exact 16-step
      precedence. Permute contribution and candidate declaration order,
      exercise the constructible shared-usage overflow and its interactions
      with capacity failures, and keep raw-adapter short-circuit tests separate
      from the typed resolver corpus.
- [x] `T2.5` — Add fixed-width instrumentation for role visits, set
      intersections/comparisons, checked arithmetic, candidate checks,
      validation-result construction, and resolver invocation. Enforce at most
      96 primitive operations on every success/negative path and zero resolver
      invocations during repeated snapshot access; compile instrumentation out
      of production resource images.

### Milestone 3: Prove the Four Normalized Configurations and One-Shot Seam

**Entry conditions:** Milestone 2 passes without a runtime, backend, or
connected target.

**Exit evidence:** Pure normalized fixtures prove equivalent capability
meaning across all four profiles, exact Pi/nRF bounds, complete field
justification, and a one-shot tiled seam without promoting Spike code.

- [x] `T3.1` — Encode the macOS dynamic, macOS static, PiScreen `240 x 240`,
      and nRF52840 TFT `480 x 320` fixtures from SPEC-004. Produce a
      fixture-to-field assertion report for every admitted field, equal macOS
      semantic coverage, bounded Pi RGB565 tiling, one nRF RGB565 `3,840`-byte
      in-flight payload, and unavailable nRF full-surface RGBA8888.
- [x] `T3.2` — Rebuild the authoritative one-shot lease and derived-payload
      fixtures rather than copying SPIKE-001 production shapes. Cover every
      lifetime/handoff pair, exact-once synchronous stream consumption,
      synchronous-copy ownership before borrow end, no queued synchronous
      borrow, no retained/replayed GiftUI operation, and independent
      encoding/lifetime negative-control pairs.
- [x] `T3.3` — Complete missing, duplicate, malformed raw adapter, extent
      overflow, optional absence, required absence, workspace exhaustion,
      unsupported extent, policy, and every capacity negative/control case.
      Assert no traps, partial snapshots, last-writer substitution, weakened
      result, or diagnostic dependence.
- [x] `T3.4` — Compare normalized dynamic/static transcripts and prove the
      static fixture uses fixed/caller-owned storage throughout contribution,
      resolution, validation-result construction, snapshot storage, and
      steady-state access.

### Milestone 4: Integrate Approved Cross-Owner Boundaries

**Entry conditions:** Milestones 1-3 pass independently. Each production task
below begins only after the owning approved Specification exposes its stable
target and declarations.

**Exit evidence:** Foundation, failure, execution, backend, and host owners
join the capability leaf through one-way adapters without duplicating
vocabulary, mutating the snapshot, or making capability resolution substitute
for structural validation.

- [x] `T4.1` — At the first downstream boundary importing SPEC-002 and
      `GiftUICapabilities`, implement the exact `Size` adapter: valid positive
      `UInt16` dimensions map to `CapabilityExtent`, zero maps to malformed
      requirement extent, positive overflow maps to logical extent overflow,
      and negative values remain earlier SPEC-002 failures. Preserve reciprocal
      import and condition evidence without moving geometry into capabilities.
- [ ] `T4.2` — After SPEC-003 supplies `GiftUIFailureCore`, implement the
      downstream required-family adapter from every
      `RasterPresentationUnavailable` case to the exact condition raw value
      `12...25` and `GiftUIOutcome<CapabilitySnapshot>.failure`. Prove
      `.capability`/`.runtime`/`.contained`, preserved associated capability
      detail, immutable snapshots under refusal/disconnection/post-handoff
      fault injection, and no failure import by `GiftUICapabilities`.
- [ ] `T4.3` — After SPEC-009 and SPEC-014 provide the production one-shot
      stream and first-party tiled paths, integrate capability inputs and
      consumers without rerunning resolution. Prove each tiled path consumes
      the borrowed operation stream once synchronously, retains only bounded
      backend-owned derived payload, and expresses runtime faults only through
      SPEC-003-owned seams.
- [ ] `T4.4` — After SPEC-015 provides the host composition/start gate, join
      RFC-002 B2 validation and SPEC-004 resolution as independent conjunctive
      gates. Prove valid-B2/capability-negative and B2-negative/capability-valid
      controls, no partial snapshot, one resolution before first cycle, and no
      later resolution or live snapshot mutation.
- [ ] `T4.5` — Refresh the exact package allow-list, positive/negative imports,
      compiled module dependencies, product linkage, and portable-source scans
      after every owner adapter lands. Fail upward imports, re-export, concrete
      identity, duplicated resolution, and any correctness dependency on
      tooling or diagnostics.

### Milestone 5: Produce Four-Profile and Bounded-Resource Evidence

**Entry conditions:** Milestones 1-3 are complete; every available Milestone 4
adapter has an exact disposition; the pinned macOS/Pi/nRF toolchains and
hardware-free probes pass.

**Exit evidence:** All four exact commands produce repeatable semantic,
allocation, operation-count, layout, section, stack, and code reports labeled
as host or hardware-free cross-build evidence.

- [ ] `T5.1` — Compile and run/cross-build the same normalized corpus with the
      exact profile compilers and optimization modes. Verify Raspberry Pi
      `armv6-unknown-linux-gnueabihf` and nRF52840 Cortex-M4F hard-float/VFP
      ABI. Do not substitute architectures, mutate global toolchains, access a
      remote, deploy, or flash.
- [ ] `T5.2` — Instrument the static path for zero heap allocation from
      contribution construction through repeated snapshot access. Record
      operation/invocation counts for every success and negative path and
      compare complete static/dynamic semantic transcripts.
- [ ] `T5.3` — Report size/stride/alignment for every named capability record
      on supported 32-bit and 64-bit compilers; enforce all per-record ceilings.
      Report total and incremental nRF linked RAM, named fixed capability
      storage, default display staging, worst-case resolver stack, linked
      flash, initialization work, and aggregate/device warning thresholds
      separately.
- [ ] `T5.4` — Build two pristine matched nRF baseline/candidate pairs from one
      revision using the exact SPEC-004 source-list and configuration rules.
      Record compiler/linker arguments, hashes, load-segment accounting, maps,
      named symbols, disassembly, and a complete resolved call graph. Enforce
      capability deltas of at most 768 bytes RAM, 512 bytes named storage,
      256 bytes resolver stack, and 8 KiB flash; fail unequal inputs,
      unresolved indirect calls, non-repeatable metrics, or non-identical ELF
      hashes across pristine rebuilds.

### Milestone 6: Complete Integration Evidence and Prepare Conformance Review

**Entry conditions:** Hardware-free evidence passes and the owning Wave 1/host
plans have supplied the production integration seams required by Milestone 4.

**Exit evidence:** Every acceptance criterion has reproducible evidence or an
explicit upstream blocker, and a SPEC-004 conformance report is ready for
independent review.

- [ ] `T6.1` — Audit the manifest, Specification/plan link, reciprocal
      SPEC-002/003 declarations, package edges, adapter ownership, exact
      one-family catalogue, B2/capability gate independence, snapshot
      immutability, and all deferred-work boundaries. Update navigation only;
      do not change contract meaning.
- [ ] `T6.2` — Run the complete top-level hardware-free matrix and preserve
      exact standalone commands and stable evidence links. Label host execution,
      Pi/nRF cross-build/inspection, simulator, and any separately authorized
      connected-hardware evidence without promoting one category into another.
- [ ] `T6.3` — Create `docs/conformance/spec-004-conformance.md`, link the
      stable reports, record every `CR` row and upstream disposition, and hand
      the result to conformance review. Do not mark SPEC-004 `implemented`
      without complete evidence and explicit maintainer authorization.

## Design-Note Triggers

- Create `docs/implementation-designs/spec-004-role-addressed-resolution.md`
  if the four-slot duplicate semantics, two-candidate workspace, canonical
  evaluation order, or reusable caller-owned storage cannot be reconstructed
  directly from the resolver and focused tests.
- Create `docs/implementation-designs/spec-004-resource-evidence-driver.md` if
  matched-image load-segment accounting, symbol classification, call-graph
  resolution, or conservative stack summation becomes non-local or difficult
  to reproduce from the driver README.
- Create a focused one-shot tiled-consumption note only if SPEC-014 integration
  requires non-obvious ownership or lifetime machinery. It must not introduce
  replayable GiftUI operations or another stream lifetime.
- The existing
  [checked raster-arithmetic design note](../implementation-designs/spec-004-raster-arithmetic.md)
  records the fixed-width representability proof and corrected arithmetic
  direction. Keep it current while `T2.1` uses that non-local mechanism.
- Do not create another note merely to catalogue finite enums, fixed records,
  arithmetic formulas, or local failable initializers.

## Integration and Validation Order

1. Preserve the maintainer's explicit approval of the corrected SPEC-004
   arithmetic contract and complete the authorized implementation iteration
   above without claiming the complete resolver.
2. Preserve completed SPEC-003 work and leave its capability, execution, and
   host adapters dependency-blocked until their owning declarations exist.
3. Continue Milestone 2 in dependency order through compatibility, resolver
   orchestration, precedence, and bounded-work instrumentation, with no
   runtime, backend, failure, host, or connected-hardware dependency.
4. Prove all normalized profiles, formula/precedence corpora, one-shot lease
   behavior, zero allocation, and bounded operation counts through pure seams.
5. Integrate SPEC-002 extent and SPEC-003 outcome adapters only at downstream
   boundaries that import both owners; retain their exact reciprocal tests.
6. Integrate SPEC-009/SPEC-014 one-shot consumers and SPEC-015 conjunctive
   startup only after their owner targets exist. Never create placeholder
   owner contracts inside `GiftUICapabilities`.
7. Run macOS dynamic/static evidence, then Raspberry Pi ARMv6 and nRF hardware-
   free cross-build/inspection, matched images, and conformance collection.
8. Connected hardware is not required by a SPEC-004 criterion. Do not deploy,
   restart a remote service, or flash an nRF52840-DK under this plan unless a
   separate user request explicitly authorizes that change.

## Risks and Upstream Blockers

### Upstream blockers

- The exact SPEC-003 required-family outcome carrier and operational fault
  seam depend on the active failure implementation. The pure
  `GiftUICapabilities` resolver must not import failure or wait for it.
- Production one-shot tiled consumption and post-handoff fault evidence depend
  on SPEC-009 and SPEC-014 owner targets. SPIKE-001 proves feasibility but
  cannot substitute for production integration evidence.
- The independent B2/capability startup-gate integration depends on SPEC-015.
  Pure independent-negative fixtures may be built earlier, but the plan must
  not invent a host assembly API.
- If any accepted owner changes operation-stream lifetime, extent meaning,
  failure ownership, contribution fields, or startup sequencing, pause the
  affected task and route the conflict to the owning Specification/RFC/ADR.
- Any breach of a frozen layout, allocation, operation-count, RAM, stack, or
  flash ceiling requires a conforming representation reduction or renewed
  Specification review; this plan cannot grant an exception.

### Implementation risks

- The large closed declaration set can hide accidental invalid states. Keep
  failable construction tests separate from typed resolver tests and generate
  unknown option-bit and boundary-value corpora from the fixed raw widths.
- Contribution and candidate order can leak through first-value preservation,
  optional alternate storage, or policy preference. Compare all role
  permutations and both candidate orders by value, including simultaneous
  failures.
- Checked LCM and row arithmetic must preserve their proven representable
  maxima, while the shared row-by-region multiplication can overflow before a
  capacity comparison. Preserve the exact operation order and `.raster`
  assignment; do not use wrap, saturation, zero substitution, wider private
  fixtures, or a smaller tile to evade a ceiling.
- A generic collection, diagnostic string, or convenience closure can violate
  static allocation and representation bounds. Keep human-readable reports in
  downstream tooling and make the allocator-free fixture link the complete
  production path observably.
- Dead stripping or unlike baseline/candidate support can understate nRF cost.
  Make every required path observable, compare identical support and linker
  configuration, report signed deltas, and preserve maps/disassembly.
- Adding capability targets can invalidate the active SPEC-002/003 exact graph.
  Update exact manifests and compiled dependency evidence atomically; do not
  overwrite or discard the user's in-progress failure-core changes.

## Deferred and Follow-up Work

- [FW-006](../future-work/fw-006-generated-target-configuration.md) remains
  outside MVP until repeated static-host composition or measured resource cost
  triggers lifecycle re-evaluation; no generator is planned here.
- [FW-007](../future-work/fw-007-cost-aware-capability-planning.md) and
  [FW-008](../future-work/fw-008-generalized-component-traits.md) remain
  speculative generalization. MVP retains explicit bounded policy and one
  closed typed family.
- [FW-014](../future-work/fw-014-replayable-operation-delivery.md) remains
  outside the one-shot MVP contract; no retained/replayable operation mode may
  enter an implementation task.
- [FW-015](../future-work/fw-015-capability-resolver-input-minimization.md)
  remains an optional later optimization and cannot remove an approved field
  or negative fixture.
- [FW-018](../future-work/fw-018-live-surface-reconfiguration.md) remains
  post-MVP. One runtime has one immutable snapshot; changed extent or
  orientation requires reconstruction.
- SPIKE-001 and SPIKE-002 remain feasibility evidence only. Production types,
  algorithms, layouts, and code require ordinary implementation and tests
  under this plan.

## Completion Record

Draft created on 2026-08-29 after lifecycle triage found that the next
executable implementation iteration remains within active SPEC-003, while
SPEC-004 is the next distinct approved contract whose foundational target
unblocks both active SPEC-002 and later SPEC-003 integration. The maintainer
marked this plan `ready` on 2026-08-29. This derived-plan transition makes the
ordered work executable but does not change SPEC-004 from `approved`, start
implementation, or authorize work owned by another Specification.
`T0.1` is complete: the checked-in
[authority audit](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-0/authority-audit.md)
verifies the complete accepted/approved chain, reciprocal SPEC-002/003 and
manifest relationships, and all 17 acceptance labels. The
[fixture contract](../../Tests/ContractFixtures/SPEC004/README.md) establishes
the ordered compile registry, normalized corpus and raw-adapter boundary,
matched resource roots, deterministic generated/report paths, and precise
host/cross-build/connected-target evidence labels without starting production
implementation.
`T0.2` is complete: implementation began with an empty importable
`GiftUICapabilities` leaf and focused test target, transitioning SPEC-004 to
`implementing`, this plan to `active`, and the manifest feature to
`implementation`. The SPEC-002 exact target graph and the SPEC-004 boundary
fixture record the new dependency-free leaf without changing any existing
failure or diagnostic edge; see the
[leaf evidence](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-0/capability-leaf.md).
`T0.3` is complete: the registered
[four-profile contract driver](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-0/contract-driver.md)
fails closed on profile, compiler, target, SDK, board, optimization, pin,
source-list, package-graph, and emitted-image mismatches. Each standalone run
records revision/dirty state, complete commands, compiler identity and hash,
input/image hashes, deterministic roots and exit, and an explicit absence of
remote access, deployment, service restart, and flashing. `T0.4` is next.
`T0.4` is complete: the ordered
[capability boundary evidence](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-0/capability-boundary.md)
contains one positive capability import and negative fixtures for every
forbidden module. Source, emitted interfaces, compiler dependency scans,
product links, exact package edges, cycle regressions, `GiftUI` non-re-export,
and the portable Signal Analyzer identity scan all fail closed. `T0.5` is
next.
`T0.5` is complete at clean revision
`66921422be8f97aad2de47f3b03fb6b0045a0630`. The checked-in
[Milestone 0 readiness transcript](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-0/harness-readiness.md)
records the exact graph and boundary checks, 15 compile fixtures, four clean
portable presentation sources, one focused capability test, 70 root tests,
the standalone macOS-dynamic driver, and every registered no-argument gate.
Milestone 0 is complete; `T1.1` is next.
`T1.1` is complete: the
[closed-vocabulary evidence](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-1/closed-vocabulary.md)
records 26 exact public types, the single `rasterPresentation` catalogue field,
all raw bits/tags, failable structural invariants, zero-valid byte ceilings,
bounded unavailable payloads, record ceilings, and value/Sendable behavior.
The same production source compiles in all four exact hardware-free profiles;
`T1.2` is next.
`T1.2` is complete: the
[fixed contribution-storage evidence](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-1/fixed-contribution-storage.md)
records the four inline role slots, duplicate-mask and order-independent
equality rules, deterministic lowest-role duplicate/missing selection, exact
two-slot workspace with usable capacities `0...2`, reset/reuse behavior, and
the 192-byte/96-byte layout ceilings. The emitted-interface audit now covers
all 30 public types and the exact T1.2 signatures; `T1.3` is next.
`T1.3` is complete: the
[malformed adapter-boundary evidence](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-1/malformed-adapter-boundary.md)
records exhaustive failable-constructor cases and a test-only downstream
adapter importing both SPEC-002 portable geometry and SPEC-004 capabilities.
It distinguishes zero extent from positive `UInt16` overflow, applies raw
requirement stages and contributor role/field precedence, preserves all eleven
malformed fields for all four roles, and leaves the production capability leaf
dependency-free. `T1.4` is next.
`T1.4` is complete: the
[bounded value-audit evidence](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-1/bounded-value-audits.md)
records source/interface/binary exclusions, checked failing audit fixtures,
zero measured allocations across 10,000 optimized construction iterations,
and all ten early 64-bit layout ceilings in both macOS profiles. The same
fixed-value source cross-builds for ARMv6 and nRF52840; complete 32-bit and
linked-resource reports remain assigned to `T5.3`. Milestone 1 is complete;
`T2.1` is next.
The [checked raster-arithmetic design note](../implementation-designs/spec-004-raster-arithmetic.md)
records the fixed-width proof that resolved the `T2.1` contract conflict.
SPEC-004 now requires maximum-bound non-overflow proofs, assigns the one
constructible shared-usage overflow to `.raster`, and excludes manufactured
payload-only/in-flight arithmetic overflow. The maintainer explicitly
reapproved that correction.
The 2026-08-30 planning review marked the `T2.1` iteration `ready` after adding
explicit coverage for all nine capacity-ceiling owners, maximum typed
representability, single shared-usage overflow, allocation-free helper
execution, all four hardware-free profile commands, stable corpus IDs, and
parallel-safe coordination with SPEC-003 `T4.2`. This readiness record does not
by itself accept implementation evidence.
`T2.1` is complete: the internal fixed-width arithmetic seam performs checked
LCM, row round-up, deterministic region selection, one shared usage
multiplication, and ordered three-owner capacity minima without allocation or
public-surface changes. Twenty-one focused capability tests pass, and both
macOS drivers record the 22-case normalized transcript in
`Tests/ContractFixtures/SPEC004/SemanticCorpus/cases.tsv`, including both
encodings, full/tiled geometry, exact nRF usage, maximum typed boundaries,
shared `.raster` overflow, every region limit, and all nine capacity owners at
equality and first excess. The allocation probe reports zero allocations while
executing the seam; both macOS profiles and the hardware-free ARMv6 and nRF
drivers pass. The maintainer explicitly reapproved the validation-only
operation-stream correction; `T2.2` is the next executable task.
`T2.2` is complete: the validation-only operation-stream fact has exact raw
value `2`, requirements reject it, producer/candidate compatibility maps it to
`.operationStreamMismatch`, and no available path can contain it. The bounded
candidate evaluator preserves geometry, operation, stream, encoding,
lifetime, handoff, arithmetic/capacity, and policy separation; covers the
complete five-admitted/one-rejected lifetime-handoff matrix; selects encoding,
lifetime, handoff, and realization preferences deterministically; and applies
policy only after technical conformance. Twenty-seven focused capability tests
and all four hardware-free SPEC-004 drivers pass, with zero allocations while
the optimized probe executes compatibility. `T2.3` is next.
`T2.3` is complete: the exact public `RasterPresentationResolver.resolve`
entry point validates duplicate/missing roles and workspace before semantic
evaluation, canonicalizes one or two candidates by realization raw value,
selects by complete-path preference, constructs the immutable effective value
only on success, and resets caller-owned workspace on every return. Positive
and stream-mismatch fixtures are value-equal across all 24 role permutations;
reversed candidate declarations resolve identically; missing, duplicate, and
workspace failures short-circuit; and optional absence produces a nil snapshot
while required failure blocks snapshot construction. All 105 package tests,
the 24-row normalized semantic transcript, zero-allocation macOS probes, and
all four hardware-free SPEC-004 drivers pass. `T2.4` is next.
`T2.4` is complete: the fixed selector covers all 120 unordered pairs across
the exact 16 precedence stages in both argument orders, including the distinct
producer/candidate operation and stream positions, and separately covers all
55 candidate-specific reason pairs in both orders. Concrete resolver fixtures
prove duplicate/missing and producer operation/stream short-circuiting,
primary/alternate order independence, the corrected shared overflow over zero
capacity, and raster before payload/in-flight capacity. Raw malformed adapter
coverage remains separate in the T1.3 corpus. Thirty-seven focused capability
tests, the 26-row normalized transcript, and all four hardware-free SPEC-004
drivers pass. `T2.5` is next.
`T2.5` is complete: compile-conditional fixed-width counters cover resolver
invocations, four role visits, set operations, checked arithmetic, candidate
checks, and validation-result construction at their actual decision points.
The widest two-candidate/two-encoding path records 44 primitive operations,
which bounds every success and later negative exit below the 96-operation
ceiling; the early producer-stream negative records 8. Ten thousand repeated
snapshot reads record zero resolver invocations and zero primitive operations.
The production macOS image check rejects instrumentation symbols, while the Pi
and nRF production modules compile without the instrumentation flag. The
29-row normalized transcript, zero-allocation macOS probes, and all four
hardware-free SPEC-004 drivers pass. Milestone 2 is complete and `T3.1` is
next.
`T3.1` is complete: pure normalized fixtures assert every admitted field for
macOS dynamic, macOS static, PiScreen, and nRF52840 TFT. The two macOS fixtures
are value-identical full-surface RGBA8888 results; Pi resolves a 240-by-16
RGB565 tile using 7,680 bytes; nRF resolves a 480-by-4 RGB565 tile using
exactly 3,840 raster, payload, and in-flight bytes; and the nRF full-surface
RGBA8888 control is unavailable with the exact raster-capacity reason. The
fixture-to-field report records each requirement, contribution, policy, and
effective-result assertion. The 34-row normalized transcript and all four
hardware-free SPEC-004 drivers pass. `T3.2` is next.
`T3.2` is complete: an independently rebuilt, fixed three-operation lease
fixture covers all six submission-lifetime/handoff pairs. Five conforming
pairs traverse the stream exactly once and derive three bounded bytes; queued
synchronous borrow is rejected before traversal. Synchronous copy and
ownership transfer complete into endpoint-owned fixed payload storage while
the borrow remains active, synchronous borrow retains no payload, post-return
poisoning rejects access, replay is rejected, and no operation is retained.
Independent encoding and lifetime negative/control pairs retain distinct
stable reasons. The fixture is contract-only and copies no SPIKE-001 or
unimplemented SPEC-009/SPEC-014 production shape. The 37-row normalized
transcript and all four hardware-free SPEC-004 drivers pass. `T3.3` is next.
`T3.3` is complete: the consolidated negative/control evidence covers missing
and duplicate roles, all raw malformed fields and role/field precedence,
SPEC-002 extent overflow, optional and required absence, resolver workspace,
unsupported geometry, policy exclusion, shared arithmetic overflow, and every
owner of every capacity minimum. Normalized rows prove required failures
produce no snapshot, optional absence produces only a nil family, duplicate
insertion preserves the first value, and policy cannot weaken the result.
Typed values and dependency/binary checks keep results independent of
diagnostics. All 110 package tests, the 42-row normalized transcript,
zero-allocation macOS probes, and all four hardware-free SPEC-004 drivers pass.
`T3.4` is next.
`T3.4` is complete: both macOS profile reports record byte-for-byte equality
of the 42-row normalized transcript. The static zero-allocation loop now spans
fixed contribution insertion, caller-owned workspace resolution,
validation-result handling, snapshot construction/storage, and repeated
snapshot access. It records zero allocations while bounded layout evidence
reports 96-byte contribution stride, 52-byte workspace, 40-byte effective
value, and 40-byte snapshot; the production image contains no instrumentation.
All four hardware-free SPEC-004 drivers pass. Milestone 3 is complete; `T4.1`
is next, subject to its owning Specification entry conditions.
`T4.1` is complete at the approved test-only downstream owner boundary. Its
exact adapter accepts positive `UInt16`-representable `Size` dimensions,
classifies zero as malformed requirement extent, classifies positive overflow
as logical extent overflow, and cannot receive negative dimensions because
SPEC-002 rejects them before adapter entry. Valid controls preserve the whole
extent. The exact package graph keeps both production leaves dependency-free,
and compile/binary checks preserve reciprocal non-import and non-re-export
evidence without moving geometry. Four focused adapter tests and the SPEC-002
macOS dynamic graph gate pass. `T4.2` is next.
