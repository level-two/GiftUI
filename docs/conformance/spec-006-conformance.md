---
spec: SPEC-006
feature: giftui-mvp-architecture
title: SPEC-006 Conformance Report
status: complete
reviewers:
  - codex
created: 2026-09-09
updated: 2026-09-11
implementation_plan: ../implementation-plans/spec-006-implementation-plan.md
related_future_work:
  - FW-017
  - FW-020
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-006 Conformance Report

> This complete report records evidence. It does not itself authorize or
> perform the governing Specification's `implemented` transition.

## Review Scope

- Governing contract: [SPEC-006 Declarative View Semantics](../specs/spec-006-declarative-view-semantics.md), status `implemented` after complete conformance review and explicit maintainer authorization on 2026-09-11.
- Derived plan: [SPEC-006 Implementation Plan](../implementation-plans/spec-006-implementation-plan.md), status `completed` after all amendment tasks received dispositions.
- Reviewed implementation revision: `085f52c58a9ee27d6c7652b2f3562bed7416998d`.
- Design note: [bounded semantic expansion](../implementation-designs/spec-006-bounded-semantic-expansion.md), status `current`.
- Environments: Apple Swift 6.3.3 macOS arm64 dynamic/static host execution;
  project-local Swift 6.3.2 ARMv6 and Embedded Swift/nRF52840 hardware-free
  cross-build and artifact inspection.

The Proposal, RFC, and ADR authority chain remains accepted/approved. SPEC-006
remains required for the Signal Analyzer's fixed non-trivial
hierarchy and common Rank 0 semantics across all four MVP configurations.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `DV-001` | pass | [Portable declarations](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-6/portable-declarations.md), [action and custom-view surface](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-1/action-and-custom-view.md) | Exact portable imports, declarations, action codes, external conformance, and unevaluated `Never` compile in all profiles. |
| `DV-002` | pass | [Builder and wrappers](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-1/builder-and-wrappers.md), [builder boundaries](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-1/builder-lowering-boundaries.md) | Zero-through-five, conditional, and optional forms pass; direct six-child and dynamic-array forms fail closed. |
| `DV-003` | pass | [Declaration corpus](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-3/declaration-corpus.md), [complexity](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-6/complexity.md) | Active bodies are synchronous and once-only; inactive work is unobserved; canonical order, summaries, and constant work ratios pass. |
| `DV-004` | pass | [Identity relations](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-3/identity-relations.md), [dependency surface](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-6/dependency-surface.md) | Repetition, branch changes, removal/restoration, collision injection, and absence of public raw identity pass. |
| `DV-005` | pass | [Modifier corpus](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-3/modifier-corpus.md), [normative audit](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-7/normative-audit.md) | Source and nesting order are exact, with no semantic-node identity or layout/render meaning. |
| `DV-006` | pass | [Action corpus](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-3/action-corpus.md), [dependency surface](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-6/dependency-surface.md) | Stable distinct semantic identities pass without generation, target, callable, handler, model, capture, or invocation. |
| `DV-007` | pass | [Boundary matrix](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-4/boundary-matrix.md), [detection order](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-4/detection-order.md), [owner mapping](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-4/owner-mapping.md) | Every limit and coincident failure passes with atomic discard, stable precedence, exact fact mapping, and reusable storage. |
| `DV-008` | pass | [Framework invariants](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-4/framework-invariants.md), [owner mapping](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-4/owner-mapping.md) | Alias, reentrancy, invalid-limit, sealed-protocol, and diagnostic-isolation cases preserve exact results. |
| `DV-009` | pass | [Semantic profiles](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-6/semantic-profiles.md) | All four profiles validate the same complete corpus digest and normalized values. |
| `DV-010` | pass | [Layout and allocation](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-6/layout-allocation.md), [complexity](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-6/complexity.md) | Static SIL has no heap allocation; layouts, nonwrapping bounds, depth, ARMv6 ELF, and nRF hard-float ABI pass. |
| `DV-011` | pass | [Semantic Core leaf](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-0/semantic-core-leaf.md), [dependency surface](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-6/dependency-surface.md) | Exact package partial order, imports, interfaces, and underscored-reference allow-list pass. |
| `DV-012` | pass | [Normative audit](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-7/normative-audit.md) | Scope scans find no downstream layout, render, state ownership, input, capability, backend, frame, or host policy. |
| `DV-013` | pass | [Migration baseline](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-0/migration-baseline.md), [normative audit](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-7/normative-audit.md) | All 23 historical rows are resolved with no compatibility shim or second expansion engine. |
| `DV-014` | pass | [Deferred-work review](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-7/deferred-work.md) | FW-017 and FW-020 remain reciprocal, untriggered, optional post-MVP captures with no implementation dependency. |
| `DV-015` | pass | [Stateful binding](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-5/stateful-binding.md), [stateful binding failures](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-5/stateful-binding-failures.md) | Generated binding precedes one body on success; all twelve binding failures publish no body or semantic result. |
| `DV-016` | pass | [Primitive with content](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-8/primitive-with-content.md), [semantic profiles](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-6/semantic-profiles.md) | Both typed primitive overloads compile without a compatibility hook; containers stage before `fixedChild(0)` content with exact identities/order, zero body evaluation, bounded failures, atomic reuse, equal profile meaning, zero optimized allocation instructions, and hard-float artifact evidence. |

## Required-Test Results

At reviewed revision `085f52c58a9ee27d6c7652b2f3562bed7416998d`,
the four standalone commands below passed with common run identity
`085f52c58a9ee27d6c7652b2f3562bed7416998d-4256b4ebf2b2e167`:

- `scripts/contracts/run-spec-006.sh --profile macos-dynamic`
- `scripts/contracts/run-spec-006.sh --profile macos-static`
- `scripts/contracts/run-spec-006.sh --profile raspberry-pi-armv6`
- `scripts/contracts/run-spec-006.sh --profile nrf52840-embedded`

The full Swift package suite also passes 292 tests. Each contract report records
the compiler digest/version, exact commands, input and artifact hashes,
repository cleanliness, target, optimization, and successful exit.

## Profile, Backend, and Platform Evidence

macOS dynamic and static are host-executed compile and semantic evidence for
`arm64-apple-macosx26.0` with Apple Swift 6.3.3. Raspberry Pi evidence is an
ARMv6 hard-float cross-build and ELF inspection for
`armv6-unknown-linux-gnueabihf`; nRF evidence is an Embedded Swift cross-build
and ELF inspection for `armv7em-none-none-eabi`, Cortex-M4F hard-float, and
`nrf52840dk/nrf52840`, both using project-local Swift 6.3.2. Backend and
capability facts are symbolic independence inputs only. No simulator, remote
Pi, connected board, deployment, service restart, or flashing is claimed.

Every profile compiled the exact package-only primitive-with-content fixture
and validated the same 29-case, 158-event canonical corpus with maximum depth
12. The nested amendment case stages four container primitives before their
ordered children and applies four modifier scopes in source-call order.

## Resource and Performance Evidence

The shared layout probe enforces one-byte `SemanticExpansionError`, ten-byte
limits/summary maxima, and a twelve-byte result maximum. Optimized static-path
SIL contains no heap-allocation instruction. Geometric scales 1, 2, 4, 8, and
16 preserve constant per-unit ratios for ten work counters; the base includes
all four nested container semantic stages. Rejected inactive subtrees stop at
the fixed third attempted event and publish zero work. ARMv6 and nRF objects
carry the required ABI attributes, including VFP-register arguments on nRF.

## Deviations and Exceptions

No implementation divergence, failed criterion, or approved exception is
known. Connected-target execution and downstream layout, rendering,
interaction, backend, runtime-profile, and host integration are explicitly
owned by other Specifications and are not evidence gaps for this independent
Rank 0 contract.

## Deferred Work Audit

FW-017 and FW-020 remain captured, reciprocal, unpromoted, and outside MVP.
Their concrete triggers have not fired, and neither item conceals required
current work.

## Review Conclusion

All sixteen criteria have reproducible passing evidence, including the
amended primitive-with-content contract across all four profiles. No review
gate remains open, and this report supports the Specification's separately
authorized `implemented` transition. The maintainer explicitly authorized
that transition on 2026-09-11, conditional on this review finding no issues;
the review satisfied that condition. This report records the authorization
but does not itself perform the transition.
