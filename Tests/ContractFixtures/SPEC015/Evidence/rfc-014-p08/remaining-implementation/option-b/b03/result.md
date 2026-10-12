# P08-B03 — single native attempt, frozen outcome

2026-10-12. **PASS for this bounded invocation; separate Strong result review
pending.** Entry `102382d7b2c8af48db932c8695eacd67747aac56`, with only the
parent-authored B03 evidence dispatch dirty. Strong `gpt-6.1-sol`, high, C3/R3;
sequential/no delegation. B01 independent review passed and the parent inspected
the committed B02 diff against its reviewed pattern. No source changed in B03.

## Exact prerequisites and invocation

[Preflight](preflight.json): all 492 B01 dependency comparisons matched, plus
the current identities of all four documented historical source exceptions
(496 comparisons total). No stale/missing dependency and no refresh/rebuild
outside the predeclared driver. `scripts/format-swift.sh` exited0, emitted no
output and changed no maintained source. Its normal formatter availability/version
check was part of that required command. [Source identities](source-identities.json)
record the post-formatter, pre-invocation source at B02 commit.

Invoked exactly once from the repository root:

```sh
python3 scripts/contracts/check-spec-015-counter.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static
```

[Invocation record](invocation.json): started `2026-10-12T11:02:32.016536+00:00`,
finished `2026-10-12T11:04:03.848576+00:00`; **exit0**. Build:
`.build/contracts/p08-counter-s6e2ayc7`. Full driver stdout/stderr is
[gate.log](gate.log); exact child command sequence is
[commands.txt](reports/commands.txt). There was no repair, rerun, alternate probe,
compiler switch or target build. The driver's predeclared fresh selected-module
builds remain inside this single invocation; no dependency graph was refreshed.

## Frozen result and identities

```text
P08 counter components assertions=1348673 failures=0
```

All **23/23** driver checks passed: fourteen selected GiftUI module builds,
counter lowering, three generated counter module builds, actual counter-model
module, copy/backing rejection controls, link and execution. The counter-model
stage that previously failed in the removed borrowing helper now completes.
The two expected compiler rejection controls exit1 and satisfy their exact
diagnostic predicates; the other21 checks exit0. Their full diagnostic logs are
frozen with all module and execution logs in `reports/`. The graph fixture reports
46 checks; the total is46 above last validated step7f's1,348,627, whose driver
did not yet include the later graph call. No historical failure is overwritten.

The pinned dependency route and result receipt profile are `macos-static`,
target `arm64-apple-macosx26.0`, using the approved Swift6.4 compiler file
`.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swiftc`, SHA-256
`79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`.
Exact Osize/WMO, LifetimeDependence/Lifetimes, SDK, macro and module search flags
are in commands.txt. This executable invokes both actual concrete native
Static/Dynamic counter coordinator and scoped-host paths; it is not two fresh
registered profile-driver routes or four-configuration evidence.

[Frozen driver receipt](reports/result.json) records all commands/check statuses,
compiler/runtime/host receipt identities, 190 source input hashes and121 generated
artifact identities. [Freeze manifest](freeze.json) separately verifies all190
current inputs and121 build artifact hashes/sizes; freezes all49 top-level text
reports/generated-source artifacts (755,939 bytes) and190 exact source snapshots
(1,683,950 bytes). Sources are under `sources/` with original repository paths.
Binary modules/objects/executable remain under the named `.build/` directory;
their exact identities are frozen, with no claim that a source snapshot alone
replaces the executable evidence. Independent review can inspect these artifacts
without rebuilding or repeating the counter gate.

Newly authored receipts/metadata pass the whitespace check. The plain staged
`git diff --check` reports existing/generated whitespace in six frozen
source/diagnostic files (generated Counter and backing-negative source, copy
diagnostic, and snapshots of CounterGeometry/ProfileStorage/StaticGeometry).
Their exact original bytes are preserved; no evidence or source was rewritten
to silence that check. This is a frozen-evidence whitespace limitation, not a
compiler/gate failure or a reason to rerun the attempt.

## Applicability, open gates and stop

This result establishes only the bounded native B02 realization plus the existing
driver's actual controls. It does not close HC-003/011/014/018, HC-RD-001–004 or
P08. All recorded [B01 operational/origin coverage gaps](../b01-inventory.md#separate-operational-binding-and-required-coverage)
remain mandatory remaining-P08 obligations: rejected-admission wake/timestamp
invariance; multiple fact categories behind nonfact wake; actual foreign binding/
control/report rejection; production burst/category boundaries; actual
nonretryable refusal/supersession; every actual activation failure/backing expiry;
required-origin/callback-indirection rejection before later projection. A passing
positive mask vector and structural negatives cannot establish the last item.
Actual Embedded endpoint, four registered application routes, early linked target
images/resources/ABI and independent P08 exit also remain open. No connected
hardware or full resource conformance is claimed.

Historical repair **2/2 stays closed**. B03 native allowance is **1/1 consumed**.
Freeze/commit and **stop for separate Strong result review regardless of PASS**;
this result authorizes no repair, rerun or automatic remaining-P08 work.
SPEC-015 remains implementing, plan active, T8.1/P08 open and P09–P12 pending.
The parent B03 dispatch and outcome are included in this step's commit.
