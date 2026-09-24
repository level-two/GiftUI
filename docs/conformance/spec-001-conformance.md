---
spec: SPEC-001
feature: signal-analyzer
title: SPEC-001 Conformance Report
status: complete
reviewers: [codex]
created: 2026-09-19
updated: 2026-09-24
implementation_plan: ../implementation-plans/spec-001-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-001 Conformance Report

> This report records evidence. It does not authorize the governing
> Specification's `implemented` transition.

## Review Scope

The review freezes [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md)
at pre-report SHA-256
`b68b72236c06ba4515acdfd9cb8d68c4d43f0b489a3a556d48b62adeb1bdbb4d`,
the active [implementation plan](../implementation-plans/spec-001-implementation-plan.md),
the current implementation design notes, and reviewed implementation revision
`b5b2640`. Evidence covers Apple Swift 6.3.3 host execution, project-local
Swift 6.3.2 ARMv6/nRF cross-build inspection, and host-native Pi/nRF semantic
fixtures. Connected PiScreen and nRF52840 TFT/input execution was not
authorized or collected.

The 2026-09-24 hardware-free follow-up is recorded at implementation revision
`da4a410d` under the current approved Spec SHA-256
`042e21d20ac320d998fa2f7b8cbdf603981692c2ab32ad3918f0e303d1bc50df`.
T6.7 and T6.8 now compose production target host loops. This update revises
the connected-gate descriptions below; it does not claim a connected run. The
registered SPEC-001 `nrf52840-embedded` gate passed at
`.build/contract-reports/spec-001/20260924T020406Z-13454/nrf52840-embedded/`
with zero failed checks.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `SA-AC-001` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md) | Authority, manifest, and reciprocal implementation links pass governance. |
| `SA-AC-002` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md) | Exact Domain/Data/Presentation/host direction is audited. |
| `SA-AC-003` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md) | Domain forbidden-import/facility scans pass. |
| `SA-AC-004` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md) | Presentation forbidden-import/facility scans pass. |
| `SA-AC-005` | blocked | [host structural gates](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/host-structural-gates.md), [Pi adapter](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/piscreen-platform-adapter.md), [nRF adapter](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/nrf52840-tft-input-adapter.md) | Semantic hierarchy and device adapters are complete; connected analyzer output on PiScreen and TFT is missing. |
| `SA-AC-006` | pass | [host structural gates](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/host-structural-gates.md) | One source identity and fixed hierarchy compile across all profiles. |
| `SA-AC-007` | pass | [repository corpus](../../Tests/ContractFixtures/SPEC001/repository-lifecycle-cases.tsv) | Current-value, replacement, detach, and bounded-return cases pass. |
| `SA-AC-008` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md), [integrated cycle](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/integrated-cycle.md) | Serialized delivery and distinct mutation domains pass without portable concurrency facilities. |
| `SA-AC-009` | pass | [repository corpus](../../Tests/ContractFixtures/SPEC001/repository-lifecycle-cases.tsv) | Complete action/state table passes. |
| `SA-AC-010` | pass | [capture publication corpus](../../Tests/ContractFixtures/SPEC001/capture-publication-cases.tsv) | Clear/rebase/state preservation passes. |
| `SA-AC-011` | pass | [sustained workload](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/sustained-workload-and-resources.md) | Exact 2,400-event logical workload has no loss or duplication. |
| `SA-AC-012` | pass | [sustained workload](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/sustained-workload-and-resources.md) | Static capture storage contains 2,404 transitions and four baselines. |
| `SA-AC-013` | pass | [retention corpus](../../Tests/ContractFixtures/SPEC001/retention-cases.tsv) | Oldest-first eviction and lower-bound levels pass. |
| `SA-AC-014` | pass | [retention corpus](../../Tests/ContractFixtures/SPEC001/retention-cases.tsv) | Stable ordering and invalid/out-of-horizon behavior pass. |
| `SA-AC-015` | pass | [source corpus](../../Tests/ContractFixtures/SPEC001/deterministic-source-cases.tsv) | Exact patterns, restart, cancellation, and teardown pass. |
| `SA-AC-016` | pass | [fact application](../../Tests/ContractFixtures/SPEC001/fact-application-cases.tsv), [integrated cycle](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/integrated-cycle.md) | Initial state, mutation-only changes, and synchronous reports pass. |
| `SA-AC-017` | pass | [control matrix](../../Tests/ContractFixtures/SPEC001/control-state-cases.tsv) | All control enabled/disabled states pass. |
| `SA-AC-018` | pass | [presentation values](../../Tests/ContractFixtures/SPEC001/presentation-value-cases.tsv) | Exact one/two/five-second ranges pass. |
| `SA-AC-019` | pass | [waveform corpus](../../Tests/ContractFixtures/SPEC001/waveform-drawing-cases.tsv) | Baselines, transition mapping, and right-edge extension pass. |
| `SA-AC-020` | pass | [waveform corpus](../../Tests/ContractFixtures/SPEC001/waveform-drawing-cases.tsv) | Ruler bytes and 11-plus-one grid pass. |
| `SA-AC-021` | pass | [sustained workload](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/sustained-workload-and-resources.md) | 120 consistent frames cover 2,400 events with coalescing. |
| `SA-AC-022` | pass | [driver suite](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/hardware-free-driver-suite.md) | Both macOS executables build, execute, and compare equal. |
| `SA-AC-023` | blocked | [four-preset evidence](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/raspberry-pi-armv6.md), [Pi adapter](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/piscreen-platform-adapter.md), [Pi host loop](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-pi-lifecycle-owner.md) | ARMv6 and host-native semantics pass. The production analyzer host loop now owns framebuffer/input devices; the earlier connected bounded display transfer did not exercise a physical control or the complete analyzer loop. |
| `SA-AC-024` | blocked | [four-preset evidence](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/nrf52840-static.md), [nRF adapter and host loop](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/nrf52840-tft-input-adapter.md) | The selected ILI9486/ADS7846 production firmware and exact-source native probe pass the hardware-free gate; no board was flashed or connected output/input measured. |
| `SA-AC-025` | blocked | [sustained workload](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/sustained-workload-and-resources.md), [nRF adapter and host loop](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/nrf52840-tft-input-adapter.md) | Production binary/RAM/storage/drawing fit is inspected; connected stack high-water, timing, and application execution remain missing. |
| `SA-AC-026` | pass | [source substitution](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/source-and-facility-substitution.md) | Conforming source replacement changes no portable owner. |
| `SA-AC-027` | pass | [source/facility evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/source-and-facility-substitution.md) | Every required facility fails closed before publication. |
| `SA-AC-028` | pass | [host structural gates](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/host-structural-gates.md) | Host lifecycle owns observation and adapter sinks. |
| `SA-AC-029` | pass | [sustained workload](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/sustained-workload-and-resources.md) | Exact 1/32/1 stores and first-excess corpus pass. |
| `SA-AC-030` | pass | [fact admission](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/static-fact-admission.md) | Nonzero sequence, merge order, sealing, and at-most-once application pass. |
| `SA-AC-031` | pass | [fact application](../../Tests/ContractFixtures/SPEC001/fact-application-cases.tsv) | Full replay and mismatch containment pass. |
| `SA-AC-032` | pass | [observable origin](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/observable-generation-origin.md) | One portable declaration preserves identity in both profiles. |
| `SA-AC-033` | pass | [observable origin](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/observable-generation-origin.md) | Replacement/removal/reinsertion lifecycle passes. |
| `SA-AC-034` | pass | [failure matrix](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/exhaustive-failure-matrix.md) | Every bounded observable failure has a deterministic nonaliasing disposition. |
| `SA-AC-035` | pass | [fact mutation/publication](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/fact-mutation-publication.md) | Twenty reports coalesce without fact or publication loss. |
| `SA-AC-036` | pass | [integrated cycle](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/integrated-cycle.md) | Button callback becomes a later fact; executor transcripts agree. |
| `SA-AC-037` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md) | Six qualified actions and total noncapturing handler pass all profiles. |
| `SA-AC-038` | pass | [action target access](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/action-model-target-access.md) | Replacement cancellation and failed-replacement preservation pass. |
| `SA-AC-039` | blocked | [nRF evidence](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/nrf52840-static.md) | Typed storage, ELF, RAM/flash/stack, and forbidden symbols pass; target mutation/publication/frame timing is not collected. |
| `SA-AC-040` | pass | [failure matrix](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/exhaustive-failure-matrix.md), [diagnostic matrix](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/diagnostic-profile-equivalence.md) | Exact normalization, effect order, policy, and diagnostic independence pass. |
| `SA-AC-041` | pass | [diagnostic matrix](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/diagnostic-profile-equivalence.md) | Complete bounded UTF-8 and projection corpus passes both profiles. |
| `SA-AC-042` | pass | [driver suite](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/hardware-free-driver-suite.md) | Both CH4 vectors compare equal in all four fixtures. |
| `SA-AC-043` | pass | [revision exhaustion](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/revision-exhaustion.md) | Transition and Clear boundaries quiesce without wrap or policy. |
| `SA-AC-044` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md) | Only normalized failure plus bounded diagnostic is representable. |
| `SA-AC-045` | pass | [sustained workload](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/sustained-workload-and-resources.md) | All manifests, limits, Drawing minima, extents, regions, bounds, and assembly values match. |

## Required-Test Results

On 2026-09-19, `scripts/test.sh --profile all-hardware-free` passed from
revision `b5b2640`: governance, formatter lint, root tests, static compiler
probes, and all 60 SPEC-001-through-SPEC-015 profile-driver combinations. The
machine report is `.build/test-reports/all-hardware-free/` with
`failure_count=0`. Standalone SPEC-001 invocations and 24-field normalized
comparison also pass; see the [driver-suite evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/hardware-free-driver-suite.md).

## Profile, Backend, and Platform Evidence

macOS Dynamic and Static are executable host evidence. Raspberry Pi includes
an exact ARMv6 hard-float cross-build, host-native Dynamic semantic fixture,
and supplemental connected adapter evidence: deployment without service
restart, validated framebuffer/input descriptors, and one bounded framebuffer
transfer. That transfer is not analyzer-host or physical-touch evidence.
nRF52840 remains ARMv7E-M/VFP hard-float ELF/resource inspection plus a
host-native Static semantic fixture; no board was flashed.

## Resource and Performance Evidence

All four fixtures execute 2,400 events over the exact 30-second logical range
and 120 frame opportunities, with equal workload checksums and exact 28/32/33
capacity boundaries. macOS records host execution. Pi/nRF runtime timing is
`not-collected`; cross-build reports record ABI, maps, symbols, workspaces,
RAM/flash, and supported stack evidence without inferring connected behavior.

## Deviations and Exceptions

No implementation divergence or approved exception was found. Five criteria
remain blocked only by missing connected evidence: `SA-AC-005`, `SA-AC-023`,
`SA-AC-024`, `SA-AC-025`, and `SA-AC-039`. These are requirements, not waived
exceptions.

## Deferred Work Audit

SPEC-001 originates no deferred item. FW-017, FW-019, and FW-021 remain
post-MVP extensions and are unnecessary for the fixed analyzer. No deferred
artifact conceals a current correctness or conformance requirement.

## Review Conclusion

Forty criteria pass and five have explicit connected-hardware blockers. The
hardware-free implementation and evidence boundary is complete, but this
report does not yet support requesting SPEC-001's `implemented` transition.
T8.1 through T8.3 remain open pending separate authorization and physical
PiScreen/nRF52840 display/input access. Human conformance review may proceed
with those gates visible.
