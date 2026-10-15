# P08 control-resident measurement — compilation progresses, fit blocked

**Narrow allowance closed: fix 1/1, measurement 1/1; prior 2/2 remains closed.**
At `dd183fbc`, the registered fresh focused run passed 24 checks, failed layout
extraction and left 202 controls not-run. Counter compilation now succeeds.
Fresh-focused=true; focused-passed, collection-complete and aggregate passed=false.
No compiler retry, source/decoder/reservation change or runtime/image occurred
in this read-only diagnosis. P08/R07/T8.1/HC-RD-003 remain open.

[Receipt manifest](control-resident-predicate-measurement/receipt-manifest.json)
and [actual run archive](control-resident-predicate-measurement/actual-run.tar.xz)
preserve commands, source/compiler identities and logs. Object SHA-256:
`15ac2dea6836ec4c161903a4f98a65851bffe00fd4f2c000da284236d1f1ad59`;
build receipt `6e8a7e33d3a26b4fdb0a93c0df963054c5f529ff7f6c7305c4507598d33ae6f7`;
wrapper result `eb1648edb68d99ed0634aa46c015ff1f68a55ae6fdedabd0b349289ca7092922`.
[Packet hashes](control-resident-predicate-measurement/packet-hashes.json) pin the
derived inspection records. The object itself remains at its recorded build path.

## Official layout failure and diagnostic arithmetic

All 129 exact exported roots are present. The unchanged strict decoder proves 128,
including all 25 region fact, cursor 34,713, alignment 8 and slot 34,720. Sole rejected
root `giftui_p08_layout_totalBytes` is exactly 8 bytes `00487047801e0200`, without
relocation/tail edge: Thumb16 `ldr r0,[pc,#0]` at 0, `bx lr` at 2, inline word
`0x00021e80` at 4. PC=Align(0+4,4)=4, so the load returns 138,880=4×34720.
The immediate-only decoder correctly rejects loads; its destination error reflects
an attempted wide-immediate interpretation, not an actual non-r0 destination.

[All root bodies/relocations](control-resident-predicate-measurement/root-analysis.json)
and [manual diagnostic](control-resident-predicate-measurement/manual-layout-diagnostic.json)
separate 128 strict proofs from the manual literal proof. Checked independent region
arithmetic validates disjointness, offsets, overflow and roundup using diagnostic
derived extent, **not** current capacity. Control is 6,920 size/stride, alignment 8,
offset 27,792. Required diagnostic slot 34,720/four-slot138880 adds 10,880 bytes over
old 128,000. Swift/C remain 32,000×4; runtime bounds stay enforced. There is no official
raw-facts or accepted layout output, and no official extractor PASS.

## Required stack path still exceeds 27,648

[Exact path](control-resident-predicate-measurement/required-stack-path.json) binds
ET_REL sections and actual symbol-table/index relocation targets. [Bounded disassembly](control-resident-predicate-measurement/required-stack-disassembly.txt.xz)
is the review entrypoint. Each edge is direct R_ARM_THM_CALL; caller frames remain.

| Function / section | Frame bytes | Next call offset |
| --- | ---: | ---: |
| p08RunStaticSessionPhase /3869 |12664|1730|
| p08RunStaticHostPhase /3861 |1528|24|
| p08RunReuseHost specialization /3760 |2680|100|
| p08ReuseRejectOldOrigins specialization /3720 |9136|400|
| p08ReuseRejectAction specialization /3672 |8552|deeper calls omitted|
| **Simultaneous lower bound** |**34560**|**6912 excess**|

Source feasibility: session early 0 reaches its host phase while retaining lexical
host/deferred cleanup; nonnil reuse selects reuse; transcript.hosts==1 (second host)
selects old-origin rejection; its stale-action call is unconditional. Mutually
exclusive branches are not summed. Current undersized reservation blocks successful
runtime entry; this is the source-required path with valid supplied backing after
measured sizing, not an executed runtime claim. Outer/root, deeper fingerprint,
helper and IRQ costs are omitted, so no complete upper bound is claimed.

The initial diagnostic prologue parser missed `subw`: host phase28+1500=1528,
reuse36+2644=2680. [Saved metadata](control-resident-predicate-measurement/frames-and-calls.json.xz)
now explicitly records/corrects all affected entries from saved prologues; its
original packet hash and before/after corrections are retained. No ELF changed.
Session fell from 26,072 to 12,664; root is 128. Full baseline/stale checking still
contributes 9,136/8,552. Old 66,864 included deeper calls than this conservative 34,560
path, so their difference is not a like-for-like whole-path saving. Exact residual
copy attribution and complete upper bounds remain unproved.

## Concrete next package — proposal only

Separately review finite literal-leaf support for this exact 8-byte shape: LDR r0
PC0, BX LR, owned inline word, unique executable function bounds, no relocations
or mutable/external data. Compiler-free negative tests must reject other loads,
registers/offsets, extra bytes, aliases, truncation and relocations. Re-read this
**same** object after tooling correction; no compiler is needed for that proof.
Then independently review exact measured Swift/C 34,720 spacing and 138,880 charge
before affected rebuilding. No decoder or sizing edit is applied here.

Complete nested main/IRQ upper-bound and current-image RAM accounting should follow
before another source variant or resource-limit decision. Acceptance remains 27,648;
no modest increase is yet justified by an upper bound. Only conditionally reusing
the **old** image's other RAM, backing+10880 reduces old 36,864 headroom to 25,984,
allowing at most 53,632 main-stack bytes at zero residual margin. This is planning
arithmetic, not current image/MPU/IRQ fit or a proposed limit. No 30-KiB claim follows.

Evidence hash/absence/source checks and read-only objdump/demangling were performed.
One broad initial extraction completed; subsequent conclusion uses only the bounded
saved chain. An unnecessary process-list escalation was interrupted and provides
no evidence. There were no additional compiler executions or source changes.
