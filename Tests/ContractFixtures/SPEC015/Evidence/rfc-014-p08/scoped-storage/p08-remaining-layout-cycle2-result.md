# P08 final focused layout result — 2026-10-15

**Selected layout gate PASS**, source `0d3e3c7d`, independent source review
`51544daa`. Luna 6 Medium ran the exact recorded fresh-focused command once.
Pinned formatter passed without changes; wrapper records clean before/after and
exit 0. [Immutable evidence](remaining-layout-cycle2-pass/manifest.json) retains
receipts, generated probes, commands and logs; compiled object hash remains in
the layout receipt and original build artifact.

Actual build `.build/nrf52840/contracts/p08-counter-9lhfd73s`: **25 passed,
202 not-run**. `fresh_focused=true`, `focused_passed=true`,
`collection_complete=false`, `passed=false`. The partial receipt cannot feed
image acceptance or qualify omitted controls. All 129 facts were proved from the
actual target object without execution (`executed=false`): 25 original regions,
cursor 31,993, maximum alignment 8, rounded slot 32,000, four-slot total 128,000.
The supplied four-slot reservation is 128,000 bytes with zero surplus. No linked
C reservation, complete runtime stack/IRQ, RAM/flash fit or P08 pass is claimed.

Correction cycles **2/2 consumed**; both were productive and the final selected
measurement now passes. Historical budgets remain closed. Continue the already
[frozen four full collections](p08-remaining-execution-freeze.md), reusing only
qualified unchanged component evidence. The complete Embedded collection now
contains 227 checks (24 preparation + 202 scoped + 1 layout). Full current
coverage, both linked images/resource evidence, current caller reconciliation
and independent P08 exit remain open. A new material failure is preserved and
reported under the current exhausted correction boundary, not automatically
repaired or reclassified.
