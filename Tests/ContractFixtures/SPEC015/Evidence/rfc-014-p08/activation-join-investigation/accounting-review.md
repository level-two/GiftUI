# Independent investigation accounting review — 2026-10-11

**Disposition: the original authorization permits the next CandidateB positive
control; the investigation guard is not established as exhausted.** Strong
Sol 6.1 High, sequential, read-only record review at clean
`0e21d82286d910b033e0aa423994c3148e4df6b8`. No compiler/test, probe or repair ran.

## Accounting basis

The [approved proposal](../activation-join-stop/independent-stop-review.md#concrete-next-authorization-option)
and [authorization](authorization.md) distinguish compiler invocations, candidate
layouts and consecutive unproductive candidate attempts. Every correction counts
as an invocation, but two nonzero exits alone do not establish the latter guard.
The [shared plan](../../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md)
defines unproductive repairs as the same blocker with no passing check or narrowed
cause. This review neither changes that rule nor resets any allowance.

[Run1](run-1/stderr.txt) rejects two caller `consume` expressions on Copyable
fields. [Run2](run-2/stderr.txt), after exactly those two tokens were removed,
no longer reports those errors and reaches concrete CandidateA `activate()`
self-lifetime diagnostics, noncopyable-copy diagnostics and additional caller
imported-non-frozen partial-consumption errors. LayoutA and Supplied source hashes
are unchanged. The two calls therefore do not demonstrate two consecutive
unproductive attempts on an unchanged blocker. This conclusion does not rely
solely on counting layouts: repeated attempts at one layout can exhaust a guard,
but these records show caller setup followed by a narrower candidate rejection.
No isolated initializer pass, positive control pass or compiler-bug attribution
is inferred from the changed diagnostics.

Record **2/6 compiler invocations, 1/2 layouts, zero negatives and zero passing
controls**. Conservatively charge failed CandidateA as **1/2 consecutive
unproductive candidate attempts**; do not treat its diagnostics as a successful
construction or claim a fresh allowance. Preserve the provisional runner count2
and raw [ledger-after-run-2.json](ledger-after-run-2.json), with this independent
interpretation alongside them. The historical production guard remains **2/2**.

## Exact permitted continuation

Reserve **invocation3** for the already authorized CandidateB positive control.
A caller-only correction for the recorded imported-non-frozen partial-consumption
errors is within scope if it retains the actual backing types, all supplying
scopes and initialization/activation calls. It may not rebuild/change imported
modules, introduce another owner layout, remove the real caller, weaken lifetime
dependence or construct the coordinator/endpoint before activation. This is a
scope determination, not a claim that such a caller correction will compile.

If B passes, its separate explicit-copy and outliving-backing negatives remain
required, with every invocation charged to the same six-call total. If it fails,
skip negatives; another unproductive candidate attempt reaches2/2 and stops.
Any correction/rerun must also satisfy that unchanged guard, the two-layout limit
and six-call cap; this review grants no free retry or further hypothesis. Report
the finite result for review. Production stays stopped and P08 incomplete; no
contract amendment, compiler change, package acceptance or production resumption
is authorized here.
