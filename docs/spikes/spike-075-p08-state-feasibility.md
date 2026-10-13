---
id: SPIKE-075
feature: external-application-integration
title: P08 Scoped and Owned State Feasibility
status: planned
authors:
  - codex
created: 2026-10-13
updated: 2026-10-13
source:
  - RFC-015
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# SPIKE-075: P08 Scoped and Owned State Feasibility

On 2026-10-13 Eugene authorized “the minimum experiments which are really needed
to gain the required evidence,” sequential execution, bounded delegation,
preserved repair limits, package-boundary reporting and a commit for each step.
Contract or scope decisions must return to the maintainer. This is new, narrow
feasibility authorization under draft [RFC-015](../rfcs/rfc-015-p08-scoped-storage-ownership.md),
not approval of its architecture or reopening of production repair budgets.

## Target Questions

- Can the approved Swift 6.4 compiler express the RFC's exact six protocol Self
  suppressions, five-bank consuming state lifetime union, failable owned-key
  wrapper and four conditional Copyable/Escapable conformances?
- Can owned concrete banks still produce copyable escaping states while scoped
  banks remain usable in scope, noncopyable and dependent on every bank input?

This is the first falsification gate. If the state contract is not expressible,
building the proposed full carrier/session/retirement chain is unnecessary.
Passing this gate alone does not establish that complete chain.

## Bounds / Stop Conditions

- One exact candidate, zero compiler-driven repair rounds, at most 32 compiler
  experiment invocations plus two compiler identity queries; 20 minutes from the
  first compiler invocation. Stop at the first ceiling or unexpected result.
- Sequential profiles: macOS Dynamic, macOS Static, Raspberry Pi 1 ARMv6 Dynamic,
  nRF52840 Embedded Static. Do not proceed past a failing profile/check.
- At most eight experiment invocations per profile: shadow module emission,
  positive client, copy negative, five single-input escape negatives. The positive
  client contains an in-scope twin for each escape and owned copy/return coverage.
- At most 800 disposable Swift lines and one runner under
  `experiments/spike-075-p08-state-feasibility/`. No production source changes,
  whole application builds, linking/execution, firmware image or hardware.
- No alternative state architecture, lifetime erasure, unchecked bypass, compiler
  change or new associated-type semantics. Unexpected diagnostics/crashes are
  preserved and independently reviewed before any new work is proposed.
- Closed helper 2/2, B03 1/1, GOT 1/1, prior image/backing-image, phase
  correction/image and diagnostic-capture 1/1 allowances stay closed. Preserve
  the two-consecutive-unproductive-repairs stop rule and historical counts;
  this package allocates no repair round and resets no counter.
- Commit scope, reviewed fixture, evidence and final disposition as separate
  steps. Use Standard (Sol 6.1 Medium) for bounded fixture preparation and Strong
  (Sol 6.1 High) for read-only review, one assignment at a time.

## Method

Compile an isolated package-visible shadow module and a separate client module.
Copy the six protocol declarations and the state field/initializer/conditional
conformance shapes from the RFC. Use minimal owned stand-ins for domain values
and inert method bodies; do not test production transaction behavior by proxy.
Concrete scoped banks contain Span values derived from actual local typed
InlineArray owners, not freely escaping raw pointer descriptors.

The positive client copies and returns both owned state layers and consumes
scoped layers within real owner lifetimes. Five negatives each shorten exactly
one physical bank input and use the resulting wrapped state afterward; their
positive twins retain that owner through last use. Copy rejection must identify
noncopyability. Escape rejection must identify lifetime escape, not an unrelated
missing witness, access-control error or compiler crash. Use optimized object
emission, not only frontend typechecking. Record all attempted invocations.

## Reproduction

The fixture runner will select compilers through
`scripts/contracts/compiler-baseline.sh`, require
`Apple Swift version 6.4 (swift-6.4-RELEASE)`, and enable LifetimeDependence and
Lifetimes with Swift 6, Osize, whole-module optimization and an isolated module
cache. Use the approved native, ARMv6 SDK and Cortex-M4F hard-float recipes.
Keep native build outputs under `.build/spike-075/`, Pi objects under
`.build/raspberry-pi/spike-075/`, and Embedded objects under
`.build/nrf52840/spike-075/`. Preserve source/compiler/configuration hashes,
commands, exits and diagnostics with the experiment evidence.

## Results

Not run. The scope commit precedes fixture preparation and execution.

## Limitations

- Shadow declarations isolate language feasibility; they are not production
  integration, lifecycle correctness, concurrency, zero-heap or resource proof.
- This gate does not prove common-session mutable exchange, the complete
  supplied/pipeline/coordinator/host/retirement chain or physical initialization.
- Native success is not target evidence; target object acceptance is not target
  execution, ABI conformance or whole-image stack fit.

## Disposition

Planned. A failed architectural premise stops for a maintainer decision. If the
state gate passes, record the next minimum carrier/retirement question before
executing it; do not expand this package's fixed case list. Full migration,
physical resource accounting and linked stack acceptance remain downstream
implementation/conformance obligations, not prerequisites to this experiment.

## References

- [RFC-015](../rfcs/rfc-015-p08-scoped-storage-ownership.md), R1–R4 and B1–B4.
- [Revision review](../iterations/iteration-003-review/rfc-015-revision-review.md).
- [Compiler baseline correction](../iterations/iteration-003-review/rfc-014-compiler-baseline-correction.md).
