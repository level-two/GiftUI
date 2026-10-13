---
id: SPIKE-075
feature: external-application-integration
title: P08 Scoped and Owned State Feasibility
status: completed
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

Prepared 526 disposable Swift lines after scope commit `722f5862`.
[Strong preflight review](../../experiments/spike-075-p08-state-feasibility/preflight-review.md)
found the fixture ready for one bounded run, committed as `861f012b`.
Run `20261013T155029Z-b1c24da8` passed the shadow module and positive client on
macOS Dynamic, then stopped at the copy negative: its helper inadvertently
required Escapable as well as Copyable. Three experiments and one identity query
ran, with zero repairs. All escape negatives and other profiles remain unrun.
[Evidence](../../experiments/spike-075-p08-state-feasibility/evidence/run-1/receipt.json)
and [Strong package review](../../experiments/spike-075-p08-state-feasibility/package-review.md)
preserve the inconclusive disposition and the minimum proposed harness correction.

The authorized continuation, prepared in `1dbe456b` with raw evidence committed
in `743e8cf8`, passed the corrected copy negative and then accepted Escape0.
It stopped immediately after two additional experiments and one identity query
(cumulative five and two). [Strong continuation review](../../experiments/spike-075-p08-state-feasibility/continuation-exit-review.md)
finds the outcome inconclusive: the inner lexical block does not establish a
hard end to the trivial local backing's lifetime. No unsafe escape or compiler
bug is established. Remaining escape checks and all target profiles are unrun.

The final approved function-return pair passed Strong diagnostic review:
caller-owned return compiled, and returning the bank0-backed local state was
rejected with an explicit bank0 lifetime/return diagnostic. The
[final result](../../experiments/spike-075-p08-state-feasibility/final-result.md)
and [run-3 receipt](../../experiments/spike-075-p08-state-feasibility/evidence/run-3/receipt.json)
record two final compilations and one identity query. Cumulative counts are
seven experiments, three identity queries, one earlier helper correction and
zero new repairs. This is bounded native evidence, not the full state matrix.

## Limitations

- Shadow declarations isolate language feasibility; they are not production
  integration, lifecycle correctness, concurrency, zero-heap or resource proof.
- This gate does not prove common-session mutable exchange, the complete
  supplied/pipeline/coordinator/host/retirement chain or physical initialization.
- Native success is not target evidence; target object acceptance is not target
  execution, ABI conformance or whole-image stack fit.

## Disposition

**Final disposition: completed with a passing bounded native return control;
experiment work closed.** No successor is proposed. Full matrix, integration
and resource proof remain outside this result, and RFC-015 remains draft.

Historical initial disposition: completed as an attempted, **inconclusive** experiment; this status does not mean
the gate passed. The observed blocker is the copy-test helper, not a falsified
RFC declaration. The package's zero-repair boundary prevents a retry. The linked
package review proposes one harness-only correction and at most 30 further
experiments for explicit maintainer disposition; it does not allocate them.
The subsequent maintainer follow-up asks to continue toward conditional RFC
acceptance and P08 readiness. The [bounded continuation](../../experiments/spike-075-p08-state-feasibility/continuation-scope.md)
implements that one-helper proposal within the ongoing minimum-evidence task.
It preserves this initial completed/inconclusive run and all historical counts;
RFC acceptance remains conditional on resolving the actual architectural blockers.
The continuation has now ended at its first unexpected result, with its one
authorized helper correction used and no further repairs. The linked exit review
proposed a separately bounded function-return control pair. The maintainer
subsequently accepted that final pair with an explicit prohibition on indefinite
iterations. Its passing bounded result above closes this experiment work.
If the state gate later passes, record the next minimum carrier/retirement
question before executing it. Full migration,
physical resource accounting and linked stack acceptance remain downstream
implementation/conformance obligations, not prerequisites to this experiment.

## References

- [Final bounded return control](../../experiments/spike-075-p08-state-feasibility/return-boundary-scope.md):
  maintainer accepted two native checks, no repairs and no indefinite continuation.
- [RFC-015](../rfcs/rfc-015-p08-scoped-storage-ownership.md), R1–R4 and B1–B4.
- [Revision review](../iterations/iteration-003-review/rfc-015-revision-review.md).
- [Compiler baseline correction](../iterations/iteration-003-review/rfc-014-compiler-baseline-correction.md).
