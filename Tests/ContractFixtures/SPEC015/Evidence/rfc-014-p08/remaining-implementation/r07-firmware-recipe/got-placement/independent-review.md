# Independent successful GOT-control review — 2026-10-12

Reviewed clean `40acab83`, sequential Sol6.1 High / Strong. **The control
establishes the frozen pre0 script/GOT failure. A bounded production linker
recipe correction is supported within existing authorization.** R07/P08 remain
open until the actual production image and resource evidence are reviewed.
No compiler, linker, diagnostic variant, source repair or hardware action ran
in this review. The control budget remains consumed1/1.

## Evidence and authority

The sole script change turns actual exit1 into exit0 with original objects,
GC and orphan policy. The recorded20bytes comprise12zero GOT-PLT header bytes
and two static resolved Thumb addresses for the existing weak protected
`swift_setDeallocating` and `swift_initStackObject`. The retained
`RasterFillCoverage.intersection` loads these entries; its duplicate is discarded.
This supports preserving emitted link data, rather than changing Swift source,
compiler flags, runtime definitions or workload. Exact SDK internal branch
execution remains unproved and is unnecessary for this local correction.

SPEC-015's schema-4 ledger and HC-RD-003 require actual static initialization,
linked section, zero-heap, stack and ABI accounting within unchanged limits.
They do not forbid statically resolved function-address tables or prescribe
their linker section name. ADR-035/036/037/038 remain unchanged. This is
firmware composition of existing emitted objects, not a new runtime service,
dynamic linking mechanism, ownership boundary or physical budget. No additional
human contract approval is required for this implementation choice.

Do **not** copy the diagnostic block's location into production: it follows
`__rom_region_end` in the frozen script. The installed pinned Zephyr supports
the narrower `zephyr_linker_sources(RODATA ...)` extension. Its
`include/zephyr/arch/arm/cortex_m/scripts/linker.ld` includes
`snippets-rodata.ld` inside the ordinary rodata output section, before ROM
end/MPU alignment accounting and before the four-pattern GOT discard. Its
`cmake/modules/extensions.cmake:1254` documents this hook and recommends RODATA
for content fitting that section. Current configuration already selects XIP,
hard-float and MPU, with flash writes disabled. Resolved immutable entries
belong in the existing ROMABLE region and its flash ledger; no startup copy,
runtime relocation or write is needed. Input SHF_WRITE flags alone do not prove
a runtime write; inspect the actual final layout and relocations below.

## Exact bounded implementation handoff

1. In the current counter branch only, add
   `zephyr_linker_sources(RODATA counter_got.ld)` in `Counter.cmake`, with a
   small adjacent maintained linker snippet containing:

   ```ld
   . = ALIGN(4);
   __giftui_counter_got_start = .;
   *(.got.plt)
   *(.igot.plt)
   *(.got)
   *(.igot)
   __giftui_counter_got_end = .;
   ```

   Document that these are statically resolved Embedded Swift runtime-function
   references. No KEEP, new symbols implementing behavior, generated-script
   patching, Zephyr checkout mutation, warning suppression, GC change, or
   broader normal-analyzer recipe change. The two boundary symbols provide
   exact ledger attribution; they are not a new resource allowance.
2. Preserve the control and failed receipts. Record the two-file patch and
   current input identities. Run the repository formatter, then the existing
   supported command once:

   ```sh
   scripts/nrf52840/build.sh --application signal-analyzer-static --counter-build .build/nrf52840/contracts/p08-counter-7x97oi7d
   ```

   Capture its actual exit, generated pre0/final scripts and all final output
   identities in a new production-attempt evidence directory. This is one
   production validation invocation, no automatic follow-on repair or option
   sweep. CMake's ordinary compilation/link stages are permitted by that
   supported invocation; the consumed diagnostic allowance is not reopened.
3. On success, inspect actual final ELF/HEX/map, ARMv7E-M/VFP, sections/LOADs,
   remaining relocations and runtime/allocator symbols. Confirm the GOT span
   is20bytes, its header is zero and its two words equal the final Thumb
   addresses of those existing functions. Confirm its VMA/LMA lie in accounted
   flash inside the ROM bounds, with no RAM copy/dynamic relocation requirement.
   Any additional entry, startup write or unexpected layout requires exact
   review before adoption; do not silently broaden the snippet or its meaning.
4. Complete the actual selected C root/counter corpus/callee gross-stack
   inspection and linked RAM/flash/zero-heap ledger. Stop on any frame exceeding
   mainstack27648, or any unresolved feasible-path overlap; no hardcoded old
   entry-stack claim. RAM196608, flash1048576 and heap0 remain unchanged.
   Preserve failure or success and obtain separate Strong result review before
   claiming R07 or P08 exit. A successful link alone does not establish stack
   fit, allocation freedom or migration conformance.

No target execution, deploy or flash. No constructor/entropy/runtime configuration,
toolchain pin, owner/API, workload/assertion or ceiling changes. A new genuine
contract requirement must be escalated with its exact evidence; the resolved
linker-script defect itself creates no such gate. Historical helper2/2+B031/1
remain permanently closed. P09–P12 untouched; Pi remains separately qualified.
