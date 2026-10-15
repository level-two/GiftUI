# P08 collected-suite repair batch — 2026-10-15

Status: **repair batch complete; independent package review PASS**. The requested
batch collected the registered four-profile P08 baseline, grouped routine defects,
and validated the corrected code with focused native/ARMv6 checks and a complete
Embedded counter collection. This is completion of the repair batch, not P08
acceptance or a resource-fit claim. Source correction `73e5dcf1` was independently
reviewed at `76dca6cf`; earlier source and diagnosis commits remain immutable.
[Independent package review](p08-suite-collection-independent-package-review.md)
confirms the evidence and coverage limits below.

## Baseline and corrections

The baseline covered the existing fourteen-cell component/counter matrix. Three
unchanged Dynamic component cells retained qualified predecessor evidence; the
remaining component cells were collected. Native interaction/runtime/host checks
passed (459/5,904/187 assertions per profile); both target interaction/runtime
modules cross-compiled. All four counter collections completed their planned
inventory, retaining failed and blocked checks rather than stopping at the first
error. Dynamic's 192 legacy observations retain their original provenance and
unknown numeric negative exit codes.

| Collected problem | Correction | Validation |
| --- | --- | --- |
| Six negative diagnostic matchers rejected legitimate lifetime diagnostics | Finite primary-diagnostic alternatives with mandatory lifetime error and exact generated-probe sites | All 22 selected compiler checks passed on both native profiles at `6eaeb9fc` and on ARMv6 at current source |
| Async negative fixture compiled because it did not attempt the transfer | Actual async call inside the synchronous storage callback, paired with a synchronous positive control | Positive compiles; negative rejects at the intended callback boundary |
| Embedded counter module lacked a direct Interaction import | Added the required import | Current Embedded module and scoped collection results below |
| Native Static G4 Optional's stride tail overlapped the following slot | Private typed G4 tail wrapper with unchanged disjointness/containment guards and full storage accounting | Both native runtimes and exclusivity controls pass |
| Empty drawing oracle read an unpublished summary | Inspect actual empty counts through the existing typed synchronous loan | Both native runtimes and all thirteen reuse observations per profile pass |
| Implicated warning sites and one missing explicit return in the grouped correction | Corrected closure spelling/unused binding and returned the nested pointer loan | Current module preparation passes on all four profiles |

The [diagnosis](p08-suite-collection-diagnosis.md),
[source receipt](p08-suite-cycle2-source.md), and
[independent source review with follow-ups](p08-suite-cycle2-independent-source-review.md)
record causes, exact changes and failed intermediate runs. No matcher accepts a
compiler crash, an unrelated primary error, or a failed positive twin.

## Corrected-source validation

| Profile | Fresh result | Coverage |
| --- | --- | --- |
| macOS Static | 1,736,158 runtime assertions, zero failures; all thirteen reuse observations and five exclusivity controls pass | 40 checks pass; 384 scoped compiler checks deliberately not run in this final runtime subset |
| macOS Dynamic | 1,736,082 runtime assertions, zero failures; all thirteen reuse observations and five exclusivity controls pass | 40 checks pass; 384 scoped compiler checks deliberately not run in this final runtime subset |
| Raspberry Pi ARMv6 | Current modules and all 22 selected compiler checks pass | 47 checks pass; 362 scoped checks not run; compile evidence only |
| nRF52840 Embedded | 226 checks pass, zero failures; complete collection, exit 0 | Full fresh 202 scoped controls plus 24 preparation checks; compile evidence only |

The native 22-check compiler subsets also passed on the immediately preceding
source (`6eaeb9fc`); the final change only repaired the empty-drawing oracle. They
remain prior-source observations rather than silently reused current coverage.
Current native and ARMv6 focused receipts intentionally report
`collection_complete=false`, `passed=false`, and `focused_passed=true`.
No full four-profile corrected-source suite pass is claimed.

The final warning scan found two unused `d` bindings in
`CounterScopedStorage.reset()` (lines 1045 and 1048), repeated in non-Embedded
compilations; they are warnings, not failed checks. Embedded logs have no located
warnings. These bindings are reported explicitly rather than claiming a
warning-free suite; cleanup can accompany the next source-changing P08 step.
This batch makes no further source edit after the validated candidate.

The immutable [evidence manifest](suite-collection-results/manifest.json) hashes
original receipts, logs, generated probes and commands in the accompanying
archive. It includes original baseline failures and both same-cycle follow-ups.
The archive excludes compiled binaries, whose hashes and original build paths
remain in the receipts. Wrapper records retain exact invocation, source revision,
exit status and timestamps; no failed result was rewritten as a pass.

## Package boundary

The two authorized grouped correction cycles are consumed: productive harness
setup (cycle 1), then the collected-suite correction including its explicit-return
and empty-drawing-oracle follow-ups (cycle 2). Historical repair budgets remain
closed; this report does not reset a repair allowance. Routine defects were
handled together without per-error approval stops. Contract, scope, resource and
toolchain decisions remain maintainer decisions.

The registered source limits, compiler/toolchain pins, targets and complete
384/202-case inventories remain unchanged. No hardware deployment, restart or
flash occurred. Full corrected-source acceptance coverage, both target images,
the nine SO criteria, HC-RD-003, R07/T8.1 and P08/fit remain open. The existing
27,648-byte stack ceiling and historical 58,648-byte failure are unchanged;
this batch supplies no replacement fit evidence. FW-038 retains the deferred
validation-cost work without changing the approved corpus.

Package documentation checks: governance validation (199 authority nodes / 2,022
edges), 521 local Markdown links and `git diff --check` pass. The archive was
reread and all 7,456 recorded member hashes verified; it is 1,471,892 bytes.
The source step already passed the formatter and 29 compiler-free collection
tests before the recorded compiler/runtime validation.
