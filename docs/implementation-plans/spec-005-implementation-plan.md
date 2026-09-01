---
spec: SPEC-005
feature: giftui-mvp-architecture
title: SPEC-005 Implementation Plan
status: active
owners:
  - codex
created: 2026-08-30
updated: 2026-09-01
related_design_notes:
  - ../implementation-designs/spec-005-reference-package-generation.md
conformance_report: null
related_future_work:
  - FW-001
  - FW-002
  - FW-003
related_explorations: []
related_spikes:
  - SPIKE-005
supersedes: null
superseded_by: null
---

# SPEC-005 Implementation Plan

> This ready plan derives work from the approved Deterministic Text Resource
> Contract. It orders implementation and evidence but does not amend that
> contract, promote SPIKE-005 code into production, or authorize work owned by
> another Specification.

## Authority and Scope

The governing contract is approved
[SPEC-005](../specs/spec-005-text-resources.md). Its authority chain is
accepted
[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md),
approved [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md),
[RFC-003](../rfcs/rfc-003-deterministic-text-rendering-architecture.md),
[RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md), and
[RFC-005](../rfcs/rfc-005-failure-diagnostics-propagation.md), and accepted
[ADR-005](../adrs/adr-005-semantic-layout-render-boundary.md),
[ADR-006](../adrs/adr-006-shared-semantics-runtime-profiles.md),
[ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md),
[ADR-009](../adrs/adr-009-checked-integer-geometry.md),
[ADR-010](../adrs/adr-010-synchronous-one-shot-frame-handoff.md), and
[ADR-021](../adrs/adr-021-canonical-text-geometry.md) through
[ADR-023](../adrs/adr-023-exact-font-resource-identity.md).

The approved [SPEC-002](../specs/spec-002-portable-foundation.md) supplies the
portable checked `Int32` geometry used by this work. Approved
[SPEC-003](../specs/spec-003-failure-outcomes-and-containment.md) exclusively
owns cross-layer failure facts and outcomes; `GiftUITextResources` therefore
returns only its local validation vocabulary. Layout, positioned-glyph
rendering, backend integration, and production host composition remain owned
by SPEC-007, SPEC-008, SPEC-014, and SPEC-015 respectively.

The [MVP Scope](../MVP_SCOPE.md) and approved
[SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md) require
deterministic titles, subtitles, channel names, levels, status, controls,
visible-window values, and bounded error text in one substantially shared
Signal Analyzer presentation. Equal logical glyph selection and geometry must
survive macOS dynamic, macOS static, Raspberry Pi 1/Linux dynamic, and
nRF52840 static configurations even though the selected exact bitmap or
outline realization may differ. SPEC-005 is therefore Wave 2 MVP work needed
for the text, layout, rendering, backend, and host stack; it is not a general
typography platform.

The complete contract-local implementation and hardware-free suite may proceed
independently after Milestone 0. Production adapters that require layout,
render, backend, or host owner modules remain blocked until the corresponding
approved Specifications have created those modules; test-only owner adapters
must prove the already approved mappings without inventing those production
contracts.

## Current Repository State

- `Package.swift` currently exposes `GiftUI`, `GiftUIFailureCore`,
  `GiftUIFailureDiagnostics`, and `GiftUICapabilities`. There is no
  `GiftUITextResources` target, standalone product, focused unit-test target,
  concrete reference-resource target, layout target, render-core target,
  backend target, or host-composition target.
- `Sources/GiftUI/GiftUI.swift` contains SPEC-002's `GeometryScalar`, `Point`,
  `Size`, `Rect`, and package-visible checked `GeometryArithmetic`. The new
  text-resource leaf must depend only on this target and must not cause
  `GiftUI` to import or re-export text-resource SPI.
- SPEC-002 established the fail-closed target allow-list, package-graph and
  cycle checks, positive/negative compile-fixture convention, deterministic
  contract-report roots, and explicit contract-driver registry. SPEC-003 and
  SPEC-004 extended the same harness without relaxing it.
- `scripts/test.sh` is the single top-level gate. Its default is the fast
  `macos-dynamic` profile; the other three profiles and
  `all-hardware-free` are explicit selections. A SPEC-005 driver must retain
  its four standalone commands and must not deploy, access a remote target,
  restart a service, or flash hardware.
- [SPIKE-005](../spikes/spike-005-inter-reference-font-resource.md) preserves
  the adopted Inter 4.1 source, OFL 1.1 text, exact derived bytes, provenance,
  hashes, disposable generator and C validator, and hardware-free nRF52840
  calibration. Its canonical manifest and payload bytes are normative inputs
  because SPEC-005 adopts their exact identities; its Python/C implementation
  and target organization remain non-authoritative evidence.
- The adopted reference evidence contains one instance, 96 mappings, 102
  glyphs, a 6,218-byte canonical manifest, a 1,911-byte bitmap payload, and a
  13,195-byte outline payload under resource identity
  `bd14de9ff2baaaf464c130d5e2d0554004a4055cc57a8c16a65fe2cc39394910`.
  No production Swift tables or target-specific payload-subset packages exist.
- The repository-managed Raspberry Pi workflow pins Swift 6.3.2 and
  `armv6-unknown-linux-gnueabihf`. The nRF workflow pins Swift 6.3.2, Zephyr
  4.3.0, SDK 0.17.4, `nrf52840dk/nrf52840`, and
  `armv7em-none-none-eabi` with Zephyr's Cortex-M4F hard-float flags. Existing
  doctor/probe scripts validate those environments, but no SPEC-005 Swift
  cross-build, allocation, layout, symbol-omission, or resource report exists.
- SPEC-002 and SPEC-003 are implementing, and SPEC-004 has active work. Their
  present sources and graph checks are shared repository state; SPEC-005 work
  must preserve unrelated in-progress changes and update exact-set controls
  atomically when its own targets are introduced.

## Readiness Review

**Reviewed:** 2026-08-30

**Disposition:** Ready. The approved authority chain is intact, every
acceptance criterion maps to ordered implementation and evidence, all
contract-local work can begin without inventing architecture, and downstream
layout/render/backend/host dependencies are explicit. No RFC, ADR, or
Specification amendment is required by this review.

The review made previously implicit requirements executable by adding the
complete count/byte boundary matrix, canonical-manifest exclusion invariants,
throwing-body `withPayload` behavior, exact bitmap and outline encoding
coverage, and validated-package assembly/teardown lifetime evidence. FW-001
through FW-003 remain captured and untriggered; SPIKE-005 remains completed
non-authoritative evidence. The plan remains `ready`, while SPEC-005 remains
`approved` until implementation actually starts.

## Acceptance-Criterion Matrix

The criterion text remains authoritative in SPEC-005. Every criterion appears
once below and maps to implementation tasks and reproducible evidence.

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `TR-001` — Approval, manifest, authority, reciprocal Specification/Spike/Future Work traceability | `T0.1`, `T6.1` | Governance and reciprocal-link audit | pending |
| `TR-002` — Exact module graph and zero parallel or translated text-resource identities | `T0.2`, `T0.4`, `T4.4`, `T6.2` | Package graph, source/interface/binary scans, compile fixtures, downstream integration audit | pending |
| `TR-003` — Exact identity declarations, widths, serialization, SHA-256 inputs, counts, and identity-change behavior | `T1.1`, `T1.2`, `T1.5`, `T3.1`, `T5.1` | API/layout tests, canonical golden vectors, mutation corpus, four-profile digest transcripts | pending |
| `TR-004` — Licensed reference package, exact coverage, replacement glyph, build validation, and target-selected assembly validity | `T0.5`, `T3.1`, `T3.2`, `T3.3`, `T3.4`, `T4.3`, `T5.1` | Provenance/hash audit, deterministic generation, complete-package and target-subset validation | pending |
| `TR-005` — Exact scalar and line-break mapping with package-only replacement and no ambient fallback | `T1.3`, `T2.4`, `T5.1` | Exhaustive scalar/control corpus and cross-profile normalized output | pending |
| `TR-006` — Equal metrics, selection, advances, ink geometry, and explicit points in all four profiles | `T1.3`, `T2.4`, `T4.2`, `T5.1` | Golden geometry corpus and value-for-value profile comparison | pending |
| `TR-007` — Exact deterministic local errors and SPEC-002/SPEC-003 owner mappings without partial results or diagnostics | `T2.1`, `T2.2`, `T4.1`, `T4.2`, `T5.1` | Independent/pairwise validation corpus, overflow fixtures, owner-adapter transcripts | pending |
| `TR-008` — Common catalogue/identity with target-specific payload availability and raster-independent logical results | `T2.3`, `T3.3`, `T4.3`, `T5.1`, `T5.3` | Complete, bitmap-only, and outline-only package transcripts plus link-map omission evidence | pending |
| `TR-009` — Exactly-once synchronous payload/offer traversal and no retained borrows | `T1.4`, `T4.2`, `T4.3`, `T5.2` | Invocation counters, poisoned-lifetime probes, allocation instrumentation | pending |
| `TR-010` — Zero static-path allocation, type/table limits, and bounded nRF bitmap-only resources | `T1.5`, `T2.5`, `T3.3`, `T5.2`, `T5.3` | Allocation traps, size/stride/alignment report, boundary corpus, ELF/map/stack and symbol reports | pending |
| `TR-011` — Four exact contract-driver commands reproduce required clean-checkout evidence without hardware claims | `T0.3`, `T5.1`, `T5.3`, `T5.4`, `T5.5`, `T6.3` | Registered standalone driver reports, resource timing, and two pristine normalized rebuilds | pending |
| `TR-012` — No out-of-scope text, layout, rendering, backend, cache, capability, host-policy, or deferred typography semantics | `T0.1`, `T6.2` | Public/package surface and non-goal audit | pending |
| `TR-013` — Complete baseline, line, ink, break, availability, and post-validation lookup rules with unchanged Foundation facts | `T1.3`, `T2.4`, `T4.1`, `T4.2`, `T4.3`, `T6.1` | Focused geometry/availability/failure corpus and contract-coverage audit | pending |

## Milestones and Tasks

### Milestone 0: Establish the Text-Resource Harness and Contract Leaf

**Entry conditions:** SPEC-005 remains `approved`; PROPOSAL-003 remains
`accepted`; all four linked RFCs remain `approved`; all eight linked ADRs
remain `accepted`; SPEC-002 and SPEC-003 remain approved authority; and the
existing exact package-graph and driver-registry checks pass without weakening
their treatment of in-progress targets.

**Exit evidence:** An empty importable `GiftUITextResources` target with its
exact dependency boundary and focused test harness exists; no standalone
text-resource product or `GiftUI` re-export exists; and a registered
four-profile driver can fail closed before semantic implementation begins.

- [x] `T0.1` — Audit SPEC-005's status, manifest registration, Proposal/RFC/ADR/
      Specification relationships, SPIKE-005 and FW-001 through FW-003 links,
      thirteen acceptance criteria, and non-goals. Create
      `Tests/ContractFixtures/SPEC005/` with an ordered fixture manifest,
      stable normalized-corpus schema, matched resource-harness roots,
      deterministic generated/report paths, and explicit host, cross-build,
      simulator, and connected-hardware evidence labels.
- [x] `T0.2` — Add the package-internal `GiftUITextResources` target and a
      focused unit-test target. The production target depends only on `GiftUI`;
      it exposes no standalone library product and imports no failure,
      capability, layout, render, runtime, backend, resource implementation,
      platform, driver, OS/RTOS, HAL, or hardware module. Update SPEC-002's
      exact target/dependency allow-list and graph fixtures atomically.
- [x] `T0.3` — Add
      `scripts/contracts/run-spec-005.sh --profile <profile>` for exactly
      `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
      `nrf52840-embedded`. Register it in
      `scripts/contracts/driver-registry.tsv`; fail closed on unknown profile,
      compiler/SDK/board/pin/optimization/source-list drift, missing fixtures,
      stale generated assets, and incomplete reports; preserve the standalone
      invocations when adding the driver to `scripts/test.sh` through the
      registry.
- [x] `T0.4` — Add positive package-SPI imports and negative fixtures for every
      prohibited upward import, a `GiftUI` non-re-export check, no-product
      inspection, exact source/compiled dependency checks, cycle detection,
      and scans rejecting parallel or translated resource, instance, glyph,
      and realization identities. Reserve downstream fixture rows for layout,
      render, raster, backend, platform, and concrete-package consumers so
      later targets fail closed rather than silently escaping the audit. Scan
      portable Presentation fixtures for text-resource, raster, backend,
      platform, device imports or target-conditional branches.
- [x] `T0.5` — Freeze the adopted SPIKE-005 inputs as a baseline evidence
      inventory: source and license, derivation pins, canonical manifest,
      bitmap and outline payloads, record tables, provenance, all SHA-256
      values, counts, and measured nRF calibration. Record which bytes and
      facts SPEC-005 adopts while explicitly classifying the spike generator,
      C validator, and firmware organization as disposable.

### Milestone 1: Implement Exact Values, Views, and Canonical Bytes

**Entry conditions:** Milestone 0's leaf, fixtures, driver, and adopted-input
inventory are complete. SPEC-002 geometry declarations and checked arithmetic
remain unchanged.

**Exit evidence:** Every normative SPEC-005 value and view declaration exists
with exact visibility, raw widths, optional-access semantics, canonical byte
order, finite bounds, and layout evidence, but no concrete package is admitted
until Milestone 2's validator is complete.

- [x] `T1.1` — Implement the exact package-visible identity, descriptor,
      metric, mapping, raster-record, validation-error/result, view-protocol,
      package, and validator declarations named by SPEC-005. Preserve raw
      values, initializer and field meaning, `Equatable`/`Hashable`/`Sendable`
      conformances, absence-as-optional semantics, and pointer/reference-free
      identity storage. Add declaration and raw-value surface checks.
- [x] `T1.2` — Implement one collection-free canonical serialization and
      digest seam using the exact schema-version-1 concatenation, big-endian
      unsigned fields, signed `Int32` geometry, digest word order, and exact
      SHA-256 byte interpretation. The seam must support build tooling and host
      validation without parsing a runtime file format or depending on host
      endianness or struct memory layout. Add official SHA-256 vectors,
      byte-for-byte SPEC-005 manifest vectors, and invariance fixtures proving
      filenames, timestamps, locale, table addresses, host byte order, display
      names, and raw payload bytes do not enter the manifest directly while
      every canonical field and payload digest does.
- [x] `T1.3` — Implement total metrics/mapping/raster accessor behavior:
      contiguous range and identity checks, valid-scalar classification,
      package replacement mapping, U+000A/U+000D `nil`, exact metrics, record
      lookup, availability, bitmap MSB-first interpretation, outline-record
      structural rules, and checked ink/advance geometry seams. Cover every
      scalar boundary, surrogate, printable ASCII scalar, U+00B0, unsupported
      valid scalar, CR, LF, and CRLF sequence behavior. Cover exact bitmap row
      width, padding bits, dimensions, checked byte count, and gap-free record
      partitioning, plus the `giftui-spike-outline-v1` version/header,
      big-endian operands, command arities, implied-point sentinel,
      close/end encoding, `Int16` coordinates, and no-trailing-byte rules.
- [x] `T1.4` — Implement `withPayload` with exact-zero/exact-once body
      invocation, exact buffer count, unavailable/invalid zero-invocation,
      body-only `rethrows`, a non-throwing static conformance path, and no
      allocation or retained borrow. Add lifetime instrumentation that poisons
      or invalidates test storage immediately after return and proves no
      escaped pointer or source remains usable. Prove a body-thrown sentinel is
      propagated unchanged after exactly one invocation and is never produced
      by validation or availability handling itself.
- [x] `T1.5` — Add compile-time/runtime size, stride, alignment, count, and
      boundary checks for every normative value and table ceiling. Exercise
      zero, one, maximum, and maximum plus one independently for instances,
      mappings, glyphs, realizations, canonical-manifest bytes, and payload
      bytes, including the valid zero-byte payload/empty partition case.
      Instrument mapping, metric, record, payload, and canonical-byte paths for
      zero static allocation and at most 256 comparisons per lookup. Record
      maximum comparison counts without selecting a cache or speculative index.

### Milestone 2: Implement Deterministic Complete-Package Validation

**Entry conditions:** Milestone 1 declarations and canonical-byte seam pass
their focused tests. No caller treats an initializer or accessor as package
admission.

**Exit evidence:** `TextResourceValidator.validate` is total, deterministic,
order-independent, validates the entire available package, returns the first
raw-value-precedence error, exposes no partial selected realization, and
allocates zero heap bytes on the static path.

- [x] `T2.1` — Implement validation as an explicit nine-class predicate pass in
      `TextResourceValidationError` raw-value precedence. It must enumerate
      declared instances, mappings, metrics, realizations, and records exactly;
      validate every applicable predicate; and choose the same first error
      independent of declaration/traversal order. Do not short-circuit earlier
      table traversal into a different precedence result.
- [x] `T2.2` — Add isolated positive/negative fixtures for every validation
      predicate and a generated pairwise simultaneous-error corpus with table
      and traversal permutations. Assert exact local result, no trap, no
      partial package/realization, no repair or substitution, and no diagnostic
      dependency. Include all mismatched identities, descriptors, ranges,
      digests, metrics, mappings, raster records, and malformed outline/bitmap
      encodings. Include controls proving a zero-byte payload with a valid
      empty record partition is admitted, while zero required counts and zero
      manifest bytes retain their exact `.invalidCount` meaning.
- [x] `T2.3` — Validate the complete common catalogue while admitting one
      required available realization: every catalogued record and descriptor,
      every metric/mapping, the reconstructed manifest, and every available
      payload must validate; an omitted unselected payload remains valid; an
      unavailable selected payload is exactly `.incompatibleViews`; and an
      availability claim whose bytes cannot be borrowed completely fails.
- [x] `T2.4` — Add golden behavior fixtures for baseline/ascent/descent/line
      gap, glyph offsets and ink rectangles, advances, explicit points,
      explicit line breaks, replacement mapping, post-validation lookups, and
      every checked-overflow site. Expected line-break `nil` and prevalidated
      invalid input must remain distinct from unexpected post-validation
      lookup failure.
- [x] `T2.5` — Run allocation traps, comparison counters, full-table visit
      counters, payload-byte visit counters, and validator call-frequency
      instrumentation. Prove validation visits every record and each available
      payload byte at most once per digest pass and is called only in build or
      structural-assembly fixtures, never per glyph or per frame.

### Milestone 3: Adopt the Licensed Concrete Reference Package

**Entry conditions:** Milestone 2 validates synthetic packages and reproduces
the adopted canonical hash. SPIKE-005 remains evidence only; production code
must be reviewed as a fresh implementation of SPEC-005.

**Exit evidence:** Reproducible production Swift tables and immutable concrete
package variants expose the exact adopted catalogue and target-specific
availability, validate against every exact adopted hash, and keep licensing
and derivation provenance intact.

- [x] `T3.1` — Implement a checked-in deterministic resource-generation/build-
      validation workflow from the adopted Inter 4.1 source and OFL evidence.
      Generate package-owned Swift metrics, mappings, descriptors, raster
      records, bitmap bytes, outline-fixture bytes, canonical byte count, and
      digests. Generate twice in clean temporary roots and fail on any byte,
      ordering, name, count, hash, tool-pin, source, or license drift. Do not
      copy the spike's disposable implementation without production review.
- [x] `T3.2` — Add one package-internal concrete reference-resource target
      whose immutable views conform to the contract without introducing
      parallel identities or importing upward modules. Build tooling must make
      both payloads available and validate the package once for each required
      realization before generated changes may pass the repository gate.
- [x] `T3.3` — Produce matched complete-catalogue, bitmap-only-linked, and
      outline-only-linked target compositions plus a one-realization synthetic
      package. All reference compositions retain identical descriptor/record/
      digest tables and `FontResourceID`; only payload availability and linked
      provider bytes may differ. The nRF composition selects bitmap, omits the
      outline payload and provider, and stores no unnecessary second manifest
      copy.
- [x] `T3.4` — Record source, license, derivative naming, attribution,
      derivation command, generated-file inventory, input/output hashes, and
      build-validation results in stable contract evidence. Keep legal claims
      scoped to reviewed engineering provenance rather than asserting legal
      advice.

### Milestone 4: Prove Borrowing and Exact Owner-Adapter Boundaries

**Entry conditions:** A validated reference package and synthetic negative
packages exist. SPEC-003's approved fact vocabulary is available. Missing
production layout/render/host modules are not filled with plan-defined APIs.

**Exit evidence:** Test-only downstream owners prove every exact SPEC-003 map,
Foundation facts remain unchanged, and synchronous payload/offer borrowing is
fully exercised without defining production render operations. Production
integration tasks have explicit downstream prerequisites.

- [ ] `T4.1` — Add test-only downstream owner adapters importing exactly the
      contracts each mapping needs. Fixture the three target-host assembly
      error families with `.hostComposition`/`.runtime`/`.contained`:
      schema/count/metrics/mapping/raster-record errors map to `.invalidValue`,
      identity/view/integrity errors map to `.invalidIdentity`, and capacity
      errors map to `.capacityExhausted`. Fixture the
      layout and render unexpected post-validation lookup failures with their
      exact `.invariantViolation` facts:
      `.layout`/`.candidateFrame`/`.safetyNotProven` and
      `.rendering`/`.candidateFrame`/`.safetyNotProven`. Preserve layout's
      SPEC-002 arithmetic fact exactly as
      `.arithmeticOverflow`/`.foundation`/`.operation`/`.contained`, and map
      render's required-realization loss exactly as
      `.requiredFacilityUnavailable`/`.rendering`/`.runtime`/`.contained`.
      Prove `GiftUITextResources` imports no failure vocabulary and diagnostics
      cannot change any result.
- [ ] `T4.2` — Add the required contract-local synchronous-offer adapter using
      only nominal `FontInstanceID`, `GlyphID`, and explicit `Point` data.
      Exercise nested resource/payload lookup during the offer; exact-once
      traversal; empty payload; invalid/unavailable zero invocation; and zero
      retained package pointer, payload pointer, test operation, or source
      after return. Do not define paint, clip, ordering, capacity, or the
      production positioned-glyph operation owned by SPEC-008.
- [ ] `T4.3` — Add a contract-local assembly/lifecycle fixture proving build
      validation sees both reference payloads and requires each realization in
      turn; target assembly sees its immutable linked subset and requires its
      one selected available realization before the first run cycle; no layout,
      render, raster, backend, or runtime consumer receives a package reference
      before success; descriptors, tables, records, and payloads remain
      immutable; nested borrows end synchronously; and host ownership lasts
      until the last simulated consumer tears down. Failed validation exposes
      no partial metrics or selected realization, while omission of an
      unselected payload remains valid catalogue unavailability rather than a
      partial package.
- [ ] `T4.4` — When SPEC-007, SPEC-008, SPEC-014, and SPEC-015 create their
      approved owner targets, integrate the exact nominal types and validated
      package without aliases or translation. Add the production host assembly
      validation/lifetime adapter, layout and render lookup adapters, exact
      raster-provider consumption, and backend/host dependency fixtures under
      those governing plans. This task cannot complete by inventing substitute
      modules here.

### Milestone 5: Reproduce Four-Profile and Static-Resource Evidence

**Entry conditions:** Milestones 1 through 4's independently executable tasks
pass on macOS dynamic. Repository-managed target toolchains pass their doctor
and hardware-free probe workflows; setup or repair remains a separate explicit
toolchain action when local generated state is absent.

**Exit evidence:** The four standalone driver commands reproduce equal logical
values and exact local errors, target-specific linked payload availability,
zero static allocation, bounded type/table/resource measurements, and clean
repeatability without deployment, flashing, or connected-hardware claims.

- [ ] `T5.1` — Run the identical normalized identity, digest, validation,
      mapping, metrics, geometry, owner-mapping, and availability corpus through
      macOS dynamic, macOS static, ARMv6, and nRF builds. Compare value-for-
      value outputs; permit only declared payload availability and raster
      coverage differences. Record compiler identity, target, flags, revision,
      dirty state, source/generator/table/manifest/payload hashes, required and
      available realization IDs, and maximum comparisons.
- [ ] `T5.2` — Measure every owned type's size/stride/alignment and allocation
      count for validation, mapping, metric/raster lookup, `withPayload`, and
      the contract-local offer. Static paths must link no allocator use caused
      by the text-resource implementation and must use no reflection, runtime
      discovery, Objective-C, `Task`, `MainActor`, unrestricted existential
      storage, or desktop concurrency.
- [ ] `T5.3` — Produce matched baseline/candidate optimized resource images and
      link maps. For nRF, record text-resource-specific incremental flash,
      fixed writable RAM, conservative validation stack and its measurement
      method, section/symbol data,
      ARMv7E-M and VFP hard-float evidence, and proof that outline bytes/provider
      are absent while the bitmap package meets the 96 KiB flash, 512-byte
      fixed-RAM, and 1 KiB stack ceilings. For ARMv6, retain the exact
      `armv6-unknown-linux-gnueabihf` identity and payload-omission evidence.
- [ ] `T5.4` — From two pristine temporary checkouts/build roots, run each exact
      standalone driver and compare normalized commands, hashes, semantic
      transcripts, allocation results, selected/available realizations,
      section measurements, and omission evidence. Then run the registered
      top-level default and `all-hardware-free` gates. Label every Pi/nRF result
      as cross-built hardware-free evidence; perform no remote access,
      deployment, service restart, or flashing.
- [ ] `T5.5` — Measure representative and maximum admitted resource lookup and
      borrow work independently from layout, rasterization, cache, and transfer
      timing. Record that the measured resource-only work fits within the
      250-millisecond presentation interval without claiming the downstream
      timing portions owned by later Specifications.

### Milestone 6: Complete Integration Traceability and Prepare Conformance

**Entry conditions:** All independently executable contract tasks and required
downstream integrations have recorded dispositions. No authoritative conflict
or unapproved exception remains hidden in implementation evidence.

**Exit evidence:** Every TR criterion has stable reproducible evidence or an
explicit upstream blocker, downstream nominal identities are audited, non-
goals remain absent, and the plan is ready to hand to SPEC-005 conformance
review without asserting the `implemented` transition.

- [ ] `T6.1` — Re-audit the thirteen criteria, authority/status chain,
      manifest, reciprocal Specification links, SPIKE-005/Future Work
      boundaries, exact hashes, owner mappings, and unchanged Foundation facts.
      Update task dispositions and evidence links; create the collecting
      conformance report only when implementation evidence exists.
- [ ] `T6.2` — Audit source, package interfaces, compiled modules, linked
      products, concrete packages, and every implemented downstream consumer
      for the exact dependency graph, nominal text-resource identities, no
      re-export/standalone product, and absence of public `Text`, layout,
      render-order, backend-raster, cache, capability, host-policy, or deferred
      typography additions. Route any contract or architecture mismatch
      upstream instead of normalizing it in this plan.
- [ ] `T6.3` — Run the complete registered hardware-free gate from a clean
      checkout and record any required platform exceptions separately.
      Conformance review, not plan completion, determines whether the evidence
      satisfies SPEC-005; a human maintainer still controls the
      `implemented` transition.

## Design-Note Triggers

- Create `docs/implementation-designs/spec-005-validation-pipeline.md` before
  implementing `T1.2`/`T2.1` if the canonical-byte emitter, SHA-256 state,
  precedence-wide predicate collection, or available-payload traversal cannot
  be reconstructed locally. The note may choose replaceable storage and data
  flow but must preserve exact bytes, precedence, bounds, and visit limits.
- Create `docs/implementation-designs/spec-005-reference-package-generation.md`
  before `T3.1` if production derivation, target-specific emitted Swift
  variants, or stale-output detection spans multiple tools and ownership
  boundaries. It must distinguish adopted outputs from disposable SPIKE-005
  mechanisms and cannot select a new asset, encoding, or identity.
- Create `docs/implementation-designs/spec-005-static-resource-layout.md` before
  `T5.3` if section placement, payload omission, validation stack accounting,
  or generic specialization needs maintained explanation. It cannot relax any
  flash/RAM/stack ceiling or substitute cross-build evidence for hardware.
- Do not require a design note for direct value declarations, table-driven
  unit tests, compile fixtures, or simple package-manifest edits.

## Integration and Validation Order

1. Establish the exact target/driver boundary and adopted-input audit before
   semantic source or generated production tables land.
2. Validate identities, canonical bytes, accessors, bounds, and lifetimes with
   synthetic unit fixtures before writing complete-package admission.
3. Complete the deterministic validator and its pairwise error-precedence
   corpus before admitting the reference package.
4. Reimplement and build-validate the adopted package from checked-in source;
   then prove complete, bitmap-only, and outline-only availability under one
   catalogue and identity.
5. Prove failure-owner mappings and one-shot borrowing through test-only
   downstream adapters. Integrate production adapters only after their owning
   Specifications have created authoritative modules and APIs.
6. Run focused macOS dynamic tests, macOS static allocation/layout checks, then
   ARMv6 and nRF hardware-free cross-builds. Compare normalized values only
   after every individual profile passes its local checks.
7. Run two pristine four-profile rebuilds, the default top-level gate, and the
   explicit all-hardware-free gate. Keep connected Raspberry Pi execution,
   display behavior, nRF execution, deployment, and flashing outside this
   independent contract suite and under later integration/conformance work.

## Risks and Upstream Blockers

- SPEC-002 is still implementing. Its approved geometry contract and present
  declarations are sufficient to start the leaf, but incomplete or changed
  Foundation evidence blocks final four-profile and reciprocal conformance; it
  does not authorize a duplicate geometry or arithmetic implementation.
- SPEC-007, SPEC-008, SPEC-014, and SPEC-015 have not created production
  layout, render, backend, or host targets. `T4.4`, the final downstream part
  of the module-graph criterion, and production-adapter evidence remain
  blocked on those governed implementations. Test-only adapters may prove
  mappings but may not become substitute architecture.
- The exact error-precedence rule requires knowledge of all applicable
  predicates. A validator that returns on first traversal failure can be
  order-dependent; if a bounded implementation cannot preserve precedence,
  pause and report a Specification feasibility defect.
- SHA-256 and canonical-byte validation must fit zero allocation and the nRF
  flash/stack ceilings. A measured miss requires upstream review or a
  conforming internal redesign, never skipped host validation or reliance on
  the disposable C validator as production authority.
- The package-access/no-standalone-product boundary needs compiler and link
  evidence across host and cross-built fixtures. If Swift package access or
  specialization changes the observable boundary on a pinned toolchain, treat
  that as a compatibility blocker rather than widening visibility.
- Production-generated assets must reproduce the already adopted identity.
  Any byte, mapping, metric, raster record, payload, tool-input, or license-
  relevant change creates a different resource and requires Specification
  review; the plan cannot bless a new digest.
- Type-layout and linked-section measurements vary by compiler and target.
  Exact ceilings apply on every supported pinned compiler, and desktop success
  cannot waive an ARMv6 or nRF violation.
- Cross-built Pi/nRF evidence proves compilation, linking, values, and static
  resources only. It cannot claim framebuffer output, PiScreen behavior, TFT
  output, runtime stack high-water, or connected-hardware timing.
- Any discovered need for complex shaping, bidi/vertical text, rich text,
  editing/accessibility geometry, extra instances, runtime registration,
  resampling, compression, generalized outlines, or shared caching remains in
  FW-001 through FW-003. It must not enter this plan's milestones.

## Deferred and Follow-up Work

- [FW-001](../future-work/fw-001-international-and-rich-text-layout.md)
  preserves international, complex-script, bidirectional/vertical, rich,
  variable, and color text work.
- [FW-002](../future-work/fw-002-text-interaction-and-accessibility-geometry.md)
  preserves selection, editing, carets, text hit testing, and accessibility
  geometry.
- [FW-003](../future-work/fw-003-advanced-font-delivery-and-glyph-rasterization.md)
  preserves additional instances, runtime registration, resampling, distance
  fields, compression, generalized outline delivery, and shared caches.
- [SPIKE-005](../spikes/spike-005-inter-reference-font-resource.md) remains the
  completed evidence source for adopted bytes and calibration. Its code is not
  a scheduled production implementation task.

No new deferred item was discovered while preparing this plan.

## Completion Record

Implementation began on 2026-08-31. The plan is `active` and SPEC-005 is
`implementing`; these are progress transitions and do not change the approved
contract or authorize the eventual `implemented` transition.

| Task | Disposition | Evidence |
| --- | --- | --- |
| `T0.1` | completed | [Authority and fixture audit](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-0/authority-audit.md), fixture README, ordered manifest, normalized-corpus schema, matched resource-harness roots, and evidence labels |
| `T0.2` | completed | [Text-resource contract leaf](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-0/contract-leaf.md), focused unit test, and updated exact package graph |
| `T0.3` | completed | [Four-profile contract driver](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-0/contract-driver.md), registry entry, fail-closed fixture/corpus/generated-asset checks, and deterministic reports |
| `T0.4` | completed | [Compiler-visible boundary evidence](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-0/compiler-boundaries.md), positive/negative compile fixtures, exact dependency/interface scans, reserved consumer rows, identity-owner scan, and portable Presentation scan |
| `T0.5` | completed | [Adopted SPIKE-005 input baseline](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-0/adopted-input-baseline.md), machine-checked inventory, exact hashes/counts/provenance, and nRF calibration |
| `T1.1` | completed | [Exact declarations and raw surface](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-1/exact-declarations.md), focused value/protocol tests, package-interface audit, and fail-closed validator seam |
| `T1.2` | completed | [Canonical serialization and SHA-256 seam](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-1/canonical-serialization.md), official hash vectors, exact schema-v1 byte vector, canonical-field mutation checks, exclusion invariants, and four-profile fixed-state compile evidence |
| `T1.3` | completed | [Total accessor and resource-format behavior](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-1/accessor-behavior.md), full reference scalar coverage, explicit-break classification, checked geometry, total identity/range lookups, exact bitmap interpretation, gap-free partitions, and outline-v1 grammar fixtures |
| `T1.4` | completed | [Exact payload borrowing](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-1/payload-borrowing.md), exact-zero/exact-once invocation fixtures, catalogue/range/availability rejection, body-sentinel propagation, nonthrowing conformance, and immediately poisoned test storage |
| `T1.5` | completed | [Layouts, ceilings, work, and allocation bounds](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-1/layout-capacity-and-work-bounds.md), 16-value target IR reports, independent zero/one/max/max-plus-one fixtures, empty partition, 256-comparison maximum, exact visit counters, and zero-allocation macOS dynamic/static probes |
| `T2.1` | completed | [Nine-class complete validator](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-2/validator-predicate-pass.md), valid synthetic package, raw-precedence conflict fixture, non-short-circuit traversal counters, complete catalogue/payload/manifest passes, and ordered predicate audit |
| `T2.2` | completed | [Isolated and pairwise validation corpus](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-2/validation-predicate-corpus.md), nine isolated classes, all 36 class pairs in both fault orders, complete identity/count/metric/mapping/raster/integrity subfixtures, malformed bitmap/outline cases, and zero-payload positive control |
| `T2.3` | completed | [Common catalogue and payload-subset admission](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-2/common-catalogue-admission.md), complete dual-payload validation, bitmap-only and outline-only linkage with identical identity/tables, unavailable-selected rejection, false availability rejection, omitted-record validation, and linked-unselected integrity enforcement |
| `T2.4` | completed | [Validated behavior goldens](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-2/validated-behavior.md), checked baseline/ascent/descent/line-gap geometry, explicit points and ink rectangles, advances, exact/replacement mappings, explicit break classification, post-validation lookup distinction, and every consumer geometry overflow site |
| `T2.5` | completed | [Validator work and allocation instrumentation](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-2/validator-instrumentation.md), zero-allocation optimized dynamic/static validator probes, exact comparison and full-table counters, once-per-digest payload-byte visits, and one assembly-time validator call across 256 frame lookups |
| `T3.1` | completed | [Deterministic production reference generation](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-3/reference-generation.md), [current generation design](../implementation-designs/spec-005-reference-package-generation.md), exact Inter/OFL inputs, hash-pinned tools, two fresh-root generation comparison, checked-in Swift catalogue/payloads, adopted identity reproduction, and registered fail-closed drift audit |
| `T3.2` | completed | [Concrete reference package](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-3/concrete-reference-package.md), exact package graph, immutable complete-catalogue views, record-local static payload borrowing, all-record grammar checks, and build validation returning `.valid` once for each required realization |
| `T3.3` | completed | [Matched payload-subset compositions](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-3/payload-subset-compositions.md), one common catalogue/identity, explicit complete/bitmap-only/outline-only source lists, exact availability and selection transcripts, nRF bitmap-only mapping, omitted-provider source evidence, and retained one-realization synthetic validation |
| `T3.4` | completed | [Provenance and build validation](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-3/provenance-and-build-validation.md), [machine-checked inventory](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-3/reference-provenance.tsv), source-side attribution, exact derivative naming and reproduction command, input/output hashes and sizes, and scoped engineering/license evidence |

Record every completed, changed, removed, and blocked task disposition here or
in a clearly linked iteration record; update any current design note in the
same change that invalidates it. Plan completion requires a disposition for
every task and a linked conformance report, but it does not mark SPEC-005
`implemented`.
