# SPIKE-075 run-1 minimum continuation

The latest maintainer follow-up requests the minimum RFC-015 evidence, bounded
sequential work, a commit for each step and preserved historical repair limits.
It conditionally requests RFC acceptance and required downstream documents only
if readiness is established. This continuation implements the one-helper
proposal in [package-review.md](package-review.md); it does not itself establish
readiness or approve RFC-015. The original [SPIKE-075 scope](../../docs/spikes/spike-075-p08-state-feasibility.md),
failed run, report and immutable source snapshots remain historical evidence.

Exactly one fixture correction is allowed: replace
`func requireCopy<T: Copyable>(_ value: T)` with
`func requireCopy<T: Copyable & ~Escapable>(_ value: borrowing T)`.
No RFC declaration, state contract, lifetime annotation, protocol constraint or
strict diagnostic matcher changes. No further repair is allocated.

Use `run.py --continue-run-1` only after independent Strong preflight review.
Before any compiler invocation, verify original evidence and emitted-artifact
hashes (including every native module companion), original source snapshots,
all unchanged Swift inputs, the exact helper-only diff, and compiler/SDK inputs.
A missing or mismatched input stops without rebuilding the native module.
Import the original verified native module, skipping its passed emission and
positive client. Run the corrected copy negative and five escape negatives;
only on success run the same eight checks for macOS Static, ARMv6 Dynamic and
Embedded Static. Execute sequentially, stopping at the first unexpected result,
with at most **30 additional compiler experiments**, **two identity queries**,
and **20 minutes from the first compiler invocation**, at most 180 seconds per
invocation. No linking, execution, hardware or production changes.

A unique continuation receipt preserves the parent receipt hash, its three
experiments and one identity query, its failed copy test, the one fixture repair
and cumulative counts: at most 33 experiments and three identity queries. The
original failure remains counted. Historical closed helper/B03/GOT/image/phase/
diagnostic allowances and the two-consecutive-unproductive-repairs rule remain
unchanged; unused calls grant no automatic retry.

Passing this gate establishes only state-language feasibility. Full carrier,
session and retirement feasibility and an ownership/cleanup plan remain distinct
readiness questions. Conditional RFC approval must await the remaining readiness
evidence and explicit lifecycle disposition; downstream ADR/Specification work
must follow the applicable approval gates.

## Preflight disposition

Sequential Strong review (Sol 6.1 High) found one inventory omission before
execution: the saved module includes `P08Shadow.abi.json`. Its original hash and
size are now preserved and included in the whole-artifact-set check. A focused
recheck returned **ready for the bounded continuation**. No compiler or runner
was executed during either preflight; this metadata correction adds no compiler
repair or invocation. The one Swift helper correction is unchanged.
