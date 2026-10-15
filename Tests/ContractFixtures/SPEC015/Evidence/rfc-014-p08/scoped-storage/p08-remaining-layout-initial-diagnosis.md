# P08 initial layout materialization diagnosis — 2026-10-15

Read-only diagnosis of clean `105edebe` and the actual focused build
`.build/nrf52840/contracts/p08-counter-h4tyo2r0`. The
[immutable failure packet](remaining-layout-initial-failure/manifest.json) pins
the original wrapper/receipt/commands/logs, all input hashes, the actual compiler
and 2,795,992-byte counter object, complete selected-section disassembly and
every measurement symbol/body/relocation. The original receipt and commands are
losslessly gzip-compressed; the manifest retains their original hashes. All
original artifact hashes and the actual compiler hash were rechecked.

The run has **24 preparation/module passes, 202 deliberately not-run controls,
one failed layout extraction**. It is partial failing evidence, not a full
collection. The receipt SHA-256 is
`afb483c18a5bd812ef02b6712f0b703214ee08630532a3e39b95e6b2335234eb`;
the object SHA-256 is
`356b19c08a27b2335519893a2d7a44378e93c6db4bc72e2b82a0143d98058c8f`.
No compiler, target runtime, build, image, source variant or rerun occurred in
this diagnosis. Maintained source and fixture hygiene are unchanged.

## Proved causes

**Inventory classification:** all **129** exact expected exported roots exist,
each a global defined Thumb function. The sole extra prefixed symbol is
`giftui_p08_layout_limits_offsetTm`, a **local** compiler-generated shared helper.
The prefix-only set comparison incorrectly treats it as an additional exported
measurement root. There is no missing source registration, visibility failure
or elided required root in this object.

**The measurement is also invalid independently of that classification:** every
exported root is four bytes `fff7feff` with an `R_ARM_THM_CALL` relocation.
Their paths converge through `giftui_p08_layout_b0_alignment` to the shared
28-byte helper. It subtracts **752** from SP, calls the zeroing/region-array
initializers, then executes `udf #254`; it has no return. All 129 roots fail the
unchanged per-root strict decoder individually. Ignoring the local helper alone
cannot produce numeric evidence, and these call/trap bodies must not be accepted.

The current supplied extent **30,176** is insufficient for the actual checked
target layout. The preserved general initializer disassembly identifies its
supplied byte count in r5 and R1 surplus in r6. The roots use the default zero
surplus. These exact late-offset operations prove the failing bound:

| Existing initializer offsets | Target-compiled operation, zero R1 surplus |
| --- | --- |
| `+0x45a`, `+0x476`–`+0x482` | R1 retained extent = `484 + surplus`; start `26844`, end `27328`; compare with supplied extent. |
| `+0x4b8`–`+0x4d8` | Align H1 start to 4 (still `27328`), add `460`, giving end `27788`. |
| `+0x4e0`–`+0x51e` | Align the next control start to 8, giving `27792`. |
| `+0x520`–`+0x52a` | Add actual control extent `4200`, giving `31992`; compare supplied count and branch to nil at `+0x5ba` when smaller. |
| `+0x560`–`+0x5aa` | Add the final Bool byte (`31993`) and checked round-up to maximum alignment 8: required slot extent **32000**. |

Thus the current `30176` input necessarily fails at the control region even
before final rounding. This explains the roots' constant failure path; it is
not evidence that successful-layout folding is unsupported. The checked required
four-slot total is `32000 * 4 = 128000`; current C retained bytes are
`30176 * 4 = 120704`. Correcting all four slots adds **7296 RAM bytes**. Neither
these diagnostic arithmetic facts nor the module pass establish resource fit.
The strict SO07 numeric table and actual SO08 C-symbol comparison remain absent.

The two live source literals are `counterEmbeddedSlotBytes` in
`StaticCounterEmbeddedBacking.swift` and `[4][30176]` in `counter_main.c`.
Other uses derive from the Swift constant: route-entry byte count, checked slot
selection, the Embedded outer's minimum, the two-slot surplus reservation and
both measurement helpers. The source-consistency test separately pins the two
literals. No semantic element count, workload, physical region order or approved
resource ceiling needs to change.

## Proposed grouped correction 1/2

1. Set the Swift/C supplied slot extent consistently to the actual target-derived
   minimum **32000**, preserving four slots, alignment, every region/count and
   checked arithmetic. Update only the corresponding source-consistency test and
   current source freeze. Parent explicitly dispositions this as the authorized
   existing-contract reservation correction; it is not a capacity/ceiling waiver.
2. Classify the root inventory by exact required global defined function names;
   separately record/allow **only** the known local nonexport helper above.
   Continue rejecting any other extra/missing/duplicate root and every call,
   relocation, stack/trap body or nonconstant sequence. Add actual-object-shaped
   compiler-free regressions; do not weaken the decoder to accept this failure.
3. Preserve all failure/source records. Freeze the coherent correction and obtain
   independent Strong assessment before one fresh existing nRF
   `so07-layout-facts` focused invocation. All four full collections remain held.

After the extent correction, exported roots might still contain merging thunks,
helper calls or stack work; this is **unknown**, not solved by inference. Such
output must fail unchanged strict decoding and retain its actual evidence.
No extra instruction form, relaxed guard, speculative optimization attribute,
compiler flag, new probe or automatic source variant is proposed here. Actual
firmware/C symbol size, all slot-origin alignments, full retained cost, complete
stack/IRQ/RAM/flash proof and P08 acceptance remain open. The initial pass is
failed; no corrective source freeze has occurred, so current consumption remains
**0/2** until the proposed candidate is frozen. Historical budgets stay closed.
