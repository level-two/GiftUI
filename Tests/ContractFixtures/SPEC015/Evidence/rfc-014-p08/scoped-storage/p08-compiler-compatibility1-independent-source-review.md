# P08 compiler compatibility 1 — independent Strong SOURCE review

**Disposition: source ready for the one authorized exact counter invocation.**
Independent Sol 6.1 High review of clean `bbb54fc1`, diff from `c1339c16`,
[authorized activity](p08-compiler-compatibility1-activity.md),
[source freeze](p08-compiler-compatibility1-source-freeze.md),
[manifest](p08-compiler-compatibility1-source-manifest.json) and
[qualification](p08-compiler-compatibility1-applicability.json).
Accepted ADR-039 and approved S11/S13/S15 remain authority. The prior
[package-stop diagnosis](p08-integrated-package-stop.md) identifies a capture
suspect; this source review does not prove its compiler root cause or acceptance.
No source fix, compiler, formatter, build, probe, driver/runtime or subagent here.

| Focus | Independent source assessment |
| --- | --- |
| Reported graph capture | `CounterScopedStorage.swift:2169–2193` borrows outer only for its direct audit and local control-pointer projection. Nested `reject` and both assertion paths capture the existing Copyable typed pointer, rereading the live pointee each time. Every graph mask, negative/positive case, validation ordering, no-later-read assertion, observation count and live no-effect check remains. No counter snapshot or constant replaces a live check. This removes the exact source-backed aggregate-capture suspect; whether it resolves the SILGenCleanup failure remains unproved. |
| Analogous Static callbacks | `1934–1968` projects original root/semantic/Canvas/control typed pointers, original buffer descriptors and owned limits before the nested foreign/model/semantic/Canvas/session callbacks. The same initialized addresses/counts feed MutableSpan and the same actual owner withLifetime calls. Outer audit remains a direct borrowing operation. No owned backing copy/allocation is introduced. |
| Analogous Dynamic callbacks | `2078–2106` makes the equivalent existing pointer/limits projections before its actual nested lifetime callbacks. It does not copy Dynamic workspace/backing, manufacture COW storage aliases, retain a model/root target or change profile semantics. |
| Projection boundary | All changed projection locals and callbacks end within the original synchronous selected reservation/function call; all actual returns are owned Int counts. Original typed field/buffer loans still enclose these callbacks. No pointer is added to an external return, global, task or escaping closure; no new capability getter/generic escape wrapper is introduced. Existing complete scoped carrier/model/root/semantic/values/control lifetime unions, private access declarations and exclusive session ownership remain. Raw pointer locals retain the existing trusted synchronous discipline; this is not a claim that unsafe-pointer values intrinsically receive compiler-bounded storage lifetime. |
| Transcript nesting and release | Static `1993–2016` and Dynamic `2123–2146` enclose each selected reservation with the transcript-pointer scope. Direct run/reconstruct/audit operations still borrow outer; assertion autoclosures use local control. Both host scopes return and retirement/empty/inventory checks precede `endRetainedObservations`, then `owner.release`. The helper at 1471–1473 clears every action/event/admission/application/revision Optional before release; after release only empty observations and host count remain. These owned observation types contain no custom destructor/deferred callback that touches backing. Original reverse destruction checks and all reuse labels remain. |
| Prior findings and resources | C01's exact conversion, C02–C05, B01's retained original capture→actual pointer/seal/mutating dispatch and O01's complete stale fingerprint are unchanged. No Copyable-view workaround, lifetime suppression, second transaction/dirty state, removed oracle or changed flags/platform/workload/limits. Added owned projections and wider transcript context still need actual family24/helper-frame/nested-stack/IRQ accounting; no numerical fit follows. |

The driver only selects this named activity's immutable qualification, validates
the activity identity and records it with qualification use. The exact three
predecessor receipt hashes/original source hashes, conservative recorded Swift
argv-path hashes/counts **112/173/53**, source exclusion and new corrected source
hash are verified. CounterScopedStorage is the sole changed applicability input
and was not compiled by these components. Every actual compiled-input/artifact/
compiler/macro/flags/recipe check and historical r06 fallback remains. Old receipts
and qualifications are unchanged; their whole-source applicability manifests are
not relabeled globally current and passed components are not rerun.

Consistency checks pass: nine source hashes/exactly two changed paths; new
qualification and all three pinned receipts/path lists; all six immutable crash
file hashes; unchanged 26 unique route labels; driver AST without invocation;
whitespace and local review links. The 384/202 compiler controls, five Native
exclusivity controls and positive-before-negative order remain registered.
No additional bounded source blocker or optional deferred discovery is found.

New allowance: **candidate 1/1 consumed; invocation 0/1; automatic repairs 0**.
Parent may format at the validation boundary and perform the one exact registered
macOS Dynamic counter invocation with the original successful predecessor paths.
Stop and report its result at this activity boundary; no second candidate/repair,
new variant/probe or remaining-profile/image continuation is automatically allowed.
Historical integrated corrections remain **2/2 consumed**, with all historical
failures/closed allowances and cumulative guard preserved.

Compiler/root-cause, full matrix/runtime/target and resource acceptance remain
unknown. All nine SO criteria, HC-RD-003/P08/R07/T8.1 and fit remain open;
the historical **58,648-byte failure / unchanged 27,648-byte main-stack ceiling**
is not replaced. I4-07/P09–12, hardware/timing and lifecycle obligations remain
separate; Specifications implementing, plans active. Only this independent review
document changes; parent owns subsequent evidence, navigation and boundary report.
