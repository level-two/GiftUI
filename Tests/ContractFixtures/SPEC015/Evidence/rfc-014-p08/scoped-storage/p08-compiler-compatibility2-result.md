# P08 grouped lifetime continuation — independent result and boundary assessment

**Disposition: FAILED at a diagnostic classifier; STOP at this activity boundary.**
Independent Sol 6.1 High read-only review of candidate `cab1c415`,
[source review](p08-compiler-compatibility2-independent-source-review.md)
`2989ca7f`, [activity/freeze](p08-compiler-compatibility2-source-freeze.md) and
[immutable evidence packet](compiler-compatibility2-counter/manifest.json).
Accepted ADR-039 and approved S11/S13/S15 remain authority. No source/driver fix,
compiler, formatter, probe, variant, runtime or subagent during this assessment.
Only this report and packet are committed; parent maintains current navigation.

## Exact result and classification

The [single authorized invocation](compiler-compatibility2-counter/result.json)
started at clean `2989ca7f` and exited **1**, output
`.build/contracts/p08-counter-sztjx6jq`. The actual `counter-model` step successfully
compiled P08CounterRuntime before the scoped controls; its log has warnings and
no errors, and actual object/module artifacts are present and
[hashed](compiler-compatibility2-counter/module-identities.json). Thus L01–L03's
previous emitted module errors and the earlier assertion are no longer present
in this native compilation. This is actual compiler progress, not runtime, target,
whole-matrix or full conformance acceptance.

[211 recorded commands](compiler-compatibility2-counter/commands.txt) consist of
19 preparation/module commands followed by **192 attempted scoped controls**.
The driver's sequential stop rule establishes **191 driver-accepted controls:
96 positives and 95 negatives**. These are driver acceptance dispositions, not
independent acceptance of every earlier diagnostic's intended cause. The
[complete control record](compiler-compatibility2-counter/control-statuses.json)
preserves ordering, source/log hashes, errors and statuses. Per-compiler numeric
negative exit codes were not persisted before the overall failure; the record
labels their nonzero exit class as inferred from driver logic/logs, without
inventing individual numeric codes.

The 192nd control,
`so06-erasure-static-generic-active-host-closure-negative`, is **oracle-rejected**.
Its [negative log](compiler-compatibility2-counter/controls/so06-erasure-static-generic-active-host-closure-negative.log)
contains exactly two errors at generated source line **2520**:

- `'input' is borrowed and cannot be consumed`, with a note at the returned closure.
- `lifetime-dependent variable 'input' escapes its scope`, with notes at that return
  and the reference inside the closure.

There is no other error, compiler assertion or fatal diagnostic in this log.
The [exact negative source](compiler-compatibility2-counter/so06-erasure-static-generic-active-host-closure-negative.swift)
returns `() -> Int` capturing the borrowed actual generic Static host carrier.
The immediately preceding
[positive twin](compiler-compatibility2-counter/so06-erasure-static-generic-active-host-closure-positive.swift)
instead invokes a nonescaping `scoped` callback and returns Int; its
[log](compiler-compatibility2-counter/controls/so06-erasure-static-generic-active-host-closure-positive.log)
has no errors and that step was accepted by the driver. Both include the same
frozen trusted prefix and same actual generic host constraints. The negative's
two errors therefore identify the intended returned-closure ownership/lifetime
boundary, rather than a shared unrelated trusted-source failure.

`check-spec-015-counter.py:257` expects the tuple `('escaping',)` for this family.
`run` at 110–122 requires nonzero compiler exit **and every expected substring**.
The log says **“escapes its scope”**, and contains no **“escaping”** substring.
That spelling mismatch explains the driver's stop. The negative has diagnostic
evidence consistent with its intended rejection; **its recorded check and the
overall invocation remain failed**. This assessment does not relabel the 192nd
control as passed or complete the remaining validation from inferred behavior.

## Next coherent correction invariant

The next package-boundary recommendation is a focused **diagnostic-classifier
correction** retaining the exact positive twins and full registered matrix.
For each affected returned-closure negative, require a nonzero compiler result
and a recognized lifetime/ownership diagnostic at that generated probe's intended
borrowed input/closure-return site. A finite expected diagnostic family may include
the pinned compiler's observed lifetime-dependent escape wording; accompanying
borrowed-consumption errors must be attributable to the same intended capture.
Do not accept arbitrary nonzero failures, a generic `error`/`borrowed` substring,
unrelated trusted-prefix errors, a crashing compiler or missing diagnostics.
The corresponding positive must still compile under identical source/flags.

Review the shared finite closure-negative registration for equivalent wording
requirements as one coherent classifier boundary. Preserve actual source bodies,
384 non-Embedded/202 Embedded controls, order, five Native exclusivity controls,
26 reuse labels and all runtime/platform/resource obligations. No matrix reduction,
source-lifetime relaxation, result-cache substitution or compiler flag/toolchain
change follows from this failure. Any correction and subsequent registered
invocation need renewed explicit authorization; no candidate, run or repair
allowance is inferred here.

## Boundary accounting, deferred work and unknowns

Compatibility 2 is exhausted: **candidate 1/1, invocation 1/1 failed, automatic
repairs 0**. Historical integrated corrections remain **2/2 consumed** with both
affected reruns failed; compatibility 1 remains closed after its failed run.
This activity made productive progress through module compilation and 191
driver-accepted controls, but progress does not reset these allowances or the
cumulative guard.

The initial matrix still has **three qualifying component passes** (SPEC-011
459 assertions, SPEC-013 5,904, scoped-host 187) and one failed counter cell.
Their exact noncompiled applicability qualification remains necessary. **Ten
initial profile cells and two images remain unrun.** The counter invocation did
not finish its 384 scoped controls, five Native exclusivity controls, link or
execute; no actual counter runtime, reuse action/semantic/pixel result or full
driver result receipt exists. No other profile, target or numerical fit is proved.

All nine SO criteria, HC-RD-003/P08/R07/T8.1 and fit remain open. The historical
**58,648-byte failure / unchanged 27,648-byte main-stack ceiling** is not replaced.
I4-07/P09–12, hardware/timing and lifecycle transitions remain separate; Specs
implementing, plans active. No accepted contract change or implemented transition.

During the run, documentation-only commit `f9fc6431` captured
[FW-038: Scoped Contract Validation Cost](../../../../../../docs/future-work/fw-038-scoped-contract-validation-cost.md).
The nine frozen source hashes remain unchanged. That optional work records repeated
compilation cost for later investigation; it authorizes no optimization, experiment
or reduction of the current mandatory matrix. The classifier failure remains
current required correctness, not deferred work.

## Preservation and review checks

The packet preserves wrapper argv/result/stdout/stderr, complete commands,
counter-model log, all 192 control logs, per-control source/log hashes/statuses,
the exact final positive/negative source pair and successful module artifact
hashes. Generated objects and other complete variant sources are not copied.
Manifest hashes, nine unchanged source identities, counts/order, final error
locations and missing expected substring are verified. Whitespace and local
report links pass. These checks preserve evidence and distinguish compiler/module
progress from the failed oracle and unrun runtime/resource acceptance.
