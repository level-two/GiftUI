# Independent R07 residual-link review — 2026-10-12

Reviewed clean `fc7a380b` sequentially with Sol6.1 High / Strong. **R07 and
P08 remain open. No production correction is accepted by this review.** One
isolated GOT-placement diagnostic is supported by the existing evidence; stop
after its result for independent disposition. This is an implementation-tool
investigation within current authorization, not a new human contract gate.

## Authority and applicability

SPEC-015 is implementing, its plan active and T8.1 / HC-RD-003 open. Accepted
ADR-035/036/037/038 and the approved SPEC-015 amendments govern the counter.
ITERATION-003 I3-04 / IT-AC-006 requires runtime-derived counter/analyzer routes;
IT-AC-008 requires actual Embedded-image resource evidence. ITERATION-001's
Signal Analyzer and four-stack validation remain regression constraints.
Read the executor/platform skills, governance, current plan/context checkpoints,
recipe receipt/results, and prior early-image independent review.

All346 frozen input identities match current bytes, including333objects,
app archive, build/rules/cache, scripts and SDK inspector/linker. The four
diagnostic receipts each report actual link exit1. No compiler/linker/test
variant, source fix, target execution or hardware action ran in this review.
Read-only SDK readelf and host nm inspections are captured in
[independent-inspection.json](independent-inspection.json).

## Independently checked findings

The actual command uses Cortex-M4/thumb/AAPCS/hard-float, static/nostdlib,
Zephyr's generated pre0 script, whole-archive app/Zephyr libraries followed by
kernel/libc/libgcc, and GC. Its current Swift compilation commands already
include `-wmo`, firmware defines, function sections and disable-stack-protector.
The original missing-flag diagnosis therefore does not support another compiler
flag change. The C entry still passes synchronous `spi_tft_write_rgb565` to the
actual counter root.

Orphan-place still exits1 with no orphan warnings. No-inhibit still produces
no ELF. No-GC reports the six kernel/entropy undefined symbols recorded in the
checkpoint, but changes reachability and still has no usable image. These are
not evidence for enabling entropy/constructors, removing GC or suppressing
warnings. All five731-line maps contain archive extraction only, without final
retained sections/LOADs. Their byte identity cannot identify which internal
linker phase failed. The script's constructor assertion remains intact; its
message is absent from the corrected supported failure.

There is a more precise input/script conflict to test. Readelf successfully
reads all app-archive relocations with empty stderr. Exactly four are
`R_ARM_GOT_PREL`: offsets0x14c/0x150 in
`RasterFillCoverage.swift.obj` and `CounterTiledRaster.swift.obj`, all in the
specialized `RasterFillCoverage.intersection` section, against
`swift_initStackObject` / `swift_setDeallocating`. The references are global
undefined in those members; the archive also contains weak protected runtime
definitions. They are not the no-GC kernel/entropy symbols.

The frozen script at lines281–286 explicitly discards `.got.plt`, `.igot.plt`,
`.got` and `.igot`. `-Xcc -fno-pic/-fno-pie` does not erase these observed Swift
object relocations. Their existence does not yet prove that this exact
intersection copy is live after GC, that a GOT must remain in the final image,
or that source semantics/ownership must change.

The already-downloaded reference `/private/tmp/giftui-r07-elf32-arm.c`
(hash in the inspection receipt) strengthens this lead. Its ARM relocation
handling explicitly allocates GOT entries for R_ARM_GOT_PREL. At lines17304–
17308, `elf32_arm_finish_dynamic_sections` silently returns false when its
`sgotplt` output section is absolute, with the adjacent comment identifying a
discarded linker-script section. This is a plausible matching silent-failure
mechanism, not a captured call stack or proof that the SDK's patched binary
took that branch. The installed Mach-O linker has no exported BFD error/final-
link symbols in `nm -g`; an assumed symbolic BFD breakpoint is not a concrete
ready diagnostic here.

## One finite next diagnostic

Use the exact `original_command` array and `cwd` from [invocation.json](invocation.json).
Prepare an isolated copy of its frozen linker script, changing **only** its
one four-pattern GOT `/DISCARD/` block to:

```ld
.r07_diagnostic_got : ALIGN(4) {
 *(.got.plt)
 *(.igot.plt)
 *(.got)
 *(.igot)
} > FLASH
```

Do not add KEEP or change any other script text. Assert exactly one original
block match before writing. Preserve the original script hash and the exact
script diff. In the original argument array replace only the `-T` operand,
`-o` operand and `-Wl,-Map,` output with isolated paths under
`.build/nrf52840/contracts/r07-got-placement/`. Invoke that array exactly once
from the original cwd, recording full argv, stdout/stderr, actual exit, elapsed
time, script hashes and output identities. No `-v`, no orphan change, no GC
change, no compiler/build regeneration. The invocation is the existing GCC
driver plus precisely these three operand substitutions; use an argument-array
recorder rather than shell reconstruction. A recorder's success is not a link
pass. Budget: **one link invocation, zero automatic retries or repairs**.

If this links, preserve its ELF/map and inspect whether `.r07_diagnostic_got`
contains the two runtime entries and which intersection section survived. A
transition from the unchanged exit1 to exit0 under this sole script difference,
with retained GOT data and relocations explained, establishes the script/GOT
interaction for this frozen pre0 link and permits a focused production-recipe
proposal. It does not accept the control script for production, prove the
reference source branch executed, or replace final Zephyr image/resource review.

If the error becomes explicit, record its exact cause for separate review;
do not correct it in the same continuation. If silent exit1 remains, stop and
report the lead inconclusive: actual BFD failure-site evidence or matching SDK
diagnostic symbols are still missing. No option sweep, metadata deletion,
alternative linker/toolchain, source rewrite or speculative contract exception
follows from that result. A control ELF is diagnostic only, never a deliverable.

## Unchanged exit boundary

No compiler/SDK/Zephyr pin, runtime configuration, constructor/entropy behavior,
owner/API, workload/assertion, stack/heap or resource ceiling change. Preserve
main stack27648, heap0, RAM196608 and flash1048576. Do not execute/flash the
control image. Only an independently reviewed final linked production image
can support nRF ARMv7E-M/VFP, zero-heap/allocator, RAM/flash and actual root/
corpus gross-stack dispositions. Pi remains its separate qualified result.
P09–P12 untouched. Historical helper2/2 and B031/1 stay permanently closed;
this review ran zero production repairs and does not reset any allowance.
