# Swift 6.4 actual activation feasibility result — 2026-10-12

The frozen actual activation positive compiles and executes against freshly
rebuilt Swift 6.4 dependencies. Its reachable callback-escape negative is rejected
for the intended lifetime condition. This is a passing bounded feasibility pair,
not P08 acceptance or an adopted compiler baseline.

The official Swift 6.4.0 package reports `Apple Swift version 6.4
(swift-6.4-RELEASE)`. The compiler identity matches the independently verified
compiler-comparison setup receipt. The accepted 6.3.2 pin remains unchanged.

## Fresh dependency graph and results

Calls 1–25 rebuilt GiftUI, the 17 P07 runtime/schema/table/workspace modules,
and the seven P08 host-component dependency modules. Each emitted its module and
object in `.build/contracts/p08-native-6.4`. Every rebuild succeeded. No old
GiftUI module or object search path remained; all imports and linked GiftUI
objects resolve in that new tree. No source incompatibility or command correction
occurred. All 233 source inputs match their governing frozen receipt hashes.

Call 26 compiled and executed the unchanged `activation-boundary` actual positive.
It exercised real coordinator opportunity, accepted rendering, publication and
cleanup. Its five fixture lifecycle assertions passed: zero initial teardowns,
available after activation, successful opportunity, unavailable after quiescence,
and exactly one teardown. Execution exits 0 and ends with
`activation-boundary: five lifecycle assertions and coordinator quiescence passed`.
Complete execution output is in `run-26/execution-stdout.txt`.

Call 27 compiled the unchanged reachable callback negative and exits 1. Its six
errors identify `escaped` as lifetime-dependent escaping its scope. Notes identify
models, root, semantic, Canvas values and control pointer closure captures, and
specifically callback-local `activationBacking`; the escaping use is the callback
return. Although capture notes say that capture dependence is not yet supported,
the explicit marker lifetime diagnosis independently identifies the intended
forbidden callback escape. The positive uses the same source definitions and
supplying scopes successfully. This is not a syntax, SDK or unrelated API failure.
The negative was never executed.

## Reproducibility and bounds

`plan.json` records compiler/macro/receipt/source identities and every original
and remapped command. `sources/` freezes all inputs, including generated source;
`receipts/` freezes the source authority receipts. Each `run-N` contains complete
command, stdout, stderr and raw results with produced module/object hashes.
`ledger.json` records final dispositions; `sha256-manifest.json` freezes evidence.
Post-run verification rechecked all source snapshots, current sources, receipts,
compiler and macro executable hashes.

The corrected scope preserves the original `GIFTUI_DYNAMIC_PROFILE` flag: this is
a native Dynamic-profile host graph using the actual Static coordinator, not a
Static-profile validation. Target, SDK, optimization, feature settings and source
inventory remain frozen; only compiler and output/cache/import/link artifact paths
were remapped. The existing GiftUIMacros executable ran only as a separate host
plugin process via `-load-plugin-executable`. Its identity is recorded; it was not
rebuilt and does not establish complete macro/compiler baseline compatibility.

The scope is closed at 27 of 32 calls, with zero command corrections. No maintained
source, driver, compiler pin, contract or approval status changed. This pair does
not validate the generic host wrapper, copy/backing/constant-marker controls, all
lifecycle failures, Static profile, resource costs, ARMv6 or nRF52840. Independent
review and a baseline decision remain necessary before maintained adoption.
