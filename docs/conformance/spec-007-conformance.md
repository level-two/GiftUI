---
spec: SPEC-007
feature: giftui-mvp-architecture
title: SPEC-007 Conformance Report
status: collecting
reviewers:
  - codex
created: 2026-09-11
updated: 2026-09-11
implementation_plan: ../implementation-plans/spec-007-implementation-plan.md
related_future_work:
  - FW-001
  - FW-002
  - FW-005
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-007 Conformance Report

> This report records evidence. It does not itself authorize or perform the
> governing Specification's `implemented` transition.

## Review Scope

- Governing contract: [SPEC-007 Proposal-Based Layout Contract](../specs/spec-007-layout.md), status `implementing`.
- Completed plan: [SPEC-007 Implementation Plan](../implementation-plans/spec-007-implementation-plan.md).
- Design note: [bounded layout attempt](../implementation-designs/spec-007-bounded-layout-attempt.md), status `current`.
- Reviewed implementation revision: `c431b73a1df03590309515b967dd37cb847acf93`.
- Four-profile run: `c431b73a1df03590309515b967dd37cb847acf93-8e38137a10b2b531`.
- Environments: Apple Swift 6.3.3 macOS arm64 dynamic/static host execution;
  project-local Swift 6.3.2 ARMv6 and Embedded Swift/nRF52840 hardware-free
  cross-build and artifact inspection.

The accepted Proposal, RFC, and ADR authority chain remains unchanged.
SPEC-007 supplies the MVP Signal Analyzer's shared backend-free Rank 1 layout
and canonical text geometry without assuming runtime-profile, renderer,
platform, or hardware authority.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `LY-001` | pass | [checked geometry](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-4/checked-geometry.md), [four-profile gate](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-8/four-profile-gate.md) | Public declarations and preserved invalid payloads compile; validation and checked arithmetic reject them in the specified phase. |
| `LY-002` | pass | [semantic adapter](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-2/semantic-result-adapter.md), [borrow and dependency probes](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-2/borrow-allocation-dependencies.md) | The real SPEC-006 result is borrowed directly with exact flattening, identity, order, access, and no second graph. |
| `LY-003` | pass | [stacks](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-4/stacks-and-proxy.md), [spacers](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-4/flexible-spacers.md), [overlays and padding](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-4/overlay-and-padding.md), [frames](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-4/frames.md) | Proposal, underflow, alignment, remainder, padding/frame order, placement, and clipping goldens pass, including minimum/fixed 100 under parent 50. |
| `LY-004` | pass | [scalar decoding](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-5/scalar-decoding.md), [wrapping](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-5/wrapping-and-sizing.md), [positioning](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-5/positioned-text.md), [SPEC-005 goldens](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-5/reference-text-goldens.md) | Exact instances, glyphs, breaks, wrapping, bounds, baselines, advances, positions, and clips pass. |
| `LY-005` | pass | [preflight counters](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-3/preflight-counters.md), [atomic publication](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-3/atomic-publication.md), [combined corpus](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-6/combined-recording-corpus.md) | Limit, malformed input, overflow, lookup, reentry, refusal, reset/discard, ordering, and owner mapping are fail-closed and atomic. |
| `LY-006` | pass | [profile equivalence](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-6/profile-equivalence.md), [resource probes](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-7/resource-probes.md) | Recording, dynamic-slot, and fixed-enum views produce equal normalized output; static IR/SIL reports zero heap calls and lifetime probes retain no borrow. |
| `LY-007` | pass | [boundary audit](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-7/final-boundary-audit.md) | The package graph, direct dependency allow-list, import negatives, sibling separation, and reverse-edge exclusions pass. |
| `LY-008` | pass | [Signal Analyzer fixture](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-7/signal-analyzer-fixture.md) | Exact 512/64/4096/512/4096 limits pass with every admitted surface category and observed 24/5/10/2/9 high-water counts. |
| `LY-009` | pass | [four-profile gate](../../Tests/ContractFixtures/SPEC007/Evidence/milestone-8/four-profile-gate.md) | Four clean-revision reports contain target value layouts, finite workspace, stack, allocation, layout-image, graph, and nRF hard-float evidence with no hardware claim. |

## Required-Test Results

At reviewed revision `c431b73a1df03590309515b967dd37cb847acf93`,
all four exact standalone SPEC-007 commands passed under the common run ID
listed above. The standard `scripts/test.sh` macOS gate then passed governance,
formatter lint, the dependency/driver registries, 350 Swift tests, the
diagnostic-buffer probe, and every registered macOS-dynamic contract driver
from SPEC-002 through SPEC-010.

The focused layout target contributes 60 passing tests spanning declarations,
geometry, counters, workspace/sink lifecycle, semantic validation, stacks,
spacers, overlays, modifiers, frames, text, combined output, Signal Analyzer,
and three-profile semantic equivalence. The four report command transcripts
and hashed inputs/artifacts are retained under
`.build/contract-reports/spec-007/<run-id>/<profile>/`.

## Profile, Backend, and Platform Evidence

macOS dynamic and static provide behavioral host execution plus target
inspection for `arm64-apple-macosx26.0`. Raspberry Pi provides a static
cross-build for `armv6-unknown-linux-gnueabihf`. nRF provides an Embedded
Swift cross-build and ELF inspection for `armv7em-none-none-eabi`,
`nrf52840dk/nrf52840`, with ARMv7E-M and VFP-register argument attributes.

No backend is involved. Raspberry Pi and nRF evidence does not claim target
execution, display/input validation, remote access, deployment, service
restart, or flashing. All six such metadata flags are false in every report.

## Resource and Performance Evidence

Target IR gives identical values on all four configurations: primitive 9
bytes, modifier 32, limits 10, summary 28, error 1, and result 28, all within
their exact ceilings. The Signal-capacity finite workspace is 350,488 bytes
with equal size and stride. This is contract-fixture storage, not a production
host budget owned by SPEC-013.

The Signal fixture observes 24 scopes, 10 scalars, 2 lines, 9 glyphs, and five
simultaneous recursive layout frames. Traversal, measurement, placement, and
publication are bounded passes over scopes plus glyphs without a solver or
sibling sort. Static target IR and optimized macOS SIL report zero heap
allocation calls/instructions; nRF symbols contain no Swift allocation entry
point. The reports record the selected-target layout artifact contribution as
77,264 bytes for both macOS profiles, 77,200 for ARMv6, and 32,736 for nRF.

## Deviations and Exceptions

No implementation divergence, failed criterion, or approved exception was
found. The large approval-fixture workspace is explicitly not a production
runtime-profile budget, and hardware-free cross-builds are not represented as
connected-target evidence.

## Deferred Work Audit

FW-001, FW-002, and FW-005 remain linked, unpromoted, and outside the MVP
layout contract. Rich/international text, accessibility interaction geometry,
and alternative scalar models are not required to satisfy any current
criterion and conceal no correctness gap.

## Review Conclusion

All nine acceptance criteria have reproducible passing evidence, with no
deviation or exception. This collecting report supports requesting explicit
human conformance review and, if approved, a separate authorization for the
SPEC-007 `implemented` transition. It does not perform that transition.
