# P08 control-resident correction 1 — focused independent source review

**SOURCE PASS at `8e747182`; B01 closed.** Review of the
[cycle 1 freeze](p08-control-resident-cycle1-source-freeze.md) and exact patch
confirms the bounded G03 correction. No additional source blocker is found;
compiler, runtime/exclusivity and fit acceptance remain unproved.

Native/Tiled borrowing getters project all 13 actual nonpayload backend fields:
active, reservation/submission/finish/cancel counts, submitted bytes/rows, health,
published endpoint health and construction/projection/envelope diagnostics.
These are original values, not endpoint-counter substitutes. Native UInt16 rows
widen losslessly to UInt32; Tiled UInt32 rows are read directly. The owned result
contains no callback, pointer, payload array or live owner; no mutation, parent
copy or callback occurs in either getter. Physical code-generation costs remain
for measurement, not inferred from borrowing syntax.

CounterRuntimeSlotObservation now contains this Equatable backend value, so the
unchanged single stale fingerprint and duplicate/wrong-owner before/after baseline
compare it automatically. Four full keys, all 64 recording entries, independent
accepted lastFrame, operation order and every previous field remain. Only these
three Swift paths change; lifecycle, producer guards, field loans, namespaces,
labels, layout and strict measurement logic are unchanged.

Exact source/driver/test hashes and patch verify. Seven predecessor receipt hashes,
exclusion metadata and original source identities are unchanged; eight current
candidate hashes and corrected metadata pins match. Driver changes only the exact
qualification path/hash/activity constants. Python AST and the **four focused
compiler-free backend-observation regressions PASS**. The just-reviewed 895/180
source-input and unchanged artifact proof was not repeated. No Swift compiler,
build, runtime, image or source edit was performed in this review.

Correction **1/2 consumed**; initial measurement pending, old allowances closed.
Proceed with the exact command below. Strict decoded facts remain diagnostic and
accepted=false; expected old 32,000-byte reservation mismatch must remain a failed
SO07 validation until exact measured Swift/C sizing and reviewed verification.
No partial receipt qualifies for full current-source image/acceptance handoff.
P08/R07/T8.1/HC-RD-003 and complete resource proof remain open.

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded --host-build .build/contracts/p08-scoped-host-hzs5q7za --collect-failures --fresh-focused --select-family so07-layout-facts
```
