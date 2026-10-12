# One R07 GOT-placement diagnostic — 2026-10-12

Entry433599e3; Sol6.1 High / Strong. The independently prescribed **single link
passed: actual exit0, 0.172 seconds**, with an isolated pre0 ELF and map.
This is a diagnostic control, not a production recipe or final Zephyr image.
R07/P08 and HC-RD-003 remain open; stop for separate Strong review.

## Exact inputs and change

All346frozen input hashes matched before preparation and after linking, including
333objects and the app archive. The generated current pre0 script matched its
frozen copy byte for byte. Exactly one four-pattern GOT DISCARD block matched;
[script.diff](script.diff) replaces only that block with the reviewed
.r07_diagnostic_got ALIGN(4) output section in FLASH, without KEEP.

[invocation.json](invocation.json) records full argv/cwd, original/control hashes,
elapsed time, output hashes and the only three operand substitutions: -T, -o and
-Wl,-Map output. Original GC/orphan flags and every other argument were preserved.
One link invocation, zero retries, source/compiler/build/config changes or repairs.
[stdout](stdout.log) is empty; [stderr](stderr.log) retains orphan warnings.
The recorder returned success separately from the actual link exit0.

Outputs remain isolated at:
.build/nrf52840/contracts/r07-got-placement/zephyr_pre0-got.elf and
zephyr_pre0-got.map. ELF SHA256
9ccca06fe99ce036f6471768922e71f4a25c6b876db0f5c8bf4cb454f5ccec38;
map SHA256
3bb8b7313d1f507112e20dc71d0557c6c50404f9b9069623fc76b810ec2fa88c.
The complete map is also preserved as zephyr_pre0-got.map.gz; decompression
reproduces that hash. No binary ELF duplication is committed.

## Read-only retained-code findings

[Map excerpts](map-excerpts.txt), [GOT hex](got-hex.txt),
[selected symbols](selected-symbols.txt), [sections](sections.txt), and
[intersection disassembly](intersection-disassembly.txt) show:

- .r07_diagnostic_got at0x487bc occupies20bytes: twelve .got.plt bytes and eight
  .got bytes. The two little-endian GOT words are0x0002662f and0x00000405.
- Those match the retained Thumb function symbols swift_setDeallocating and
  swift_initStackObject respectively (WEAK PROTECTED); the actual code addresses
  are0x2662e and0x404. This is static linked data, not a new runtime stub.
- The specialized RasterFillCoverage.intersection copy from
  RasterFillCoverage.swift.obj survives at0x1e50,size0x154; the same section in
  CounterTiledRaster.swift.obj is discarded. The input relocation evidence in
  the independent review identifies the surviving copy's two R_ARM_GOT_PREL
  references to these runtime functions.
- The unchanged orphan warnings coexist with successful linking. They are
  not themselves a sufficient failure cause.

[inspection.json](inspection.json) contains all read-only commands/results and
artifact hashes. No target executable was run. Transition from frozen exit1 to
exit0 under the sole script difference, with retained GOT/runtime references,
establishes this frozen pre0 script/GOT interaction. It does not prove the exact
reference-binutils internal failure branch ran.

## Review boundary

The one-link diagnostic budget is consumed1/1. Stop: no second variant,
production edit, automatic repair, source rewrite or runtime/compiler/limit choice.
Separate Strong review owns disposition and any focused production-recipe
proposal. This control's FLASH placement is not accepted for production.
Historical helper2/2+B031/1 remain permanently closed; no guard reset.

No compiler/SDK/Zephyr pin, owner/API, workload/assertion, entropy/constructor,
mainstack27648, heap0, RAM196608 or flash1048576 change. No deploy/flash/hardware.
Final supported Zephyr image/HEX and its ARMv7EM/VFP, zeroheap/allocator,
RAM/flash and actual root/corpus gross-stack evidence remain pending. Pi remains
its separately qualified early image. P09–P12 untouched, no P08 exit approval.
