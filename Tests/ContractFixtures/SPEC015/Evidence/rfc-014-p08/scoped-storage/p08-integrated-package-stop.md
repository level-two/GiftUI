# P08 integrated package stop — independent Strong assessment, 2026-10-14

**Disposition: STOP; correction allowance 2/2 exhausted, P08 incomplete.**
Independent Sol 6.1 High read-only assessment of final source `8ef34f59`,
[source review](p08-integrated-cycle2-independent-source-review.md) `72bd3a11`
and the [immutable final failure packet](integrated-cycle2-counter/manifest.json).
Conformance-reviewer rules apply to this bounded package disposition; accepted
ADR-039 and approved S11/S13/S15 remain authority. No source change, compiler,
probe, variant, formatter, driver/runtime, target or subagent in this assessment.
No Specification is marked implemented, no requirement is waived or deferred.

## What the final run proves

The final exact macOS Dynamic counter invocation at clean `72bd3a11` exited **1**
at `counter-model`, output `.build/contracts/p08-counter-l5svlxmv`. Preserved
[argv/result](integrated-cycle2-counter/result.json),
[19 commands](integrated-cycle2-counter/commands.txt) and
[compiler log](integrated-cycle2-counter/counter-model.log) identify the unchanged
pinned Swift 6.4/flags, predecessor paths and actual failure.

The prior UInt64/Int error is no longer emitted. The frontend reports an ownership
error in the `p08CounterGraph` callback: a
`mark_unresolved_non_copyable_value [no_consume_or_assign]` of P08StaticOuterView
is used by `copy_addr ... [init]` with owned convention and a non-lifetime-ending
constraint. It then asserts during SILGenCleanup, locating the callback expression
at `CounterScopedStorage.swift:2151–2177`. This establishes **compiler rejection/
crash for this source and invocation**, not accepted source, a proven compiler-bug
root cause or a demonstrated unavoidable architectural conflict.

The actual counter runtime module did not successfully compile; its compiler
positive/negative matrix, native exclusivity execution and reuse semantic/action/
pixel labels were not reached. No full counter result receipt, linked image,
target execution or resource acceptance follows from the prior 18 commands.
The crash can mask additional ownership/code-generation/runtime problems. Prior
source-review dispositions remain limited source evidence, not compiler acceptance.

## Narrow source-backed suspect and next decision

`P08StaticOuterView` is noncopyable (`CounterScopedStorage.swift:1655`), and
`withP08SelectedStatic` lends it as a **borrowing** callback argument
(1688–1689). Within the reported callback, nested local `reject` at 2153–2162
reads `outer.control` inside `precondition` autoclosures (2160); the outer callback
also uses that borrowed aggregate in an assertion at 2174. A capture/cleanup path
trying to own this borrowed noncopyable view is the strongest exact source-backed
suspect for the emitted `copy_addr`. The supplied SIL diagnostic does not map its
instruction to one particular nested capture or assertion, so this is a hypothesis.
The log does not distinguish an illegal implicit source capture from a compiler
lowering/diagnostic defect, and no reduction or corrected candidate has been run.

The next decision belongs at the package boundary: explicitly authorize a **new,
bounded compiler-compatibility diagnosis/correction activity** under the same
contract/toolchain, or choose another reviewed direction. A concrete minimal
starting scope is this borrowing callback, its nested rejection helper and
assertion capture shape. A candidate may avoid capturing the entire borrowed
aggregate by passing only the required owned observation/control facts within
the original synchronous reservation scope, while preserving every live no-effect
check, graph-positive/negative case and complete backing/lifetime obligation.
This is an unvalidated candidate, not a prescribed proven fix. Do not make the
view Copyable, erase storage lifetimes, remove graph controls, disable ownership/
exclusivity checking or substitute a compiler/platform as an implicit workaround.

Any renewed activity should state its exact finite source/invocation allowance,
freeze before execution, retain independent Strong assessment and stop on its
specified failure boundary. One focused source candidate and one existing exact
counter-driver invocation with no automatic repair loop is a concrete bounded
starting proposal; additional reductions, variants, compiler runs or continuation
of remaining matrix/images require inclusion in that renewed authorization.
No such activity is authorized by this assessment. A toolchain or accepted
contract change, if actually needed, takes its separate reviewed decision gate.
No guessed fix or compiler-bug attribution can replace that evidence.

## Package accounting and acceptance disposition

| Boundary | Final disposition |
| --- | --- |
| Initial driver matrix | **4/14 cells consumed:** SPEC-011 macOS Dynamic 459 assertions, SPEC-013 5,904 and scoped-host 187 passed; actual counter failed. Those three unchanged component results retain their exact qualified applicability limits. **10 initial cells unrun.** |
| Corrective counter runs | **2 affected reruns consumed, both failed:** cycle 1 emitted the remaining numeric error; cycle 2 reached ownership/SILGenCleanup failure. No further repair/rerun allowance remains. |
| Early images | **0/2 invoked; both unrun.** Four-profile success prerequisite was not achieved. |
| IN-SO-001/002/003 | Open: complete current four-profile classified matrix, actual transaction/stale controls, physical/caller accounting and compatibility proof remain incomplete. |
| RP-SO-001/002/003 | Open: complete physical/unwind/reuse/exclusivity evidence and target layout/nested-stack/IRQ/ABI/Static-zero-heap/Dynamic allocation proof remain incomplete. |
| HC-SO-001/002/003 | Open: actual complete host carrier matrix, repeated-host runtime proof, current route/caller coverage and early-image/resource acceptance remain incomplete. |
| HC-RD-003/P08/R07/T8.1/fit | Open. Historical **58,648-byte failure** and unchanged **27,648-byte main-stack ceiling** remain; no replacement passing measurement. |
| Separate obligations | I4-07/P09–12, hardware/timing and lifecycle transitions remain separate. SPEC-011/013/015 remain implementing, plans active. |

The corrections made **productive progress**: earlier source causes were repaired,
the numeric error disappeared and the final run exposed a deeper, concrete
ownership/lowering boundary. This is not two consecutive unproductive corrections
or evidence of contract impossibility. It nevertheless cannot override the
independent **2/2 budget stop**. Historical helper/B03/GOT/image/phase/IR/SPIKE-075/
source-correction allowances and the cumulative guard remain unchanged.

No new optional deferred idea is identified. This compiler compatibility and
required safety/fit evidence are current blockers, not Future Work. The complete
requested P08 outcome was not achieved; report the package stop rather than
request another per-file permission or continue with an unbounded candidate search.

## Preserved evidence and review checks

All six final failure files match their immutable manifest hashes; wrapper exit1,
19 commands and the unchanged nine-source cycle 2 identities are verified.
The source diff from `8ef34f59` is empty. Review whitespace and local links pass.
The separate commit contains this assessment and the immutable final packet only.
Parent maintains activity/receipt/plan/context/manifest navigation, governance
checks and the user-facing package report. These checks establish evidence
identity, not successful compilation, runtime behavior or resource conformance.
