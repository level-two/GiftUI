# P08 control-resident measurement — independent result review

**Evidence verification PASS; official layout FAIL; intended-workload stack fit
FAIL by lower bound.** The [measurement result](p08-control-resident-predicate-measurement-result.md)
accurately separates compilation progress from acceptance. The narrow fix 1/1 and
rerun 1/1 are closed; historical grouped 2/2 stays closed. No new action is granted
by this review. P08/R07/T8.1/HC-RD-003 remain open.

The actual ET_REL ARM object at `p08-counter-ap7tbjem/P08CounterRuntime.o` hashes to
`15ac2dea6836ec4c161903a4f98a65851bffe00fd4f2c000da284236d1f1ad59`.
Current artifact and derived packet hashes verify. Reading the unchanged strict
constant decoder against this object confirms exactly 128 successful roots and
one rejection. The unique executable Thumb function `giftui_p08_layout_totalBytes`
is exactly eight bytes `00487047801e0200`, with no relocation: LDR r0,[PC,#0],
BX LR, then the owned inline word at offset 4. Aligned PC+4 selects that word,
0x21e80 = 138,880. This is a diagnostic proof of this bounded immutable literal,
not a runtime execution, heap read, general load allowance or official decoder PASS.
No raw-facts or accepted SO07 output was emitted by the failed official extractor.

The other 128 strict values match the saved diagnostic ledger. Independently
checking all 25 region offsets/counts/strides/alignments gives cursor 34,713,
maximum alignment 8, rounded slot 34,720 and four-slot total 138,880. Control is
6,920 bytes at offset 27,792. The 10,880-byte increase over old backing is arithmetic,
not an accepted current reservation. Swift/C still supply 32,000 per slot; the
runtime guard therefore prevents valid workload entry with current backing.

The five recorded frame allocations independently decode from raw Thumb prologues,
including SUBW: **12,664 + 1,528 + 2,680 + 9,136 + 8,552 = 34,560**. Actual SHT_REL
sh_link/symbol-index targets and BL instruction encodings confirm all four edges
3869 → 3861 → 3760 → 3720 → 3672 at offsets 1730/24/100/400. Source selects this
nested path with early=0, nonnil reuse and the second logical host; old-origin
rejection unconditionally calls stale-action rejection. The lexical host/defer
and callers remain live; mutually exclusive branches are not summed. This is a
source-required path after adequate measured backing is supplied, not an executed
current-image path. It exceeds 27,648 by 6,912 before outer/deeper/IRQ costs, and is
not a complete maximum or a like-for-like comparison with the historical deeper
66,864 path. The saved parser's SUBW correction is material and now accurate.

Actual receipt statuses verify: 24 pass (including counter compilation), one
layout failure and 202 not-run; fresh_focused=true and focused_passed,
collection_complete, passed=false. No current runtime/image or complete peak is
proved. Conditional old-image arithmetic is also correct: adding 10,880 backing
leaves 25,984 of old headroom, and 27,648+25,984=53,632 at zero residual margin.
Those values cannot establish current ELF/MPU/IRQ fit or justify a proposed ceiling.

Recommended next decision: authorize a finite tooling/evidence package for the
exact eight-byte literal leaf, with negative cases for other registers/offsets,
external or mutable data, relocation, aliases, extra bytes and truncation. Require
unique function/section bounds and an in-body immutable literal in object and ELF;
retain the immediate/tail grammar unchanged otherwise. Re-read this same object
without recompilation, then independently review the planned exact measured
Swift/C 34,720 spacing and full 138,880 charge before affected rebuilding. Complete
nested main/IRQ accounting and current ELF RAM evidence are needed before a limit
or further implementation decision. No blind source variant or stack increase is
recommended. All closed repair allowances require a new explicit bounded decision.

This review used bounded existing object/source/receipt records only. It changed
no maintained source or decoder and ran no compiler, build, tests, runtime or image.
