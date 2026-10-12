# R07 supported image: link PASS, gross-stack FAIL — 2026-10-12

Sourcee5620a35, Sol6.1 High / Strong. The **single supported build passes
actual exit0**, producing the final Zephyr ELF/HEX/map. Actual retained counter
frames exceed mainstack27648, so **R07/P08 remain incomplete**. Stop for separate
Strong review; no automatic repair, second invocation or target execution.

## Exact supported build

[invocation.json](invocation.json) records the supported build.sh argv, source
patch identity, formatter exit0, actual build exit0 and4.876seconds elapsed.
[Full log](build.log) retains all warnings. Initial supported-build budget1/1
consumed; no retry/variant. Source step changes only Counter.cmake's RODATA hook
and the prescribed counter_got.ld. Original source/runtime/flags/workload/limits
remain unchanged; no normal-analyzer recipe edit.

Final artifacts are at the emitted
.build/nrf52840/signal-analyzer-static/rfc014-counter-firmware/zephyr/
zephyr.elf, zephyr.hex, zephyr.map and zephyr.dts.
[Output identities](output-identities.json) preserve exact ELF/HEX/maps/DTS,
generated pre0/final scripts, config/reports and333object/archive hashes.
Full maps/DTS/disassembly/symbols are compressed beside this result; scripts and
reports are preserved directly. Diagnostic control remains separate and intact.

## Final image checks

The supported verifier confirms ARMv7E-M/VFP calling convention and retained
counter entry, actual SPI initialize/write/shutdown and fault symbols.
[LOAD summary](memory-summary.txt): flash297604/1048576bytes,
RAM31616/196608bytes. These are linked sections/configured stack, not peak
runtime consumption or proof that the counter call frames fit.

[Exact GOT layout](got-layout.json) and [map excerpt](got-map-excerpt.txt):
20bytes at0x487bc–0x487d0 within rodata and ROM0–0x80000. Its12-byte header is
zero; two words0x2662f/0x405 equal final Thumb swift_setDeallocating/
swift_initStackObject symbols. Containing flash LOAD has VMA=LMA0, so this
span's VMA=LMA0x487bc. Initialized RAM LOAD starts VMA0x20000000 with
LMA0x487d0, after the GOT span; the table has no RAM copy. The final ELF has
[no remaining relocations](relocations.txt), no dynamic relocation requirement.
The table precedes __rodata_region_end and ROM alignment/accounting; production
does not reuse the diagnostic post-ROM layout.

[Allocator check](allocator-check.json) confirms heap pool and libc arena0,
and absence of malloc/calloc/realloc/aligned_alloc/k_malloc/k_calloc/k_realloc
function entries. Retained Swift allocation thunks and existing posix_memalign
refusal stub are explicit: the stub returns12, and swift_allocObject traps when
it receives no memory. This is no working heap allocator, not evidence that
all allocation-call code is absent or every error path was dynamically tested.
[Exact linked excerpts](allocator-excerpts.txt) preserve that qualification.
Constructor/entropy config remains disabled; no new runtime behavior.

## Actual-root gross-stack failure

[Root/prologue evidence](stack-root-prologues.txt),
[demangled identities](selected-demangled-symbols.txt), and
[gross-stack.json](gross-stack.json) identify actual final code:

| Retained function | Address | Local SP reservations | Saved registers | Observed local frame |
| --- | --- | --- | --- | --- |
| p08CounterGraph | 0x20f28 | 32256 + 52 | 36 | **32344** |
| p08CounterHost | 0x1935c | 120832 + 348 | 36 | **121216** |
| selected Static counterHostCorpus | 0x18d24 | 4352 + 28 | 36 | 4416 |
| selected corpus click | 0x1d688 | 8320 + 36 | 36 | 8392 |

Both graph and host individually exceed27648: by4696 and93568bytes.
Actual Cmain passes spi_tft_write_rgb565 into giftui_rfc014_counter_entry.
The retained Swift entry wrapper calls graph first, then host sequentially.
These oversized frames are directly on the selected root path; graph and host
are not added together as concurrent frames. Smaller C/entry/callee frames and
IRQ overlap only strengthen the need for a complete bound; the individual
failures already establish gross no-fit. No hardcoded historical entry-stack
number, target high-water observation or full P11 peak proof is claimed.

## Required independent disposition

This is an implementation/resource failure, not a proven need to change the
contract. Independent Strong review must determine whether approved caller-owned
backing/layout supports a bounded local realization, or identify the smallest
actual contract/scope decision. No such fix is selected here. Do not enlarge
stack/heap/RAM, reduce assertions/workload, flatten owners, change compiler flags
or add runtime behavior to make the image appear feasible.

Mainstack27648, heap0, RAM196608, flash1048576 and source semantics are unchanged.
Historicalhelper2/2+B031/1 and diagnostic1/1 stay closed; this continuation ran one
reviewed source correction and one initial supported validation, no follow-on
repair. R07/P08/T8.1/HC-RD-003 remain open; P09–P12 untouched. Pi remains its
separate qualified early result. No hardware, deploy or flash.
