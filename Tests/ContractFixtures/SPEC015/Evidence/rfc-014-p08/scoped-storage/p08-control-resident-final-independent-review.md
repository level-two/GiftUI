# P08 control-resident package — independent final boundary review

**Evidence verification PASS; compilation BLOCKED; package STOP at 2/2.**
The [final result](p08-control-resident-final-result.md) accurately records the
failed measurement at `37ba818a`, with fixture source unchanged at `999de5f9`.
This is a compiler failure before materialization, not a measured layout or fit
failure. P08/R07/T8.1/HC-RD-003 remain open.

The actual `p08-counter-uhsvmp_l/counter-model.log` hashes to
`db169588ecb7dbbb84c26c062a23f15cca8620864cfc0f6b893c038ce3b99019`.
It contains exactly two primary errors: borrowed self is captured by an escaping
closure in CounterPipelineOwner.swift:73 and :78. Notes identify stored-field
reads inside short-circuit RHS autoclosures on lines 74–75 and 79. Both final
preconditions already use owned Bool locals. The previous eight extension-bound
errors are absent: the compiler advanced to this distinct cause, without proving
later compilation or code generation acceptance.

The proposed correction is precise and preserves the existing contract: evaluate
all seven vacancy predicates and four claim predicates separately into owned
Bools, then combine only those Bools. These are pure stored-field comparisons;
eager evaluation preserves the original phase/owner/endpoint/four-key checks.
No control copy, refreshed baseline, owner, capability or lifetime change is
needed. Merely wrapping the existing compound expression in another Bool local
would retain the diagnosed capture. This correction is not applied here.

The finite audit of newly introduced borrowing helpers finds no other occurrence
of this same borrowed-self Boolean RHS pattern. The private cleanup helper reads
idle/inactive separately; Native/Tiled backend getters return direct scalar facts;
recording equality combines owned local copies. Endpoint/slot observations are
direct owned projections. The synchronous semantic producer callback remains a
separate lifetime-sensitive surface whose compiler acceptance is not established
by this failed run. Mutating claim/install/clear predicates are not these borrowed
signatures. Existing full identity, 64-record, lastFrame and single-baseline checks
remain required; this audit does not promise absence of later diagnostics.

The [failure manifest](control-resident-cycle2-measurement-failure/failure.json),
actual artifact hashes/sizes, archive and every archived member, compressed failed
source and current source identity verify. Actual receipt statuses are **23 pass,
1 counter-model failure, 1 blocked layout check and 202 not-run**. Fresh focused
is true; focused_passed, collection_complete and passed are false. Counter object,
raw decoded facts and accepted layout receipt are absent. The old 32,000-byte
reservation remains unchanged; no new size, stack, runtime or resource result
exists. No qualification history or unchanged input corpus was re-audited.

The next concrete decision is whether to authorize **one bounded mechanical
predicate correction, independent source review and one identical focused
measurement rerun**, with fresh exact pins and preserved failure evidence. This
requires additional narrow allowance because both package corrections are spent;
it does not require an architecture or resource-limit amendment. Further compiler
errors remain possible. Strict actual facts must still precede the already planned
measured Swift/C sizing completion. No third variant or rerun is authorized by
this review. Historical budgets stay closed.

This verification used existing source/logs, hashes and receipt inspection only.
No maintained source edit, compiler, test, build, runtime or image invocation ran.
