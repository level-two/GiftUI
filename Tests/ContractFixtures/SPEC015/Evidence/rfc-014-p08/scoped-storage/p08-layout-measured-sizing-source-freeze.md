# P08 measured reservation completion — source freeze

This is the planned initial sizing completion under the
[approved activity](p08-layout-sizing-validation-activity.md), not a new physical
variant or corrective cycle. Tooling/sizing corrections remain 0/2; all prior
allowances stay closed. Baseline `221d974c`. Independent sizing source review is
pending. No compiler/build/runtime/image execution occurred in this source step.

The reviewed decoder read the same object and strictly proved all 129 roots.
Original raw facts SHA-256:
`df14bb46b5b316ef0b0ad55b0049885f691f06d6366d3d1a52f19dd6dc48d777`.
They retain `accepted=false`, `diagnostic_only=true`, kind
`decoded-unvalidated-layout-facts`. Cursor 34,713 rounds to 34,720 at maximum
alignment 8. The full four-slot charge is 138,880, exactly 10,880 above 128,000;
34,720 modulo 8 is zero, so all four origins preserve alignment.

Both actual extraction attempts, exact original Swift/C sources and raw facts were
[archived before editing](layout-measured-sizing-source/prior-extraction.tar.xz).
The first attempt failed only because its destination directory was absent; after
routine directory creation the second retained facts and correctly failed old
32,000-byte bounds. Its wrapper result SHA-256 is
`95de9c6be014e540ab36c02cea5d896a772606892031639aab9917e65af48e4a`.
No accepted SO07 output existed. [Provenance and all 25 numeric regions](layout-measured-sizing-source/measurement-provenance.json)
retain both commands/results/log hashes and checked disjointness/overflow/roundup
against the proposed exact extent. This arithmetic does not relabel the old
object as current-source compilation or the raw facts as accepted layout evidence.

The only runtime-source changes are the measured slot literal in
`StaticCounterEmbeddedBacking.swift` and the matching C `counter_backing[4][34720]`.
Slot count, eight-byte C alignment, derivation, supplied-storage bounds, original
inventory, payload, workload, owner/lifetime/cleanup behavior and stack limit stay
unchanged. The source-constant regression's positive expectation and mismatching
C mutation were updated to the new exact numbers; no check was removed.

[Manifest](layout-measured-sizing-source/manifest.json) and
[patch](layout-measured-sizing-source/source.patch) pin all four source/glue/test
files. New Swift SHA-256:
`c0f13dfa35a11c6f627905d8663bcf716eef2dedb2221cd357380d48c045e51f`;
C SHA-256:
`31c36569948cbf3870ef15df8d25db6247a3434ce55d14d2616247855028f6f4`.
[Exact qualification](p08-layout-measured-sizing-applicability.json) SHA-256
`91242d203cd6eaf2a86617511a452136524c981fa5c0356a1ddcb142198ac649`
is freshly pinned by the counter driver. Seven unchanged component receipt/argv
identities and eight Swift exclusions were rechecked; changed C is absent from
their inputs/argv. The actual driver qualifier verifies eight metadata exceptions.
Changed counter Swift and firmware C still require fresh compilation; no image
or counter receipt is reused through this component qualification.

All 50 compiler-free layout tests, AST/hash/whitespace checks and pinned host
formatter pass. Fixtures are outside formatter scope; no incidental Swift edits.
After independent source PASS, the registered first check is:

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded --host-build .build/contracts/p08-scoped-host-hzs5q7za --collect-failures --fresh-focused --select-family so07-layout-facts
```

This is partial evidence: 202 controls remain not-run and aggregate acceptance
false. Read-only complete main/IRQ path analysis must precede costly broader work;
if not conclusively impossible, current full nRF controls are required before the
guarded current image and linked-memory accounting. The existing required 34,560
stack lower bound already exceeds 27,648, but is not a complete upper bound or
proof against every feasible RAM allocation. No new limit is proposed. P08 and
its aggregate gates remain open.
