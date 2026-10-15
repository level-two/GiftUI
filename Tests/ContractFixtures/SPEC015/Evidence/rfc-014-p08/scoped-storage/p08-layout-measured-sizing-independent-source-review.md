# P08 measured reservation completion — independent source review

**SOURCE PASS at `5e463e50`.** The
[sizing freeze](p08-layout-measured-sizing-source-freeze.md) completes the planned
initial measured reservation, with no new representation variant. Tooling/sizing
corrections remain 0/2; all historical allowances stay closed. Fresh current-source
compilation and accepted layout evidence remain pending.

The only Swift/C changes are `counterEmbeddedSlotBytes` and the C backing's second
dimension, each 32,000 → 34,720. Exact substitution reconstructs both current files;
slot count four, C _Alignas(8), all 25 checked regions, runtime bounds, ownership,
cleanup, workload and stack baseline are unchanged. The positive source-constant
expectation and mismatching-C mutation now target the new literal; neither guard
was removed. No runtime/counter receipt is qualified by this source change.

The raw 129-root proof hashes to
`df14bb46b5b316ef0b0ad55b0049885f691f06d6366d3d1a52f19dd6dc48d777`,
binds the previously reviewed object and extractor, and retains accepted=false,
diagnostic_only=true, executed=false. Its entire numeric inventory matches the
previous independently reviewed diagnostic facts. Rechecking all regions against
the proposed source reservation proves cursor 34,713, maximum alignment 8,
rounded slot 34,720, four-slot extent 138,880 and zero retained surplus. All four
origins preserve alignment. The full 10,880-byte backing increase remains charged;
this is not current-image RAM or stack fit evidence.

The immutable extraction archive, original Swift/C bytes, raw/provenance hashes,
wrapper results and log hashes verify. The first attempt failed on the absent
output directory; the prepared second attempt retained facts then failed old
field bounds. Both exits remain 1, and accepted output remains absent. No failed
historical receipt is promoted to acceptance or current-source compilation.

All four source/glue/test hashes and exact patch match. Qualification hash
`91242d203cd6eaf2a86617511a452136524c981fa5c0356a1ddcb142198ac649`
is freshly pinned by the otherwise unchanged driver. Seven predecessor receipt
entries/hashes remain exact; the changed C path is absent from their recorded
inputs/commands. All eight current candidate hashes match, with only the measured
Swift backing hash changed from the prior qualification. Current counter Swift
and firmware C must compile afresh. The already reviewed full input proof was not
repeated. Python AST checks pass; the author's 50 compiler-free test passes are
recorded, not rerun. No object decode, compiler, build, tests, runtime or image ran
in this review; existing proof records alone were read and checked.

Proceed with the registered fresh focused command below. Its partial receipt must
leave 202 controls not-run and aggregate acceptance false. Preserve any actual
failure; no acceptance follows merely from corrected spacing. The existing 34,560
required stack lower bound still exceeds 27,648. Complete main/IRQ accounting and
current linked-memory proof remain necessary before a resource-limit decision;
P08/R07/T8.1/HC-RD-003 remain open.

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded --host-build .build/contracts/p08-scoped-host-hzs5q7za --collect-failures --fresh-focused --select-family so07-layout-facts
```
